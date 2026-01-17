/*
 * CuteCalculator Theme Configuration
 * 可爱计算器主题配置
 * 支持亮色/深色模式
 */

/**
 * 主题颜色配置（使用资源引用以支持深色模式）
 */
export class ThemeColors {
  // 主色调
  static readonly PRIMARY_ORANGE: string = '#FF8C42';  // 主题橙
  static readonly PRIMARY_PINK: string = '#FFB3C1';    // 主题粉

  // 背景色 - 使用资源引用（运行时读取）
  // 亮色: #FFD4A3, 深色: #2C2C2E
  static readonly BG_MAIN: string = '#FFD4A3';         // 主背景(暖浅橙)
  // 通过资源系统 $r('app.color.bg_main') 在代码中动态获取

  static readonly BG_CARD: string = '#FFFFFF';         // 卡片背景

  // 按钮背景色
  static readonly BTN_NORMAL: string = '#FFE8CC';      // 数字按钮(浅橙)
  static readonly BTN_OPERATOR: string = '#FFFFFF';    // 运算符按钮(白色)
  static readonly BTN_EQUAL: string = '#FFFFFF';       // 等号按钮(白色)
  static readonly BTN_CLEAR_AC: string = '#B7410E';    // AC按钮(深红褐)
  static readonly BTN_CLEAR: string = '#E54B4B';       // C按钮(红色)
  static readonly BTN_DEL: string = '#FFE8CC';         // 删除按钮(浅橙)

  // 文字颜色 - 提高对比度以符合UX规范
  static readonly TEXT_PRIMARY: string = '#8B4513';    // 主文字(更深的棕色，提高对比度)
  static readonly TEXT_WHITE: string = '#FFFFFF';      // 白色文字
  static readonly TEXT_SECONDARY: string = '#5D4037';  // 次要文字(深棕色，对比度>7:1)
}

/**
 * 深色模式颜色配置
 */
export class DarkThemeColors {
  static readonly BG_MAIN: string = '#2C2C2E';         // 深色主背景
  static readonly BG_CARD: string = '#3A3A3C';         // 深色卡片背景
  static readonly BTN_NORMAL: string = '#48484A';      // 深色数字按钮
  static readonly BTN_OPERATOR: string = '#5A5A5C';    // 深色运算符按钮
  static readonly TEXT_PRIMARY: string = '#FFB366';    // 深色主文字
  static readonly BORDER_COLOR: string = '#FF8C42';    // 深色边框
}

/**
 * 字体配置
 */
export class ThemeFonts {
  // 手绘字体（用于数字和运算符）
  // 注意：HarmonyOS资源系统会自动处理文件名，不需要.ttf后缀
  static readonly CUTE_FONT: string = 'squeaky_chalk_sound';  // 粉笔手绘风格
  // 系统字体（用于中文）
  static readonly SYSTEM_FONT: string = 'HarmonyOS-Sans';     // 鸿蒙默认字体
}

/**
 * 主题尺寸配置
 */
export class ThemeSizes {
  // 按钮尺寸
  static readonly BUTTON_SIZE: number = 80;            // 标准按钮大小(vp)
  static readonly BUTTON_SIZE_LARGE: number = 168;     // 大按钮(0和=)
  static readonly BUTTON_RADIUS: number = 20;          // 按钮圆角

  // 间距
  static readonly SPACING_SMALL: number = 8;           // 小间距
  static readonly SPACING_MEDIUM: number = 16;         // 中等间距
  static readonly SPACING_LARGE: number = 24;          // 大间距

  // 字体大小
  static readonly FONT_SIZE_RESULT: number = 48;       // 结果显示字体
  static readonly FONT_SIZE_EXPRESSION: number = 24;   // 表达式字体
  static readonly FONT_SIZE_BUTTON: number = 28;       // 按钮文字字体
}

/**
 * 动画配置
 */
export class ThemeAnimations {
  // 按钮按压动画
  static readonly PRESS_SCALE: number = 0.95;          // 按压缩放比例
  static readonly PRESS_DURATION: number = 100;        // 按压动画时长(ms)

  // 角色切换动画
  static readonly CHARACTER_DURATION: number = 300;    // 角色切换时长(ms)
  static readonly CHARACTER_CURVE = Curve.EaseInOut;   // 动画曲线

  // 结果显示动画
  static readonly RESULT_DURATION: number = 200;       // 结果显示时长(ms)
}
