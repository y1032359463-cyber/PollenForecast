import router from '@ohos.router';

interface BusinessCard {
  id: string;
  type: string;
  icon: string;
  activeCount: number;
  countdown: string;
}

interface BusinessType {
  type: string;
  icon: string;
  name: string;
  checked: boolean;
}

@Entry
@Component
struct MerchantHome {
  @State businessList: BusinessCard[] = [];
  @State todayIncome: number = 0;
  
  // 业务类型配置
  private businessTypes: BusinessType[] = [
    { type: 'pool', icon: '🎱', name: '桌球', checked: false },
    { type: 'stall', icon: '🏪', name: '地摊', checked: false },
    { type: 'chess', icon: '🎴', name: '棋牌', checked: false },
    { type: 'general', icon: '📦', name: '通用', checked: false }
  ];

  aboutToAppear() {
    // TODO: 从本地存储加载已添加的业务
    this.loadBusinessData();
  }

  loadBusinessData() {
    // 模拟数据
    this.businessList = [
      { id: '1', type: 'pool', icon: '🎱', activeCount: 2, countdown: '58:35' },
      { id: '2', type: 'chess', icon: '🎴', activeCount: 0, countdown: '' }
    ];
    this.todayIncome = 358;
  }

  onBusinessTypeClick(type: string, icon: string, name: string) {
    // 检查是否已添加
    const exists = this.businessList.find(b => b.type === type);
    if (exists) {
      // 已存在，跳转到业务管理页
      router.pushUrl({
        url: 'pages/merchant/BusinessManage',
        params: { businessType: type, businessName: name }
      });
    } else {
      // 添加新业务
      if (this.businessList.length < 4) {
        this.businessList.push({
          id: Date.now().toString(),
          type: type,
          icon: icon,
          activeCount: 0,
          countdown: ''
        });
      }
    }
  }

  build() {
    Row() {
      // 左侧固定业务类型栏
      Column() {
        ForEach(this.businessTypes, (item: BusinessType) => {
          Column() {
            Text(item.icon)
              .fontSize(32)
              .margin({ bottom: 4 })
            Text(item.name)
              .fontSize(12)
              .fontColor('#666')
            
            // 已添加标记
            if (this.businessList.some(b => b.type === item.type)) {
              Text('✓')
                .fontSize(16)
                .fontColor('#4CAF50')
                .margin({ top: 2 })
            }
          }
          .width('100%')
          .height(80)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.businessList.some(b => b.type === item.type) ? '#E8F5E9' : '#FFF')
          .border({ width: { bottom: 1 }, color: '#E0E0E0' })
          .onClick(() => {
            this.onBusinessTypeClick(item.type, item.icon, item.name);
          })
        })
      }
      .width(80)
      .height('100%')
      .backgroundColor('#FAFAFA')

      // 右侧主内容区
      Column() {
        // 顶部导航栏
        Row() {
          Text('我的业务')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          
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
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .backgroundColor('#FFF')
        .border({ width: { bottom: 1 }, color: '#E0E0E0' })

        // 今日收入
        Row() {
          Text(`今日收入: ¥${this.todayIncome}`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#4CAF50')
        }
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#F9FFF9')
        .border({ width: { bottom: 1 }, color: '#E0E0E0' })

        // 业务卡片区域
        if (this.businessList.length === 0) {
          Column() {
            Text('还没有业务')
              .fontSize(18)
              .fontColor('#999')
              .margin({ bottom: 8 })
            Text('点击或拖拽左侧图标')
              .fontSize(14)
              .fontColor('#BBB')
            Text('添加业务（最多4个）')
              .fontSize(14)
              .fontColor('#BBB')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Grid() {
            ForEach(this.businessList, (item: BusinessCard) => {
              GridItem() {
                Column() {
                  Text(item.icon)
                    .fontSize(48)
                    .margin({ bottom: 8 })
                  
                  if (item.activeCount > 0) {
                    Text(`⏱ ${item.countdown}`)
                      .fontSize(18)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#FF6B9D')
                      .margin({ top: 8 })
                    Text(`使用中: ${item.activeCount}`)
                      .fontSize(12)
                      .fontColor('#666')
                      .margin({ top: 4 })
                  } else {
                    Text('无使用中')
                      .fontSize(14)
                      .fontColor('#999')
                      .margin({ top: 8 })
                  }
                }
                .width('100%')
                .height(160)
                .backgroundColor('#FFF')
                .borderRadius(12)
                .justifyContent(FlexAlign.Center)
                .shadow({ radius: 4, color: '#1000', offsetY: 2 })
                .onClick(() => {
                  const typeName = this.businessTypes.find(t => t.type === item.type)?.name || '';
                  router.pushUrl({
                    url: 'pages/merchant/BusinessManage',
                    params: { businessType: item.type, businessName: typeName }
                  });
                })
              }
            })
          }
          .columnsTemplate('1fr 1fr')
          .rowsGap(16)
          .columnsGap(16)
          .padding(16)
          .layoutWeight(1)
        }
      }
      .layoutWeight(1)
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}
