/**
 * 如厕记录数据模型
 */

/**
 * 如厕类型
 */
export enum RecordType {
  URINE = 'urine',      // 小便
  STOOL = 'stool',      // 大便
  BOTH = 'both'         // 两者都有
}

/**
 * 舒适度评价
 */
export enum ComfortLevel {
  VERY_COMFORTABLE = 5,   // 非常舒适 😊
  COMFORTABLE = 4,        // 舒适 🙂
  NORMAL = 3,            // 一般 😐
  UNCOMFORTABLE = 2,      // 不适 😟
  VERY_UNCOMFORTABLE = 1  // 非常不适 😣
}

/**
 * 如厕记录
 */
export interface ToiletRecord {
  id: string;                    // 记录ID
  userId?: string;               // 用户ID（可选，未登录用户本地存储）
  
  // 时间信息
  recordTime: number;            // 记录时间（时间戳）
  duration: number;              // 用时（秒）
  
  // 位置信息
  toiletId?: string;             // 厕所ID（如果是已知厕所）
  toiletName?: string;           // 厕所名称
  latitude: number;              // 纬度
  longitude: number;             // 经度
  address: string;               // 地址
  
  // 记录详情
  type: RecordType;              // 如厕类型
  comfortLevel: ComfortLevel;    // 舒适度
  rating?: number;               // 对厕所的评分（1-5）
  
  // 备注
  note?: string;                 // 用户备注
  
  // 健康相关（可选）
  hasIssue?: boolean;            // 是否有异常
  issueDescription?: string;     // 异常描述
  
  // 隐私
  isPrivate: boolean;            // 是否私密（不参与统计分享）
  
  // 时间戳
  createdAt: number;             // 创建时间
  syncedAt?: number;             // 同步到云端时间
}

/**
 * 统计数据
 */
export interface RecordStatistics {
  // 时间范围
  startDate: number;
  endDate: number;
  
  // 基础统计
  totalCount: number;            // 总次数
  averageDuration: number;       // 平均时长（秒）
  
  // 舒适度统计
  comfortDistribution: ComfortDistribution;
  
  // 类型统计
  typeDistribution: TypeDistribution;
  
  // 时段统计
  hourDistribution: number[];    // 24小时分布（0-23点）
  
  // 地点统计
  topLocations: TopLocation[];
  
  // 趋势
  dailyCounts: DailyCount[];
}

/**
 * 舒适度分布
 */
export interface ComfortDistribution {
  veryComfortable: number;
  comfortable: number;
  normal: number;
  uncomfortable: number;
  veryUncomfortable: number;
}

/**
 * 类型分布
 */
export interface TypeDistribution {
  urine: number;
  stool: number;
  both: number;
}

/**
 * 高频地点
 */
export interface TopLocation {
  toiletName: string;
  count: number;
}

/**
 * 每日次数
 */
export interface DailyCount {
  date: string;
  count: number;
}

/**
 * 创建默认记录
 */
export function createDefaultRecord(): ToiletRecord {
  return {
    id: `record_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
    recordTime: Date.now(),
    duration: 0,
    latitude: 0,
    longitude: 0,
    address: '',
    type: RecordType.URINE,
    comfortLevel: ComfortLevel.NORMAL,
    isPrivate: false,
    createdAt: Date.now()
  };
}
