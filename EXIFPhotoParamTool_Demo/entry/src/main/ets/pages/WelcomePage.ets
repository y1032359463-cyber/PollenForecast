/**
 * 欢迎页面 - 首次启动时选择UI风格
 */
import { common } from '@kit.AbilityKit'
import { UIStyle } from '../models/PhotoRecord'
import { PreferenceService } from '../services/PreferenceService'
import { hilog } from '@kit.PerformanceAnalysisKit'

@Entry
@Component
struct WelcomePage {
  @State selectedStyle: UIStyle = UIStyle.CARD
  private preferenceService: PreferenceService | null = null

  aboutToAppear(): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    this.preferenceService = new PreferenceService(context)
  }

  // 确认选择并进入主页
  async confirmSelection(): Promise<void> {
    try {
      if (this.preferenceService) {
        await this.preferenceService.setUIStyle(this.selectedStyle)
        await this.preferenceService.markFirstLaunchDone()
      }
      this.getUIContext().getRouter().replaceUrl({ url: 'pages/Index' })
    } catch (error) {
      hilog.error(0x0021, 'UI', '保存设置失败:' + error)
    }
  }

  build() {
    Column() {
      // 标题区域
      Column() {
        Text('📷')
          .fontSize(60)
          .margin({ bottom: 16 })
        
        Text('EXIF光影备忘录')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Text('选择你喜欢的界面风格')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ top: 8 })
      }
      .margin({ top: 80, bottom: 40 })

      // 风格选择区域
      Row() {
        // 风格A: 卡片列表式
        Column() {
          this.StylePreview(UIStyle.CARD)
        }
        .width('45%')
        .onClick(() => {
          this.selectedStyle = UIStyle.CARD
        })

        Blank().width(16)

        // 风格B: 参数突出式
        Column() {
          this.StylePreview(UIStyle.PARAM)
        }
        .width('45%')
        .onClick(() => {
          this.selectedStyle = UIStyle.PARAM
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ left: 20, right: 20 })

      Blank()

      // 开始使用按钮
      Button('开始使用')
        .width('80%')
        .height(50)
        .fontSize(18)
        .fontColor(Color.White)
        .backgroundColor('#007AFF')
        .borderRadius(25)
        .margin({ bottom: 60 })
        .onClick(() => {
          this.confirmSelection()
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  StylePreview(style: UIStyle) {
    Column() {
      // 预览卡片
      Column() {
        if (style === UIStyle.CARD) {
          // 卡片式预览
          Row() {
            Column()
              .width(50)
              .height(50)
              .backgroundColor('#E0E0E0')
              .borderRadius(8)
            
            Column() {
              Text('2024/12/14')
                .fontSize(12)
                .fontColor('#999999')
              Text('f/2.8 · 1/125s · ISO400')
                .fontSize(11)
                .fontColor('#333333')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 10 })
          }
          .width('100%')
          .padding(10)
          
          Text('📝 夕阳人像...')
            .fontSize(11)
            .fontColor('#666666')
            .width('100%')
            .padding({ left: 10, bottom: 10 })
        } else {
          // 参数式预览
          Text('f/2.8')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ top: 15 })
          
          Divider()
            .width('80%')
            .margin({ top: 8, bottom: 8 })
          
          Row() {
            Text('1/125s')
              .fontSize(11)
            Text('ISO400')
              .fontSize(11)
              .margin({ left: 12 })
            Text('50mm')
              .fontSize(11)
              .margin({ left: 12 })
          }
          .margin({ bottom: 15 })
        }
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })

      // 风格名称
      Text(style === UIStyle.CARD ? '卡片列表式' : '参数突出式')
        .fontSize(14)
        .fontColor('#333333')
        .margin({ top: 12 })
      
      Text(style === UIStyle.CARD ? '适合浏览为主' : '适合学习参数')
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 4 })

      // 选中指示器
      if (this.selectedStyle === style) {
        Row() {
          Text('✓')
            .fontSize(14)
            .fontColor(Color.White)
        }
        .width(24)
        .height(24)
        .backgroundColor('#007AFF')
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
        .margin({ top: 12 })
      } else {
        Row()
          .width(24)
          .height(24)
          .border({ width: 2, color: '#CCCCCC' })
          .borderRadius(12)
          .margin({ top: 12 })
      }
    }
  }
}
