/**
 * 用户信息数据模型
 */

/**
 * 用户信息
 */
export interface User {
  id: string;                    // 用户ID
  phone?: string;                // 手机号（脱敏显示）
  nickname?: string;             // 昵称
  avatar?: string;               // 头像URL
  
  // 成就
  achievements: Achievement[];   // 获得的成就
  
  // 统计
  stats: UserStats;              // 用户统计数据
  
  // 设置
  settings: UserSettings;        // 用户设置
  
  // 时间
  createdAt: number;             // 注册时间
  lastLoginAt: number;           // 最后登录时间
}

/**
 * 成就类型
 */
export enum AchievementType {
  EXPLORER = 'explorer',         // 探险家（打卡厕所数量）
  REVIEWER = 'reviewer',         // 评论员（评价数量）
  CONTRIBUTOR = 'contributor',   // 贡献者（上报厕所数量）
  RECORDER = 'recorder'          // 记录者（记录天数）
}

/**
 * 成就
 */
export interface Achievement {
  type: AchievementType;
  level: number;                 // 等级（1-5）
  progress: number;              // 当前进度
  target: number;                // 目标值
  unlockedAt?: number;           // 解锁时间
}

/**
 * 用户统计数据
 */
export interface UserStats {
  // 厕所相关
  checkedToilets: number;        // 打卡的厕所数量
  favoriteToilets: number;       // 收藏的厕所数量
  contributedToilets: number;    // 贡献的厕所数量
  
  // 评价相关
  reviewCount: number;           // 评价数量
  usefulReviewCount: number;     // 被认为有用的评价数量
  
  // 记录相关
  recordCount: number;           // 如厕记录总数
  recordDays: number;            // 记录天数
  
  // 里程
  totalDistance: number;         // 总导航距离（米）
}

/**
 * 用户设置
 */
export interface UserSettings {
  // 界面设置
  theme: 'light' | 'dark' | 'auto';        // 主题
  mapLayer: string;                         // 默认地图图层
  
  // 定位设置
  locationPrecision: 'precise' | 'approximate'; // 定位精度
  autoLocation: boolean;                    // 自动定位
  
  // 通知设置
  enableNotifications: boolean;             // 启用通知
  habitReminder: boolean;                   // 习惯提醒
  reminderTime?: string;                    // 提醒时间（HH:mm）
  
  // 隐私设置
  recordEncryption: boolean;                // 记录数据加密
  cloudBackup: boolean;                     // 云端备份
  shareStatistics: boolean;                 // 共享匿名统计数据
  
  // 其他
  language: string;                         // 语言（'zh-CN' / 'en-US'）
}

/**
 * 创建默认用户
 */
export function createDefaultUser(): User {
  return {
    id: `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
    achievements: [],
    stats: {
      checkedToilets: 0,
      favoriteToilets: 0,
      contributedToilets: 0,
      reviewCount: 0,
      usefulReviewCount: 0,
      recordCount: 0,
      recordDays: 0,
      totalDistance: 0
    },
    settings: {
      theme: 'auto',
      mapLayer: 'simple',
      locationPrecision: 'precise',
      autoLocation: true,
      enableNotifications: true,
      habitReminder: false,
      recordEncryption: true,
      cloudBackup: false,
      shareStatistics: true,
      language: 'zh-CN'
    },
    createdAt: Date.now(),
    lastLoginAt: Date.now()
  };
}
