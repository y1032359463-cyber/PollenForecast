/**
 * 记录 Tab 组件
 * 显示如厕记录统计和日历视图
 */
import { Colors } from '../constants/Colors';
import { ToiletRecord, RecordType, ComfortLevel } from '../models/ToiletRecord';

@Component
export struct RecordTab {
  @State recordList: ToiletRecord[] = [];
  @State weekStats: WeekStats = this.getEmptyWeekStats();
  @State selectedDate: Date = new Date();
  @State isLoading: boolean = false;
  
  aboutToAppear() {
    this.loadRecords();
  }
  
  build() {
    Column() {
      // 顶部统计卡片
      this.StatsCard()
      
      // 本周数据
      this.WeekDataCard()
      
      // 日历视图
      this.CalendarView()
      
      // 记录列表
      this.RecordList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.BG_PRIMARY)
  }
  
  /**
   * 顶部统计卡片
   */
  @Builder
  StatsCard() {
    Column() {
      Text('本周记录')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.TEXT_PRIMARY)
        .margin({ bottom: 20 })
      
      Row() {
        // 总次数
        this.StatItem('📝', '总次数', this.weekStats.totalCount.toString())
        
        Divider()
          .vertical(true)
          .height(40)
          .color(Colors.DIVIDER)
          .margin({ left: 15, right: 15 })
        
        // 平均时长
        this.StatItem('⏱️', '平均时长', this.weekStats.avgDuration + '分钟')
        
        Divider()
          .vertical(true)
          .height(40)
          .color(Colors.DIVIDER)
          .margin({ left: 15, right: 15 })
        
        // 舒适度
        this.StatItem('⭐', '舒适度', this.weekStats.avgComfort.toFixed(1))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('90%')
    .padding(20)
    .margin({ left: '5%', top: 16 })
    .backgroundColor(Colors.BG_CARD)
    .borderRadius(16)
    .shadow({
      radius: 10,
      color: '#10000000',
      offsetY: 2
    })
  }
  
  /**
   * 统计项
   */
  @Builder
  StatItem(icon: string, label: string, value: string) {
    Column() {
      Text(icon)
        .fontSize(24)
        .margin({ bottom: 8 })
      
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.PRIMARY)
        .margin({ bottom: 4 })
      
      Text(label)
        .fontSize(12)
        .fontColor(Colors.TEXT_SECONDARY)
    }
    .layoutWeight(1)
  }
  
  /**
   * 本周数据卡片
   */
  @Builder
  WeekDataCard() {
    Column() {
      Row() {
        Text('本周趋势')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.TEXT_PRIMARY)
        
        Blank()
        
        Text('查看详情 ›')
          .fontSize(14)
          .fontColor(Colors.PRIMARY)
      }
      .width('100%')
      .margin({ bottom: 16 })
      
      // 简单的柱状图（占位）
      Row() {
        ForEach(['周一', '周二', '周三', '周四', '周五', '周六', '周日'], (day: string, index: number) => {
          Column() {
            // 柱子
            Column()
              .width(30)
              .height(this.weekStats.dailyCounts[index] * 20)
              .backgroundColor(Colors.PRIMARY)
              .borderRadius(4)
              .margin({ bottom: 8 })
            
            // 标签
            Text(day.substring(1))
              .fontSize(12)
              .fontColor(Colors.TEXT_SECONDARY)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }, (day: string) => day)
      }
      .width('100%')
      .height(150)
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(VerticalAlign.Bottom)
    }
    .width('90%')
    .padding(20)
    .margin({ left: '5%', top: 16 })
    .backgroundColor(Colors.BG_CARD)
    .borderRadius(16)
    .shadow({
      radius: 10,
      color: '#10000000',
      offsetY: 2
    })
  }
  
