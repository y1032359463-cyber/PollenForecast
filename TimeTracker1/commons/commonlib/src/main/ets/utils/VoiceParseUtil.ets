/**
 * 语音速记工具类 - 非AI方案
 * 通过固定模板+关键词规则匹配+鸿蒙原生语音转文字实现精准拆分
 */

import { commonPhrasesCache } from './CommonPhrasesCache';
import { parseRuleManager } from './ParseRuleManager';

export class VoiceParseUtil {
  /**
   * 从语音文本中提取工时记录字段
   * @param voiceText 语音识别后的文本
   * @returns 提取的字段对象
   */
  static async parseWorkRecord(voiceText: string): Promise<WorkRecordFields> {
    // 初始化结果对象
    const result: WorkRecordFields = {
      date: VoiceParseUtil.getCurrentDate(),
      taskName: '',
      normalHours: 0,
      overtimeHours: 0,
      quantity: 0,
      unitPrice: 0,
      templateType: TemplateType.SIMPLIFIED
    };

    // 使用常用语缓存增强语音文本
    const enhancedText = await commonPhrasesCache.enhanceVoiceText(voiceText);
    
    // 清理文本，去除多余空格和标记
    const cleanText = enhancedText.replace(/\[|\]/g, '').replace(/\s+/g, ' ').trim();
    
    // 获取解析规则
    const dateRules = await parseRuleManager.getRulesByType('date');
    const overtimeRules = await parseRuleManager.getRulesByType('overtime');
    const hoursRules = await parseRuleManager.getRulesByType('hours');
    const quantityRules = await parseRuleManager.getRulesByType('quantity');
    const unitPriceRules = await parseRuleManager.getRulesByType('unitPrice');
    
    // 提取日期（按规则优先级）
    for (const rule of dateRules) {
      const regex = new RegExp(rule.regex, 'gi');
      const match = cleanText.match(regex);
      if (match) {
        result.date = VoiceParseUtil.parseDate(match[0]);
        await parseRuleManager.updateRuleUsage(rule.id, true);
        break;
      } else {
        await parseRuleManager.updateRuleUsage(rule.id, false);
      }
    }

    // 提取加班工时（按规则优先级）
    for (const rule of overtimeRules) {
      const regex = new RegExp(rule.regex, 'gi');
      const match = cleanText.match(regex);
      if (match && match[1]) {
        result.overtimeHours = parseFloat(match[1]);
        result.templateType = TemplateType.TIMED;
        await parseRuleManager.updateRuleUsage(rule.id, true);
        break;
      } else {
        await parseRuleManager.updateRuleUsage(rule.id, false);
      }
    }

    // 提取正常工时（排除加班工时部分）
    let textWithoutOvertime = cleanText;
    const overtimeRegex = /加班\s*(\d+(?:\.\d+)?)(?:[小时|钟|点])?/gi;
    textWithoutOvertime = textWithoutOvertime.replace(overtimeRegex, '');
    
    for (const rule of hoursRules) {
      const regex = new RegExp(rule.regex, 'gi');
      const match = textWithoutOvertime.match(regex);
      if (match && match[1]) {
        result.normalHours = parseFloat(match[1]);
        if (result.templateType === TemplateType.SIMPLIFIED) {
          result.templateType = TemplateType.TIMED;
        }
        await parseRuleManager.updateRuleUsage(rule.id, true);
        break;
      } else {
        await parseRuleManager.updateRuleUsage(rule.id, false);
      }
    }

    // 检查是否为计件类（按规则优先级）
    for (const rule of quantityRules) {
      const regex = new RegExp(rule.regex, 'gi');
      const match = cleanText.match(regex);
      if (match && match[1]) {
        result.quantity = parseInt(match[1]);
        result.templateType = TemplateType.PIECEWORK;
        await parseRuleManager.updateRuleUsage(rule.id, true);
        break;
      } else {
        await parseRuleManager.updateRuleUsage(rule.id, false);
      }
    }
    
    for (const rule of unitPriceRules) {
      const regex = new RegExp(rule.regex, 'gi');
      const match = cleanText.match(regex);
      if (match && match[1]) {
        result.unitPrice = parseFloat(match[1]);
        result.templateType = TemplateType.PIECEWORK;
        await parseRuleManager.updateRuleUsage(rule.id, true);
        break;
      } else {
        await parseRuleManager.updateRuleUsage(rule.id, false);
      }
    }

    // 提取任务名（排除日期、时长、加班、单价相关关键词）
    let taskText = cleanText;
    
    // 移除日期
    taskText = taskText.replace(/(\d{1,2}月\d{1,2}日)|今天|昨天|明天/g, '');
    // 移除加班相关
    taskText = taskText.replace(/加班\s*(\d+(?:\.\d+)?)(?:[小时|钟|点])?/g, '');
    // 移除时长相关
    taskText = taskText.replace(/(\d+(?:\.\d+)?)(?:[小时|钟|点])/g, '');
    // 移除计件相关
    taskText = taskText.replace(/(\d+)(?:件|个|块|箱|套|份|次)/g, '');
    taskText = taskText.replace(/(?:每件|每个|每块|每箱|每套|每份|每次)\s*(\d+(?:\.\d+)?)(?:元|角)/g, '');
    
    // 清理并提取任务名
    result.taskName = taskText.replace(/\s+/g, ' ').trim();
    
    // 将识别到的任务名和单价添加到缓存
    if (result.taskName) {
      commonPhrasesCache.addTaskName(result.taskName);
    }
    
    if (result.unitPrice > 0) {
      // 构建单价短语并添加到缓存
      const unitPricePhrase = `每件${result.unitPrice}元`;
      commonPhrasesCache.addUnitPrice(unitPricePhrase);
    }

    return result;
  }

