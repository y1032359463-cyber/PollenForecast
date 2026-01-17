/*
 * 可爱计算器 ViewModel
 * 基于华为官方计算器逻辑，UI 修改为可爱风格
 */

import CalculateUtil from '../common/CalculateUtil';
import CheckEmptyUtil from '../common/CheckEmptyUtil';
import { CalcConstants, Symbol } from '../common/Constant';

@ObservedV2
export class CuteCalculatorVM {
  @Trace expressions: string[] = [];
  @Trace inputValue: string = '0';
  @Trace result: string = '0';
  @Trace lastBtnIsEqu: boolean = false;

  /**
   * 输入数字
   */
  inputNumber(value: string) {
    if (this.lastBtnIsEqu) {
      this.expressions = [];
      this.lastBtnIsEqu = false;
    }

    let len = this.expressions.length;
    if (!len && value === '.') {
      return;
    }

    let last = len > 0 ? this.expressions[len - 1] : '';
    let secondLast = len > 1 ? this.expressions[len - 2] : undefined;

    if (!this.validateEnter(last, value)) {
      return;
    }

    if (!last) {
      this.expressions.push(value);
    } else if (!secondLast) {
      this.expressions[len - 1] += value;
    }

    if (secondLast && CalculateUtil.isSymbol(secondLast)) {
      this.expressions[len - 1] += value;
    }
    if (secondLast && !CalculateUtil.isSymbol(secondLast)) {
      this.expressions.push(value);
    }

    this.updateDisplay();
    if (value !== '.') {
      this.calculateResult();
    }
  }

  /**
   * 输入运算符
   */
  inputOperator(value: string) {
    this.lastBtnIsEqu = false;
    let len = this.expressions.length;

    if (!len && value === '-') {
      this.expressions.push(value);
      this.updateDisplay();
      return;
    }

    if (!len) {
      return;
    }

    let last = this.expressions[len - 1];
    let secondLast = len > 1 ? this.expressions[len - 2] : undefined;

    if (!CalculateUtil.isSymbol(last)) {
      this.expressions.push(value);
      this.updateDisplay();
      return;
    }

    if ((value === '-') && (last === '-' || last === '+')) {
      this.expressions.pop();
      this.expressions.push(value);
      this.updateDisplay();
      return;
    }

    if (!secondLast) {
      return;
    }

    if (value !== '-') {
      this.expressions.pop();
    }
    if (CalculateUtil.isSymbol(secondLast)) {
      this.expressions.pop();
    }
    this.expressions.push(value);
    this.updateDisplay();
  }

  /**
   * 清空
   */
  clear() {
    this.expressions = [];
    this.inputValue = '0';
    this.result = '0';
    this.lastBtnIsEqu = false;
  }

  /**
   * 删除
   */
  delete() {
    let len = this.expressions.length;
    if (len === 0) {
      this.result = '0';
      this.inputValue = '0';
      return;
    }

    let last = this.expressions[len - 1];
    if (last.length === 1) {
      this.expressions.pop();
    } else {
      this.expressions[len - 1] = last.slice(0, -1);
    }

    len = this.expressions.length;
    if (len === 0) {
      this.inputValue = '0';
      this.result = '0';
      return;
    }

    if (!CalculateUtil.isSymbol(this.expressions[len - 1])) {
      this.calculateResult();
    } else {
      this.result = '';
    }

    this.updateDisplay();
  }

  /**
   * 计算等号
   */
  equals() {
    if (this.expressions.length === 0) {
      return;
    }

    let success = this.calculateResult();
    if (success) {
      this.inputValue = this.result;
      this.expressions = [];
      this.lastBtnIsEqu = true;
    }
  }

  /**
   * 验证输入
   */
  private validateEnter(last: string, value: string): boolean {
    if (!last && value === '%') {
      return false;
    }
    if (last.endsWith('%')) {
      return false;
    }
    if (last.indexOf('.') !== -1 && value === '.') {
      return false;
    }
    if (last === '0' && value !== '.' && value !== '%') {
      return false;
    }
    return true;
  }

  /**
   * 计算结果
   */
  private calculateResult(): boolean {
    if (this.expressions.length === 1 || 
        CalculateUtil.isSymbol(this.expressions[this.expressions.length - 1])) {
      return false;
    }

    let copyExpressions = [...this.expressions];
    let calResult = CalculateUtil.parseExpression(copyExpressions);

    if (calResult === 'NaN' || calResult === 'null' || CalculateUtil.isSymbol(calResult)) {
      this.result = 'Error';
      return false;
    }

    this.result = calResult;
    return true;
  }

  /**
   * 更新显示
   */
  private updateDisplay() {
    this.inputValue = this.expressions.join('') || '0';
  }
}
