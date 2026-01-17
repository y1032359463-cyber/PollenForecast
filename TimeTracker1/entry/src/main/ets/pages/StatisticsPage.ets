/**
 * StatisticsPage.ets - 数据统计页面
 * 
 * 功能：
 * - 周/月/年数据切换
 * - 总工时统计
 * - 收入统计
 * - 工时趋势图表
 * - 工作天数统计
 */

import { storageUtils, EventBus, EventKey, ThemeManager, type ThemeColors } from '@ohos/commonlib';
import type { WorkRecord } from '@ohos/commonlib';

interface DayData {
  day: string;
  hours: number;
}

@Component
export struct StatisticsPage {
  // 主题管理
  @StorageProp('themeColors') themeColors: ThemeColors = ThemeManager.getInstance().colors
  private themeManager: ThemeManager = ThemeManager.getInstance()

  // 状态
  @State selectedPeriod: 'week' | 'month' | 'year' = 'month'; // 当前选择的时间周期
  @State totalHours: number = 0; // 总工时
  @State totalIncome: number = 0; // 总收入
  @State workDays: number = 0; // 工作天数
  @State avgHoursPerDay: number = 0; // 日均工时
  @State avgHourlyRate: number = 0; // 平均时薪
  @State changePercent: number = 0; // 相比上期的变化百分比
  @State chartData: DayData[] = []; // 图表数据
  private cachedRecords: WorkRecord[] = []; // 缓存所有记录，避免重复读取
  private lastLoadTime: number = 0; // 上次加载时间戳
  private cacheValidDuration: number = 5000; // 缓存有效期5秒
  private switchDebounceTimer: number = -1; // 防抖定时器

  aboutToAppear() {
    console.info('[StatisticsPage] aboutToAppear - 初始化页面');
    this.loadStatistics();
    
    // 监听全局刷新事件
    EventBus.instance.on(EventKey.GLOBAL_REFRESH_EVENT, () => {
      console.info('[StatisticsPage] 收到全局刷新事件，重新加载统计数据');
      this.loadStatistics();
    });
  }

  aboutToDisappear() {
    console.info('[StatisticsPage] aboutToDisappear - 页面销毁');
    // 移除事件监听
    EventBus.instance.off(EventKey.GLOBAL_REFRESH_EVENT);
  }

  onPageShow() {
    console.info('[StatisticsPage] onPageShow - 页面显示，刷新数据');
    this.loadStatistics();
  }
  
  // 带防抖的周期切换（避免快速滑动时频繁计算）
  switchPeriodWithDebounce(period: 'week' | 'month' | 'year') {
    // 立即更新UI
    this.selectedPeriod = period;
    
    // 清除之前的定时器
    if (this.switchDebounceTimer !== -1) {
      clearTimeout(this.switchDebounceTimer);
    }
    
    // 100ms防抖，避免快速点击
    this.switchDebounceTimer = setTimeout(() => {
      this.loadStatistics();
      this.switchDebounceTimer = -1;
    }, 100);
  }

  // 加载统计数据（带缓存优化）
  async loadStatistics() {
    const now = Date.now();
    
    // 如果缓存仍有效，使用缓存数据
    if (this.cachedRecords.length > 0 && (now - this.lastLoadTime) < this.cacheValidDuration) {
      console.info('[StatisticsPage] 使用缓存数据');
      this.calculateStats(this.cachedRecords);
      return;
    }
    
    // 读取并缓存数据
    this.cachedRecords = await storageUtils.getAllWorkRecords();
    this.lastLoadTime = now;
    console.info(`[StatisticsPage] 重新加载数据，共 ${this.cachedRecords.length} 条记录`);
    
    this.calculateStats(this.cachedRecords);
  }
  
