/**
 * 应用配置接口定义
 * 用于定义配置文件的TypeScript类型,确保类型安全
 */

/**
 * 应用基本信息
 */
export interface AppInfo {
  appName: string;          // 应用名称
  appId: string;            // 应用唯一标识
  version: string;          // 版本号
  description: string;      // 应用描述
}

/**
 * 任务类型配置
 */
export interface TaskTypeConfig {
  id: number;               // 任务类型ID
  name: string;             // 任务名称
  icon: string;             // 图标资源名称
  unit: string;             // 单位(如: 杯, 分钟, 次)
  targetValue: number;      // 默认目标值
  step: number;             // 步进值
  isTimeBased: boolean;     // 是否基于时间(如21天打卡)
}

/**
 * 主题配置
 */
export interface ThemeConfig {
  primaryColor: string;         // 主色调
  primaryDark?: string;         // 主色调深色(可选)
  primaryLight?: string;        // 主色调浅色(可选)
  accentColor: string;          // 强调色
  backgroundColor: string;      // 背景色
  surfaceColor?: string;        // 表面色(可选)
  surfaceVariant?: string;      // 表面变体色(可选)
  cardBackgroundColor: string;  // 卡片背景色
  outlineColor?: string;        // 轮廓色(可选)
  textPrimaryColor: string;     // 主要文字颜色
  textSecondaryColor: string;   // 次要文字颜色
  textDisabledColor?: string;   // 禁用文字颜色(可选)
  successColor: string;         // 成功状态颜色
  warningColor: string;         // 警告状态颜色
  errorColor: string;           // 错误状态颜色
  infoColor?: string;           // 信息状态颜色(可选)
  taskColors?: Record<string, string>;  // 任务颜色(可选)
}

/**
 * 字体尺寸配置
 */
export interface FontSizeConfig {
  xs?: number;        // 超小(可选)
  sm?: number;        // 小(可选)
  small?: number;     // 小(旧版)
  base?: number;      // 基础(可选)
  normal?: number;    // 正常(旧版)
  lg?: number;        // 大(可选)
  large?: number;     // 大(旧版)
  xl?: number;        // 超大(可选)
  xxl?: number;       // 超超大(可选)
  xxxl?: number;      // 超超超大(可选)
  title?: number;     // 标题(旧版)
}

/**
 * 间距配置
 */
export interface SpacingConfig {
  xs?: number;
  sm?: number;
  md?: number;
  base?: number;
  lg?: number;
  xl?: number;
  xxl?: number;
  xxxl?: number;
}

/**
 * 圆角配置
 */
export interface BorderRadiusConfig {
  sm?: number;
  md?: number;
  lg?: number;
  xl?: number;
  xxl?: number;
  round?: number;
}

/**
 * 图标尺寸配置
 */
export interface IconSizeConfig {
  sm?: number;
  base?: number;
  lg?: number;
  xl?: number;
}

/**
 * UI配置
 */
export interface UIConfig {
  cardBorderRadius: number;     // 卡片圆角
  cardPadding: number;          // 卡片内边距
  spacing?: number | SpacingConfig;  // 标准间距(兼容旧版number或新版对象)
  iconSize?: number | IconSizeConfig;  // 图标尺寸(兼容旧版number或新版对象)
  fontSize: FontSizeConfig;
  borderRadius?: BorderRadiusConfig;   // 圆角配置(新增)
}

/**
 * 数据库配置
 */
export interface DatabaseConfig {
  dbName: string;               // 数据库名称
  version: number;              // 数据库版本
  tableName: string;            // 主表名
}

/**
 * 功能开关配置
 */
export interface FeatureFlags {
  enableDataAnalytics: boolean;     // 启用数据统计
  enableAchievements: boolean;      // 启用成就系统
  enableCalendar: boolean;          // 启用日历视图
  enableReminders: boolean;         // 启用智能提醒
  enableThemeCustomization: boolean; // 启用主题自定义
  enableDataExport: boolean;        // 启用数据导出
  enableSocialSharing: boolean;     // 启用社交分享
}

/**
 * 完整应用配置
 */
export interface AppConfigData {
  app: AppInfo;
  theme: ThemeConfig;
  ui: UIConfig;
  database: DatabaseConfig;
  taskTypes: TaskTypeConfig[];
  features: FeatureFlags;
}

/**
 * 全局配置单例
 */
export class AppConfig {
  private static instance: AppConfig;
  private configData: AppConfigData | null = null;

  private constructor() {}

  /**
   * 获取配置实例
   */
  public static getInstance(): AppConfig {
    if (!AppConfig.instance) {
      AppConfig.instance = new AppConfig();
    }
    return AppConfig.instance;
  }

  /**
   * 设置配置数据
   */
  public setConfig(config: AppConfigData): void {
    this.configData = config;
  }

  /**
   * 获取配置数据
   */
  public getConfig(): AppConfigData {
    if (!this.configData) {
      throw new Error('配置未初始化,请先调用 ConfigLoader.load()');
    }
    return this.configData;
  }

  /**
   * 获取应用信息
   */
  public get app(): AppInfo {
    return this.getConfig().app;
  }

  /**
   * 获取主题配置
   */
  public get theme(): ThemeConfig {
    return this.getConfig().theme;
  }

  /**
   * 获取UI配置
   */
  public get ui(): UIConfig {
    return this.getConfig().ui;
  }

  /**
   * 获取数据库配置
   */
  public get database(): DatabaseConfig {
    return this.getConfig().database;
  }

  /**
   * 获取任务类型列表
   */
  public get taskTypes(): TaskTypeConfig[] {
    return this.getConfig().taskTypes;
  }

  /**
   * 获取功能开关
   */
  public get features(): FeatureFlags {
    return this.getConfig().features;
  }

  /**
   * 根据ID获取任务类型
   */
  public getTaskTypeById(id: number): TaskTypeConfig | undefined {
    return this.taskTypes.find(task => task.id === id);
  }

  /**
   * 将配置文件中的图标名称转换为Resource引用
   * @param iconName 图标名称,如 "getup_task_icon"
   * @returns Resource引用
   */
  public getIconResource(iconName: string): Resource {
    // 图标名称映射表
    const iconMap: Record<string, string> = {
      'getup_task_icon': 'ic_task_morning',
      'drink_task_icon': 'ic_task_water',
      'apple_task_icon': 'ic_task_apple',
      'smile_task_icon': 'ic_task_smile',
      'brushTeeth_task_icon': 'ic_task_brush',
      'sleep_task_icon': 'ic_task_night',
      // 学习主题图标(如有需要可补充)
      'study_task_icon': 'ic_task_morning',
      'homework_task_icon': 'ic_task_water',
    };

    const mediaName = iconMap[iconName] || 'ic_task_morning'; // 默认图标
    return $r(`app.media.${mediaName}`);
  }
}
