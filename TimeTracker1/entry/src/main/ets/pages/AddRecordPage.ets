/**
 * AddRecordPage.ets - 添加/编辑工时记录页面
 * 
 * 功能：
 * - 选择工作类型（9种类型）
 * - 输入项目名称
 * - 设置时薪
 * - 选择开始/结束时间
 * - 选择日期
 * - 保存工时记录
 */

import { router } from '@kit.ArkUI';
import type { WorkRecord, WorkType, WorkRecordFields } from '@ohos/commonlib';
import { storageUtils, EventBus, EventKey, ThemeManager, type ThemeColors } from '@ohos/commonlib';
import promptAction from '@ohos.promptAction';

// 识别历史记录接口
interface RecognitionHistoryItem {
  text: string;
  parsedFields: WorkRecordFields;
}

// 路由参数接口
interface RouterParams {
  recordId?: string;
  date?: string;
  voiceParsedData?: WorkRecordFields;
  recognitionHistory?: RecognitionHistoryItem[];
}

// 常量定义
const DEFAULT_HOURLY_RATE = 30;
const HOURS_IN_DAY = 24;
const MINUTES_IN_HOUR = 60;
const HOURS_IN_HALF_DAY = 12;
const PRECISION_MULTIPLIER = 100;
const TIME_PAD_LENGTH = 2;
const RANDOM_ID_LENGTH = 9;
const RADIX_36 = 36;
const TOAST_DURATION = 3000;
const FIRST_INDEX = 0;
const SECOND_INDEX = 1;
const THIRD_INDEX = 2;

// 班次类型定义
const WORK_TYPES: WorkType[] = [
  { id: 'day', name: '白班', icon: 'BUG', color: '#2196F3' },
  { id: 'night', name: '夜班', icon: 'BUG', color: '#9C27B0' },
  { id: 'rest', name: '休息', icon: 'BUG', color: '#4CAF50' },
  { id: 'morning', name: '早班', icon: 'BUG', color: '#FF9800' },
  { id: 'afternoon', name: '中班', icon: 'BUG', color: '#00BCD4' },
  { id: 'evening', name: '晚班', icon: 'BUG', color: '#795548' }
];

@Entry
@Component
struct AddRecordPage {
  // 主题管理
  @StorageProp('themeColors') themeColors: ThemeColors = ThemeManager.getInstance().colors
  private themeManager: ThemeManager = ThemeManager.getInstance()

  // 路由参数
  @State editRecordId: string = '' // 如果有值则为编辑模式
  @State preSelectedDate: string = '' // 预选日期

  // 表单状态
  @State selectedTypeId: string = '' // 选中的班次类型
  @State projectName: string = '' // 项目名称
  @State hourlyRate: number = DEFAULT_HOURLY_RATE // 时薪
  @State startTime: string = '' // 开始时间 "HH:mm"
  @State endTime: string = '' // 结束时间 "HH:mm"
  @State selectedDate: Date = new Date() // 选中的日期
  @State duration: number = FIRST_INDEX // 计算出的时长（小时）
  @State allowance: number = FIRST_INDEX // 补贴
  @State deduction: number = FIRST_INDEX // 扣款
  @State remarks: string = '' // 备注

  // UI状态
  @State showTimePicker: boolean = false
  @State showDatePicker: boolean = false
  @State timePickerType: 'start' | 'end' = 'start' // 当前选择的时间类型
  @State recognitionHistory: RecognitionHistoryItem[] = [] // 识别历史记录
  @State showHistoryPanel: boolean = false // 是否显示历史记录面板

