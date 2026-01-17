import router from '@ohos.router';
import preferences from '@ohos.data.preferences';

@Entry
@Component
struct QRCodePage {
  @State wechatQRCode: string = '';
  @State alipayQRCode: string = '';
  @State resourceName: string = '';
  @State hasQRCodes: boolean = false;

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    this.resourceName = params.resourceName || '';
    
    // 加载收款码
    this.loadQRCodes();
  }

  async loadQRCodes() {
    // TODO: 从沙箱目录加载收款码图片
    // const context = getContext(this);
    // const wechatPath = context.filesDir + '/qrcode/wechat.png';
    // const alipayPath = context.filesDir + '/qrcode/alipay.png';
    
    // 模拟检查是否已设置
    this.hasQRCodes = false; // 首次使用设为false
  }

  onUploadWechat() {
    // TODO: 打开相册选择微信收款码
    router.pushUrl({
      url: 'pages/merchant/QRCodeSettings',
      params: { type: 'wechat' }
    });
  }

  onUploadAlipay() {
    // TODO: 打开相册选择支付宝收款码
    router.pushUrl({
      url: 'pages/merchant/QRCodeSettings',
      params: { type: 'alipay' }
    });
  }

  onSettingsClick() {
    router.pushUrl({
      url: 'pages/merchant/QRCodeSettings'
    });
  }

  build() {
    Column() {
      if (this.hasQRCodes) {
        // 已设置收款码 - 正常展示
        Column() {
          // 微信收款码区域
          Stack() {
            // 绿色背景
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('#09BB07')

            // 收款码
            Column() {
              Text('微信支付')
                .fontSize(18)
                .fontColor('#FFF')
                .margin({ bottom: 12 })
              
              // TODO: 显示实际收款码图片
              Image($rawfile('qrcode/wechat.png'))
                .width('80%')
                .aspectRatio(1)
                .backgroundColor('#FFF')
                .borderRadius(8)
                .objectFit(ImageFit.Contain)
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)

            // 设置按钮
            Button({ type: ButtonType.Circle }) {
              Text('⚙️')
                .fontSize(20)
            }
            .width(40)
            .height(40)
            .backgroundColor('rgba(255,255,255,0.9)')
            .position({ x: '90%', y: 16 })
            .onClick(() => {
              this.onSettingsClick();
            })
          }
          .width('100%')
          .layoutWeight(1)

          // 支付宝收款码区域
          Stack() {
            // 蓝色背景
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('#1677FF')

            // 收款码
            Column() {
              Text('支付宝')
                .fontSize(18)
                .fontColor('#FFF')
                .margin({ bottom: 12 })
              
              // TODO: 显示实际收款码图片
              Image($rawfile('qrcode/alipay.png'))
                .width('80%')
                .aspectRatio(1)
                .backgroundColor('#FFF')
                .borderRadius(8)
                .objectFit(ImageFit.Contain)
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
      } else {
        // 未设置收款码 - 引导上传
        Column() {
          // 微信收款码上传区域
          Stack() {
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('#E7F7E6')

            Column() {
              Text('微信支付')
                .fontSize(18)
                .fontColor('#09BB07')
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 12 })

              Column() {
                Text('[+]')
                  .fontSize(48)
                  .fontColor('#09BB07')
                  .margin({ bottom: 12 })
                
                Text('点击上传微信')
                  .fontSize(16)
                  .fontColor('#666')
                Text('收款码图片')
                  .fontSize(16)
                  .fontColor('#666')
                  .margin({ bottom: 12 })
                
                Text('(1024x1024推荐)')
                  .fontSize(12)
                  .fontColor('#999')
              }
              .width('75%')
              .aspectRatio(1)
              .backgroundColor('#FFF')
              .borderRadius(12)
              .border({ width: 2, color: '#09BB07', style: BorderStyle.Dashed })
              .justifyContent(FlexAlign.Center)
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.onUploadWechat();
            })

            // 设置按钮
            Button({ type: ButtonType.Circle }) {
              Text('⚙️')
                .fontSize(20)
            }
            .width(40)
            .height(40)
            .backgroundColor('rgba(255,255,255,0.9)')
            .position({ x: '90%', y: 16 })
            .onClick(() => {
              this.onSettingsClick();
            })
          }
          .width('100%')
          .layoutWeight(1)

          // 支付宝收款码上传区域
          Stack() {
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('#E6F4FF')

            Column() {
              Text('支付宝')
                .fontSize(18)
                .fontColor('#1677FF')
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 12 })

              Column() {
                Text('[+]')
                  .fontSize(48)
                  .fontColor('#1677FF')
                  .margin({ bottom: 12 })
                
                Text('点击上传支付宝')
                  .fontSize(16)
                  .fontColor('#666')
                Text('收款码图片')
                  .fontSize(16)
                  .fontColor('#666')
                  .margin({ bottom: 12 })
                
                Text('(1024x1024推荐)')
                  .fontSize(12)
                  .fontColor('#999')
              }
              .width('75%')
              .aspectRatio(1)
              .backgroundColor('#FFF')
              .borderRadius(12)
              .border({ width: 2, color: '#1677FF', style: BorderStyle.Dashed })
              .justifyContent(FlexAlign.Center)
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.onUploadAlipay();
            })
          }
          .width('100%')
          .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}
