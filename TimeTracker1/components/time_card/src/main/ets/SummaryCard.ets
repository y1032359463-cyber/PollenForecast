/**
 * 月度工时汇总卡片
 * 蓝色渐变背景 + 时钟图标
 * 显示：本月工时 + 收入金额
 */

import { UIConstants } from '@ohos/commonlib'

@Component
export struct SummaryCard {
  @Prop hours: number = 128 // 工时数
  @Prop amount: number = 3840 // 收入金额
  @Prop label: string = '本月工时' // 标签文字
  @State private scaleValue: number = UIConstants.ONE // 按压缩放状态

  build() {
    Row() {
      // 左侧：文字信息
      Column({ space: UIConstants.SPACING_XS }) {
        Text(this.label)
          .fontSize(UIConstants.FONT_SIZE_SM)
          .fontColor('#FFFFFF')
          .opacity(UIConstants.OPACITY_HIGH)
          .fontWeight(FontWeight.Regular)

        Text(`${this.hours} 小时`)
          .fontSize(UIConstants.FONT_SIZE_XXXL)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .lineHeight(40)

        Text(`¥${this.amount.toLocaleString()}`)
          .fontSize(UIConstants.FONT_SIZE_XL)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .opacity(UIConstants.OPACITY_VERY_HIGH)
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      // 右侧：时钟图标
      Image($r('app.media.ic_clock'))
        .width(UIConstants.ICON_SIZE_LARGE)
        .height(UIConstants.ICON_SIZE_LARGE)
        .fillColor('#FFFFFF')
        .opacity(0.7)
    }
    .width('calc(100% - 32vp)')
    .height(UIConstants.SUMMARY_CARD_HEIGHT)
    .padding(UIConstants.SPACING_LG)
    .linearGradient({
      angle: 135,
      colors: [
        ['#2196F3', 0.0],
        ['#64B5F6', 1.0]
      ]
    })
    .borderRadius(UIConstants.RADIUS_MD)
    .shadow({
      radius: UIConstants.SHADOW_RADIUS_MD,
      color: 'rgba(33, 150, 243, 0.3)',
      offsetX: UIConstants.ZERO,
      offsetY: UIConstants.SHADOW_OFFSET_Y
    })
    .margin({ left: UIConstants.SPACING_LG, right: UIConstants.SPACING_LG })
    .scale({ x: this.scaleValue, y: this.scaleValue })
    .animation({
      duration: UIConstants.ANIMATION_DURATION_FAST,
      curve: Curve.EaseOut
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.scaleValue = UIConstants.OPACITY_CARD_PRESS
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.scaleValue = UIConstants.ONE
        if (event.type === TouchType.Up) {
          console.info('Summary card clicked')
        }
      }
    })
  }
}
