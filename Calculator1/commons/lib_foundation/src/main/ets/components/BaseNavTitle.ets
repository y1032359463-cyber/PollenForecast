import { RouterModule } from '../router/RouterModule';
@ComponentV2
export struct BaseNavTitle {
  @Param title: ResourceStr = ''
  @Param routerModule?: NavPathStack = RouterModule.getStack()

  build() {
    Row({ space: 8 }) {
      Column() {
        Image($r('app.media.base_left')).height(24).width(24)
          .objectFit(ImageFit.Contain).onClick(() => {
          this.routerModule?.pop()
        })
      }.borderRadius('50%').padding(8)
      .backgroundColor($r('app.color.base_nav_title_icon'))
      .opacity(0.1)
      .justifyContent(FlexAlign.Center)

      Text(this.title).fontColor($r('app.color.base_nav_title_icon')).fontSize(20).fontWeight(700).opacity(0.9)
        .lineHeight(27)
    }
    .height(36)
    .constraintSize({maxWidth : '100%'})
    .margin({ top: 10, right: 100 })
    .width('100%')
    .onClick(() => {
      this.routerModule?.pop()
    })
  }
}