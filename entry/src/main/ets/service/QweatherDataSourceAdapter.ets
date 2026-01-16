/**
 * 和风天气（Qweather）花粉数据源适配器
 * 将和风天气 Indices API 数据格式转换为应用内部数据格式
 */

import { http } from '@kit.NetworkKit'
import { IPollenDataSourceAdapter } from './PollenDataSourceAdapter'
import { PollenForecastResponse, DailyInfo, PollenTypeInfo, IndexInfo, DateInfo } from '../model/PollenModels'

/**
 * 和风天气代理服务器地址
 */
const QWEATHER_PROXY_BASE = 'http://106.12.143.105:3000'

/**
 * 和风天气 Indices API 响应格式（原始）
 */
interface QweatherApiResponse {
  code: string           // API 状态码："200" 表示成功
  updateTime: string     // 数据更新时间（ISO 8601 格式）
  fxLink: string         // 和风天气数据页面链接
  daily: QweatherDailyIndex[]  // 每日指数数据数组
}

interface QweatherDailyIndex {
  date: string           // 日期，格式 "2026-01-16"
  type: string           // 指数类型标识："1" = 花粉过敏指数
  name: string           // 指数名称："花粉过敏指数"
  level: string          // 等级标识："1"/"2"/"3"/"4"/"5"
  category: string       // 类别文字描述："极不易发"/"不易发"/"较易发"/"易发"/"极易发"
  text: string           // 详细说明文字，包含健康建议等信息
}

/**
 * 和风天气数据源适配器实现
 */
export class QweatherDataSourceAdapter implements IPollenDataSourceAdapter {
  name: string = '和风天气'
  
  /**
   * 检查数据源是否可用
   * @returns true 表示可用，false 表示不可用
   */
  isAvailable(): boolean {
    return true  // 服务器代理已部署，默认可用
  }

  /**
   * 将和风的 category（中文）转换为 Google API 的 category（英文）
   * @param category 和风天气的中文类别：极不易发/不易发/较易发/易发/极易发
   * @returns Google API 的英文类别：None/Low/Moderate/High/Very High
   */
  protected convertCategoryToEnglish(category: string): string {
    const categoryMap: Map<string, string> = new Map([
      ['极不易发', 'None'],
      ['不易发', 'Low'],
      ['较易发', 'Moderate'],
      ['易发', 'High'],
      ['极易发', 'Very High']
    ])
    return categoryMap.get(category) || 'None'
  }

  /**
   * 将和风的 level 转换为数值（0-100）
   * 用于统一不同数据源的指数值范围
   * @param level 和风天气的等级标识："1"/"2"/"3"/"4"/"5"
   * @returns 标准化的指数值：0/25/50/75/100
   */
  protected convertLevelToValue(level: string): number {
    const levelMap: Map<string, number> = new Map([
      ['1', 0],      // 极不易发
      ['2', 25],     // 不易发
      ['3', 50],     // 较易发
      ['4', 75],     // 易发
      ['5', 100]     // 极易发
    ])
    return levelMap.get(level) || 0
  }

  /**
   * 转换和风的日指数为应用内部格式
   * 将 QweatherDailyIndex 转换为 DailyInfo，包括日期解析、指数转换和健康建议提取
   * @param qweatherDaily 和风天气的日指数数据
   * @returns 应用内部的每日信息格式（DailyInfo）
   */
  protected convertDailyInfo(qweatherDaily: QweatherDailyIndex): DailyInfo {
    // 解析日期
    const dateParts = qweatherDaily.date.split('-')
    const dateInfo: DateInfo = {
      year: parseInt(dateParts[0]),
      month: parseInt(dateParts[1]),
      day: parseInt(dateParts[2])
    }

    // 转换花粉指数信息
    const indexInfo: IndexInfo = {
      code: 'POLLEN_TOTAL',
      displayName: '综合花粉',
      value: this.convertLevelToValue(qweatherDaily.level),
      category: this.convertCategoryToEnglish(qweatherDaily.category),
      indexDescription: qweatherDaily.text,
      categoryOriginal: qweatherDaily.category  // 保留原始中文文本（如"极易发"、"易发"等）
    }

    // 构造花粉类型信息（和风只提供综合指数，不细分树/草/杂草）
    const pollenTypeInfo: PollenTypeInfo = {
      code: 'TOTAL',
      displayName: '综合花粉',
      inSeason: this.convertLevelToValue(qweatherDaily.level) > 0,
      indexInfo: indexInfo,
      healthRecommendations: this.extractRecommendations(qweatherDaily.text)
    }

    const result: DailyInfo = {
      date: dateInfo,
      pollenTypeInfo: [pollenTypeInfo],
      plantInfo: []  // 和风不提供具体植物信息
    }
    return result
  }