  aboutToAppear(): void {
    // 获取路由参数（使用类型断言处理）
    const params = router.getParams() as RouterParams | undefined;
    this.editRecordId = params?.recordId || '';
    this.preSelectedDate = params?.date || '';

    // 检查是否有语音解析数据
    const voiceParsedData = params?.voiceParsedData;
    const recognitionHistory = params?.recognitionHistory;
    if (voiceParsedData) {
      this.handleVoiceParsedData(voiceParsedData);
      // 保存识别历史
      if (recognitionHistory) {
        this.recognitionHistory = recognitionHistory;
      }
      return;
    }

    // 如果有预选日期，设置为当前日期
    if (this.preSelectedDate) {
      this.selectedDate = new Date(this.preSelectedDate);
    }

    // 初始化默认时间为当前时间(如果不是编辑模式)
    if (!this.editRecordId) {
      const now = new Date();
      const hours = now.getHours().toString().padStart(TIME_PAD_LENGTH, '0');
      const minutes = now.getMinutes().toString().padStart(TIME_PAD_LENGTH, '0');
      this.startTime = `${hours}:${minutes}`;
      // 结束时间默认为开始时间+1小时
      const endHours = ((now.getHours() + SECOND_INDEX) % HOURS_IN_DAY).toString().padStart(TIME_PAD_LENGTH, '0');
      this.endTime = `${endHours}:${minutes}`;
      this.calculateDuration();
    }

    // 如果是编辑模式，加载记录数据
    if (this.editRecordId) {
      this.loadRecordData();
    }
  }

  /**
   * 处理语音解析数据
   * @param data 语音解析后的字段数据
   */
  handleVoiceParsedData(data: WorkRecordFields): void {
    // 设置日期
    if (data.date) {
      this.selectedDate = new Date(data.date);
    }

    // 设置任务名
    if (data.taskName) {
      this.projectName = data.taskName;
    }

    // 设置工时
    if (data.normalHours > 0 || data.overtimeHours > 0) {
      const totalHours = data.normalHours + data.overtimeHours;
      // 假设开始时间为当前时间，结束时间为开始时间+总工时
      const now = new Date();
      const startHours = now.getHours().toString().padStart(TIME_PAD_LENGTH, '0');
      const minutes = now.getMinutes().toString().padStart(TIME_PAD_LENGTH, '0');
      this.startTime = `${startHours}:${minutes}`;
      
      // 计算结束时间
      const endDate = new Date(now);
      endDate.setHours(now.getHours() + totalHours);
      const endHours = endDate.getHours().toString().padStart(TIME_PAD_LENGTH, '0');
      this.endTime = `${endHours}:${minutes}`;
      
      this.duration = totalHours;
    }

    // 设置项目类型（默认白班）
    this.selectedTypeId = 'day';
  }

  /**
   * 重新识别指定的历史记录
   * @param item 历史记录项
   */
  private reRecognizeHistoryItem(item: RecognitionHistoryItem): void {
    this.handleVoiceParsedData(item.parsedFields);
  }

  /**
   * 切换历史记录面板显示
   */
  private toggleHistoryPanel(): void {
    this.showHistoryPanel = !this.showHistoryPanel;
  }

  // 加载记录数据
  async loadRecordData(): Promise<void> {
    const records: WorkRecord[] = await storageUtils.getAllWorkRecords();
    const record = records.find(r => r.id === this.editRecordId);
    if (record) {
      this.selectedTypeId = record.projectType;
      this.projectName = record.projectName;
      this.hourlyRate = record.hourlyWage;
      this.startTime = record.startTime;
      this.endTime = record.endTime;
      // 使用字符串split避免时区问题
      const dateParts = record.date.split('-');
      this.selectedDate = new Date(parseInt(dateParts[FIRST_INDEX]), parseInt(dateParts[SECOND_INDEX]) - SECOND_INDEX, parseInt(dateParts[THIRD_INDEX]));
      this.duration = record.duration;
      this.allowance = record.allowance;
      this.deduction = record.deduction;
      this.remarks = record.remarks;
    }
  }

