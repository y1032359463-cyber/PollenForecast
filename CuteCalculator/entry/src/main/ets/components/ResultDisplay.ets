/*
 * ResultDisplay Component
 * 计算结果显示组件
 * 支持亮色/深色模式自动适配
 */

import { ThemeColors, ThemeSizes, ThemeFonts } from '../common/ThemeConfig';

/**
 * 结果显示组件
 */
@Component
export struct ResultDisplay {
  @Prop expression: string = ''; // 当前表达式（从父组件传入）
  @Prop result: string = '0'; // 计算结果（从父组件传入）

  build() {
    Column({ space: 4 }) { // 4px间距
      // 表达式显示（运算过程）
      Scroll() {
        Row() {
          Text(this.expression || ' ')
            .fontSize(this.expression.length > 15 ? 16 : 20)
            .fontColor($r('app.color.text_secondary'))
            .fontFamily('Pacifico, HarmonyOS Sans')
            .textAlign(TextAlign.End)
            .maxLines(1)
            .letterSpacing(-0.3)
            .padding(0)
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .height(28)

      // 结果显示（当前输入或计算结果）
      Scroll() {
        Row() {
          Text(this.result)
            .fontSize(this.getDynamicFontSize(this.result))
            .fontColor($r('app.color.text_primary'))
            .fontFamily('Pacifico, HarmonyOS Sans')
            .textAlign(TextAlign.End)
            .maxLines(1)
            .letterSpacing(-0.5)
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .height(60)
    }
    .width('100%')
    .height(116)
    .padding({
      left: 16,
      right: 16,
      top: 10,
      bottom: 14
    })
    .alignItems(HorizontalAlign.End)
    .justifyContent(FlexAlign.Start)
    .borderRadius(12)
    .backgroundColor($r('app.color.bg_card'))
    .border({ width: 1, color: $r('app.color.border_color') })
    .shadow({
      radius: 12,
      color: 'rgba(255, 140, 66, 0.15)',
      offsetX: 0,
      offsetY: 2
    })
    .margin({
      left: 16,
      right: 16,
      top: 48,
      bottom: 16
    })
  }

  /**
   * 根据文本长度动态计算字体大小
   */
  private getDynamicFontSize(text: string): number {
    // 优化字体大小，全屏更大，长文本自动缩小
    if (text.length <= 6) {
      return 42;  // 短文本用大字体
    } else if (text.length <= 10) {
      return 34;
    } else if (text.length <= 15) {
      return 26;
    } else {
      return 20;
    }
  }
}
