/**
 * 成就管理器
 * 负责成就解锁判定、成就数据管理
 */

import { StatisticsService } from './StatisticsService';

/**
 * 成就类型枚举
 */
export enum AchievementType {
  // 连续打卡成就
  STREAK_3 = 'streak_3',       // 连续打卡3天
  STREAK_7 = 'streak_7',       // 连续打卡7天
  STREAK_30 = 'streak_30',     // 连续打卡30天
  STREAK_100 = 'streak_100',   // 连续打卡100天

  // 任务完成数成就
  TOTAL_10 = 'total_10',       // 累计完成10个任务
  TOTAL_50 = 'total_50',       // 累计完成50个任务
  TOTAL_100 = 'total_100',     // 累计完成100个任务
  TOTAL_365 = 'total_365',     // 累计完成365个任务

  // 完美周成就
  PERFECT_WEEK = 'perfect_week',   // 完美一周(7天全满)
  PERFECT_MONTH = 'perfect_month', // 完美一月(30天全满)

  // 特殊成就
  EARLY_BIRD = 'early_bird',       // 早起鸟(连续7天6点前打卡)
  NIGHT_OWL = 'night_owl',         // 夜猫子(连续7天22点后打卡)
}

/**
 * 成就配置接口
 */
export interface AchievementConfig {
  type: AchievementType;
  name: string;
  description: string;
  icon: Resource;
  iconUnlock: Resource;
  level: number;          // 等级(1-4: 铜银金钻)
  requiredValue: number;  // 解锁所需数值
  color: string;          // 主题颜色
}

/**
 * 成就管理器类
 */
export class AchievementManager {
  private static instance: AchievementManager;
  private unlockedAchievements: Set<AchievementType> = new Set();

  private constructor() {
    this.loadUnlockedAchievements();
  }

  static getInstance(): AchievementManager {
    if (!AchievementManager.instance) {
      AchievementManager.instance = new AchievementManager();
    }
    return AchievementManager.instance;
  }

  /**
   * 获取所有成就配置
   */
  getAllAchievements(): AchievementConfig[] {
    return [
      // 连续打卡成就
      {
        type: AchievementType.STREAK_3,
        name: '初出茅庐',
        description: '连续打卡3天',
        icon: $r('app.media.ic_badge_3_off'),
        iconUnlock: $r('app.media.ic_badge_3_on'),
        level: 1,
        requiredValue: 3,
        color: '#CD7F32'
      },
      {
        type: AchievementType.STREAK_7,
        name: '坚持不懈',
        description: '连续打卡7天',
        icon: $r('app.media.ic_badge_7_off'),
        iconUnlock: $r('app.media.ic_badge_7_on'),
        level: 2,
        requiredValue: 7,
        color: '#C0C0C0'
      },
      {
        type: AchievementType.STREAK_30,
        name: '习惯养成',
        description: '连续打卡30天',
        icon: $r('app.media.ic_badge_30_off'),
        iconUnlock: $r('app.media.ic_badge_30_on'),
        level: 3,
        requiredValue: 30,
        color: '#FFD700'
      },
      {
        type: AchievementType.STREAK_100,
        name: '坚如磐石',
        description: '连续打卡100天',
        icon: $r('app.media.ic_badge_99_off'),
        iconUnlock: $r('app.media.ic_badge_99_on'),
        level: 4,
        requiredValue: 100,
        color: '#B9F2FF'
      },

      // 任务完成数成就
      {
        type: AchievementType.TOTAL_10,
        name: '小试牛刀',
        description: '累计完成10个任务',
        icon: $r('app.media.ic_badge_3_off'),
        iconUnlock: $r('app.media.ic_badge_3_on'),
        level: 1,
        requiredValue: 10,
        color: '#CD7F32'
      },
      {
        type: AchievementType.TOTAL_50,
        name: '勤奋达人',
        description: '累计完成50个任务',
        icon: $r('app.media.ic_badge_7_off'),
        iconUnlock: $r('app.media.ic_badge_7_on'),
        level: 2,
        requiredValue: 50,
        color: '#C0C0C0'
      },
      {
        type: AchievementType.TOTAL_100,
        name: '百炼成钢',
        description: '累计完成100个任务',
        icon: $r('app.media.ic_badge_30_off'),
        iconUnlock: $r('app.media.ic_badge_30_on'),
        level: 3,
        requiredValue: 100,
        color: '#FFD700'
      },
      {
        type: AchievementType.TOTAL_365,
        name: '全年无休',
        description: '累计完成365个任务',
        icon: $r('app.media.ic_badge_99_off'),
        iconUnlock: $r('app.media.ic_badge_99_on'),
        level: 4,
        requiredValue: 365,
        color: '#B9F2FF'
      },
    ];
  }

