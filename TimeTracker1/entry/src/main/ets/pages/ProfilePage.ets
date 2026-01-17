/**
 * ProfilePage - 个人中心页面
 * 
 * 设计规范（严格对照 figma/08_我的页面.txt）:
 * - 屏幕尺寸: 360×812px（包含76px底部导航）
 * - 内容区域: 360×736px（可滚动）
 * - 主色: #2196F3（HarmonyOS Blue）
 * - 背景: #F8F9FA
 * - 间距系统: 8px网格（8/12/16/20/24px）
 * 
 * 布局结构:
 * 1. Header（56px）- 白色背景，"个人中心"标题
 * 2. UserCard（140px）- 蓝色渐变卡片
 * 3. Settings List（"设置"标题 + 6个设置项）
 * 4. VIP Banner（80px）- 金色渐变横幅
 */

import { ThemeManager, type ThemeColors, ThemeMode, AccountManager, type UserInfo, LoginStatus } from '@ohos/commonlib';
import { UserCard } from '../components/UserCard'
import { SettingItem } from '../components/SettingItem'
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';

interface ThemeItem {
  mode: ThemeMode
  name: string
}

@Component
export struct ProfilePage {
  @State hourlyWage: number = 30; // 默认时薪
  @State workCycle: string = '每周'; // 考勤周期
  @State showHourlyWageDialog: boolean = false; // 时薪设置对话框
  @State showThemeDialog: boolean = false; // 主题设置对话框
  @State showWorkCycleDialog: boolean = false; // 考勤周期对话框
  @StorageProp('currentThemeMode') currentThemeMode: ThemeMode = ThemeMode.AUTO; // 当前主题模式
  @StorageProp('themeColors') themeColors: ThemeColors = ThemeManager.getInstance().colors
  private themeManager: ThemeManager = ThemeManager.getInstance()

  // 账号管理(云同步功能预留)
  @State isLoggedIn: boolean = false; // 是否已登录华为账号
  @State userInfo: UserInfo | null = null; // 用户信息
  private accountManager: AccountManager = AccountManager.getInstance();

  // 生命周期：预初始化 Sheet 对话框，解决首次点击无响应问题
  aboutToAppear() {
    // 方案一：使用 setTimeout 延迟触发 Sheet 初始化（ArkTS 兼容方案）
    // 增加延迟时间到100ms，确保ArkUI完成所有Sheet实例化
    setTimeout(() => {
      console.info('[ProfilePage] 开始初始化Sheet组件');
      this.showHourlyWageDialog = false;
      this.showWorkCycleDialog = false;
      this.showThemeDialog = false;
      console.info('[ProfilePage] Sheet组件初始化完成');
    }, 100);

    // 初始化账号管理器(云同步功能预留)
    this.loadAccountStatus();
  }

  /**
   * 加载账号状态(云同步功能预留)
   */
  private loadAccountStatus(): void {
    this.isLoggedIn = this.accountManager.isLoggedIn();
    this.userInfo = this.accountManager.getUserInfo();
    console.info('[ProfilePage] 账号状态:', this.isLoggedIn ? '已登录' : '未登录');
  }

  /**
   * 登录按钮点击(云同步功能预留)
   */
  private onLoginClick(): void {
    console.info('[ProfilePage] 点击登录按钮');
    AlertDialog.show({
      title: '云同步功能',
      message: '云同步功能开发中，敬请期待！\n\n功能规划:\n• 华为账号登录\n• 数据云端备份\n• 多设备同步',
      confirm: {
        value: '知道了',
        fontColor: '#2196F3',
        action: () => {}
      }
    });
  }

  // 获取主题显示名称
  getThemeDisplayName(): string {
    switch (this.currentThemeMode) {
      case ThemeMode.LIGHT:
        return '浅色';
      case ThemeMode.DARK:
        return '深色';
      case ThemeMode.AUTO:
        return '跟随系统';
      default:
        return '跟随系统';
    }
  }

