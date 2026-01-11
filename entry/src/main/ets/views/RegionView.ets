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
  CityGroup,
  CityItem as CityItemType
} from '../utils/CityUtils'
import { PollenService } from '../service/PollenService'
import { PollenLevel, getMaxPollenFromDaily } from '../model/PollenModels'
import { loadChinaAreaData, getCityWithDistricts } from '../utils/ChinaAreaDataLoader'  // 新增：区县数据加载器

// 重新定义CityItem以确保与CityUtils中的定义一致
interface CityItem {
  name: string
  distance: number
  isFavorite: boolean
  isTop: boolean
  pollenLevel?: number  // 花粉等级 (0-5, -1表示无数据)
  pollenIndex?: number  // 花粉指数值
  province?: string     // 省份名称
  pinyin?: string       // 拼音（用于搜索和排序）
  pinyinInitial?: string // 拼音首字母（用于字母索引）
}

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
  @State currentCity: string = '当前位置'
  @State actualLocationCity: string = ''  // GPS定位的真实城市名
  @State isAnimating: boolean = false
  @State firstLoad: boolean = true  // 首次加载标志（性能优化）
  @State swipeOffsets: Map<string, number> = new Map()  // 手动滑动状态管理
  @State isRefreshingLocation: boolean = false  // GPS定位中
  private lastUpdateTime: number = 0  // 节流：上次更新时间
  private pendingOffset: Map<string, number> = new Map()  // 节流：待更新的偏移值
  private cachedLocation: LocationInfo | null = null  // 缓存的GPS位置，用于快速响应
  @StorageLink('safeTop') safeTop: number = 44
  @StorageLink('safeBottom') safeBottom: number = 28
  @StorageLink('vibrationEnabled') vibrationEnabled: boolean = false  // 震动反馈开关
  @StorageLink('pollenThemeColor') pollenThemeColor: string = '#4CAF50'  // 花粉主题色

  private locationService: LocationService = LocationService.getInstance()

  // 滚动控制器
  private scroller: Scroller = new Scroller()

  // 定时更新花粉数据的定时器
  private pollenUpdateTimer: number | null = null

  // 最后一次更新时间
  private lastPollenUpdateTime: number = 0

  // 收藏的城市列表
  @State favoriteCities: string[] = []

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

  // 根据花粉等级获取颜色
  getPollenColor(level: number): ResourceColor {
    switch (level) {
      case 0:
        return '#E8F5E9' // 无/极低 - 浅绿
      case 1:
        return '#4CAF50' // 低 - 绿色
      case 2:
        return '#FFEB3B' // 中 - 黄色
      case 3:
        return '#FF9800' // 高 - 橙色
      case 4:
        return '#F44336' // 很高 - 红色
      case 5:
        return '#9C27B0' // 极高 - 紫色
      default:
        return '#9E9E9E' // 无数据 - 灰色
    }
  }


  // 过滤城市列表
  getFilteredCities(): CityItem[] {
    let targetList = this.cityList

    // 如果有搜索文本，使用工具类搜索（支持拼音）
    if (this.searchText && this.searchText.trim() !== '') {
      targetList = searchCities(this.cityList, this.searchText)
    }

    // 使用工具类排序
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

  // 切换城市收藏状态
  toggleFavorite(cityName: string): void {
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
        isFavorite: !city.isFavorite,
        isTop: city.isFavorite ? false : city.isTop, // 取消收藏时同时取消置顶
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
    // 【测试代码】加载区县数据
    console.info('[RegionView-Test] 开始加载区县数据...')
    try {
      const startTime = Date.now()
      // 传入context参数
      const allCitiesWithDistricts = await loadChinaAreaData(getContext(this))
      const loadTime = Date.now() - startTime
      
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

    // 1. 从 AppStorage 读取当前城市
    const storedCity = AppStorage.Get<string>('currentCity')
    if (storedCity) {
      this.currentCity = storedCity
      console.info(`[RegionView] 使用已存储城市: ${storedCity}`)
    }

    // 2. 初始化城市数据（补充拼音和省份信息）
    const updatedCityList: CityItem[] = []
    for (let i = 0; i < this.cityList.length; i++) {
      const city = this.cityList[i]
      const updatedCity: CityItem = {
        name: city.name,
        distance: city.distance,
        isFavorite: city.isFavorite,
        isTop: city.isTop,
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

  @Builder
  CityItemComponent(city: CityItem) {
    // P0优化: 手动实现滑动，替代 swipeAction
    Stack({ alignContent: Alignment.End }) {
      // 背景层：操作按钮
      Row() {
        Button({ type: ButtonType.Normal }) {
          Text(city.isFavorite ? '取消收藏' : '收藏')
            .fontSize(14)
            .fontColor(Color.White)
        }
        .width(80)
        .height('100%')
        .backgroundColor(city.isFavorite ? '#757575' : '#FF6B35')
        .onClick(() => {
          this.toggleFavorite(city.name)
          // 操作后回弹
          animateTo({ duration: 200 }, () => {
            this.swipeOffsets.set(city.name, 0)
          })
        })

        if (city.isFavorite && !city.isTop) {
          Button({ type: ButtonType.Normal }) {
            Text('置顶').fontSize(14).fontColor(Color.White)
          }
          .width(60)
          .height('100%')
          .backgroundColor('#4CAF50')
          .onClick(() => {
            this.moveToTop(city.name)
            animateTo({ duration: 200 }, () => {
              this.swipeOffsets.set(city.name, 0)
            })
          })
        }
      }
      .height('100%')

      // 主内容层
      Row() {
        // 状态图标：置顶 > 收藏 > 普通
        if (city.isTop) {
          Image($r('app.media.icon_pin'))
            .width(14)
            .height(14)
            .fillColor(this.pollenThemeColor)
        } else if (city.isFavorite) {
          Image($r('app.media.icon_star'))
            .width(14)
            .height(14)
            .fillColor('#FFD700')
        } else {
          Image($r('app.media.icon_chevron_right'))
            .width(12)
            .height(12)
            .fillColor(this.pollenThemeColor)
        }

        // 城市名称
        Column() {
          Text(city.name)
            .fontSize(15)
            .fontColor(city.isTop ? '#FFD700' : (city.isFavorite ? '#FF6B35' : $r('app.color.text_primary')))

          // 花粉浓度显示（如果有数据）
          if (city.pollenLevel !== undefined && city.pollenLevel >= 0) {
            Row() {
              Text(`花粉: ${city.pollenLevel}级`)
                .fontSize(11)
                .fontColor($r('app.color.text_secondary'))

              if (city.pollenIndex !== undefined && city.pollenIndex > 0) {
                Text(`(${city.pollenIndex})`)
                  .fontSize(11)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ left: 4 })
              }
            }
            .margin({ top: 2 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })

        Blank()

        // 距离和花粉信息
        Column() {
          Text(`${city.distance}公里`)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))

          // 花粉等级颜色指示
          if (city.pollenLevel !== undefined && city.pollenLevel >= 0) {
            Circle()
              .width(8)
              .height(8)
              .fill(this.getPollenColor(city.pollenLevel))
              .margin({ top: 4 })
          }
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .height(50)
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.page_background'))
      .translate({ x: this.swipeOffsets.get(city.name) ?? 0 })
      .gesture(
        PanGesture({ direction: PanDirection.Left | PanDirection.Right })
          .onActionUpdate((event: GestureEvent) => {
            const currentOffset = this.swipeOffsets.get(city.name) ?? 0
            const maxSwipe = city.isFavorite && !city.isTop ? -140 : -80
            const newOffset = Math.max(maxSwipe, Math.min(0, currentOffset + event.offsetX))

            // 节流优化：限制更新频率为 60fps (约 16ms)
            const now = Date.now()
            this.pendingOffset.set(city.name, newOffset)

            if (now - this.lastUpdateTime >= 16) {
              this.lastUpdateTime = now
              this.swipeOffsets.set(city.name, newOffset)
            }
          })
          .onActionEnd((event: GestureEvent) => {
            // 使用待更新的最终值（如果存在）
            const finalOffset = this.pendingOffset.get(city.name) ?? this.swipeOffsets.get(city.name) ?? 0
            if (this.pendingOffset.has(city.name)) {
              this.swipeOffsets.set(city.name, finalOffset)
              this.pendingOffset.delete(city.name)
            }

            const velocity = event.velocityX
            const currentOffset = finalOffset
            const threshold = city.isFavorite && !city.isTop ? -70 : -40

            // 判断是否展开
            if (velocity < -800 || currentOffset < threshold) {
              animateTo({ duration: 200, curve: Curve.Sharp }, () => {
                this.swipeOffsets.set(city.name, city.isFavorite && !city.isTop ? -140 : -80)
              })
            } else {
              animateTo({ duration: 200, curve: Curve.Sharp }, () => {
                this.swipeOffsets.set(city.name, 0)
              })
            }
          })
      )
      .onClick(() => {
        // 如果已展开，先收起
        const currentOffset = this.swipeOffsets.get(city.name) ?? 0
        if (currentOffset < -10) {
          animateTo({ duration: 200 }, () => {
            this.swipeOffsets.set(city.name, 0)
          })
        } else {
          this.selectCity(city.name)
        }
      })
    }
    .width('100%')
    .height(50)
    // P1优化: 使用 scale 替代 opacity+translate 复合动画
    .scale({
      x: this.shouldAnimate(0) ? (this.isAnimating ? 1 : 0.95) : 1,
      y: this.shouldAnimate(0) ? (this.isAnimating ? 1 : 0.95) : 1
    })
    .animation({
      duration: 240,  // 缩短时长
      delay: this.firstLoad ? 0 : 0,  // 减少延迟
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
            this.selectCity(this.actualLocationCity)
          })
        }
        .margin({ bottom: 20 })
      }

      // 热门城市
      Column() {
        Text('热门城市')
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
          .padding({ left: 16, bottom: 8 })

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
  }

  // 选择城市处理函数
  selectCity(cityName: string): void {
    console.info(`[RegionView] 选择城市: ${cityName}`)

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
      message: `已切换到 ${cityName}`,
      duration: 1500
    })

    // 3. 更新全局存储的城市信息
    AppStorage.SetOrCreate<string>('currentCity', cityName)
    this.currentCity = cityName

    // 获取城市坐标（使用全局常量）
    const coords = cityCoordinates[cityName]
    if (coords) {
      AppStorage.SetOrCreate<number>('latitude', coords.lat)
      AppStorage.SetOrCreate<number>('longitude', coords.lng)
      console.info(`[RegionView] 城市坐标: ${coords.lat}, ${coords.lng}`)
    } else {
      console.warn(`[RegionView] 未找到城市 ${cityName} 的坐标，使用默认值`)
      AppStorage.SetOrCreate<number>('latitude', 23.1291)
      AppStorage.SetOrCreate<number>('longitude', 113.2644)
    }

    // 4. 跳转到首页（Tab 0）并刷新数据
    AppStorage.SetOrCreate<number>('selectedTabIndex', 0)
    console.info(`[RegionView] 已切换到城市: ${cityName}，跳转首页`)
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
