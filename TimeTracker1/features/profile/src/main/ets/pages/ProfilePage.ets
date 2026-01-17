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
 * 5. Bottom Navigation（76px）- 固定底部
 */

import { UserCard } from '../components/UserCard'
import { SettingItem } from '../components/SettingItem'
import { VIPBanner } from '../components/VIPBanner'

@Component
export struct ProfilePage {

  // 设置项配置（与Figma设计一致）
  // 图标来源: figma/图标/ 目录，已复制到 entry/src/main/resources/base/media/
  private settingsConfig = [
    {
      icon: $r('app.media.ic_money'),        // Currency.svg - 时薪图标
      label: '时薪设置',
      value: '¥30/小时',
      action: () => this.onHourlyWageClick()
    },
    {
      icon: $r('app.media.ic_calendar_line'), // calendar.svg - 日历图标
      label: '考勤周期',
      value: '每周',
      action: () => this.onWorkCycleClick()
    },
    {
      icon: $r('app.media.ic_palette'),      // More.svg - 主题图标（使用More代替调色板）
      label: '主题设置',
      value: '跟随系统',
      action: () => this.onThemeClick()
    },
    {
      icon: $r('app.media.ic_cloud'),        // Wallet.svg - 备份图标（使用钱包代替云）
      label: '数据备份',
      value: '',
      action: () => this.onBackupClick()
    },
    {
      icon: $r('app.media.ic_phone'),        // Message.svg - 关于图标（使用消息代替手机）
      label: '关于应用',
      value: 'v1.0.0',
      action: () => this.onAboutClick()
    },
    {
      icon: $r('app.media.ic_settings'),     // ReadBook.svg - 设置图标（使用书籍代替齿轮）
      label: '高级设置',
      value: '',
      action: () => this.onAdvancedClick()
    }
  ]

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
              .fontColor('#212121')
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)

          // 2. User Card（140px高度 + 16px上边距）
          UserCard({
            userName: '用户名称',
            userRole: '小时工',
            memberSince: '注册于 2025年11月'
          })
            .margin({ left: 16, right: 16, top: 16 })

          // 3. Settings List Section
          Column({ space: 0 }) {
            // Section Title（"设置"）
            Text('设置')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#212121')
              .width('100%')
              .margin({ top: 16, bottom: 12 })

            // 6个设置列表项（间距8px）
            ForEach(this.settingsConfig, (item: {
              icon: Resource,
              label: string,
              value: string,
              action: () => void
            }, index: number) => {
              SettingItem({
                icon: item.icon,
                label: item.label,
                value: item.value,
                showArrow: true,
                onTap: item.action
              })
                .margin({ top: index === 0 ? 0 : 8 }) // 第一项不需要上边距
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })

          // 注意：VIP功能已完全移除，应用定位为免费使用
        }
        .width('100%')
        .backgroundColor('#F8F9FA') // 页面背景色
      }
      .width('100%')
      .layoutWeight(1) // 占据所有空间
      .scrollBar(BarState.Off) // 隐藏滚动条（iOS风格）
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA')
  }

  // ========== 事件处理器 ==========

  /**
   * 时薪设置点击
   */
  private onHourlyWageClick(): void {
    console.info('Hourly wage setting clicked')
    // TODO: 打开时薪设置弹窗或页面
  }

  /**
   * 考勤周期点击
   */
  private onWorkCycleClick(): void {
    console.info('Work cycle setting clicked')
    // TODO: 打开考勤周期设置
  }

  /**
   * 主题设置点击
   */
  private onThemeClick(): void {
    console.info('Theme setting clicked')
    // TODO: 打开主题选择弹窗
  }

  /**
   * 数据备份点击
   */
  private onBackupClick(): void {
    console.info('Data backup clicked')
    // TODO: 实现数据备份功能
  }

  /**
   * 关于应用点击
   */
  private onAboutClick(): void {
    console.info('About app clicked')
    // TODO: 打开关于页面
  }

  /**
   * 高级设置点击
   */
  private onAdvancedClick(): void {
    console.info('Advanced settings clicked')
    // TODO: 打开高级设置页面
  }
}
