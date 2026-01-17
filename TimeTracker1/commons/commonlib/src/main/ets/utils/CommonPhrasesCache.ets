/**
 * 常用语缓存工具类
 * 用于存储和管理用户常用的任务名和单价信息
 * 基于使用频率和时间衰减算法自动更新缓存
 */

import { storageUtils } from './StorageUtils';
import { Logger } from './logger/Index';

const TAG = '[CommonPhrasesCache]';
const COMMON_PHRASES_KEY = 'commonPhrasesCache';
const MAX_CACHE_SIZE = 50; // 最大缓存数量
const DECAY_FACTOR = 0.9; // 时间衰减因子
const USAGE_WEIGHT = 0.7; // 使用频率权重
const RECENCY_WEIGHT = 0.3; // 时间权重

// 常用语缓存项接口
export interface CacheItem {
  phrase: string;
  usageCount: number;
  lastUsedTime: number;
  score: number;
}

// 常用语缓存数据结构
export interface CommonPhrasesCacheData {
  taskNames: CacheItem[];
  unitPrices: CacheItem[];
  lastUpdateTime: number;
}

class CommonPhrasesCache {
  private cacheData: CommonPhrasesCacheData = {
    taskNames: [],
    unitPrices: [],
    lastUpdateTime: Date.now()
  };
  private isInitialized: boolean = false;

  /**
   * 初始化缓存
   */
  async init(): Promise<void> {
    if (this.isInitialized) {
      return;
    }

    try {
      // 初始化存储工具
      await storageUtils.init();
      
      // 加载缓存数据
      this.cacheData = await storageUtils.get<CommonPhrasesCacheData>(COMMON_PHRASES_KEY, {
        taskNames: [],
        unitPrices: [],
        lastUpdateTime: Date.now()
      });
      
      // 更新缓存分数
      this.updateScores();
      
      this.isInitialized = true;
      Logger.info(TAG, 'Common phrases cache initialized successfully.');
    } catch (error) {
      Logger.error(TAG, `Failed to initialize common phrases cache: ${error}`);
    }
  }

  /**
   * 更新缓存分数
   * 基于使用频率和时间衰减算法
   */
  private updateScores(): void {
    const now = Date.now();
    const timeDiffInDays = (now - this.cacheData.lastUpdateTime) / (1000 * 60 * 60 * 24);
    
    // 更新任务名分数
    this.cacheData.taskNames.forEach(item => {
      const recency = 1 / (1 + timeDiffInDays);
      item.score = (item.usageCount * USAGE_WEIGHT) + (recency * RECENCY_WEIGHT);
    });
    
    // 更新单价分数
    this.cacheData.unitPrices.forEach(item => {
      const recency = 1 / (1 + timeDiffInDays);
      item.score = (item.usageCount * USAGE_WEIGHT) + (recency * RECENCY_WEIGHT);
    });
    
    // 按分数排序
    this.cacheData.taskNames.sort((a, b) => b.score - a.score);
    this.cacheData.unitPrices.sort((a, b) => b.score - a.score);
    
    // 限制缓存大小
    if (this.cacheData.taskNames.length > MAX_CACHE_SIZE) {
      this.cacheData.taskNames = this.cacheData.taskNames.slice(0, MAX_CACHE_SIZE);
    }
    
    if (this.cacheData.unitPrices.length > MAX_CACHE_SIZE) {
      this.cacheData.unitPrices = this.cacheData.unitPrices.slice(0, MAX_CACHE_SIZE);
    }
    
    // 更新最后更新时间
    this.cacheData.lastUpdateTime = now;
  }

  /**
   * 保存缓存数据到本地存储
   */
  private async saveCache(): Promise<void> {
    try {
      await storageUtils.set(COMMON_PHRASES_KEY, this.cacheData);
      Logger.info(TAG, 'Common phrases cache saved successfully.');
    } catch (error) {
      Logger.error(TAG, `Failed to save common phrases cache: ${error}`);
    }
  }

