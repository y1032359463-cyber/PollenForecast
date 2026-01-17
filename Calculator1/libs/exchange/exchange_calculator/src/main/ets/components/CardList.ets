import { CALCULATE_DATA } from '../constants/Constants';
import { StyleConstants } from '../constants/Styles';
import { ICurrencyData } from '../model/Types';
import { ExchangeVM } from '../viewmodel/ExchangeVM';
import { CardItem } from './CardItem';

@ComponentV2
export struct CardList {
  vm: ExchangeVM = ExchangeVM.instance;
  @Param cardBgColor: ResourceColor = $r('sys.color.background_primary')
  @Param listBgColor: ResourceColor = Color.Transparent;
  @Param space: string | number = StyleConstants.SPACE_8;

  aboutToAppear(): void {
    this.vm.resetResults();
    this.vm.onKeyboardChange();
  }

  aboutToDisappear(): void {
    this.vm.offKeyboardChange();
  }

  build() {
    List({ space: this.space }) {
      ForEach(CALCULATE_DATA, (data: ICurrencyData, index) => {
        CardItem({ index: index, cardBgColor: this.cardBgColor })
      }, (data: ICurrencyData, index) => JSON.stringify(data) + '_' + index)
    }
    .scrollBar(BarState.Off)
    .backgroundColor(this.listBgColor)
    .layoutWeight(1)
  }
}