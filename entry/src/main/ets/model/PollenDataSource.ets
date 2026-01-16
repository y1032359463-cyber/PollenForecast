/**
 * 花粉数据源配置
 * 用户可选择不同的数据源提供商
 */

/**
 * 数据源类型枚举
 */
export enum PollenDataSourceType {
  GOOGLE = 'GOOGLE',           // Google Pollen API（全球覆盖）
  MINSHU = 'MINSHU',           // 敏舒城市过敏预报（国内权威，2026-01-09 新增）
  CMA = 'CMA',                 // 中国气象局（国内权威）
  QWEATHER = 'QWEATHER',       // 和风天气（如果支持）
  AUTO = 'AUTO'                // 自动选择（默认）
}

/**
 * 数据源配置
 */
export interface PollenDataSourceConfig {
  type: PollenDataSourceType
  name: string                 // 显示名称
  description: string          // 描述
  coverage: string            // 覆盖范围（全球/国内）
  accuracy: string            // 数据准确性
  updateFrequency: string     // 更新频率
  enabled: boolean            // 是否可用
}

/**
 * 数据源列表配置
 */
export const POLLEN_DATA_SOURCES: PollenDataSourceConfig[] = [
  {
    type: PollenDataSourceType.AUTO,
    name: '自动选择',
    description: '根据网络和位置自动选择最佳数据源',
    coverage: '全球',
    accuracy: '高',
    updateFrequency: '实时',
    enabled: true
  },
  {
    type: PollenDataSourceType.GOOGLE,
    name: 'Google Pollen API',
    description: '全球花粉数据，覆盖范围广',
    coverage: '全球',
    accuracy: '高',
    updateFrequency: '每日更新',
    enabled: true
  },
  {
    type: PollenDataSourceType.MINSHU,
    name: '敏舒城市过敏预报',
    description: '国内权威花粉数据，覆盖全国省市区县',
    coverage: '国内',
    accuracy: '高',
    updateFrequency: '每日更新',
    enabled: true  // ✅ 已实现（2026-01-09）
  },
  {
    type: PollenDataSourceType.CMA,
    name: '中国气象局',
    description: '国内权威花粉数据',
    coverage: '国内',
    accuracy: '高',
    updateFrequency: '每日更新',
    enabled: false  // 待实现
  },
  {
    type: PollenDataSourceType.QWEATHER,
    name: '和风天气',
    description: '国内生活指数花粉数据，覆盖全国3578个城市区县',
    coverage: '国内',
    accuracy: '中',
    updateFrequency: '每日更新',
    enabled: true  // ✅ 已实现（2026-01-16）
  }
]

/**
 * 获取数据源显示名称
 */
export function getDataSourceName(type: PollenDataSourceType): string {
  for (let i = 0; i < POLLEN_DATA_SOURCES.length; i++) {
    if (POLLEN_DATA_SOURCES[i].type === type) {
      return POLLEN_DATA_SOURCES[i].name
    }
  }
  return '未知'
}

/**
 * 获取数据源描述
 */
export function getDataSourceDescription(type: PollenDataSourceType): string {
  for (let i = 0; i < POLLEN_DATA_SOURCES.length; i++) {
    if (POLLEN_DATA_SOURCES[i].type === type) {
      return POLLEN_DATA_SOURCES[i].description
    }
  }
  return ''
}

