/**
 * 数据统计页面
 * 展示周/月统计图表和关键指标
 */

import { LineChart, BarChart } from '../view/statistics/ChartComponent';
import { CalendarHeatmap } from '../view/statistics/CalendarHeatmap';
import { StatisticsService, ChartDataPoint } from '../common/utils/StatisticsService';
import { CommonConstants as Const } from '../common/constants/CommonConstants';

@Entry
@Component
struct StatisticsPage {
  @State weeklyData: ChartDataPoint[] = [];
  @State monthlyData: ChartDataPoint[] = [];
  @State streakDays: number = 0;
  @State totalCompleted: number = 0;
  @State weekCompletionRate: number = 0;
  @State monthCompletionRate: number = 0;
  @State isLoading: boolean = true;

  async aboutToAppear() {
    await this.loadStatisticsData();
  }

  /**
   * 加载统计数据
   */
  async loadStatisticsData() {
    try {
      this.isLoading = true;

      // 并行加载所有数据
      const results = await Promise.all([
        StatisticsService.getWeeklyCompletionData(),
        StatisticsService.getMonthlyCompletionData(),
        StatisticsService.getStreakDays(),
        StatisticsService.getTotalCompletedTasks(),
        StatisticsService.getCurrentWeekCompletionRate(),
        StatisticsService.getCurrentMonthCompletionRate()
      ]);

      this.weeklyData = results[0];
      this.monthlyData = results[1];
      this.streakDays = results[2];
      this.totalCompleted = results[3];
      this.weekCompletionRate = results[4];
      this.monthCompletionRate = results[5];
    } catch (error) {
      console.error('加载统计数据失败:', JSON.stringify(error));
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 关键指标卡片
   */
  @Builder
  MetricCard(title: string, value: string, subtitle: string, color: string) {
    Column() {
      Text(title)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 8 })

      Text(value)
        .fontSize(32)
        .fontWeight(600)
        .fontColor(color)
        .margin({ bottom: 4 })

      Text(subtitle)
        .fontSize(12)
        .fontColor('#666666')
    }
    .width('48%')
    .padding(16)
    .backgroundColor($r('app.color.start_window_background'))
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Image($r('app.media.ic_right_grey'))
          .width(24)
          .height(24)
          .rotate({ angle: 180 })
          .onClick(() => {
            this.getUIContext().getRouter().back();
          })

        Text('数据统计')
          .fontSize(20)
          .fontWeight(600)
          .margin({ left: 12 })

        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color('#52C41A')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            // 关键指标区域
            Row({ space: 12 }) {
              this.MetricCard(
                '连续打卡',
                this.streakDays.toString(),
                '天',
                '#FF6B6B'
              )

              this.MetricCard(
                '累计完成',
                this.totalCompleted.toString(),
                '个任务',
                '#52C41A'
              )
            }
            .width('100%')

            Row({ space: 12 }) {
              this.MetricCard(
                '本周完成率',
                this.weekCompletionRate + '%',
                '较上周持平',
                '#1890FF'
              )

              this.MetricCard(
                '本月完成率',
                this.monthCompletionRate + '%',
                '继续保持',
                '#722ED1'
              )
            }
            .width('100%')

            // 周完成度折线图
            if (this.weeklyData.length > 0) {
              LineChart({
                chartData: this.weeklyData,
                chartTitle: '本周完成度趋势',
                primaryColor: '#52C41A'
              })
                .margin({ top: 8 })
            } else {
              // 空状态提示
              Column() {
                Text('📊')
                  .fontSize(48)
                  .margin({ bottom: 16 })
                Text('暂无数据')
                  .fontSize(16)
                  .fontColor('#999999')
                  .margin({ bottom: 8 })
                Text('完成几个任务后再来查看吧!')
                  .fontSize(14)
                  .fontColor('#CCCCCC')
              }
              .width('100%')
              .height(200)
              .backgroundColor($r('app.color.start_window_background'))
              .borderRadius(12)
              .justifyContent(FlexAlign.Center)
              .margin({ top: 8 })
            }

            // 月汇总柱状图
            if (this.monthlyData.length > 0) {
              BarChart({
                chartData: this.monthlyData,
                chartTitle: '近30天完成统计',
                primaryColor: '#1890FF'
              })
                .margin({ bottom: 16 })
            } else {
              // 空状态提示
              Column() {
                Text('📈')
                  .fontSize(48)
                  .margin({ bottom: 16 })
                Text('暂无数据')
                  .fontSize(16)
                  .fontColor('#999999')
                  .margin({ bottom: 8 })
                Text('坚持打卡,积累数据!')
                  .fontSize(14)
                  .fontColor('#CCCCCC')
              }
              .width('100%')
              .height(200)
              .backgroundColor($r('app.color.start_window_background'))
              .borderRadius(12)
              .justifyContent(FlexAlign.Center)
              .margin({ bottom: 16 })
            }

            // 日历热力图
            CalendarHeatmap()
              .margin({ bottom: 16 })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.primaryBgColor'))
  }
}
