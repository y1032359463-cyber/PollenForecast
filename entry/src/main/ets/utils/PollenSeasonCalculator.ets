/**
 * 花粉季节计算工具类
 * 用于判断当前是否在花粉季、计算下次花粉期等
 */

import { PollenSeasonInfo, SeasonPeriod, getPollenSeasonByCity } from '../model/PollenSeasonData'

export interface NextSeasonResult {
  isInSeason: boolean        // 当前是否在花粉季
  currentSeason: SeasonPeriod | null   // 当前花粉季信息
  nextSeason: SeasonPeriod | null      // 下次花粉季信息
  daysUntilNext: number      // 距离下次花粉期的天数
  message: string            // 用户友好的提示信息
}

/**
 * 花粉季节计算器
 */
export class PollenSeasonCalculator {
  /**
   * 判断指定日期是否在某个花粉季内
   * @param date 要判断的日期
   * @param season 花粉季信息
   * @returns 是否在花粉季内
   */
  static isDateInSeason(date: Date, season: SeasonPeriod): boolean {
    const month = date.getMonth() + 1  // JavaScript月份从0开始，需+1
    
    // 判断是否在花粉季月份范围内
    if (season.startMonth <= season.endMonth) {
      // 正常情况：3月-5月
      return month >= season.startMonth && month <= season.endMonth
    } else {
      // 跨年情况（理论上花粉季不会跨年，但预留判断）
      return month >= season.startMonth || month <= season.endMonth
    }
  }

  /**
   * 计算两个日期之间的天数差
   * @param date1 第一个日期
   * @param date2 第二个日期
   * @returns 天数差（正数表示date2在date1之后）
   */
  static getDaysDifference(date1: Date, date2: Date): number {
    const timeDiff = date2.getTime() - date1.getTime()
    return Math.floor(timeDiff / (1000 * 60 * 60 * 24))
  }

  /**
   * 计算距离指定月份还有多少天
   * @param currentDate 当前日期
   * @param targetMonth 目标月份 (1-12)
   * @returns 剩余天数
   */
  static getDaysUntilMonth(currentDate: Date, targetMonth: number): number {
    const currentYear = currentDate.getFullYear()
    const currentMonth = currentDate.getMonth() + 1
    
    let targetYear = currentYear
    
    // 如果目标月份在当前月份之前，说明是明年的
    if (targetMonth < currentMonth) {
      targetYear = currentYear + 1
    }
    
    // 创建目标日期（月份的第一天）
    const targetDate = new Date(targetYear, targetMonth - 1, 1)
    
    return PollenSeasonCalculator.getDaysDifference(currentDate, targetDate)
  }

  /**
   * 判断当前是否在花粉季，并计算下次花粉期信息
   * @param cityName 城市名称
   * @param currentDate 当前日期（可选，默认为系统当前时间）
   * @returns 花粉季信息
   */
  static getNextSeasonInfo(cityName: string, currentDate?: Date): NextSeasonResult {
    const now = currentDate || new Date()
    const cityData = getPollenSeasonByCity(cityName)
    
    // 如果城市不在数据库中
    if (cityData === null || cityData.seasons.length === 0) {
      return {
        isInSeason: false,
        currentSeason: null,
        nextSeason: null,
        daysUntilNext: -1,
        message: '暂无该城市花粉季节数据'
      }
    }

    // 检查是否在任何一个花粉季内
    for (const season of cityData.seasons) {
      if (PollenSeasonCalculator.isDateInSeason(now, season)) {
        // 当前正在花粉季内
        return {
          isInSeason: true,
          currentSeason: season,
          nextSeason: null,
          daysUntilNext: 0,
          message: `正处于${season.name}（${season.startMonth}月-${season.endMonth}月）`
        }
      }
    }

    // 不在花粉季内，计算下次花粉期
    const currentMonth = now.getMonth() + 1
    let nextSeason: SeasonPeriod | null = null
    let minDays = Number.MAX_VALUE

    for (const season of cityData.seasons) {
      const daysUntil = PollenSeasonCalculator.getDaysUntilMonth(now, season.startMonth)
      
      // 找到最近的下一个花粉季
      if (daysUntil > 0 && daysUntil < minDays) {
        minDays = daysUntil
        nextSeason = season
      }
    }

    // 如果今年没有找到下一个花粉季，说明所有花粉季都已结束
    // 则下一个花粉季是明年的第一个（通常是春季）
    if (nextSeason === null && cityData.seasons.length > 0) {
      // 按开始月份排序，找到最早的花粉季
      const sortedSeasons = [...cityData.seasons].sort((a, b) => a.startMonth - b.startMonth)
      nextSeason = sortedSeasons[0]
      minDays = PollenSeasonCalculator.getDaysUntilMonth(now, nextSeason.startMonth)
    }

    if (nextSeason === null) {
      return {
        isInSeason: false,
        currentSeason: null,
        nextSeason: null,
        daysUntilNext: -1,
        message: '暂无花粉季节数据'
      }
    }

    return {
      isInSeason: false,
      currentSeason: null,
      nextSeason: nextSeason,
      daysUntilNext: minDays,
      message: `距离${nextSeason.name}还有 ${minDays} 天`
    }
  }

  /**
   * 简化版判断：当前是否在花粉季
   * @param cityName 城市名称
   * @returns 是否在花粉季
   */
  static isInPollenSeason(cityName: string): boolean {
    const result = PollenSeasonCalculator.getNextSeasonInfo(cityName)
    return result.isInSeason
  }

  /**
   * 获取当前花粉季的防护建议
   * @param cityName 城市名称
   * @returns 防护建议数组，如果不在花粉季则返回空数组
   */
  static getCurrentSeasonTips(cityName: string): string[] {
    const result = PollenSeasonCalculator.getNextSeasonInfo(cityName)
    if (result.isInSeason && result.currentSeason !== null) {
      return result.currentSeason.tips
    }
    return []
  }

  /**
   * 获取下次花粉季的预警信息
   * @param cityName 城市名称
   * @returns 预警信息对象
   */
  static getNextSeasonAlert(cityName: string): NextSeasonAlertResult {
    const result = PollenSeasonCalculator.getNextSeasonInfo(cityName)
    
    if (result.nextSeason !== null) {
      return {
        hasAlert: true,
        seasonName: result.nextSeason.name,
        daysUntil: result.daysUntilNext,
        mainAllergens: result.nextSeason.mainAllergens,
        level: result.nextSeason.level
      }
    }
    
    return {
      hasAlert: false,
      seasonName: '',
      daysUntil: -1,
      mainAllergens: [],
      level: 0
    }
  }
}

export interface NextSeasonAlertResult {
  hasAlert: boolean
  seasonName: string
  daysUntil: number
  mainAllergens: string[]
  level: number
}
