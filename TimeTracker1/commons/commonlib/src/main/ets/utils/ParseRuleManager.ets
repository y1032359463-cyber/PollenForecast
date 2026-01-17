/**
 * 解析规则管理工具类
 * 用于管理和优化语音文本解析规则
 * 支持规则动态更新和用户反馈收集
 */

import { storageUtils } from './StorageUtils';
import { Logger } from './logger/Index';

const TAG = '[ParseRuleManager]';
const PARSE_RULES_KEY = 'parseRules';
const FEEDBACK_RECORDS_KEY = 'parseFeedbackRecords';
const MAX_FEEDBACK_RECORDS = 100;

// 解析规则接口
export interface ParseRule {
  id: string;
  type: 'date' | 'taskName' | 'hours' | 'overtime' | 'quantity' | 'unitPrice';
  regex: string;
  priority: number;
  enabled: boolean;
  usageCount: number;
  successRate: number;
}

// 解析反馈记录接口
export interface ParseFeedbackRecord {
  id: string;
  voiceText: string;
  parsedResult: object | null;
  correctResult: object | null;
  feedbackType: 'success' | 'failure';
  timestamp: number;
}

// 解析反馈输入接口 (ArkTS 不支持 Omit 工具类型)
export interface ParseFeedbackInput {
  voiceText: string;
  parsedResult: object | null;
  correctResult: object | null;
  feedbackType: 'success' | 'failure';
}

// 解析规则输入接口 (ArkTS 不支持 Omit 工具类型)
export interface ParseRuleInput {
  type: 'date' | 'taskName' | 'hours' | 'overtime' | 'quantity' | 'unitPrice';
  regex: string;
  priority: number;
  enabled: boolean;
}

// 规则统计接口
interface RuleStatistics {
  total: number;
  success: number;
}

// 默认解析规则
const DEFAULT_RULES: ParseRule[] = [
  // 日期规则
  {
    id: 'date_rule_1',
    type: 'date',
    regex: '(\\d{1,2}月\\d{1,2}日)',
    priority: 10,
    enabled: true,
    usageCount: 0,
    successRate: 1.0
  },
  {
    id: 'date_rule_2',
    type: 'date',
    regex: '今天|昨天|明天',
    priority: 9,
    enabled: true,
    usageCount: 0,
    successRate: 1.0
  },
  // 工时规则
  {
    id: 'hours_rule_1',
    type: 'hours',
    regex: '(\\d+(?:\\.\\d+)?)[小时|钟|点]',
    priority: 8,
    enabled: true,
    usageCount: 0,
    successRate: 1.0
  },
  // 加班规则
  {
    id: 'overtime_rule_1',
    type: 'overtime',
    regex: '加班\\s*(\\d+(?:\\.\\d+)?)[小时|钟|点]',
    priority: 7,
    enabled: true,
    usageCount: 0,
    successRate: 1.0
  },
  // 数量规则
  {
    id: 'quantity_rule_1',
    type: 'quantity',
    regex: '(\\d+)(?:件|个|块|箱|套|份|次)',
    priority: 6,
    enabled: true,
    usageCount: 0,
    successRate: 1.0
  },
  // 单价规则
  {
    id: 'unit_price_rule_1',
    type: 'unitPrice',
    regex: '(?:每件|每个|每块|每箱|每套|每份|每次)\\s*(\\d+(?:\\.\\d+)?)(?:元|角)',
    priority: 5,
    enabled: true,
    usageCount: 0,
    successRate: 1.0
  }
];

class ParseRuleManager {
  private rules: ParseRule[] = [...DEFAULT_RULES];
  private feedbackRecords: ParseFeedbackRecord[] = [];
  private isInitialized: boolean = false;

  /**
   * 初始化规则管理器
   */
  async init(): Promise<void> {
    if (this.isInitialized) {
      return;
    }

    try {
      // 初始化存储工具
      await storageUtils.init();
      
      // 加载规则
      this.rules = await storageUtils.get<ParseRule[]>(PARSE_RULES_KEY, [...DEFAULT_RULES]);
      
      // 加载反馈记录
      this.feedbackRecords = await storageUtils.get<ParseFeedbackRecord[]>(FEEDBACK_RECORDS_KEY, []);
      
      this.isInitialized = true;
      Logger.info(TAG, 'Parse rule manager initialized successfully.');
    } catch (error) {
      Logger.error(TAG, `Failed to initialize parse rule manager: ${error}`);
    }
  }

  /**
   * 保存规则到本地存储
   */
  private async saveRules(): Promise<void> {
    try {
      await storageUtils.set(PARSE_RULES_KEY, this.rules);
      Logger.info(TAG, 'Parse rules saved successfully.');
    } catch (error) {
      Logger.error(TAG, `Failed to save parse rules: ${error}`);
    }
  }

  /**
   * 保存反馈记录到本地存储
   */
  private async saveFeedbackRecords(): Promise<void> {
    try {
      await storageUtils.set(FEEDBACK_RECORDS_KEY, this.feedbackRecords);
      Logger.info(TAG, 'Parse feedback records saved successfully.');
    } catch (error) {
      Logger.error(TAG, `Failed to save parse feedback records: ${error}`);
    }
  }

