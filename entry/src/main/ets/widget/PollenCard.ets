let storage = new LocalStorage();

@Entry(storage)
@Component
export struct PollenCard {
  // 使用 LocalStorage 获取数据
  @LocalStorageProp('pollenValue') pollenValue: string = '45'
  @LocalStorageProp('pollenLevel') pollenLevel: string = '中等'
  @LocalStorageProp('cityName') cityName: string = '广州'

  build() {
    Stack() {
      // 背景色 - 适配浅色/深色模式
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.card_background'))

      // 左上角：位置图标 + 城市名
      Row() {
        Text('📍')
          .fontSize(14)
          .fontColor('#666666')
        Text(this.cityName)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ left: 4 })
      }
      .position({ x: 12, y: 12 })

      // 中心：花粉浓度数值
      Column({
        space: 2
      }) {
        Text(this.pollenValue)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4CAF50')
          .lineHeight(56)

        // 数值下方：单位
        Text('粒/km³')
          .fontSize(12)
          .fontColor('#757575')
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .position({ x: '50%', y: '45%' })
      .translate({ x: '-50%', y: '-50%' })

      // 底部：风险等级胶囊
      Text(this.pollenLevel)
        .fontSize(14)
        .fontColor('#1A1A1A') // 使用深色文字确保对比度
        .backgroundColor(this.pollenLevel === '极高' ? '#F44336' : (this.pollenLevel === '中等' ? '#FFC107' : '#CDDC39'))
        .padding({ left: 16, right: 16, top: 6, bottom: 6 })
        .borderRadius(50)
        .position({ x: '50%', y: '85%' })
        .translate({ x: '-50%' })
    }
    .width('100%')
    .height('100%')
    .borderRadius(12)
    .clip(true)
    .onClick(() => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
        params: {
          targetPage: 'index'
        }
      });
    })
  }
}
