import router from '@ohos.router';

@Entry
@Component
struct HistoryPage {
  build() {
    Column() {
      Text('历史记录页')
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
