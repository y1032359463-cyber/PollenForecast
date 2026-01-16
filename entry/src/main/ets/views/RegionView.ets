/**
 * 区域页面 - Tab2
 * 城市列表，支持搜索和收藏
 * 滑动操作：收藏/取消收藏/置顶
 */

import { LocationService, LocationInfo } from '../service/LocationService'
import { vibrator } from '@kit.SensorServiceKit'
import { promptAction } from '@kit.ArkUI'
import {
  extractProvince,
  getCityPinyin,
  getPinyinInitial,
  groupCitiesByProvince,
  groupCitiesByAlphabet,
  searchCities,
  sortCities,
  loadPinyinMap,
  CityGroup,
  CityItem,
  DistrictItem
} from '../utils/CityUtils'
import { PollenService } from '../service/PollenService'
import { PollenLevel, getMaxPollenFromDaily } from '../model/PollenModels'
import { loadChinaAreaData, getCityWithDistricts } from '../utils/ChinaAreaDataLoader'  // 新增：区县数据加载器
import { PollenDataSourceType } from '../model/PollenDataSource' // ✅ 新增：导入枚举用于精准判断

// 城市坐标接口
interface CityCoordinate {
  lat: number
  lng: number
}

// 花粉缓存数据接口
interface PollenCacheData {
  level: number
  index: number
}

// 城市经纬度映射表
const cityCoordinates: Record<string, CityCoordinate> = {
  '当前位置': {lat: 39.9042, lng: 116.4074},  // 默认北京坐标
  '北京市': {lat: 39.9042, lng: 116.4074},
  '上海市': {lat: 31.2304, lng: 121.4737},
  '广州市': {lat: 23.1291, lng: 113.2644},
  '深圳市': {lat: 22.5431, lng: 114.0579},
  '杭州市': {lat: 30.2741, lng: 120.1551},
  '成都市': {lat: 30.5728, lng: 104.0668},
  '武汉市': {lat: 30.5928, lng: 114.3055},
  '重庆市': {lat: 29.4316, lng: 106.9123},
  '海南省, 海口市': {lat: 20.0444, lng: 110.1989},
  '广西壮族自治区, 南宁市': {lat: 22.8170, lng: 108.3665},
  '贵州省, 贵阳市': {lat: 26.6470, lng: 106.6302},
  '贵州省, 六盘水': {lat: 26.5918, lng: 104.8305},
  '云南省, 昆明市': {lat: 25.0406, lng: 102.7129},
  '湖南省, 长沙市': {lat: 28.2278, lng: 112.9388},
  '江西省, 南昌市': {lat: 28.6829, lng: 115.8579},
  '福建省, 福州市': {lat: 26.0745, lng: 119.2965},
  '湖北省, 武汉市': {lat: 30.5928, lng: 114.3055},
  '四川省, 南充市': {lat: 30.8376, lng: 106.1107},
  '安徽省, 合肥市': {lat: 31.8206, lng: 117.2272},
  '浙江省, 杭州市': {lat: 30.2741, lng: 120.1551},
  '陕西省, 西安市': {lat: 34.3416, lng: 108.9398},
  '江苏省, 无锡市': {lat: 31.4912, lng: 120.3119},
  '河南省, 郑州市': {lat: 34.7472, lng: 113.6249}
}

@Component
export struct RegionView {
  @State searchText: string = ''
  @StorageLink('currentCity') currentCity: string = '定位中...'
  @StorageLink('currentAdcode') currentAdcode: string = ''
  @State actualLocationCity: string = ''  // GPS定位的真实城市名
  @State isAnimating: boolean = false
  @State firstLoad: boolean = true  // 首次加载标志（性能优化）
  @State swipeOffsets: Map<string, number> = new Map()  // 手动滑动状态管理
  @State isRefreshingLocation: boolean = false  // GPS定位中
  private lastUpdateTime: number = 0  // 节流：上次更新时间
  private pendingOffset: Map<string, number> = new Map()  // 节流：待更新的偏移值
  private swipeStartTime: number = 0  // 手势开始时间
  private isSwipeGesture: boolean = false  // 是否为手势滑动（区分点击和滑动）
  private cachedLocation: LocationInfo | null = null  // 缓存的GPS位置，用于快速响应
  @StorageLink('safeTop') safeTop: number = 44
  @StorageLink('safeBottom') safeBottom: number = 28
  @StorageLink('vibrationEnabled') vibrationEnabled: boolean = false  // 震动反馈开关
  @StorageLink('pollenThemeColor') pollenThemeColor: string = '#4CAF50'  // 花粉主题色
  @StorageLink('pollenThemeTextColor') pollenThemeTextColor: string = '#2E7D32' // 花粉主题文字色
  @StorageLink('pollenDataSource') dataSourceType: string = 'AUTO' // 当前数据源类型
  
  // 免费版收藏上限，后续可与会员体系打通
  private readonly MAX_FREE_FAVORITES: number = 4

  // 当前处于滑动展开状态的 key（城市或区县）
  private currentSwipeKey: string = ''
  
  private locationService: LocationService = LocationService.getInstance()

  // 滚动控制器
  private scroller: Scroller = new Scroller()

  // 定时更新花粉数据的定时器
  private pollenUpdateTimer: number | null = null

  // 最后一次更新时间
  private lastPollenUpdateTime: number = 0

  // 收藏的城市列表（用于“我的收藏”Tab）
  @State favoriteCities: string[] = []

  // 热门/收藏 Tab 当前索引：0=热门城市，1=我的收藏
  @State hotTabIndex: number = 0

  // 热门城市列表
  @State hotCities: string[] = ['北京市', '上海市', '广州市', '深圳市', '杭州市', '成都市', '武汉市', '重庆市']

  // 城市列表数据（初始化时添加拼音和省份信息）
  @State cityList: CityItem[] = [
    { name: '北京市', distance: 0, isFavorite: false, isTop: false, province: '北京', pinyin: 'beijing', pinyinInitial: 'B' },
    { name: '上海市', distance: 0, isFavorite: false, isTop: false, province: '上海', pinyin: 'shanghai', pinyinInitial: 'S' },
    { name: '广州市', distance: 0, isFavorite: false, isTop: false, province: '广东', pinyin: 'guangzhou', pinyinInitial: 'G' },
    { name: '深圳市', distance: 0, isFavorite: false, isTop: false, province: '广东', pinyin: 'shenzhen', pinyinInitial: 'S' },
    { name: '杭州市', distance: 0, isFavorite: false, isTop: false, province: '浙江', pinyin: 'hangzhou', pinyinInitial: 'H' },
    { name: '成都市', distance: 0, isFavorite: false, isTop: false, province: '四川', pinyin: 'chengdu', pinyinInitial: 'C' },
    { name: '武汉市', distance: 0, isFavorite: false, isTop: false, province: '湖北', pinyin: 'wuhan', pinyinInitial: 'W' },
    { name: '重庆市', distance: 0, isFavorite: false, isTop: false, province: '重庆', pinyin: 'chongqing', pinyinInitial: 'C' },
    { name: '海南省, 海口市', distance: 16, isFavorite: false, isTop: false, province: '海南', pinyin: 'haikou', pinyinInitial: 'H' },
    { name: '广西壮族自治区, 南宁市', distance: 363, isFavorite: false, isTop: false, province: '广西', pinyin: 'nanning', pinyinInitial: 'N' },
    { name: '贵州省, 贵阳市', distance: 820, isFavorite: false, isTop: false, province: '贵州', pinyin: 'guiyang', pinyinInitial: 'G' },
    { name: '贵州省, 六盘水', distance: 911, isFavorite: false, isTop: false, province: '贵州', pinyin: 'liupanshui', pinyinInitial: 'L' },
    { name: '云南省, 昆明市', distance: 926, isFavorite: false, isTop: false, province: '云南', pinyin: 'kunming', pinyinInitial: 'K' },
    { name: '湖南省, 长沙市', distance: 953, isFavorite: false, isTop: false, province: '湖南', pinyin: 'changsha', pinyinInitial: 'C' },
    { name: '江西省, 南昌市', distance: 1121, isFavorite: false, isTop: false, province: '江西', pinyin: 'nanchang', pinyinInitial: 'N' },
    { name: '福建省, 福州市', distance: 1151, isFavorite: false, isTop: false, province: '福建', pinyin: 'fuzhou', pinyinInitial: 'F' },
    { name: '湖北省, 武汉市', distance: 1244, isFavorite: false, isTop: false, province: '湖北', pinyin: 'wuhan', pinyinInitial: 'W' },
    { name: '四川省, 南充市', distance: 1267, isFavorite: false, isTop: false, province: '四川', pinyin: 'nanchong', pinyinInitial: 'N' },
    { name: '安徽省, 合肥市', distance: 1487, isFavorite: false, isTop: false, province: '安徽', pinyin: 'hefei', pinyinInitial: 'H' },
    { name: '浙江省, 杭州市', distance: 1519, isFavorite: false, isTop: false, province: '浙江', pinyin: 'hangzhou', pinyinInitial: 'H' },
    { name: '陕西省, 西安市', distance: 1593, isFavorite: false, isTop: false, province: '陕西', pinyin: 'xian', pinyinInitial: 'X' },
    { name: '江苏省, 无锡市', distance: 1627, isFavorite: false, isTop: false, province: '江苏', pinyin: 'wuxi', pinyinInitial: 'W' },
    { name: '河南省, 郑州市', distance: 1669, isFavorite: false, isTop: false, province: '河南', pinyin: 'zhengzhou', pinyinInitial: 'Z' }
  ]