  build() {
    Column() {
      // 主内容区域（可滚动）
      Scroll() {
        Column() {
          // 1. Header Section（56px高度）
          Row() {
            Text('个人中心')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeColors.textPrimary)
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.themeColors.surfaceBackground)
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)

          // 2. User Card - 隐藏，云同步功能未开发
          // UserCard({
          //   isLoggedIn: this.isLoggedIn,
          //   userName: this.userInfo?.userName ?? '未设置',
          //   userRole: this.userInfo ? '会员用户' : '免费用户',
          //   memberSince: this.userInfo?.memberSince ?? '未登录',
          //   onLoginClick: () => this.onLoginClick()
          // })
          //   .margin({ left: 16, right: 16, top: 16 })

          // 3. Settings List Section
          Column({ space: 0 }) {
            // Section Title（"设置"）
            Text('设置')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeColors.textPrimary)
              .width('100%')
              .margin({ top: 16, bottom: 12 })

            // 6个设置列表项（间距8px）
            // 时薪设置
            SettingItem({
              icon: $r('app.media.ic_money'),
              label: '时薪设置',
              value: `¥${this.hourlyWage}/小时`,
              showArrow: true,
              onTap: () => this.onHourlyWageClick()
            })
              .bindSheet($$this.showHourlyWageDialog, this.HourlyWageDialog(), {
                height: 300,
                backgroundColor: this.themeColors.cardBackground
              })

            // 考勤周期
            SettingItem({
              icon: $r('app.media.ic_calendar'),
              label: '考勤周期',
              value: this.workCycle,
              showArrow: true,
              onTap: () => this.onWorkCycleClick()
            })
              .margin({ top: 8 })
              .bindSheet($$this.showWorkCycleDialog, this.WorkCycleDialog(), {
                height: 300,
                backgroundColor: this.themeColors.cardBackground
              })

            // 主题设置
            SettingItem({
              icon: $r('app.media.ic_palette'),
              label: '主题设置',
              value: this.getThemeDisplayName(),
              showArrow: true,
              onTap: () => this.onThemeClick()
            })
              .margin({ top: 8 })
              .bindSheet($$this.showThemeDialog, this.ThemeDialog(), {
                height: 300,
                backgroundColor: this.themeColors.cardBackground
              })

            // 关于应用
            SettingItem({
              icon: $r('app.media.ic_phone'),
              label: '关于应用',
              value: 'v1.0.0',
              showArrow: true,
              onTap: () => this.onAboutClick()
            })
              .margin({ top: 8 })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })

