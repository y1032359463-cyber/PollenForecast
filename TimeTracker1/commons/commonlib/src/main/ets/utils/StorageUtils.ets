import { preferences } from '@kit.ArkData';
import { WorkRecord } from '../models/WorkRecord';
import { Logger } from './logger/Index';
import { GlobalContext } from './GlobalContext';

const TAG = '[StorageUtils]';
const PREFERENCES_NAME = 'TimeTrackerPrefs';
const WORK_RECORDS_KEY = 'workRecords';

class StorageUtils {
  private pref: preferences.Preferences | null = null;

  /**
   * 初始化 Preferences 实例。
   * 必须在使用任何其他方法之前调用。
   */
  async init(): Promise<void> {
    try {
      const context = GlobalContext.getContext();
      if (!context) {
        throw new Error('Global context is not available for StorageUtils initialization.');
      }
      this.pref = await preferences.getPreferences(context, PREFERENCES_NAME);
      Logger.info(TAG, 'Preferences instance initialized successfully.');
    } catch (err) {
      Logger.error(TAG, `Failed to get preferences instance. Code: ${err.code}, message: ${err.message}`);
    }
  }

  /**
   * 检查 Preferences 实例是否已初始化。
   */
  private checkInitialized(): void {
    if (!this.pref) {
      throw new Error('StorageUtils is not initialized. Call init() first.');
    }
  }

  /**
   * 保存单条工时记录。
   * @param record - 要保存的工时记录。
   */
  async saveWorkRecord(record: WorkRecord): Promise<void> {
    this.checkInitialized();
    try {
      const allRecords = await this.getAllWorkRecords();
      allRecords.push(record);
      await this.pref!.put(WORK_RECORDS_KEY, JSON.stringify(allRecords));
      await this.pref!.flush();
      Logger.info(TAG, `Work record with id ${record.id} saved successfully.`);
    } catch (err) {
      Logger.error(TAG, `Failed to save work record. Code: ${(err as Error).message}`);
    }
  }

  /**
   * 获取所有工时记录。
   * @returns 返回包含所有工时记录的数组。
   */
  async getAllWorkRecords(): Promise<WorkRecord[]> {
    this.checkInitialized();
    try {
      const recordsStr = await this.pref!.get(WORK_RECORDS_KEY, '[]') as string;
      return JSON.parse(recordsStr) as WorkRecord[];
    } catch (err) {
      Logger.error(TAG, `Failed to get all work records. Code: ${(err as Error).message}`);
      return [];
    }
  }

  /**
   * 根据 ID 删除一条工时记录。
   * @param recordId - 要删除的记录的 ID。
   */
  async deleteWorkRecord(recordId: string): Promise<void> {
    this.checkInitialized();
    try {
      let allRecords = await this.getAllWorkRecords();
      allRecords = allRecords.filter(rec => rec.id !== recordId);
      await this.pref!.put(WORK_RECORDS_KEY, JSON.stringify(allRecords));
      await this.pref!.flush();
      Logger.info(TAG, `Work record with id ${recordId} deleted successfully.`);
    } catch (err) {
      Logger.error(TAG, `Failed to delete work record. Code: ${(err as Error).message}`);
    }
  }
  
  /**
   * 清空所有工时记录。
   */
  async clearAllWorkRecords(): Promise<void> {
    this.checkInitialized();
    try {
      await this.pref!.delete(WORK_RECORDS_KEY);
      await this.pref!.flush();
      Logger.info(TAG, 'All work records have been cleared.');
    } catch (err) {
      Logger.error(TAG, `Failed to clear work records. Code: ${(err as Error).message}`);
    }
  }

  /**
   * 存储通用键值对。
   * @param key - 存储键。
   * @param value - 存储值。
   */
  async set(key: string, value: string | number | boolean | object): Promise<void> {
    this.checkInitialized();
    try {
      await this.pref!.put(key, JSON.stringify(value));
      await this.pref!.flush();
      Logger.info(TAG, `Value for key ${key} saved successfully.`);
    } catch (err) {
      Logger.error(TAG, `Failed to save value for key ${key}. Code: ${(err as Error).message}`);
    }
  }

  /**
   * 获取通用键值对。
   * @param key - 存储键。
   * @param defaultValue - 默认值。
   * @returns 返回存储的值或默认值。
   */
  async get<T>(key: string, defaultValue: T): Promise<T> {
    this.checkInitialized();
    try {
      const valueStr = await this.pref!.get(key, JSON.stringify(defaultValue)) as string;
      return JSON.parse(valueStr) as T;
    } catch (err) {
      Logger.error(TAG, `Failed to get value for key ${key}. Code: ${(err as Error).message}`);
      return defaultValue;
    }
  }
}

export const storageUtils = new StorageUtils();
