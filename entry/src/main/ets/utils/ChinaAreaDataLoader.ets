/**
 * 中国行政区划数据加载器
 * 用于加载和解析 china_area_full.json 数据
 */

import { CityItem, DistrictItem, LocationCoordinate } from './CityUtils'
import resourceManager from '@ohos.resourceManager'

// 原始数据接口（与JSON结构对应）
interface RawAreaData {
  citycode: string | string[]
  adcode: string
  name: string
  center: string  // 格式：“经度,纬度”
  level: string   // "province" | "city" | "district"
  districts: RawAreaData[]
}

/**
 * 解析中心点坐标
 * @param center 格式："113.264499,23.130061"
 * @returns {lat, lng}
 */
function parseCenter(center: string): LocationCoordinate {
  const parts = center.split(',')
  const lng = parseFloat(parts[0])
  const lat = parseFloat(parts[1])
  const result: LocationCoordinate = { lat: lat, lng: lng }
  return result
}

/**
 * 加载并解析JSON数据
 * @param context 应用上下文
 */
export async function loadChinaAreaData(context: Context): Promise<CityItem[]> {
  try {
    // 获取资源管理器
    const resMgr = context.resourceManager
    
    // 读取rawfile中的JSON文件
    const rawFile = await resMgr.getRawFileContent('china_area_full.json')
    
    // 转换为Uint8Array再转为字符串
    const uint8Array = new Uint8Array(rawFile.buffer)
    let jsonString = ''
    for (let i = 0; i < uint8Array.length; i++) {
      jsonString += String.fromCharCode(uint8Array[i])
    }
    
    // 解析JSON
    const provinceData: RawAreaData[] = JSON.parse(jsonString)
    
    // 转换为CityItem数组
    const cities: CityItem[] = []
    
    for (const province of provinceData) {
      // 遍历省份下的城市
      for (const city of province.districts) {
        if (city.level !== 'city') continue
        
        // 解析城市坐标
        const location = parseCenter(city.center)
        
        // 解析区县列表
        const districts: DistrictItem[] = []
        const hasDistricts = city.districts && city.districts.length > 0
        
        if (hasDistricts) {
          for (const district of city.districts) {
            if (district.level === 'district') {
              const districtLocation = parseCenter(district.center)
              const districtItem: DistrictItem = {
                name: district.name,
                cityName: city.name,
                isFavorite: false,
                isTop: false,
                adcode: district.adcode,
                location: districtLocation
              }
              districts.push(districtItem)
            }
          }
        }
        
        // 创建CityItem
        const cityItem: CityItem = {
          name: city.name,
          province: province.name,
          distance: 0,  // 默认值，后续通过定位更新
          isFavorite: false,
          isTop: false,
          hasDistricts: hasDistricts,
          districts: hasDistricts ? districts : undefined,
          adcode: city.adcode,
          location: location
        }
        cities.push(cityItem)
      }
    }
    
    console.info(`[ChinaAreaDataLoader] 加载完成，共 ${cities.length} 个城市`)
    return cities
    
  } catch (error) {
    console.error(`[ChinaAreaDataLoader] 加载失败: ${JSON.stringify(error)}`)
    return []
  }
}

/**
 * 根据城市名获取城市数据（包含区县）
 * 支持模糊匹配："广州" 和 "广州市" 都能匹配
 */
export function getCityWithDistricts(cities: CityItem[], cityName: string): CityItem | null {
  // 1. 精确匹配
  for (const city of cities) {
    if (city.name === cityName) {
      return city
    }
  }
  
  // 2. 模糊匹配（去掉"市"后缀）
  const normalizedSearchName = cityName.replace(/市$/, '')
  for (const city of cities) {
    const normalizedCityName = city.name.replace(/市$/, '')
    if (normalizedCityName === normalizedSearchName) {
      return city
    }
  }
  
  return null
}

/**
 * 根据adcode获取城市数据
 */
export function getCityByAdcode(cities: CityItem[], adcode: string): CityItem | null {
  for (const city of cities) {
    if (city.adcode === adcode) {
      return city
    }
  }
  return null
}

/**
 * 搜索区县
 */
export function searchDistricts(city: CityItem, keyword: string): DistrictItem[] {
  if (!city.districts || !keyword) {
    return city.districts || []
  }
  
  const lowerKeyword = keyword.toLowerCase().trim()
  const results: DistrictItem[] = []
  
  for (const district of city.districts) {
    if (district.name.includes(keyword) || district.adcode.includes(lowerKeyword)) {
      results.push(district)
    }
  }
  
  return results
}
