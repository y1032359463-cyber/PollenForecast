import router from '@ohos.router';

@Entry
@Component
struct RentalDetail {
  build() {
    Column() {
      Text('租赁详情页')
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
