import { CommonConstants, RouterModule } from 'lib_foundation';

@Builder
export function AboutPageBuilder() {
  AboutPage()
}

@ComponentV2
export struct AboutPage {
  @Local title: string = '';

  build() {
    NavDestination() {
      Column() {
        Row({ space: 16 }) {
          Text('用户协议与隐私政策').fontColor($r('sys.color.font_primary'))
            .margin({ left: 13 })
          Image($r('app.media.chevron_right_new')).width(8).height(14).margin({left: 10, top: 7, bottom: 7, right: 10})
        }.rowStyle()
        .onClick(() => {
          const params: Record<string, string> = {
            'title': '用户协议与隐私政策',
            'type': 'agreement'
          }
          RouterModule.getStack().pushPathByName('AgreementPrivacy', params)
        })
      }.padding({left: 16, right: 16})
    }
    .backgroundColor($r('sys.color.background_secondary')).title('关于')
  }
}


@Extend(Row)
function rowStyle() {
  .justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
  .borderRadius(16)
  .backgroundColor($r('sys.color.comp_background_list_card'))
  .padding(16).width(CommonConstants.FULL_PERCENT)
}