/**
 * 日历热力图组件
 * 参考GitHub贡献图,显示每日打卡完成度
 */

import { StatisticsService } from '../../common/utils/StatisticsService';
import { CommonConstants as Const } from '../../common/constants/CommonConstants';

/**
 * 日历热力图组件
 */
@Component
export struct CalendarHeatmap {
  @State monthData: Map<string, number> = new Map(); // 日期 -> 完成率
  @State currentMonth: number = new Date().getMonth();
  @State currentYear: number = new Date().getFullYear();
  @State isLoading: boolean = true;

  async aboutToAppear() {
    await this.loadMonthData();
  }

  /**
   * 加载当月数据
   */
  async loadMonthData() {
    this.isLoading = true;
    const year = this.currentYear;
    const month = this.currentMonth;

    // 获取当月天数
    const daysInMonth = new Date(year, month + 1, 0).getDate();

    for (let day = 1; day <= daysInMonth; day++) {
      const date = new Date(year, month, day);
      const dateStr = this.formatDate(date);
      const rate = await StatisticsService.calculateDayCompletionRate(date);
      this.monthData.set(dateStr, rate);
    }

    this.isLoading = false;
  }

  /**
   * 格式化日期
   */
  formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  /**
   * 获取热力颜色
   */
  getHeatColor(rate: number): string {
    if (rate === 0) return '#EBEDF0';      // 灰色 - 无数据
    if (rate < 25) return '#C6E48B';       // 浅绿
    if (rate < 50) return '#7BC96F';       // 中绿
    if (rate < 75) return '#239A3B';       // 深绿
    return '#196127';                       // 最深绿
  }

  /**
   * 获取当月所有日期
   */
  getDaysInMonth(): string[] {
    const year = this.currentYear;
    const month = this.currentMonth;
    const daysInMonth = new Date(year, month + 1, 0).getDate();
    const days: string[] = [];

    for (let day = 1; day <= daysInMonth; day++) {
      const date = new Date(year, month, day);
      days.push(this.formatDate(date));
    }

    return days;
  }

  /**
   * 获取星期几
   */
  getDayOfWeek(dateStr: string): number {
    const date = new Date(dateStr);
    return date.getDay(); // 0=周日, 6=周六
  }

  /**
   * 切换到上个月
   */
  previousMonth() {
    if (this.currentMonth === 0) {
      this.currentMonth = 11;
      this.currentYear--;
    } else {
      this.currentMonth--;
    }
    this.loadMonthData();
  }

  /**
   * 切换到下个月
   */
  nextMonth() {
    if (this.currentMonth === 11) {
      this.currentMonth = 0;
      this.currentYear++;
    } else {
      this.currentMonth++;
    }
    this.loadMonthData();
  }

  /**
   * 获取月份名称
   */
  getMonthName(): string {
    const months = ['1月', '2月', '3月', '4月', '5月', '6月', 
                    '7月', '8月', '9月', '10月', '11月', '12月'];
    return months[this.currentMonth];
  }

  /**
   * 单个日期单元格
   */
  @Builder
  DayCell(dateStr: string) {
    Column() {
      Text(new Date(dateStr).getDate().toString())
        .fontSize(10)
        .fontColor((this.monthData.get(dateStr) || 0) > 50 ? '#FFFFFF' : '#333333')
    }
    .width(32)
    .height(32)
    .backgroundColor(this.getHeatColor(this.monthData.get(dateStr) || 0))
    .borderRadius(4)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      // 点击显示详情
      AlertDialog.show({
        title: dateStr,
        message: `完成度: ${this.monthData.get(dateStr) || 0}%`,
        confirm: {
          value: '确定',
          action: () => {}
        }
      });
    })
  }

  build() {
    Column() {
      // 标题和月份切换
      Row() {
        Image($r('app.media.ic_right_grey'))
          .width(20)
          .height(20)
          .rotate({ angle: 180 })
          .onClick(() => this.previousMonth())

        Text(`${this.currentYear}年 ${this.getMonthName()}`)
          .fontSize(16)
          .fontWeight(600)
          .margin({ left: 16, right: 16 })

        Image($r('app.media.ic_right_grey'))
          .width(20)
          .height(20)
          .onClick(() => this.nextMonth())

        Blank()
      }
      .width('100%')
      .margin({ bottom: 16 })

      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(32)
            .height(32)
            .color('#52C41A')
          Text('加载中...')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 8 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else {
        // 星期标题
        Row() {
          Text('日').fontSize(10).fontColor('#999999').width(32).textAlign(TextAlign.Center)
          Text('一').fontSize(10).fontColor('#999999').width(32).textAlign(TextAlign.Center)
          Text('二').fontSize(10).fontColor('#999999').width(32).textAlign(TextAlign.Center)
          Text('三').fontSize(10).fontColor('#999999').width(32).textAlign(TextAlign.Center)
          Text('四').fontSize(10).fontColor('#999999').width(32).textAlign(TextAlign.Center)
          Text('五').fontSize(10).fontColor('#999999').width(32).textAlign(TextAlign.Center)
          Text('六').fontSize(10).fontColor('#999999').width(32).textAlign(TextAlign.Center)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
        .margin({ bottom: 8 })

        // 日历网格
        Grid() {
          ForEach(this.getDaysInMonth(), (dateStr: string) => {
            GridItem() {
              this.DayCell(dateStr)
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
        .rowsGap(4)
        .columnsGap(4)
        .width('100%')

        // 图例
        Row() {
          Text('少')
            .fontSize(10)
            .fontColor('#999999')
            .margin({ right: 4 })

          Row()
            .width(12)
            .height(12)
            .backgroundColor('#EBEDF0')
            .borderRadius(2)
            .margin({ right: 4 })

          Row()
            .width(12)
            .height(12)
            .backgroundColor('#C6E48B')
            .borderRadius(2)
            .margin({ right: 4 })

          Row()
            .width(12)
            .height(12)
            .backgroundColor('#7BC96F')
            .borderRadius(2)
            .margin({ right: 4 })

          Row()
            .width(12)
            .height(12)
            .backgroundColor('#239A3B')
            .borderRadius(2)
            .margin({ right: 4 })

          Row()
            .width(12)
            .height(12)
            .backgroundColor('#196127')
            .borderRadius(2)
            .margin({ right: 4 })

          Text('多')
            .fontSize(10)
            .fontColor('#999999')
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .margin({ top: 16 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.start_window_background'))
    .borderRadius(12)
  }
}
