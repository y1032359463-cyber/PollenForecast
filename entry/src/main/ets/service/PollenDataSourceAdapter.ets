/**
 * 花粉数据源适配器接口
 * 每个数据源需要实现此接口
 */

import { PollenForecastResponse } from '../model/PollenModels'

/**
 * 数据源适配器接口
 */
export interface IPollenDataSourceAdapter {
  /**
   * 数据源名称
   */
  name: string

  /**
   * 获取花粉预报数据
   * @param lat 纬度
   * @param lng 经度
   * @param days 预报天数
   * @returns 花粉预报数据，失败返回 null
   */
  fetchPollenData(lat: number, lng: number, days: number): Promise<PollenForecastResponse | null>

  /**
   * 检查数据源是否可用
   */
  isAvailable(): boolean
}