  // 计算统计数据（从缓存的记录中计算）
  calculateStats(records: WorkRecord[]) {
    const now = new Date();
    
    let startDate: Date;
    let endDate: Date = now;
    let prevStartDate: Date;
    let prevEndDate: Date;

    // 根据选择的周期计算日期范围
    if (this.selectedPeriod === 'week') {
      // 本周（周一到周日）
      const dayOfWeek = now.getDay() || 7; // 0(周日)改为7
      startDate = new Date(now);
      startDate.setDate(now.getDate() - dayOfWeek + 1);
      startDate.setHours(0, 0, 0, 0);

      // 上周
      prevEndDate = new Date(startDate);
      prevEndDate.setDate(prevEndDate.getDate() - 1);
      prevStartDate = new Date(prevEndDate);
      prevStartDate.setDate(prevEndDate.getDate() - 6);
    } else if (this.selectedPeriod === 'month') {
      // 本月
      startDate = new Date(now.getFullYear(), now.getMonth(), 1);
      
      // 上月
      prevEndDate = new Date(startDate);
      prevEndDate.setDate(prevEndDate.getDate() - 1);
      prevStartDate = new Date(prevEndDate.getFullYear(), prevEndDate.getMonth(), 1);
    } else {
      // 今年
      startDate = new Date(now.getFullYear(), 0, 1);
      
      // 去年
      prevStartDate = new Date(now.getFullYear() - 1, 0, 1);
      prevEndDate = new Date(now.getFullYear() - 1, 11, 31);
    }

    // 筛选当前周期的记录
    const currentRecords: WorkRecord[] = records.filter((r: WorkRecord) => {
      // 使用字符串split避免时区问题
      const dateParts = r.date.split('-');
      const recordDate = new Date(parseInt(dateParts[0]), parseInt(dateParts[1]) - 1, parseInt(dateParts[2]));
      return recordDate >= startDate && recordDate <= endDate;
    });

    // 筛选上个周期的记录
    const prevRecords: WorkRecord[] = records.filter((r: WorkRecord) => {
      const dateParts = r.date.split('-');
      const recordDate = new Date(parseInt(dateParts[0]), parseInt(dateParts[1]) - 1, parseInt(dateParts[2]));
      return recordDate >= prevStartDate && recordDate <= prevEndDate;
    });

    // 计算统计数据
    this.totalHours = currentRecords.reduce((sum: number, r: WorkRecord): number => sum + r.duration, 0);
    this.totalIncome = currentRecords.reduce((sum: number, r: WorkRecord): number => sum + (r.duration * r.hourlyWage + r.allowance - r.deduction), 0);
    
    // 计算工作天数（去重日期）
    const uniqueDates: Set<string> = new Set<string>(currentRecords.map((r: WorkRecord): string => r.date));
    this.workDays = uniqueDates.size;

    // 计算日均工时
    this.avgHoursPerDay = this.workDays > 0 ? this.totalHours / this.workDays : 0;

    // 计算平均时薪
    this.avgHourlyRate = this.totalHours > 0 ? this.totalIncome / this.totalHours : 0;

    // 计算相比上期的变化
    const prevTotalHours: number = prevRecords.reduce((sum: number, r: WorkRecord): number => sum + r.duration, 0);
    if (prevTotalHours > 0) {
      this.changePercent = ((this.totalHours - prevTotalHours) / prevTotalHours) * 100;
    } else {
      this.changePercent = this.totalHours > 0 ? 100 : 0;
    }

    // 生成图表数据
    this.generateChartData(currentRecords, startDate, endDate);
  }

  // 生成图表数据
  generateChartData(records: WorkRecord[], startDate: Date, endDate: Date) {
    if (this.selectedPeriod === 'week') {
      // 周视图：7天数据
      const dayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      this.chartData = [];
      
      for (let i = 0; i < 7; i++) {
        const date = new Date(startDate);
        date.setDate(startDate.getDate() + i);
        // 使用本地日期格式避免时区偏移
        const year = date.getFullYear();
        const month = (date.getMonth() + 1).toString().padStart(2, '0');
        const day = date.getDate().toString().padStart(2, '0');
        const dateStr = `${year}-${month}-${day}`;
        
        const dayRecords: WorkRecord[] = records.filter((r: WorkRecord): boolean => r.date === dateStr);
        const hours: number = dayRecords.reduce((sum: number, r: WorkRecord): number => sum + r.duration, 0);
        
        this.chartData.push({
          day: dayNames[i],
          hours: Math.round(hours * 10) / 10
        });
      }
    } else if (this.selectedPeriod === 'month') {
      // 月视图：每周数据
      const weekNames = ['第1周', '第2周', '第3周', '第4周', '第5周'];
      this.chartData = [];
      
      for (let week = 0; week < 5; week++) {
        const weekStart = new Date(startDate);
        weekStart.setDate(startDate.getDate() + week * 7);
        const weekEnd = new Date(weekStart);
        weekEnd.setDate(weekStart.getDate() + 6);
        
        const weekRecords: WorkRecord[] = records.filter((r: WorkRecord): boolean => {
          const dateParts = r.date.split('-');
          const recordDate = new Date(parseInt(dateParts[0]), parseInt(dateParts[1]) - 1, parseInt(dateParts[2]));
          return recordDate >= weekStart && recordDate <= weekEnd;
        });
        
        const hours: number = weekRecords.reduce((sum: number, r: WorkRecord): number => sum + r.duration, 0);
        
        if (hours > 0 || week < 4) { // 至少显示4周
          this.chartData.push({
            day: weekNames[week],
            hours: Math.round(hours * 10) / 10
          });
        }
      }
    } else {
      // 年视图：每月数据
      const monthNames = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
      this.chartData = [];
      
      for (let month = 0; month < 12; month++) {
        const monthRecords: WorkRecord[] = records.filter((r: WorkRecord): boolean => {
          const dateParts = r.date.split('-');
          const recordMonth = parseInt(dateParts[1]) - 1; // 月份从0开始
          return recordMonth === month;
        });
        
        const hours: number = monthRecords.reduce((sum: number, r: WorkRecord): number => sum + r.duration, 0);
        
        this.chartData.push({
          day: monthNames[month],
          hours: Math.round(hours * 10) / 10
        });
      }
    }
  }

