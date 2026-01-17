/**
 * UI设计常量
 * 定义所有magic number,符合HarmonyOS设计规范
 */

export class UIConstants {
  // ========== 尺寸常量 ==========
  
  // 状态栏和导航栏
  static readonly STATUS_BAR_HEIGHT_DEFAULT: number = 0
  static readonly HEADER_HEIGHT: number = 56
  static readonly TAB_BAR_HEIGHT: number = 56
  static readonly TAB_BAR_SAFE_AREA: number = 20
  static readonly TAB_BAR_TOTAL_HEIGHT: number = 76 // 56 + 20
  
  // 触摸目标尺寸(HarmonyOS最小标准)
  static readonly MIN_TOUCH_TARGET: number = 44
  static readonly ICON_SIZE_SMALL: number = 16
  static readonly ICON_SIZE_MEDIUM: number = 24
  static readonly ICON_SIZE_LARGE: number = 48
  
  // 日历组件
  static readonly CALENDAR_CELL_SIZE: number = 48
  static readonly CALENDAR_GAP: number = 4
  static readonly CALENDAR_PADDING: number = 16
  static readonly WEEK_HEADER_HEIGHT: number = 32
  static readonly MONTH_SELECTOR_HEIGHT: number = 48
  
  // 卡片尺寸
  static readonly SUMMARY_CARD_HEIGHT: number = 120
  
  // ========== 间距常量 ==========
  
  // 基础间距(8px网格系统)
  static readonly SPACING_XXS: number = 2
  static readonly SPACING_XS: number = 4
  static readonly SPACING_SM: number = 8
  static readonly SPACING_MD: number = 12
  static readonly SPACING_LG: number = 16
  static readonly SPACING_XL: number = 20
  static readonly SPACING_XXL: number = 24
  static readonly SPACING_XXXL: number = 32
  
  // ========== 圆角常量 ==========
  
  static readonly RADIUS_XS: number = 4
  static readonly RADIUS_SM: number = 8
  static readonly RADIUS_MD: number = 12
  static readonly RADIUS_LG: number = 16
  static readonly RADIUS_XL: number = 24
  
  // ========== 字体尺寸 ==========
  
  static readonly FONT_SIZE_XS: number = 12
  static readonly FONT_SIZE_SM: number = 14
  static readonly FONT_SIZE_MD: number = 16
  static readonly FONT_SIZE_LG: number = 18
  static readonly FONT_SIZE_XL: number = 20
  static readonly FONT_SIZE_XXL: number = 24
  static readonly FONT_SIZE_XXXL: number = 32
  
  // ========== 动画时长 ==========
  
  static readonly ANIMATION_DURATION_FAST: number = 150
  static readonly ANIMATION_DURATION_NORMAL: number = 300
  static readonly ANIMATION_DURATION_SLOW: number = 500
  
  // ========== 不透明度 ==========
  
  static readonly OPACITY_DISABLED: number = 0.4
  static readonly OPACITY_MEDIUM: number = 0.6
  static readonly OPACITY_HIGH: number = 0.8
  static readonly OPACITY_VERY_HIGH: number = 0.9
  static readonly OPACITY_CARD_PRESS: number = 0.98
  static readonly OPACITY_CELL_PRESS: number = 0.95
  
  // ========== 数值常量 ==========
  
  static readonly ZERO: number = 0
  static readonly ONE: number = 1
  static readonly LAYOUT_WEIGHT_FULL: number = 1
  
  // 日期计算
  static readonly MONTHS_PER_YEAR: number = 12
  static readonly DAYS_PER_WEEK: number = 7
  static readonly SUNDAY_INDEX: number = 0
  static readonly MONDAY_OFFSET: number = 6
  static readonly FIRST_DAY_OFFSET: number = 1
  
  // 数字精度
  static readonly DECIMAL_PLACES_ONE: number = 10 // 保留1位小数用
  static readonly DECIMAL_PLACES_TWO: number = 100 // 保留2位小数用
  
  // ========== 边框常量 ==========
  
  static readonly BORDER_WIDTH_THIN: number = 1
  static readonly BORDER_WIDTH_MEDIUM: number = 2
  static readonly BORDER_WIDTH_NONE: number = 0
  
  // ========== 阴影常量 ==========
  
  static readonly SHADOW_RADIUS_SM: number = 8
  static readonly SHADOW_RADIUS_MD: number = 12
  static readonly SHADOW_RADIUS_LG: number = 16
  static readonly SHADOW_OFFSET_Y: number = 4
  static readonly SHADOW_OFFSET_Y_LARGE: number = 6
}
