/*
 * ThemeManager - 主题管理工具类
 * 支持多种主题切换
 */

import PreferencesUtils from './PreferencesUtils';

/**
 * 主题类型枚举
 */
export enum ThemeType {
  DEFAULT = 'default',      // 默认主题（橙粉色调）
  BLUE = 'blue',            // 蓝色主题
  GREEN = 'green',          // 绿色主题
  PURPLE = 'purple',        // 紫色主题
  YELLOW = 'yellow'         // 黄色主题
}

/**
 * 主题配置接口
 */
export interface ThemeConfig {
  type: ThemeType;          // 主题类型
  name: string;             // 主题名称
  bgMain: string;           // 主背景色
  bgCard: string;           // 卡片背景色
  primaryColor: string;     // 主色调
  textPrimary: string;      // 主文字色
  btnNormal: string;        // 数字按钮色
  btnOperator: string;      // 运算符按钮色
  btnEqual: string;         // 等号按钮色
}

/**
 * 主题管理工具类
 */
export class ThemeManager {
  // 主题配置映射
  private static readonly THEME_CONFIGS: Map<ThemeType, ThemeConfig> = new Map<ThemeType, ThemeConfig>([
    [
      ThemeType.DEFAULT,
      {
        type: ThemeType.DEFAULT,
        name: '默认主题',
        bgMain: '#FFD4A3',
        bgCard: '#FFFFFF',
        primaryColor: '#FF8C42',
        textPrimary: '#C17735',
        btnNormal: '#FFE8CC',
        btnOperator: '#FFFFFF',
        btnEqual: '#FF8C42'
      } as ThemeConfig
    ],
    [
      ThemeType.BLUE,
      {
        type: ThemeType.BLUE,
        name: '蓝色主题',
        bgMain: '#E0F7FA',
        bgCard: '#FFFFFF',
        primaryColor: '#00BCD4',
        textPrimary: '#00796B',
        btnNormal: '#B2EBF2',
        btnOperator: '#FFFFFF',
        btnEqual: '#00BCD4'
      } as ThemeConfig
    ],
    [
      ThemeType.GREEN,
      {
        type: ThemeType.GREEN,
        name: '绿色主题',
        bgMain: '#E8F5E8',
        bgCard: '#FFFFFF',
        primaryColor: '#4CAF50',
        textPrimary: '#2E7D32',
        btnNormal: '#C8E6C9',
        btnOperator: '#FFFFFF',
        btnEqual: '#4CAF50'
      } as ThemeConfig
    ],
    [
      ThemeType.PURPLE,
      {
        type: ThemeType.PURPLE,
        name: '紫色主题',
        bgMain: '#F3E5F5',
        bgCard: '#FFFFFF',
        primaryColor: '#9C27B0',
        textPrimary: '#4A148C',
        btnNormal: '#E1BEE7',
        btnOperator: '#FFFFFF',
        btnEqual: '#9C27B0'
      } as ThemeConfig
    ],
    [
      ThemeType.YELLOW,
      {
        type: ThemeType.YELLOW,
        name: '黄色主题',
        bgMain: '#FFF8E1',
        bgCard: '#FFFFFF',
        primaryColor: '#FFC107',
        textPrimary: '#FF8F00',
        btnNormal: '#FFECB3',
        btnOperator: '#FFFFFF',
        btnEqual: '#FFC107'
      } as ThemeConfig
    ]
  ]);

  /**
   * 获取当前主题
   * @param isDarkMode 是否为深色模式（可选，不传则从系统获取）
   */
  static async getCurrentTheme(isDarkMode?: boolean): Promise<ThemeConfig> {
    const themeType = await PreferencesUtils.getThemeType();
    let config = ThemeManager.THEME_CONFIGS.get(themeType as ThemeType) || ThemeManager.THEME_CONFIGS.get(ThemeType.DEFAULT)!;
    
    // 如果指定了深色模式，返回对应的深色主题配置
    if (isDarkMode) {
      // 为当前主题创建深色版本（ArkTS不支持展开运算符，逐个赋值）
      const darkConfig: ThemeConfig = {
        type: config.type,
        name: config.name,
        bgMain: '#2C2C2E',          // 深色主背景
        bgCard: '#3A3A3C',          // 深色卡片背景
        primaryColor: config.primaryColor,
        textPrimary: '#FFB366',     // 深色文字（提高对比度）
        btnNormal: '#48484A',       // 深色数字按钮
        btnOperator: '#5A5A5C',     // 深色运算符按钮
        btnEqual: config.btnEqual
      };
      return darkConfig;
    }
    
    return config;
  }

  /**
   * 设置主题
   */
  static async setTheme(themeType: ThemeType): Promise<void> {
    await PreferencesUtils.setThemeType(themeType);
  }

  /**
   * 获取所有主题
   */
  static getAllThemes(): ThemeConfig[] {
    return Array.from(ThemeManager.THEME_CONFIGS.values());
  }

  /**
   * 获取主题名称
   */
  static getThemeName(themeType: ThemeType): string {
    return ThemeManager.THEME_CONFIGS.get(themeType)?.name || '默认主题';
  }
}