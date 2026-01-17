/**
 * 我的 Tab 组件
 * 个人中心，大色块设计
 */
import { Colors } from '../constants/Colors';
import { User, Achievement, AchievementType } from '../models/User';

@Component
export struct ProfileTab {
  @State user: User | null = null;
  
  aboutToAppear() {
    this.loadUserInfo();
  }
  
  build() {
    Column() {
      // 顶部用户信息
      this.UserInfoCard()
      
      // 功能区（大色块）
      this.FunctionBlocks()
      
      // 设置入口
      this.SettingsEntry()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.BG_PRIMARY)
  }
  
  /**
   * 用户信息卡片
   */
  @Builder
  UserInfoCard() {
    Row() {
      // 头像
      Column() {
        Text('👤')
          .fontSize(50)
      }
      .width(80)
      .height(80)
      .backgroundColor(Colors.AVATAR_BG)
      .borderRadius(40)
      .justifyContent(FlexAlign.Center)
      .margin({ right: 16 })
      
      // 用户信息
      Column() {
        Text(this.user?.nickname || '游客')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.TEXT_PRIMARY)
        
        Text(`已使用 ${this.user?.stats.recordCount || 0} 次`)
          .fontSize(14)
          .fontColor(Colors.TEXT_SECONDARY)
          .margin({ top: 8 })
        
        // 成就徽章
        Row() {
          if (this.user && this.user.achievements.length > 0) {
            ForEach(this.user.achievements.slice(0, 3), (achievement: Achievement) => {
              Text(this.getAchievementIcon(achievement))
                .fontSize(16)
                .margin({ right: 8 })
            }, (achievement: Achievement) => achievement.type)
          }
        }
        .margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('90%')
    .padding(20)
    .margin({ left: '5%', top: 20 })
    .backgroundColor(Colors.BG_CARD)
    .borderRadius(16)
    .shadow({
      radius: 10,
      color: '#10000000',
      offsetY: 2
    })
  }
  
  /**
   * 功能区（大色块）
   */
  @Builder
  FunctionBlocks() {
    Column({ space: 12 }) {
      // 第一行：我的收藏 + 我的上报
      Row({ space: 12 }) {
        this.FunctionBlock('⭐', '我的收藏', this.user?.stats.favoriteToilets.toString() || '0', '#FFB74D')
        this.FunctionBlock('📍', '我的上报', this.user?.stats.contributedToilets.toString() || '0', '#4FC3F7')
      }
      .width('100%')
      
      // 第二行：使用记录 + 成就墙
      Row({ space: 12 }) {
        this.FunctionBlock('📝', '使用记录', this.user?.stats.recordCount.toString() || '0', '#81C784')
        this.FunctionBlock('🏆', '成就墙', this.user?.achievements.length.toString() || '0', '#BA68C8')
      }
      .width('100%')
    }
    .width('90%')
    .margin({ left: '5%', top: 20 })
  }
  
  /**
   * 功能色块
   */
  @Builder
  FunctionBlock(icon: string, title: string, count: string, color: string) {
    Column() {
      Text(icon)
        .fontSize(40)
        .margin({ bottom: 12 })
      
      Text(title)
        .fontSize(15)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Medium)
      
      Text(count)
        .fontSize(24)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .margin({ top: 8 })
    }
    .width('50%')
    .height(140)
    .layoutWeight(1)
    .backgroundColor(color)
    .borderRadius(16)
    .justifyContent(FlexAlign.Center)
    .shadow({
      radius: 8,
      color: '#20000000',
      offsetY: 2
    })
    .onClick(() => {
      console.info('点击功能块', title);
    })
  }
  
  /**
   * 设置入口
   */
  @Builder
  SettingsEntry() {
    Column({ space: 0 }) {
      this.SettingItem('🔔', '消息通知', true)
      Divider().color(Colors.DIVIDER)
      
      this.SettingItem('🎨', '主题设置', false)
      Divider().color(Colors.DIVIDER)
      
      this.SettingItem('🔒', '隐私设置', false)
      Divider().color(Colors.DIVIDER)
      
      this.SettingItem('ℹ️', '关于我们', false)
      Divider().color(Colors.DIVIDER)
      
      this.SettingItem('📱', '分享应用', false)
    }
    .width('90%')
    .margin({ left: '5%', top: 20, bottom: 20 })
    .backgroundColor(Colors.BG_CARD)
    .borderRadius(16)
    .shadow({
      radius: 10,
      color: '#10000000',
      offsetY: 2
    })
  }
  
  /**
   * 设置项
   */
  @Builder
  SettingItem(icon: string, title: string, showArrow: boolean) {
    Row() {
      Text(icon)
        .fontSize(22)
        .margin({ right: 12 })
      
      Text(title)
        .fontSize(15)
        .fontColor(Colors.TEXT_PRIMARY)
        .layoutWeight(1)
      
      if (showArrow) {
        Text('›')
          .fontSize(20)
          .fontColor(Colors.TEXT_HINT)
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    .onClick(() => {
      console.info('点击设置项', title);
    })
  }
  
  /**
   * 加载用户信息
   */
  private loadUserInfo() {
    // TODO: 从本地存储加载
    setTimeout(() => {
      this.user = {
        id: 'user_001',
        nickname: '厕所探索家',
        avatar: '',
        achievements: [
          {
            type: AchievementType.EXPLORER,
            level: 2,
            progress: 15,
            target: 20
          },
          {
            type: AchievementType.REVIEWER,
            level: 1,
            progress: 8,
            target: 10
          }
        ],
        stats: {
          checkedToilets: 15,
          favoriteToilets: 8,
          contributedToilets: 3,
          reviewCount: 23,
          usefulReviewCount: 18,
          recordCount: 42,
          recordDays: 30,
          totalDistance: 5000
        },
        settings: {
          theme: 'light',
          mapLayer: 'simple',
          locationPrecision: 'precise',
          autoLocation: true,
          enableNotification: true,
          enableSound: true,
          enableVibration: false,
          privacyMode: false,
          shareLocation: true,
          language: 'zh-CN'
        },
        createdAt: Date.now() - 30 * 24 * 60 * 60 * 1000,
        lastLoginAt: Date.now()
      };
    }, 300);
  }
  
  /**
   * 获取成就图标
   */
  private getAchievementIcon(achievement: Achievement): string {
    switch (achievement.type) {
      case 'explorer': return '🗺️';
      case 'reviewer': return '⭐';
      case 'contributor': return '📍';
      case 'frequent': return '🔥';
      case 'night_owl': return '🦉';
      default: return '🏆';
    }
  }
}
