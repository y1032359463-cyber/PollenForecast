/**
 * 数据导出页面
 */

import { DataExportService, ExportFormat } from '../common/utils/DataExportService';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct DataExportPage {
  @State exportFormat: ExportFormat = ExportFormat.CSV;
  @State isExporting: boolean = false;
  @State lastExportPath: string = '';
  private exportService = DataExportService.getInstance();

  /**
   * 执行导出
   */
  async performExport() {
    this.isExporting = true;

    try {
      const filePath = await this.exportService.exportAllData(this.exportFormat);
      this.lastExportPath = filePath;

      promptAction.showToast({
        message: '导出成功!',
        duration: 2000
      });
    } catch (error) {
      promptAction.showToast({
        message: '导出失败,请重试',
        duration: 2000
      });
      console.error(`Export error: ${error}`);
    } finally {
      this.isExporting = false;
    }
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('←')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.getUIContext().getRouter().back();
          })

        Text('数据导出')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 12 })
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.Start)

      // 格式选择
      Column() {
        Text('导出格式')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 12 })

        Row() {
          Button('CSV格式')
            .width('48%')
            .backgroundColor(this.exportFormat === ExportFormat.CSV ? '#FF6B35' : '#E0E0E0')
            .fontColor(this.exportFormat === ExportFormat.CSV ? Color.White : '#666666')
            .onClick(() => {
              this.exportFormat = ExportFormat.CSV;
            })

          Button('JSON格式')
            .width('48%')
            .backgroundColor(this.exportFormat === ExportFormat.JSON ? '#FF6B35' : '#E0E0E0')
            .fontColor(this.exportFormat === ExportFormat.JSON ? Color.White : '#666666')
            .onClick(() => {
              this.exportFormat = ExportFormat.JSON;
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('90%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 16 })

      // 格式说明
      Column() {
        Text('格式说明')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        if (this.exportFormat === ExportFormat.CSV) {
          Text('CSV格式适合用Excel打开查看\n包含: 日期、任务ID、目标值、完成值、状态')
            .fontSize(12)
            .fontColor('#666666')
            .lineHeight(20)
        } else {
          Text('JSON格式适合程序读取\n包含完整的任务数据结构')
            .fontSize(12)
            .fontColor('#666666')
            .lineHeight(20)
        }
      }
      .width('90%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 16 })

      // 导出按钮
      Button(this.isExporting ? '导出中...' : '开始导出')
        .width('90%')
        .height(48)
        .fontSize(16)
        .backgroundColor('#4CAF50')
        .margin({ top: 24 })
        .enabled(!this.isExporting)
        .onClick(() => {
          this.performExport();
        })

      // 导出路径显示
      if (this.lastExportPath) {
        Column() {
          Text('最近导出')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })

          Text(this.lastExportPath)
            .fontSize(12)
            .fontColor('#666666')
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('90%')
        .padding(16)
        .backgroundColor('#E8F5E9')
        .borderRadius(12)
        .margin({ top: 16 })
      }

      // 说明文字
      Column() {
        Text('📝 注意事项')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        Text('• 数据保存在应用私有目录\n• 卸载应用会清空导出文件\n• 建议定期备份到云盘\n• 导出包含所有历史打卡记录')
          .fontSize(12)
          .fontColor('#666666')
          .lineHeight(20)
      }
      .width('90%')
      .padding(16)
      .backgroundColor('#FFF3E0')
      .borderRadius(12)
      .margin({ top: 16 })

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
