import router from '@ohos.router';
import picker from '@ohos.file.picker';

@Entry
@Component
struct QRCodeSettings {
  @State wechatQRCode: string = '';
  @State alipayQRCode: string = '';
  @State hasWechat: boolean = false;
  @State hasAlipay: boolean = false;

  aboutToAppear() {
    // 加载已有的收款码
    this.loadExistingQRCodes();
  }

  async loadExistingQRCodes() {
    // TODO: 从沙箱目录加载已保存的收款码
    // const context = getContext(this);
    // const wechatPath = context.filesDir + '/qrcode/wechat.png';
    // const alipayPath = context.filesDir + '/qrcode/alipay.png';
  }

  async onSelectWechatImage() {
    try {
      // TODO: 打开相册选择器
      // const photoSelectOptions = new picker.PhotoSelectOptions();
      // photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      // photoSelectOptions.maxSelectNumber = 1;
      // const photoPicker = new picker.PhotoViewPicker();
      // const result = await photoPicker.select(photoSelectOptions);
      
      // 模拟选择成功
      this.hasWechat = true;
      
      // TODO: 保存图片到沙箱
      // const context = getContext(this);
      // const destPath = context.filesDir + '/qrcode/wechat.png';
    } catch (err) {
      console.error('选择图片失败:', err);
    }
  }

  async onSelectAlipayImage() {
    try {
      // TODO: 打开相册选择器
      this.hasAlipay = true;
      
      // TODO: 保存图片到沙箱
      // const context = getContext(this);
      // const destPath = context.filesDir + '/qrcode/alipay.png';
    } catch (err) {
      console.error('选择图片失败:', err);
    }
  }

  onDeleteWechat() {
    // TODO: 删除微信收款码
    this.hasWechat = false;
  }

  onDeleteAlipay() {
    // TODO: 删除支付宝收款码
    this.hasAlipay = false;
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button({ type: ButtonType.Circle }) {
          Text('←')
            .fontSize(20)
        }
        .width(40)
        .height(40)
        .backgroundColor('#E0E0E0')
        .onClick(() => {
          router.back();
        })

        Text('收款码设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 12 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFF')
      .border({ width: { bottom: 1 }, color: '#E0E0E0' })

      Scroll() {
        Column() {
          // 微信收款码设置
          Column() {
            Text('微信收款码')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 12 })

            if (this.hasWechat) {
              // 显示已上传的收款码
              Column() {
                Image($rawfile('qrcode/wechat.png'))
                  .width(200)
                  .height(200)
                  .backgroundColor('#FFF')
                  .borderRadius(8)
                  .objectFit(ImageFit.Contain)
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#E7F7E6')
              .borderRadius(8)
              .margin({ bottom: 12 })

              Row() {
                Button('更换图片')
                  .fontSize(14)
                  .backgroundColor('#09BB07')
                  .onClick(() => {
                    this.onSelectWechatImage();
                  })

                Button('删除')
                  .fontSize(14)
                  .backgroundColor('#FF5252')
                  .margin({ left: 12 })
                  .onClick(() => {
                    this.onDeleteWechat();
                  })
              }
            } else {
              // 未上传状态
              Column() {
                Text('[+]')
                  .fontSize(48)
                  .fontColor('#09BB07')
                  .margin({ bottom: 12 })
                Text('点击上传微信收款码')
                  .fontSize(14)
                  .fontColor('#666')
              }
              .width('100%')
              .height(200)
              .backgroundColor('#E7F7E6')
              .borderRadius(8)
              .border({ width: 2, color: '#09BB07', style: BorderStyle.Dashed })
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.onSelectWechatImage();
              })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFF')
          .borderRadius(8)
          .margin({ bottom: 16 })

          // 支付宝收款码设置
          Column() {
            Text('支付宝收款码')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 12 })

            if (this.hasAlipay) {
              // 显示已上传的收款码
              Column() {
                Image($rawfile('qrcode/alipay.png'))
                  .width(200)
                  .height(200)
                  .backgroundColor('#FFF')
                  .borderRadius(8)
                  .objectFit(ImageFit.Contain)
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#E6F4FF')
              .borderRadius(8)
              .margin({ bottom: 12 })

              Row() {
                Button('更换图片')
                  .fontSize(14)
                  .backgroundColor('#1677FF')
                  .onClick(() => {
                    this.onSelectAlipayImage();
                  })

                Button('删除')
                  .fontSize(14)
                  .backgroundColor('#FF5252')
                  .margin({ left: 12 })
                  .onClick(() => {
                    this.onDeleteAlipay();
                  })
              }
            } else {
              // 未上传状态
              Column() {
                Text('[+]')
                  .fontSize(48)
                  .fontColor('#1677FF')
                  .margin({ bottom: 12 })
                Text('点击上传支付宝收款码')
                  .fontSize(14)
                  .fontColor('#666')
              }
              .width('100%')
              .height(200)
              .backgroundColor('#E6F4FF')
              .borderRadius(8)
              .border({ width: 2, color: '#1677FF', style: BorderStyle.Dashed })
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.onSelectAlipayImage();
              })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFF')
          .borderRadius(8)
          .margin({ bottom: 16 })

          // 使用提示
          Column() {
            Row() {
              Text('⚠️ ')
                .fontSize(16)
              Text('使用提示:')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
            }
            .margin({ bottom: 8 })

            Text('• 请使用原始收款码截图')
              .fontSize(12)
              .fontColor('#666')
              .margin({ left: 20, bottom: 4 })
            Text('• 推荐1024x1024分辨率')
              .fontSize(12)
              .fontColor('#666')
              .margin({ left: 20, bottom: 4 })
            Text('• 确保二维码完整清晰')
              .fontSize(12)
              .fontColor('#666')
              .margin({ left: 20, bottom: 4 })
            Text('• 避免边缘被裁切')
              .fontSize(12)
              .fontColor('#666')
              .margin({ left: 20, bottom: 4 })
            Text('• 不要添加文字水印')
              .fontSize(12)
              .fontColor('#666')
              .margin({ left: 20 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFF8E1')
          .borderRadius(8)
          .alignItems(HorizontalAlign.Start)
        }
        .padding(16)
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}