  // 计算时长
  calculateDuration(): void {
    if (!this.startTime || !this.endTime) {
      this.duration = FIRST_INDEX;
      return;
    }

    const startParts: string[] = this.startTime.split(':');
    const startHour: number = parseInt(startParts[FIRST_INDEX]);
    const startMin: number = parseInt(startParts[SECOND_INDEX]);
    const endParts: string[] = this.endTime.split(':');
    const endHour: number = parseInt(endParts[FIRST_INDEX]);
    const endMin: number = parseInt(endParts[SECOND_INDEX]);

    const startMinutes = startHour * MINUTES_IN_HOUR + startMin;
    const endMinutes = endHour * MINUTES_IN_HOUR + endMin;

    let durationMinutes = endMinutes - startMinutes;
    if (durationMinutes < FIRST_INDEX) {
      durationMinutes += HOURS_IN_DAY * MINUTES_IN_HOUR; // 跨天处理
    }

    this.duration = Math.round(durationMinutes / MINUTES_IN_HOUR * PRECISION_MULTIPLIER) / PRECISION_MULTIPLIER; // 保留2位小数
  }

  // 格式化时间显示
  formatTime(time: string): string {
    if (!time) {
      return '选择时间';
    }
    const timeParts: string[] = time.split(':');
    const hour: number = parseInt(timeParts[FIRST_INDEX]);
    const min: number = parseInt(timeParts[SECOND_INDEX]);
    const period = hour >= HOURS_IN_HALF_DAY ? '下午' : '上午';
    const displayHour = hour > HOURS_IN_HALF_DAY ? hour - HOURS_IN_HALF_DAY : (hour === FIRST_INDEX ? HOURS_IN_HALF_DAY : hour);
    return `${displayHour}:${min.toString().padStart(TIME_PAD_LENGTH, '0')} ${period}`;
  }

  // 格式化日期显示
  formatDate(): string {
    const today = new Date();
    const isToday = this.selectedDate.toDateString() === today.toDateString();
    
    const year = this.selectedDate.getFullYear();
    const month = this.selectedDate.getMonth() + SECOND_INDEX;
    const day = this.selectedDate.getDate();

    if (isToday) {
      return `今天, ${month}月${day}日, ${year}`;
    } else {
      return `${year}年${month}月${day}日`;
    }
  }

  // 格式化时长显示
  formatDuration(): string {
    const hours = Math.floor(this.duration);
    const minutes = Math.round((this.duration - hours) * MINUTES_IN_HOUR);
    return `${hours}小时 ${minutes}分钟`;
  }

