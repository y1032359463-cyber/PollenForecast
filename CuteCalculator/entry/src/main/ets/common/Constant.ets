/*
 * Simplified constants for CuteCalculator
 * Based on Huawei's Standard Calculator
 */

export const enum BUTTON_TYPE {
  // 数字按钮
  NUMBER,
  // 运算符按钮
  OPERATOR,
  // 功能按钮
  FUNCTION
}

/**
 * 按钮配置类型
 */
export interface ButtonConfig {
  value: string;              // 按钮值
  image: Resource;            // 按钮图片资源
  type: BUTTON_TYPE;          // 按钮类型
  gridSpan?: number;          // 占用格数(默认1)
}

/**
 * 计算器常量
 */
export class CalcConstants {
  /**
   * 运算符集合
   */
  static readonly OPERATORS: string = '+-×÷';

  /**
   * 加法
   */
  static readonly ADD: string = '+';

  /**
   * 减法
   */
  static readonly MIN: string = '-';

  /**
   * 乘法
   */
  static readonly MUL: string = '×';

  /**
   * 除法
   */
  static readonly DIV: string = '÷';

  /**
   * 百分号
   */
  static readonly PERCENT_SIGN: string = '%';

  /**
   * 小数点
   */
  static readonly DOTS: string = '.';

  /**
   * 等号
   */
  static readonly EQUAL: string = '=';

  /**
   * 清空
   */
  static readonly CLEAR: string = 'C';

  /**
   * 删除
   */
  static readonly DELETE: string = 'DEL';
  
  /**
   * 删除(小写)
   */
  static readonly DEL: string = 'del';
  
  /**
   * 乘法(英文)
   */
  static readonly MULTIPLY: string = '×';
  
  /**
   * 除法(英文)
   */
  static readonly DIVIDE: string = '÷';
  
  /**
   * 减法(英文)
   */
  static readonly MINUS: string = '-';
  
  /**
   * 加法(英文)
   */
  static readonly PLUS: string = '+';

  /**
   * 零
   */
  static readonly ZERO: string = '0';

  /**
   * 数字10
   */
  static readonly TEN: number = 10;

  /**
   * 数字100
   */
  static readonly ONE_HUNDRED: string = '100';

  /**
   * 最大显示长度(大字体)
   */
  static readonly MAX_LEN_LARGE: number = 12;

  /**
   * 最大显示长度(小字体)
   */
  static readonly MAX_LEN_SMALL: number = 16;

  /**
   * 显示结果的最大长度
   */
  static readonly MAX_RESULT_LEN: number = 200;

  /**
   * 小数点0
   */
  static readonly ZERO_DOTS: string = '0.';

  /**
   * 科学计数法标识
   */
  static readonly E: string = 'e';

  /**
   * 数字最大长度
   */
  static readonly NUM_MAX_LEN: number = 16;
}

/**
 * 运算符优先级
 */
export enum Priority {
  LOW = 0,
  MEDIUM = 1,
  HIGH = 2
}

/**
 * 运算符枚举
 */
export enum SymbolicEnumeration {
  ADD = '+',
  MIN = '-',
  MUL = '×',
  DIV = '÷'
}

/**
 * Symbol value.
 */
export enum Symbol {
  ADD = '+',
  MIN = '-',
  MUL = '×',
  DIV = '÷',
  CLEAN = 'C',
  DEL = 'del',
  EQU = '=',
  PERCENT = '%',
  DOT = '.'
}

/**
 * 卡通角色状态
 */
export const enum CharacterState {
  NORMAL,       // 正常状态
  CALCULATING,  // 计算中
  RESULT,       // 显示结果
  ERROR         // 错误状态
}

/**
 * AppStorage映射键名
 */
export class AppStorageMap {
  static readonly HISTORY_RESULT: string = 'history_result';
}
