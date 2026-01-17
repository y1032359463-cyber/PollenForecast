/*
 * CuteCalcKeyboard Component
 * 可爱计算器键盘组件
 */

import { CuteButton, CuteButtonConfig } from './CuteButton';
import { BUTTON_TYPE, CalcConstants } from '../common/Constant';
import { ThemeSizes } from '../common/ThemeConfig';

/**
 * 可爱计算器键盘
 */
@Component
export struct CuteCalcKeyboard {
  onButtonClick?: (value: string) => void;   // 按钮点击回调
  @Prop buttonShape: string = 'rounded';     // 按钮形状
  @Prop keyboardTheme: string = 'default';   // 键盘主题
  @Prop buttonBorder: string = 'flat';       // 按键边框

  /**
   * 按钮配置数组（严格按照原始布局）
   * 第1行: C del % ÷
   * 第2行: 7 8 9 ×
   * 第3行: 4 5 6 -
   * 第4行: 1 2 3 +
   * 第5行: 0 . =(占2列)
   */
  private buttons: CuteButtonConfig[] = [
    // 第一行: C, del, %, ÷
    { value: CalcConstants.CLEAR, type: BUTTON_TYPE.FUNCTION },
    { value: 'del', type: BUTTON_TYPE.FUNCTION },
    { value: '%', type: BUTTON_TYPE.OPERATOR },
    { value: CalcConstants.DIV, type: BUTTON_TYPE.OPERATOR },

    // 第二行: 7, 8, 9, ×
    { value: '7', type: BUTTON_TYPE.NUMBER },
    { value: '8', type: BUTTON_TYPE.NUMBER },
    { value: '9', type: BUTTON_TYPE.NUMBER },
    { value: CalcConstants.MUL, type: BUTTON_TYPE.OPERATOR },

    // 第三行: 4, 5, 6, -
    { value: '4', type: BUTTON_TYPE.NUMBER },
    { value: '5', type: BUTTON_TYPE.NUMBER },
    { value: '6', type: BUTTON_TYPE.NUMBER },
    { value: CalcConstants.MIN, type: BUTTON_TYPE.OPERATOR },

    // 第四行: 1, 2, 3, +
    { value: '1', type: BUTTON_TYPE.NUMBER },
    { value: '2', type: BUTTON_TYPE.NUMBER },
    { value: '3', type: BUTTON_TYPE.NUMBER },
    { value: CalcConstants.ADD, type: BUTTON_TYPE.OPERATOR },

    // 第五行: 0, ., = (双倍宽)
    { value: CalcConstants.ZERO, type: BUTTON_TYPE.NUMBER },
    { value: CalcConstants.DOTS, type: BUTTON_TYPE.FUNCTION },
    { value: CalcConstants.EQUAL, type: BUTTON_TYPE.FUNCTION }
  ];

  build() {
    Column() {
      // 键盘区域：4列 × 5行（符合 Figma 规范）
      // Figma 尺寸：200×200px @3x = 66.7vp, 间距 8px @3x = 2.7vp
      Grid() {
        ForEach(this.buttons, (item: CuteButtonConfig, index: number) => {
          GridItem() {
            CuteButton({
              config: item,
              buttonShape: this.buttonShape,
              keyboardTheme: this.keyboardTheme,
              buttonBorder: this.buttonBorder,
              onButtonClick: this.onButtonClick
            })
              .width('100%')
              .height('100%')
          }
          .columnStart(index === 18 ? 2 : undefined)
          .columnEnd(index === 18 ? 3 : undefined)
        }, (item: CuteButtonConfig) => `btn_${item.value}_${item.type}`)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')  // 4列均分
      .rowsTemplate('1fr 1fr 1fr 1fr 1fr')  // 5行均分
      .columnsGap(8)
      .rowsGap(8)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 12 })
  }
}
