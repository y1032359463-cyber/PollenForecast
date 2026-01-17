/**
 * 底部导航栏组件
 * 3个Tab：工时记录/数据统计/个人中心
 * 总高度：76vp（56vp 导航 + 20vp 安全区）
 */

export interface NavTab {
  icon: Resource
  label: string
  index: number
}

@Component
export struct BottomNav {
  @Prop currentIndex: number = 0 // 当前选中的Tab索引（改为@Prop）
  onTabChange?: (index: number) => void // 添加Tab切换回调
  
  private tabs: NavTab[] = [
    { icon: $r('app.media.ic_clock'), label: '工时记录', index: 0 },
    { icon: $r('app.media.ic_chart'), label: '数据统计', index: 1 },
    { icon: $r('app.media.ic_user'), label: '个人中心', index: 2 }
  ]

  @Builder
  TabItem(tab: NavTab) {
    Column({ space: 4 }) {
      Image(tab.icon)
        .width(24)
        .height(24)
        .fillColor(this.currentIndex === tab.index ? '#2196F3' : '#9E9E9E')

      Text(tab.label)
        .fontSize(12)
        .fontColor(this.currentIndex === tab.index ? '#2196F3' : '#9E9E9E')
        .fontWeight(this.currentIndex === tab.index ? FontWeight.Medium : FontWeight.Regular)
    }
    .width(120)
    .height(56)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (this.onTabChange) {
        this.onTabChange(tab.index)
      }
    })
  }

  build() {
    Column() {
      // 顶部分割线
      Divider()
        .color('#E0E0E0')
        .strokeWidth(1)

      // 导航栏主体
      Row() {
        ForEach(this.tabs, (tab: NavTab) => {
          this.TabItem(tab)
        })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceEvenly)

      // 底部安全区（20vp for HarmonyOS gesture navigation）
      Row()
        .width('100%')
        .height(20)
        .backgroundColor('#FFFFFF')
    }
    .width('100%')
  }
}
