/**
 * Google Pollen API 数据模型
 * 基于 https://developers.google.com/maps/documentation/pollen/reference
 */

/**
 * 卡片表单数据模型
 */
export interface WidgetFormData {
  pollenValue: string
  pollenLevel: string
  cityName: string
}

// ========== API 响应模型 ==========

/**
 * 花粉预报响应
 */
export interface PollenForecastResponse {
  regionCode: string
  dailyInfo: DailyInfo[]
}

/**
 * 每日花粉信息
 */
export interface DailyInfo {
  date: DateInfo
  pollenTypeInfo: PollenTypeInfo[]
  plantInfo: PlantInfo[]
}

/**
 * 日期信息
 */
export interface DateInfo {
  year: number
  month: number
  day: number
}

/**
 * 花粉类型信息 (GRASS/TREE/WEED)
 */
export interface PollenTypeInfo {
  code: string
  displayName: string
  inSeason: boolean
  indexInfo: IndexInfo | null
  healthRecommendations: string[]
}

/**
 * 指数信息
 */
export interface IndexInfo {
  code: string
  displayName: string
  value: number
  category: string
  indexDescription: string
}

/**
 * 植物信息
 */
export interface PlantInfo {
  code: string
  displayName: string
  inSeason: boolean
  indexInfo: IndexInfo | null
}

// ========== 花粉等级枚举 ==========

export enum PollenLevel {
  NONE = 0,
  VERY_LOW = 1,
  LOW = 2,
  MODERATE = 3,
  HIGH = 4,
  VERY_HIGH = 5
}

// ========== 工具函数 ==========

/**
 * 将 API 返回的 category 转换为 PollenLevel
 */
export function categoryToLevel(category: string): PollenLevel {
  if (category === 'None') {
    return PollenLevel.NONE
  } else if (category === 'Very Low') {
    return PollenLevel.VERY_LOW
  } else if (category === 'Low') {
    return PollenLevel.LOW
  } else if (category === 'Moderate') {
    return PollenLevel.MODERATE
  } else if (category === 'High') {
    return PollenLevel.HIGH
  } else if (category === 'Very High') {
    return PollenLevel.VERY_HIGH
  }
  return PollenLevel.NONE
}

/**
 * 将 PollenLevel 转换为中文文本
 */
export function levelToText(level: PollenLevel): string {
  if (level === PollenLevel.NONE) {
    return '无'
  } else if (level === PollenLevel.VERY_LOW) {
    return '很低'
  } else if (level === PollenLevel.LOW) {
    return '低'
  } else if (level === PollenLevel.MODERATE) {
    return '中等'
  } else if (level === PollenLevel.HIGH) {
    return '高'
  } else if (level === PollenLevel.VERY_HIGH) {
    return '很高'
  }
  return '未知'
}

/**
 * 根据花粉等级获取颜色
 */
export function levelToColor(level: PollenLevel): string {
  if (level === PollenLevel.NONE) {
    return '#4CAF50'
  } else if (level === PollenLevel.VERY_LOW) {
    return '#8BC34A'
  } else if (level === PollenLevel.LOW) {
    return '#CDDC39'
  } else if (level === PollenLevel.MODERATE) {
    return '#FFC107'
  } else if (level === PollenLevel.HIGH) {
    return '#FF9800'
  } else if (level === PollenLevel.VERY_HIGH) {
    return '#F44336'
  }
  return '#757575'
}

/**
 * 格式化日期为 MM/DD
 */
export function formatDateShort(dateInfo: DateInfo): string {
  const month = dateInfo.month.toString().padStart(2, '0')
  const day = dateInfo.day.toString().padStart(2, '0')
  return `${month}/${day}`
}

/**
 * 从 DailyInfo 中获取最高花粉指数
 * 兼容 API 响应中字段名首字母大写的情况
 */
export function getMaxPollenFromDaily(dayInfo: DailyInfo): PollenLevel {
  let maxLevel = PollenLevel.NONE

  // 检查 pollenTypeInfo 是否存在
  if (dayInfo.pollenTypeInfo && dayInfo.pollenTypeInfo.length > 0) {
    for (let i = 0; i < dayInfo.pollenTypeInfo.length; i++) {
      const typeInfo = dayInfo.pollenTypeInfo[i]
      
      // 检查 indexInfo 是否存在
      if (typeInfo.indexInfo !== null && typeInfo.indexInfo !== undefined) {
        const category = typeInfo.indexInfo.category || 'None'
        const level = categoryToLevel(category)
        if (level > maxLevel) {
          maxLevel = level
        }
      }
    }
  }

  return maxLevel
}

/**
 * 从 DailyInfo 中获取最高花粉指数值
 */
export function getMaxPollenIndexFromDaily(dayInfo: DailyInfo): number {
  let maxIndex = 0

  // 检查 pollenTypeInfo 是否存在
  if (dayInfo.pollenTypeInfo && dayInfo.pollenTypeInfo.length > 0) {
    for (let i = 0; i < dayInfo.pollenTypeInfo.length; i++) {
      const typeInfo = dayInfo.pollenTypeInfo[i]
      
      // 检查 indexInfo 是否存在
      if (typeInfo.indexInfo !== null && typeInfo.indexInfo !== undefined) {
        const value = typeInfo.indexInfo.value || 0
        if (value > maxIndex) {
          maxIndex = value
        }
      }
    }
  }

  return maxIndex
}

/**
 * 从 DailyInfo 中提取去重的健康建议
 */
export function getHealthRecommendationsFromDaily(dayInfo: DailyInfo): string[] {
  const recommendations: Set<string> = new Set()

  if (dayInfo.pollenTypeInfo && dayInfo.pollenTypeInfo.length > 0) {
    for (const typeInfo of dayInfo.pollenTypeInfo) {
      if (typeInfo.healthRecommendations && typeInfo.healthRecommendations.length > 0) {
        for (const rec of typeInfo.healthRecommendations) {
          if (rec && rec.trim().length > 0) {
            recommendations.add(rec)
          }
        }
      }
    }
  }

  return Array.from(recommendations)
}
