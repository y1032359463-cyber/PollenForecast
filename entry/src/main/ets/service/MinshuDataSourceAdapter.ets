/**
 * 敏舒（Minshu）花粉数据源适配器
 * 将敏舒 API 数据格式转换为应用内部数据格式
 */

import { http } from '@kit.NetworkKit'
import { AppStorage } from '@kit.ArkData'
import { IPollenDataSourceAdapter } from './PollenDataSourceAdapter'
import { PollenForecastResponse, DailyInfo, PollenTypeInfo, IndexInfo, PlantInfo, DateInfo } from '../model/PollenModels'
import { getAdcodeByCityName } from '../utils/AdcodeUtils'

/**
 * 敏舒 API 代理服务器地址
 */
const MINSHU_PROXY_BASE = 'http://106.12.143.105:3000'

/**
 * 敏舒 API 响应格式（原始）
 */
interface MinshuApiResponse {
  code: number
  msg: string
  data: {
    regionCode: string
    dailyInfo: MinshuDailyInfo[]
  }
}

interface MinshuDailyInfo {
  date: {
    year: number
    month: number
    day: number
    hour?: number  // 24小时数据包含此字段
  }
  todayAllergy?: {
    level: number
    precision: number
    prompt: string
    suggestList: string[]
  }
  pollenTypeInfo: MinshuPollenTypeInfo[]
  plantInfo: MinshuPlantInfo[]
}

interface MinshuPollenTypeInfo {
  code: string  // TREE/GRASS/WEED
  displayName: string
  inSeason: boolean
  indexInfo: MinshuIndexInfo | null
  healthRecommendations: string[]
}

interface MinshuIndexInfo {
  code: string
  displayName: string
  value: number
  category: string  // 中文：无/极低/低/中/高/极高
  indexDescription: string
  color?: {
    red: number
    green: number
    blue: number
  }
}

interface MinshuPlantInfo {
  code: string
  displayName: string
  inSeason: boolean
  indexInfo: MinshuIndexInfo | null
  plantDescription?: {
    type: string
    family: string
    season: string
    specialColors?: string
    specialShapes?: string
    crossReaction?: string
  }
}

/**
 * 敏舒数据源适配器实现
 */
export class MinshuDataSourceAdapter implements IPollenDataSourceAdapter {
  name: string = '敏舒城市过敏预报'
  
