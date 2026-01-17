/**
 * ThemeManager - 主题管理器
 * 支持浅色/深色/跟随系统三种主题模式
 * 
 * 使用方式:
 * 1. 在应用启动时初始化: ThemeManager.getInstance()
 * 2. 在组件中获取颜色: ThemeManager.getInstance().colors.background
 * 3. 切换主题: ThemeManager.getInstance().setThemeMode('dark')
 */

import preferences from '@ohos.data.preferences';

// 主题模式类型
export enum ThemeMode {
  LIGHT = 'light',      // 浅色
  DARK = 'dark',        // 深色
  AUTO = 'auto'         // 跟随系统
}

// 主题颜色配置接口
export interface ThemeColors {
  // 基础背景
  background: string;           // 页面背景色
  cardBackground: string;       // 卡片背景色
  surfaceBackground: string;    // 表面背景（如顶栏）
  
  // 文字颜色
  textPrimary: string;          // 主要文字
  textSecondary: string;        // 次要文字
  textHint: string;             // 提示文字
  
  // 主题色
  primaryColor: string;         // 主色（蓝色）
  primaryLight: string;         // 浅主色
  primaryDark: string;          // 深主色
  
  // 功能色
  successColor: string;         // 成功（绿色）
  warningColor: string;         // 警告（橙色）
  errorColor: string;           // 错误（红色）
  
  // 分割线和边框
  dividerColor: string;         // 分割线
  borderColor: string;          // 边框
  
  // 阴影
  shadowColor: string;          // 阴影颜色
}

// 浅色主题配置
const LIGHT_THEME: ThemeColors = {
  background: '#F8F9FA',
  cardBackground: '#FFFFFF',
  surfaceBackground: '#FFFFFF',
  
  textPrimary: '#212121',
  textSecondary: '#616161',
  textHint: '#9E9E9E',
  
  primaryColor: '#2196F3',
  primaryLight: '#64B5F6',
  primaryDark: '#1976D2',
  
  successColor: '#4CAF50',
  warningColor: '#FF9800',
  errorColor: '#F44336',
  
  dividerColor: '#E0E0E0',
  borderColor: '#BDBDBD',
  
  shadowColor: 'rgba(0, 0, 0, 0.1)'
};

// 深色主题配置（根据你的截图设计）
const DARK_THEME: ThemeColors = {
  background: '#000000',        // 纯黑背景
  cardBackground: '#1C1C1E',    // 深灰卡片
  surfaceBackground: '#1C1C1E', // 深灰表面
  
  textPrimary: '#FFFFFF',       // 白色主文字
  textSecondary: '#8E8E93',     // 灰色次文字
  textHint: '#636366',          // 深灰提示
  
  primaryColor: '#0A84FF',      // iOS风格深色蓝
  primaryLight: '#409EFF',
  primaryDark: '#0066CC',
  
  successColor: '#32D74B',      // iOS风格深色绿
  warningColor: '#FF9F0A',      // iOS风格深色橙
  errorColor: '#FF453A',        // iOS风格深色红
  
  dividerColor: '#38383A',      // 深色分割线
  borderColor: '#48484A',       // 深色边框
  
  shadowColor: 'rgba(0, 0, 0, 0.3)'
};

/**
 * 主题管理器单例类
 */
export class ThemeManager {
  private static instance: ThemeManager | null = null;
  private themeMode: ThemeMode = ThemeMode.AUTO;
  private _colors: ThemeColors = LIGHT_THEME;
  private preferencesKey: string = 'theme_mode';

  private constructor() {
    this.loadThemePreference();
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): ThemeManager {
    if (!ThemeManager.instance) {
      ThemeManager.instance = new ThemeManager();
    }
    return ThemeManager.instance;
  }

  /**
   * 获取当前主题颜色配置
   */
  public get colors(): ThemeColors {
    return this._colors;
  }

  /**
   * 获取当前主题模式
   */
  public getThemeMode(): ThemeMode {
    return this.themeMode;
  }

  /**
   * 获取主题模式的显示名称
   */
  public getThemeModeName(): string {
    switch (this.themeMode) {
      case ThemeMode.LIGHT:
        return '浅色';
      case ThemeMode.DARK:
        return '深色';
      case ThemeMode.AUTO:
        return '跟随系统';
      default:
        return '跟随系统';
    }
  }

  /**
   * 设置主题模式
   * @param mode 主题模式
   */
  public setThemeMode(mode: ThemeMode): void {
    this.themeMode = mode;
    this.updateColors();
    this.saveThemePreference();
  }

  /**
   * 更新颜色配置
   */
  private updateColors(): void {
    if (this.themeMode === ThemeMode.DARK) {
      this._colors = DARK_THEME;
    } else if (this.themeMode === ThemeMode.LIGHT) {
      this._colors = LIGHT_THEME;
    } else {
      // AUTO模式：检测系统主题（TODO: 实现系统主题检测）
      // 暂时默认使用浅色
      this._colors = LIGHT_THEME;
    }
  }

  /**
   * 加载主题偏好设置
   */
  private async loadThemePreference(): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(getContext(), 'theme_settings');
      const savedMode = await prefs.get(this.preferencesKey, ThemeMode.AUTO) as string;
      this.themeMode = savedMode as ThemeMode;
      this.updateColors();
    } catch (error) {
      console.error('[ThemeManager] 加载主题设置失败:', error);
      this.themeMode = ThemeMode.AUTO;
      this.updateColors();
    }
  }

  /**
   * 保存主题偏好设置
   */
  private async saveThemePreference(): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(getContext(), 'theme_settings');
      await prefs.put(this.preferencesKey, this.themeMode);
      await prefs.flush();
      console.info('[ThemeManager] 主题设置已保存:', this.themeMode);
    } catch (error) {
      console.error('[ThemeManager] 保存主题设置失败:', error);
    }
  }
}
