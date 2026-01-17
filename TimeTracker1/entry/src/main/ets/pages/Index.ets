import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  aboutToAppear(): void {
    // 启动后立即跳转到 HomePage（Tab容器页面）
    // 使用 pushDestination 或保持 replaceUrl（HarmonyOS NEXT 仍支持）
    router.replaceUrl({
      url: 'pages/HomePage'
    }).then(() => {
      console.info('Successfully navigated to HomePage');
    }).catch((err: BusinessError) => {
      console.error(`Failed to navigate to HomePage: ${err.code}, ${err.message}`);
    });
  }

  build() {
    Column() {
      Text('Loading...')
        .fontSize(16)
        .fontColor('#999999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}