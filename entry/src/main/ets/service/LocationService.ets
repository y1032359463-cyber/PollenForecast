/**
 * 位置服务（优化版）
 * 快速定位 + 缓存 + 位置监听
 */

import { geoLocationManager } from '@kit.LocationKit'
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit'

/**
 * 位置信息接口
 */
export interface LocationInfo {
  latitude: number
  longitude: number
  city: string
  address: string
}

/**
 * 地址信息接口（用于异步获取地址）
 */
interface AddressInfo {
  city: string
  address: string
}

/**
 * 位置变化回调类型
 */
export type LocationChangeCallback = (location: LocationInfo) => void

/**
 * 位置服务类（优化版）
 */
export class LocationService {
  private static instance: LocationService | null = null
  private context: common.UIAbilityContext | null = null
  
  // 缓存相关
  private cachedLocation: LocationInfo | null = null
  private cacheTimestamp: number = 0
  private readonly CACHE_VALID_MS: number = 5 * 60 * 1000  // 缓存有效期 5 分钟
  
  // 位置监听相关
  private isListening: boolean = false
  private locationCallbacks: LocationChangeCallback[] = []

  private constructor() {
  }

  /**
   * 获取单例实例
   */
  static getInstance(): LocationService {
    if (LocationService.instance === null) {
      LocationService.instance = new LocationService()
    }
    return LocationService.instance
  }

  /**
   * 设置上下文
   */
  setContext(context: common.UIAbilityContext): void {
    this.context = context
  }

  /**
   * 检查并请求位置权限
   */
  async checkAndRequestPermission(): Promise<boolean> {
    if (this.context === null) {
      console.error('[LocationService] Context not set')
      return false
    }

    const permissions: Permissions[] = [
      'ohos.permission.LOCATION',
      'ohos.permission.APPROXIMATELY_LOCATION'
    ]

    try {
      const atManager = abilityAccessCtrl.createAtManager()

      // 检查权限状态
      const checkResult = await atManager.checkAccessToken(
        this.context.applicationInfo.accessTokenId,
        permissions[0]
      )

      if (checkResult === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        console.info('[LocationService] 已有位置权限')
        // 有权限后启动位置监听
        this.startLocationListener()
        return true
      }

      // 请求权限
      console.info('[LocationService] 请求位置权限...')
      const requestResult = await atManager.requestPermissionsFromUser(this.context, permissions)

      const granted = requestResult.authResults.every(result =>
        result === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
      )

      console.info('[LocationService] 权限请求结果: ' + granted)
      
      // 授权成功后启动位置监听
      if (granted) {
        this.startLocationListener()
      }
      
      return granted
    } catch (error) {
      console.error('[LocationService] 权限检查失败: ' + JSON.stringify(error))
      return false
    }
  }

  /**
   * 快速获取位置（优先返回缓存，后台更新）
   * 适用于：应用启动、切换页面等需要快速响应的场景
   */
  async getQuickLocation(): Promise<LocationInfo | null> {
    const startTime = Date.now()
    
    // 1. 优先返回有效缓存（毫秒级响应）
    if (this.isCacheValid()) {
      console.info(`[LocationService] ⚡ 使用缓存位置 (${Date.now() - startTime}ms)`)
      // 后台静默更新位置
      this.updateLocationInBackground()
      return this.cachedLocation
    }

    // 2. 尝试获取最后已知位置（通常 <100ms）
    const lastLocation = await this.getLastKnownLocation()
    if (lastLocation) {
      const locationInfo = await this.buildLocationInfoQuick(lastLocation)
      this.updateCache(locationInfo)
      console.info(`[LocationService] ⚡ 使用最后位置 (${Date.now() - startTime}ms)`)
      // 后台静默更新
      this.updateLocationInBackground()
      return locationInfo
    }

    // 3. 快速定位（基站优先，2秒超时）
    console.info('[LocationService] 快速定位...')
    const quickLocation = await this.tryGetLocation('QUICK', {
      priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
      scenario: geoLocationManager.LocationRequestScenario.UNSET,
      maxAccuracy: 1000,  // 放宽精度要求
      timeoutMs: 2000     // 2秒超时
    })
    
    if (quickLocation) {
      const locationInfo = await this.buildLocationInfoQuick(quickLocation)
      this.updateCache(locationInfo)
      console.info(`[LocationService] ⚡ 快速定位成功 (${Date.now() - startTime}ms)`)
      // 后台获取更精确位置
      this.updateLocationInBackground()
      return locationInfo
    }

    // 4. 所有方法都失败，返回默认位置
    console.warn(`[LocationService] 快速定位失败，返回默认位置 (${Date.now() - startTime}ms)`)
    return this.getDefaultLocation()
  }

