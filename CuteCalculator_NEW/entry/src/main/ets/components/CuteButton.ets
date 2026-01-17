/*
 * CuteButton Component
 * 像素按钮组件 - Retro Pixel Game Boy Theme
 */

import { RetroPixelTheme } from '../common/RetroPixelTheme';
import { BUTTON_TYPE } from '../common/Constant';

/**
 * 按钮配置接口
 */
export interface CuteButtonConfig {
  value: string;              // 按钮值
  type: BUTTON_TYPE;          // 按钮类型
  gridSpan?: number;          // 占用列数(默认1)
  gridRowSpan?: number;       // 占用行数(默认1)
}

/**
 * 可爱按钮组件
 */
@Component
export struct CuteButton {
  @Prop config: CuteButtonConfig;                    // 按钮配置
  @State isPressed: boolean = false;                 // 是否按下
  onButtonClick?: (value: string) => void;           // 点击回调

  build() {
    Text(this.config.value)
      .fontSize(24)
      .fontWeight(FontWeight.Bold)
      .fontColor(this.getTextColor())
      .fontFamily('PressStart2P, HarmonyOS Sans')  // 像素字体
      .width('94%')
      .height('95%')
      .textAlign(TextAlign.Center)
      .borderRadius(RetroPixelTheme.BUTTON_RADIUS)  // 4 像素化圆角
      .backgroundColor(this.getBackgroundColor())
      .border({
        width: 2,
        color: RetroPixelTheme.COLOR_DARK  // 深绿色边框
      })
      .shadow({
        radius: 2,
        color: 'rgba(0, 0, 0, 0.3)',
        offsetX: 2,
        offsetY: 2
      })
      .scale({ 
        x: this.isPressed ? 0.95 : 1,
        y: this.isPressed ? 0.95 : 1 
      })
      .animation({
        duration: RetroPixelTheme.BUTTON_PRESS_DURATION,
        curve: Curve.Sharp
      })
      .onClick(() => {
        this.handleClick();
      })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.isPressed = true;
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.isPressed = false;
        }
      })
  }

  /**
   * 获取按钮宽度（符合 Figma 规范）
   * 标准：200px @3x = 66.7vp
   * 双倍：416px @3x = 138.7vp
   */
  private getButtonWidth(): number {
    const span = this.config.gridSpan ?? 1;
    return span === 1 ? 66.7 : 138.7;  // Figma 规范尺寸
  }

  /**
   * 获取按钮高度（符合 Figma 规范）
   * 标准：200px @3x = 66.7vp
   * 双倍：416px @3x = 138.7vp
   */
  private getButtonHeight(): number {
    const rowSpan = this.config.gridRowSpan ?? 1;
    return rowSpan === 1 ? 66.7 : 138.7;  // Figma 规范尺寸
  }

  /**
   * 根据按钮类型获取背景色 (Game Boy配色)
   */
  private getBackgroundColor(): string {
    switch (this.config.type) {
      case BUTTON_TYPE.NUMBER:
        return RetroPixelTheme.BUTTON_NUMBER_BG;     // #8BAC0F 中绿
      case BUTTON_TYPE.OPERATOR:
        return RetroPixelTheme.BUTTON_OPERATOR_BG;   // #306230 深绿
      case BUTTON_TYPE.FUNCTION:
        // 根据具体按钮值区分
        if (this.config.value === 'AC' || this.config.value === 'C') {
          return RetroPixelTheme.BUTTON_CLEAR_BG;    // #8B0000 红色
        } else if (this.config.value === '=') {
          return RetroPixelTheme.BUTTON_EQUAL_BG;    // #9BBC0F 亮绿
        }
        return RetroPixelTheme.BUTTON_NUMBER_BG;     // 其他功能键用数字键配色
      default:
        return RetroPixelTheme.BUTTON_NUMBER_BG;
    }
  }

  /**
   * 根据背景色获取文字颜色 (Game Boy配色)
   */
  private getTextColor(): string {
    const bgColor = this.getBackgroundColor();
    if (bgColor === RetroPixelTheme.BUTTON_CLEAR_BG) {
      return RetroPixelTheme.BUTTON_CLEAR_TEXT;      // #FFE4E1 浅红
    } else if (bgColor === RetroPixelTheme.BUTTON_OPERATOR_BG) {
      return RetroPixelTheme.BUTTON_OPERATOR_TEXT;   // #9BBC0F 亮绿
    } else if (bgColor === RetroPixelTheme.BUTTON_EQUAL_BG) {
      return RetroPixelTheme.BUTTON_EQUAL_TEXT;      // #0F380F 黑绿
    }
    return RetroPixelTheme.BUTTON_NUMBER_TEXT;       // #0F380F 黑绿
  }

  /**
   * 处理点击事件
   */
  private handleClick(): void {
    if (this.onButtonClick) {
      this.onButtonClick(this.config.value);
    }
  }
}
