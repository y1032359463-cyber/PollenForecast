import router from '@ohos.router';

interface Resource {
  id: string;
  name: string;
  status: 'idle' | 'active';
  startTime?: number;
  countdown?: string;
  estimatedFee?: number;
}

@Entry
@Component
struct BusinessManage {
  @State businessType: string = '';
  @State businessName: string = '';
  @State resources: Resource[] = [];
  @State showTimePicker: boolean = false;
  @State selectedResourceId: string = '';

  aboutToAppear() {
    // 获取传递的参数
    const params = router.getParams() as Record<string, string>;
    this.businessType = params.businessType || '';
    this.businessName = params.businessName || '';
    
    // TODO: 从本地加载资源列表
    this.loadResources();
  }

  loadResources() {
    // 模拟数据
    this.resources = [
      { id: '1', name: '1号台', status: 'active', startTime: Date.now() - 3515000, countdown: '00:58:35', estimatedFee: 35.50 },
      { id: '2', name: '2号台', status: 'idle' },
      { id: '3', name: '3号台', status: 'active', startTime: Date.now() - 4520000, countdown: '01:15:20', estimatedFee: 45.00 },
      { id: '4', name: '4号台', status: 'idle' },
      { id: '5', name: '5号台', status: 'idle' }
    ];
  }

  onResourceClick(resource: Resource) {
    if (resource.status === 'idle') {
      // 空闲资源，弹出时间选择
      this.selectedResourceId = resource.id;
      this.showTimePicker = true;
    } else {
      // 使用中的资源，跳转到收款码页面
      router.pushUrl({
        url: 'pages/merchant/QRCodePage',
        params: { 
          resourceId: resource.id,
          resourceName: resource.name,
          businessType: this.businessType
        }
      });
    }
  }

  startCountdown(hours: number) {
    // TODO: 启动倒计时逻辑
    const resource = this.resources.find(r => r.id === this.selectedResourceId);
    if (resource) {
      resource.status = 'active';
      resource.startTime = Date.now();
      resource.countdown = `${hours.toString().padStart(2, '0')}:00:00`;
    }
    this.showTimePicker = false;
  }

  @Builder
  TimePickerDialog() {
    Column() {
      Text('选择时长')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 24 })

      // 快捷时间按钮
      Row() {
        Button('1小时')
          .width(80)
          .onClick(() => this.startCountdown(1))
        
        Button('2小时')
          .width(80)
          .margin({ left: 12, right: 12 })
          .onClick(() => this.startCountdown(2))
        
        Button('3小时')
          .width(80)
          .onClick(() => this.startCountdown(3))
      }
      .margin({ bottom: 16 })

      Button('自定义')
        .width(260)
        .backgroundColor('#E0E0E0')
        .fontColor('#333')
        .onClick(() => {
          // TODO: 打开自定义时间输入
        })

      Button('取消')
        .width(260)
        .backgroundColor('#FFF')
        .fontColor('#666')
        .margin({ top: 16 })
        .onClick(() => {
          this.showTimePicker = false;
        })
    }
    .width(300)
    .padding(24)
    .backgroundColor('#FFF')
    .borderRadius(12)
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

        Text(`${this.businessName}管理`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 12 })

        Blank()

        Button('[+新增]')
          .fontSize(14)
          .backgroundColor('#4CAF50')
          .onClick(() => {
            // TODO: 添加新资源
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFF')
      .border({ width: { bottom: 1 }, color: '#E0E0E0' })

      Scroll() {
        Column() {
          // 使用中的资源
          if (this.resources.filter(r => r.status === 'active').length > 0) {
            Column() {
              Text(`使用中 (${this.resources.filter(r => r.status === 'active').length})`)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 12 })

              ForEach(this.resources.filter(r => r.status === 'active'), (resource: Resource) => {
                Column() {
                  Row() {
                    Text(`🎱 ${resource.name}`)
                      .fontSize(18)
                      .fontWeight(FontWeight.Medium)
                    
                    Blank()
                    
                    Text(`⏱ ${resource.countdown}`)
                      .fontSize(16)
                      .fontColor('#FF6B9D')
                      .fontWeight(FontWeight.Bold)
                  }
                  .width('100%')
                  .margin({ bottom: 8 })

                  Row() {
                    Text(`参考: ¥${resource.estimatedFee?.toFixed(2)}`)
                      .fontSize(14)
                      .fontColor('#4CAF50')
                    
                    Blank()
                    
                    Button('查看收款码')
                      .fontSize(14)
                      .height(32)
                      .backgroundColor('#FF6B9D')
                  }
                  .width('100%')
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFF')
                .borderRadius(8)
                .margin({ bottom: 12 })
                .shadow({ radius: 2, color: '#1000', offsetY: 1 })
                .onClick(() => {
                  this.onResourceClick(resource);
                })
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16 })
          }

          // 空闲资源
          if (this.resources.filter(r => r.status === 'idle').length > 0) {
            Column() {
              Text(`空闲 (${this.resources.filter(r => r.status === 'idle').length})`)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 12 })

              Grid() {
                ForEach(this.resources.filter(r => r.status === 'idle'), (resource: Resource) => {
                  GridItem() {
                    Column() {
                      Text(resource.name)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                    }
                    .width('100%')
                    .height(80)
                    .backgroundColor('#E8F5E9')
                    .borderRadius(8)
                    .justifyContent(FlexAlign.Center)
                    .onClick(() => {
                      this.onResourceClick(resource);
                    })
                  }
                })
              }
              .columnsTemplate('1fr 1fr 1fr')
              .rowsGap(12)
              .columnsGap(12)
              .width('100%')

              Text('(点击空闲台开始计时)')
                .fontSize(12)
                .fontColor('#999')
                .margin({ top: 12 })
            }
            .width('100%')
            .padding(16)
          }
        }
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')

      // 时间选择弹窗
      if (this.showTimePicker) {
        Column() {
          this.TimePickerDialog()
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.showTimePicker = false;
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
