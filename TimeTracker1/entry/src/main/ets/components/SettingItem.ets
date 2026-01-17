/**
 * SettingItem Component
 * 设置列表项组件 - 统一的设置选项样式
 * 
 * 设计规范:
 * - 尺寸: 328×56vp
 * - 布局: 图标 | 标签 | 值(右对齐) | 箭头
 * - 间距: 元素间 12vp
 * - 圆角: 10vp
 * - 阴影: rgba(0,0,0,0.06) 8vp 模糊
 */

import { ThemeManager, type ThemeColors } from '@ohos/commonlib'

@Component
export struct SettingItem {
  @Prop icon: Resource = $r('sys.symbol.gearshape')
  @Prop label: string = 'Setting'
  @Prop value: string = ''
  @Prop showArrow: boolean = true
  @State isPressed: boolean = false  // 手动管理按压态
  @StorageProp('themeColors') themeColors: ThemeColors = ThemeManager.getInstance().colors
  onTap?: () => void

  build() {
    Row() {
      // 图标
      Image(this.icon)
        .width(24)
        .height(24)
        .fillColor(this.themeColors.textSecondary)

      // 标签
      Text(this.label)
        .fontSize(16)
        .fontColor(this.themeColors.textPrimary)
        .margin({ left: 12 })
        .layoutWeight(1)

      // 值（可选）
      if (this.value) {
        Text(this.value)
          .fontSize(14)
          .fontColor(this.themeColors.textSecondary)
          .margin({ right: 8 })
      }

      // 箭头（可选）
      if (this.showArrow) {
        Image($r('sys.symbol.chevron_right'))
          .width(16)
          .height(16)
          .fillColor(this.themeColors.textHint)
      }
    }
    .width('100%')
    .height(56)
    .padding({ top: 12, bottom: 12, left: 16, right: 16 })
    .backgroundColor(this.isPressed ? this.themeColors.background : this.themeColors.cardBackground)
    .borderRadius(10)
    .border({ width: 1, color: this.themeColors.dividerColor })
    .shadow({
      radius: 8,
      color: this.themeColors.shadowColor,
      offsetX: 0,
      offsetY: 2
    })
    .onTouch((event: TouchEvent) => {
      // 手动管理按压态，提供即时视觉反馈
      if (event.type === TouchType.Down) {
        this.isPressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false;
      }
    })
    .onClick(() => {
      console.info(`[SettingItem] 点击: ${this.label}`);
      if (this.onTap) {
        this.onTap();
      }
    })
  }
}
