import router from '@ohos.router';

@Entry
@Component
struct BusinessTypeSelect {
  build() {
    Column() {
      Text('业务类型选择页')
        .fontSize(20)
      
      Button('返回')
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
