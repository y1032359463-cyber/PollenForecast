/**
 * AddWorkSessionPage - 工时录入页面
 * 
 * 功能：记录工作时间、项目类型、项目名称、时薪，自动计算工时
 * 
 * 设计来源：Figma Make 生成（严格遵循 02_记账页.txt 提示词）
 * 更新时间：2025-11-15
 * 
 * 布局规格：
 * - 画布尺寸：360×780px
 * - 配色：主色 #2196F3（Material Blue 500）
 * - 图标：IconPark 线性风格，24×24px
 * - 触控目标：最小 48×48px
 * - 安全区：底部 20px（HarmonyOS 手势导航）
 */

import { router } from '@kit.ArkUI';
import { storageUtils, ThemeManager } from '@ohos/commonlib';
import type { WorkRecord } from '@ohos/commonlib';
import { promptAction } from '@kit.ArkUI';

// 班次类型定义
interface ShiftType {
  id: string;
  name: string;
  icon: string; // 系统图标名称
  color: string;
}

// 6 个班次类型（2×3网格）- 小时工常见班次
const SHIFT_TYPES: ShiftType[] = [
  { id: 'day', name: '白班', icon: 'sun_max', color: '#FF9800' },           // 白天班次
  { id: 'night', name: '夜班', icon: 'moon', color: '#3F51B5' },            // 夜晚班次
  { id: 'rest', name: '休息', icon: 'pause', color: '#9E9E9E' },            // 休息日
  { id: 'morning', name: '早班', icon: 'sunrise', color: '#FFC107' },       // 早班
  { id: 'middle', name: '中班', icon: 'sun_min', color: '#FF5722' },        // 中班
  { id: 'evening', name: '晚班', icon: 'sunset', color: '#673AB7' }         // 晚班
];

@Entry
@Component
struct AddWorkSessionPage {
  // 主题状态
  @State themeColors: any = ThemeManager.getInstance().colors
  private themeManager: ThemeManager = ThemeManager.getInstance()
  
  // 时间相关状态
  @State startTime: string = '';
  @State endTime: string = '';
  @State durationHours: number = 0;
  @State durationMinutes: number = 0;
  
  // 工作详情状态
  @State selectedDate: Date = new Date();
  @State selectedShiftType: string = ''; // 选中的班次类型 ID（可选）
  @State projectName: string = '';
  @State hourlyWage: number = 30;
  
  // 补贴和扣款（新增）
  @State allowance: number = 0;      // 补贴金额
  @State deduction: number = 0;      // 扣款金额
  @State remarks: string = '';       // 备注（最多200字）
  
  // UI 状态
  @State showStartTimePicker: boolean = false;
  @State showEndTimePicker: boolean = false;
  @State showDatePicker: boolean = false;

  /**
   * 计算工作时长（当开始/结束时间改变时自动调用）
   */
  private calculateDuration(): void {
    if (!this.startTime || !this.endTime) {
      this.durationHours = 0;
      this.durationMinutes = 0;
      return;
    }
    
    const [startHour, startMin] = this.startTime.split(':').map(Number);
    const [endHour, endMin] = this.endTime.split(':').map(Number);
    
    let totalMinutes = (endHour * 60 + endMin) - (startHour * 60 + startMin);
    
    // 处理跨天情况
    if (totalMinutes < 0) {
      totalMinutes += 24 * 60;
    }
    
    this.durationHours = Math.floor(totalMinutes / 60);
    this.durationMinutes = totalMinutes % 60;
  }

  /**
   * 格式化时间显示（12小时制 + 上午/下午）
   */
  private formatTime(time: string): string {
    if (!time) {
      return '选择时间';
    }
    
    const [hours, minutes] = time.split(':').map(Number);
    const period = hours >= 12 ? '下午' : '上午';
    const displayHour = hours === 0 ? 12 : hours > 12 ? hours - 12 : hours;
    return `${displayHour}:${minutes.toString().padStart(2, '0')} ${period}`;
  }

