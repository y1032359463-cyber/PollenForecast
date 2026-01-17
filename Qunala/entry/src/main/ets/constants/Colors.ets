/**
 * 去哪拉 App 颜色常量
 * 主题：阳光黄 - 轻松愉快风格
 */
export class AppColors {
  // 主色调 - 黄色系
  static readonly PRIMARY = '#FFD700';           // 阳光黄（主色）
  static readonly PRIMARY_LIGHT = '#FFE55C';     // 亮黄色
  static readonly PRIMARY_DARK = '#FFA000';      // 深黄色
  
  // 辅助色
  static readonly SECONDARY = '#FF9800';         // 活力橙
  static readonly ACCENT = '#FFC107';            // 强调黄
  
  // 背景色
  static readonly BG_PRIMARY = '#FFFEF7';        // 主背景（奶白色）
  static readonly BG_CARD = '#FFF9E6';           // 卡片背景（奶油黄）
  static readonly BG_LIGHT = '#FFFEF0';          // 浅色背景
  
  // 状态色
  static readonly STATUS_AVAILABLE = '#81C784';  // 空闲（薄荷绿）
  static readonly STATUS_CROWDED = '#FF7043';    // 拥挤（珊瑚红）
  static readonly STATUS_CLOSED = '#9E9E9E';     // 关闭（灰色）
  static readonly STATUS_MAINTENANCE = '#FFB74D';// 维修（橙色）
  
  // 文本颜色
  static readonly TEXT_PRIMARY = '#333333';      // 主要文本
  static readonly TEXT_SECONDARY = '#666666';    // 次要文本
  static readonly TEXT_HINT = '#999999';         // 提示文本
  static readonly TEXT_WHITE = '#FFFFFF';        // 白色文本
  
  // 分割线和头像
  static readonly DIVIDER = '#E0E0E0';           // 分割线
  static readonly AVATAR_BG = '#FFE082';         // 头像背景
  
  // 功能色块（设置页、我的页）
  static readonly BLOCK_ORANGE = '#FFB74D';      // 橙色块
  static readonly BLOCK_YELLOW = '#FFD54F';      // 黄色块
  static readonly BLOCK_GREEN = '#81C784';       // 绿色块
  static readonly BLOCK_BLUE = '#64B5F6';        // 蓝色块
  static readonly BLOCK_PURPLE = '#BA68C8';      // 紫色块
  static readonly BLOCK_RED = '#E57373';         // 红色块
  static readonly BLOCK_GRAY = '#BDBDBD';        // 灰色块
  
  // 渐变色
  static readonly GRADIENT_PRIMARY = 'linear-gradient(135deg, #FFD700, #FFA000)';
  static readonly GRADIENT_CARD = 'linear-gradient(135deg, #FFF9E6, #FFECB3)';
  static readonly GRADIENT_AVAILABLE = 'linear-gradient(135deg, #81C784, #66BB6A)';
  static readonly GRADIENT_CROWDED = 'linear-gradient(135deg, #FF7043, #FF5722)';
  
  // 阴影色
  static readonly SHADOW_LIGHT = 'rgba(0, 0, 0, 0.08)';
  static readonly SHADOW_MEDIUM = 'rgba(0, 0, 0, 0.15)';
  static readonly SHADOW_HEAVY = 'rgba(0, 0, 0, 0.25)';
  
  // 地图相关（简洁模式）
  static readonly MAP_BG = '#FFF9E6';            // 地图背景（奶油黄）
  static readonly MAP_ROAD = '#FFE5B4';          // 道路颜色（淡黄）
  static readonly MAP_BUILDING = '#FFEFD5';      // 建筑颜色（淡橙）
  static readonly MAP_WATER = '#B3E5FC';         // 水体颜色（浅蓝）
  static readonly MAP_GREEN = '#C8E6C9';         // 绿地颜色（浅绿）
  static readonly MAP_LABEL = '#8B7355';         // 标签颜色（棕色）
}

export { AppColors as Colors };
