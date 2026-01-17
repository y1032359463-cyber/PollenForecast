/*
 * ResultDisplay Component
 * 计算结果显示组件 - Retro Pixel Game Boy液晶屏效果
 */

import { RetroPixelTheme } from '../common/RetroPixelTheme';

/**
 * 结果显示组件
 */
@Component
export struct ResultDisplay {
  @Prop expression: string = '';    // 当前表达式（从父组件传入）
  @Prop result: string = '0';       // 计算结果（从父组件传入）

  build() {
    Column({ space: 4 }) {
      // 表达式显示（运算过程）
      Text(this.expression || ' ')
        .fontSize(16)
        .height(20)
        .fontColor(RetroPixelTheme.COLOR_OPERATOR)  // #306230 深绿
        .fontFamily('PressStart2P, monospace')
        .textAlign(TextAlign.End)
        .width('100%')
        .maxLines(1)
        .padding(0)

      // 结果显示（当前输入或计算结果）
      Text(this.result)
        .fontSize(32)
        .height(40)
        .fontColor(RetroPixelTheme.COLOR_RESULT)    // #9BBC0F 亮绿
        .fontFamily('PressStart2P, monospace')
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.End)
        .width('100%')
        .maxLines(1)
        .padding(0)
    }
    .width('100%')
    .height(100)
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
    .alignItems(HorizontalAlign.End)
    .justifyContent(FlexAlign.Start)
    .borderRadius(RetroPixelTheme.DISPLAY_RADIUS)   // 8 圆角
    .backgroundColor(RetroPixelTheme.COLOR_PRIMARY)  // #7FA99B 青绿液晶屏
    .border({ 
      width: RetroPixelTheme.DISPLAY_BORDER,        // 3px边框
      color: RetroPixelTheme.COLOR_BACKGROUND       // #4A4A4A 深灰外壳
    })
    .shadow({
      radius: 0,
      color: 'rgba(0, 0, 0, 0)',
      offsetX: 0,
      offsetY: 0
    })
    .margin({ left: 16, right: 16, top: 48, bottom: 16 })
  }
}