          // 注意：VIP功能已完全移除，应用定位为免费使用
        }
        .width('100%')
        .backgroundColor(this.themeColors.background)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColors.background)
  }

  // 事件处理器（方案四：每个Sheet绑定到独立组件）
  private onHourlyWageClick(): void {
    console.info('[ProfilePage] 点击时薪设置，打开对话框');
    this.showHourlyWageDialog = true;
  }

  private onWorkCycleClick(): void {
    console.info('[ProfilePage] 点击考勤周期，打开对话框');
    this.showWorkCycleDialog = true;
  }

  private onThemeClick(): void {
    console.info('[ProfilePage] 点击主题设置，打开对话框');
    this.showThemeDialog = true;
  }

  private onBackupClick(): void {
    AlertDialog.show({
      title: '数据备份',
      message: '备份功能开发中，敬请期待！',
      confirm: {
        value: '确定',
        fontColor: '#2196F3',
        action: () => {}
      }
    });
  }

  private onAboutClick(): void {
    AlertDialog.show({
      title: '关于应用',
      message: 'TimeTracker v1.0.0\n\n一款简洁高效的工时记录应用\n\n© 2025 TimeTracker',
      confirm: {
        value: '确定',
        fontColor: '#2196F3',
        action: () => {}
      }
    });
  }

  private onAdvancedClick(): void {
    try {
      promptAction.showToast({
        message: '高级设置功能开发中'
      });
    } catch (err) {
      console.error('Failed to show toast:', (err as Error).message);
    }
  }

  // 时薪设置对话框
  @Builder HourlyWageDialog() {
    Column() {
      Text('设置默认时薪')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeColors.textPrimary)
        .margin({ top: 20, bottom: 20 })

      Row() {
        Text('¥')
          .fontSize(20)
          .fontColor(this.themeColors.textSecondary)
          .fontWeight(FontWeight.Medium)
          .margin({ right: 8 })

        TextInput({ text: this.hourlyWage.toString() })
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeColors.textPrimary)
          .backgroundColor(this.themeColors.background)
          .type(InputType.Number)
          .layoutWeight(1)
          .onChange((value: string) => {
            this.hourlyWage = parseInt(value) || 0;
          })

        Text('/小时')
          .fontSize(16)
          .fontColor(this.themeColors.textSecondary)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 8 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(this.themeColors.background)
      .borderRadius(8)

      Row() {
        Button('取消')
          .width('48%')
          .backgroundColor(this.themeColors.background)
          .fontColor(this.themeColors.textSecondary)
          .onClick(() => {
            this.showHourlyWageDialog = false;
          })

        Button('确定')
          .width('48%')
          .backgroundColor(this.themeColors.primaryColor)
          .fontColor(Color.White)
          .onClick(() => {
            try {
              promptAction.showToast({ message: `时薪已设置为 ¥${this.hourlyWage}/小时` });
            } catch (err) {
              console.error('Failed to show toast:', (err as Error).message);
            }
            this.showHourlyWageDialog = false;
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 24 })
    }
    .width('100%')
    .padding(20)
  }

  // 考勤周期对话框
  @Builder WorkCycleDialog() {
    Column() {
      Text('选择考勤周期')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeColors.textPrimary)
        .margin({ top: 20, bottom: 20 })

      Column() {
        ForEach(['每周', '每月', '自定义'], (cycle: string) => {
          Row() {
            Text(cycle)
              .fontSize(16)
              .fontColor(this.themeColors.textPrimary)
              .layoutWeight(1)

            if (this.workCycle === cycle) {
              Text('✓')
                .fontSize(20)
                .fontColor(this.themeColors.primaryColor)
            }
          }
          .width('100%')
          .height(48)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.workCycle = cycle;
            try {
              promptAction.showToast({ message: `考勤周期已设置为${cycle}` });
            } catch (err) {
              console.error('Failed to show toast:', (err as Error).message);
            }
            this.showWorkCycleDialog = false;
          })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(this.themeColors.cardBackground)
  }

  // 主题设置对话框
  @Builder ThemeDialog() {
    Column() {
      Text('选择主题')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeColors.textPrimary)
        .margin({ top: 20, bottom: 20 })

      Column() {
        ForEach([
          { mode: ThemeMode.AUTO, name: '跟随系统' },
          { mode: ThemeMode.LIGHT, name: '浅色' },
          { mode: ThemeMode.DARK, name: '深色' }
        ], (item: ThemeItem) => {
          Row() {
            Text(item.name)
              .fontSize(16)
              .fontColor(this.themeColors.textPrimary)
              .layoutWeight(1)

            if (this.currentThemeMode === item.mode) {
              Text('✓')
                .fontSize(20)
                .fontColor(this.themeColors.primaryColor)
            }
          }
          .width('100%')
          .height(48)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.themeManager.setThemeMode(item.mode);
            
            // 手动创建新的颜色对象,触发AppStorage监听
            const colors = this.themeManager.colors;
            const newColors: ThemeColors = {
              background: colors.background,
              cardBackground: colors.cardBackground,
              surfaceBackground: colors.surfaceBackground,
              textPrimary: colors.textPrimary,
              textSecondary: colors.textSecondary,
              textHint: colors.textHint,
              primaryColor: colors.primaryColor,
              primaryLight: colors.primaryLight,
              primaryDark: colors.primaryDark,
              successColor: colors.successColor,
              warningColor: colors.warningColor,
              errorColor: colors.errorColor,
              dividerColor: colors.dividerColor,
              borderColor: colors.borderColor,
              shadowColor: colors.shadowColor
            };
            AppStorage.set('themeColors', newColors);
            AppStorage.set('currentThemeMode', item.mode); // 同步更新主题模式
            
            try {
              promptAction.showToast({ message: `主题已设置为${item.name}` });
            } catch (err) {
              console.error('Failed to show toast:', (err as Error).message);
            }
            this.showThemeDialog = false;
          })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(this.themeColors.cardBackground)
  }
}
