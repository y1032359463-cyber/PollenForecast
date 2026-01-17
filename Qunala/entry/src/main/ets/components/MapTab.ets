/**
 * 地图 Tab 组件
 * 显示附近厕所位置，支持定位和搜索
 */
import { Colors } from '../constants/Colors';
import { MapConfig } from '../constants/Config';

@Component
export struct MapTab {
  @State userLocation: LocationInfo | null = null;
  @State nearbyToilets: ToiletMarker[] = [];
  @State isLoading: boolean = false;
  @State searchRadius: number = MapConfig.SEARCH_RADIUS_DEFAULT;
  
  // 地图配置
  private mapController: MapController = new MapController();
  
  aboutToAppear() {
    // 请求定位权限并获取用户位置
    this.requestLocation();
  }
  
  build() {
    Stack() {
      // 地图容器
      Column() {
        // TODO: 集成华为地图组件
        // Map({ controller: this.mapController })
        this.MapPlaceholder()
      }
      .width('100%')
      .height('100%')
      
      // 顶部搜索栏
      this.SearchBar()
      
      // 定位按钮（右下角）
      this.LocationButton()
      
      // 附近厕所列表（底部抽屉）
      this.NearbyDrawer()
      
      // 加载指示器
      if (this.isLoading) {
        LoadingProgress()
          .color(Colors.PRIMARY)
          .width(50)
          .height(50)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.MAP_BG)
  }
  
  /**
   * 地图占位符（待集成华为地图）
   */
  @Builder
  MapPlaceholder() {
    Column() {
      Text('🗺️')
        .fontSize(60)
        .margin({ bottom: 20 })
      
      Text('华为地图组件')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.TEXT_PRIMARY)
      
      Text('需要配置 Map Kit API Key')
        .fontSize(14)
        .fontColor(Colors.TEXT_SECONDARY)
        .margin({ top: 8 })
      
      Button('申请 API Key')
        .fontSize(14)
        .fontColor(Colors.BG_PRIMARY)
        .backgroundColor(Colors.PRIMARY)
        .borderRadius(20)
        .padding({ left: 24, right: 24, top: 10, bottom: 10 })
        .margin({ top: 20 })
        .onClick(() => {
          console.info('打开申请页面');
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Colors.MAP_BG)
  }
  
  /**
   * 顶部搜索栏
   */
  @Builder
  SearchBar() {
    Row() {
      // 搜索图标
      Text('🔍')
        .fontSize(20)
        .margin({ right: 10 })
      
      // 搜索输入框
      TextInput({ placeholder: '搜索附近的厕所' })
        .layoutWeight(1)
        .fontSize(15)
        .backgroundColor(Colors.BG_PRIMARY)
        .borderRadius(20)
        .padding({ left: 15, right: 15 })
        .placeholderColor(Colors.TEXT_HINT)
      
      // 筛选按钮
      Button('筛选')
        .fontSize(14)
        .fontColor(Colors.PRIMARY)
        .backgroundColor(Colors.BG_PRIMARY)
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .margin({ left: 10 })
        .onClick(() => {
          console.info('打开筛选面板');
        })
    }
    .width('90%')
    .height(50)
    .padding({ left: 15, right: 15 })
    .backgroundColor(Colors.BG_CARD)
    .borderRadius(25)
    .shadow({
      radius: 10,
      color: '#10000000',
      offsetY: 2
    })
    .margin({ top: 50 })
    .position({ x: '5%', y: 0 })
  }
  
  /**
   * 定位按钮（右下角）
   */
  @Builder
  LocationButton() {
    Button() {
      Column() {
        Text('📍')
          .fontSize(24)
      }
    }
    .width(56)
    .height(56)
    .backgroundColor(Colors.BG_PRIMARY)
    .borderRadius(28)
    .shadow({
      radius: 8,
      color: '#20000000',
      offsetY: 2
    })
    .position({ x: '85%', y: '75%' })
    .onClick(() => {
      this.requestLocation();
    })
  }
  
  /**
   * 附近厕所列表（底部抽屉）
   */
  @Builder
  NearbyDrawer() {
    Column() {
      // 拖动条
      Divider()
        .width(40)
        .height(4)
        .color(Colors.TEXT_HINT)
        .borderRadius(2)
        .margin({ top: 10, bottom: 10 })
      
      // 标题
      Row() {
        Text('附近厕所')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.TEXT_PRIMARY)
        
        Text(` (${this.nearbyToilets.length})`)
          .fontSize(14)
          .fontColor(Colors.TEXT_SECONDARY)
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 10 })
      
      // 厕所列表（占位）
      if (this.nearbyToilets.length === 0) {
        Column() {
          Text('🚽')
            .fontSize(40)
            .margin({ bottom: 10 })
          
          Text('暂无附近厕所数据')
            .fontSize(14)
            .fontColor(Colors.TEXT_SECONDARY)
        }
        .width('100%')
        .padding({ top: 40, bottom: 40 })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .backgroundColor(Colors.BG_PRIMARY)
    .borderRadius({ topLeft: 20, topRight: 20 })
    .shadow({
      radius: 15,
      color: '#30000000',
      offsetY: -3
    })
    .position({ x: 0, y: '80%' })
    .alignItems(HorizontalAlign.Center)
  }
  
  /**
   * 请求定位权限并获取位置
   */
  private requestLocation() {
    this.isLoading = true;
    
    // TODO: 实现定位逻辑
    setTimeout(() => {
      // 模拟定位成功
      this.userLocation = {
        latitude: 39.9042,
        longitude: 116.4074,
        address: '北京市东城区'
      };
      this.isLoading = false;
      console.info('定位成功', JSON.stringify(this.userLocation));
    }, 1000);
  }
}

/**
 * 地图控制器（占位）
 */
class MapController {
  // TODO: 实现地图控制方法
}

/**
 * 位置信息
 */
interface LocationInfo {
  latitude: number;
  longitude: number;
  address: string;
}

/**
 * 厕所标记
 */
interface ToiletMarker {
  id: string;
  latitude: number;
  longitude: number;
  name: string;
  distance: number;
}