  /**
   * 精确获取位置（等待 GPS）
   * 适用于：用户点击定位按钮等需要精确位置的场景
   */
  async getCurrentLocation(): Promise<LocationInfo | null> {
    const startTime = Date.now()
    
    try {
      // 检查位置服务是否启用
      const isEnabled = geoLocationManager.isLocationEnabled()
      if (!isEnabled) {
        console.error('[LocationService] 位置服务未启用')
        return this.cachedLocation || this.getDefaultLocation()
      }

      // 策略1: 先尝试快速定位（基站/网络，2秒）
      console.info('[LocationService] 尝试快速定位...')
      const quickLocation = await this.tryGetLocation('QUICK', {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        scenario: geoLocationManager.LocationRequestScenario.UNSET,
        maxAccuracy: 500,
        timeoutMs: 2000
      })
      
      if (quickLocation) {
        const locationInfo = await this.buildLocationInfo(quickLocation)
        this.updateCache(locationInfo)
        console.info(`[LocationService] ✅ 快速定位成功 (${Date.now() - startTime}ms)`)
        
        // 后台继续 GPS 精确定位
        this.getGpsLocationInBackground()
        return locationInfo
      }

      // 策略2: GPS 精确定位（3秒超时）
      console.info('[LocationService] 尝试 GPS 定位...')
      const gpsLocation = await this.tryGetLocation('GPS', {
        priority: geoLocationManager.LocationRequestPriority.ACCURACY,
        scenario: geoLocationManager.LocationRequestScenario.UNSET,
        maxAccuracy: 100,
        timeoutMs: 3000
      })
      
      if (gpsLocation) {
        const locationInfo = await this.buildLocationInfo(gpsLocation)
        this.updateCache(locationInfo)
        console.info(`[LocationService] ✅ GPS 定位成功 (${Date.now() - startTime}ms)`)
        return locationInfo
      }

      // 策略3: 使用最后一次定位
      const lastLocation = await this.getLastKnownLocation()
      if (lastLocation) {
        const locationInfo = await this.buildLocationInfo(lastLocation)
        this.updateCache(locationInfo)
        console.info(`[LocationService] ✅ 使用最后位置 (${Date.now() - startTime}ms)`)
        return locationInfo
      }

      // 策略4: 返回缓存
      if (this.cachedLocation) {
        console.info(`[LocationService] ✅ 使用缓存位置 (${Date.now() - startTime}ms)`)
        return this.cachedLocation
      }

      console.error(`[LocationService] ❌ 所有定位策略均失败 (${Date.now() - startTime}ms)`)
      return this.getDefaultLocation()
    } catch (error) {
      console.error('[LocationService] 获取位置失败: ' + JSON.stringify(error))
      return this.cachedLocation || this.getDefaultLocation()
    }
  }

  /**
   * 后台静默更新位置（不阻塞 UI）
   */
  private updateLocationInBackground(): void {
    setTimeout(async () => {
      try {
        const location = await this.tryGetLocation('BG_GPS', {
          priority: geoLocationManager.LocationRequestPriority.ACCURACY,
          scenario: geoLocationManager.LocationRequestScenario.UNSET,
          maxAccuracy: 100,
          timeoutMs: 5000
        })
        
        if (location) {
          const locationInfo = await this.buildLocationInfo(location)
          this.updateCache(locationInfo)
          // 通知订阅者位置更新
          this.notifyLocationChange(locationInfo)
          console.info('[LocationService] 🔄 后台位置已更新')
        }
      } catch (e) {
        console.warn('[LocationService] 后台更新位置失败')
      }
    }, 100)
  }

