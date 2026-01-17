import router from '@ohos.router';

@Entry
@Component
struct ConsumerHome {
  build() {
    Column() {
      Text('消费者主页')
        .fontSize(20)
        .margin({ bottom: 20 })
      
      Text('(待实现)')
        .fontSize(14)
        .fontColor('#999')
        .margin({ bottom: 40 })
      
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
