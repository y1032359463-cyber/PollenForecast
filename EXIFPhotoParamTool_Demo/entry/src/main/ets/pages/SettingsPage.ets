/**
 * 设置页面 - 切换UI风格等设置
 */
import { common } from '@kit.AbilityKit'
import { UIStyle } from '../models/PhotoRecord'
import { PreferenceService } from '../services/PreferenceService'
import { hilog } from '@kit.PerformanceAnalysisKit'

@Entry
@Component
struct SettingsPage {
  @State currentStyle: UIStyle = UIStyle.CARD
  private preferenceService: PreferenceService | null = null

  aboutToAppear(): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    this.preferenceService = new PreferenceService(context)
    this.loadSettings()
  }

  async loadSettings(): Promise<void> {
    if (this.preferenceService) {
      await this.preferenceService.init()
      this.currentStyle = await this.preferenceService.getUIStyle()
    }
  }

  async changeStyle(style: UIStyle): Promise<void> {
    if (this.preferenceService && style !== this.currentStyle) {
      await this.preferenceService.setUIStyle(style)
      this.currentStyle = style
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => {
            try {
              this.getUIContext().getRouter().back()
            } catch (error) {
              hilog.error(0x0021, 'UI', '返回失败:' + error)
            }
          })
        
        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
        
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      // 设置列表
      List() {
        // 界面风格设置组
        ListItemGroup({ header: this.GroupHeader('界面风格') }) {
          ListItem() {
            this.StyleOption('卡片列表式', '照片缩略图 + 参数概览', UIStyle.CARD)
          }
          
          ListItem() {
            this.StyleOption('参数突出式', '大字体参数 + 专业布局', UIStyle.PARAM)
          }
        }
        .divider({ strokeWidth: 0.5, color: '#F0F0F0', startMargin: 56 })

        // 关于设置组
        ListItemGroup({ header: this.GroupHeader('关于') }) {
          ListItem() {
            this.InfoRow('版本', '1.0.0')
          }
          
          ListItem() {
            this.InfoRow('隐私说明', '仅本地存储，无联网')
          }
        }
        .divider({ strokeWidth: 0.5, color: '#F0F0F0', startMargin: 16 })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      .sticky(StickyStyle.Header)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  GroupHeader(title: string) {
    Text(title)
      .fontSize(14)
      .fontColor('#999999')
      .padding({ left: 16, top: 20, bottom: 8 })
      .width('100%')
  }

  @Builder
  StyleOption(title: string, desc: string, style: UIStyle) {
    Row() {
      Column() {
        Text(title)
          .fontSize(16)
          .fontColor('#333333')
        Text(desc)
          .fontSize(13)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      // 选中状态
      if (this.currentStyle === style) {
        Text('✓')
          .fontSize(20)
          .fontColor('#007AFF')
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor(Color.White)
    .onClick(() => {
      this.changeStyle(style)
    })
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor('#333333')
      
      Blank()
      
      Text(value)
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor(Color.White)
  }
}
