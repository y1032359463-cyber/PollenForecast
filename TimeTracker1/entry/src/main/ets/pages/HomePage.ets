/**
 * HomePage - 应用主页面（Tab容器）
 * 管理3个Tab页面的切换：工时记录、数据统计、个人中心
 */

import { TimeRecordPage } from '@ohos/time_record';
import { StatisticsPage } from './StatisticsPage';
import { ProfilePage } from './ProfilePage';
import { ThemeManager, type ThemeColors, storageUtils } from '@ohos/commonlib';
import { VoiceAssistantButton } from '@ohos/commonlib';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct HomePage {
  @State currentTabIndex: number = 0
  @StorageProp('themeColors') themeColors: ThemeColors = ThemeManager.getInstance().colors
  private themeManager: ThemeManager = ThemeManager.getInstance()

  aboutToAppear(): void {
    this.checkShowVoiceGuide();
  }

  // 检查是否显示语音引导
  private async checkShowVoiceGuide(): Promise<void> {
    try {
      // 初始化存储工具
      await storageUtils.init();
      
      // 获取是否显示引导的偏好设置
      const showGuide = await storageUtils.get<boolean>('showVoiceGuide', true);
      
      // 如果需要显示引导，跳转到引导页面
      if (showGuide) {
        router.pushUrl({
          url: 'pages/VoiceGuidePage'
        });
      }
    } catch (error) {
      console.error(`检查语音引导显示状态失败: ${error}`);
    }
  }

  // 刷新主题
  refreshTheme(): void {
    this.themeColors = this.themeManager.colors;
  }

  // TabBar自定义构建函数
  @Builder
  TabBarBuilder(icon: Resource, selectedIcon: Resource, label: string, index: number) {
    Column({ space: 4 }) {
      Image(this.currentTabIndex === index ? selectedIcon : icon)
        .width(24)
        .height(24)
        .fillColor(this.currentTabIndex === index ? this.themeColors.primaryColor : this.themeColors.textHint)
      Text(label)
        .fontSize(12)
        .fontColor(this.currentTabIndex === index ? this.themeColors.primaryColor : this.themeColors.textHint)
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Stack() {
      // Tab容器
      Tabs({ index: $$this.currentTabIndex, barPosition: BarPosition.End }) {
        // Tab 1: 工时记录
        TabContent() {
          TimeRecordPage()
        }
        .tabBar(this.TabBarBuilder(
          $r('app.media.ic_clock'),
          $r('app.media.ic_clock'),
          '工时记录',
          0
        ))

        // Tab 2: 数据统计
        TabContent() {
          StatisticsPage()
        }
        .tabBar(this.TabBarBuilder(
          $r('app.media.ic_chart'),
          $r('app.media.ic_chart'),
          '数据统计',
          1
        ))

        // Tab 3: 个人中心
        TabContent() {
          ProfilePage()
        }
        .tabBar(this.TabBarBuilder(
          $r('app.media.ic_user'),
          $r('app.media.ic_user'),
          '个人中心',
          2
        ))
      }
      .width('100%')
      .height('100%')
      .barMode(BarMode.Fixed)
      .barHeight(76)
      .animationDuration(300)
      .backgroundColor(this.themeColors.background)
      .barBackgroundColor(this.themeColors.surfaceBackground)
      .padding({ bottom: 20 })  // 底部安全区
      .edgeEffect(EdgeEffect.Spring)  // 添加弹簧回弹效果

      // 语音助手悬浮按钮
      VoiceAssistantButton()
    }
    .width('100%')
    .height('100%')
  }
}
