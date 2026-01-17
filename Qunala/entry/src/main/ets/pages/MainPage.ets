/**
 * 去哪拉 - 主页面
 * 包含4个Tab：地图、列表、记录、我的
 */
import { Colors } from '../constants/Colors';
import { MapTab } from '../components/MapTab';
import { ListTab } from '../components/ListTab';
import { RecordTab } from '../components/RecordTab';
import { ProfileTab } from '../components/ProfileTab';

@Entry
@Component
struct MainPage {
  @State currentTabIndex: number = 0;
  
  // Tab标签数据
  private tabData: TabItem[] = [
    { index: 0, icon: '🗺️', label: '地图' },
    { index: 1, icon: '📋', label: '列表' },
    { index: 2, icon: '📝', label: '记录' },
    { index: 3, icon: '👤', label: '我的' }
  ];
  
  build() {
    Column() {
      // Tab内容区域
      Tabs({
        barPosition: BarPosition.End,
        index: this.currentTabIndex
      }) {
        // Tab 1: 地图
        TabContent() {
          this.MapTabContent()
        }
        .tabBar(this.TabBarBuilder(this.tabData[0]))
        
        // Tab 2: 列表
        TabContent() {
          this.ListTabContent()
        }
        .tabBar(this.TabBarBuilder(this.tabData[1]))
        
        // Tab 3: 记录
        TabContent() {
          this.RecordTabContent()
        }
        .tabBar(this.TabBarBuilder(this.tabData[2]))
        
        // Tab 4: 我的
        TabContent() {
          this.ProfileTabContent()
        }
        .tabBar(this.TabBarBuilder(this.tabData[3]))
      }
      .barMode(BarMode.Fixed)
      .barHeight(56)
      .barBackgroundColor(Colors.BG_PRIMARY)
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.BG_PRIMARY)
  }
  
  /**
   * 自定义 TabBar（带动画效果）
   */
  @Builder
  TabBarBuilder(item: TabItem) {
    Column() {
      // 图标
      Text(item.icon)
        .fontSize(24)
        .fontColor(this.currentTabIndex === item.index ? Colors.PRIMARY : Colors.TEXT_HINT)
      
      // 文字
      Text(item.label)
        .fontSize(12)
        .fontColor(this.currentTabIndex === item.index ? Colors.PRIMARY : Colors.TEXT_HINT)
        .fontWeight(this.currentTabIndex === item.index ? FontWeight.Bold : FontWeight.Normal)
        .margin({ top: 4 })
      
      // 下划线指示器
      if (this.currentTabIndex === item.index) {
        Divider()
          .width(20)
          .height(3)
          .color(Colors.PRIMARY)
          .borderRadius(1.5)
          .margin({ top: 4 })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
  
  /**
   * 地图 Tab 内容
   */
  @Builder
  MapTabContent() {
    MapTab()
  }
  
  /**
   * 列表 Tab 内容
   */
  @Builder
  ListTabContent() {
    ListTab()
  }
  
  /**
   * 记录 Tab 内容
   */
  @Builder
  RecordTabContent() {
    RecordTab()
  }
  
  /**
   * 我的 Tab 内容
   */
  @Builder
  ProfileTabContent() {
    ProfileTab()
  }
}

/**
 * Tab项数据结构
 */
interface TabItem {
  index: number;
  icon: string;
  label: string;
}
