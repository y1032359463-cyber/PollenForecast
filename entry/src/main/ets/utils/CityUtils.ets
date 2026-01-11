/**
 * 城市数据工具类
 * 提供拼音转换、省份提取、字母索引等功能
 */

// 坐标接口
export interface LocationCoordinate {
  lat: number  // 纬度
  lng: number  // 经度
}

// 城市数据接口（与 RegionView.ets 保持一致）
export interface CityItem {
  name: string
  distance: number
  isFavorite: boolean
  isTop: boolean
  pollenLevel?: number  // 花粉等级 (0-5, -1表示无数据)
  pollenIndex?: number  // 花粉指数值
  province?: string     // 省份名称
  pinyin?: string       // 拼音（用于搜索和排序）
  pinyinInitial?: string // 拼音首字母（用于字母索引）
  hasDistricts?: boolean // 是否有下级区县
  districts?: DistrictItem[] // 区县列表
  adcode?: string       // 行政区划代码
  location?: LocationCoordinate
}

// 区县数据接口
export interface DistrictItem {
  name: string          // 区县名称
  cityName: string      // 所属城市
  isFavorite: boolean   // 是否收藏
  isTop: boolean        // 是否置顶
  adcode: string        // 行政区划代码
  location: LocationCoordinate
  pollenLevel?: number  // 花粉等级（可选）
  pollenIndex?: number  // 花粉指数值（可选）
}

/**
 * 拼音映射表（常用城市）
 * 完整版需要引入第三方拼音库，这里先实现常用城市
 */
const PINYIN_MAP: Record<string, string> = {
  '北京': 'beijing',
  '上海': 'shanghai',
  '广州': 'guangzhou',
  '深圳': 'shenzhen',
  '杭州': 'hangzhou',
  '成都': 'chengdu',
  '武汉': 'wuhan',
  '重庆': 'chongqing',
  '海口': 'haikou',
  '南宁': 'nanning',
  '贵阳': 'guiyang',
  '六盘水': 'liupanshui',
  '昆明': 'kunming',
  '长沙': 'changsha',
  '南昌': 'nanchang',
  '福州': 'fuzhou',
  '南充': 'nanchong',
  '合肥': 'hefei',
  '西安': 'xian',
  '无锡': 'wuxi',
  '郑州': 'zhengzhou',
  '海南': 'hainan',
  '广西壮族自治区': 'guangxi',
  '贵州': 'guizhou',
  '云南': 'yunnan',
  '湖南': 'hunan',
  '江西': 'jiangxi',
  '福建': 'fujian',
  '湖北': 'hubei',
  '四川': 'sichuan',
  '安徽': 'anhui',
  '浙江': 'zhejiang',
  '陕西': 'shanxi',
  '江苏': 'jiangsu',
  '河南': 'henan'
}

/**
 * 提取省份名称
 * 格式：省份 城市名 或 城市名
 */
export function extractProvince(cityName: string): string {
  // 如果包含空格，提取省份部分
  const parts = cityName.split(' ')
  if (parts.length > 1) {
    return parts[0]
  }
  
  // 常见省份列表
  const provinces = ['北京', '上海', '天津', '重庆', '海南', '广西壮族自治区', '新疆维吾尔自治区', 
                     '宁夏回族自治区', '内蒙古自治区', '西藏自治区', '香港', '澳门', '台湾']
  
  // 检查是否是直辖市或自治区
  for (const province of provinces) {
    if (cityName.startsWith(province)) {
      return province
    }
  }
  
  // 提取省份（假设格式为"XX省 XX市"）
  const provinceMatch = cityName.match(/^(.+?)(省|自治区|市)/)
  if (provinceMatch) {
    return provinceMatch[1] + (provinceMatch[2] || '')
  }
  
  return '其他'
}

/**
 * 获取城市拼音
 */
export function getCityPinyin(cityName: string): string {
  // 先检查完整匹配
  if (PINYIN_MAP[cityName]) {
    return PINYIN_MAP[cityName]
  }
  
  // 提取城市名（去掉省份）
  const cityPart = cityName.split(' ').pop() || cityName
  if (PINYIN_MAP[cityPart]) {
    return PINYIN_MAP[cityPart]
  }
  
  // 如果没有匹配，返回空字符串（后续可以集成第三方拼音库）
  return ''
}

/**
 * 获取拼音首字母
 */
export function getPinyinInitial(cityName: string): string {
  const pinyin = getCityPinyin(cityName)
  if (pinyin && pinyin.length > 0) {
    return pinyin.charAt(0).toUpperCase()
  }
  
  // 如果没有拼音，使用城市名首字符
  const firstChar = cityName.charAt(0)
  // 判断是否是中文字符
  if (/[\u4e00-\u9fa5]/.test(firstChar)) {
    // 中文字符返回 #
    return '#'
  }
  
  return firstChar.toUpperCase()
}

/**
 * 城市分组接口
 */
