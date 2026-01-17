/**
 * 列表 Tab 组件
 * 显示附近厕所列表，支持排序和筛选
 */
import { Colors } from '../constants/Colors';
import { Toilet, ToiletType } from '../models/Toilet';

@Component
export struct ListTab {
  @State toiletList: Toilet[] = [];
  @State isLoading: boolean = false;
  @State sortType: SortType = SortType.DISTANCE;
  @State filterType: ToiletType | null = null;
  
  aboutToAppear() {
    this.loadToiletList();
  }
  
  build() {
    Column() {
      // 顶部筛选栏
      this.FilterBar()
      
      // 厕所列表
      if (this.isLoading) {
        this.LoadingView()
      } else if (this.toiletList.length === 0) {
        this.EmptyView()
      } else {
        this.ToiletListView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.BG_PRIMARY)
  }
  
  /**
   * 顶部筛选栏
   */
  @Builder
  FilterBar() {
    Row() {
      // 排序按钮
      Button(`排序: ${this.getSortLabel()}`)
        .fontSize(14)
        .fontColor(Colors.TEXT_PRIMARY)
        .backgroundColor(Colors.BG_CARD)
        .borderRadius(20)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .onClick(() => {
          this.toggleSort();
        })
      
      Blank()
      
      // 筛选按钮
      Button('筛选')
        .fontSize(14)
        .fontColor(Colors.PRIMARY)
        .backgroundColor(Colors.BG_CARD)
        .borderRadius(20)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .onClick(() => {
          console.info('打开筛选');
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 10 })
  }
  
  /**
   * 厕所列表视图
   */
  @Builder
  ToiletListView() {
    List({ space: 12 }) {
      ForEach(this.toiletList, (toilet: Toilet) => {
        ListItem() {
          this.ToiletCard(toilet)
        }
      }, (toilet: Toilet) => toilet.id)
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16, top: 6 })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
  
  /**
   * 厕所卡片（黄色大卡片设计）
   */
  @Builder
  ToiletCard(toilet: Toilet) {
    Column() {
      // 顶部：名称和距离
      Row() {
        Text(toilet.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.TEXT_PRIMARY)
          .layoutWeight(1)
        
        Text('500m')
          .fontSize(14)
          .fontColor(Colors.PRIMARY)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .margin({ bottom: 8 })
      
      // 地址
      Row() {
        Text('📍')
          .fontSize(14)
          .margin({ right: 4 })
        
        Text(toilet.address)
          .fontSize(14)
          .fontColor(Colors.TEXT_SECONDARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .margin({ bottom: 8 })
      
      // 设施标签
      Row() {
        this.FacilityTag('♿ 无障碍', toilet.hasDisabledAccess)
        this.FacilityTag('🚻 免费', toilet.type === ToiletType.PUBLIC)
        this.FacilityTag('⭐ ' + toilet.rating.toFixed(1), true)
      }
      .width('100%')
      
      // 底部按钮
      Row() {
        Button('导航')
          .fontSize(14)
          .fontColor(Colors.BG_PRIMARY)
          .backgroundColor(Colors.PRIMARY)
          .borderRadius(18)
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
          .layoutWeight(1)
          .onClick(() => {
            console.info('导航到', toilet.name);
          })
        
        Button('详情')
          .fontSize(14)
          .fontColor(Colors.PRIMARY)
          .backgroundColor(Colors.BG_PRIMARY)
          .borderRadius(18)
          .border({ width: 1, color: Colors.PRIMARY })
          .padding({ left: 20, right: 20, top: 8, bottom: 8 })
          .layoutWeight(1)
          .margin({ left: 10 })
          .onClick(() => {
            console.info('查看详情', toilet.name);
          })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Colors.BG_CARD)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: '#10000000',
      offsetY: 2
    })
  }
  
  /**
   * 设施标签
   */
  @Builder
  FacilityTag(label: string, show: boolean) {
    if (show) {
      Text(label)
        .fontSize(12)
        .fontColor(Colors.TEXT_SECONDARY)
        .backgroundColor(Colors.BG_PRIMARY)
        .borderRadius(10)
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .margin({ right: 8 })
    }
  }
  
  /**
   * 空视图
   */
  @Builder
  EmptyView() {
    Column() {
      Text('🚽')
        .fontSize(60)
        .margin({ bottom: 20 })
      
      Text('附近暂无厕所数据')
        .fontSize(16)
        .fontColor(Colors.TEXT_SECONDARY)
      
      Text('试试扩大搜索范围')
        .fontSize(14)
        .fontColor(Colors.TEXT_HINT)
        .margin({ top: 8 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
  
  /**
   * 加载视图
   */
  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .color(Colors.PRIMARY)
        .width(50)
        .height(50)
      
      Text('加载中...')
        .fontSize(14)
        .fontColor(Colors.TEXT_SECONDARY)
        .margin({ top: 16 })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
  
  /**
   * 加载厕所列表
   */
  private loadToiletList() {
    this.isLoading = true;
    
    // TODO: 从数据源加载
    setTimeout(() => {
      // 模拟数据（使用完整的 Toilet 对象）
      this.toiletList = [];
      this.isLoading = false;
    }, 800);
  }
  
  /**
   * 切换排序方式
   */
  private toggleSort() {
    this.sortType = this.sortType === SortType.DISTANCE 
      ? SortType.RATING 
      : SortType.DISTANCE;
  }
  
  /**
   * 获取排序标签
   */
  private getSortLabel(): string {
    return this.sortType === SortType.DISTANCE ? '距离' : '评分';
  }
}

/**
 * 排序类型
 */
enum SortType {
  DISTANCE,
  RATING
}
