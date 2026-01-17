/**
 * EXIF服务外观模式（Facade Pattern）
 * 提供统一的EXIF解析入口，整合标准EXIF和鸿蒙专属字段
 */
import { ExifData } from '../../models/PhotoRecord'
import { ExifParserService } from '../ExifParserService'
import { HarmonyExifService } from './HarmonyExifService'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'

/**
 * LRU缓存实现（性能优化）
 */
class LRUCache {
  private cache: Map<string, ExifData>
  private maxSize: number

  constructor(maxSize: number = 50) {
    this.cache = new Map<string, ExifData>()
    this.maxSize = maxSize
  }

  get(key: string): ExifData | undefined {
    if (!this.cache.has(key)) {
      return undefined
    }
    // LRU: 重新插入到末尾（最近使用）
    const value = this.cache.get(key)!
    this.cache.delete(key)
    this.cache.set(key, value)
    return value
  }

  set(key: string, value: ExifData): void {
    // 如果已存在，先删除（避免重复）
    if (this.cache.has(key)) {
      this.cache.delete(key)
    }
    // 如果超出容量，删除最旧的（第一个）
    if (this.cache.size >= this.maxSize) {
      const firstKey = this.cache.keys().next().value as string
      this.cache.delete(firstKey)
    }
    this.cache.set(key, value)
  }

  has(key: string): boolean {
    return this.cache.has(key)
  }

  clear(): void {
    this.cache.clear()
  }

  size(): number {
    return this.cache.size
  }
}

/**
 * EXIF服务外观类
 * 整合标准EXIF解析和鸿蒙专属特性检测
 */
export class ExifServiceFacade {
  private static instance: ExifServiceFacade
  private exifParser: ExifParserService = new ExifParserService()
  private harmonyService: HarmonyExifService
  private cache: LRUCache

  private constructor() {
    this.harmonyService = new HarmonyExifService()
    this.cache = new LRUCache(50) // 缓存最近50张照片
  }

  /**
   * 初始化（必须在使用前调用）
   */
  init(context: common.UIAbilityContext): void {
    this.exifParser.init(context)
    hilog.info(0x0021, 'EXIF', '[ExifFacade] 初始化完成')
  }

  /**
   * 获取单例实例
   */
  static getInstance(): ExifServiceFacade {
    if (!ExifServiceFacade.instance) {
      ExifServiceFacade.instance = new ExifServiceFacade()
    }
    return ExifServiceFacade.instance
  }

  /**
   * 解析完整EXIF数据（标准+鸿蒙）
   * @param photoUri 照片URI
   * @param useCache 是否使用缓存（默认true）
   * @returns 完整EXIF数据
   */
  async parseFullExif(photoUri: string, useCache: boolean = true): Promise<ExifData> {
    // 检查缓存
    if (useCache && this.cache.has(photoUri)) {
      hilog.info(0x0021, 'EXIF', '[ExifFacade] 🎯 命中缓存:' + photoUri)
      return this.cache.get(photoUri)!
    }

    try {
      hilog.info(0x0021, 'EXIF', '[ExifFacade] 开始解析EXIF:' + photoUri)
      const startTime = Date.now()

      // 使用混合解析策略
      const exifData = await this.exifParser.parseExif(photoUri)

      const elapsed = Date.now() - startTime
      hilog.info(0x0021, 'EXIF', `[ExifFacade] ✅ EXIF解析完成，耗时: ${elapsed}ms`)

      // 存入缓存
      if (useCache) {
        this.cache.set(photoUri, exifData)
        hilog.info(0x0021, 'EXIF', `[ExifFacade] 缓存已更新，当前缓存数: ${this.cache.size()}`)
      }

      return exifData
    } catch (error) {
      hilog.error(0x0021, 'EXIF', '[ExifFacade] EXIF解析失败:' + error)
      throw new Error(`EXIF解析失败: ${error}`)
    }
  }

  /**
   * 仅解析基础EXIF参数（快速模式）
   * @param photoUri 照片URI
   * @returns 基础EXIF数据（光圈/快门/ISO/焦距）
   */
  async parseBasicExif(photoUri: string): Promise<Partial<ExifData>> {
    hilog.info(0x0021, 'EXIF', '[ExifFacade] 快速模式：仅解析基础参数')
    return await this.exifParser!.parseBasicExif(photoUri)
  }

  /**
   * 清除缓存
   */
  clearCache(): void {
    this.cache.clear()
    hilog.info(0x0021, 'EXIF', '[ExifFacade] 缓存已清空')
  }

  /**
   * 获取缓存状态
   */
  getCacheStats(): CacheStats {
    const stats: CacheStats = {
      size: this.cache.size(),
      maxSize: 50
    }
    return stats
  }
}

/**
 * 缓存统计接口
 */
interface CacheStats {
  size: number
  maxSize: number
}
