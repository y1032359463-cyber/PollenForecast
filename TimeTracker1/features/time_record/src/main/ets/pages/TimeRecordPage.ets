/**
 * 工时记录首页
 * 主要功能：月历视图 + 月度汇总
 */

import { router } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { CalendarCell } from '@ohos/time_calendar'
import { SummaryCard } from '@ohos/time_card'
import { storageUtils, EventBus, GLOBAL_REFRESH_EVENT, UIConstants, ThemeManager, type ThemeColors } from '@ohos/commonlib'
import type { WorkRecord } from '@ohos/commonlib'

@Component
export default struct TimeRecordPage {
  // 主题管理
  @StorageProp('themeColors') themeColors: ThemeColors = ThemeManager.getInstance().colors
  private themeManager: ThemeManager = ThemeManager.getInstance()

  @State currentYear: number = new Date().getFullYear()
  @State currentMonth: number = new Date().getMonth() + UIConstants.ONE // JavaScript月份是0-11
  @State selectedDate: number = new Date().getDate()
  @State todayDate: number = new Date().getDate()

  // 工时记录数据
  @State allRecords: WorkRecord[] = []
  @State workDates: Set<number> = new Set() // 有工时数据的日期
  @State monthTotalHours: number = UIConstants.ZERO // 本月总工时
  @State monthTotalAmount: number = UIConstants.ZERO // 本月总收入

  // 星期标签
  private weekDays: string[] = ['一', '二', '三', '四', '五', '六', '日']

  // Sheet弹窗状态
  @State showDateSheet: boolean = false
  @State selectedDateRecords: WorkRecord[] = [] // 选中日期的工时记录

  // 刷新主题
  refreshTheme(): void{
    this.themeColors = this.themeManager.colors;
  }

  /**
   * 页面初始化时加载数据
   */
  async aboutToAppear(): Promise<void>{
    await this.loadWorkRecords()
    // 监听全局刷新事件
    EventBus.instance.on(GLOBAL_REFRESH_EVENT, () => {
      this.loadWorkRecords()
    })
  }

  /**
   * 页面显示时重新加载数据（从其他页面返回时）
   */
  onPageShow(): void{
    this.loadWorkRecords()
  }

  /**
   * 加载工时记录
   */
  private async loadWorkRecords(): Promise<void>{
    try {
      this.allRecords = await storageUtils.getAllWorkRecords()
      this.calculateMonthData()
      console.info(`[TimeRecord] Loaded ${this.allRecords.length} work records`)
    } catch (error) {
      console.error('[TimeRecord] Failed to load records:', error)
    }
  }

  /**
   * 计算本月数据（工时、收入、有数据的日期）
   */
  private calculateMonthData(): void{
    const workDatesSet = new Set<number>()
    let totalHours = 0
    let totalAmount = 0

    this.allRecords.forEach((record: WorkRecord) => {
      const recordDate = new Date(record.date)
      
      // 只统计当前选中月份的数据
      if (recordDate.getFullYear() === this.currentYear && 
          recordDate.getMonth() + UIConstants.ONE === this.currentMonth) {
        
        // 添加到有数据的日期集合
        workDatesSet.add(recordDate.getDate())
        
        // 累计工时
        totalHours += record.duration
        
        // 计算收入：基本工资 + 补贴 - 扣款
        const baseWage = record.duration * record.hourlyWage
        const actualIncome = baseWage + record.allowance - record.deduction
        totalAmount += actualIncome
      }
    })

    this.workDates = workDatesSet
    // 保留1位小数
    this.monthTotalHours = Math.round(totalHours * UIConstants.DECIMAL_PLACES_ONE) /
      UIConstants.DECIMAL_PLACES_ONE
    // 保留2位小数
    this.monthTotalAmount = Math.round(totalAmount * UIConstants.DECIMAL_PLACES_TWO) /
      UIConstants.DECIMAL_PLACES_TWO
  }

  // 获取当月天数
  private getDaysInMonth(): number{
    return new Date(this.currentYear, this.currentMonth, UIConstants.ZERO).getDate()
  }

