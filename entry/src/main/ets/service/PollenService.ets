/**
 * 花粉 API 服务
 * 支持多服务器故障转移，提高稳定性
 * 支持用户选择数据源（Google/CMA/QWeather）
 */

import { http } from '@kit.NetworkKit'
import { PollenForecastResponse } from '../model/PollenModels'
import { PollenDataSourceType } from '../model/PollenDataSource'
import { MinshuDataSourceAdapter } from './MinshuDataSourceAdapter'
import { QweatherDataSourceAdapter } from './QweatherDataSourceAdapter'

/**
 * 服务器配置
 */
interface ServerConfig {
  name: string           // 服务器名称
  url: string            // API 地址
  timeout: number        // 超时时间(ms)
  priority: number       // 优先级 (数字越小优先级越高)
}

/**
 * 服务器状态
 */
interface ServerStatus {
  lastSuccess: number    // 上次成功时间戳
  failCount: number      // 连续失败次数
  isHealthy: boolean     // 是否健康
}

/**
 * 服务器列表配置
 * 可以添加多个服务器，实现故障转移
 */
const POLLEN_SERVERS: ServerConfig[] = [
  {
    name: 'AWS Lambda 东京',
    url: 'https://g7d8o7pf5b.execute-api.ap-northeast-1.amazonaws.com/default/pollen-api',
    timeout: 20000,
    priority: 1
  },
  {
    name: 'AWS Lambda 新加坡',
    url: 'https://8de0lncs7f.execute-api.ap-southeast-1.amazonaws.com/default/pollen-api-singapore',
    timeout: 20000,
    priority: 2
  },
  {
    name: '阿里云新加坡',
    url: 'http://47.84.1.164:5000/pollen-api',
    timeout: 15000,
    priority: 3
  },
]

// 服务器健康状态缓存
const serverStatusMap: Map<string, ServerStatus> = new Map()

// 健康检查间隔 (5分钟)
const HEALTH_CHECK_INTERVAL = 5 * 60 * 1000

// 最大连续失败次数（超过后标记为不健康）
const MAX_FAIL_COUNT = 3

/**
 * 花粉服务类 - 支持多服务器故障转移
 */
export class PollenService {
  private static instance: PollenService | null = null

  private constructor() {
    // 初始化服务器状态
    this.initServerStatus()
  }

  /**
   * 获取单例实例
   */
  static getInstance(): PollenService {
    if (PollenService.instance === null) {
      PollenService.instance = new PollenService()
    }
    return PollenService.instance
  }

  /**
   * 初始化服务器状态
   */
  private initServerStatus(): void {
    for (const server of POLLEN_SERVERS) {
      if (!serverStatusMap.has(server.url)) {
        serverStatusMap.set(server.url, {
          lastSuccess: 0,
          failCount: 0,
          isHealthy: true
        })
      }
    }
  }

  /**
   * 获取排序后的服务器列表
   * 优先级: 健康 > 最近成功 > 配置优先级
   */
  private getSortedServers(): ServerConfig[] {
    const now = Date.now()

    return POLLEN_SERVERS.slice().sort((a, b) => {
      const statusA = serverStatusMap.get(a.url)
      const statusB = serverStatusMap.get(b.url)

      if (!statusA || !statusB) return a.priority - b.priority

      // 健康的优先
      if (statusA.isHealthy !== statusB.isHealthy) {
        return statusA.isHealthy ? -1 : 1
      }

      // 最近成功的优先
      if (statusA.lastSuccess !== statusB.lastSuccess) {
        return statusB.lastSuccess - statusA.lastSuccess
      }

      // 按配置优先级
      return a.priority - b.priority
    })
  }

  /**
   * 更新服务器状态 - 成功
   */
  private markServerSuccess(serverUrl: string): void {
    const status = serverStatusMap.get(serverUrl)
    if (status) {
      status.lastSuccess = Date.now()
      status.failCount = 0
      status.isHealthy = true
      console.info(`[PollenService] 服务器成功: ${serverUrl}`)
    }
  }

  /**
   * 更新服务器状态 - 失败
   */
  private markServerFail(serverUrl: string): void {
    const status = serverStatusMap.get(serverUrl)
    if (status) {
      status.failCount++
      if (status.failCount >= MAX_FAIL_COUNT) {
        status.isHealthy = false
        console.warn(`[PollenService] 服务器标记为不健康: ${serverUrl}, 连续失败 ${status.failCount} 次`)
      }
    }
  }

