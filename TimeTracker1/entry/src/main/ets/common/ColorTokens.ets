/**
 * 颜色规范 - 确保良好的文本对比度和可读性
 * 
 * WCAG 2.1 标准：
 * - AA级别（正常文本）：对比度至少 4.5:1
 * - AA级别（大文本）：对比度至少 3:1
 * - AAA级别（正常文本）：对比度至少 7:1
 */

export class ColorTokens {
  // ========== 主色调 ==========
  /** 主要品牌色 - 蓝色 */
  static readonly PRIMARY_BLUE: string = '#2196F3'
  
  /** 主要品牌色 - 深蓝（悬停/按压状态） */
  static readonly PRIMARY_BLUE_DARK: string = '#1976D2'
  
  /** 主要品牌色 - 浅蓝（背景） */
  static readonly PRIMARY_BLUE_LIGHT: string = '#E3F2FD'

  // ========== 文本颜色（白色背景） ==========
  /** 主要文本 - 深灰黑（白色背景上对比度 15.8:1） */
  static readonly TEXT_PRIMARY: string = '#212121'
  
  /** 次要文本 - 中灰（白色背景上对比度 7.0:1，满足AAA级） */
  static readonly TEXT_SECONDARY: string = '#616161'
  
  /** 提示文本 - 灰色（白色背景上对比度 4.6:1，满足AA级） */
  static readonly TEXT_HINT: string = '#757575'
  
  /** 禁用文本 - 浅灰（白色背景上对比度 3.2:1） */
  static readonly TEXT_DISABLED: string = '#9E9E9E'

  // ========== 文本颜色（深色背景） ==========
  /** 深色背景上的白色文本 */
  static readonly TEXT_ON_DARK: string = '#FFFFFF'
  
  /** 深色背景上的次要文本（95%不透明度） */
  static readonly TEXT_ON_DARK_SECONDARY: string = '#FFFFFF'
  static readonly TEXT_ON_DARK_SECONDARY_OPACITY: number = 0.95

  // ========== 背景颜色 ==========
  /** 主背景 - 纯白 */
  static readonly BACKGROUND_PRIMARY: string = '#FFFFFF'
  
  /** 次要背景 - 极浅灰 */
  static readonly BACKGROUND_SECONDARY: string = '#F8F9FA'
  
  /** 输入框背景 - 浅灰 */
  static readonly BACKGROUND_INPUT: string = '#F5F5F5'
  
  /** 卡片背景 - 浅灰 */
  static readonly BACKGROUND_CARD: string = '#FAFAFA'

  // ========== 边框颜色 ==========
  /** 默认边框 - 浅灰 */
  static readonly BORDER_DEFAULT: string = '#E0E0E0'
  
  /** 分割线 - 极浅灰 */
  static readonly DIVIDER: string = '#EEEEEE'

  // ========== 状态颜色 ==========
  /** 成功 - 绿色 */
  static readonly SUCCESS: string = '#4CAF50'
  
  /** 警告 - 橙色 */
  static readonly WARNING: string = '#FF9800'
  
  /** 错误 - 红色 */
  static readonly ERROR: string = '#F44336'
  
  /** 信息 - 蓝色 */
  static readonly INFO: string = '#2196F3'

  // ========== 阴影 ==========
  /** 卡片阴影 */
  static readonly SHADOW_LIGHT: string = 'rgba(0,0,0,0.06)'
  
  /** 弹出层阴影 */
  static readonly SHADOW_MEDIUM: string = 'rgba(0,0,0,0.12)'
  
  /** 模态框阴影 */
  static readonly SHADOW_HEAVY: string = 'rgba(0,0,0,0.24)'

  // ========== 工作类型颜色 ==========
  /** 开发 - 蓝色 */
  static readonly WORK_TYPE_DEV: string = '#2196F3'
  
  /** 设计 - 紫色 */
  static readonly WORK_TYPE_DESIGN: string = '#9C27B0'
  
  /** 测试 - 红色 */
  static readonly WORK_TYPE_TEST: string = '#F44336'
  
  /** 会议 - 橙色 */
  static readonly WORK_TYPE_MEETING: string = '#FF9800'
  
  /** 文档 - 绿色 */
  static readonly WORK_TYPE_DOC: string = '#4CAF50'
  
  /** 学习 - 青色 */
  static readonly WORK_TYPE_STUDY: string = '#00BCD4'
  
  /** 调研 - 棕色 */
  static readonly WORK_TYPE_RESEARCH: string = '#795548'
  
  /** 沟通 - 粉色 */
  static readonly WORK_TYPE_COMMUNICATION: string = '#E91E63'
  
  /** 其他 - 灰色 */
  static readonly WORK_TYPE_OTHER: string = '#9E9E9E'
}

/**
 * 使用建议：
 * 
 * 1. 主要标题：
 *    .fontSize(24)
 *    .fontWeight(FontWeight.Bold)
 *    .fontColor(ColorTokens.TEXT_PRIMARY)
 * 
 * 2. 正文文本：
 *    .fontSize(16)
 *    .fontColor(ColorTokens.TEXT_PRIMARY)
 * 
 * 3. 次要说明：
 *    .fontSize(14)
 *    .fontColor(ColorTokens.TEXT_SECONDARY)
 * 
 * 4. 提示文字：
 *    .fontSize(12)
 *    .fontColor(ColorTokens.TEXT_HINT)
 * 
 * 5. 深色背景上的文字：
 *    .fontColor(ColorTokens.TEXT_ON_DARK)
 *    .opacity(ColorTokens.TEXT_ON_DARK_SECONDARY_OPACITY) // 次要文字
 * 
 * 6. 输入框：
 *    .backgroundColor(ColorTokens.BACKGROUND_INPUT)
 *    .fontColor(ColorTokens.TEXT_PRIMARY)
 * 
 * 7. 占位符：
 *    TextInput({ placeholder: '请输入' })
 *      .fontColor(ColorTokens.TEXT_HINT) // 输入后的文字
 */
