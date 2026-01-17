import { promptAction } from '@kit.ArkUI';
import {
  BalanceChangeType,
  BillCardItem,
  BillCardItemModel,
  ResourceUtil,
} from 'bill_base';
import {
  AccountingDB,
  BillManageUtil,
  UserTransaction,
} from 'bill_data_processing';
import {
  ConfirmParam,
  DialogInfo,
  DialogMap,
  EventBus,
  EventKey,
  Logger,
  RouterMap,
  RouterModule,
} from 'commonlib';

const TAG = '[BillDetailVM]';

@ObservedV2
export class BillDetailVM {
  @Trace bill: BillCardItemModel = new BillCardItemModel();

  @Computed
  public get isIncome() {
    return Boolean(this.bill?.type === BalanceChangeType.INCOME);
  }

  public initData() {
    const data = RouterModule.getNavParam<BillCardItem>({
      url: RouterMap.HOME_BILL_DETAIL,
    });
    if (data) {
      this.bill.accountId = data.accountId;
      this.bill.transactionId = data.transactionId;
      this.bill.resource = data.resource;
      this.bill.icon = data.icon;
      this.bill.title = data.title;
      this.bill.note = data.note;
      this.bill.amount = data.amount;
      this.bill.type = data.type;
      this.bill.date = data.date;
    }
  }

  public deleteBill() {
    RouterModule.push({
      url: DialogMap.COMMON_CONFIRM,
      param: {
        message: '删除后账单无法恢复，是否确认删除？',
      },
      onPop: async (value) => {
        const result = value.result as DialogInfo<ConfirmParam>;
        if (result.param?.isConfirm && this.bill) {
          await AccountingDB.deleteTransactions(this.bill.transactionId);
          promptAction.showToast({ message: '账单删除成功~' });
          EventBus.instance.emit(EventKey.GLOBAL_REFRESH_EVENT);
          RouterModule.pop(1);
        }
      },
    });
  }

  public editBill() {
    BillManageUtil.manageBill(this.bill, undefined, (data: UserTransaction) => {
      try {
        const resourceItem = ResourceUtil.getResourceItem(data.resource);
        this.bill.accountId = this.bill.accountId;
        this.bill.transactionId = this.bill.transactionId;
        this.bill.date = data.date;
        this.bill.resource = resourceItem.key;
        this.bill.title = resourceItem.name;
        this.bill.icon = resourceItem.icon;
        this.bill.amount = data.amount;
        this.bill.type = data.type;
        this.bill.note = data.note;
        EventBus.instance.emit(EventKey.GLOBAL_REFRESH_EVENT);
      } catch (error) {
        Logger.error(TAG, 'edit bill failed.error:' + JSON.stringify(error));
      }
    });
  }
}