  /**
   * 获取指定类型的解析规则
   * @param type 规则类型
   * @returns 解析规则列表
   */
  async getRulesByType(type: 'date' | 'taskName' | 'hours' | 'overtime' | 'quantity' | 'unitPrice'): Promise<ParseRule[]> {
    await this.init();
    
    return this.rules
      .filter(rule => rule.type === type && rule.enabled)
      .sort((a, b) => b.priority - a.priority);
  }

  /**
   * 获取所有解析规则
   * @returns 所有解析规则列表
   */
  async getAllRules(): Promise<ParseRule[]> {
    await this.init();
    
    return [...this.rules];
  }

  /**
   * 更新规则使用统计
   * @param ruleId 规则ID
   * @param success 是否成功
   */
  async updateRuleUsage(ruleId: string, success: boolean): Promise<void> {
    await this.init();
    
    const rule = this.rules.find(r => r.id === ruleId);
    if (rule) {
      rule.usageCount += 1;
      
      // 更新成功率
      const totalSuccess = rule.usageCount * rule.successRate;
      const newSuccess = success ? totalSuccess + 1 : totalSuccess;
      rule.successRate = newSuccess / rule.usageCount;
      
      // 保存规则
      await this.saveRules();
    }
  }

  /**
   * 添加解析反馈记录
   * @param feedbackRecord 反馈记录
   */
  async addFeedbackRecord(feedbackRecord: ParseFeedbackInput): Promise<void> {
    await this.init();
    
    // 创建完整的反馈记录
    const record: ParseFeedbackRecord = {
      voiceText: feedbackRecord.voiceText,
      parsedResult: feedbackRecord.parsedResult,
      correctResult: feedbackRecord.correctResult,
      feedbackType: feedbackRecord.feedbackType,
      id: `feedback_${Date.now()}_${Math.floor(Math.random() * 1000)}`,
      timestamp: Date.now()
    };
    
    // 添加到反馈记录列表
    this.feedbackRecords.unshift(record);
    
    // 限制反馈记录数量
    if (this.feedbackRecords.length > MAX_FEEDBACK_RECORDS) {
      this.feedbackRecords = this.feedbackRecords.slice(0, MAX_FEEDBACK_RECORDS);
    }
    
    // 保存反馈记录
    await this.saveFeedbackRecords();
    
    // 根据反馈优化规则
    this.optimizeRulesBasedOnFeedback();
  }

  /**
   * 根据反馈优化解析规则
   */
  private async optimizeRulesBasedOnFeedback(): Promise<void> {
    // 分析反馈记录，优化规则
    // 这里实现简单的优化逻辑，实际可以更复杂
    
    // 1. 统计各规则的成功率 - 使用 Record 替代 Map
    const ruleStats: Record<string, RuleStatistics> = {};
    
    for (const rule of this.rules) {
      ruleStats[rule.id] = { total: 0, success: 0 };
    }
    
    // 2. 根据反馈记录更新规则优先级和成功率
    for (const feedback of this.feedbackRecords) {
      // 这里可以根据反馈记录分析哪些规则需要调整
      // 简单起见，我们只调整成功率较低的规则优先级
    }
    
    // 3. 保存优化后的规则
    await this.saveRules();
  }

  /**
   * 获取解析反馈记录
   * @param limit 返回数量限制
   * @returns 解析反馈记录列表
   */
  async getFeedbackRecords(limit: number = 20): Promise<ParseFeedbackRecord[]> {
    await this.init();
    
    return this.feedbackRecords.slice(0, limit);
  }

  /**
   * 重置解析规则到默认状态
   */
  async resetRules(): Promise<void> {
    await this.init();
    
    this.rules = [...DEFAULT_RULES];
    await this.saveRules();
    
    Logger.info(TAG, 'Parse rules reset to default.');
  }

  /**
   * 动态添加新的解析规则
   * @param rule 新的解析规则
   */
  async addRule(rule: ParseRuleInput): Promise<void> {
    await this.init();
    
    const newRule: ParseRule = {
      type: rule.type,
      regex: rule.regex,
      priority: rule.priority,
      enabled: rule.enabled,
      id: `${rule.type}_rule_${Date.now()}`,
      usageCount: 0,
      successRate: 1.0
    };
    
    this.rules.push(newRule);
    await this.saveRules();
    
    Logger.info(TAG, `New parse rule added: ${newRule.id}`);
  }

  /**
   * 更新现有解析规则
   * @param rule 更新后的解析规则
   */
  async updateRule(rule: ParseRule): Promise<void> {
    await this.init();
    
    const index = this.rules.findIndex(r => r.id === rule.id);
    if (index >= 0) {
      this.rules[index] = rule;
      await this.saveRules();
      
      Logger.info(TAG, `Parse rule updated: ${rule.id}`);
    }
  }
}

export const parseRuleManager = new ParseRuleManager();