  /**
   * 添加或更新任务名到缓存
   * @param phrase 任务名
   */
  async addTaskName(phrase: string): Promise<void> {
    await this.init();
    
    // 查找是否已存在
    const existingIndex = this.cacheData.taskNames.findIndex(item => item.phrase === phrase);
    
    if (existingIndex >= 0) {
      // 更新现有项
      const item = this.cacheData.taskNames[existingIndex];
      item.usageCount += 1;
      item.lastUsedTime = Date.now();
    } else {
      // 添加新项
      this.cacheData.taskNames.push({
        phrase,
        usageCount: 1,
        lastUsedTime: Date.now(),
        score: 1
      });
    }
    
    // 更新分数
    this.updateScores();
    
    // 保存到本地存储
    await this.saveCache();
  }

  /**
   * 添加或更新单价到缓存
   * @param phrase 单价短语（如 "每件10元"）
   */
  async addUnitPrice(phrase: string): Promise<void> {
    await this.init();
    
    // 查找是否已存在
    const existingIndex = this.cacheData.unitPrices.findIndex(item => item.phrase === phrase);
    
    if (existingIndex >= 0) {
      // 更新现有项
      const item = this.cacheData.unitPrices[existingIndex];
      item.usageCount += 1;
      item.lastUsedTime = Date.now();
    } else {
      // 添加新项
      this.cacheData.unitPrices.push({
        phrase,
        usageCount: 1,
        lastUsedTime: Date.now(),
        score: 1
      });
    }
    
    // 更新分数
    this.updateScores();
    
    // 保存到本地存储
    await this.saveCache();
  }

  /**
   * 获取常用任务名列表
   * @param limit 返回数量限制
   * @returns 常用任务名列表
   */
  async getTopTaskNames(limit: number = 10): Promise<string[]> {
    await this.init();
    
    return this.cacheData.taskNames
      .slice(0, limit)
      .map(item => item.phrase);
  }

  /**
   * 获取常用单价列表
   * @param limit 返回数量限制
   * @returns 常用单价列表
   */
  async getTopUnitPrices(limit: number = 10): Promise<string[]> {
    await this.init();
    
    return this.cacheData.unitPrices
      .slice(0, limit)
      .map(item => item.phrase);
  }

  /**
   * 在语音文本中优先匹配缓存的常用语
   * @param voiceText 语音识别文本
   * @returns 增强后的语音文本（优先匹配常用语）
   */
  async enhanceVoiceText(voiceText: string): Promise<string> {
    await this.init();
    
    let enhancedText = voiceText;
    
    // 优先匹配任务名
    for (const item of this.cacheData.taskNames) {
      // 使用正则表达式匹配完整单词
      const regex = new RegExp(`\\b${this.escapeRegExp(item.phrase)}\\b`, 'gi');
      if (regex.test(enhancedText)) {
        // 如果匹配到，增加其权重（在解析时优先考虑）
        // 这里只是标记，实际解析时会优先处理
        enhancedText = enhancedText.replace(regex, `[${item.phrase}]`);
      }
    }
    
    // 优先匹配单价
    for (const item of this.cacheData.unitPrices) {
      const regex = new RegExp(`\\b${this.escapeRegExp(item.phrase)}\\b`, 'gi');
      if (regex.test(enhancedText)) {
        enhancedText = enhancedText.replace(regex, `[${item.phrase}]`);
      }
    }
    
    return enhancedText;
  }

  /**
   * 清除缓存
   */
  async clearCache(): Promise<void> {
    await this.init();
    
    this.cacheData = {
      taskNames: [],
      unitPrices: [],
      lastUpdateTime: Date.now()
    };
    
    await this.saveCache();
    Logger.info(TAG, 'Common phrases cache cleared successfully.');
  }

  /**
   * 转义正则表达式特殊字符
   * @param str 要转义的字符串
   * @returns 转义后的字符串
   */
  private escapeRegExp(str: string): string {
    return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }
}

export const commonPhrasesCache = new CommonPhrasesCache();
