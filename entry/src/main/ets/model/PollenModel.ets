/**
 * 花粉数据模型
 * 定义花粉浓度相关的数据结构
 */

/**
 * 花粉浓度等级枚举
 */
export enum PollenLevel {
  VERY_LOW = 1,   // 很低 - 可正常活动
  LOW = 2,        // 低 - 轻度过敏者注意
  MODERATE = 3,   // 中等 - 建议佩戴口罩
  HIGH = 4,       // 高 - 减少户外活动
  VERY_HIGH = 5   // 很高 - 避免外出
}

/**
 * 花粉类型枚举
 */
export enum PollenType {
  TREE = 'tree',       // 树木花粉
  GRASS = 'grass',     // 草类花粉
  WEED = 'weed'        // 杂草花粉
}

/**
 * 花粉数据接口
 */
export interface PollenData {
  level: PollenLevel;           // 浓度等级 1-5
  value: number;                // 浓度数值
  pollenTypes: PollenTypeData[]; // 各类花粉详情
  updateTime: string;           // 更新时间
  location: LocationInfo;       // 位置信息
}

/**
 * 花粉类型详细数据
 */
export interface PollenTypeData {
  type: PollenType;             // 花粉类型
  name: string;                 // 中文名称
  level: PollenLevel;           // 浓度等级
  value: number;                // 浓度数值
  species?: string[];           // 主要植物种类
}

/**
 * 位置信息
 */
export interface LocationInfo {
  city: string;                 // 城市名
  district?: string;            // 区/县
  latitude: number;             // 纬度
  longitude: number;            // 经度
}

/**
 * 花粉预报数据（单日）
 */
export interface PollenForecast {
  date: string;                 // 日期 YYYY-MM-DD
  dayOfWeek: string;            // 星期几
  level: PollenLevel;           // 预测等级
  value: number;                // 预测数值
  highTemp?: number;            // 最高温度
  lowTemp?: number;             // 最低温度
  weather?: string;             // 天气状况
}

/**
 * 防护建议
 */
export interface ProtectionAdvice {
  level: PollenLevel;           // 对应等级
  title: string;                // 建议标题
  description: string;          // 详细描述
  actions: string[];            // 具体行动建议
}

/**
 * 获取等级对应的颜色
 */
export function getLevelColor(level: PollenLevel): string {
  switch (level) {
    case PollenLevel.VERY_LOW:
      return '#4CAF50';  // 绿色
    case PollenLevel.LOW:
      return '#8BC34A';  // 浅绿
    case PollenLevel.MODERATE:
      return '#FFC107';  // 黄色
    case PollenLevel.HIGH:
      return '#FF9800';  // 橙色
    case PollenLevel.VERY_HIGH:
      return '#F44336';  // 红色
    default:
      return '#9E9E9E';  // 灰色
  }
}

/**
 * 获取等级对应的背景色
 */
export function getLevelBgColor(level: PollenLevel): string {
  switch (level) {
    case PollenLevel.VERY_LOW:
      return '#E8F5E9';  // 浅绿背景
    case PollenLevel.LOW:
      return '#F1F8E9';  // 更浅的绿
    case PollenLevel.MODERATE:
      return '#FFF8E1';  // 浅黄背景
    case PollenLevel.HIGH:
      return '#FFF3E0';  // 浅橙背景
    case PollenLevel.VERY_HIGH:
      return '#FFEBEE';  // 浅红背景
    default:
      return '#FAFAFA';  // 浅灰背景
  }
}

/**
 * 获取等级描述文本
 */
export function getLevelText(level: PollenLevel): string {
  switch (level) {
    case PollenLevel.VERY_LOW:
      return '很低';
    case PollenLevel.LOW:
      return '较低';
    case PollenLevel.MODERATE:
      return '中等';
    case PollenLevel.HIGH:
      return '较高';
    case PollenLevel.VERY_HIGH:
      return '很高';
    default:
      return '未知';
  }
}

/**
 * 获取等级对应的表情图标
 */
export function getLevelEmoji(level: PollenLevel): string {
  switch (level) {
    case PollenLevel.VERY_LOW:
      return '😊';
    case PollenLevel.LOW:
      return '🙂';
    case PollenLevel.MODERATE:
      return '😐';
    case PollenLevel.HIGH:
      return '😷';
    case PollenLevel.VERY_HIGH:
      return '🏠';
    default:
      return '❓';
  }
}
