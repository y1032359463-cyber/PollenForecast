/**
 * UserCard Component
 * 用户信息卡片 - 支持登录/未登录两种状态
 * 
 * 设计规范:
 * - 尺寸: 328×140vp
 * - 背景: 蓝色渐变 (#2196F3 → #64B5F6)
 * - 布局: 头像左侧，文本右侧，间距 12vp
 * - 阴影: rgba(33,150,243,0.3) 12vp 模糊
 * 
 * 云同步功能预留:
 * - isLoggedIn: 控制显示登录/未登录状态
 * - onLoginClick: 登录按钮点击回调
 * - userName/userRole/memberSince: 登录后显示的用户信息
 */

@Component
export struct UserCard {
  // 云同步功能接口(预留)
  @Prop isLoggedIn: boolean = false // 是否已登录华为账号
  @Prop userName: string = '未设置' // 用户名(登录后从服务端获取)
  @Prop userRole: string = '小时工' // 用户角色
  @Prop memberSince: string = '注册于 2025年11月' // 注册时间
  onLoginClick: () => void = () => {} // 登录按钮点击回调(不使用@Prop避免可选参数警告)

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

      // 用户信息 - 根据登录状态显示不同内容
      if (this.isLoggedIn) {
        // 已登录状态:显示用户信息
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
      } else {
        // 未登录状态:显示登录提示
        Column({ space: 8 }) {
          Text('未登录')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Text('登录后可使用云同步功能')
            .fontSize(14)
            .fontColor('rgba(255, 255, 255, 0.8)')

          // 登录按钮(云同步功能开发时启用)
          Row() {
            Text('登录华为账号')
              .fontSize(14)
              .fontColor('#2196F3')
              .fontWeight(FontWeight.Medium)
          }
          .width(120)
          .height(32)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.onLoginClick();
          })
          .visibility(Visibility.None) // TODO: 云同步功能开发时改为Visibility.Visible
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
      }
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
