/**
 * 样式工具类
 * 提供统一的样式访问接口,基于配置系统
 */

import { AppConfig } from '../config/AppConfig';

export class StyleUtils {
  /**
   * 获取主题颜色
   */
  static getPrimaryColor(): string {
    return AppConfig.getInstance().theme.primaryColor;
  }

  static getPrimaryDarkColor(): string {
    return AppConfig.getInstance().theme.primaryDark || AppConfig.getInstance().theme.primaryColor;
  }

  static getPrimaryLightColor(): string {
    return AppConfig.getInstance().theme.primaryLight || AppConfig.getInstance().theme.primaryColor;
  }

  static getAccentColor(): string {
    return AppConfig.getInstance().theme.accentColor;
  }

  static getBackgroundColor(): string {
    return AppConfig.getInstance().theme.backgroundColor;
  }

  static getSurfaceColor(): string {
    return AppConfig.getInstance().theme.surfaceColor || AppConfig.getInstance().theme.cardBackgroundColor;
  }

  static getCardBackgroundColor(): string {
    return AppConfig.getInstance().theme.cardBackgroundColor;
  }

  static getTextPrimaryColor(): string {
    return AppConfig.getInstance().theme.textPrimaryColor;
  }

  static getTextSecondaryColor(): string {
    return AppConfig.getInstance().theme.textSecondaryColor;
  }

  static getSuccessColor(): string {
    return AppConfig.getInstance().theme.successColor;
  }

  static getWarningColor(): string {
    return AppConfig.getInstance().theme.warningColor;
  }

  static getErrorColor(): string {
    return AppConfig.getInstance().theme.errorColor;
  }

  static getInfoColor(): string {
    return AppConfig.getInstance().theme.infoColor || AppConfig.getInstance().theme.accentColor;
  }

  /**
   * 获取任务颜色
   */
  static getTaskColor(taskType: string): string {
    const taskColors = AppConfig.getInstance().theme.taskColors;
    if (taskColors && taskColors[taskType]) {
      return taskColors[taskType];
    }
    return StyleUtils.getPrimaryColor();
  }

  /**
   * 获取字体大小(支持新旧格式)
   */
  static getFontSize(size: 'xs' | 'sm' | 'base' | 'lg' | 'xl' | 'xxl' | 'xxxl' | 'small' | 'normal' | 'large' | 'title'): number {
    const fontSize = AppConfig.getInstance().ui.fontSize;
    
    // 新格式
    if (size === 'xs' || size === 'sm' || size === 'base' || size === 'lg' || size === 'xl' || size === 'xxl' || size === 'xxxl') {
      return fontSize[size] || 16;
    }
    
    // 旧格式兼容
    const sizeMap: Record<string, string> = {
      'small': 'xs',
      'normal': 'base',
      'large': 'lg',
      'title': 'xl'
    };
    
    const mappedSize = sizeMap[size] || 'base';
    return fontSize[mappedSize] || fontSize[size] || 16;
  }

  /**
   * 获取间距(支持新旧格式)
   */
  static getSpacing(size?: 'xs' | 'sm' | 'md' | 'base' | 'lg' | 'xl' | 'xxl' | 'xxxl'): number {
    const spacing = AppConfig.getInstance().ui.spacing;
    
    // 如果spacing是对象(新格式)
    if (typeof spacing === 'object') {
      if (size) {
        return spacing[size] || spacing['base'] || 16;
      }
      return spacing['base'] || 16;
    }
    
    // 如果spacing是数字(旧格式)
    return spacing as number;
  }

  /**
   * 获取圆角半径
   */
  static getBorderRadius(size?: 'sm' | 'md' | 'lg' | 'xl' | 'xxl' | 'round'): number {
    const borderRadius = AppConfig.getInstance().ui.borderRadius;
    if (borderRadius && size) {
      return borderRadius[size] || borderRadius['md'] || 12;
    }
    return AppConfig.getInstance().ui.cardBorderRadius;
  }

  /**
   * 获取图标大小(支持新旧格式)
   */
  static getIconSize(size?: 'sm' | 'base' | 'lg' | 'xl'): number {
    const iconSize = AppConfig.getInstance().ui.iconSize;
    
    // 如果iconSize是对象(新格式)
    if (typeof iconSize === 'object') {
      if (size) {
        return iconSize[size] || iconSize['base'] || 24;
      }
      return iconSize['base'] || 24;
    }
    
    // 如果iconSize是数字(旧格式)
    return iconSize as number;
  }

  /**
   * 获取卡片圆角
   */
  static getCardBorderRadius(): number {
    return AppConfig.getInstance().ui.cardBorderRadius;
  }

  /**
   * 获取卡片内边距
   */
  static getCardPadding(): number {
    return AppConfig.getInstance().ui.cardPadding;
  }
}

