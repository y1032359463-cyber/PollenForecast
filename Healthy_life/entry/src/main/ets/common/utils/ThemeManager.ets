/**
 * 主题管理器
 * 提供5种预设主题
 */

export interface ThemeConfig {
  name: string;
  primaryColor: string;
  secondaryColor: string;
  backgroundColor: string;
  textColor: string;
  icon: string;
}

/**
 * 预设主题列表
 */
export const THEMES: ThemeConfig[] = [
  {
    name: '健康绿',
    primaryColor: '#4CAF50',
    secondaryColor: '#81C784',
    backgroundColor: '#E8F5E9',
    textColor: '#1B5E20',
    icon: '🌿'
  },
  {
    name: '活力橙',
    primaryColor: '#FF6B35',
    secondaryColor: '#FF8C61',
    backgroundColor: '#FFF3E0',
    textColor: '#E65100',
    icon: '🔥'
  },
  {
    name: '宁静蓝',
    primaryColor: '#2196F3',
    secondaryColor: '#64B5F6',
    backgroundColor: '#E3F2FD',
    textColor: '#0D47A1',
    icon: '💙'
  },
  {
    name: '冥想紫',
    primaryColor: '#9C27B0',
    secondaryColor: '#BA68C8',
    backgroundColor: '#F3E5F5',
    textColor: '#4A148C',
    icon: '🔮'
  },
  {
    name: '阅读青',
    primaryColor: '#00BCD4',
    secondaryColor: '#4DD0E1',
    backgroundColor: '#E0F7FA',
    textColor: '#006064',
    icon: '📘'
  }
];

/**
 * 主题管理器单例
 */
export class ThemeManager {
  private static instance: ThemeManager;
  private currentTheme: ThemeConfig = THEMES[0];

  private constructor() {}

  static getInstance(): ThemeManager {
    if (!ThemeManager.instance) {
      ThemeManager.instance = new ThemeManager();
    }
    return ThemeManager.instance;
  }

  /**
   * 获取当前主题
   */
  getCurrentTheme(): ThemeConfig {
    return this.currentTheme;
  }

  /**
   * 设置主题
   */
  setTheme(index: number) {
    if (index >= 0 && index < THEMES.length) {
      this.currentTheme = THEMES[index];
      AppStorage.setOrCreate('current_theme', index);
      
      // 触发全局刷新通知
      const current = AppStorage.get<number>('theme_updated') || 0;
      AppStorage.setOrCreate('theme_updated', current + 1);
    }
  }

  /**
   * 从持久化存储加载主题
   */
  loadTheme() {
    const themeIndex = AppStorage.get<number>('current_theme');
    if (themeIndex !== undefined && themeIndex >= 0 && themeIndex < THEMES.length) {
      this.currentTheme = THEMES[themeIndex];
    }
  }

  /**
   * 获取所有主题
   */
  getAllThemes(): ThemeConfig[] {
    return THEMES;
  }
}