  /**
   * 检查成就是否解锁
   */
  async checkAchievementUnlock(type: AchievementType): Promise<boolean> {
    if (this.unlockedAchievements.has(type)) {
      return true; // 已解锁
    }

    const config = this.getAllAchievements().find(a => a.type === type);
    if (!config) return false;

    let currentValue = 0;

    // 根据成就类型获取当前进度
    switch (type) {
      case AchievementType.STREAK_3:
      case AchievementType.STREAK_7:
      case AchievementType.STREAK_30:
      case AchievementType.STREAK_100:
        currentValue = await StatisticsService.getStreakDays();
        break;

      case AchievementType.TOTAL_10:
      case AchievementType.TOTAL_50:
      case AchievementType.TOTAL_100:
      case AchievementType.TOTAL_365:
        currentValue = await StatisticsService.getTotalCompletedTasks();
        break;

      case AchievementType.PERFECT_WEEK:
        const weekRate = await StatisticsService.getCurrentWeekCompletionRate();
        currentValue = weekRate >= 100 ? 1 : 0;
        break;

      case AchievementType.PERFECT_MONTH:
        const monthRate = await StatisticsService.getCurrentMonthCompletionRate();
        currentValue = monthRate >= 100 ? 1 : 0;
        break;
    }

    // 判断是否达成
    if (currentValue >= config.requiredValue) {
      this.unlockAchievement(type);
      return true;
    }

    return false;
  }

  /**
   * 解锁成就
   */
  unlockAchievement(type: AchievementType): void {
    this.unlockedAchievements.add(type);
    this.saveUnlockedAchievements();
  }

  /**
   * 获取成就进度
   */
  async getAchievementProgress(type: AchievementType): Promise<number> {
    const config = this.getAllAchievements().find(a => a.type === type);
    if (!config) return 0;

    let currentValue = 0;

    switch (type) {
      case AchievementType.STREAK_3:
      case AchievementType.STREAK_7:
      case AchievementType.STREAK_30:
      case AchievementType.STREAK_100:
        currentValue = await StatisticsService.getStreakDays();
        break;

      case AchievementType.TOTAL_10:
      case AchievementType.TOTAL_50:
      case AchievementType.TOTAL_100:
      case AchievementType.TOTAL_365:
        currentValue = await StatisticsService.getTotalCompletedTasks();
        break;
    }

    return Math.min(100, Math.round((currentValue / config.requiredValue) * 100));
  }

  /**
   * 判断成就是否已解锁
   */
  isUnlocked(type: AchievementType): boolean {
    return this.unlockedAchievements.has(type);
  }

  /**
   * 获取已解锁成就数量
   */
  getUnlockedCount(): number {
    return this.unlockedAchievements.size;
  }

  /**
   * 加载已解锁成就(从本地存储)
   */
  private loadUnlockedAchievements(): void {
    try {
      const storage = AppStorage.get<string>('unlockedAchievements');
      if (storage) {
        const unlocked: string[] = JSON.parse(storage);
        unlocked.forEach(type => {
          this.unlockedAchievements.add(type as AchievementType);
        });
      }
    } catch (error) {
      console.error('加载成就数据失败:', JSON.stringify(error));
    }
  }

  /**
   * 保存已解锁成就(到本地存储)
   */
  private saveUnlockedAchievements(): void {
    try {
      const unlocked = Array.from(this.unlockedAchievements);
      AppStorage.setOrCreate('unlockedAchievements', JSON.stringify(unlocked));
    } catch (error) {
      console.error('保存成就数据失败:', JSON.stringify(error));
    }
  }

  /**
   * 检查所有成就并返回新解锁的
   */
  async checkAllAchievements(): Promise<AchievementType[]> {
    const newlyUnlocked: AchievementType[] = [];
    const allAchievements = this.getAllAchievements();

    for (const achievement of allAchievements) {
      const wasUnlocked = this.isUnlocked(achievement.type);
      const isNowUnlocked = await this.checkAchievementUnlock(achievement.type);

      if (isNowUnlocked && !wasUnlocked) {
        newlyUnlocked.push(achievement.type);
      }
    }

    return newlyUnlocked;
  }
}