  /**
   * 获取花粉预报数据（带城市名，用于获取 adcode）
   * @param lat 纬度
   * @param lng 经度
   * @param days 预报天数
   * @param cityName 城市名称（用于获取 adcode）
   */
  async fetchPollenDataWithCity(
    lat: number,
    lng: number,
    days: number,
    cityName: string
  ): Promise<PollenForecastResponse | null> {

  /**
   * 检查数据源是否可用
   */
  isAvailable(): boolean {
    return true  // 服务器已部署，始终可用
  }

  /**
   * 将敏舒的 category（中文）转换为 Google API 的 category（英文）
   */
  private convertCategoryToEnglish(category: string): string {
    const categoryMap: Map<string, string> = new Map([
      ['无', 'None'],
      ['极低', 'Very Low'],
      ['低', 'Low'],
      ['中', 'Moderate'],
      ['高', 'High'],
      ['极高', 'Very High']
    ])
    return categoryMap.get(category) || 'None'
  }

  /**
   * 转换敏舒的 IndexInfo 为应用内部格式
   */
  private convertIndexInfo(minshuIndex: MinshuIndexInfo | null): IndexInfo | null {
    if (!minshuIndex) {
      return null
    }

    return {
      code: minshuIndex.code,
      displayName: minshuIndex.displayName,
      value: minshuIndex.value,
      category: this.convertCategoryToEnglish(minshuIndex.category),
      indexDescription: minshuIndex.indexDescription
    }
  }

  /**
   * 转换敏舒的 PollenTypeInfo 为应用内部格式
   */
  private convertPollenTypeInfo(minshuType: MinshuPollenTypeInfo): PollenTypeInfo {
    return {
      code: minshuType.code,
      displayName: minshuType.displayName,
      inSeason: minshuType.inSeason,
      indexInfo: this.convertIndexInfo(minshuType.indexInfo),
      healthRecommendations: minshuType.healthRecommendations || []
    }
  }

  /**
   * 转换敏舒的 PlantInfo 为应用内部格式
   */
  private convertPlantInfo(minshuPlant: MinshuPlantInfo): PlantInfo {
    return {
      code: minshuPlant.code,
      displayName: minshuPlant.displayName,
      inSeason: minshuPlant.inSeason,
      indexInfo: this.convertIndexInfo(minshuPlant.indexInfo)
    }
  }

  /**
   * 转换敏舒的 DailyInfo 为应用内部格式
   */
  private convertDailyInfo(minshuDaily: MinshuDailyInfo): DailyInfo {
    return {
      date: {
        year: minshuDaily.date.year,
        month: minshuDaily.date.month,
        day: minshuDaily.date.day
      },
      pollenTypeInfo: minshuDaily.pollenTypeInfo.map(type => this.convertPollenTypeInfo(type)),
      plantInfo: minshuDaily.plantInfo.map(plant => this.convertPlantInfo(plant))
    }
  }

  /**
   * 获取花粉预报数据（实现接口方法）
   * 注意：敏舒 API 需要 adcode（城市编码），但接口只提供经纬度
   * 当前实现：尝试从 AppStorage 获取城市名，然后转换为 adcode
   * @param lat 纬度
   * @param lng 经度
   * @param days 预报天数（敏舒支持未来5天）
   */
  async fetchPollenData(
    lat: number,
    lng: number,
    days: number
  ): Promise<PollenForecastResponse | null> {
    try {
      // 1. 尝试从 AppStorage 获取当前城市名
      const currentCity: string | undefined = AppStorage.get('currentCity') as string | undefined
      
      if (!currentCity) {
        console.warn('[MinshuAdapter] 无法获取城市名称，需要先设置 currentCity')
        return null
      }
      
      // 2. 使用城市名获取 adcode
      return await this.fetchPollenDataWithCity(lat, lng, days, currentCity)
    } catch (error) {
      console.error(`[MinshuAdapter] 获取花粉数据失败: ${JSON.stringify(error)}`)
      return null
    }
  }

  /**
   * 获取花粉预报数据（带城市名，用于获取 adcode）
   * @param lat 纬度
   * @param lng 经度
   * @param days 预报天数
   * @param cityName 城市名称（用于获取 adcode）
   */
  async fetchPollenDataWithCity(
    lat: number,
    lng: number,
    days: number,
    cityName: string
  ): Promise<PollenForecastResponse | null> {
    try {
      // 1. 获取 adcode（城市编码）
      const adcode = getAdcodeByCityName(cityName)
      
      if (!adcode) {
        console.warn(`[MinshuAdapter] 无法获取城市 ${cityName} 的 adcode`)
        return null
      }

      // 2. 获取今天的日期（格式：yyyy-MM-dd）
      const today = new Date()
      const recordDate = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`

      // 3. 调用敏舒 API（通过代理服务器）
      const url = `${MINSHU_PROXY_BASE}/minshu/pollen/day?adcode=${adcode}&recordDate=${recordDate}`
      console.info(`[MinshuAdapter] 请求敏舒 API: ${url}`)

      const httpRequest = http.createHttp()
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
        connectTimeout: 10000,
        readTimeout: 10000
      })

      httpRequest.destroy()

      if (response.responseCode !== 200) {
        console.error(`[MinshuAdapter] API 请求失败: ${response.responseCode}`)
        return null
      }

      // 4. 解析响应
      const resultStr = response.result as string
      const minshuResponse: MinshuApiResponse = JSON.parse(resultStr)

      if (minshuResponse.code !== 0 || !minshuResponse.data) {
        console.error(`[MinshuAdapter] API 返回错误: ${minshuResponse.msg}`)
        return null
      }

      // 5. 转换数据格式
      const convertedResponse: PollenForecastResponse = {
        regionCode: minshuResponse.data.regionCode,
        dailyInfo: minshuResponse.data.dailyInfo.map(daily => this.convertDailyInfo(daily))
      }

      console.info(`[MinshuAdapter] 数据转换成功，共 ${convertedResponse.dailyInfo.length} 天数据`)
      return convertedResponse

    } catch (error) {
      console.error(`[MinshuAdapter] 获取花粉数据失败: ${JSON.stringify(error)}`)
      return null
    }
  }
}