  /**
   * 后台获取 GPS 精确位置
   */
  private getGpsLocationInBackground(): void {
    setTimeout(async () => {
      try {
        const location = await this.tryGetLocation('BG_GPS', {
          priority: geoLocationManager.LocationRequestPriority.ACCURACY,
          scenario: geoLocationManager.LocationRequestScenario.UNSET,
          maxAccuracy: 50,
          timeoutMs: 8000
        })
        
        if (location) {
          const locationInfo = await this.buildLocationInfo(location)
          
          // 只有更精确时才更新
          if (this.cachedLocation) {
            const distance = this.calculateDistance(
              this.cachedLocation.latitude, this.cachedLocation.longitude,
              locationInfo.latitude, locationInfo.longitude
            )
            if (distance > 50) {  // 偏差超过 50 米才更新
              this.updateCache(locationInfo)
              this.notifyLocationChange(locationInfo)
              console.info(`[LocationService] 🎯 GPS 精确位置已更新（偏差 ${distance.toFixed(0)}m）`)
            }
          } else {
            this.updateCache(locationInfo)
            this.notifyLocationChange(locationInfo)
          }
        }
      } catch (e) {
        console.warn('[LocationService] 后台 GPS 定位失败')
      }
    }, 100)
  }

  /**
   * 启动位置监听（授权后自动更新位置）
   */
  startLocationListener(): void {
    if (this.isListening) {
      return
    }
    
    try {
      const locationRequest: geoLocationManager.LocationRequest = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        scenario: geoLocationManager.LocationRequestScenario.UNSET,
        timeInterval: 60,      // 60秒更新一次
        distanceInterval: 100, // 移动 100 米更新一次
        maxAccuracy: 200
      }
      
      geoLocationManager.on('locationChange', locationRequest, async (location) => {
        console.info(`[LocationService] 📍 位置变化: ${location.latitude}, ${location.longitude}`)
        const locationInfo = await this.buildLocationInfoQuick(location)
        this.updateCache(locationInfo)
        this.notifyLocationChange(locationInfo)
      })
      
      this.isListening = true
      console.info('[LocationService] ✅ 位置监听已启动')
    } catch (e) {
      console.warn('[LocationService] 启动位置监听失败: ' + JSON.stringify(e))
    }
  }

  /**
   * 停止位置监听
   */
  stopLocationListener(): void {
    if (!this.isListening) {
      return
    }
    
    try {
      geoLocationManager.off('locationChange')
      this.isListening = false
      console.info('[LocationService] 位置监听已停止')
    } catch (e) {
      console.warn('[LocationService] 停止位置监听失败')
    }
  }

  /**
   * 订阅位置变化
   */
  onLocationChange(callback: LocationChangeCallback): void {
    this.locationCallbacks.push(callback)
  }

  /**
   * 取消订阅
   */
  offLocationChange(callback: LocationChangeCallback): void {
    const index = this.locationCallbacks.indexOf(callback)
    if (index > -1) {
      this.locationCallbacks.splice(index, 1)
    }
  }

  /**
   * 通知位置变化
   */
  private notifyLocationChange(location: LocationInfo): void {
    for (let i = 0; i < this.locationCallbacks.length; i++) {
      try {
        this.locationCallbacks[i](location)
      } catch (e) {
        console.warn('[LocationService] 回调执行失败')
      }
    }
  }

  /**
   * 检查缓存是否有效
   */
  private isCacheValid(): boolean {
    if (!this.cachedLocation) {
      return false
    }
    return Date.now() - this.cacheTimestamp < this.CACHE_VALID_MS
  }

  /**
   * 更新缓存
   */
  private updateCache(location: LocationInfo): void {
    this.cachedLocation = location
    this.cacheTimestamp = Date.now()
  }

  /**
   * 尝试单次定位
   */
  private async tryGetLocation(
    type: string,
    request: geoLocationManager.CurrentLocationRequest
  ): Promise<geoLocationManager.Location | null> {
    try {
      const location = await geoLocationManager.getCurrentLocation(request)
      console.info(`[LocationService] ${type} 定位: ${location.latitude}, ${location.longitude}`)
      return location
    } catch (error) {
      console.warn(`[LocationService] ${type} 定位失败: ${JSON.stringify(error)}`)
      return null
    }
  }

  /**
   * 获取最后已知位置
   */
  private async getLastKnownLocation(): Promise<geoLocationManager.Location | null> {
    try {
      const location = await geoLocationManager.getLastLocation()
      if (location) {
        console.info(`[LocationService] 最后位置: ${location.latitude}, ${location.longitude}`)
        return location
      }
      return null
    } catch (error) {
      console.warn('[LocationService] 获取最后位置失败: ' + JSON.stringify(error))
      return null
    }
  }

  /**
   * 快速构建位置信息（异步获取城市名，不阻塞）
   */
  private async buildLocationInfoQuick(location: geoLocationManager.Location): Promise<LocationInfo> {
    const locationInfo: LocationInfo = {
      latitude: location.latitude,
      longitude: location.longitude,
      city: '当前位置',  // 先用默认值
      address: ''
    }

    // 异步获取城市名（不阻塞返回）
    this.getAddressAsync(location.latitude, location.longitude).then((address) => {
      if (address && this.cachedLocation) {
        this.cachedLocation.city = address.city
        this.cachedLocation.address = address.address
        // 通知城市名已更新
        this.notifyLocationChange(this.cachedLocation)
      }
    })

    return locationInfo
  }

  /**
   * 构建位置信息（包含逆地理编码，会等待）
   */
  private async buildLocationInfo(location: geoLocationManager.Location): Promise<LocationInfo> {
    const locationInfo: LocationInfo = {
      latitude: location.latitude,
      longitude: location.longitude,
      city: '',
      address: ''
    }

    // 尝试逆地理编码获取城市名（最多等待 2 秒）
    try {
      const addressPromise = this.getAddressAsync(location.latitude, location.longitude)
      const timeoutPromise = new Promise<null>((resolve) => setTimeout(() => resolve(null), 2000))
      
      const address = await Promise.race([addressPromise, timeoutPromise])
      if (address) {
        locationInfo.city = address.city
        locationInfo.address = address.address
      } else {
        locationInfo.city = '当前位置'
      }
    } catch (geoError) {
      console.warn('[LocationService] 逆地理编码失败: ' + JSON.stringify(geoError))
      locationInfo.city = '当前位置'
    }

    return locationInfo
  }

  /**
   * 异步获取地址
   */
  private async getAddressAsync(latitude: number, longitude: number): Promise<AddressInfo | null> {
    try {
      const reverseRequest: geoLocationManager.ReverseGeoCodeRequest = {
        latitude: latitude,
        longitude: longitude,
        maxItems: 1
      }
      const addresses = await geoLocationManager.getAddressesFromLocation(reverseRequest)
      if (addresses.length > 0) {
        const addr = addresses[0]
        const city = (addr.administrativeArea || '') + ', ' + (addr.locality || '')
        const address = addr.placeName || ''
        console.info('[LocationService] 城市: ' + city)
        const addressInfo: AddressInfo = { city, address }
        return addressInfo
      }
    } catch (e) {
      console.warn('[LocationService] 获取地址失败')
    }
    return null
  }

  /**
   * 计算两点距离（米）
   */
  private calculateDistance(lat1: number, lng1: number, lat2: number, lng2: number): number {
    const R = 6371000  // 地球半径（米）
    const dLat = (lat2 - lat1) * Math.PI / 180
    const dLng = (lng2 - lng1) * Math.PI / 180
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
      Math.sin(dLng / 2) * Math.sin(dLng / 2)
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    return R * c
  }

  /**
   * 获取缓存的位置
   */
  getCachedLocation(): LocationInfo | null {
    return this.cachedLocation
  }

  /**
   * 获取默认位置（广州）
   */
  getDefaultLocation(): LocationInfo {
    return {
      latitude: 23.1291,
      longitude: 113.2644,
      city: '广东省, 广州市',
      address: '广州市'
    }
  }
}