  // 周期选择器
  @Builder PeriodSelector() {
    Row() {
      Button('周')
        .width(104)
        .height(32)
        .fontSize(14)
        .fontColor(this.selectedPeriod === 'week' ? Color.White : this.themeColors.textSecondary)
        .backgroundColor(this.selectedPeriod === 'week' ? this.themeColors.primaryColor : Color.Transparent)
        .borderRadius(16)
        .onClick(() => {
          this.switchPeriodWithDebounce('week');
        })

      Button('月')
        .width(104)
        .height(32)
        .fontSize(14)
        .fontColor(this.selectedPeriod === 'month' ? Color.White : this.themeColors.textSecondary)
        .backgroundColor(this.selectedPeriod === 'month' ? this.themeColors.primaryColor : Color.Transparent)
        .borderRadius(16)
        .onClick(() => {
          this.switchPeriodWithDebounce('month');
        })

      Button('年')
        .width(104)
        .height(32)
        .fontSize(14)
        .fontColor(this.selectedPeriod === 'year' ? Color.White : this.themeColors.textSecondary)
        .backgroundColor(this.selectedPeriod === 'year' ? this.themeColors.primaryColor : Color.Transparent)
        .borderRadius(16)
        .onClick(() => {
          this.switchPeriodWithDebounce('year');
        })
    }
    .width('calc(100% - 32vp)')
    .height(48)
    .padding(8)
    .backgroundColor(this.themeColors.background)
    .borderRadius(24)
    .margin({ left: 16, right: 16, top: 16 })
    .justifyContent(FlexAlign.SpaceAround)
  }