export interface CityGroup {
  key: string        // 分组键（省份名或字母）
  title: string      // 分组标题
  cities: CityItem[] // 城市列表
  isExpanded?: boolean // 是否展开（用于省份分组）
}

/**
 * 按省份分组城市
 */
export function groupCitiesByProvince(cities: CityItem[]): CityGroup[] {
  const groups = new Map<string, CityItem[]>()
  
  cities.forEach(city => {
    const province = city.province || extractProvince(city.name)
    if (!groups.has(province)) {
      groups.set(province, [])
    }
    groups.get(province)!.push(city)
  })
  
  // 转换为数组并排序
  const result: CityGroup[] = []
  groups.forEach((cityList, province) => {
    result.push({
      key: province,
      title: province,
      cities: cityList,
      isExpanded: true // 默认展开
    })
  })
  
  // 按省份名排序
  result.sort((a, b) => {
    // 特殊省份优先
    const specialProvinces = ['北京', '上海', '天津', '重庆', '广东', '江苏', '浙江']
    const aIndex = specialProvinces.indexOf(a.title)
    const bIndex = specialProvinces.indexOf(b.title)
    
    if (aIndex !== -1 && bIndex !== -1) {
      return aIndex - bIndex
    }
    if (aIndex !== -1) return -1
    if (bIndex !== -1) return 1
    
    return a.title.localeCompare(b.title, 'zh-CN')
  })
  
  return result
}

/**
 * 按字母索引分组城市
 */
export function groupCitiesByAlphabet(cities: CityItem[]): CityGroup[] {
  const groups = new Map<string, CityItem[]>()
  
  cities.forEach(city => {
    const initial = city.pinyinInitial || getPinyinInitial(city.name)
    if (!groups.has(initial)) {
      groups.set(initial, [])
    }
    groups.get(initial)!.push(city)
  })
  
  // 转换为数组并排序
  const result: CityGroup[] = []
  groups.forEach((cityList: CityItem[], initial: string) => {
    // 对城市列表按拼音排序
    const sortedCities: CityItem[] = []
    for (let i = 0; i < cityList.length; i++) {
      sortedCities.push(cityList[i])
    }
    sortedCities.sort((a: CityItem, b: CityItem) => {
      // 按拼音排序
      const aPinyin = a.pinyin || getCityPinyin(a.name)
      const bPinyin = b.pinyin || getCityPinyin(b.name)
      return aPinyin.localeCompare(bPinyin)
    })
    
    const group: CityGroup = {
      key: initial,
      title: initial,
      cities: sortedCities
    }
    result.push(group)
  })
  
  // 按字母顺序排序，# 放在最后
  result.sort((a, b) => {
    if (a.key === '#') return 1
    if (b.key === '#') return -1
    return a.key.localeCompare(b.key)
  })
  
  return result
}

/**
 * 搜索城市（支持中文和拼音）
 */
export function searchCities(cities: CityItem[], keyword: string): CityItem[] {
  if (!keyword || keyword.trim() === '') {
    return cities
  }
  
  const lowerKeyword = keyword.toLowerCase().trim()
  const result: CityItem[] = []
  
  for (let i = 0; i < cities.length; i++) {
    const city = cities[i]
    let matched = false
    
    // 中文匹配
    if (city.name.includes(keyword)) {
      matched = true
    }
    
    // 拼音匹配
    if (!matched) {
      const pinyin = city.pinyin || getCityPinyin(city.name)
      if (pinyin && pinyin.toLowerCase().includes(lowerKeyword)) {
        matched = true
      }
    }
    
    // 拼音首字母匹配
    if (!matched) {
      const initial = city.pinyinInitial || getPinyinInitial(city.name)
      if (initial.toLowerCase() === lowerKeyword) {
        matched = true
      }
    }
    
    if (matched) {
      result.push(city)
    }
  }
  
  return result
}

/**
 * 城市排序（置顶 > 收藏 > 花粉浓度 > 距离）
 */
export function sortCities(cities: CityItem[]): CityItem[] {
  // 创建副本
  const result: CityItem[] = []
  for (let i = 0; i < cities.length; i++) {
    result.push(cities[i])
  }
  
  result.sort((a: CityItem, b: CityItem) => {
    // 1. 置顶优先
    if (a.isTop && !b.isTop) return -1
    if (!a.isTop && b.isTop) return 1
    
    // 2. 收藏次之
    if (a.isFavorite && !b.isFavorite) return -1
    if (!a.isFavorite && b.isFavorite) return 1
    
    // 3. 花粉浓度排序（从低到高）
    const aLevel = a.pollenLevel ?? -1
    const bLevel = b.pollenLevel ?? -1
    if (aLevel !== -1 && bLevel !== -1) {
      return aLevel - bLevel
    }
    if (aLevel !== -1) return -1  // 有数据的排在前面
    if (bLevel !== -1) return 1
    
    // 4. 按距离排序
    return a.distance - b.distance
  })
  
  return result
}
