/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Logger from '../common/util/Logger';
import CalculateUtil from '../common/util/CalculateUtil';
import CheckEmptyUtil from '../common/util/CheckEmptyUtil';
import keysModel from '../viewmodel/PresskeysViewModel';
import { PressKeyItem } from '../viewmodel/PressKeysItem';
import { CommonConstants, Symbol } from '../common/constants/CommonConstants';
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

class DisplayToken {
  text: string = '';
  isOperator: boolean = false;
}

@Entry
@Component
struct HomePage {
  @State inputValue: string = '';
  @State calValue: string = '';
  private expressions: Array<string> = [];
  @State displayTokens: DisplayToken[] = [];
  @State lastBtnIsEqu: boolean = false;
  @State topSafeHeight: number = 0;
  uiContext = this.getUIContext();

  aboutToAppear() {
    window.getLastWindow(getContext(this)).then(win => {
      let area = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      this.topSafeHeight = px2vp(area.topRect.height);
      win.on('avoidAreaChange', (data) => {
        if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
          this.topSafeHeight = px2vp(data.area.topRect.height);
        }
      });
    })
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          // title
          Column() {
            Row() {
              Text($r('app.string.homepage_text1'))
                .width(128)
                .height(32)
                .fontSize(26)
                .fontWeight(700)
                .lineHeight(35)
                .fontColor('rgba(0, 0, 0, 0.9)')
                .fontFamily(CommonConstants.FONT_FAMILY_1)
                .margin({ left: CommonConstants.COMPONENT_BAY_SIZE_16 });
              Column() {
                Image($r('app.media.back'))
                  .objectFit(ImageFit.Contain)
                  .height(15);
              }
              .height(25)
              .margin({ right: CommonConstants.COMPONENT_BAY_SIZE_16 })
              .onClick(() => {
                // 清空
                this.inputSymbol(Symbol.CLEAN);
              });
            }
            .width('100%')
            .height(32)
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.SpaceBetween);
          }
          .width('100%')
          .height(32)
          .margin({ top: 12 });

          // input
          Column() {
            Column() {
              Text() {
                // 判断是否是符号，是则设置字体颜色为蓝色
                ForEach(this.displayTokens, (token: DisplayToken) => {
                  Span(token.text)
                    .fontColor(token.isOperator ? Color.Blue : Color.Black);
                }, (token: DisplayToken, index: number) => index + "_" + token.text)
              }
              .fontSize(24)
              .fontWeight(CommonConstants.FONT_WEIGHT_REGULAR)
              .fontFamily(CommonConstants.FONT_FAMILY_1)
              .lineHeight(32)
              .margin({ right: 16 })
              .textAlign(TextAlign.End);

              // 隐藏不用
              TextArea({ text: this.inputValue })
                .visibility(Visibility.None)
                .fontSize(24)
                .focusable(false)
                .lineHeight(32)
                .maxLines(6)
                .fontColor(Color.Transparent)
                .textAlign(TextAlign.End)
                .align(Alignment.End)
                .backgroundColor($r('app.color.all_back_color'));
            }
            .width(360)
            .height(190)
            .alignItems(HorizontalAlign.End)
            .justifyContent(FlexAlign.End);
          }
          .width(360)
          .height(190)
          .alignItems(HorizontalAlign.End)
          .margin({
            top: 20
          });

          // result
          Column() {
            Text(this.resultFormat(this.calValue))
              .fontSize(40)
              .fontWeight(CommonConstants.FONT_WEIGHT_MEDIUM)
              .fontFamily(CommonConstants.FONT_FAMILY_1)
              .fontColor($r('app.color.text_color'))
              .margin({ right: 16 })
              .textAlign(TextAlign.End)
              .maxLines(1);
          }
          .width(CommonConstants.FULL_PERCENT)
          .height($r('app.float.text_height'))
          .alignItems(HorizontalAlign.End)
          .margin({
            top: 7,
            right: 20,
            bottom: 16,
          });

          // 键盘
          Column() {
            Column() {
              // 外部
              Row() {
                ForEach(keysModel.getPressKeys(), (columnItem: Array<PressKeyItem>, columnItemIndex?: number) => {
                  // 键盘每一列
                  Column() {
                    ForEach(columnItem, (keyItem: PressKeyItem, keyItemIndex?: number) => {
                      Column() {
                        if (keyItem.flag === 0) {
                          Image(keyItem.source !== undefined ? keyItem.source : '')
                            .width(keyItem.width)
                            .height(keyItem.height);
                        } else if (keyItem.flag === 3) {
                          Text(keyItem.value)
                            .lineHeight(48)
                            .fontSize(36)
                            .fontColor(Color.White)
                            .width(keyItem.width)
                            .height(keyItem.height)
                            .textAlign(TextAlign.Center);
                        } else {
                          Text(keyItem.value)
                            .fontColor(keyItem.flag === 2 ? 'rgb(10, 89, 247)' : Color.Black)
                            .fontSize(keyItem.width)
                            .width(64)
                            .height(64)
                            .lineHeight(keyItem.height)
                            .textAlign(TextAlign.Center);
                        }
                      }
                      .shadow({ radius: 4, color: 'rgba(0, 0, 0, 0.15)' })
                      .margin({
                        top: 16,
                        bottom: 8
                      })
                      .width(64)
                      .height(
                        // 判断是否是最后一个元素，决定高度
                        ((columnItemIndex === (keysModel.getPressKeys().length - 1)) &&
                          (keyItemIndex === (columnItem.length - 1))) ?
                          148 : 64
                      )
                      .borderColor($r('app.color.border_color'))
                      .borderRadius(
                        ((columnItemIndex === (keysModel.getPressKeys().length - 1)) &&
                          (keyItemIndex === (columnItem.length - 1))) ?
                          40 : 32
                      )
                      .backgroundColor(
                        ((columnItemIndex === (keysModel.getPressKeys().length - 1)) &&
                          (keyItemIndex === (columnItem.length - 1))) ?
                          $r('app.color.equals_back_color') : 'rgb(255, 255, 255)'
                      )
                      .alignItems(HorizontalAlign.Center)
                      .justifyContent(FlexAlign.Center)
                      .onClick(() => {
                        // 根据flag判断是数字还是符号
                        if (keyItem.flag === 0 || keyItem.flag === 2 || keyItem.flag === 3) {
                          this.inputSymbol(keyItem.value);
                        } else {
                          if (this.lastBtnIsEqu) {
                            this.expressions = [];
                          }
                          this.lastBtnIsEqu = false;
                          this.inputNumber(keyItem.value);
                        }
                      });
                    }, (keyItem: PressKeyItem) => keyItem.value);
                  }
                  .height('100%')
                  .layoutWeight(1);
                }, (item: Array<Array<PressKeyItem>>, index: number) => "col_" + index);
              }
              .width('100%')
              .height('100%')
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.End);
            }
            .width('100%')
            .height('100%')
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.End);
          }
          .width('100%')
          .height(472)
          .layoutWeight(1)
          .borderRadius({ topLeft: 16, topRight: 16 })
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('rgb(241, 243, 245)');
        }
        .padding({ top: this.topSafeHeight })
      }
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.all_back_color'));
  }

  /**
   * Input Symbols.
   * 输入
   *
   * @param value Input Operators.
   */
  inputSymbol(value: string) {
    if (CheckEmptyUtil.isEmpty(value)) {
      return;
    }
    let len = this.expressions.length;
    this.lastBtnIsEqu = false;
    switch (value) {
      case Symbol.CLEAN:
        this.expressions = [];
        this.calValue = '';
        break;
      case Symbol.DEL:
        this.inputDelete(len);
        break;
      case Symbol.EQU:
        if (len === 0) {
          return;
        }
        this.getResult().then((result: boolean) => {
          if (!result) {
            return;
          }
          this.inputValue = this.calValue;
          this.calValue = '';
          this.expressions = [];
          this.expressions.push(this.inputValue);
          this.lastBtnIsEqu = true;
        });
        break;
      default:
        this.inputOperators(len, value);
        break;
    }
    this.formatInputValue();
  }

  /**
   * Enter numbers.
   * 结果
   *
   * @param value Enter numbers.
   */
  inputNumber(value: string) {
    if (CheckEmptyUtil.isEmpty(value)) {
      return;
    }
    let len = this.expressions.length;
    let last = len > 0 ? this.expressions[len - 1] : '';
    let secondLast = len > 1 ? this.expressions[len - CommonConstants.TWO] : undefined;
    if (!this.validateEnter(last, value)) {
      return;
    }
    if (!last) {
      this.expressions.push(value);
    } else if (!secondLast) {
      this.expressions[len - 1] += value;
    }
    if (secondLast && CalculateUtil.isSymbol(secondLast)) {
      this.expressions[len -1] += value;
    }
    if (secondLast && !CalculateUtil.isSymbol(secondLast)) {
      this.expressions.push(value);
    }
    this.formatInputValue();
    if (value !== CommonConstants.DOTS) {
      this.getResult();
    }
  }

  /**
   * Verify that you can enter.
   *
   * @param last Value of the last element.
   * @param value Current input value.
   * return Indicates whether to allow input.
   */
  validateEnter(last: string, value: string) {
    if (!last && value === CommonConstants.PERCENT_SIGN) {
      return false;
    }
    if ((last === CommonConstants.MIN) && (value === CommonConstants.PERCENT_SIGN)) {
      return false;
    }
    if (last.endsWith(CommonConstants.PERCENT_SIGN)) {
      return false;
    }
    if ((last.indexOf(CommonConstants.DOTS) !== -1) && (value === CommonConstants.DOTS)) {
      return false;
    }
    if ((last === '0') && (value !== CommonConstants.DOTS) &&
      (value !== CommonConstants.PERCENT_SIGN)) {
      return false;
    }
    return true;
  }

  /**
   * Delete Key Trigger.
   *
   * @param len Expression Length.
   */
  inputDelete(len: number) {
    if (len === 0) {
      return;
    }
    let last = this.expressions[len - 1];
    let lastLen = last.length;
    if (lastLen === 1) {
      this.expressions.pop();
      len = this.expressions.length;
    } else {
      this.expressions[len - 1] = last.slice(0, last.length - 1);
    }
    if (len === 0) {
      this.inputValue = '';
      this.calValue = '';
      return;
    }
    if (!CalculateUtil.isSymbol(this.expressions[len - 1])) {
      this.getResult();
    }
  }

  /**
   * Triggered when input is added, subtracted, multiplied, and divided.
   *
   * @param len Expression Length.
   * @param value Current Input Value.
   */
  inputOperators(len: number, value: string) {
    let last = len > 0 ? this.expressions[len - 1] : undefined;
    let secondLast = len > 1 ? this.expressions[len - CommonConstants.TWO] : undefined;
    if (!last && (value === Symbol.MIN)) {
      this.expressions.push(this.getSymbol(value));
      return;
    }
    if (!last) {
      return;
    }
    if (!CalculateUtil.isSymbol(last)) {
      this.expressions.push(this.getSymbol(value));
      return;
    }
    if ((value === Symbol.MIN) &&
      (last === CommonConstants.MIN || last === CommonConstants.ADD)) {
      this.expressions.pop();
      this.expressions.push(this.getSymbol(value));
      return;
    }
    if (!secondLast) {
      return;
    }
    if (value !== Symbol.MIN) {
      this.expressions.pop();
    }
    if (CalculateUtil.isSymbol(secondLast)) {
      this.expressions.pop();
    }
    this.expressions.push(this.getSymbol(value));
  }

  /**
   * Get Operator.
   *
   * @param value.
   * @return Operators.
   */
  getSymbol(value: string) {
    if (CheckEmptyUtil.isEmpty(value)) {
      return '';
    }
    let symbol = '';
    switch (value) {
      case Symbol.ADD:
        symbol = CommonConstants.ADD;
        break;
      case Symbol.MIN:
        symbol = CommonConstants.MIN;
        break;
      case Symbol.MUL:
        symbol = CommonConstants.MUL;
        break;
      case Symbol.DIV:
        symbol = CommonConstants.DIV;
        break;
      default:
        break;
    }
    return symbol;
  }

  /**
   * Make a deep copy of an expression.
   *
   * @return deep copy expression.
   */
  deepCopy(): Array<string> {
    let copyExpressions: Array<string> = Array.from(this.expressions);
    return copyExpressions;
  }

  /**
   * Obtaining Results.
   *
   * @return Whether the result is incorrect.
   */
  async getResult() {
    let calResult = CalculateUtil.parseExpression(this.deepCopy());
    if (calResult === 'NaN') {
      this.calValue = this.resourceToString($r('app.string.error'));
      return false;
    }
    this.calValue = calResult;
    return true;
  }

  /**
   * Number Formatting.
   *
   * @param value Formatting parameters.
   * @return Thousand percentile data.
   */
  resultFormat(value: string) {
    let reg = (value.indexOf('.') > -1) ? new RegExp('(\\d)(?=(\\d{3})+\\.)', 'g') : new RegExp('(\\d)(?=(?:\\d{3})+$)', 'g');
    return value.replace(reg, '$1,');
  }

  /**
   * Convert a resource file to a string.
   *
   * @param resource Resource file.
   * @return Character string converted from the resource file.
   */
  resourceToString(resource: Resource): string {
    if (CheckEmptyUtil.isEmpty(resource)) {
      return '';
    }
    let result = '';
    try {
      result = (this.uiContext.getHostContext() as common.UIAbilityContext).resourceManager.getStringSync(resource.id);
    } catch (error) {
      Logger.error('[CalculateModel] getResourceString fail: ' + JSON.stringify(error));
    }
    return result;
  }

  /**
   * Thousands in the formatting result.
   */
  formatInputValue() {
    let deepExpressions: Array<string> = [];
    let tokens: DisplayToken[] = [];
    this.deepCopy().forEach((item: string, index: number) => {
      let formatted = this.resultFormat(item);
      deepExpressions[index] = formatted;
      let isOp = CalculateUtil.isSymbol(item);
      tokens.push({ text: formatted, isOperator: isOp });
    });
    this.inputValue = deepExpressions.join('');
    this.displayTokens = tokens;
  }
}