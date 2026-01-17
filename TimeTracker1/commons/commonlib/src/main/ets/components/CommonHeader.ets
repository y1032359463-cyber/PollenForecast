import { RouterModule } from '../utils/router/Router';

@Preview
@ComponentV2
export struct CommonHeader {
  @Param title: string = '';
  @Param bgColor: ResourceStr = $r('app.color.system_color_background_transparent');
  private _topBannerHeight: number = 56;

  @Computed
  get showBackButton() {
    return Boolean(RouterModule.size() > 0);
  }

  build() {
    Row() {
      if (this.showBackButton) {
        Row() {
          Image($r('app.media.ic_arrow_left'))
            .fillColor($r('app.color.font_color_level1'))
            .height(20)
        }
        .backgroundColor($r('app.color.system_color_background_grey_level2'))
        .borderRadius($r('app.string.border_radius_capsule'))
        .margin({ right: $r('app.string.space_s') })
        .height(40)
        .width(40)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          RouterModule.pop();
        });
      }
      Text(this.title)
        .fontSize(this.showBackButton ? $r('app.string.font_size_20') : $r('app.string.font_size_24'))
        .fontColor($r('app.color.font_color_level1'))
        .margin({left:$r('app.string.space_m')})
        .fontWeight(this.showBackButton ? FontWeight.Medium : FontWeight.Bold);
    }
    .width($r('app.string.width_percent_full'))
    .backgroundColor(this.bgColor)
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .height(this._topBannerHeight)
    .padding({ left: $r('app.string.space_s') })
    .margin({bottom:$r('app.string.space_s')})
  }
}