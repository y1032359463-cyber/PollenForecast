/**
 * 设置页面 - Tab4
 * 应用设置、关于、反馈等
 * 注：会员功能UI已隐藏，代码预留接口
 */

import { promptAction, router } from '@kit.ArkUI'
import { pasteboard } from '@kit.BasicServicesKit'
import { VibrationUtils } from '../utils/VibrationUtils'

@Component
export struct SettingsView {
  @State appVersion: string = '1.0.1'
  @State buildNumber: string = '2'
  @State isAnimating: boolean = false
  @State showFeedbackSheet: boolean = false  // 反馈弹窗状态
  @StorageLink('safeTop') safeTop: number = 44
  @StorageLink('safeBottom') safeBottom: number = 28
  private groupIndex: number = 0

  build() {
    Column() {
      // 顶部安全距离
      Blank().height(this.safeTop)

      // 标题
      Text('设置')
        .fontSize(28)
        .fontColor($r('app.color.text_primary'))
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: 16, top: 8, bottom: 24 })

      // 设置列表
      Scroll() {
        Column() {
          // ===== 会员区域（已隐藏，代码预留）=====
          // this.PremiumSection()

          // ===== 通知设置组 =====
          this.SettingGroup([
            { icon: $r('app.media.icon_notifications'), iconBg: '#FF6B35', title: '通知设置', showArrow: true },
          ])

          // ===== 通用设置组 =====
          this.SettingGroup([
            { icon: $r('app.media.icon_settings'), iconBg: '#666666', title: '通用', showArrow: true },
          ])

          // ===== 关于组 =====
          this.SettingGroup([
            { icon: $r('app.media.icon_info'), iconBg: '#9C27B0', title: '关于', showArrow: true },
            { icon: $r('app.media.icon_document'), iconBg: '#00BCD4', title: '隐私政策', showArrow: true },
            { icon: $r('app.media.icon_document'), iconBg: '#607D8B', title: 'ICP备案', subtitle: '粤ICP备2025510506号-1A', showArrow: false },
            // { icon: $r('app.media.icon_star'), iconBg: '#2196F3', title: '给我们评分', showArrow: true },  // 暂时隐藏
            { icon: $r('app.media.icon_edit'), iconBg: '#4CAF50', title: '反馈建议', showArrow: true },
          ])

          // 版本信息
          Column() {
            Text(`Version: ${this.appVersion} build: ${this.buildNumber}`)
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
            Text('数据来源: Google Pollen API / 和风天气')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
          }
          .margin({ top: 32 })

          // 底部间距（TabBar高度 + 安全距离 + 额外间距）
          Blank().height(56 + this.safeBottom + 16)
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.KEYBOARD], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .bindSheet($$this.showFeedbackSheet, this.FeedbackSheetBuilder(), {
      height: SheetSize.FIT_CONTENT,
      showClose: true,
      dragBar: true,
      backgroundColor: $r('app.color.card_background'),
      onDisappear: () => {
        this.showFeedbackSheet = false
      }
    })
    .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
      if (isVisible && currentRatio >= 1.0) {
        // 页面完全可见时触发动画
        this.groupIndex = 0
        setTimeout(() => {
          this.getUIContext().animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
            this.isAnimating = true
          })
        }, 50)
      } else if (!isVisible || currentRatio < 0.5) {
        // 页面不可见或可见比侎于50%时重置
        this.isAnimating = false
        this.groupIndex = 0
      }
    })
  }

  // ========== 设置分组 ==========

  // 反馈建议底部弹窗
  @Builder
  FeedbackSheetBuilder() {
    Column() {
      // 标题
      Text('反馈/建议')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 12 })
      
      // 副标题
      Text('您的反馈非常重要')
        .fontSize(15)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 8 })

      // 分隔线
      Divider()
        .color($r('app.color.divider_color'))
        .margin({ top: 28, bottom: 28 })

      // 邮箱提示
      Text('您可将反馈/建议发送至邮箱：')
        .fontSize(16)
        .fontColor($r('app.color.text_secondary'))

      // 邮箱地址
      Text('blueskysbx@qq.com')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 12 })

      // 复制按钮
      Text('复制邮箱')
        .fontSize(17)
        .fontColor('#4CAF50')
        .fontWeight(FontWeight.Medium)
        .margin({ top: 24 })
        .padding({ top: 12, bottom: 12, left: 32, right: 32 })
        .borderRadius(8)
        .backgroundColor('rgba(76, 175, 80, 0.1)')
        .onClick(() => {
          this.copyEmail()
        })

      // 底部间距
      Blank().height(this.safeBottom + 20)
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 16, bottom: 16 })
  }

  // 复制邮箱地址
  private copyEmail(): void {
    const email = 'blueskysbx@qq.com'
    const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, email)
    const systemPasteboard = pasteboard.getSystemPasteboard()
    systemPasteboard.setData(pasteboardData).then(() => {
      VibrationUtils.triggerLight()
      this.getUIContext().getPromptAction().showToast({
        message: '邮箱已复制',
        duration: 2000
      })
    }).catch((err: Error) => {
      console.error('复制失败:', JSON.stringify(err))
    })
  }

  @Builder
  SettingGroup(items: SettingItemData[]) {
    Column() {
      ForEach(items, (item: SettingItemData, index: number) => {
        // 设置项
        Row() {
          // 左侧彩色图标
          Row() {
            Image(item.icon)
              .width(18)
              .height(18)
              .fillColor(Color.White)
          }
          .width(32)
          .height(32)
          .borderRadius(8)
          .backgroundColor(item.iconBg)
          .justifyContent(FlexAlign.Center)

          // 标题和副标题
          Column() {
            Text(item.title)
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
            
            if (item.subtitle) {
              Text(item.subtitle)
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 2 })
            }
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 12 })

          Blank()

          // 右侧内容或箭头
          if (item.rightText) {
            Text(item.rightText)
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ right: 8 })
          }

          if (item.showArrow) {
            Text('›')
              .fontSize(20)
              .fontColor($r('app.color.text_secondary'))
          }
        }
        .width('100%')
        .height(52)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          VibrationUtils.triggerLight()
          this.handleSettingClick(item.title)
        })

        // 分隔线（非最后一项）
        if (index < items.length - 1) {
          Divider()
            .color($r('app.color.divider_color'))
            .margin({ left: 56 })
        }
      })
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .margin({ bottom: 16 })
    // 分组入场动画（从右侧滑入，与区域页一致）
    .opacity(this.isAnimating ? 1 : 0)
    .translate({ x: this.isAnimating ? 0 : 60 })
    .animation({
      duration: 350,
      delay: this.groupIndex++ * 60,
      curve: Curve.FastOutSlowIn
    })
  }

  // ========== 会员区域（预留，当前隐藏）==========
  @Builder
  PremiumSection() {
    Column() {
      // 会员标题
      Text('高级会员')
        .fontSize(18)
        .fontColor('#FFD700')
        .fontWeight(FontWeight.Medium)

      // 会员权益列表
      Column() {
        this.PremiumFeatureItem('花粉指数 AI 报告')
        this.PremiumFeatureItem('40 多个国内城市和地区')
        this.PremiumFeatureItem('全国花粉地图')
        this.PremiumFeatureItem('消息提醒')
        this.PremiumFeatureItem('没有广告')
      }
      .margin({ top: 16 })
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .padding(20)
    .margin({ bottom: 16 })
  }

  @Builder
  PremiumFeatureItem(text: string) {
    Row() {
      Text('✓')
        .fontSize(14)
        .fontColor('#4CAF50')
      Text(text)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .margin({ left: 8 })
    }
    .width('100%')
    .margin({ top: 8 })
  }

  // ========== 点击处理 ==========
  handleSettingClick(title: string) {
    console.info(`点击设置: ${title}`)
    
    switch (title) {
      case '通用':
        this.getUIContext().getRouter().pushUrl({ url: 'pages/GeneralSettingsPage' })
          .catch((err: Error) => {
            console.error('跳转失败:', JSON.stringify(err));
          });
        break
      case '通知设置':
        this.getUIContext().getRouter().pushUrl({ url: 'pages/NotificationSettingsPage' })
          .catch((err: Error) => {
            console.error('跳转失败:', JSON.stringify(err));
          });
        break
      case '关于':
        this.showAboutDialog()
        break
      case '隐私政策':
        this.showPrivacyPolicy()
        break
      case '给我们评分':
        this.rateApp()
        break
      case '反馈建议':
        this.feedback()
        break
      default:
        console.info(`未处理的设置项: ${title}`)
    }
  }
  
  // 显示关于应用对话框
  showAboutDialog() {
    console.info('显示关于应用')
    
    // API 20 使用 promptAction.showDialog()
    this.getUIContext().getPromptAction().showDialog({
      title: '关于花粉浓度预报',
      message: `花粉浓度预报
一款为过敏人群提供实时花粉浓度和天气信息的应用

版本: ${this.appVersion} (Build ${this.buildNumber})
开发者: 郑志雄

数据来源:
· Google Pollen API - 花粉数据
· 和风天气API - 天气数据

特色功能:
· 智感握姿自适应
· 多地区花粉监测
· 天气预报集成
· 花粉播报提醒

Eric © 2025`,
      buttons: [{ text: '确定', color: '#4CAF50' }]
    }).catch((err: Error) => {
      console.error('显示对话框失败:', JSON.stringify(err));
    })
  }
  
  
  // 显示隐私政策
  showPrivacyPolicy() {
    console.info('显示隐私政策')
    
    this.getUIContext().getPromptAction().showDialog({
      title: '隐私政策',
      message: `花粉浓度预报 - 隐私政策\n\n生效日期：2025年1月1日\n\n1. 信息收集\n· 位置信息：用于提供当前位置的花粉浓度数据\n· 设备信息：用于优化应用性能\n\n2. 信息使用\n· 位置信息仅用于查询花粉数据API\n· 不会上传或存储您的个人信息\n· 所有数据仅在本地处理\n\n3. 第三方服务\n· Google Pollen API：提供花粉数据\n· 和风天气API：提供天气数据\n\n4. 权限说明\n· 定位权限：获取当前位置花粉信息\n· 通知权限：发送花粉播报提醒\n\n5. 数据安全\n· 采用HTTPS加密传输\n· 不与任何第三方共享个人数据\n\nEric © 2025`,
      buttons: [{ text: '我知道了', color: '#4CAF50' }]
    }).catch((err: Error) => {
      console.error('显示对话框失败:', JSON.stringify(err));
    })
  }
  
  // 给应用评分
  rateApp() {
    console.info('给应用评分')
    // TODO: 实现应用评分
  }
  
  // 反馈建议
  feedback() {
    console.info('反馈建议')
    this.showFeedbackSheet = true
  }
}

// 设置项数据接口
interface SettingItemData {
  icon: Resource
  iconBg: string
  title: string
  subtitle?: string     // 副标题(如备案号)
  rightText?: string
  showArrow?: boolean
}