  // 保存记录
  async saveRecord(): Promise<void> {
    console.info('[TimeTracker] 开始保存，selectedTypeId=' + this.selectedTypeId + ', projectName=' + this.projectName);
    
    // 验证必填项
    if (!this.projectName.trim()) {
      try {
        promptAction.showToast({ 
          message: '请输入项目名称',
          duration: TOAST_DURATION,
          bottom: '50%'
        });
      } catch (err) {
        console.error('Failed to show toast:', (err as Error).message);
      }
      return;
    }
    if (!this.startTime || !this.endTime) {
      try {
        promptAction.showToast({ 
          message: '请选择开始和结束时间',
          duration: TOAST_DURATION,
          bottom: '50%'
        });
      } catch (err) {
        console.error('Failed to show toast:', (err as Error).message);
      }
      return;
    }
    if (this.duration <= FIRST_INDEX) {
      try {
        promptAction.showToast({ 
          message: '工作时长必须大于0',
          duration: TOAST_DURATION,
          bottom: '50%'
        });
      } catch (err) {
        console.error('Failed to show toast:', (err as Error).message);
      }
      return;
    }

    // 格式化日期为本地日期字符串 YYYY-MM-DD
    const year = this.selectedDate.getFullYear();
    const month = (this.selectedDate.getMonth() + SECOND_INDEX).toString().padStart(TIME_PAD_LENGTH, '0');
    const day = this.selectedDate.getDate().toString().padStart(TIME_PAD_LENGTH, '0');
    const dateStr = `${year}-${month}-${day}`;
    
    console.info('[TimeTracker] 保存日期=' + dateStr);
    
    const record: WorkRecord = {
      id: this.editRecordId || `${Date.now()}_${Math.random().toString(RADIX_36).substr(TIME_PAD_LENGTH, RANDOM_ID_LENGTH)}`,
      date: dateStr,
      startTime: this.startTime,
      endTime: this.endTime,
      duration: this.duration,
      projectType: this.selectedTypeId,
      projectName: this.projectName.trim(),
      hourlyWage: this.hourlyRate,
      allowance: this.allowance,
      deduction: this.deduction,
      remarks: this.remarks.trim(),
      createdAt: this.editRecordId ? '' : new Date().toISOString() // 编辑时保持原创建时间
    };

    console.info(`[TimeTracker] 准备保存记录: ${JSON.stringify(record)}`);

    if (this.editRecordId) {
      // 更新记录：先删除旧记录，再添加新记录
      await storageUtils.deleteWorkRecord(this.editRecordId);
      await storageUtils.saveWorkRecord(record);
      try {
        promptAction.showToast({ message: '更新成功' });
      } catch (err) {
        console.error('Failed to show toast:', (err as Error).message);
      }
    } else {
      await storageUtils.saveWorkRecord(record);
      console.info('[TimeTracker] 保存成功，准备返回并刷新首页');
      try {
        promptAction.showToast({ message: '保存成功' });
      } catch (err) {
        console.error('Failed to show toast:', (err as Error).message);
      }
    }

    // 发送全局刷新事件，通知首页更新数据
    console.info('[TimeTracker] 🔔 发送全局刷新事件');
    EventBus.instance.emit(EventKey.GLOBAL_REFRESH_EVENT);
    console.info('[TimeTracker] 🔙 返回首页');
    router.back();
  }

  // 班次选择器
  @Builder WorkTypeSelector() {
    Column() {
      Text('班次选择（可选）')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeColors.textSecondary)
        .margin({ bottom: 16 })

      // 3x3网格
      Grid() {
        ForEach(WORK_TYPES, (type: WorkType) => {
          GridItem() {
            Column() {
              // 图标
              Image($r(`app.media.${type.icon}`))
                .width(24)
                .height(24)
                .fillColor(type.color)
              
              // 标签
              Text(type.name)
                .fontSize(12)
                .fontColor(this.themeColors.textPrimary)
                .fontWeight(FontWeight.Medium)
                .margin({ top: 4 })
            }
            .width(60)
            .height(60)
            .backgroundColor(this.selectedTypeId === type.id ? this.themeColors.background : this.themeColors.cardBackground)
            .borderRadius(12)
            .border({
              width: this.selectedTypeId === type.id ? 2 : 1,
              color: this.selectedTypeId === type.id ? this.themeColors.primaryColor : this.themeColors.dividerColor
            })
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.selectedTypeId = type.id;
            })
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .width('100%')
      .height(132) // 60*2 + 12*1
      .backgroundColor(this.themeColors.background)
    }
    .alignItems(HorizontalAlign.Start)
  }

  // 获取图标字符（简化版）


  build() {
    Column() {
      // 顶部导航栏
      Row() {
        // 关闭按钮
        Button() {
          Image($r('app.media.CloseSmall'))
            .width(24)
            .height(24)
            .fillColor(this.themeColors.textSecondary)
        }
        .width(44)
        .height(44)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.back();
        })

        // 标题
        Text(this.editRecordId ? '编辑工时记录' : '添加工时记录')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeColors.textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 右侧占位（保持对称）
        Row()
          .width(44)
          .height(44)
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 8, top: 60 })
      .backgroundColor(this.themeColors.surfaceBackground)