  /**
   * 检查服务器是否应该重试（不健康的服务器超过一定时间后重试）
   */
  private shouldRetryServer(serverUrl: string): boolean {
    const status = serverStatusMap.get(serverUrl)
    if (!status) return true

    if (status.isHealthy) return true

    // 不健康的服务器，超过 HEALTH_CHECK_INTERVAL 后重试
    const timeSinceLastSuccess = Date.now() - status.lastSuccess
    return timeSinceLastSuccess > HEALTH_CHECK_INTERVAL
  }

  /**
   * 向单个服务器发送请求
   */
  private async requestFromServer(
    server: ServerConfig,
    latitude: number,
    longitude: number,
    days: number
  ): Promise<PollenForecastResponse | null> {
    const url = `${server.url}?lat=${latitude}&lng=${longitude}&days=${days}`
    console.info(`[PollenService] 🚀 准备向服务器 [${server.name}] 发起请求: ${url}`)

    const httpRequest = http.createHttp()
    const startTime = Date.now()

    try {
      console.info(`[PollenService] [${server.name}] 正在执行异步请求...`)
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        connectTimeout: server.timeout,
        readTimeout: server.timeout
      })

      const duration = Date.now() - startTime
      console.info(`[PollenService] [${server.name}] 请求完成，耗时: ${duration}ms, 响应码: ${response.responseCode}`)

