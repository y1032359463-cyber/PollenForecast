import { CALCULATE_DATA } from '../constants/Constants';
import { window } from '@kit.ArkUI';

@ObservedV2
export class ExchangeVM {
  @Trace results: string[] = [];
  @Trace keyboardShow: boolean = false;
  private _keyboardHeightChangeCallback = (data: number) => {
    this.keyboardShow = data ? true : false;
  };

  public onKeyboardChange() {
    window.getLastWindow(getContext())
      .then(currentWindow => currentWindow.on('keyboardHeightChange', this._keyboardHeightChangeCallback));
  }

  public offKeyboardChange() {
    window.getLastWindow(getContext())
      .then(currentWindow => currentWindow.off('keyboardHeightChange', this._keyboardHeightChangeCallback));
  }

  private static _instance: ExchangeVM;

  public static get instance() {
    if (!ExchangeVM._instance) {
      ExchangeVM._instance = new ExchangeVM();
    }
    return ExchangeVM._instance;
  }

  public resetResults() {
    this.results = Array.from<string>({ length: CALCULATE_DATA.length }).fill('');
  }

  public calcBaseValue(newText: string, index: number) {
    if (!newText) {
      this.resetResults();
      return;
    }
    let rate = Number(CALCULATE_DATA[index].bankConversionPri);
    const baseValue = rate / 100 * Number(newText);
    this.results = CALCULATE_DATA.map((item, i) => {
      if (i !== index) {
        return (100 / Number(item.bankConversionPri) * baseValue).toFixed(3).toString();
      } else {
        return newText;
      }
    })
  }

  public getCurrentTimeStr() {
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
  }
}