  // 获取月份第一天是星期几（0-6，0表示周一）
  private getFirstDayOfWeek(): number{
    const firstDay = new Date(this.currentYear, this.currentMonth - UIConstants.ONE, UIConstants.ONE).getDay()
    // 转换为周一为0的格式
    return firstDay === UIConstants.SUNDAY_INDEX ? UIConstants.MONDAY_OFFSET : firstDay - UIConstants.ONE
  }

  build(){
    Column() {
      // 1. Header Section
      Column() {
        Row() {
          Text('工时日志')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeColors.textPrimary)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 60, bottom: 8 })
      }
      .width('100%')
      .backgroundColor(this.themeColors.surfaceBackground)

      Scroll() {
        Column() {
          // 2. Month Selector - 灰色背景,三角形箭头
          Row() {
            // 左箭头 - 44×44px触摸区域
            Row() {
              Image($r('app.media.ic_arrow_left'))
                .width(UIConstants.ICON_SIZE_SMALL)
                .height(UIConstants.ICON_SIZE_SMALL)
                .fillColor(this.themeColors.textSecondary)
            }
            .width(UIConstants.MIN_TOUCH_TARGET)
            .height(UIConstants.MIN_TOUCH_TARGET)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              // Previous month logic
              if (this.currentMonth > UIConstants.ONE) {
                this.currentMonth--
              } else {
                this.currentMonth = UIConstants.MONTHS_PER_YEAR
                this.currentYear--
              }
              this.calculateMonthData()
            })

            Text(`${this.currentYear}年${this.currentMonth}月`)
              .fontSize(UIConstants.FONT_SIZE_LG)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeColors.textPrimary)
              .layoutWeight(UIConstants.LAYOUT_WEIGHT_FULL)
              .textAlign(TextAlign.Center)

