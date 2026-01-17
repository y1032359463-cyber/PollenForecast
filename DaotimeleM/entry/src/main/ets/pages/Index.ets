import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State scaleValue1: number = 1;
  @State scaleValue2: number = 1;
  @State opacityValue1: number = 1;
  @State opacityValue2: number = 1;

  aboutToAppear() {
    // 启动呼吸动效
    this.startBreathingAnimation();
  }

  startBreathingAnimation() {
    // 为两个按钮添加不同步的呼吸效果
    setInterval(() => {
      animateTo({
        duration: 2000,
        curve: Curve.EaseInOut,
        iterations: 1,
        playMode: PlayMode.Alternate
      }, () => {
        this.scaleValue1 = this.scaleValue1 === 1 ? 1.05 : 1;
        this.opacityValue1 = this.opacityValue1 === 1 ? 0.85 : 1;
      });
    }, 2000);

    setInterval(() => {
      animateTo({
        duration: 2500,
        curve: Curve.EaseInOut,
        iterations: 1,
        playMode: PlayMode.Alternate
      }, () => {
        this.scaleValue2 = this.scaleValue2 === 1 ? 1.05 : 1;
        this.opacityValue2 = this.opacityValue2 === 1 ? 0.85 : 1;
      });
    }, 2500);
  }

  build() {
    Column() {
      // 标题
      Text('到时间了吗')
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 80, bottom: 120 })

      // 身份选择按钮区域
      Row() {
        // 老板按钮
        Column() {
          Text('🏪')
            .fontSize(60)
            .margin({ bottom: 16 })
          Text('老板')
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
        }
        .width(140)
        .height(140)
        .borderRadius(70)
        .backgroundColor('#FF6B9D')
        .justifyContent(FlexAlign.Center)
        .scale({ x: this.scaleValue1, y: this.scaleValue1 })
        .opacity(this.opacityValue1)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/merchant/MerchantHome'
          });
        })

        // 消费者按钮
        Column() {
          Text('👤')
            .fontSize(60)
            .margin({ bottom: 16 })
          Text('消费者')
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
        }
        .width(140)
        .height(140)
        .borderRadius(70)
        .backgroundColor('#4A90E2')
        .justifyContent(FlexAlign.Center)
        .scale({ x: this.scaleValue2, y: this.scaleValue2 })
        .opacity(this.opacityValue2)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/consumer/ConsumerHome'
          });
        })
        .margin({ left: 50 })
      }
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}