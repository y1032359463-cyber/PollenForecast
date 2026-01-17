import { promptAction } from '@kit.ArkUI';
import { BaseNavTitle } from 'module_base_apis';
import { HistoryUtils, HistoryItem } from '../utils/HistoryUtils';
import { CalcConstants } from '../common/Constant';
import { CalculatorVM } from '../viewmodel/CalculatorVM'

@Builder
export function HistoryResultBuilder() {
  HistoryResult()
}


@ComponentV2
export struct HistoryResult {
  @Local calcHistory: Array<HistoryItem> = [];

  build() {
    NavDestination() {
      if (this.calcHistory.length) {
        Stack({ alignContent: Alignment.Bottom }) {
          List() {
            ForEach(this.calcHistory, (item: HistoryItem) => {
              ListItem() {
                this.ResultItem(item.value);
              }
            }, (item: HistoryItem) => item.id.toString())
          }.height('calc(100% - 68vp)')

          Row() {
            Image($r('app.media.ic_public_trash_active')).height(40).width(40).onClick(() => {
              this.calcHistory = [];
              HistoryUtils.clearHistoryResult();
              promptAction.showToast({
                message: '历史记录已清空！',
              })
            })
          }
        }
      } else {
        Row() {
          Column() {
            Image($r('app.media.no_result')).height(120).width(120)
            Text('暂无记录~~')
              .fontSize($r('sys.float.Body_L'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 24 })
          }
        }.height('calc(100% - 108vp)')

        Row() {
          Image($r('app.media.ic_public_trash')).height(40).width(40);
        }
      }
    }
    .title('历史记录')
    .backgroundColor(this.calcHistory.length  ? $r('sys.color.background_primary') : $r('sys.color.background_secondary'))
    .onReady(() => {
      this.calcHistory = HistoryUtils.getHistoryResult().reverse();
    })
  }

  getFirstEx(str: string): string {
    if (typeof str === 'undefined' || str === null || str === '') {
      return '';
    }
    return CalcConstants.OPERATORS_ARY.some(item => str.endsWith(item)) ? str.slice(0, str.length - 1) : str;
  }

  @Builder
  ResultItem(record: string) {
    Column() {
      Row() {
        Text(this.getFirstEx(record?.split('=')[0]))
          .fontSize($r('sys.float.Body_L'))
          .textAlign(TextAlign.Start)
          .width('100%')
          .fontColor($r('sys.color.font_secondary'))
          .lineHeight(21)
      }
      .padding({ left: 10 })
      .justifyContent(FlexAlign.Start)

      Row() {
        Text(`=${record?.split('=')[1]}`)
          .fontSize($r('sys.float.Subtitle_M'))
          .width('100%')
          .lineHeight(21)
          .textAlign(TextAlign.Start)
          .fontColor($r('sys.color.font_primary'))
      }
      .justifyContent(FlexAlign.Start)
      .padding({ left: 10 })
      .margin({ bottom: 13 });

      Divider().color($r('sys.color.comp_divider')).margin({ bottom: 12 })
    }
  }
}