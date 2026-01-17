/**
 * UserCard Component
 * 用户信息卡片 - 显示头像、用户名、角色和注册时间
 * 
 * 设计规范:
 * - 尺寸: 328×140vp
 * - 背景: 蓝色渐变 (#2196F3 → #64B5F6)
 * - 布局: 头像左侧，文本右侧，间距 12vp
 * - 阴影: rgba(33,150,243,0.3) 12vp 模糊
 */

@Component
export struct UserCard {
  @Prop userName: string = 'User Name'
  @Prop userRole: string = 'Hourly Worker'
  @Prop memberSince: string = 'Since Nov 2025'

  build() {
    Row() {
      // 头像
      Row() {
        Image($r('sys.symbol.person_fill'))
          .width(32)
          .height(32)
          .fillColor('#2196F3')
      }
      .width(64)
      .height(64)
      .backgroundColor(Color.White)
      .borderRadius(32)
      .justifyContent(FlexAlign.Center)

      // 用户信息
      Column({ space: 4 }) {
        Text(this.userName)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)

        Text(this.userRole)
          .fontSize(14)
          .fontColor('rgba(255, 255, 255, 0.8)')

        Text(this.memberSince)
          .fontSize(12)
          .fontColor('rgba(255, 255, 255, 0.7)')
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
    }
    .width('100%')
    .height(140)
    .padding(20)
    .linearGradient({
      angle: 135,
      colors: [['#2196F3', 0.0], ['#64B5F6', 1.0]]
    })
    .borderRadius(12)
    .shadow({
      radius: 12,
      color: 'rgba(33, 150, 243, 0.3)',
      offsetX: 0,
      offsetY: 4
    })
  }
}
