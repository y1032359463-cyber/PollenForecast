/**
 * 成就展示页面
 * 显示所有成就及解锁进度
 */

import { AchievementManager, AchievementType, AchievementConfig } from '../common/utils/AchievementManager';
import { CommonConstants as Const } from '../common/constants/CommonConstants';

@Entry
@Component
struct AchievementPage {
  @State achievements: AchievementConfig[] = [];
  @State unlockedCount: number = 0;
  @State totalCount: number = 0;
  @State progressMap: Map<AchievementType, number> = new Map();
  private achievementMgr: AchievementManager = AchievementManager.getInstance();

  async aboutToAppear() {
    await this.loadAchievements();
  }

  /**
   * 加载成就数据
   */
  async loadAchievements() {
    this.achievements = this.achievementMgr.getAllAchievements();
    this.totalCount = this.achievements.length;
    this.unlockedCount = this.achievementMgr.getUnlockedCount();

    // 加载每个成就的进度
    for (const achievement of this.achievements) {
      const progress = await this.achievementMgr.getAchievementProgress(achievement.type);
      this.progressMap.set(achievement.type, progress);
    }
  }

  /**
   * 获取等级文本
   */
  getLevelText(level: number): string {
    const levels = ['', '铜', '银', '金', '钻'];
    return levels[level] || '';
  }

  /**
   * 获取等级颜色
   */
  getLevelColor(level: number): string {
    const colors = ['', '#CD7F32', '#C0C0C0', '#FFD700', '#B9F2FF'];
    return colors[level] || '#999999';
  }

  /**
   * 成就卡片
   */
  @Builder
  AchievementCard(achievement: AchievementConfig) {
    Column() {
      // 徽章图标
      Image(this.achievementMgr.isUnlocked(achievement.type) ? achievement.iconUnlock : achievement.icon)
        .width(64)
        .height(64)
        .opacity(this.achievementMgr.isUnlocked(achievement.type) ? 1 : 0.4)

      // 成就名称
      Text(achievement.name)
        .fontSize(16)
        .fontWeight(600)
        .fontColor(this.achievementMgr.isUnlocked(achievement.type) ? '#333333' : '#999999')
        .margin({ top: 12, bottom: 4 })

      // 成就描述
      Text(achievement.description)
        .fontSize(12)
        .fontColor('#999999')
        .margin({ bottom: 8 })

      // 进度条(未解锁时显示)
      if (!this.achievementMgr.isUnlocked(achievement.type)) {
        Column() {
          Row() {
            Text(`${this.progressMap.get(achievement.type) || 0}%`)
              .fontSize(10)
              .fontColor('#666666')
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 4 })

          Row() {
            Row()
              .width(`${this.progressMap.get(achievement.type) || 0}%`)
              .height(4)
              .backgroundColor(achievement.color)
              .borderRadius(2)
          }
          .width('100%')
          .height(4)
          .backgroundColor('#F0F0F0')
          .borderRadius(2)
        }
        .width('100%')
        .padding({ top: 8 })
      } else {
        // 已解锁标识
        Row() {
          Text('✓')
            .fontSize(10)
            .fontColor('#FFFFFF')
        }
        .width(20)
        .height(20)
        .backgroundColor(achievement.color)
        .borderRadius(10)
        .justifyContent(FlexAlign.Center)
        .margin({ top: 8 })
      }

      // 等级标签
      Text(this.getLevelText(achievement.level))
        .fontSize(10)
        .fontColor('#FFFFFF')
        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
        .backgroundColor(this.getLevelColor(achievement.level))
        .borderRadius(4)
        .margin({ top: 8 })
    }
    .width('48%')
    .padding(16)
    .backgroundColor($r('app.color.start_window_background'))
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
    .border({
      width: this.achievementMgr.isUnlocked(achievement.type) ? 2 : 0,
      color: achievement.color
    })
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Image($r('app.media.ic_right_grey'))
          .width(24)
          .height(24)
          .rotate({ angle: 180 })
          .onClick(() => {
            this.getUIContext().getRouter().back();
          })

        Text('成就')
          .fontSize(20)
          .fontWeight(600)
          .margin({ left: 12 })

        Blank()

        Text(`${this.unlockedCount}/${this.totalCount}`)
          .fontSize(14)
          .fontColor('#999999')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      // 总体进度卡片
      Column() {
        Row() {
          Text('总体进度')
            .fontSize(16)
            .fontWeight(600)

          Blank()

          Text(`${Math.round((this.unlockedCount / this.totalCount) * 100)}%`)
            .fontSize(24)
            .fontWeight(600)
            .fontColor('#52C41A')
        }
        .width('100%')
        .margin({ bottom: 12 })

        // 进度条
        Row() {
          Row()
            .width(`${(this.unlockedCount / this.totalCount) * 100}%`)
            .height(8)
            .backgroundColor('#52C41A')
            .borderRadius(4)
        }
        .width('100%')
        .height(8)
        .backgroundColor('#F0F0F0')
        .borderRadius(4)
      }
      .width('100%')
      .padding(16)
      .margin({ left: 16, right: 16, top: 8, bottom: 16 })
      .backgroundColor($r('app.color.start_window_background'))
      .borderRadius(12)

      // 成就列表
      Scroll() {
        Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.achievements, (achievement: AchievementConfig) => {
            Column() {
              this.AchievementCard(achievement)
            }
            .width('48%')
            .margin({ bottom: 12 })
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.primaryBgColor'))
  }
}
