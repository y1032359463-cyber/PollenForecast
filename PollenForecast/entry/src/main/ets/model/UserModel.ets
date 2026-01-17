/**
 * 用户档案模型
 * 定义用户过敏信息和设置
 */

/**
 * 过敏程度枚举
 */
export enum AllergyLevel {
  NONE = 0,       // 无过敏
  MILD = 1,       // 轻度
  MODERATE = 2,   // 中度
  SEVERE = 3      // 重度
}

/**
 * 用户过敏档案
 */
export interface UserAllergyProfile {
  userId: string;                    // 用户ID
  allergyLevel: AllergyLevel;        // 整体过敏程度
  allergenTypes: string[];           // 过敏原类型列表
  hasAsthma: boolean;                // 是否有哮喘
  hasRhinitis: boolean;              // 是否有鼻炎
  age?: number;                      // 年龄
  medications?: string[];            // 常用药物
  createdAt: string;                 // 创建时间
  updatedAt: string;                 // 更新时间
}

/**
 * 预警设置
 */
export interface AlertSettings {
  enabled: boolean;                  // 是否启用预警
  threshold: number;                 // 触发阈值 (1-5)
  notifyTime: string;                // 每日通知时间 HH:mm
  notifyMethods: NotifyMethod[];     // 通知方式
}

/**
 * 通知方式
 */
export enum NotifyMethod {
  PUSH = 'push',           // 推送通知
  WIDGET = 'widget',       // 卡片更新
  WATCH = 'watch',         // 手表提醒
  SOUND = 'sound'          // 声音提醒
}

/**
 * 用户设置
 */
export interface UserSettings {
  alertSettings: AlertSettings;      // 预警设置
  theme: 'light' | 'dark' | 'auto';  // 主题模式
  unit: 'metric' | 'imperial';       // 单位制
  language: string;                  // 语言
  autoLocation: boolean;             // 自动定位
  savedLocations: string[];          // 收藏的城市
}

/**
 * 获取过敏程度描述
 */
export function getAllergyLevelText(level: AllergyLevel): string {
  switch (level) {
    case AllergyLevel.NONE:
      return '无过敏';
    case AllergyLevel.MILD:
      return '轻度过敏';
    case AllergyLevel.MODERATE:
      return '中度过敏';
    case AllergyLevel.SEVERE:
      return '重度过敏';
    default:
      return '未设置';
  }
}

/**
 * 计算个性化风险系数
 * 根据用户过敏档案调整风险评估
 */
export function calculateRiskFactor(profile: UserAllergyProfile): number {
  let factor = 1.0;

  // 过敏程度影响
  switch (profile.allergyLevel) {
    case AllergyLevel.MILD:
      factor *= 1.2;
      break;
    case AllergyLevel.MODERATE:
      factor *= 1.5;
      break;
    case AllergyLevel.SEVERE:
      factor *= 2.0;
      break;
  }

  // 哮喘患者风险更高
  if (profile.hasAsthma) {
    factor *= 1.3;
  }

  // 鼻炎患者风险更高
  if (profile.hasRhinitis) {
    factor *= 1.2;
  }

  // 年龄因素（儿童和老人更敏感）
  if (profile.age) {
    if (profile.age < 12 || profile.age > 65) {
      factor *= 1.15;
    }
  }

  return factor;
}
