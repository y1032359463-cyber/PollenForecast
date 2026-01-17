import { WeeklyBarChart, DayData } from '../../../../components/time_chart/Index';

/**
 * Mock data for chart and stats.
 * In a real application, this would be fetched from a ViewModel.
 */
const mockChartData: DayData[] = [
  { day: '一', hours: 4 },
      Image($r('app.media.ic_chart'))
        .width(28)
        .height(28)
        .margin({ right: 12 })
      Text("统计")
        .fontSize(26)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
  { day: '六', hours: 2 },
  { day: '日', hours: 1 },
];

const mockTotalHours = "16小时48分钟";
const mockComparison = "+5%";
const mockLongestSession = "2小时30分钟";
const mockAverageSession = "1小时15分钟";
const mockFocusDays = "5天";
const mockFocusSessions = "12次";


@Component
export struct StatisticsView {
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding(4)
    .justifyContent(FlexAlign.SpaceAround)
    .width('100%')
    .padding({ left: 16, right: 16 })
    .margin({ left: 16, right: 16, top: -28 })
    .shadow({ radius: 12, color: 'rgba(0,0,0,0.08)', offsetY: 4 });

      // 2. Period Selector
      this.PeriodSelector();

      // Scrollable content area
    Text(params.label)
      .fontSize(16)
      .fontWeight(isSelected ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(isSelected ? Color.White : '#757575')
      .padding({ top: 10, bottom: 10, left: 28, right: 28 })
      .backgroundColor(isSelected ? '#2196F3' : '#F5F5F5')
      .borderRadius(14)
      .onClick(() => {
        this.selectedPeriod = params.label;
      });
      .scrollBar(BarState.Off)

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5');
  }

  @Builder
  TopBar() {
    Row() {
      Text("统计")
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
    }
    .width('100%')
    .height(72)
    .padding({ left: 20, right: 20, top: 12 })
    .linearGradient({
      angle: 135,
      colors: [[0x2196F3, 0.0], [0x64B5F6, 1.0]]
    });
  }

  @Builder
  PeriodSelector() {
    Row() {
      this.PeriodButton({ label: '周' });
      this.PeriodButton({ label: '月' });
      this.PeriodButton({ label: '年' });
    }
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .padding(6)
    .justifyContent(FlexAlign.SpaceAround)
    .width('calc(100% - 32vp)')
    .margin({ left: 16, right: 16, top: -28 })
    .shadow({
      radius: 12,
      color: 'rgba(0, 0, 0, 0.08)',
      offsetY: 4
    });
  }

    .padding(20)
  PeriodButton(params: { label: '周' | '月' | '年' }) {
    .borderRadius(16)
    .width('100%')
    .margin({ left: 16, right: 16, top: 20 })
    .shadow({ radius: 16, color: 'rgba(0,0,0,0.06)', offsetY: 4 })
      .fontColor(this.selectedPeriod === params.label ? '#FFFFFF' : '#757575')
      .padding({ top: 10, bottom: 10, left: 28, right: 28 })
      .backgroundColor(this.selectedPeriod === params.label ? '#2196F3' : '#F5F5F5')
      .borderRadius(12)
      .onClick(() => {
        this.selectedPeriod = params.label;
        .fontSize(15)
  }

  @Builder
        .fontSize(24)
    Column() {
      // Chart Title
      Row() {
    .padding(20)
          .fontSize(18)
    .borderRadius(16)
    .shadow({ radius: 12, color: 'rgba(0,0,0,0.06)', offsetY: 4 })
        Text("本周")
          .fontSize(14)
          .fontColor('#666666')
          .margin({ left: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 16 })

      // Chart
      WeeklyBarChart({ data: mockChartData })
        .margin({ bottom: 16 })

      // Divider
      Divider().color('#E0E0E0').strokeWidth(1).width('100%')

      // Total Hours
      Row() {
        Text("总时长")
          .fontSize(16)
          .fontColor('#333333')
        Row() {
          Text(mockTotalHours)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          Text(mockComparison)
            .fontSize(14)
            .fontColor('#4CAF50') // Green for positive
            .margin({ left: 8 })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 16 })
    }
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .width('100%')
    .margin({ left: 16, right: 16, top: 20, bottom: 16 })
    .shadow({
      radius: 16,
      color: 'rgba(0, 0, 0, 0.06)',
      offsetY: 4
    });
  }

  @Builder
  StatsGrid() {
    GridRow({
      columns: 2,
      gutter: { x: 12, y: 12 }
    }) {
      GridCol() {
        this.StatCard({ title: "最长专注", value: mockLongestSession });
      }
      GridCol() {
        this.StatCard({ title: "平均专注", value: mockAverageSession });
      }
      GridCol() {
        this.StatCard({ title: "专注天数", value: mockFocusDays });
      }
      GridCol() {
        this.StatCard({ title: "专注次数", value: mockFocusSessions });
      }
    }
  }

  @Builder
  StatCard(params: { title: string, value: string }) {
    Column() {
      Text(params.title)
        .fontSize(15)
        .fontColor('#757575')
        .margin({ bottom: 8 })
      Text(params.value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#212121')
    }
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .shadow({
      radius: 12,
      color: 'rgba(0, 0, 0, 0.06)',
      offsetY: 4
    });
  }
}
