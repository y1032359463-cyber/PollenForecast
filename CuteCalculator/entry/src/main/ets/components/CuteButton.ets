/*
 * CuteButton Component
 * 可爱按钮组件 - 使用文字+背景色（代码优先方案）
 */

import { ThemeColors, ThemeSizes, ThemeAnimations, ThemeFonts } from '../common/ThemeConfig';
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
  @State private scaleValue: number = 1;             // 缩放值（用于动画）
  @Prop buttonShape: string = 'rounded';             // 'circle' | 'rounded'
  @Prop keyboardTheme: string = 'default';           // 键盘主题
  @Prop buttonBorder: string = 'flat';               // 边框风格
  onButtonClick?: (value: string) => void;           // 点击回调

  build() {
    if (this.keyboardTheme !== 'default') {
      // 使用主题图片按钮（图片自带数字，不显示文字）
      Stack() {
        // 普通状态图片
        Image(this.getNormalImage())
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .syncLoad(true)
          .visibility(this.scaleValue < 1 ? Visibility.Hidden : Visibility.Visible)

        // 按下状态图片
        Image(this.getPressedImage())
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .syncLoad(true)
          .visibility(this.scaleValue < 1 ? Visibility.Visible : Visibility.Hidden)
      }
      .width('100%')
      .height('100%')
      .hitTestBehavior(HitTestMode.Block)
      .scale({ x: this.scaleValue, y: this.scaleValue })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          animateTo({ duration: 80, curve: Curve.EaseOut }, () => {
            this.scaleValue = 0.92;
          });
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          animateTo({ duration: 120, curve: Curve.EaseOut }, () => {
            this.scaleValue = 1;
          });
        }
      })
      .onClick(() => this.handleClick())
    } else {
      // 默认文字按钮（保持现有逻辑，但应用形状和边框设置）
      Text(this.config.value)
        .fontSize(24)
        .minFontSize(12)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Clip })
        .heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST)
        .fontColor(this.getTextColor())
        .fontFamily('Pacifico, HarmonyOS Sans')
        .textAlign(TextAlign.Center)
        .constraintSize({
          minWidth: 40,
          minHeight: 40
        })
        .width('100%')
        .height('100%')
        .borderRadius(this.getButtonRadius())
        .backgroundColor(this.getBackgroundColor())
        .border(this.getBorderStyle())
        .shadow(this.getShadowStyle())
        .scale({ x: this.scaleValue, y: this.scaleValue })
        .onClick(() => {
          this.handleClick();
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            animateTo({ duration: 80, curve: Curve.EaseOut }, () => {
              this.scaleValue = 0.96;
            });
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            animateTo({ duration: 120, curve: Curve.EaseOut }, () => {
              this.scaleValue = 1;
            });
          }
        })
    }
  }

  /**
   * 获取边框颜色
   */
  private getBorderColor(): ResourceColor {
    return $r('app.color.btn_border_color');
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
   * 根据按钮类型获取背景色
   */
  private getBackgroundColor(): string {
    switch (this.config.type) {
      case BUTTON_TYPE.NUMBER:
        return ThemeColors.BTN_NORMAL;     // #FFE8CC 浅橙
      case BUTTON_TYPE.OPERATOR:
        return ThemeColors.BTN_OPERATOR;   // #FFFFFF 白色
      case BUTTON_TYPE.FUNCTION:
        // 根据具体按钮值区分
        if (this.config.value === 'AC') {
          return ThemeColors.BTN_CLEAR_AC; // #B7410E 深红褐色
        } else if (this.config.value === 'C') {
          return ThemeColors.BTN_CLEAR;    // #E54B4B 红色
        } else if (this.config.value === '=') {
          return '#FF8C42';                // 等号键用醒目的橙色
        } else if (this.config.value === 'del' || this.config.value === '%' || this.config.value === '.') {
          return ThemeColors.BTN_DEL;      // #FFE8CC 浅橙
        }
        return ThemeColors.BTN_DEL;
      default:
        return ThemeColors.BTN_NORMAL;
    }
  }

  /**
   * 根据背景色获取文字颜色
   */
  private getTextColor(): string {
    const bgColor = this.getBackgroundColor();
    // AC、C和等号按钮用白色文字,其他用深褐色
    if (bgColor === ThemeColors.BTN_CLEAR_AC || bgColor === ThemeColors.BTN_CLEAR || bgColor === '#FF8C42') {
      return ThemeColors.TEXT_WHITE;      // #FFFFFF 白色
    }
    return '#C17735';  // 深褐色文字
  }

  /**
   * 获取阴影颜色
   */
  private getShadowColor(): string {
    const bgColor = this.getBackgroundColor();
    // 根据背景色调整阴影
    if (bgColor === ThemeColors.BTN_EQUAL) {
      return 'rgba(255, 140, 66, 0.3)';   // 橙色阴影
    } else if (bgColor === ThemeColors.BTN_OPERATOR) {
      return 'rgba(255, 179, 102, 0.3)';  // 浅橙阴影
    } else if (bgColor === ThemeColors.BTN_CLEAR) {
      return 'rgba(255, 107, 107, 0.3)';  // 红色阴影
    }
    return 'rgba(0, 0, 0, 0.1)';          // 默认灰色阴影
  }

  /**
   * 处理点击事件
   */
  private handleClick(): void {
    if (this.onButtonClick) {
      this.onButtonClick(this.config.value);
    }
  }

  /**
   * 获取普通状态图片
   */
  private getNormalImage(): Resource {
    const keyName = this.getImageKeyName(this.config.value);
    return $rawfile(`keyboard_themes/${this.keyboardTheme}/${this.keyboardTheme}_${keyName}_normal.png`);
  }

  /**
   * 获取按下状态图片
   */
  private getPressedImage(): Resource {
    const keyName = this.getImageKeyName(this.config.value);
    return $rawfile(`keyboard_themes/${this.keyboardTheme}/${this.keyboardTheme}_${keyName}_pressed.png`);
  }

  /**
   * 获取主题按钮图片（已废弃，保留兼容）
   * 图片命名规范：{theme}_{key}_{state}.png
   * 例如：catpaw_5_normal.png, catpaw_5_pressed.png
   */
  private getThemeButtonImage(): Resource {
    const keyName = this.getImageKeyName(this.config.value);
    const state = this.scaleValue < 1 ? 'pressed' : 'normal';
    return $rawfile(`keyboard_themes/${this.keyboardTheme}/${this.keyboardTheme}_${keyName}_${state}.png`);
  }

  /**
   * 将按钮值转换为图片文件名
   */
  private getImageKeyName(value: string): string {
    switch (value) {
      case '+': return 'add';
      case '-': return 'sub';
      case '×': return 'mul';
      case '÷': return 'div';
      case '=': return 'equal';
      case '.': return 'dot';
      case '%': return 'percent';
      case 'AC': return 'ac';
      case 'C': return 'ac';   // C 按钮使用 ac 图片（显示 AC 全部清除）
      case 'del': return 'del';  // del 按钮使用 del 图片
      default: return value; // 数字直接返回
    }
  }

  /**
   * 获取按钮圆角
   */
  private getButtonRadius(): number | string {
    if (this.buttonBorder === 'pixel') {
      return 0; // 像素风格无圆角
    }
    if (this.buttonShape === 'circle') {
      return '50%';
    }
    return 16; // 默认圆角
  }

  /**
   * 获取边框样式
   */
  private getBorderStyle(): BorderOptions {
    switch (this.buttonBorder) {
      case 'flat':
        return { width: 0 };
      case '3d':
        return { width: { bottom: 4 }, color: this.get3DBorderColor() };
      case 'neon':
        return { width: 2, color: this.getNeonBorderColor() };
      case 'pixel':
        return { width: 3, color: '#000000' };
      default:
        return { width: 1, color: this.getBorderColor() };
    }
  }

  /**
   * 获取阴影样式
   */
  private getShadowStyle(): ShadowOptions {
    switch (this.buttonBorder) {
      case 'flat':
        return { radius: 0, offsetX: 0, offsetY: 0, color: 'transparent' };
      case '3d':
        return { radius: 0, offsetX: 0, offsetY: 4, color: this.get3DShadowColor() };
      case 'neon':
        return { radius: 15, offsetX: 0, offsetY: 0, color: this.getNeonGlowColor() };
      case 'pixel':
        return { radius: 0, offsetX: 2, offsetY: 2, color: '#000000' };
      default:
        return { radius: 6, offsetX: 0, offsetY: 3, color: this.getShadowColor() };
    }
  }

  /**
   * 获取3D边框颜色
   */
  private get3DBorderColor(): string {
    const bgColor = this.getBackgroundColor();
    // 根据背景色返回更深的阴影色
    if (bgColor === ThemeColors.BTN_CLEAR_AC || bgColor === ThemeColors.BTN_CLEAR) {
      return '#8B2500'; // 深红褐
    } else if (bgColor === '#FF8C42') {
      return '#CC6D30'; // 深橙
    }
    return '#D4A574'; // 默认深米色
  }

  /**
   * 获取3D阴影颜色
   */
  private get3DShadowColor(): string {
    return 'rgba(0, 0, 0, 0.2)';
  }

  /**
   * 获取霓虹边框颜色
   */
  private getNeonBorderColor(): string {
    const bgColor = this.getBackgroundColor();
    if (bgColor === ThemeColors.BTN_CLEAR_AC || bgColor === ThemeColors.BTN_CLEAR) {
      return '#FF6B6B'; // 红色霓虹
    } else if (bgColor === '#FF8C42') {
      return '#FFA500'; // 橙色霓虹
    } else if (bgColor === ThemeColors.BTN_OPERATOR) {
      return '#00CED1'; // 青色霓虹
    }
    return '#FFD700'; // 金色霓虹
  }

  /**
   * 获取霓虹发光颜色
   */
  private getNeonGlowColor(): string {
    return this.getNeonBorderColor() + '80'; // 添加50%透明度
  }
}
