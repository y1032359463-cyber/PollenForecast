/**
 * 周工时柱状图组件
 * 显示周一到周日的工时数据
 * 
 * 设计规格（符合 Figma 规范）：
 * - 容器：288×180px（不含标题和外边距）
 * - 7 根柱子（周一-周日）
 * - 柱子宽度：32px，间距：12px
 * - 柱子颜色：渐变 #2196F3 → #64B5F6
 * - 顶部圆角：4px
 * - 阴影：0 2px 4px rgba(33,150,243,0.2)
 * - 高度范围：0-10 小时
 * - 数据标签：顶部显示，14px/700
 */

export interface DayData {
  day: string;
  hours: number;
}

@Component
export struct WeeklyBarChart {
  @Prop data: DayData[] = [
    { day: '周一', hours: 8.5 },
    { day: '周二', hours: 7.2 },
    { day: '周三', hours: 9.1 },
    { day: '周四', hours: 6.8 },
    { day: '周五', hours: 8.0 },
    { day: '周六', hours: 4.5 },
    { day: '周日', hours: 3.2 },
  ];
  
  private maxHours: number = 10; // Y 轴最大值
  private chartHeight: number = 160; // 图表有效高度（不含标签）

  /**
   * 计算柱子高度（按比例）
   */
  private getBarHeight(hours: number): number {
    if (hours === 0) return 0;
    return Math.max((hours / this.maxHours) * this.chartHeight, 8); // 最小高度 8px
  }

  build() {
    Column() {
      // 图表区域
      Row({ space: 12 }) {
        ForEach(this.data, (item: DayData, index: number) => {
          Column({ space: 4 }) {
            // 柱子容器（固定高度，从底部对齐）
            Stack({ alignContent: Alignment.Bottom }) {
              // 数据标签（显示在柱子顶部）
              if (item.hours > 0) {
                Text(`${item.hours}h`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#212121')
                  .position({ x: 0, y: -(this.getBarHeight(item.hours) + 12) })
                  .width(32)
                  .textAlign(TextAlign.Center)
              }
              
              // 柱子（带渐变和阴影）
              Column()
                .width(32)
                .height(this.getBarHeight(item.hours))
                .linearGradient({
                  angle: 180,
                  colors: [
                    ['#2196F3', 0.0],
                    ['#64B5F6', 1.0]
                  ]
                })
                .borderRadius({ topLeft: 4, topRight: 4 })
                .shadow({
                  radius: 4,
                  color: 'rgba(33, 150, 243, 0.2)',
                  offsetX: 0,
                  offsetY: 2
                })
            }
            .width(32)
            .height(this.chartHeight)
            
            // X 轴标签（星期）
            Text(item.day)
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor('#9E9E9E')
              .textAlign(TextAlign.Center)
              .width(32)
              .margin({ top: 8 })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.End)
          .alignItems(HorizontalAlign.Center)
        })
      }
      .width('100%')
      .height(this.chartHeight + 48) // 图表高度 + 标签高度 + 数据标签空间
      .justifyContent(FlexAlign.SpaceEvenly)
      .alignItems(VerticalAlign.Bottom)
    }
    .width('100%')
  }
}
