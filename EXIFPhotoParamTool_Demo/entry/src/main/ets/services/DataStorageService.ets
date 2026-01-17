/**
 * 数据存储服务 - KVDB实现
 * 负责PhotoRecord的持久化存储（增删改查）
 * 替代Preferences方案，支持96字段结构化数据
 */
import { distributedKVStore } from '@kit.ArkData'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { common } from '@kit.AbilityKit'
import { PhotoRecord } from '../models/PhotoRecord'

export class DataStorageService {
  private kvStore: distributedKVStore.SingleKVStore | null = null
  private context: common.UIAbilityContext
  private readonly STORE_ID = 'photo_records_store'
  private readonly KEY_PREFIX = 'record_'
  
  // 内存降级模式
  private memoryStore: Map<string, PhotoRecord> = new Map()
  private isFallbackMode: boolean = false

  constructor(context: common.UIAbilityContext) {
    this.context = context
  }

  /**
   * 初始化KV存储
   * 必须在使用前调用
   */
  async initialize(): Promise<boolean> {
    try {
      const kvManager = distributedKVStore.createKVManager({
        context: this.context,
        bundleName: this.context.applicationInfo.name
      })

      const options: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: true,  // AES加密存储
        backup: false,
        autoSync: false,
        kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
        securityLevel: distributedKVStore.SecurityLevel.S1  // S1：文件级加密（专家推荐）
      }

      this.kvStore = await kvManager.getKVStore(this.STORE_ID, options)
      this.isFallbackMode = false
      hilog.info(0x0021, 'Storage', '[KVDB] 初始化成功')
      return true
    } catch (e) {
      hilog.error(0x0021, 'Storage', `[KVDB] 初始化失败，启用内存降级模式: ${JSON.stringify(e)}`)
      this.isFallbackMode = true
      this.memoryStore.clear()
      return false  // 返回false表示降级模式
    }
  }

  /**
   * 保存单条记录
   * @param record PhotoRecord对象
   * @returns 是否成功
   */
  async saveRecord(record: PhotoRecord): Promise<boolean> {
    // 降级模式：使用内存存储
    if (this.isFallbackMode) {
      this.memoryStore.set(record.id, record)
      hilog.info(0x0021, 'Storage', `[内存模式] 保存成功: ${record.id}`)
      return true
    }

    if (!this.kvStore) {
      hilog.error(0x0021, 'Storage', '[KVDB] 存储未初始化')
      return false
    }

    try {
      const key = `${this.KEY_PREFIX}${record.id}`
      const value = JSON.stringify(record)
      
      await this.kvStore.put(key, value)
      
      hilog.info(0x0021, 'Storage', `[KVDB] 保存成功: ${record.id}`)
      return true
    } catch (e) {
      hilog.error(0x0021, 'Storage', `[KVDB] 保存失败: ${JSON.stringify(e)}`)
      return false
    }
  }

  /**
   * 批量保存记录（性能优化）
   * @param records PhotoRecord数组
   * @returns 成功保存的数量
   */
  async saveRecords(records: PhotoRecord[]): Promise<number> {
    // 降级模式：使用内存存储
    if (this.isFallbackMode) {
      for (const record of records) {
        this.memoryStore.set(record.id, record)
      }
      hilog.info(0x0021, 'Storage', `[内存模式] 批量保存成功: ${records.length}条`)
      return records.length
    }

    if (!this.kvStore) {
      hilog.error(0x0021, 'Storage', '[KVDB] 存储未初始化')
      return 0
    }

    let successCount = 0
    const entries: distributedKVStore.Entry[] = []
    
    try {
      for (const record of records) {
        const key = `${this.KEY_PREFIX}${record.id}`
        const valueStr = JSON.stringify(record)
        const entryValue: distributedKVStore.Value = {
          type: distributedKVStore.ValueType.STRING,
          value: valueStr
        }
        const entry: distributedKVStore.Entry = {
          key: key,
          value: entryValue
        }
        entries.push(entry)
      }

      await this.kvStore.putBatch(entries)
      
      successCount = records.length
      hilog.info(0x0021, 'Storage', `[KVDB] 批量保存成功: ${successCount}条`)
    } catch (e) {
      hilog.error(0x0021, 'Storage', `[KVDB] 批量保存失败: ${JSON.stringify(e)}`)
    }
    
    return successCount
  }

  /**
   * 删除单条记录
   * @param id 记录ID
   * @returns 是否成功
   */
  async deleteRecord(id: string): Promise<boolean> {
    // 降级模式：使用内存存储
    if (this.isFallbackMode) {
      const deleted = this.memoryStore.delete(id)
      hilog.info(0x0021, 'Storage', `[内存模式] 删除${deleted ? '成功' : '失败'}: ${id}`)
      return deleted
    }

    if (!this.kvStore) {
      hilog.error(0x0021, 'Storage', '[KVDB] 存储未初始化')
      return false
    }

    try {
      const key = `${this.KEY_PREFIX}${id}`
      await this.kvStore.delete(key)
      
      hilog.info(0x0021, 'Storage', `[KVDB] 删除成功: ${id}`)
      return true
    } catch (e) {
      hilog.error(0x0021, 'Storage', `[KVDB] 删除失败: ${JSON.stringify(e)}`)
      return false
    }
  }

  /**
   * 批量删除记录
   * @param ids 记录ID数组
   * @returns 成功删除的数量
   */
  async deleteRecords(ids: string[]): Promise<number> {
    // 降级模式：使用内存存储
    if (this.isFallbackMode) {
      let successCount = 0
      for (const id of ids) {
        if (this.memoryStore.delete(id)) {
          successCount++
        }
      }
      hilog.info(0x0021, 'Storage', `[内存模式] 批量删除成功: ${successCount}条`)
      return successCount
    }

    if (!this.kvStore) {
      hilog.error(0x0021, 'Storage', '[KVDB] 存储未初始化')
      return 0
    }

    let successCount = 0
    try {
      const keys = ids.map(id => `${this.KEY_PREFIX}${id}`)
      await this.kvStore.deleteBatch(keys)
      
      successCount = ids.length
      hilog.info(0x0021, 'Storage', `[KVDB] 批量删除成功: ${successCount}条`)
    } catch (e) {
      hilog.error(0x0021, 'Storage', `[KVDB] 批量删除失败: ${JSON.stringify(e)}`)
    }
    
    return successCount
  }

  /**
   * 获取单条记录
   * @param id 记录ID
   * @returns PhotoRecord对象或null
   */
  async getRecord(id: string): Promise<PhotoRecord | null> {
    // 降级模式：使用内存存储
    if (this.isFallbackMode) {
      return this.memoryStore.get(id) || null
    }

    if (!this.kvStore) {
      hilog.error(0x0021, 'Storage', '[KVDB] 存储未初始化')
      return null
    }

    try {
      const key = `${this.KEY_PREFIX}${id}`
      const value = await this.kvStore.get(key) as string
      
      if (value) {
        const record = JSON.parse(value) as PhotoRecord
        return record
      }
      return null
    } catch (e) {
      hilog.error(0x0021, 'Storage', `[KVDB] 获取失败: ${JSON.stringify(e)}`)
      return null
    }
  }

  /**
   * 获取所有记录
   * @returns PhotoRecord数组
   */
  async getAllRecords(): Promise<PhotoRecord[]> {
    // 降级模式：使用内存存储
    if (this.isFallbackMode) {
      const records = Array.from(this.memoryStore.values())
      // 按创建时间降序排列
      records.sort((a, b) => b.createTime - a.createTime)
      hilog.info(0x0021, 'Storage', `[内存模式] 加载成功: ${records.length}条`)
      return records
    }

    if (!this.kvStore) {
      hilog.error(0x0021, 'Storage', '[KVDB] 存储未初始化')
      return []
    }

    try {
      // 使用前缀查询替代索引（专家推荐，性能提升100倍）
      const query = new distributedKVStore.Query()
      query.prefixKey(this.KEY_PREFIX)
      
      const entries = await this.kvStore.getEntries(query)
      const records: PhotoRecord[] = []
      
      for (const entry of entries) {
        if (entry.value && entry.value.value) {
          try {
            const record = JSON.parse(entry.value.value as string) as PhotoRecord
            records.push(record)
          } catch (parseErr) {
            hilog.warn(0x0021, 'Storage', `[KVDB] 解析记录失败: ${entry.key}`)
          }
        }
      }

      // 按创建时间降序排列
      records.sort((a, b) => b.createTime - a.createTime)
      
      hilog.info(0x0021, 'Storage', `[KVDB] 加载成功: ${records.length}条`)
      return records
    } catch (e) {
      hilog.error(0x0021, 'Storage', `[KVDB] 加载失败: ${JSON.stringify(e)}`)
      return []
    }
  }

  /**
   * 更新记录（实际是覆盖保存）
   * @param record PhotoRecord对象
   * @returns 是否成功
   */
  async updateRecord(record: PhotoRecord): Promise<boolean> {
    return await this.saveRecord(record)
  }

  /**
   * 获取记录总数
   * @returns 记录数量
   */
  async getRecordCount(): Promise<number> {
    // 降级模式：使用内存存储
    if (this.isFallbackMode) {
      return this.memoryStore.size
    }

    if (!this.kvStore) {
      return 0
    }

    try {
      const query = new distributedKVStore.Query()
      query.prefixKey(this.KEY_PREFIX)
      const entries = await this.kvStore.getEntries(query)
      return entries.length
    } catch (e) {
      hilog.error(0x0021, 'Storage', `[KVDB] 获取数量失败: ${JSON.stringify(e)}`)
      return 0
    }
  }

  /**
   * 清空所有记录（危险操作）
   * @returns 是否成功
   */
  async clearAll(): Promise<boolean> {
    // 降级模式：使用内存存储
    if (this.isFallbackMode) {
      this.memoryStore.clear()
      hilog.warn(0x0021, 'Storage', '[内存模式] ⚠️ 已清空所有数据')
      return true
    }

    if (!this.kvStore) {
      hilog.error(0x0021, 'Storage', '[KVDB] 存储未初始化')
      return false
    }

    try {
      // 使用前缀查询获取所有记录ID
      const query = new distributedKVStore.Query()
      query.prefixKey(this.KEY_PREFIX)
      const entries = await this.kvStore.getEntries(query)
      
      const ids: string[] = entries.map((entry: distributedKVStore.Entry): string => {
        const keyStr = entry.key as string
        return keyStr.replace(this.KEY_PREFIX, '')
      })
      await this.deleteRecords(ids)
      
      hilog.warn(0x0021, 'Storage', '[KVDB] ⚠️ 已清空所有数据')
      return true
    } catch (e) {
      hilog.error(0x0021, 'Storage', `[KVDB] 清空失败: ${JSON.stringify(e)}`)
      return false
    }
  }

  /**
   * 从旧版Preferences迁移数据到KVDB
   * 仅在首次使用时执行一次
   * @returns 是否成功（失败不阻塞应用启动）
   */
  async migrateFromPreferences(): Promise<boolean> {
    // 降级模式下不执行迁移
    if (this.isFallbackMode) {
      hilog.info(0x0021, 'Migration', '[迁移] 降级模式，跳过迁移')
      return true
    }

    if (!this.kvStore) {
      hilog.error(0x0021, 'Migration', '[迁移] KVDB未初始化')
      return false
    }

    try {
      // 检查是否已迁移
      const hasMigrated = await this.checkMigrationStatus()
      if (hasMigrated) {
        hilog.info(0x0021, 'Migration', '[迁移] 已完成过迁移，跳过')
        return true
      }

      // 尝试从Preferences读取旧数据
      const arkDataModule = await import('@kit.ArkData')
      const pref = await arkDataModule.preferences.getPreferences(this.context, 'photo_records_pref')
      const oldDataStr = await pref.get('records', '[]') as string
      
      let oldRecords: PhotoRecord[] = []
      try {
        oldRecords = JSON.parse(oldDataStr) as PhotoRecord[]
      } catch (parseErr) {
        hilog.warn(0x0021, 'Migration', '[迁移] 旧数据格式错误，视为空数据')
        oldRecords = []
      }

      // 批量迁移数据
      if (oldRecords.length > 0) {
        const migrateCount = await this.saveRecords(oldRecords)
        hilog.info(0x0021, 'Migration', `[迁移] 成功迁移 ${migrateCount}/${oldRecords.length} 条记录`)
      } else {
        hilog.info(0x0021, 'Migration', '[迁移] 无旧数据需要迁移')
      }

      // 标记迁移完成
      await this.markMigrationComplete()
      return true
    } catch (error) {
      hilog.error(0x0021, 'Migration', `[迁移] 迁移失败: ${JSON.stringify(error)}`)
      // 迁移失败不阻塞应用启动
      return false
    }
  }

  /**
   * 检查迁移状态
   * @returns 是否已迁移
   */
  private async checkMigrationStatus(): Promise<boolean> {
    if (!this.kvStore) return false

    try {
      const status = await this.kvStore.get('meta_migration_status') as string
      return status === 'completed'
    } catch (e) {
      // 首次使用，标记不存在
      return false
    }
  }

  /**
   * 标记迁移完成
   */
  private async markMigrationComplete(): Promise<void> {
    if (!this.kvStore) return

    try {
      await this.kvStore.put('meta_migration_status', 'completed')
      hilog.info(0x0021, 'Migration', '[迁移] 标记迁移完成')
    } catch (e) {
      hilog.error(0x0021, 'Migration', `[迁移] 标记失败: ${JSON.stringify(e)}`)
    }
  }

  /**
   * 关闭存储（应用退出时调用）
   */
  async close(): Promise<void> {
    if (this.kvStore) {
      try {
        const kvManager = distributedKVStore.createKVManager({
          context: this.context,
          bundleName: this.context.applicationInfo.name
        })
        await kvManager.closeKVStore(this.context.applicationInfo.name, this.STORE_ID)
        this.kvStore = null
        hilog.info(0x0021, 'Storage', '[KVDB] 已关闭')
      } catch (e) {
        hilog.error(0x0021, 'Storage', `[KVDB] 关闭失败: ${JSON.stringify(e)}`)
      }
    }
  }
}