  // 总览卡片
  @Builder OverviewCard() {
    Column() {
      Row() {
        Column() {
          Row({ space: 4 }) {
            Text(Math.round(this.totalHours).toString())
              .fontSize(48)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeColors.primaryColor)
            Text('小时')
              .fontSize(16)
              .fontColor(this.themeColors.textSecondary)
              .margin({ top: 20 })
          }

          Text(this.selectedPeriod === 'week' ? '本周' : (this.selectedPeriod === 'month' ? '本月' : '今年'))
            .fontSize(14)
            .fontColor(this.themeColors.textHint)
            .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        // 变化指示器
        Row({ space: 4 }) {
          Text(this.changePercent >= 0 ? '↑' : '↓')
            .fontSize(12)
            .fontColor(this.changePercent >= 0 ? this.themeColors.successColor : this.themeColors.errorColor)
          Text(`${this.changePercent >= 0 ? '+' : ''}${this.changePercent.toFixed(1)}%`)
            .fontSize(12)
            .fontColor(this.changePercent >= 0 ? this.themeColors.successColor : this.themeColors.errorColor)
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor(this.changePercent >= 0 ? '#E8F5E9' : '#FFEBEE')
        .borderRadius(12)
      }
      .width('100%')
    }
    .width('calc(100% - 32vp)')
    .padding(20)
    .backgroundColor(this.themeColors.cardBackground)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16 })
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.06)',
      offsetY: 2
    })
  }

  // 统计卡片网格
  @Builder StatsGrid() {
    Grid() {
      GridItem() {
        this.StatCardWithIcon($r('app.media.Currency'), '总收入', `¥${this.totalIncome.toFixed(0)}`)
      }

      GridItem() {
        this.StatCardWithIcon($r('app.media.calendar'), '工作天数', `${this.workDays}`)
      }

      GridItem() {
        this.StatCardWithIcon($r('app.media.Time'), '日均工时', `${this.avgHoursPerDay.toFixed(1)}小时`)
      }

      GridItem() {
        this.StatCardWithIcon($r('app.media.Wallet'), '平均时薪', `¥${this.avgHourlyRate.toFixed(0)}/时`)
      }
    }
    .columnsTemplate('1fr 1fr')
    .rowsTemplate('1fr 1fr')
    .columnsGap(16)
    .rowsGap(16)
    .width('calc(100% - 32vp)')
    .height(240)
    .margin({ left: 16, right: 16, top: 16 })
  }

  // 单个统计卡片（使用图标资源）
  @Builder StatCardWithIcon(icon: Resource, label: string, value: string) {
    Column() {
      Image(icon)
        .width(32)
        .height(32)
        .fillColor(this.themeColors.primaryColor)
        .margin({ bottom: 12 })

      Text(label)
        .fontSize(14)
        .fontColor(this.themeColors.textSecondary)
        .margin({ bottom: 8 })

      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeColors.textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height(110)
    .padding(16)
    .backgroundColor(this.themeColors.cardBackground)
    .borderRadius(10)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Start)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.06)',
      offsetY: 2
    })
  }

  // 单个统计卡片
  @Builder StatCard(icon: string, label: string, value: string) {
    Column() {
      Text(icon)
        .fontSize(32)
        .margin({ bottom: 12 })

      Text(label)
        .fontSize(14)
        .fontColor(this.themeColors.textSecondary)
        .margin({ bottom: 8 })

      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeColors.textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height(110)
    .padding(16)
    .backgroundColor(this.themeColors.cardBackground)
    .borderRadius(10)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Start)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.06)',
      offsetY: 2
    })
  }

  // 图表区域
  @Builder ChartSection() {
    Column() {
      Text(this.selectedPeriod === 'week' ? '周工时趋势' : (this.selectedPeriod === 'month' ? '月工时趋势' : '年工时趋势'))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeColors.textPrimary)
        .margin({ bottom: 16 })

      // 柱状图（使用稳定的key避免重复渲染）
      Row() {
        ForEach(this.chartData, (data: DayData, index: number) => {
          Column() {
            // 柱子
            Column()
              .width(32)
              .height(this.getBarHeight(data.hours))
              .backgroundColor(this.themeColors.primaryColor)
              .borderRadius({ topLeft: 4, topRight: 4 })
            
            // X轴标签
            Text(data.day)
              .fontSize(12)
              .fontColor('#616161')
              .fontWeight(FontWeight.Medium)
              .margin({ top: 8 })
            
            // 数值标签
            Text(`${data.hours}h`)
              .fontSize(10)
              .fontColor(this.themeColors.textSecondary)
              .margin({ top: 4 })
          }
          .height(240)
          .justifyContent(FlexAlign.End)
          .layoutWeight(1)
        }, (data: DayData, index: number) => `${this.selectedPeriod}_${index}_${data.day}`)
      }
      .width('100%')
      .height(240)
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('calc(100% - 32vp)')
    .padding(20)
    .backgroundColor(this.themeColors.cardBackground)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16, bottom: 16 })
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.06)',
      offsetY: 2
    })
  }

  // 计算柱子高度
  getBarHeight(hours: number): number {
    if (this.chartData.length === 0) return 0;
    
    const maxHours = Math.max(...this.chartData.map(d => d.hours), 1);
    const maxHeight = 180; // 最大高度180px
    
    return (hours / maxHours) * maxHeight;
  }

  build() {
    Column() {
      // 顶部标题（使用Column包裹，与TimeRecordPage保持一致）
      Column() {
        Row() {
          Text('数据统计')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeColors.textPrimary)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 60, bottom: 8 })
      }
      .width('100%')
      .backgroundColor(this.themeColors.cardBackground)

      // 内容区域
      Scroll() {
        Column() {
          // 周期选择器
          Column() {
            this.PeriodSelector()
          }
          .margin({ top: 16 })

          // 总览卡片
          this.OverviewCard()

          // 统计卡片网格
          this.StatsGrid()

          // 图表区域
          this.ChartSection()
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .backgroundColor(this.themeColors.background)
    }
    .width('100%')
    .height('100%')
  }
}
