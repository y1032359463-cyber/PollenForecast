/**
 * Retro Pixel Theme Configuration
 * 经典卡西欧计算器风格主题配置
 * 
 * 设计理念：致敬80年代卡西欧计算器
 * - 青绿色液晶屏效果
 * - 深灰色机身外壳
 * - 米白色按键区域
 * - 红色AC清除键
 */

export class RetroPixelTheme {
  // ==================== 卡西欧计算器经典配色 ====================
  
  /** 主色：青绿（液晶屏背景）*/
  static readonly COLOR_PRIMARY: string = '#7FA99B';
  
  /** 次色：深青绿（液晶数字）*/
  static readonly COLOR_SECONDARY: string = '#1A3A36';
  
  /** 暗色：深灰（按键）*/
  static readonly COLOR_DARK: string = '#3D3D3D';
  
  /** 背景色：深灰（机身外壳）*/
  static readonly COLOR_BACKGROUND: string = '#4A4A4A';
  
  /** 外壳色：米白（按键区域背景）*/
  static readonly COLOR_SHELL: string = '#E8DCC8';
  
  /** 按钮色：深灰（普通按键）*/
  static readonly COLOR_BUTTON: string = '#3D3D3D';
  
  /** 红色键：AC清除键 */
  static readonly COLOR_RED_KEY: string = '#C84444';
  
  // ==================== 数字显示颜色（液晶屏效果）====================
  
  /** 数字颜色：深青绿（液晶数字）*/
  static readonly COLOR_DIGIT: string = '#1A3A36';
  
  /** 运算符颜色：深青绿 */
  static readonly COLOR_OPERATOR: string = '#1A3A36';
  
  /** 结果颜色：深青绿 */
  static readonly COLOR_RESULT: string = '#1A3A36';
  
  /** 错误颜色：红色 */
  static readonly COLOR_ERROR: string = '#C84444';
  
  // ==================== 按键映射配置 ====================
  
  /** 数字按键颜色（深灰+白字） */
  static readonly BUTTON_NUMBER_BG: string = '#3D3D3D';
  static readonly BUTTON_NUMBER_TEXT: string = '#FFFFFF';
  
  /** 运算符按键颜色（深灰+白字） */
  static readonly BUTTON_OPERATOR_BG: string = '#3D3D3D';
  static readonly BUTTON_OPERATOR_TEXT: string = '#FFFFFF';
  
  /** 等号按键颜色（深灰+白字）*/
  static readonly BUTTON_EQUAL_BG: string = '#3D3D3D';
  static readonly BUTTON_EQUAL_TEXT: string = '#FFFFFF';
  
  /** 清除按键颜色（红色AC键）*/
  static readonly BUTTON_CLEAR_BG: string = '#C84444';
  static readonly BUTTON_CLEAR_TEXT: string = '#FFFFFF';
  
  // ==================== 字体配置 ====================
  
  /** 主字体：Press Start 2P（经典像素字体）*/
  static readonly FONT_PRIMARY: string = 'PressStart2P-Regular';
  
  /** 备用字体：VT323（终端风格字体）*/
  static readonly FONT_SECONDARY: string = 'VT323-Regular';
  
  /** 字体路径前缀 */
  static readonly FONT_PATH: string = 'rawfile/fonts/';
  
  // ==================== 角色资源路径 ====================
  
  static readonly CHARACTER_PATH: string = 'rawfile/characters/';
  
  /** 角色状态资源映射 */
  static readonly CHARACTER_STATES: Record<string, string> = {
    'IDLE': 'pixel_character_idle.png',
    'THINKING': 'pixel_character_thinking.png',
    'CELEBRATE': 'pixel_character_celebrate.png',
    'ERROR': 'pixel_character_error.png'
  } as Record<string, string>;
  
  // ==================== 音效资源路径 ====================
  
  static readonly AUDIO_PATH: string = 'rawfile/audio/';
  
  /** 音效资源映射 */
  static readonly AUDIO_EFFECTS: Record<string, string> = {
    'BUTTON_PRESS': 'sfx_button_press.wav',        // 按键音效
    'CALCULATE_SUCCESS': 'sfx_calculate_success.mp3', // 计算成功
    'CLEAR': 'sfx_clear.mp3',                       // 清除
    'DELETE': 'sfx_delete.wav',                     // 删除
    'ERROR': 'sfx_error.wav'                        // 错误
  } as Record<string, string>;
  
  // ==================== 背景资源路径 ====================
  
  static readonly BACKGROUND_PATH: string = 'rawfile/backgrounds/';
  
  /** 背景资源映射 */
  static readonly BACKGROUNDS: Record<string, string> = {
    'MAIN': 'background.png',           // 主背景
    'FOREGROUND': 'foreground.png',     // 前景装饰
    'TILEMAP': 'tilemap.png'            // 像素城市tilemap
  } as Record<string, string>;
  
  // ==================== UI尺寸配置 ====================
  
  /** 按键圆角（像素化效果，圆角较小）*/
  static readonly BUTTON_RADIUS: number = 4;
  
  /** 按键间距 */
  static readonly BUTTON_SPACING: number = 8;
  
  /** 按键高度 */
  static readonly BUTTON_HEIGHT: number = 56;
  
  /** 显示屏圆角 */
  static readonly DISPLAY_RADIUS: number = 8;
  
  /** 显示屏边框宽度 */
  static readonly DISPLAY_BORDER: number = 3;
  
  // ==================== 动画配置 ====================
  
  /** 按键按下动画时长（ms）*/
  static readonly BUTTON_PRESS_DURATION: number = 100;
  
  /** 角色切换动画时长（ms）*/
  static readonly CHARACTER_SWITCH_DURATION: number = 200;
  
  /** 液晶屏闪烁效果间隔（ms）*/
  static readonly SCREEN_BLINK_INTERVAL: number = 300;
  
  // ==================== 工具方法 ====================
  
  /**
   * 获取完整的字体路径
   * @param fontName 字体文件名（不含路径）
   * @returns 完整的字体资源路径
   */
  static getFontPath(fontName: string): string {
    return RetroPixelTheme.FONT_PATH + fontName + '.ttf';
  }
  
  /**
   * 获取完整的角色资源路径
   * @param state 角色状态（IDLE/THINKING/CELEBRATE/ERROR）
   * @returns 完整的角色资源路径
   */
  static getCharacterPath(state: 'IDLE' | 'THINKING' | 'CELEBRATE' | 'ERROR'): string {
    const fileName = RetroPixelTheme.CHARACTER_STATES[state];
    return RetroPixelTheme.CHARACTER_PATH + fileName;
  }
  
  /**
   * 获取完整的音效资源路径
   * @param effect 音效类型
   * @returns 完整的音效资源路径
   */
  static getAudioPath(effect: 'BUTTON_PRESS' | 'CALCULATE_SUCCESS' | 'CLEAR' | 'DELETE' | 'ERROR'): string {
    const fileName = RetroPixelTheme.AUDIO_EFFECTS[effect];
    return RetroPixelTheme.AUDIO_PATH + fileName;
  }
  
  /**
   * 获取完整的背景资源路径
   * @param bg 背景类型
   * @returns 完整的背景资源路径
   */
  static getBackgroundPath(bg: 'MAIN' | 'FOREGROUND' | 'TILEMAP'): string {
    const fileName = RetroPixelTheme.BACKGROUNDS[bg];
    return RetroPixelTheme.BACKGROUND_PATH + fileName;
  }
}
