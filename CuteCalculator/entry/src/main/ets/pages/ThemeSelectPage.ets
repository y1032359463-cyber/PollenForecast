/*
 * ThemeSelectPage - 主题选择页面
 * Theme Selection Page
 */

import { router } from '@kit.ArkUI';
import { ThemeManager, ThemeType, ThemeConfig } from '../utils/ThemeManager';
import PreferencesUtils from '../utils/PreferencesUtils';
import { ThemeColors } from '../common/ThemeConfig';

@Entry
@Component
struct ThemeSelectPage {
  @State themes: ThemeConfig[] = [];
  @State selectedTheme: ThemeType = ThemeType.DEFAULT;

  async aboutToAppear() {
    // 获取所有主题
    this.themes = ThemeManager.getAllThemes();
    // 获取当前选中的主题
    const currentTheme = await PreferencesUtils.getThemeType();
    this.selectedTheme = currentTheme as ThemeType;
  }

  build() {
    Column({ space: 0 }) {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })

        Text('选择主题')
          .fontSize(18)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Row()
          .width(24)
          .height(24)
      }
      .width('100%')
      .height(92)
      .padding({ left: 16, right: 16, top: 36 }) // top: 状态栏高度，总高度92=56+36
      .backgroundColor($r('app.color.bg_main'))

      // 主题列表
      Scroll() {
        Column({ space: 20 }) {
          ForEach(this.themes, (theme: ThemeConfig) => {
            ThemeCard({
              theme: theme,
              isSelected: this.selectedTheme === theme.type,
              onSelect: () => {
                this.handleThemeSelect(theme);
              }
            })
          })
          
          // 底部安全距离，确保最后一个主题卡片不会被导航栏遮挡
          Blank()
            .height(100)
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .width('100%')
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .backgroundColor($r('app.color.bg_main'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_main'))
  }

  /**
   * 处理主题选择
   */
  private async handleThemeSelect(theme: ThemeConfig) {
    // 更新选中状态
    this.selectedTheme = theme.type;
    // 保存主题设置
    await ThemeManager.setTheme(theme.type);
    // 返回上一页
    router.back();
  }
}

/**
 * 主题卡片组件
 */
@Component
struct ThemeCard {
  @Prop theme: ThemeConfig;
  @Prop isSelected: boolean;
  onSelect: () => void = () => {};

  build() {
    Column() {
      // 主题预览区域
      Stack() {
        // 背景色
        Column()
          .width('100%')
          .height(120)
          .backgroundColor(this.theme.bgMain)
          .borderRadius(12)
          .padding(12)

        // 模拟计算器界面
        Column() {
          // 模拟结果显示
          Column()
            .width('100%')
            .height(40)
            .backgroundColor(this.theme.bgCard)
            .borderRadius(8)
            .margin({ bottom: 8 })
            .padding({ left: 12, right: 12 })
            .justifyContent(FlexAlign.Center)

          // 模拟键盘
          Row({ space: 8 }) {
            ForEach([1, 2, 3, 4], () => {
              Column()
                .width('22%')
                .height(32)
                .backgroundColor(this.theme.btnNormal)
                .borderRadius(8)
            })
          }
        }
      }

      // 主题名称
      Text(this.theme.name)
        .fontSize(16)
        .fontColor(this.theme.textPrimary)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 8 })

      // 选择按钮
      Button(this.isSelected ? '✓ 已选择' : '选择此主题')
        .width(160)
        .height(44)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.isSelected ? this.theme.primaryColor : this.theme.bgCard)
        .fontColor(this.isSelected ? '#FFFFFF' : this.theme.textPrimary)
        .borderRadius(22)
        .margin({ top: 8 })
        .enabled(this.isSelected === false)
        .onClick(() => {
          this.onSelect();
        })
    }
    .width('100%')
    .padding(24)
    .backgroundColor(this.theme.bgCard)
    .borderRadius(20)
    .border({
      width: this.isSelected ? 3 : 0,
      color: this.theme.primaryColor
    })
    .shadow({
      radius: 12,
      color: 'rgba(255, 140, 66, 0.15)',
      offsetX: 0,
      offsetY: 4
    })
  }
}