      // 内容区域
      Scroll() {
        Column() {
          // 时长显示
          Column() {
            Text(this.formatDuration())
              .fontSize(40)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeColors.textPrimary)
            
            Text('工作时长')
              .fontSize(14)
              .fontColor(this.themeColors.textSecondary)
              .margin({ top: 8 })
          }
          .width('100%')
          .height(100)
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 16 })

          // 时间选择区域
          Column() {
            Text('时间选择')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeColors.textSecondary)
              .margin({ bottom: 16 })

            // 开始时间
            Row() {
              Image($r('sys.symbol.clock'))
                .width(20)
                .height(20)
                .fillColor(this.themeColors.primaryColor)
                .margin({ right: 12 })
              
              Text('开始时间')
                .fontSize(16)
                .fontColor(this.themeColors.textPrimary)
                .layoutWeight(1)
              
              Text(this.formatTime(this.startTime))
                .fontSize(16)
                .fontColor(this.themeColors.primaryColor)
            }
            .width('100%')
            .height(48)
            .padding({ left: 12, right: 12 })
            .onClick(() => {
              this.showStartTimePicker();
            })

            // 结束时间
            Row() {
              Image($r('sys.symbol.clock'))
                .width(20)
                .height(20)
                .fillColor(this.themeColors.primaryColor)
                .margin({ right: 12 })
              
              Text('结束时间')
                .fontSize(16)
                .fontColor(this.themeColors.textPrimary)
                .layoutWeight(1)
              
              Text(this.formatTime(this.endTime))
                .fontSize(16)
                .fontColor(this.themeColors.primaryColor)
            }
            .width('100%')
            .height(48)
            .padding({ left: 12, right: 12 })
            .margin({ top: 8 })
            .onClick(() => {
              this.showEndTimePicker();
            })

            // 时长结果
            Row() {
              Text(`时长: ${this.formatDuration()}`)
                .fontSize(14)
                .fontColor(this.themeColors.primaryColor)
            }
            .width('100%')
            .padding(8)
            .backgroundColor(this.themeColors.background)
            .borderRadius(4)
            .margin({ top: 12 })
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.themeColors.cardBackground)
          .borderRadius(12)
          .margin({ bottom: 16 })

          // 日期选择
          Column() {
            Text('日期')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeColors.textSecondary)
              .margin({ bottom: 8 })

            Row() {
              Image($r('sys.symbol.calendar'))
                .width(20)
                .height(20)
                .fillColor(this.themeColors.primaryColor)
                .margin({ right: 12 })
              
              Text(this.formatDate())
                .fontSize(16)
                .fontColor(this.themeColors.textPrimary)
            }
            .width('100%')
            .height(48)
            .padding({ left: 12, right: 12 })
            .backgroundColor(this.themeColors.cardBackground)
            .borderRadius(8)
            .onClick(() => {
              this.showDatePicker = true;
            })
          }
          .width('100%')
          .margin({ bottom: 24 })

          // 工作类型选择器
          this.WorkTypeSelector()

          // 项目名称输入
          Row() {
            Image($r('sys.symbol.briefcase'))
              .width(20)
              .height(20)
              .fillColor(this.themeColors.textSecondary)
              .margin({ right: 12 })
            
            TextInput({ placeholder: '项目名称', text: this.projectName })
              .fontSize(18)
              .fontColor(this.themeColors.textPrimary)
              .backgroundColor(Color.Transparent)
              .layoutWeight(1)
              .onChange((value: string) => {
                this.projectName = value;
              })
          }
          .width('100%')
          .height(48)
          .padding({ left: 12, right: 12 })
          .backgroundColor(this.themeColors.cardBackground)
          .borderRadius(8)
          .margin({ top: 16 })

          // 时薪输入
          Row() {
            Text('¥')
              .fontSize(20)
              .fontColor(this.themeColors.textSecondary)
              .margin({ right: 12 })
            
            TextInput({ placeholder: '时薪', text: this.hourlyRate.toString() })
              .fontSize(18)
              .fontColor(this.themeColors.textPrimary)
              .backgroundColor(Color.Transparent)
              .layoutWeight(1)
              .type(InputType.Number)
              .onChange((value: string) => {
                const parsed = parseInt(value);
                if (!isNaN(parsed)) {
                  this.hourlyRate = parsed;
                } else if (value === '') {
                  this.hourlyRate = 0;
                }
              })
            
            Text('/小时')
              .fontSize(16)
              .fontColor(this.themeColors.textSecondary)
          }
          .width('100%')
          .height(48)
          .padding({ left: 12, right: 12 })
          .backgroundColor(this.themeColors.cardBackground)
          .borderRadius(8)
          .margin({ top: 8 })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring) // 添加弹簧回弹效果

      // 底部保存按钮
      Button('保存工作记录')
        .width('calc(100% - 32vp)')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.themeColors.primaryColor)
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 8, bottom: 40 })
        .onClick(() => {
          this.saveRecord()
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColors.background)
    .bindSheet($$this.showDatePicker, this.DatePickerBuilder(), {
      height: 400,
      backgroundColor: this.themeColors.cardBackground,
      onDisappear: () => {
        this.showDatePicker = false;
      }
    })
  }

  // 显示开始时间选择器
  showStartTimePicker() {
    const timeParts = this.startTime.split(':');
    const hour = parseInt(timeParts[0]);
    const minute = parseInt(timeParts[1]);
    
    TimePickerDialog.show({
      selected: new Date(2024, 0, 1, hour, minute),
      useMilitaryTime: true,
      backgroundColor: this.themeColors.cardBackground,
      onAccept: (value: TimePickerResult) => {
        const h = value.hour !== undefined ? value.hour : 0;
        const m = value.minute !== undefined ? value.minute : 0;
        this.startTime = `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}`;
        this.calculateDuration();
      }
    })
  }

  // 显示结束时间选择器
  showEndTimePicker() {
    const timeParts = this.endTime.split(':');
    const hour = parseInt(timeParts[0]);
    const minute = parseInt(timeParts[1]);
    
    TimePickerDialog.show({
      selected: new Date(2024, 0, 1, hour, minute),
      useMilitaryTime: true,
      backgroundColor: this.themeColors.cardBackground,
      onAccept: (value: TimePickerResult) => {
        const h = value.hour !== undefined ? value.hour : 0;
        const m = value.minute !== undefined ? value.minute : 0;
        this.endTime = `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}`;
        this.calculateDuration();
      }
    })
  }

  // 时间选择器 (已弃用，改用TimePickerDialog)
  @Builder TimePickerBuilder() {
    Column() {
      Text(this.timePickerType === 'start' ? '选择开始时间' : '选择结束时间')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })

      TimePicker()
        .useMilitaryTime(true)
        .onChange((value: TimePickerResult) => {
          const hour = value.hour ?? 0;
          const minute = value.minute ?? 0;
          const time: string = `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
          if (this.timePickerType === 'start') {
            this.startTime = time;
          } else {
            this.endTime = time;
          }
          this.calculateDuration();
        })

      Button('确定')
        .width('calc(100% - 32vp)')
        .height(44)
        .margin({ top: 20 })
        .onClick(() => {
          this.showTimePicker = false;
        })
    }
    .width('100%')
    .padding(16)
  }

  // 日期选择器
  @Builder DatePickerBuilder() {
    Column() {
      Text('选择日期')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeColors.textPrimary)
        .margin({ top: 20, bottom: 20 })

      DatePicker({
        start: new Date('2020-01-01'),
        end: new Date('2030-12-31'),
        selected: this.selectedDate
      })
      .backgroundColor(this.themeColors.cardBackground)
      .onChange((value: DatePickerResult) => {
        this.selectedDate = new Date(value.year!, value.month!, value.day!);
      })

      Button('确定')
        .width('calc(100% - 32vp)')
        .height(44)
        .margin({ top: 20 })
        .backgroundColor(this.themeColors.primaryColor)
        .onClick(() => {
          this.showDatePicker = false;
        })
    }
    .width('100%')
    .backgroundColor(this.themeColors.cardBackground)
  }
}
