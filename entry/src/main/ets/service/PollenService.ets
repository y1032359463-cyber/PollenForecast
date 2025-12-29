/**
 * 花粉 API 服务
 * 通过 AWS Lambda 代理获取花粉数据（国内可直接访问）
 */

import { http } from '@kit.NetworkKit'
import { PollenForecastResponse } from '../model/PollenModels'

/**
 * API 配置
 * - 阿里云新加坡: Google Pollen API 代理，国内可访问
 * - 广州服务器: 仅负责 QWeather 天气数据
 */
// 主服务器（阿里云新加坡节点）
const POLLEN_API_BASE_URL = 'http://47.84.1.164:5000/pollen-api'

// 备用地址
// AWS Lambda (已停用): https://iigtw47lrd.execute-api.ap-southeast-1.amazonaws.com/default/pollen-api

/**
 * 花粉服务类
 */
export class PollenService {
  private static instance: PollenService | null = null

  private constructor() {
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
   * 获取花粉预报数据
   * @param latitude 纬度
   * @param longitude 经度
   * @param days 预报天数 (1-5)
   */
  async getPollenForecast(
    latitude: number,
    longitude: number,
    days: number = 5
  ): Promise<PollenForecastResponse | null> {
    const url = `${POLLEN_API_BASE_URL}?lat=${latitude}&lng=${longitude}&days=${days}`
    console.info('[PollenService] 请求URL: ' + url)

    // 每次请求创建新的 httpRequest
    const httpRequest = http.createHttp()

    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
        connectTimeout: 30000,
        readTimeout: 30000
      })

      console.info('[PollenService] 响应码: ' + response.responseCode)

      if (response.responseCode === 200) {
        const resultStr = response.result as string
        console.info('[PollenService] 响应数据: ' + resultStr.substring(0, 100))
        const result: PollenForecastResponse = JSON.parse(resultStr)
        console.info('[PollenService] 获取花粉数据成功: ' + result.regionCode)
        httpRequest.destroy()
        return result
      } else {
        console.error('[PollenService] API 请求失败: ' + response.responseCode)
        httpRequest.destroy()
        return null
      }
    } catch (error) {
      console.error('[PollenService] 网络请求异常: ' + JSON.stringify(error))
      httpRequest.destroy()
      return null
    }
  }
}