  // 分组显示模式：'province' | 'alphabet' | 'none'
  @State displayMode: 'province' | 'alphabet' | 'none' = 'province'

  // 花粉数据缓存
  @State pollenDataCache: Map<string, PollenCacheData> = new Map()

  // 分组展开状态（改用数组，解决Set不触发响应式更新问题）
  @State expandedGroups: string[] = []

  // ====== 区县选择相关状态 ======
  @State allCitiesData: CityItem[] = []  // 完整城市数据（包含区县信息）
  @State showDistrictDialog: boolean = false  // 是否显示区县选择弹窗
  @State selectedCityForDistrict: CityItem | null = null  // 当前选中要查看区县的城市

  // 判断是否应该播放动画(仅首次加载且前10项)
  shouldAnimate(index: number): boolean {
    return this.firstLoad && index < 10
  }

  // Haversine 距离计算函数（返回公里数）
  calculateDistance(lat1: number, lng1: number, lat2: number, lng2: number): number {
    const R = 6371 // 地球半径(km)
    const dLat = this.deg2rad(lat2 - lat1)
    const dLng = this.deg2rad(lng2 - lng1)

    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.deg2rad(lat1)) * Math.cos(this.deg2rad(lat2)) *
      Math.sin(dLng / 2) * Math.sin(dLng / 2)

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    return Math.round(R * c) // 四舍五入到整数公里
  }

  // 角度转弧度
  deg2rad(deg: number): number {
    return deg * (Math.PI / 180)
  }

  // 获取城市花粉浓度等级（模拟方法，实际需要从缓存或API获取）
  getPollenLevelForCity(cityName: string): number {
    // 检查是否已经有缓存的花粉数据
    const cacheData = this.pollenDataCache.get(cityName)
    if (cacheData) {
      return cacheData.level
    }
    return -1 // 无数据
  }

  // 根据花粉等级获取颜色 (确保对比度 ≥ 3:1)
  getPollenColor(level: number): ResourceColor {
    switch (level) {
      case 0:
        return '#4CAF50' // 无/极低 - 绿色
      case 1:
        return '#8BC34A' // 很低 - 浅绿
      case 2:
        return '#AFB42B' // 低 - 橄榄绿 (比原来的 #CDDC39 更深，确保可见度)
      case 3:
        return '#FBC02D' // 中 - 深黄
      case 4:
        return '#F57C00' // 高 - 深橙
      case 5:
        return '#D32F2F' // 很高 - 深红
      default:
        return '#757575' // 无数据 - 灰色
    }
  }


  // 过滤城市列表
  getFilteredCities(): CityItem[] {
    let targetList = this.cityList
    const isGoogle = this.dataSourceType === PollenDataSourceType.GOOGLE
    
    console.info(`[RegionView] 🔍 过滤逻辑触发: dataSourceType=${this.dataSourceType}, isGoogle=${isGoogle}, searchText="${this.searchText}"`)

    if (this.searchText && this.searchText.trim() !== '') {
      if (isGoogle) {
        // Google 模式：严格限制在基础 20 个城市中搜索
        targetList = searchCities(this.cityList, this.searchText)
        console.info(`[RegionView] Google 搜索模式，匹配数量: ${targetList.length}`)
      } else {
        // 国内源：支持全国 3200+ 区域搜索
        if (this.allCitiesData && this.allCitiesData.length > 0) {
          targetList = searchCities(this.allCitiesData, this.searchText)
          if (targetList.length > 50) {
            targetList = targetList.slice(0, 50)
          }
          console.info(`[RegionView] 国内源搜索模式，匹配数量: ${targetList.length}`)
        } else {
          targetList = searchCities(this.cityList, this.searchText)
        }
      }
    } else {
      // 无搜索时
      if (isGoogle) {
        // Google 模式：只显示基础列表 (约20个城市)
        targetList = this.cityList
        console.info(`[RegionView] Google 模式 - 显示基础城市列表 (${targetList.length}个)`)
      } else {
        // 国内源/AUTO 模式：显示全国 3200+ 区域列表（按省份分组）
        if (this.allCitiesData && this.allCitiesData.length > 0) {
          targetList = this.allCitiesData
          console.info(`[RegionView] 国内源模式 - 显示全量城市列表 (${targetList.length}个)`)
        } else {
          targetList = this.cityList
        }
      }
    }

    return sortCities(targetList)
  }

  // 获取分组后的城市列表
  getGroupedCities(): CityGroup[] {
    const filteredCities = this.getFilteredCities()
    console.info(`[RegionView] getGroupedCities - displayMode: ${this.displayMode}, filteredCities 数量: ${filteredCities.length}`)

    if (this.displayMode === 'province') {
      const groups = groupCitiesByProvince(filteredCities)
      console.info(`[RegionView] groupCitiesByProvince 返回 ${groups.length} 个省份分组`)
      
      // 应用展开状态
      const result: CityGroup[] = []
      for (let i = 0; i < groups.length; i++) {
        const group = groups[i]
        const updatedGroup: CityGroup = {
          key: group.key,
          title: group.title,
          cities: group.cities,
          isExpanded: this.expandedGroups.includes(group.key)
        }
        console.info(`[RegionView] 分组 ${group.title} (${group.key}): isExpanded=${updatedGroup.isExpanded}, cities=${group.cities.length}`)
        result.push(updatedGroup)
      }
      return result
    } else if (this.displayMode === 'alphabet') {
      return groupCitiesByAlphabet(filteredCities)
    } else {
      // 不分组，返回单个分组
      const allGroup: CityGroup = {
        key: 'all',
        title: '全部',
        cities: filteredCities
      }
      return [allGroup]
    }
  }

  // 获取字母索引列表（用于右侧导航）
  getAlphabetIndex(): string[] {
    if (this.displayMode !== 'alphabet') {
      return []
    }

    const groups = groupCitiesByAlphabet(this.getFilteredCities())
    const result: string[] = []
    for (let i = 0; i < groups.length; i++) {
      result.push(groups[i].key)
    }
    return result
  }

  // 切换分组展开状态
  toggleGroup(groupKey: string): void {
    console.info(`[RegionView] toggleGroup 被调用，groupKey: ${groupKey}`)
    console.info(`[RegionView] 展开前 expandedGroups:`, this.expandedGroups)

    // 使用不可变数组更新方式，确保触发响应式更新（避免使用展开运算符）
    let newExpandedGroups: string[]
    if (this.expandedGroups.includes(groupKey)) {
      // 删除：过滤出当前 key，创建新数组触发响应式更新
      newExpandedGroups = this.expandedGroups.filter(k => k !== groupKey)
      console.info(`[RegionView] 删除 ${groupKey}，现在折叠`)
    } else {
      // 添加：使用 concat 创建新数组，触发响应式更新
      newExpandedGroups = this.expandedGroups.concat([groupKey])
      console.info(`[RegionView] 添加 ${groupKey}，现在展开`)
    }
    this.expandedGroups = newExpandedGroups

    console.info(`[RegionView] 展开后 expandedGroups:`, this.expandedGroups)

    // ✨ 动画效果（可选，用于平滑过渡）
    // 注意：状态已更新，动画只是视觉效果
    animateTo({
      duration: 200,  // 动画时长 200ms（缩短以提高响应速度）
      curve: Curve.EaseInOut
    }, () => {
      // 空回调，状态已在上面更新
    })
  }

  // 更新所有城市距离（基于 GPS 实际位置）
  updateAllDistances(): void {
    // 如果没有GPS位置，不计算距离
    if (!this.actualLocationCity) {
      console.warn(`[RegionView] GPS位置未获取，无法计算距离`)
      return
    }

    const gpsCoords = cityCoordinates[this.actualLocationCity]
    if (!gpsCoords) {
      console.warn(`[RegionView] 找不到GPS城市坐标: ${this.actualLocationCity}`)
      return
    }

    // 创建新数组以触发响应式更新
    const updatedCityList: CityItem[] = []
    for (let i = 0; i < this.cityList.length; i++) {
      const city = this.cityList[i]
      const cityCoords = cityCoordinates[city.name]
      const distance = cityCoords
        ? this.calculateDistance(
            gpsCoords.lat, gpsCoords.lng,
            cityCoords.lat, cityCoords.lng
          )
        : 0

      const newCity: CityItem = {
        name: city.name,
        distance: distance,
        isFavorite: city.isFavorite,
        isTop: city.isTop,
        province: city.province || extractProvince(city.name),
        pinyin: city.pinyin || getCityPinyin(city.name),
        pinyinInitial: city.pinyinInitial || getPinyinInitial(city.name),
        pollenLevel: city.pollenLevel,
        pollenIndex: city.pollenIndex
      }
      updatedCityList.push(newCity)
    }
    this.cityList = updatedCityList

    console.info(`[RegionView] 已更新所有城市距离，GPS位置: ${this.actualLocationCity}`)
  }

  // 加载城市花粉数据（批量获取）
  async loadPollenDataForCities(): Promise<void> {
    const pollenService = PollenService.getInstance()

    // 批量获取花粉数据（限制并发数）
    const batchSize = 5
    for (let i = 0; i < this.cityList.length; i += batchSize) {
      const batch: CityItem[] = []
      const endIndex = Math.min(i + batchSize, this.cityList.length)
      for (let j = i; j < endIndex; j++) {
        batch.push(this.cityList[j])
      }

      const promises: Promise<void>[] = []
      for (let k = 0; k < batch.length; k++) {
        const city = batch[k]
        promises.push((async () => {
        try {
          const coords = cityCoordinates[city.name]
          if (!coords) return

          const response = await pollenService.getPollenForecast(coords.lat, coords.lng, 1)
          if (response && response.dailyInfo && response.dailyInfo.length > 0) {
            const todayInfo = response.dailyInfo[0]
            const maxLevel = getMaxPollenFromDaily(todayInfo)

            // 获取花粉指数值
            let pollenIndexValue = 0
            if (todayInfo.pollenTypeInfo) {
              for (let m = 0; m < todayInfo.pollenTypeInfo.length; m++) {
                if (todayInfo.pollenTypeInfo[m].indexInfo) {
                  pollenIndexValue = todayInfo.pollenTypeInfo[m].indexInfo?.value || 0
                  break
                }
              }
            }

            // 更新缓存
            const cacheData: PollenCacheData = {
              level: maxLevel,
              index: pollenIndexValue
            }
            this.pollenDataCache.set(city.name, cacheData)

            // 更新城市列表 - 创建新数组以触发UI更新
            const updatedCityList: CityItem[] = []
            for (let n = 0; n < this.cityList.length; n++) {
              const oldCity = this.cityList[n]
              if (oldCity.name === city.name) {
                // 更新当前城市的数据
                const updatedCity: CityItem = {
                  name: oldCity.name,
                  distance: oldCity.distance,
                  isFavorite: oldCity.isFavorite,
                  isTop: oldCity.isTop,
                  province: oldCity.province,
                  pinyin: oldCity.pinyin,
                  pinyinInitial: oldCity.pinyinInitial,
                  pollenLevel: maxLevel,
                  pollenIndex: pollenIndexValue
                }
                updatedCityList.push(updatedCity)
              } else {
                updatedCityList.push(oldCity)
              }
            }
            this.cityList = updatedCityList
          }
        } catch (error) {
          console.warn(`[RegionView] 获取 ${city.name} 花粉数据失败: ${JSON.stringify(error)}`)
        }
        })())
      }

      await Promise.all(promises)

      // 短暂延迟，避免请求过快
      await new Promise<void>(resolve => setTimeout(resolve, 100))
    }

    console.info(`[RegionView] 已完成 ${this.cityList.length} 个城市的花粉数据加载`)
  }

  // 切换城市/区县收藏状态
  toggleFavorite(displayName: string): void {
    if (!displayName || displayName.trim() === '') {
      return
    }

    // 1. 查找是否命中城市列表（支持名称包含关系，例如“海南省, 海口市”与“海口市”）
    let foundIndex = -1
    for (let j = 0; j < this.cityList.length; j++) {
      const name = this.cityList[j].name
      if (name === displayName || name.indexOf(displayName) >= 0 || displayName.indexOf(name) >= 0) {
        foundIndex = j
        break
      }
    }

    // 2. 当前收藏状态
    let currentlyFavorite = false
    if (foundIndex >= 0) {
      currentlyFavorite = this.cityList[foundIndex].isFavorite
    } else {
      currentlyFavorite = this.favoriteCities.includes(displayName)
    }
    const nextFavorite = !currentlyFavorite

    // 2.5 免费版收藏数量限制：新增且已达上限时提示并返回
    if (nextFavorite && !currentlyFavorite) {
      if (this.favoriteCities.length >= this.MAX_FREE_FAVORITES) {
        this.getUIContext().getPromptAction().showToast({
          message: `抱歉，当前最多仅支持收藏 ${this.MAX_FREE_FAVORITES} 项`,
          duration: 2000
        })
        return
      }
    }

    // 3. 更新城市列表（如果命中城市）
    if (foundIndex >= 0) {
      // 创建新数组以触发 UI 刷新
      const newList: CityItem[] = []
      for (let i = 0; i < this.cityList.length; i++) {
        newList.push(this.cityList[i])
      }
      const city = newList[foundIndex]
      const updatedCity: CityItem = {
        name: city.name,
        distance: city.distance,
        isFavorite: nextFavorite,
        isTop: nextFavorite ? city.isTop : false, // 取消收藏时同时取消置顶
        province: city.province,
        pinyin: city.pinyin,
        pinyinInitial: city.pinyinInitial,
        pollenLevel: city.pollenLevel,
        pollenIndex: city.pollenIndex
      }
      newList[foundIndex] = updatedCity
      this.cityList = newList
    }

    // 4. 更新收藏名称列表（用于“我的收藏”Tab 和持久化）
    const indexInFavorites = this.favoriteCities.indexOf(displayName)
    const newFavorites: string[] = []
    for (let i = 0; i < this.favoriteCities.length; i++) {
      newFavorites.push(this.favoriteCities[i])
    }

    if (nextFavorite) {
      if (indexInFavorites < 0) {
        newFavorites.push(displayName)
      }
    } else {
      if (indexInFavorites >= 0) {
        newFavorites.splice(indexInFavorites, 1)
      }
    }
    this.favoriteCities = newFavorites

    // 持久化到全局存储，便于下次启动恢复
    AppStorage.setOrCreate<string[]>('favoriteCities', newFavorites)

    // 轻微震动反馈
    if (this.vibrationEnabled) {
      try {
        vibrator.startVibration({
          type: 'time',
          duration: 30
        }, {
          id: 0,
          usage: 'touch'
        })
      } catch (err) {
        console.warn('[RegionView] 收藏震动反馈失败')
      }
    }

    // 视觉提示：收藏/取消收藏提示语
    this.getUIContext().getPromptAction().showToast({
      message: nextFavorite ? `已加入收藏：${displayName}` : `已取消收藏：${displayName}`,
      duration: 1200
    })
  }

  // 置顶城市
  moveToTop(cityName: string): void {
    // 查找索引
    let foundIndex = -1
    for (let j = 0; j < this.cityList.length; j++) {
      if (this.cityList[j].name === cityName) {
        foundIndex = j
        break
      }
    }
    if (foundIndex >= 0) {
      // 创建新数组以触发 UI 刷新
      const newList: CityItem[] = []
      for (let i = 0; i < this.cityList.length; i++) {
        newList.push(this.cityList[i])
      }
      const city = newList[foundIndex]
      const updatedCity: CityItem = {
        name: city.name,
        distance: city.distance,
        isFavorite: true, // 置顶的同时自动收藏
        isTop: true,
        province: city.province,
        pinyin: city.pinyin,
        pinyinInitial: city.pinyinInitial,
        pollenLevel: city.pollenLevel,
        pollenIndex: city.pollenIndex
      }
      newList[foundIndex] = updatedCity
      this.cityList = newList
    }
  }

  // 获取排序后的城市列表（使用工具类排序）
  getSortedCities(): CityItem[] {
    return sortCities(this.cityList)
  }

  // 重新定位到当前位置（优化：缓存快速响应 + 后台静默更新）
  async refreshCurrentLocation(): Promise<void> {
    if (this.isRefreshingLocation) return

    console.info('[RegionView] 快速刷新...')
    this.isRefreshingLocation = true

    try {
      // 1. 快速响应：使用缓存位置立即更新距离
      if (this.cachedLocation && this.cachedLocation.city) {
        console.info('[RegionView] 使用缓存位置快速响应')
        this.updateAllDistances()  // 基于缓存计算距离
      }

      // 2. 立即结束刷新动画（用户体感快）
      this.isRefreshingLocation = false

      // 3. 后台静默更新GPS位置（不阻塞用户操作）
      this.silentRefreshGPS()
    } catch (error) {
      console.error(`[RegionView] 刷新异常: ${JSON.stringify(error)}`)
      this.isRefreshingLocation = false
    }
  }

  // 静默刷新GPS位置（后台运行，不阻塞界UI）
  private silentRefreshGPS(): void {
    const timeoutId = setTimeout(() => {
      console.warn('[RegionView] 后台GPS定位超时')
    }, 5000)

    this.locationService.checkAndRequestPermission()
      .then((hasPermission: boolean) => {
        if (!hasPermission) {
          console.warn('[RegionView] 无位置权限')
          clearTimeout(timeoutId)
          return Promise.reject('无权限')
        }
        return this.locationService.getCurrentLocation()
      })
      .then((location: LocationInfo | null) => {
        clearTimeout(timeoutId)

        if (location !== null && location.city) {
          // 更新缓存
          this.cachedLocation = location

          // 保存GPS定位的真实城市名
          this.actualLocationCity = location.city

          // 更新GPS城市坐标
          cityCoordinates[location.city] = {
            lat: location.latitude,
            lng: location.longitude
          }

          // 静默更新距离
          this.updateAllDistances()

          console.info(`[RegionView] 后台GPS刷新成功: ${location.city}`)
        } else {
          console.warn('[RegionView] 后台GPS定位失败')
        }
      })
      .catch((error: Error) => {
        clearTimeout(timeoutId)
        console.error(`[RegionView] 后台GPS异常: ${JSON.stringify(error)}`)
      })
  }

  // 滑动操作按钮构建器
  @Builder
  SwipeActionBuilder(city: CityItem) {
    Row() {
      // 收藏/取消收藏按钮
      Button(city.isFavorite ? '取消收藏' : '收藏')
        .fontSize(14)
        .fontColor(Color.White)
        .backgroundColor(city.isFavorite ? '#666666' : '#FF6B35')
        .height('100%')
        .width(80)
        .onClick(() => {
          this.toggleFavorite(city.name)
        })

      // 置顶按钮（仅对已收藏的显示）
      if (city.isFavorite && !city.isTop) {
        Button('置顶')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor('#4CAF50')
          .height('100%')
          .width(60)
          .onClick(() => {
            this.moveToTop(city.name)
          })
      }
    }
    .height('100%')
  }

  // 生命周期：组件即将出现
  async aboutToAppear(): Promise<void> {
    // 加载拼音映射表（支持智能搜索）
    console.info('[RegionView] 加载拼音映射表...')
    await loadPinyinMap(getContext(this))
    console.info('[RegionView] 拼音映射表加载完成')
    
    // 【测试代码】加载区县数据
    console.info('[RegionView-Test] 开始加载区县数据...')
    try {
      const startTime = Date.now()
      // 传入context参数
      const allCitiesWithDistricts = await loadChinaAreaData(getContext(this))
      const loadTime = Date.now() - startTime
      
      // ✅ 保存到状态变量
      this.allCitiesData = allCitiesWithDistricts
      
      console.info(`[RegionView-Test] ✅ 加载成功！`)
      console.info(`[RegionView-Test] 总城市数：${allCitiesWithDistricts.length}`)
      console.info(`[RegionView-Test] 加载耗时：${loadTime}ms`)
      
      // 测试查找广州市
      const guangzhou = getCityWithDistricts(allCitiesWithDistricts, '广州市')
      if (guangzhou) {
        console.info(`[RegionView-Test] 广州市数据：`)
        console.info(`  - 名称: ${guangzhou.name}`)
        console.info(`  - 省份: ${guangzhou.province}`)
        console.info(`  - adcode: ${guangzhou.adcode}`)
        console.info(`  - 坐标: (${guangzhou.location?.lat}, ${guangzhou.location?.lng})`)
        console.info(`  - 有区县: ${guangzhou.hasDistricts}`)
        console.info(`  - 区县数量: ${guangzhou.districts?.length || 0}`)
        
        if (guangzhou.districts && guangzhou.districts.length > 0) {
          console.info(`  - 前3个区县：`)
          for (let i = 0; i < Math.min(3, guangzhou.districts.length); i++) {
            const district = guangzhou.districts[i]
            console.info(`    ${i+1}. ${district.name} - adcode: ${district.adcode}, 坐标: (${district.location.lat}, ${district.location.lng})`)
          }
        }
      } else {
        console.warn('[RegionView-Test] ⚠️ 未找到广州市数据')
      }
      
    } catch (error) {
      console.error(`[RegionView-Test] ❌ 加载失败: ${JSON.stringify(error)}`)
    }
    console.info('[RegionView-Test] 测试完毕\n')
    // 【测试代码结束】

    // 1. 从 AppStorage 读取当前城市 (由于使用了 @StorageLink，这里主要是为了日志)
    console.info(`[RegionView] 当前城市: ${this.currentCity}, adcode: ${this.currentAdcode}`)

    // 1.5 从 AppStorage 读取收藏列表
    const storedFavorites = AppStorage.Get<string[]>('favoriteCities')
    if (storedFavorites && Array.isArray(storedFavorites)) {
      this.favoriteCities = storedFavorites
    }

    // 2. 初始化城市数据（补充拼音和省份信息）
    const updatedCityList: CityItem[] = []
    for (let i = 0; i < this.cityList.length; i++) {
      const city = this.cityList[i]
      const isFav = this.favoriteCities.includes(city.name)
      const updatedCity: CityItem = {
        name: city.name,
        distance: city.distance,
        isFavorite: isFav,
        isTop: isFav ? city.isTop : false,
        province: city.province || extractProvince(city.name),
        pinyin: city.pinyin || getCityPinyin(city.name),
        pinyinInitial: city.pinyinInitial || getPinyinInitial(city.name),
        pollenLevel: city.pollenLevel,
        pollenIndex: city.pollenIndex
      }
      updatedCityList.push(updatedCity)
    }
    this.cityList = updatedCityList

    // 3. 默认所有省份分组为折叠状态（点击省份名才展开）
    // 不需要自动展开，用户手动点击 toggleGroup() 展开

    // 4. 无论是否有存储城市，都尝试获取 GPS 位置（显示"当前位置"按钮）
    try {
      const hasPermission = await this.locationService.checkAndRequestPermission()
      if (hasPermission) {
        const location: LocationInfo | null = await this.locationService.getCurrentLocation()
        if (location !== null && location.city) {
          // 保存GPS定位的真实城市名
          this.actualLocationCity = location.city
          // 缓存GPS位置，供后续快速刷新使用
          this.cachedLocation = location
          // 将 GPS 位置添加到坐标表
          cityCoordinates[location.city] = {
            lat: location.latitude,
            lng: location.longitude
          }
          console.info(`[RegionView] GPS定位成功: ${location.city} (${location.latitude}, ${location.longitude})`)

          // GPS定位成功后，立即计算距离
          this.updateAllDistances()
        }
      }
    } catch (error) {
      console.warn(`[RegionView] GPS定位失败: ${JSON.stringify(error)}`)
    }

    // 5. 后台加载花粉数据（不阻塞UI）
    this.loadPollenDataForCities().catch((err: Error) => {
      console.warn(`[RegionView] 花粉数据加载失败: ${JSON.stringify(err)}`)
    })

    // 6. 启动定时更新花粉数据
    this.startPollenDataUpdate()

    // 7. 延迟触发动画，确保布局完成
    setTimeout(() => {
      this.isAnimating = true
    }, 50)
  }

  // ====== 区县选择弹窗 ======
  @Builder
  DistrictDialog() {
    Column() {
      // 顶部安全距离
      Blank().height(this.safeTop)

      // 区县列表（包含市级选项）
      // 统一显示，无论有无区县
      if (!this.selectedCityForDistrict) {
        // 没有选中城市数据（异常情况）
        Column() {
          Text('数据加载失败')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 20, bottom: 20 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 区县列表（包含市级选项）
        List({ space: 0 }) {
          // 首项：整个市级选项（支持手势）
          ListItem() {
            Stack({ alignContent: Alignment.End }) {
              // 背景层：操作按钮
              Row() {
                Button({ type: ButtonType.Normal }) {
                  Text(this.favoriteCities.includes(this.selectedCityForDistrict.name) ? '取消收藏' : '收藏')
                    .fontSize(14)
                    .fontColor(Color.White)
                }
                .width(80)
                .height('100%')
                .backgroundColor(this.favoriteCities.includes(this.selectedCityForDistrict.name) ? '#666666' : '#FF6B35')
                .onClick(() => {
                  const cityName = this.selectedCityForDistrict?.name || ''
                  this.toggleFavorite(cityName)
                  animateTo({ duration: 200 }, () => {
                    this.swipeOffsets.set(cityName, 0)
                  })
                })
              }
              .height('100%')
              
              // 主内容层
              Row() {
                // 市级图标
                Image($r('app.media.icon_location'))
                  .width(18)
                  .height(18)
                  .fillColor(this.pollenThemeTextColor as ResourceColor)
                  .margin({ right: 12 })
                
                // 市级名称
                Column() {
                  Row() {
                    if (this.favoriteCities.includes(this.selectedCityForDistrict.name)) {
                      Text('★ ')
                        .fontSize(14)
                        .fontColor(this.pollenThemeTextColor as ResourceColor)
                    }
                    Text(`整个${this.selectedCityForDistrict.name}`)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('app.color.text_primary'))
                  }
                  
                  Text('查看市级整体数据')
                    .fontSize(12)
                    .fontColor($r('app.color.text_secondary'))
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)

                Blank()

                // 箭头图标
                Image($r('app.media.icon_chevron_right'))
                  .width(16)
                  .height(16)
                  .fillColor(this.pollenThemeTextColor as ResourceColor)
              }
              .width('100%')
              .padding({ left: 20, right: 20, top: 16, bottom: 16 })
              .backgroundColor($r('app.color.card_background'))
              .borderRadius(8)
              .translate({ x: this.swipeOffsets.get(this.selectedCityForDistrict.name) ?? 0 })
              .gesture(
                // 【优化3】手势方向限制（Horizontal，避免与弹窗纵向拖拽冲突）
                PanGesture({ direction: PanDirection.Horizontal })
                  .onActionStart((event: GestureEvent) => {
                    this.swipeStartTime = Date.now()
                    this.isSwipeGesture = false

                    const cityName = this.selectedCityForDistrict?.name || ''
                    if (this.currentSwipeKey && this.currentSwipeKey !== cityName) {
                      // 收起之前展开的行
                      animateTo({ duration: 200, curve: Curve.Sharp }, () => {
                        this.swipeOffsets.set(this.currentSwipeKey, 0)
                      })
                    }
                    this.currentSwipeKey = cityName
                  })
                  .onActionUpdate((event: GestureEvent) => {
                    if (Math.abs(event.offsetX) > 10) {
                      this.isSwipeGesture = true
                    }
                    const cityName = this.selectedCityForDistrict?.name || ''
                    const currentOffset = this.swipeOffsets.get(cityName) ?? 0
                    const maxSwipe = -80
                    const newOffset = Math.max(maxSwipe, Math.min(0, currentOffset + event.offsetX))
                    const now = Date.now()
                    this.pendingOffset.set(cityName, newOffset)
                    if (now - this.lastUpdateTime >= 16) {
                      this.lastUpdateTime = now
                      this.swipeOffsets.set(cityName, newOffset)
                    }
                  })
                  .onActionEnd((event: GestureEvent) => {
                    const cityName = this.selectedCityForDistrict?.name || ''
                    const finalOffset = this.pendingOffset.get(cityName) ?? this.swipeOffsets.get(cityName) ?? 0
                    if (this.pendingOffset.has(cityName)) {
                      this.swipeOffsets.set(cityName, finalOffset)
                      this.pendingOffset.delete(cityName)
                    }
                    const velocity = event.velocityX
                    const threshold = -40
                    if (velocity < -800 || finalOffset < threshold) {
                      animateTo({ duration: 200, curve: Curve.Sharp }, () => {
                        this.swipeOffsets.set(cityName, -80)
                      })
                    } else {
                      animateTo({ duration: 200, curve: Curve.Sharp }, () => {
                        this.swipeOffsets.set(cityName, 0)
                      })
                    }
                  })
              )
              .onClick(() => {
                if (this.isSwipeGesture) {
                  this.isSwipeGesture = false
                  return
                }
                const cityName = this.selectedCityForDistrict?.name || ''
                const currentOffset = this.swipeOffsets.get(cityName) ?? 0
                if (currentOffset < -10) {
                  animateTo({ duration: 200 }, () => {
                    this.swipeOffsets.set(cityName, 0)
                  })
                } else {
                  this.selectCityOrDistrict(cityName, null)
                }
              })
            }
            .width('100%')
            .height(56)
            .margin({ left: 12, right: 12, top: 8, bottom: 4 })
          }
          .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
          
          // 分割线和区县列表（只在有区县时显示）
          if (this.selectedCityForDistrict.districts && this.selectedCityForDistrict.districts.length > 0) {
            // 分割线
            ListItem() {
              Row() {
                Text('或选择具体区县')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .padding({ left: 20, top: 12, bottom: 8 })
            }
            
            // 区县列表（支持手势）
            ForEach(this.selectedCityForDistrict.districts, (district: DistrictItem, index: number) => {
            ListItem() {
              Stack({ alignContent: Alignment.End }) {
                // 背景层：操作按钮
                Row() {
                  Button({ type: ButtonType.Normal }) {
                    Text(this.favoriteCities.includes(`${this.selectedCityForDistrict?.name || ''} - ${district.name}`) ? '取消收藏' : '收藏')
                      .fontSize(14)
                      .fontColor(Color.White)
                  }
                  .width(80)
                  .height('100%')
                  .backgroundColor(this.favoriteCities.includes(`${this.selectedCityForDistrict?.name || ''} - ${district.name}`) ? '#666666' : '#FF6B35')
                  .onClick(() => {
                    const cityName = this.selectedCityForDistrict?.name || ''
                    const districtFullName = `${cityName} - ${district.name}`
                    this.toggleFavorite(districtFullName)
                    animateTo({ duration: 200 }, () => {
                      this.swipeOffsets.set(district.name, 0)
                    })
                  })
                }
                .height('100%')
                
                // 主内容层
                Row() {
                  // 区县名称
                  Column() {
                    Row() {
                      if (this.favoriteCities.includes(`${this.selectedCityForDistrict?.name || ''} - ${district.name}`)) {
                        Text('★')
                          .fontSize(14)
                          .fontColor(this.pollenThemeTextColor as ResourceColor)
                          .margin({ right: 4 })
                      }
                      Text(district.name)
                        .fontSize(16)
                        .fontColor($r('app.color.text_primary'))
                    }
                  }
                  .alignItems(HorizontalAlign.Start)

                  Blank()

                  // 箭头图标
                  Image($r('app.media.icon_chevron_right'))
                    .width(16)
                    .height(16)
                    .fillColor(this.pollenThemeColor)
                }
                .width('100%')
                .padding({ left: 20, right: 20, top: 16, bottom: 16 })
                .backgroundColor($r('app.color.page_background'))
                .translate({ x: this.swipeOffsets.get(district.name) ?? 0 })
                .gesture(
                  // 【优化3】手势方向限制（Horizontal，避免与弹窗纵向拖拽冲突）
                  PanGesture({ direction: PanDirection.Horizontal })
                    .onActionStart((event: GestureEvent) => {
                      this.swipeStartTime = Date.now()
                      this.isSwipeGesture = false

                      const key = district.name
                      if (this.currentSwipeKey && this.currentSwipeKey !== key) {
                        animateTo({ duration: 200, curve: Curve.Sharp }, () => {
                          this.swipeOffsets.set(this.currentSwipeKey, 0)
                        })
                      }
                      this.currentSwipeKey = key
                    })
                    .onActionUpdate((event: GestureEvent) => {
                      if (Math.abs(event.offsetX) > 10) {
                        this.isSwipeGesture = true
                      }
                      const currentOffset = this.swipeOffsets.get(district.name) ?? 0
                      const maxSwipe = -80
                      const newOffset = Math.max(maxSwipe, Math.min(0, currentOffset + event.offsetX))
                      const now = Date.now()
                      this.pendingOffset.set(district.name, newOffset)
                      if (now - this.lastUpdateTime >= 16) {
                        this.lastUpdateTime = now
                        this.swipeOffsets.set(district.name, newOffset)
                      }
                    })
                    .onActionEnd((event: GestureEvent) => {
                      const finalOffset = this.pendingOffset.get(district.name) ?? this.swipeOffsets.get(district.name) ?? 0
                      if (this.pendingOffset.has(district.name)) {
                        this.swipeOffsets.set(district.name, finalOffset)
                        this.pendingOffset.delete(district.name)
                      }
                      const velocity = event.velocityX
                      const threshold = -40
                      if (velocity < -800 || finalOffset < threshold) {
                        animateTo({ duration: 200, curve: Curve.Sharp }, () => {
                          this.swipeOffsets.set(district.name, -80)
                        })
                      } else {
                        animateTo({ duration: 200, curve: Curve.Sharp }, () => {
                          this.swipeOffsets.set(district.name, 0)
                        })
                      }
                    })
                )
                .onClick(() => {
                  if (this.isSwipeGesture) {
                    this.isSwipeGesture = false
                    return
                  }
                  const currentOffset = this.swipeOffsets.get(district.name) ?? 0
                  if (currentOffset < -10) {
                    animateTo({ duration: 200 }, () => {
                      this.swipeOffsets.set(district.name, 0)
                    })
                  } else {
                    const cityName = this.selectedCityForDistrict?.name || ''
                    this.selectCityOrDistrict(cityName, district.name)
                  }
                })
              }
              .width('100%')
              .height(56)
            }
            .transition(TransitionEffect.OPACITY.animation({ duration: 200, delay: (index + 1) * 30 }))
          }, (district: DistrictItem) => district.name)
          }  // 结束 if (this.selectedCityForDistrict.districts && ...)
        }
        .width('100%')
        .divider({
          strokeWidth: 0.5,
          color: '#E0E0E0',
          startMargin: 20,
          endMargin: 20
        })
      }
    }
    .width('100%')
    .padding({ top: 8 })
  }

  @Builder
  CityItemComponent(city: CityItem) {
    // 统一为目录样式，所有城市点击后都弹出三级菜单
    Row() {
      // 目录图标
      Image($r('app.media.icon_chevron_right'))
        .width(12)
        .height(12)
        .fillColor(this.pollenThemeTextColor as ResourceColor)

      // 城市名称 + 收藏状态
      Column() {
        Row() {
          if (city.isFavorite) {
            Text('★')
              .fontSize(14)
              .fontColor(this.pollenThemeTextColor as ResourceColor)
              .margin({ right: 4 })
          }
          Text(city.name)
            .fontSize(15)
            .fontColor($r('app.color.text_primary'))
        }
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      Blank()

      // 花粉等级指示
      Column() {
        // 仅用颜色小圆点表示花粉状态，具体数值以首页为准
        if (city.pollenLevel !== undefined && city.pollenLevel >= 0) {
          Circle()
            .width(8)
            .height(8)
            .fill(this.getPollenColor(city.pollenLevel))
            .margin({ top: 4 })
        }
      }
      .alignItems(HorizontalAlign.End)
      
      // 右箭头提示
      Image($r('app.media.icon_chevron_right'))
        .width(16)
        .height(16)
        .fillColor($r('app.color.text_secondary'))
        .margin({ left: 8 })
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.page_background'))
    .onClick(() => {
      // 统一打开三级菜单（城市选择弹窗）
      console.info(`[RegionView] 点击城市: ${city.name}，打开选择弹窗`)
      // 提取纯城市名：去除省份前缀（例如："安徽省, 合肥市" → "合肥市"）
      const pureCityName = city.name.includes(',') ? city.name.split(',')[1].trim() : city.name
      console.info(`[RegionView] 提取纯城市名: ${pureCityName}`)
      this.selectCity(pureCityName)
    })
    // 入场动画
    .scale({
      x: this.shouldAnimate(0) ? (this.isAnimating ? 1 : 0.95) : 1,
      y: this.shouldAnimate(0) ? (this.isAnimating ? 1 : 0.95) : 1
    })
    .animation({
      duration: 240,
      delay: this.firstLoad ? 0 : 0,
      curve: Curve.EaseOut,
      iterations: 1,
      playMode: PlayMode.Normal
    })
  }

  build() {
    Column() {
      // 顶部安全距离
      Blank().height(this.safeTop)

      // 标题栏
      Row() {
        Text('区域')
          .fontSize(28)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 16 })

      // 搜索框
      Row() {
        Image($r('app.media.icon_search'))
          .width(16)
          .height(16)
          .fillColor($r('app.color.text_secondary'))
          .margin({ right: 8 })

        TextInput({ placeholder: '搜索你感兴趣的城市', text: this.searchText })
          .placeholderColor($r('app.color.text_secondary'))
          .fontColor($r('app.color.text_primary'))
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .onChange((value: string) => {
            this.searchText = value
          })
      }
      .width('100%')
      .height(44)
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(10)
      .padding({ left: 12, right: 12 })
      .margin({ left: 16, right: 16, bottom: 20 })

      // 当前位置区域（仅当GPS定位成功时显示）
      if (this.actualLocationCity) {
        Column() {
          Text('当前位置')
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')
            .padding({ left: 16, bottom: 8 })

          Row() {
            Image($r('app.media.icon_location'))
              .width(16)
              .height(16)
              .fillColor($r('app.color.icon_primary'))

            Text(this.actualLocationCity)
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .margin({ left: 8 })

            Blank()
          }
          .width('100%')
          .height(50)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(10)
          .padding({ left: 16, right: 16 })
          .margin({ left: 16, right: 16 })
          .onClick(() => {
            // actualLocationCity 已经是纯城市名，直接使用
            this.selectCity(this.actualLocationCity)
          })
        }
        .margin({ bottom: 20 })
      }

      // 热门城市 / 我的收藏
      Column() {
        // 顶部标签栏
        Row() {
          Text('热门城市')
            .fontSize(13)
            .fontColor(this.hotTabIndex === 0 ? $r('app.color.text_primary') : $r('app.color.text_secondary'))
            .fontWeight(this.hotTabIndex === 0 ? FontWeight.Medium : FontWeight.Normal)
            .onClick(() => {
              this.hotTabIndex = 0
            })

          Text('我的收藏')
            .fontSize(13)
            .fontColor(this.hotTabIndex === 1 ? $r('app.color.text_primary') : $r('app.color.text_secondary'))
            .fontWeight(this.hotTabIndex === 1 ? FontWeight.Medium : FontWeight.Normal)
            .margin({ left: 24 })
            .onClick(() => {
              this.hotTabIndex = 1
            })

          Blank()
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 8 })

        // 内容区域：左右滑动切换
        Swiper() {
          // Tab 0: 热门城市
          // 热门城市网格布局 - 使用 Flex 实现换行
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.hotCities, (city: string, index: number) => {
              Text(city)
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
                .backgroundColor($r('app.color.card_background'))
                .borderRadius(16)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .margin({ right: 12, bottom: 12 })
                .onClick(() => {
                  // 热门城市列表中已经是纯城市名，直接使用
                  this.selectCity(city)
                })
                // 入场动画（性能优化）
                .opacity(this.isAnimating ? 1 : 0)
                .translate({ y: this.isAnimating ? 0 : 30 })
                .animation({
                  duration: 280,
                  delay: this.firstLoad ? (index * 30) : 0,
                  curve: Curve.EaseOut
                })
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })

          // Tab 1: 我的收藏
          Flex({ wrap: FlexWrap.Wrap }) {
            if (!this.favoriteCities || this.favoriteCities.length === 0) {
              Text('还没有收藏城市，试试在列表中向左滑动添加收藏~')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .margin({ left: 16, right: 16, top: 8, bottom: 8 })
            } else {
              ForEach(this.favoriteCities, (favName: string, index: number) => {
                Row() {
                  Text('★')
                    .fontSize(14)
                    .fontColor(this.pollenThemeColor as ResourceColor)
                    .margin({ right: 4 })
                  Text(favName)
                    .fontSize(14)
                    .fontColor($r('app.color.text_primary'))
                }
                .backgroundColor($r('app.color.card_background'))
                .borderRadius(16)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .margin({ right: 12, bottom: 12 })
                .onClick(() => {
                  // 点击收藏项时，默认以城市部分进行选择
                  const parts = favName.split(' - ')
                  const cityPart = parts[0]
                  this.selectCity(cityPart)
                })
              })
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }
        .index(this.hotTabIndex)
        .onChange((index: number) => {
          this.hotTabIndex = index
        })
        .width('100%')
        .height(128)
      }
      .margin({ bottom: 20 })

      // 全部地区（下拉刷新）
      Refresh({ refreshing: $$this.isRefreshingLocation }) {
        Column() {
            // 显示模式切换按钮
            Row() {
              Button(this.displayMode === 'province' ? '省份' : (this.displayMode === 'alphabet' ? '字母' : '列表'))
                .fontSize(12)
                .type(ButtonType.Capsule)
                .width(60)
                .height(28)
                .onClick(() => {
                  if (this.displayMode === 'province') {
                    this.displayMode = 'alphabet'
                  } else if (this.displayMode === 'alphabet') {
                    this.displayMode = 'none'
                  } else {
                    this.displayMode = 'province'
                  }
                })

              Blank()
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 8 })

            // 城市列表（分组显示）
            List({ scroller: this.scroller }) {
              ForEach(this.getGroupedCities(), (group: CityGroup) => {
                // 分组标题
                if (this.displayMode === 'province') {
                  ListItem() {
                    Row() {
                      Text(group.title)
                        .fontSize(14)
                        .fontColor($r('app.color.text_primary'))
                        .fontWeight(FontWeight.Medium)

                      Blank()

                      Text(group.isExpanded ? '▼' : '▶')
                        .fontSize(10)
                        .fontColor($r('app.color.text_secondary'))
                    }
                    .width('100%')
                    .height(40)
                    .padding({ left: 16, right: 16 })
                    .backgroundColor($r('app.color.card_background'))
                  }
                  .onClick(() => {
                    console.info(`[RegionView] 点击了省份标题: ${group.title}, groupKey: ${group.key}`)
                    this.toggleGroup(group.key)
                  })
                } else if (this.displayMode === 'alphabet') {
                  ListItem() {
                    Row() {
                      Text(group.title)
                        .fontSize(14)
                        .fontColor($r('app.color.text_primary'))
                        .fontWeight(FontWeight.Medium)

                      Blank()
                    }
                    .width('100%')
                    .height(40)
                    .padding({ left: 16, right: 16 })
                    .backgroundColor($r('app.color.card_background'))
                  }
                }

                // 城市列表（仅在展开时显示）
                if (this.displayMode !== 'province' || group.isExpanded) {
                  ForEach(group.cities, (city: CityItem) => {
                    ListItem() {
                      this.CityItemComponent(city)
                    }
                  }, (city: CityItem) => city.name)
                }
              }, (group: CityGroup) => group.key + '_' + (this.expandedGroups.includes(group.key) ? '1' : '0'))
            }
            .width('100%')
            .layoutWeight(1)
            .onDidScroll(() => {
              // 滚动时禁用动画（性能优化）
              if (this.firstLoad) {
                this.firstLoad = false
              }
            })
            .divider({
              strokeWidth: 0.5,
              color: $r('app.color.divider_color'),
              startMargin: 40,
              endMargin: 16
            })
        }
        .width('100%')
        .layoutWeight(1)
      }
      .layoutWeight(1)
      .clip(true)  // 裁剪内容，防止穿透到状态栏

      // ========== 广告位预留（已隐藏）==========
      // TODO: 后续可在此位置添加广告组件
      // 建议类型: Banner广告、推广卡片、健康小贴士
      // 参考高度: 60-80px
      // Blank().height(56)  // TabBar 占位
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.KEYBOARD], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
      if (isVisible && currentRatio >= 1.0) {
        // 页面完全可见时触发动画
        setTimeout(() => {
          animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
            this.isAnimating = true
          })
        }, 50)
      } else if (!isVisible || currentRatio < 0.5) {
        // 页面不可见或可见比侎于50%时重置
        this.isAnimating = false
        // 强制停止GPS刷新动画（避免后台资源占用）
        if (this.isRefreshingLocation) {
          this.isRefreshingLocation = false
        }
        // 页面不可见时停止花粉数据定时更新
        this.stopPollenDataUpdate();
      }
    })
    // ====== 区县选择弹窗 ======
    .bindSheet($$this.showDistrictDialog, this.DistrictDialog(), {
      // 【优化2】弹窗高度自适应（有区县70%，无区县30%）
      height: (this.selectedCityForDistrict?.districts?.length || 0) > 0 ? '70%' : '30%',
      showClose: true,
      title: {
        title: `请选择${this.selectedCityForDistrict?.name || ''}的区县`,
        subtitle: `共 ${this.selectedCityForDistrict?.districts?.length || 0} 个区县`
      },
      // 【优化4】弹窗动画优化（200ms秒开）
      enableOutsideInteractive: false,
      backgroundColor: $r('app.color.card_background'),  // 🌗 支持深色模式
      onDisappear: () => {
        this.showDistrictDialog = false
        this.selectedCityForDistrict = null
      }
    })
  }

  // 选择城市处理函数（支持区县选择）
  selectCity(cityName: string): void {
    console.info(`[RegionView] 选择城市: ${cityName}`)
    
    // 【关键修复】如果是 Google 数据源，直接选中城市，不弹出区县菜单
    if (this.dataSourceType === PollenDataSourceType.GOOGLE) {
      console.info(`[RegionView] Google 模式：跳过区县选择，直接选中城市 ${cityName}`)
      this.selectCityOrDistrict(cityName, null)
      return
    }

    console.info(`[RegionView] allCitiesData 长度: ${this.allCitiesData.length}`)
    
    // 🔍 调试：打印前10个城市名，检查格式
    if (this.allCitiesData.length > 0) {
      const names = this.allCitiesData.slice(0, 10).map(c => c.name).join(', ')
      console.info(`[RegionView] 数据中的城市名（前10个）: ${names}`)
      
      // 检查是否存在完全匹配
      const exactMatch = this.allCitiesData.find(city => city.name === cityName)
      console.info(`[RegionView] 完全匹配 "${cityName}": ${exactMatch ? '找到' : '未找到'}`)
    } else {
      console.error(`[RegionView] ❌ allCitiesData 为空！数据未加载`)
    }

    // 统一三级菜单方案：所有城市都弹出三级菜单
    const cityData = getCityWithDistricts(this.allCitiesData, cityName)
    console.info(`[RegionView] getCityWithDistricts 返回: ${cityData ? '有数据' : '无数据'}`)
    
    if (cityData) {
      // 有数据就弹窗（无论是否有区县）
      const districtCount = cityData.districts?.length || 0
      console.info(`[RegionView] 城市 ${cityName} 数据加载成功，区县数量: ${districtCount}，弹出三级菜单`)
      this.selectedCityForDistrict = cityData
      this.showDistrictDialog = true

      // 【优化1】无区县城市自动选中（200ms延迟+震动反馈）
      if (!cityData.districts || cityData.districts.length === 0) {
        console.info(`[RegionView] 无区县城市，200ms后自动选中`)
        setTimeout(() => {
          this.selectCityOrDistrict(cityData.name, null)
          this.showDistrictDialog = false
          // 震动反馈
          if (this.vibrationEnabled) {
            try {
              vibrator.startVibration({
                type: 'time',
                duration: 30
              }, {
                id: 0,
                usage: 'touch'
              })
            } catch (err) {
              console.warn('[RegionView] 震动反馈失败')
            }
          }
        }, 200)
      }
    } else {
      // ❌ 数据缺失：不应该直接定位，应该提示错误
      console.error(`[RegionView] 城市 ${cityName} 数据缺失，无法弹出三级菜单`)
      
      // 弹出错误提示
      this.getUIContext().getPromptAction().showToast({
        message: `${cityName} 数据暂未加载，请稍后重试`,
        duration: 2000
      })
      
      // 不执行任何定位操作！二级菜单的唯一功能就是：点击展开三级菜单
      // 如果数据缺失，就无法展开，不应该有其他行为
    }
  }

  // 选择城市或区县（统一处理）
  selectCityOrDistrict(cityName: string, districtName: string | null): void {
    const displayName = districtName ? `${cityName} - ${districtName}` : cityName
    console.info(`[RegionView] 最终选择: ${displayName}`)

    // 1. 震动反馈（30ms 短震）
    if (this.vibrationEnabled) {
      try {
        vibrator.startVibration({
          type: 'time',
          duration: 30
        }, {
          id: 0,
          usage: 'touch'
        })
      } catch (err) {
        console.warn('[RegionView] 震动反馈失败')
      }
    }

    // 2. Toast 提示
    this.getUIContext().getPromptAction().showToast({
      message: `已选择 ${displayName}`,
      duration: 1500
    })

    // 3. 获取坐标和 adcode
    let coords: CityCoordinate | undefined = undefined
    let currentAdcode: string | undefined = undefined
    
    if (districtName) {
      // 从区县数据中获取坐标
      const cityData = getCityWithDistricts(this.allCitiesData, cityName)
      if (cityData && cityData.districts) {
        const district = cityData.districts.find(d => d.name === districtName)
        if (district) {
          if (district.location) {
            coords = { lat: district.location.lat, lng: district.location.lng }
            console.info(`[RegionView] 区县坐标: ${coords.lat}, ${coords.lng}`)
          }
          currentAdcode = district.adcode
          console.info(`[RegionView] 区县 adcode: ${currentAdcode}`)
        }
      }
    } else {
      // 从城市坐标映射表获取
      coords = cityCoordinates[cityName]
      // 如果映射表没有，尝试从完整数据获取
      const cityData = getCityWithDistricts(this.allCitiesData, cityName)
      if (cityData) {
        if (!coords && cityData.location) {
          coords = { lat: cityData.location.lat, lng: cityData.location.lng }
          console.info(`[RegionView] 从完整数据获取城市坐标: ${coords.lat}, ${coords.lng}`)
        }
        currentAdcode = cityData.adcode
        console.info(`[RegionView] 城市 adcode: ${currentAdcode}`)
      }
    }

    // 4. 更新全局存储
    this.currentCity = displayName
    
    if (currentAdcode) {
      this.currentAdcode = currentAdcode
      console.info(`[RegionView] 已更新持久化 adcode: ${currentAdcode}`)
    } else {
      this.currentAdcode = ''
    }

    if (coords) {
      AppStorage.setOrCreate<number>('latitude', coords.lat)
      AppStorage.setOrCreate<number>('longitude', coords.lng)
      console.info(`[RegionView] 最终坐标: ${coords.lat}, ${coords.lng}`)
    } else {
      console.warn(`[RegionView] 未找到 ${displayName} 的坐标，使用默认值`)
      AppStorage.setOrCreate<number>('latitude', 23.1291)
      AppStorage.setOrCreate<number>('longitude', 113.2644)
    }

    // 5. 关闭弹窗
    this.showDistrictDialog = false
    this.selectedCityForDistrict = null

    // 6. 【暂不实现】跳转到首页（Tab 0）并刷新数据
    // TODO: 后续如需恢复此功能，取消注释以下代码
    // AppStorage.setOrCreate<number>('selectedTabIndex', 0)
    console.info(`[RegionView] 已选择: ${displayName}，坐标已保存（暂不跳转首页）`)
  }

  // 启动定时更新花粉数据
  startPollenDataUpdate(): void {
    // 清除之前的定时器
    if (this.pollenUpdateTimer !== null) {
      clearInterval(this.pollenUpdateTimer);
      this.pollenUpdateTimer = null;
    }

    // 每30分钟更新一次花粉数据
    const updateInterval = 30 * 60 * 1000; // 30分钟

    this.pollenUpdateTimer = setInterval(() => {
      console.info('[RegionView] 定时更新花粉数据');
      this.loadPollenDataForCities().catch((err: Error) => {
        console.warn(`[RegionView] 定时更新花粉数据失败: ${JSON.stringify(err)}`);
      });
      this.lastPollenUpdateTime = Date.now();
    }, updateInterval);

    console.info('[RegionView] 花粉数据定时更新已启动，每30分钟更新一次');
  }

  // 停止定时更新花粉数据
  stopPollenDataUpdate(): void {
    if (this.pollenUpdateTimer !== null) {
      clearInterval(this.pollenUpdateTimer);
      this.pollenUpdateTimer = null;
      console.info('[RegionView] 花粉数据定时更新已停止');
    }
  }


}
