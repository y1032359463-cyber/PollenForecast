/**
 * 天气 API 服务
 * 通过百度云广州服务器代理调用和风天气 API（保护 API Key 安全）
 */

import { http } from '@kit.NetworkKit'

/**
 * API 配置 - 百度云广州代理服务器
 */
const WEATHER_PROXY_BASE = 'http://106.12.143.105:3000'

/**
 * 天气数据响应接口（简化版，匹配 Lambda 返回格式）
 */
export interface WeatherResponse {
  temperature: number // 温度，摄氏度
  feelsLike: number // 体感温度
  humidity: number // 湿度，百分比
  pressure: number // 气压，百帕
  windSpeed: number // 风速，米/秒
  windDirection: string // 风向
  sunrise: string // 日出时间，HH:mm
  sunset: string // 日落时间，HH:mm
  description: string // 天气描述
  tempMax?: number // 当日最高温（可选）
  tempMin?: number // 当日最低温（可选）
}

/**
 * 和风天气实时天气响应
 */
interface QWeatherNow {
  temp: string
  feelsLike: string
  humidity: string
  pressure: string
  windSpeed: string
  windDir: string
  text: string
}

interface QWeatherNowResponse {
  code?: string
  now?: QWeatherNow
  updateTime?: string
}

/**
 * 和风天气天文数据响应
 */
interface QWeatherSunResponse {
  code?: string
  sunrise?: string
  sunset?: string
}

/**
 * 和风天气每日预报数据
 */
interface QWeatherDaily {
  tempMax: string
  tempMin: string
}

interface QWeatherDailyResponse {
  code?: string
  daily?: QWeatherDaily[]
}

/**
 * 天气服务类
 */
export class WeatherService {
  private static instance: WeatherService | null = null

  private constructor() {
  }

  /**
   * 获取单例实例
   */
  static getInstance(): WeatherService {
    if (WeatherService.instance === null) {
      WeatherService.instance = new WeatherService()
    }
    return WeatherService.instance
  }

  /**
   * 获取天气数据（包含实时天气和日出日落）
   * @param latitude 纬度
   * @param longitude 经度
   */
  async getWeather(
    latitude: number,
    longitude: number
  ): Promise<WeatherResponse | null> {
    try {
      // 和风天气使用 经度,纬度 格式
      const location = `${longitude.toFixed(2)},${latitude.toFixed(2)}`
      const today = this.getTodayDate()
      
      const weatherUrl = `${WEATHER_PROXY_BASE}/weather/now?location=${location}`
      const sunUrl = `${WEATHER_PROXY_BASE}/astronomy/sun?location=${location}&date=${today}`
      const dailyUrl = `${WEATHER_PROXY_BASE}/weather/7d?location=${location}`
      
      console.info('[WeatherService] 请求实时天气: ' + weatherUrl)
      console.info('[WeatherService] 请求天文数据: ' + sunUrl)
      console.info('[WeatherService] 请求每日预报: ' + dailyUrl)

      // 并行请求处理
      const weatherRes = await this.requestQWeather<QWeatherNowResponse>(weatherUrl)
      const sunRes = await this.requestQWeather<QWeatherSunResponse>(sunUrl)
      const dailyRes = await this.requestQWeather<QWeatherDailyResponse>(dailyUrl)

      // 类型校验
      if (weatherRes === null || weatherRes.code === undefined || weatherRes.now === undefined) {
        console.error('[WeatherService] 天气数据无效')
        return null
      }

      if (weatherRes.code !== '200') {
        console.error('[WeatherService] 和风天气返回错误码: ' + weatherRes.code)
        return null
      }

      // 解析天文数据（可能失败，使用默认值）
      let sunrise = '06:00'
      let sunset = '18:00'
      if (sunRes !== null && sunRes.code !== undefined && sunRes.sunrise !== undefined) {
        if (sunRes.code === '200') {
          sunrise = this.extractTime(sunRes.sunrise)
          sunset = this.extractTime(sunRes.sunset || '18:00')
        }
      }

      // 解析每日预报数据（获取最高最低温）
      let tempMax: number | undefined = undefined
      let tempMin: number | undefined = undefined
      if (dailyRes !== null && dailyRes.code === '200' && dailyRes.daily !== undefined && dailyRes.daily.length > 0) {
        const todayForecast = dailyRes.daily[0]
        tempMax = parseFloat(todayForecast.tempMax)
        tempMin = parseFloat(todayForecast.tempMin)
        console.info(`[WeatherService] 今日温度: 最高${tempMax}°C, 最低${tempMin}°C`)
      }

      // 整合数据
      const result: WeatherResponse = {
        temperature: parseFloat(weatherRes.now.temp),
        feelsLike: parseFloat(weatherRes.now.feelsLike),
        humidity: parseFloat(weatherRes.now.humidity),
        pressure: parseFloat(weatherRes.now.pressure),
        windSpeed: parseFloat(weatherRes.now.windSpeed),
        windDirection: weatherRes.now.windDir,
        sunrise: sunrise,
        sunset: sunset,
        description: weatherRes.now.text,
        tempMax: tempMax,
        tempMin: tempMin
      }

      console.info('[WeatherService] 天气数据获取成功: ' + result.description)
      return result

    } catch (error) {
      console.error('[WeatherService] 天气获取异常: ' + JSON.stringify(error))
      return null
    }
  }

  /**
   * 请求和风天气 API（泛型封装）
   */
  private async requestQWeather<T>(url: string): Promise<T | null> {
    const httpRequest = http.createHttp()

    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
        connectTimeout: 10000,
        readTimeout: 10000
      })

      httpRequest.destroy()

      if (response.responseCode === 200) {
        const resultStr = response.result as string
        return JSON.parse(resultStr) as T
      } else {
        console.error('[WeatherService] HTTP 请求失败: ' + response.responseCode)
        return null
      }
    } catch (error) {
      httpRequest.destroy()
      console.error('[WeatherService] 请求异常: ' + JSON.stringify(error))
      return null
    }
  }

  /**
   * 获取今天日期 (YYYYMMDD 格式)
   */
  private getTodayDate(): string {
    const now = new Date()
    const year = now.getFullYear()
    const month = String(now.getMonth() + 1).padStart(2, '0')
    const day = String(now.getDate()).padStart(2, '0')
    return `${year}${month}${day}`
  }

  /**
   * 从 ISO 8601 时间字符串提取 HH:mm
   * 例如: "2025-12-08T07:24+08:00" -> "07:24"
   */
  private extractTime(isoTime: string): string {
    try {
      // 匹配 T 后面的时间部分 (HH:mm)
      const match = isoTime.match(/T(\d{2}:\d{2})/)
      if (match !== null && match[1] !== undefined) {
        return match[1]
      }
      return isoTime // 如果解析失败,返回原值
    } catch (error) {
      console.error('[WeatherService] 时间解析失败: ' + isoTime)
      return '00:00'
    }
  }
}