      if (response.responseCode === 200) {
        const resultStr = typeof response.result === 'string' ? response.result : JSON.stringify(response.result)
        console.info(`[PollenService] [${server.name}] 原始响应预览: ${resultStr.substring(0, 300)}${resultStr.length > 300 ? '...' : ''}`)
        
        try {
          const result: PollenForecastResponse = JSON.parse(resultStr)
          console.info(`[PollenService] [${server.name}] 数据解析成功: ${result.regionCode || '未知区域'}`)
          httpRequest.destroy()
          this.markServerSuccess(server.url)
          return result
        } catch (e) {
          console.error(`[PollenService] [${server.name}] JSON 解析失败: ${e.message}, 响应长度: ${resultStr.length}`)
          httpRequest.destroy()
          this.markServerFail(server.url)
          return null
        }
      } else {
        console.error(`[PollenService] [${server.name}] 服务器返回错误码: ${response.responseCode}`)
        httpRequest.destroy()
        this.markServerFail(server.url)
        return null
      }
    } catch (error) {
      const duration = Date.now() - startTime
      console.error(`[PollenService] [${server.name}] ❌ 请求发生异常 (耗时 ${duration}ms): ${JSON.stringify(error)}`)
      httpRequest.destroy()
      this.markServerFail(server.url)
      return null
    }
  }

  /**
   * 获取花粉预报数据 - 支持用户选择数据源
   * @param latitude 纬度
   * @param longitude 经度
   * @param days 预报天数 (1-5)
   */
  async getPollenForecast(
    latitude: number,
    longitude: number,
    days: number = 5
  ): Promise<PollenForecastResponse | null> {
    // 获取用户选择的数据源（默认 AUTO）
    const selectedDataSource: string = AppStorage.get('pollenDataSource') as string || 'AUTO'
    const dataSourceType = selectedDataSource as PollenDataSourceType

    console.info(`[PollenService] 用户选择的数据源: ${dataSourceType}`)

    // 根据用户选择调用对应的数据源
    switch (dataSourceType) {
      case PollenDataSourceType.AUTO:
        // 自动选择：国内城市优先使用敏舒，失败后降级到 Google
        const currentCity: string | undefined = AppStorage.get('currentCity') as string | undefined
        if (currentCity && this.isChineseCity(currentCity)) {
          console.info('[PollenService] AUTO 模式：检测到国内城市，尝试敏舒数据源')
          const minshuResult = await this.getPollenForecastFromMinshu(latitude, longitude, days, currentCity)
          if (minshuResult) {
            return minshuResult
          }
          // 敏舒失败，降级到 Google
          console.warn('[PollenService] AUTO 模式：敏舒数据源失败，降级到 Google Pollen API')
          return await this.getPollenForecastFromGoogle(latitude, longitude, days)
        } else {
          console.info('[PollenService] AUTO 模式：使用 Google Pollen API')
          return await this.getPollenForecastFromGoogle(latitude, longitude, days)
        }
      
      case PollenDataSourceType.GOOGLE:
        // 使用现有的多服务器故障转移逻辑（Google Pollen API）
        return await this.getPollenForecastFromGoogle(latitude, longitude, days)
      
      case PollenDataSourceType.MINSHU:
        // 敏舒城市过敏预报（国内权威）
        const cityName: string | undefined = AppStorage.get('currentCity') as string | undefined
        if (!cityName) {
          console.warn('[PollenService] 敏舒数据源需要城市名称')
          return null
        }
        return await this.getPollenForecastFromMinshu(latitude, longitude, days, cityName)
      
      case PollenDataSourceType.CMA:
        // 中国气象局（待实现）
        console.warn('[PollenService] 中国气象局数据源暂未实现')
        return null
      
      case PollenDataSourceType.QWEATHER:
        // 和风天气（已实现）
        return await this.getPollenForecastFromQweather(latitude, longitude, days)
      
      default:
        console.error(`[PollenService] 未知的数据源类型: ${dataSourceType}`)
        // 降级到 Google
        return await this.getPollenForecastFromGoogle(latitude, longitude, days)
    }
  }

  /**
   * 判断是否为国内城市（简单判断，通过城市名是否包含中文字符）
   */
  private isChineseCity(cityName: string): boolean {
    return /[\u4e00-\u9fa5]/.test(cityName)
  }

  /**
   * 从敏舒 API 获取数据
   * @param latitude 纬度
   * @param longitude 经度
   * @param days 预报天数
   * @param cityName 城市名称（用于获取 adcode）
   */
  private async getPollenForecastFromMinshu(
    latitude: number,
    longitude: number,
    days: number,
    cityName: string
  ): Promise<PollenForecastResponse | null> {
    try {
      const adapter = new MinshuDataSourceAdapter()
      if (!adapter.isAvailable()) {
        console.warn('[PollenService] 敏舒数据源不可用')
        return null
      }
      
      console.info(`[PollenService] 开始请求敏舒 API，城市: ${cityName}`)
      const result = await adapter.fetchPollenDataWithCity(latitude, longitude, days, cityName)
      
      if (result) {
        console.info(`[PollenService] 敏舒 API 获取成功: ${result.regionCode}`)
      } else {
        console.warn('[PollenService] 敏舒 API 获取失败')
      }
      
      return result
    } catch (error) {
      console.error(`[PollenService] 敏舒 API 请求异常: ${JSON.stringify(error)}`)
      return null
    }
  }

  /**
   * 从和风天气 API 获取数据
   * @param latitude 纬度
   * @param longitude 经度
   * @param days 预报天数
   */
  private async getPollenForecastFromQweather(
    latitude: number,
    longitude: number,
    days: number
  ): Promise<PollenForecastResponse | null> {
    try {
      const adapter = new QweatherDataSourceAdapter()
      if (!adapter.isAvailable()) {
        console.warn('[PollenService] 和风天气数据源不可用')
        return null
      }
      
      console.info('[PollenService] 开始请求和风天气 API')
      const result = await adapter.fetchPollenData(latitude, longitude, days)
      
      if (result) {
        console.info(`[PollenService] 和风天气 API 获取成功: ${result.regionCode}`)
      } else {
        console.warn('[PollenService] 和风天气 API 获取失败')
      }
      
      return result
    } catch (error) {
      console.error(`[PollenService] 和风天气 API 请求异常: ${JSON.stringify(error)}`)
      return null
    }
  }

  /**
   * 从 Google Pollen API 获取数据（多服务器故障转移）
   * @param latitude 纬度
   * @param longitude 经度
   * @param days 预报天数
   */
  private async getPollenForecastFromGoogle(
    latitude: number,
    longitude: number,
    days: number
  ): Promise<PollenForecastResponse | null> {
    const servers = this.getSortedServers()

    console.info(`[PollenService] 开始请求 Google Pollen API，可用服务器: ${servers.length}`)

    for (const server of servers) {
      // 检查是否应该尝试这个服务器
      if (!this.shouldRetryServer(server.url)) {
        console.info(`[PollenService] 跳过不健康服务器: ${server.name}`)
        continue
      }

      const result = await this.requestFromServer(server, latitude, longitude, days)
      if (result !== null) {
        return result
      }

      console.warn(`[PollenService] [${server.name}] 失败，尝试下一个服务器...`)
    }

    console.error('[PollenService] 所有 Google Pollen API 服务器均请求失败')
    return null
  }

  /**
   * 获取服务器状态信息（用于调试）
   */
  getServerStatus(): string {
    const statusList: string[] = []
    for (const server of POLLEN_SERVERS) {
      const status = serverStatusMap.get(server.url)
      if (status) {
        statusList.push(
          `${server.name}: ${status.isHealthy ? '✅健康' : '❌不健康'} (失败${status.failCount}次)`
        )
      }
    }
    return statusList.join(', ')
  }

  /**
   * 重置所有服务器状态（手动恢复）
   */
  resetServerStatus(): void {
    for (const server of POLLEN_SERVERS) {
      serverStatusMap.set(server.url, {
        lastSuccess: 0,
        failCount: 0,
        isHealthy: true
      })
    }
    console.info('[PollenService] 所有服务器状态已重置')
  }
}
