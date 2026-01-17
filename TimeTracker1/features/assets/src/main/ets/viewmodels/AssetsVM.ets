import { promptAction } from '@kit.ArkUI';
import { AssetRecordItem, AssetTypeUtil } from 'asset_base';
import { AccountingDB, AssetProcessingModel } from 'bill_data_processing';
import { RouterMap, RouterModule } from 'commonlib';

@ObservedV2
export class AssetsVM {
  @Trace anonymous: boolean = false;
  @Trace typeList = AssetTypeUtil.displayTypeList;
  @Trace assetProcessing: AssetProcessingModel = new AssetProcessingModel();

  public initData() {
    this.assetProcessing.getAssetReport();
  }

  public handleEyeClick() {
    this.anonymous = !this.anonymous;
  }

  public async jumpToDetailPage(item: AssetRecordItem) {
    RouterModule.push({
      url: RouterMap.ASSET_BILL_DETAIL,
      param: item,
      onPop: () => {
        this.assetProcessing.getAssetReport();
      },
    });
  }

  public async deleteAsset(id: number) {
    promptAction
      .showDialog({
        message:
          '删除资产账户会取消所有该账户名下的记账数据关联，并且无法恢复关联。请确认是否删除？',
        buttons: [
          {
            text: '取消',
            color: $r('app.color.font_color_level1'),
          },
          {
            text: '删除',
            color: $r('app.color.icon_color_warning'),
          },
        ],
        alignment: DialogAlignment.Bottom,
      })
      .then(async (data) => {
        if (data.index === 1) {
          await AccountingDB.deleteAssetAccount(id);
          promptAction.showToast({ message: '资产账户删除成功~' });
          await this.assetProcessing.getAssetReport();
        }
      });
  }
}