  /**
   * 解析日期字符串
   * @param dateStr 日期字符串（如：6月15日、今天、昨天）
   * @returns 格式化后的日期字符串（YYYY-MM-DD）
   */
  private static parseDate(dateStr: string): string {
    const today = new Date();
    let year = today.getFullYear();
    let month = today.getMonth() + 1;
    let day = today.getDate();

    if (dateStr === '今天') {
      // 使用当前日期
    } else if (dateStr === '昨天') {
      // 使用昨天日期
      const yesterday = new Date(today);
      yesterday.setDate(today.getDate() - 1);
      year = yesterday.getFullYear();
      month = yesterday.getMonth() + 1;
      day = yesterday.getDate();
    } else {
      // 解析具体日期（如：6月15日）
      const dateMatch = dateStr.match(/(\d{1,2})月(\d{1,2})日/);
      if (dateMatch) {
        month = parseInt(dateMatch[1]);
        day = parseInt(dateMatch[2]);
      }
    }

    // 格式化日期字符串
    return `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`;
  }

  /**
   * 获取当前日期
   * @returns 格式化后的日期字符串（YYYY-MM-DD）
   */
  private static getCurrentDate(): string {
    const today = new Date();
    const year = today.getFullYear();
    const month = (today.getMonth() + 1).toString().padStart(2, '0');
    const day = today.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }
}

/**
 * 模板类型枚举
 */
export enum TemplateType {
  /** 计时类 */
  TIMED = 'timed',
  /** 计件类 */
  PIECEWORK = 'piecework',
  /** 简化版 */
  SIMPLIFIED = 'simplified'
}

/**
 * 工时记录字段接口
 */
export interface WorkRecordFields {
  /** 日期（YYYY-MM-DD） */
  date: string;
  /** 任务名 */
  taskName: string;
  /** 正常工时 */
  normalHours: number;
  /** 加班工时 */
  overtimeHours: number;
  /** 计件数量 */
  quantity: number;
  /** 单价 */
  unitPrice: number;
  /** 匹配的模板类型 */
  templateType: TemplateType;
}
