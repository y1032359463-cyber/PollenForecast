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

@Component
export struct SettingItem {
  @Prop icon: Resource = $r('sys.symbol.gear')
  @Prop label: string = 'Setting'
  @Prop value: string = ''
  @Prop showArrow: boolean = true
  private onTap?: () => void

  // 添加点击状态
  @State isPressed: boolean = false

  build() {
    Row() {
      // 图标
      Image(this.icon)
        .width(24)
        .height(24)
        .fillColor('#757575')

      // 标签
      Text(this.label)
        .fontSize(16)
        .fontColor('#212121')
        .margin({ left: 12 })
        .layoutWeight(1)

      // 值（可选）
      if (this.value) {
        Text(this.value)
          .fontSize(14)
          .fontColor('#9E9E9E')
          .margin({ right: 8 })
      }

      // 箭头（可选）
      if (this.showArrow) {
        Image($r('sys.symbol.chevron_right'))
          .width(16)
          .height(16)
          .fillColor('#BDBDBD')
      }
    }
    .width('100%')
    .height(56)
    .padding({ top: 12, bottom: 12, left: 16, right: 16 })
    .backgroundColor(this.isPressed ? '#EEEEEE' : Color.White)
    .borderRadius(10)
    .border({ width: 1, color: '#E0E0E0' })
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.06)',
      offsetX: 0,
      offsetY: 2
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true
        console.info(`[SettingItem] ${this.label} pressed`)
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false
      }
    })
    .onClick(() => {
      console.info(`[SettingItem] ${this.label} clicked`)
      if (this.onTap) {
        this.onTap()
      }
    })
  }
}