  /**
   * 格式化日期显示
   */
  private getDateDisplay(): string {
    const today = new Date();
    const selected = this.selectedDate;
    
    const isToday =
      selected.getFullYear() === today.getFullYear() &&
      selected.getMonth() === today.getMonth() &&
      selected.getDate() === today.getDate();
    
    if (isToday) {
      return `今天, ${selected.getMonth() + 1}月${selected.getDate()}日, ${selected.getFullYear()}`;
    }
    
    return `${selected.getFullYear()}年${selected.getMonth() + 1}月${selected.getDate()}日`;
  }

  /**
   * 保存工时记录
   */
  private async saveWorkLog(): Promise<void> {
    // 数据验证
    // 班次为可选项，不需要验证
    // if (!this.selectedShiftType) {
    //   try {
    //     promptAction.showToast({
    //       message: '请选择班次',
    //       duration: 2000
    //     });
    //   } catch (err) {
    //     console.error('Toast error:', err);
    //   }
    //   return;
    // }
    
    if (!this.startTime || !this.endTime) {
      try {
        promptAction.showToast({
          message: '请选择开始和结束时间',
          duration: 2000
        });
      } catch (err) {
        console.error('Toast error:', err);
      }
      return;
    }
    
    if (this.durationHours === 0 && this.durationMinutes === 0) {
      try {
        promptAction.showToast({
          message: '工作时长不能为0',
          duration: 2000
        });
      } catch (err) {
        console.error('Toast error:', err);
      }
      return;
    }
    
    // 格式化日期为本地日期字符串 YYYY-MM-DD
    const year = this.selectedDate.getFullYear();
    const month = (this.selectedDate.getMonth() + 1).toString().padStart(2, '0');
    const day = this.selectedDate.getDate().toString().padStart(2, '0');
    const dateStr = `${year}-${month}-${day}`;
    
    // 构造工时记录对象
    const workRecord: WorkRecord = {
      id: `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`, // 生成唯一ID
      date: dateStr,
      startTime: this.startTime,
      endTime: this.endTime,
      duration: this.durationHours + (this.durationMinutes / 60),
      shiftType: this.selectedShiftType, // 班次类型（可选）
      projectName: this.projectName || '未命名项目',
      hourlyWage: this.hourlyWage,
      allowance: this.allowance,
      deduction: this.deduction,
      remarks: this.remarks,
      createdAt: new Date().toISOString()
    };
    
    try {
      // 保存到 Preferences
      await storageUtils.saveWorkRecord(workRecord);
      
      // 显示成功提示
      try {
        promptAction.showToast({
          message: '保存成功',
          duration: 1500
        });
      } catch (err) {
        console.error('Toast error:', err);
      }
      
      console.info('[AddWorkSession] 工时记录已保存:', JSON.stringify(workRecord));
      
      // 延迟返回（让Toast显示完整）
      setTimeout(() => {
        router.back();
      }, 300);
    } catch (error) {
      console.error('[AddWorkSession] 保存失败:', error);
      try {
        promptAction.showToast({
          message: '保存失败，请重试',
          duration: 2000
        });
      } catch (err) {
        console.error('Toast error:', err);
      }
    }
  }

  /**
   * 关闭页面
   */
  private closePage(): void {
    router.back();
  }

