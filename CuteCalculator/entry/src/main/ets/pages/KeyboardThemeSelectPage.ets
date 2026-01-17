/*
 * KeyboardThemeSelectPage - 键盘主题选择页面
 */

import { router } from '@kit.ArkUI';
import PreferencesUtils from '../utils/PreferencesUtils';

interface ThemeOption {
  id: string;
  name: string;
  description: string;
  available: boolean; // 是否可用（有图片资源）
}

@Entry
@Component
struct KeyboardThemeSelectPage {
  @State selectedTheme: string = 'default';
  @State themes: ThemeOption[] = [
    { id: 'default', name: '默认', description: '经典文字按钮，简洁明了', available: true },
    { id: 'catpaw', name: '猫爪', description: '可爱猫爪图案，萌趣十足', available: true },
    { id: 'star', name: '星星', description: '闪耀星星设计，梦幻可爱', available: true }
    // 未来新增主题时在这里添加，available 设为 true 即可显示
  ];

  async aboutToAppear() {
    this.selectedTheme = await PreferencesUtils.getKeyboardTheme();
  }

  build() {
    Column({ space: 0 }) {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .onClick(() => router.back())

        Text('键盘主题')
          .fontSize(18)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Row().width(24).height(24)
      }
      .width('100%')
      .height(92)
      .padding({ left: 16, right: 16, top: 36 }) // top: 状态栏高度，总高度92=56+36
      .backgroundColor($r('app.color.bg_main'))

      // 选项列表
      Scroll() {
        Column({ space: 20 }) {
          ForEach(this.themes, (theme: ThemeOption) => {
            this.buildThemeCard(theme)
          })
          Blank().height(100)
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_main'))
  }

  @Builder
  buildThemeCard(theme: ThemeOption) {
    Column({ space: 12 }) {
      // 预览区域
      Row({ space: 8 }) {
        ForEach(['1', '2', '3', '+'], (key: string) => {
          if (theme.id === 'default') {
            // 默认主题显示文字按钮
            Text(key)
              .width(50)
              .height(50)
              .backgroundColor($r('app.color.btn_normal'))
              .borderRadius(12)
              .textAlign(TextAlign.Center)
              .fontSize(20)
              .fontColor($r('app.color.text_primary'))
          } else {
            // 图片主题显示图片按钮
            Image($rawfile(`keyboard_themes/${theme.id}/${theme.id}_${this.getKeyName(key)}_normal.png`))
              .width(50)
              .height(50)
              .objectFit(ImageFit.Contain)
          }
        })
      }
      .padding(16)

      Text(theme.name)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      Text(theme.description)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))

      // 选择按钮
      Row() {
        Text(this.getButtonText(theme))
          .fontSize(14)
          .fontColor(this.getButtonTextColor(theme))
      }
      .width(120)
      .height(40)
      .backgroundColor(this.getButtonBgColor(theme))
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        if (this.selectedTheme !== theme.id) {
          this.handleSelect(theme.id)
        }
      })
    }
    .width('100%')
    .padding(20)
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(20)
    .border({
      width: this.selectedTheme === theme.id ? 3 : 0,
      color: '#FF8C42'
    })
    .shadow({ radius: 12, color: 'rgba(255, 140, 66, 0.15)', offsetX: 0, offsetY: 4 })
  }

  /**
   * 获取按钮文字
   */
  private getButtonText(theme: ThemeOption): string {
    if (this.selectedTheme === theme.id) return '✓ 已选择';
    return '选择';
  }

  /**
   * 获取按钮背景色
   */
  private getButtonBgColor(theme: ThemeOption): ResourceColor {
    if (this.selectedTheme === theme.id) return '#FF8C42';
    return $r('app.color.bg_card');
  }

  /**
   * 获取按钮文字颜色
   */
  private getButtonTextColor(theme: ThemeOption): ResourceColor {
    if (this.selectedTheme === theme.id) return '#FFFFFF';
    return $r('app.color.text_primary');
  }

  /**
   * 将按钮值转换为图片文件名
   */
  private getKeyName(key: string): string {
    switch (key) {
      case '+': return 'add';
      case '-': return 'sub';
      case '×': return 'mul';
      case '÷': return 'div';
      case '=': return 'equal';
      case '.': return 'dot';
      case '%': return 'percent';
      case 'AC': return 'ac';
      case 'C': return 'c';
      case 'del': return 'del';
      default: return key; // 数字直接返回
    }
  }

  private async handleSelect(themeId: string) {
    this.selectedTheme = themeId;
    await PreferencesUtils.setKeyboardTheme(themeId);
    router.back();
  }
}