            // 右箭头 - 44×44px触摸区域
            Row() {
              Image($r('app.media.ic_arrow_right'))
                .width(UIConstants.ICON_SIZE_SMALL)
                .height(UIConstants.ICON_SIZE_SMALL)
                .fillColor(this.themeColors.textSecondary)
            }
            .width(UIConstants.MIN_TOUCH_TARGET)
            .height(UIConstants.MIN_TOUCH_TARGET)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              // Next month logic
              if (this.currentMonth < UIConstants.MONTHS_PER_YEAR) {
                this.currentMonth++
              } else {
                this.currentMonth = UIConstants.ONE
                this.currentYear++
              }
              this.calculateMonthData()
            })
          }
          .width('calc(100% - 32vp)')
          .height(UIConstants.MONTH_SELECTOR_HEIGHT)
          .backgroundColor(this.themeColors.cardBackground)
          .borderRadius(UIConstants.RADIUS_SM)
          .margin({ left: UIConstants.SPACING_LG, right: UIConstants.SPACING_LG, top: UIConstants.SPACING_MD })

          // 3. Calendar Grid - 无背景
          Column() {
            // Week header
            Row() {
              ForEach(this.weekDays, (day: string) => {
                Text(day)
                  .fontSize(UIConstants.FONT_SIZE_XS)
                  .fontWeight(FontWeight.Regular)
                  .fontColor(this.themeColors.textSecondary)
                  .width(UIConstants.CALENDAR_CELL_SIZE)
                  .textAlign(TextAlign.Center)
              })
            }
            .width('100%')
            .height(UIConstants.WEEK_HEADER_HEIGHT)
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: UIConstants.SPACING_XXS })

            // Calendar days
            Grid() {
              // Empty cells before first day
              ForEach(Array(this.getFirstDayOfWeek()).fill(UIConstants.ZERO),
                (_: number, index: number) => {
                GridItem() {
                  Row()
                    .width(UIConstants.CALENDAR_CELL_SIZE)
                    .height(UIConstants.CALENDAR_CELL_SIZE)
                }
              }, (_: number, index: number) => index.toString())

              // Days of month
              ForEach(Array(this.getDaysInMonth()).fill(UIConstants.ZERO)
                .map((_: number, i: number) => i + UIConstants.ONE),
                (date: number, index: number) => {
                GridItem() {
                  CalendarCell({
                    date: date,
                    isToday: date === this.todayDate,
                    isSelected: date === this.selectedDate,
                    hasData: this.workDates.has(date),
                    isCurrentMonth: true,
                    onCellClick: () => {
                      this.selectedDate = date
                      console.info(`[TimeRecord] Date ${date} selected, show sheet`)
                      
                      // 筛选该日期的工时记录
                      const year = this.currentYear
                      const month = this.currentMonth.toString().padStart(2, '0')
                      const day = date.toString().padStart(2, '0')
                      const selectedDateStr = `${year}-${month}-${day}`
                      
                      this.selectedDateRecords = this.allRecords.filter((record: WorkRecord) => {
                        return record.date === selectedDateStr
                      })
                      
                      // 显示Sheet弹窗
                      this.showDateSheet = true
                    }
                  })
                }
              }, (date: number, index: number) => date.toString())
            }
            .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
            .rowsGap(4)
            .columnsGap(4)
            .width('100%')
          }
          .padding(UIConstants.CALENDAR_PADDING)          // 4. Summary Card - 使用真实数据
          Column() {
            SummaryCard({
              hours: this.monthTotalHours,
              amount: this.monthTotalAmount,
              label: '本月'
            })
          }
          .padding({ left: 0, right: 0, top: 16, bottom: 20 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColors.background)
    .bindSheet($$this.showDateSheet, this.DateRecordsSheet(), {
      height: SheetSize.MEDIUM,
      showClose: false,
      dragBar: true,
      backgroundColor: this.themeColors.cardBackground,
      onDisappear: () => {
        this.showDateSheet = false
      }
    })
  }

  // Sheet弹窗：显示选中日期的工时记录
  @Builder
  DateRecordsSheet(){
    Column() {
      // 标题
      Text(`${this.currentYear}年${this.currentMonth}月${this.selectedDate}日`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeColors.textPrimary)
        .margin({ top: 16, bottom: 16 })

      // 工时记录列表
      if (this.selectedDateRecords.length === 0) {
        Column() {
          Text('暂无记录')
            .fontSize(14)
            .fontColor(this.themeColors.textHint)
            .margin({ top: 40, bottom: 40 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.selectedDateRecords, (record: WorkRecord) => {
            ListItem() {
              Row() {
                Column({ space: 4 }) {
                  Text(record.projectName || '无项目名称')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeColors.textPrimary)
                  
                  Text(`${record.startTime} - ${record.endTime} · ${record.duration}小时`)
                    .fontSize(12)
                    .fontColor(this.themeColors.textSecondary)
                }
                .alignItems(HorizontalAlign.Start)

                Blank()

                Text(`¥${(record.duration * record.hourlyWage + record.allowance - record.deduction).toFixed(2)}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeColors.primaryColor)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(this.themeColors.cardBackground)
              .borderRadius(12)
            }
            .margin({ bottom: 8 })
          })
        }
        .width('calc(100% - 32vp)')
        .margin({ left: 16, right: 16 })
        .layoutWeight(1)
      }

      // 添加工时记录按钮
      Button('添加工时记录')
        .width('calc(100% - 32vp)')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.themeColors.primaryColor)
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 16, bottom: 40 })
        .onClick(() => {
          // 关闭Sheet
          this.showDateSheet = false
          
          // 构造选中的日期字符串
          const year = this.currentYear
          const month = this.currentMonth.toString().padStart(2, '0')
          const day = this.selectedDate.toString().padStart(2, '0')
          const selectedDate = `${year}-${month}-${day}`
          
          // 导航到添加工时页面
          router.pushUrl({
            url: 'pages/AddRecordPage',
            params: {
              date: selectedDate
            }
          }).then(() => {
            console.info('Successfully navigated to AddRecordPage');
          }).catch((err: BusinessError) => {
            console.error(`Failed to navigate: ${err.code}, ${err.message}`);
          });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColors.background)
  }

  private getMonthName(month: number): string{
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December']
    return months[month - UIConstants.ONE]
  }
}
