/**
 * 本地存储服务
 * 使用 Preferences 存储照片记录列表
 */
import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { PhotoRecord } from '../models/PhotoRecord'

const PREFERENCES_NAME = 'exif_memo_storage'
const KEY_RECORDS = 'photo_records'

export class StorageService {
  private context: common.UIAbilityContext
  private dataPreferences: preferences.Preferences | null = null

  constructor(context: common.UIAbilityContext) {
    this.context = context
  }

  /**
   * 初始化存储服务
   */
  async init(): Promise<void> {
    try {
      this.dataPreferences = await preferences.getPreferences(this.context, PREFERENCES_NAME)
      hilog.info(0x0021, 'Storage', '[Storage] 初始化成功')
    } catch (err) {
      hilog.error(0x0021, 'Storage', '[Storage] 初始化失败:' + err)
    }
  }

  /**
   * 保存所有记录
   * @param records 照片记录数组
   */
  async saveRecords(records: PhotoRecord[]): Promise<boolean> {
    if (!this.dataPreferences) {
      await this.init()
    }
    
    try {
      // 将记录数组转为JSON字符串
      const jsonString = JSON.stringify(records)
      await this.dataPreferences?.put(KEY_RECORDS, jsonString)
      await this.dataPreferences?.flush()
      hilog.info(0x0021, 'Storage', `[Storage] 保存成功，共 ${records.length} 条记录`)
      return true
    } catch (err) {
      hilog.error(0x0021, 'Storage', '[Storage] 保存失败:' + err)
      return false
    }
  }

  /**
   * 加载所有记录
   * @returns 照片记录数组
   */
  async loadRecords(): Promise<PhotoRecord[]> {
    if (!this.dataPreferences) {
      await this.init()
    }
    
    try {
      const jsonString = await this.dataPreferences?.get(KEY_RECORDS, '[]')
      const records = JSON.parse(jsonString as string) as PhotoRecord[]
      hilog.info(0x0021, 'Storage', `[Storage] 加载成功，共 ${records.length} 条记录`)
      return records
    } catch (err) {
      hilog.error(0x0021, 'Storage', '[Storage] 加载失败:' + err)
      return []
    }
  }

  /**
   * 添加单条记录
   * @param record 新记录
   */
  async addRecord(record: PhotoRecord): Promise<boolean> {
    const records = await this.loadRecords()
    records.unshift(record)
    return await this.saveRecords(records)
  }

  /**
   * 更新记录
   * @param id 记录ID
   * @param updatedRecord 更新后的记录
   */
  async updateRecord(id: string, updatedRecord: PhotoRecord): Promise<boolean> {
    const records = await this.loadRecords()
    const index = records.findIndex(r => r.id === id)
    
    if (index !== -1) {
      records[index] = updatedRecord
      return await this.saveRecords(records)
    }
    
    hilog.warn(0x0021, 'Storage', `[Storage] 记录 ${id} 不存在`)
    return false
  }

  /**
   * 删除记录
   * @param id 记录ID
   */
  async deleteRecord(id: string): Promise<boolean> {
    const records = await this.loadRecords()
    const filtered = records.filter(r => r.id !== id)
    
    if (filtered.length < records.length) {
      return await this.saveRecords(filtered)
    }
    
    hilog.warn(0x0021, 'Storage', `[Storage] 记录 ${id} 不存在`)
    return false
  }

  /**
   * 清空所有记录（用于测试）
   */
  async clearAll(): Promise<void> {
    if (!this.dataPreferences) {
      await this.init()
    }
    
    try {
      await this.dataPreferences?.delete(KEY_RECORDS)
      await this.dataPreferences?.flush()
      hilog.info(0x0021, 'Storage', '[Storage] 清空成功')
    } catch (err) {
      hilog.error(0x0021, 'Storage', '[Storage] 清空失败:' + err)
    }
  }

  /**
   * 获取记录数量
   */
  async getRecordCount(): Promise<number> {
    const records = await this.loadRecords()
    return records.length
  }
}
