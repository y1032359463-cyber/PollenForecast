import router from '@ohos.router';

@Entry
@Component
struct ResourceList {
  build() {
    Column() {
      Text('资源列表页')
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