  /**
   * 日历视图（简化版）
   */
  @Builder
  CalendarView() {
    Column() {
      Text('📅 选择日期')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.TEXT_PRIMARY)
      
      Text('日历组件开发中...')
        .fontSize(14)
        .fontColor(Colors.TEXT_SECONDARY)
        .margin({ top: 10 })
    }
    .width('90%')
    .padding(20)
    .margin({ left: '5%', top: 16 })
    .backgroundColor(Colors.BG_CARD)
    .borderRadius(16)
    .shadow({
      radius: 10,
      color: '#10000000',
      offsetY: 2
    })
  }
  
  /**
   * 记录列表
   */
  @Builder
  RecordList() {
    Column() {
      Row() {
        Text('历史记录')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.TEXT_PRIMARY)
        
        Blank()
        
        Button('+ 添加')
          .fontSize(14)
          .fontColor(Colors.BG_PRIMARY)
          .backgroundColor(Colors.PRIMARY)
          .borderRadius(16)
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .onClick(() => {
            console.info('添加记录');
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 10 })
      
      if (this.recordList.length === 0) {
        this.EmptyRecordView()
      } else {
        List({ space: 10 }) {
          ForEach(this.recordList, (record: ToiletRecord) => {
            ListItem() {
              this.RecordCard(record)
            }
          }, (record: ToiletRecord) => record.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, bottom: 16 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .layoutWeight(1)
    .margin({ top: 16 })
  }
  
  /**
   * 记录卡片
   */
  @Builder
  RecordCard(record: ToiletRecord) {
    Row() {
      // 左侧时间
      Column() {
        Text(this.formatTime(record.recordTime))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.TEXT_PRIMARY)
        
        Text(this.formatDate(record.recordTime))
          .fontSize(12)
          .fontColor(Colors.TEXT_SECONDARY)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ right: 16 })
      
      // 右侧信息
      Column() {
        Row() {
          Text(record.toiletName || '未知厕所')
            .fontSize(15)
            .fontColor(Colors.TEXT_PRIMARY)
            .layoutWeight(1)
          
          Text(this.getComfortEmoji(record.comfortLevel))
            .fontSize(18)
        }
        .width('100%')
        .margin({ bottom: 6 })
        
        if (record.duration) {
          Text(`时长: ${record.duration}分钟`)
            .fontSize(13)
            .fontColor(Colors.TEXT_SECONDARY)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Colors.BG_CARD)
    .borderRadius(12)
  }
  
  /**
   * 空记录视图
   */
  @Builder
  EmptyRecordView() {
    Column() {
      Text('📝')
        .fontSize(50)
        .margin({ bottom: 16 })
      
      Text('还没有记录')
        .fontSize(16)
        .fontColor(Colors.TEXT_SECONDARY)
      
      Text('开始记录你的如厕习惯吧')
        .fontSize(14)
        .fontColor(Colors.TEXT_HINT)
        .margin({ top: 8 })
    }
    .width('100%')
    .padding({ top: 60, bottom: 60 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
  
  /**
   * 加载记录
   */
  private loadRecords() {
    this.isLoading = true;
    
    // TODO: 从本地存储加载
    setTimeout(() => {
      this.recordList = [];
      this.weekStats = {
        totalCount: 0,
        avgDuration: 0,
        avgComfort: 0,
        dailyCounts: [0, 0, 0, 0, 0, 0, 0]
      };
      this.isLoading = false;
    }, 500);
  }
  
  /**
   * 获取舒适度表情
   */
  private getComfortEmoji(level?: ComfortLevel): string {
    if (!level) return '😐';
    switch (level) {
      case ComfortLevel.VERY_UNCOMFORTABLE: return '😣';
      case ComfortLevel.UNCOMFORTABLE: return '😕';
      case ComfortLevel.NORMAL: return '😐';
      case ComfortLevel.COMFORTABLE: return '😊';
      case ComfortLevel.VERY_COMFORTABLE: return '😄';
      default: return '😐';
    }
  }
  
  /**
   * 格式化时间
   */
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }
  
  /**
   * 格式化日期
   */
  private formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getMonth() + 1}/${date.getDate()}`;
  }
  
  /**
   * 获取空统计数据
   */
  private getEmptyWeekStats(): WeekStats {
    return {
      totalCount: 0,
      avgDuration: 0,
      avgComfort: 0,
      dailyCounts: [0, 0, 0, 0, 0, 0, 0]
    };
  }
}

/**
 * 本周统计数据
 */
interface WeekStats {
  totalCount: number;
  avgDuration: number;
  avgComfort: number;
  dailyCounts: number[];
}
