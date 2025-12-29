/**
 * 花粉浓度预报 - 主入口
 * 底部 Tab 导航，包含4个页面
 */

import { PollenIndexView } from '../views/PollenIndexView'
import { RegionView } from '../views/RegionView'
import { MapView } from '../views/MapView'
import { SettingsView } from '../views/SettingsView'
import { VibrationUtils } from '../utils/VibrationUtils'

@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  @StorageLink('safeBottom') safeBottom: number = 28
  @StorageLink('pollenThemeColor') pollenThemeColor: string = '#4CAF50'

  // Tab 配置
  private tabItems: TabItem[] = [
    { title: '花粉指数', icon: $r('app.media.icon_leaf') },
    { title: '区域', icon: $r('app.media.icon_location') },
    { title: '地图', icon: $r('app.media.icon_map') },
    { title: '设置', icon: $r('app.media.icon_settings') }
  ]

  build() {
    Column() {
      // 内容区域
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        // Tab1: 花粉指数
        TabContent() {
          PollenIndexView()
        }
        .tabBar(this.TabBuilder(0, this.safeBottom))

        // Tab2: 区域
        TabContent() {
          RegionView()
        }
        .tabBar(this.TabBuilder(1, this.safeBottom))

        // Tab3: 地图
        TabContent() {
          MapView()
        }
        .tabBar(this.TabBuilder(2, this.safeBottom))

        // Tab4: 设置
        TabContent() {
          SettingsView()
        }
        .tabBar(this.TabBuilder(3, this.safeBottom))
      }
      .barMode(BarMode.Fixed)
      .barHeight(56 + this.safeBottom)
      .barBackgroundColor($r('app.color.navbar_background'))
      .onChange((index: number) => {
        VibrationUtils.triggerLight()
        this.currentIndex = index
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  // ========== 自定义 TabBar ==========
  @Builder
  TabBuilder(index: number, safeBottom: number) {
    Column() {
      Image(this.tabItems[index].icon)
        .width(24)
        .height(24)
        .fillColor(this.currentIndex === index ? this.pollenThemeColor : $r('app.color.text_secondary'))

      Text(this.tabItems[index].title)
        .fontSize(10)
        .fontColor(this.currentIndex === index ? this.pollenThemeColor : $r('app.color.text_secondary'))
        .margin({ top: 4 })
    }
    .width('100%')
    .height(56 + safeBottom)
    .padding({ bottom: safeBottom })
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.Transparent)
  }
}

// Tab项数据接口
interface TabItem {
  title: string
  icon: Resource
}
