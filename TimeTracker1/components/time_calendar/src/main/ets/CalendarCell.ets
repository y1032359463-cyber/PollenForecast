/**
 * 日历日期单元格组件
 * 支持五种状态：默认、今天、选中、有数据、非当月
 * 尺寸：48×48vp（符合 HarmonyOS 最小触摸标准）
 * 符合 Figma 设计规范
 */

import { UIConstants, ThemeManager, type ThemeColors } from '@ohos/commonlib'

@Component
export struct CalendarCell {
  @Prop date: number // 日期数字
  @Prop isToday: boolean = false // 是否今天
  @Prop isSelected: boolean = false // 是否选中
  @Prop hasData: boolean = false // 是否有工时数据
  @Prop isCurrentMonth: boolean = true // 是否当前月份
  @BuilderParam onCellClick?: (date: number) => void // 点击回调（使用BuilderParam）
  @StorageProp('themeColors') themeColors: ThemeColors = ThemeManager.getInstance().colors
  
  @State private scaleValue: number = UIConstants.ONE // 缩放状态

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 日期数字（居中显示）
      Text(this.date.toString())
        .fontSize(UIConstants.FONT_SIZE_MD)
        .fontWeight(this.isSelected ? FontWeight.Bold : FontWeight.Regular)
        .fontColor(
          this.isSelected ? '#FFFFFF' :
          this.isToday ? this.themeColors.primaryColor :
          this.isCurrentMonth ? this.themeColors.textPrimary : this.themeColors.textHint
        )
      
      // 右上角蓝色圆点 - 标记有数据的日期
      if (this.hasData && this.isCurrentMonth && !this.isSelected) {
        Circle({ width: 6, height: 6 })
          .fill(this.themeColors.primaryColor)
          .position({ x: '70%', y: '15%' })
      }
    }
    .width(UIConstants.CALENDAR_CELL_SIZE)
    .height(UIConstants.CALENDAR_CELL_SIZE)
    .backgroundColor(
      this.isSelected ? this.themeColors.primaryColor : 'transparent'
    )
    .borderRadius(UIConstants.RADIUS_SM)
    .shadow(
      this.isSelected
        ? { radius: 8, color: 'rgba(33, 150, 243, 0.3)', offsetX: 0, offsetY: 2 }
        : (this.isToday && this.isCurrentMonth
            ? { radius: 4, color: 'rgba(33, 150, 243, 0.15)', offsetX: 0, offsetY: 1 }
            : { radius: 0, color: 'transparent' })
    )
    .scale({ x: this.scaleValue, y: this.scaleValue })
    .animation({
      duration: UIConstants.ANIMATION_DURATION_FAST,
      curve: Curve.Linear
    })
    .onClick(() => {
      if (this.isCurrentMonth && this.onCellClick) {
        // 触摸反馈动画
        this.scaleValue = UIConstants.OPACITY_CELL_PRESS
        setTimeout(() => {
          this.scaleValue = UIConstants.ONE
        }, UIConstants.ANIMATION_DURATION_FAST)
        this.onCellClick(this.date)
      }
    })
  }
}
