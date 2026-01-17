/**
 * VIPBanner Component
 * VIP 升级横幅 - 仅展示界面，不实现具体功能
 * 
 * 设计规范:
 * - 尺寸: 328×80vp
 * - 背景: 金色渐变 (#FFD700 → #FFA500)
 * - 布局: 图标左 | 文本中 | 按钮右
 * - 阴影: rgba(255,165,0,0.3) 12vp 模糊
 */

@Component
export struct VIPBanner {
  build() {
    Row() {
      // VIP 图标
      Text('⭐')
        .fontSize(32)
        .margin({ right: 12 })

      // 文本信息
      Column({ space: 4 }) {
        Text('升级VIP会员')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Text('解锁高级功能')
          .fontSize(12)
          .fontColor('rgba(255, 255, 255, 0.8)')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 按钮
      Text('了解更多')
        .fontSize(14)
        .fontColor(Color.White)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor('rgba(255, 255, 255, 0.3)')
        .borderRadius(16)
    }
    .width('100%')
    .height(80)
    .padding(16)
    .linearGradient({
      angle: 135,
      colors: [['#FFD700', 0.0], ['#FFA500', 1.0]]
    })
    .borderRadius(12)
    .shadow({
      radius: 12,
      color: 'rgba(255, 165, 0, 0.3)',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      // 仅展示界面，不实现功能
      console.info('VIP upgrade clicked - interface only')
    })
  }
}