  /**
   * 从文字说明中提取健康建议
   * 根据和风天气的文字描述生成对应的健康建议列表
   * @param text 和风天气的详细说明文字
   * @returns 健康建议字符串数组
   */
  protected extractRecommendations(text: string): string[] {
    const recommendations: string[] = []
    
    if (text.includes('极不易发') || text.includes('不易发')) {
      recommendations.push('今日花粉浓度较低，可放心外出')
    } else if (text.includes('较易发')) {
      recommendations.push('建议易敏人群减少外出时间')
      recommendations.push('外出时可佩戴口罩')
    } else if (text.includes('易发') || text.includes('极易发')) {
      recommendations.push('花粉浓度较高，易敏人群应避免外出')
      recommendations.push('关闭门窗，减少室内花粉')
      recommendations.push('必要时请遵医嘱服用抗过敏药物')
    }
    
    return recommendations
  }

  /**
   * 获取花粉预报数据（实现接口方法）
   * 通过代理服务器调用和风天气 Indices API，获取指定位置的花粉过敏指数
   * @param lat 纬度
   * @param lng 经度
   * @param days 预报天数（和风支持未来7天）
   * @returns 转换后的花粉预报数据，失败返回 null
   */
  async fetchPollenData(
    lat: number,
    lng: number,
    days: number
  ): Promise<PollenForecastResponse | null> {
    try {
      // 构造请求 URL（经纬度格式：lng,lat）
      const location = `${lng},${lat}`
      // type=10 表示花粉过敏指数
      const url = `${QWEATHER_PROXY_BASE}/weather/indices?location=${location}&type=10&days=${days}`
      
      console.info(`[QweatherAdapter] 🚀 准备请求和风数据: ${url}`)

      // 发起 HTTP 请求
      const request = http.createHttp()
      const startTime = Date.now()

      const response = await request.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000
      })

      const duration = Date.now() - startTime
      console.info(`[QweatherAdapter] 请求完成，耗时: ${duration}ms, 响应码: ${response.responseCode}`)

      // 检查 HTTP 状态码
      if (response.responseCode !== 200) {
        console.error(`[QweatherAdapter] HTTP 错误: ${response.responseCode}`)
        request.destroy()
        return null
      }

      // 解析响应数据
      const resultStr = typeof response.result === 'string' ? response.result : JSON.stringify(response.result)
      console.info(`[QweatherAdapter] 原始响应预览: ${resultStr.substring(0, 300)}`)

      const apiResponse = JSON.parse(resultStr) as QweatherApiResponse
      request.destroy()

      // 检查业务状态码
      if (apiResponse.code !== '200') {
        console.error('[QweatherAdapter] API 错误:', apiResponse.code)
        return null
      }

      // 转换数据格式
      const dailyInfoArray: DailyInfo[] = []
      for (let i = 0; i < apiResponse.daily.length; i++) {
        dailyInfoArray.push(this.convertDailyInfo(apiResponse.daily[i]))
      }

      const result: PollenForecastResponse = {
        dailyInfo: dailyInfoArray,
        regionCode: `${lat},${lng}`
      }

      console.info('[QweatherAdapter] 成功获取和风花粉数据:', dailyInfoArray.length, '天')
      return result

    } catch (error) {
      console.error('[QweatherAdapter] 请求失败:', JSON.stringify(error))
      return null
    }
  }
}
