import { RouterModule, CommonConstants } from 'lib_foundation';
import { BaseTitleBuilder } from 'lib_foundation';
@ComponentV2
export struct MinePage {

  build() {
    NavDestination() {
      Column() {
        Row({ space: 16 }) {
          Row() {
            Image($r('app.media.ic_info')).width(21).height(21)
            Text('关于').fontColor($r('sys.color.font_primary')).margin({left: 13})
          }
          Image($r('app.media.chevron_right_new')).width(8).height(14).margin({left: 10, top: 7, bottom: 7, right: 10})
        }.rowStyle()
        .onClick(() => {
          RouterModule.getStack().pushPathByName('AboutPage', null);
        })
      }.padding({left: 16, right: 16}).margin({top: 20})
    }.title(BaseTitleBuilder('我的')).backgroundColor($r('sys.color.background_secondary'))
  }
}


@Extend(Row)
function rowStyle() {
  .justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
  .borderRadius(16)
  .backgroundColor($r('sys.color.comp_background_list_card'))
  .padding(16).width(CommonConstants.FULL_PERCENT)
}