  build() {
    Column() {
      // 1. 顶部栏 - 56px高度
      this.TopBar();
      
      // 2. 滚动内容区
      Scroll() {
        Column() {
          // 时长大显示 - 100px
          this.DurationDisplay();
          
          // 时间选择器区域 - ~160px
          this.TimePickerSection();
          
          // 日期选择器 - ~56px
          this.DatePickerSection();
          
          // 工作详情区域 - ~280px
          this.WorkDetailsSection();
          
          // 底部留白（为按钮区域预留空间）
          Row().height(16);
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor(this.themeColors.cardBackground)
      
      // 3. 底部保存按钮区域 - 96px（48px按钮 + 间距 + 20px安全区）
      this.SaveButton();
    }
    .width('100%')
    .maxWidth(600)
    .height('100%')
    .backgroundColor(this.themeColors.background)
  }

  /**
   * 顶部栏 - 56px高度
   * 布局：关闭按钮(左) + 标题(中) + 保存按钮(右)
   */
  @Builder
  TopBar() {
    Row() {
      // 关闭按钮 - 44×44px 触控区
      Button() {
        Image($r('app.media.CloseSmall'))
          .width(24)
          .height(24)
          .fillColor(this.themeColors.textSecondary)
      }
      .width(44)
      .height(44)
      .backgroundColor(Color.Transparent)
      .onClick(() => this.closePage())
      
      // 标题 - 居中，18px 粗体
      Text('添加工时记录')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeColors.textPrimary)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      // 保存按钮 - 44×44px 圆形，精确 #2196F3 背景
      Button() {
        Image($r('app.media.Success'))
          .width(24)
          .height(24)
          .fillColor(this.themeColors.cardBackground)
      }
      .width(44)
      .height(44)
      .backgroundColor(this.themeColors.primaryColor)
      .borderRadius(22) // 圆形按钮
      .onClick(() => this.saveWorkLog())
    }
    .width('100%')
    .height(56)
    .padding({ left: 6, right: 6 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .borderWidth({ bottom: 1 })
    .borderColor(this.themeColors.dividerColor)
  }

  /**
   * 时长大显示 - 100px高度
   * 显示格式："0小时 0分钟" (40px粗体) + "工作时长"标签(14px)
   */
  @Builder
  DurationDisplay() {
    Column({ space: 8 }) {
      // 大号时长显示 - 40px粗体，#212121
      Text(`${this.durationHours}小时 ${this.durationMinutes}分钟`)
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeColors.textPrimary)
        .textAlign(TextAlign.Center)
      
      // 标签 - 14px，#757575
      Text('工作时长')
        .fontSize(14)
        .fontColor(this.themeColors.textSecondary)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(100)
    .justifyContent(FlexAlign.Center)
    .padding({ left: 24, right: 24 })
  }

  /**
   * 时间选择器区域 - ~160px高度
   * 包含：开始时间行 + 结束时间行 + 时长结果显示
   */
  @Builder
  TimePickerSection() {
    Column() {
      // 区域标题 - 14px medium，#757575
      Text('时间选择')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeColors.textSecondary)
        .width('100%')
        .margin({ bottom: 16 })
      
      Column({ space: 8 }) {
        // 开始时间行 - 48px高度
        Row({ space: 12 }) {
          Image($r('app.media.Time'))
            .width(20)
            .height(20)
            .fillColor(this.themeColors.primaryColor)
          
          Text('开始时间')
            .fontSize(16)
            .fontColor(this.themeColors.textPrimary)
            .layoutWeight(1)
          
          Text(this.formatTime(this.startTime))
            .fontSize(16)
            .fontColor(this.startTime ? this.themeColors.primaryColor : this.themeColors.textHint)
        }
        .width('100%')
        .height(48)
        .padding({ left: 12, right: 12 })
        .backgroundColor(this.themeColors.cardBackground)
        .borderRadius(8)
        .onClick(() => {
          this.showStartTimePicker = true;
        })
        
        // 结束时间行 - 48px高度
        Row({ space: 12 }) {
          Image($r('app.media.Time'))
            .width(20)
            .height(20)
            .fillColor(this.themeColors.primaryColor)
          
          Text('结束时间')
            .fontSize(16)
            .fontColor(this.themeColors.textPrimary)
            .layoutWeight(1)
          
          Text(this.formatTime(this.endTime))
            .fontSize(16)
            .fontColor(this.endTime ? this.themeColors.primaryColor : this.themeColors.textHint)
        }
        .width('100%')
        .height(48)
        .padding({ left: 12, right: 12 })
        .backgroundColor(this.themeColors.cardBackground)
        .borderRadius(8)
        .onClick(() => {
          this.showEndTimePicker = true;
        })
        
        // 时长结果显示 - 浅蓝背景 #E3F2FD
        Row() {
          Text(`时长: ${this.durationHours}小时 ${this.durationMinutes}分钟`)
            .fontSize(14)
            .fontColor(this.themeColors.primaryColor)
        }
        .width('100%')
        .padding(8)
        .backgroundColor(this.themeColors.background)
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeColors.background)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16 })
  }

  /**
   * 日期选择器区域 - ~56px高度
   */
  @Builder
  DatePickerSection() {
    Column() {
      // 区域标题
      Text('日期')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeColors.textSecondary)
        .width('100%')
        .margin({ bottom: 8 })
      
      // 日期选择行 - 48px高度
      Row({ space: 12 }) {
        Image($r('app.media.calendar'))
          .width(20)
          .height(20)
          .fillColor(this.themeColors.primaryColor)
        
        Text(this.getDateDisplay())
          .fontSize(16)
          .fontColor(this.themeColors.textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor(this.themeColors.background)
      .borderRadius(8)
      .onClick(() => {
        this.showDatePicker = true;
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16 })
  }

  /**
   * 工作详情区域 - ~210px高度
   * 包含：班次选择（2×3网格，可选）+ 项目名称输入 + 时薪输入
   */
  @Builder
  WorkDetailsSection() {
    Column() {
      // 区域标题
      Text('选择班次（可选）')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeColors.textSecondary)
        .width('100%')
        .margin({ bottom: 16 })
      
      // 班次选择 2×3 网格（6个班次）
      Grid() {
        ForEach(SHIFT_TYPES, (type: ShiftType) => {
          GridItem() {
            Column({ space: 4 }) {
              // 图标 - 24×24px，使用类型对应颜色
              Image($r(`sys.symbol.${type.icon}`))
                .width(24)
                .height(24)
                .fillColor(type.color)
              
              // 标签 - 12px，#757575
              Text(type.name)
                .fontSize(12)
                .fontColor(this.themeColors.textSecondary)
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .height(60)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.themeColors.background)
            .borderRadius(12)
            .border({
              width: 2,
              color: this.selectedShiftType === type.id ? this.themeColors.primaryColor : Color.Transparent
            })
            .onClick(() => {
              this.selectedShiftType = type.id;
            })
          }
        })
      }
      .columnsTemplate('1fr 1fr')      // 2列
      .rowsTemplate('1fr 1fr 1fr')     // 3行
      .rowsGap(12)
      .columnsGap(12)
      .width('100%')
      .margin({ bottom: 12 })
      
      // 项目名称输入 - 48px高度
      Row({ space: 12 }) {
        Image($r('app.media.Briefcase'))
          .width(20)
          .height(20)
          .fillColor(this.themeColors.textSecondary)
        
        TextInput({ placeholder: '项目名称', text: this.projectName })
          .fontSize(16)
          .fontColor(this.themeColors.textPrimary)
          .backgroundColor(Color.Transparent)
          .border({ width: 0 })
          .padding(0)
          .layoutWeight(1)
          .placeholderColor(this.themeColors.textHint)
          .onChange((value: string) => {
            this.projectName = value;
          })
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor(this.themeColors.background)
      .borderRadius(8)
      .margin({ top: 16 })
      
      // 时薪输入 - 48px高度
      Row({ space: 12 }) {
        Text('¥')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeColors.textSecondary)
        
        TextInput({ placeholder: '30', text: this.hourlyWage.toString() })
          .fontSize(16)
          .fontColor(this.themeColors.textPrimary)
          .backgroundColor(Color.Transparent)
          .border({ width: 0 })
          .padding(0)
          .type(InputType.Number)
          .layoutWeight(1)
          .placeholderColor(this.themeColors.textHint)
          .onChange((value: string) => {
            this.hourlyWage = parseInt(value) || 0;
          })
        
        Text('/小时')
          .fontSize(16)
          .fontColor(this.themeColors.textSecondary)
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor(this.themeColors.background)
      .borderRadius(8)
      .margin({ top: 8 })
      
      // 补贴输入 - 48px高度（新增）
      Row({ space: 12 }) {
        Image($r('sys.symbol.plus_circle'))
          .width(20)
          .height(20)
          .fillColor('#4CAF50')
        
        Text('补贴')
          .fontSize(16)
          .fontColor(this.themeColors.textSecondary)
          .width(60)
        
        TextInput({ placeholder: '0', text: this.allowance > 0 ? this.allowance.toString() : '' })
          .fontSize(16)
          .fontColor(this.themeColors.textPrimary)
          .backgroundColor(Color.Transparent)
          .border({ width: 0 })
          .padding(0)
          .type(InputType.Number)
          .layoutWeight(1)
          .placeholderColor(this.themeColors.textHint)
          .onChange((value: string) => {
            this.allowance = parseFloat(value) || 0;
          })
        
        Text('元')
          .fontSize(16)
          .fontColor(this.themeColors.textSecondary)
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor(this.themeColors.background)
      .borderRadius(8)
      .margin({ top: 8 })
      
      // 扣款输入 - 48px高度（新增）
      Row({ space: 12 }) {
        Image($r('sys.symbol.minus_circle'))
          .width(20)
          .height(20)
          .fillColor('#F44336')
        
        Text('扣款')
          .fontSize(16)
          .fontColor(this.themeColors.textSecondary)
          .width(60)
        
        TextInput({ placeholder: '0', text: this.deduction > 0 ? this.deduction.toString() : '' })
          .fontSize(16)
          .fontColor(this.themeColors.textPrimary)
          .backgroundColor(Color.Transparent)
          .border({ width: 0 })
          .padding(0)
          .type(InputType.Number)
          .layoutWeight(1)
          .placeholderColor(this.themeColors.textHint)
          .onChange((value: string) => {
            this.deduction = parseFloat(value) || 0;
          })
        
        Text('元')
          .fontSize(16)
          .fontColor(this.themeColors.textSecondary)
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .backgroundColor(this.themeColors.background)
      .borderRadius(8)
      .margin({ top: 8 })
      
      // 备注输入 - 最多200字（新增）
      Column() {
        Row() {
          Image($r('app.media.Document'))
            .width(20)
            .height(20)
            .fillColor(this.themeColors.textSecondary)
          
          Text('备注')
            .fontSize(14)
            .fontColor(this.themeColors.textSecondary)
            .margin({ left: 8 })
        }
        .width('100%')
        .margin({ bottom: 8 })
        
        TextArea({ placeholder: '填写备注，最多200个字哟~', text: this.remarks })
          .fontSize(16)
          .fontColor(this.themeColors.textPrimary)
          .backgroundColor(this.themeColors.background)
          .borderRadius(8)
          .padding(12)
          .width('100%')
          .height(80)
          .maxLength(200)
          .placeholderColor(this.themeColors.textHint)
          .onChange((value: string) => {
            this.remarks = value;
          })
        
        // 字数统计
        Text(`${this.remarks.length}/200`)
          .fontSize(12)
          .fontColor(this.themeColors.textHint)
          .width('100%')
          .textAlign(TextAlign.End)
          .margin({ top: 4 })
      }
      .width('100%')
      .margin({ top: 16 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16 })
  }

  /**
   * 底部保存按钮区域 - 96px总高度
   * 布局：16px上边距 + 48px按钮 + 12px间距 + 20px安全区
   */
  @Builder
  SaveButton() {
    Column() {
      // 保存按钮 - 48px高度，精确 #2196F3 背景
      Button('保存工作记录')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeColors.cardBackground)
        .backgroundColor(this.themeColors.primaryColor)
        .borderRadius(8)
        .width('calc(100% - 32vp)') // 左右各16px边距
        .height(48)
        .onClick(() => this.saveWorkLog())
      
      // 安全区占位 - 20px（HarmonyOS手势导航）
      Row().height(20)
    }
    .width('100%')
    .height(96)
    .padding({ top: 16, left: 16, right: 16, bottom: 12 })
    .backgroundColor(this.themeColors.cardBackground)
    .justifyContent(FlexAlign.Start)
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.08)',
      offsetY: -2
    })
  }
}
