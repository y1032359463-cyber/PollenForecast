/*
 * HistoryPage - 历史记录页面
 * Calculation History Page
 */

import { ThemeColors, ThemeSizes } from '../common/ThemeConfig';
import { HistoryUtils, HistoryItem } from '../utils/HistoryUtils';
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { pasteboard } from '@kit.BasicServicesKit';

@Entry
@Component
struct HistoryPage {
  @State historyList: HistoryItem[] = [];  // 历史记录列表

  aboutToAppear() {
    // 加载历史记录
    this.loadHistory();
  }

  /**
   * 加载历史记录
   */
  private loadHistory(): void {
    this.historyList = HistoryUtils.getHistoryResult();
    console.info(`[HistoryPage] 加载历史记录: ${this.historyList.length}条`);
  }

  build() {
    Column() {
      // 状态栏安全区域占位
      Blank()
        .height(48)  // 状态栏高度约48vp
      
      // 标题栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back({ url: 'pages/MainPage' });
          })

        Text('历史记录')
          .fontSize(20)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })

        Blank()

        Text('清空')
          .fontSize(16)
          .fontColor(ThemeColors.PRIMARY_ORANGE)
          .onClick(() => {
            this.showClearConfirmDialog();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })

      if (this.historyList.length === 0) {
        // 空状态
        Column() {
          Text('暂无计算历史')
            .fontSize(16)
            .fontColor(ThemeColors.TEXT_SECONDARY)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 历史记录列表
        List({ space: 8 }) {
          ForEach(this.historyList.slice().reverse(), (item: HistoryItem, index: number) => {
            ListItem() {
              Row() {
                Column({ space: 4 }) {
                  Text(item.value)
                    .fontSize(16)
                    .fontColor(ThemeColors.TEXT_PRIMARY)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                // 删除按钮
                Image($r('app.media.ic_delete'))
                  .width(20)
                  .height(20)
                  .margin({ left: 12 })
                  .onClick(() => {
                    this.deleteHistoryItem(item.id);
                  })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(ThemeColors.BG_CARD)
              .borderRadius(12)
              .onClick(() => {
                // 点击复制到剪贴板
                this.copyToClipboard(item.value);
              })
            }
            .width('100%')
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_MAIN)
  }

  /**
   * 显示清空确认对话框
   */
  private showClearConfirmDialog(): void {
    promptAction.showDialog({
      title: '清空历史记录',
      message: '确定要清空所有历史记录吗？',
      buttons: [
        { text: '取消', color: ThemeColors.TEXT_SECONDARY },
        { text: '清空', color: ThemeColors.PRIMARY_ORANGE }
      ]
    }).then((data: promptAction.ShowDialogSuccessResponse) => {
      if (data.index === 1) {
        HistoryUtils.clearHistoryResult();
        this.loadHistory();
        promptAction.showToast({ message: '已清空历史记录', duration: 2000 });
      }
    }).catch((err: Error) => {
      console.error('Dialog error:', err);
    });
  }

  /**
   * 删除单条历史记录
   */
  private deleteHistoryItem(id: number): void {
    HistoryUtils.deleteItem(id);
    this.loadHistory();  // 重新加载列表
    console.info(`[HistoryPage] 删除历史记录: ${id}`);
    promptAction.showToast({ message: '已删除', duration: 1500 });
  }

  /**
   * 复制到剪贴板
   */
  private copyToClipboard(text: string): void {
    try {
      const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
      const systemPasteboard = pasteboard.getSystemPasteboard();
      systemPasteboard.setData(pasteData).then(() => {
        console.info(`[HistoryPage] 复制成功: ${text}`);
        promptAction.showToast({ message: '已复制到剪贴板', duration: 1500 });
      }).catch((err: Error) => {
        console.error(`[HistoryPage] 复制失败: ${err.message}`);
        promptAction.showToast({ message: '复制失败', duration: 1500 });
      });
    } catch (error) {
      console.error(`[HistoryPage] 剪贴板错误: ${error}`);
      promptAction.showToast({ message: '复制失败', duration: 1500 });
    }
  }
}
