/**
 * 主题设置页面
 */

import { ThemeManager, THEMES, ThemeConfig } from '../common/utils/ThemeManager';
import router from '@ohos.router';

@Entry
@Component
struct ThemeSettingsPage {
  @State currentThemeIndex: number = 0;
  private themeManager = ThemeManager.getInstance();

  aboutToAppear() {
    this.currentThemeIndex = AppStorage.get<number>('current_theme') || 0;
  }

  /**
   * 应用主题
   */
  applyTheme(index: number) {
    this.currentThemeIndex = index;
    this.themeManager.setTheme(index);
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('←')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.getUIContext().getRouter().back();
          })

        Text('主题设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 12 })
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.Start)

      // 当前主题预览
      Column() {
        Text('当前主题')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ bottom: 8 })

        Row() {
          Text(THEMES[this.currentThemeIndex].icon)
            .fontSize(32)
            .margin({ right: 12 })

          Column() {
            Text(THEMES[this.currentThemeIndex].name)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)

            Text('正在使用')
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(THEMES[this.currentThemeIndex].backgroundColor)
        .borderRadius(12)
        .border({
          width: 2,
          color: THEMES[this.currentThemeIndex].primaryColor
        })
      }
      .width('90%')
      .margin({ top: 16 })

      // 主题列表
      Text('可选主题')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)
        .margin({ left: '5%', top: 24, bottom: 12 })

      List() {
        ForEach(THEMES, (theme: ThemeConfig, index: number) => {
          ListItem() {
            this.ThemeCard(theme, index)
          }
          .margin({ bottom: 12 })
        })
      }
      .width('90%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 底部说明
      Text('主题仅影响界面配色,不影响数据')
        .fontSize(12)
        .fontColor('#999999')
        .margin({ bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  ThemeCard(theme: ThemeConfig, index: number) {
    Row() {
      // 主题图标
      Text(theme.icon)
        .fontSize(24)
        .width(48)
        .height(48)
        .textAlign(TextAlign.Center)
        .backgroundColor(theme.backgroundColor)
        .borderRadius(8)

      // 主题信息
      Column() {
        Text(theme.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)

        Row() {
          Text('主色')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ right: 8 })

          Circle({ width: 16, height: 16 })
            .fill(theme.primaryColor)
            .margin({ right: 12 })

          Text('辅色')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ right: 8 })

          Circle({ width: 16, height: 16 })
            .fill(theme.secondaryColor)
        }
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)

      // 选中状态
      if (index === this.currentThemeIndex) {
        Text('✓')
          .fontSize(24)
          .fontColor(theme.primaryColor)
          .fontWeight(FontWeight.Bold)
      } else {
        Button('使用')
          .fontSize(14)
          .backgroundColor(theme.primaryColor)
          .height(32)
          .onClick(() => {
            this.applyTheme(index);
          })
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .border({
      width: index === this.currentThemeIndex ? 2 : 0,
      color: theme.primaryColor
    })
    .onClick(() => {
      if (index !== this.currentThemeIndex) {
        this.applyTheme(index);
      }
    })
  }
}
