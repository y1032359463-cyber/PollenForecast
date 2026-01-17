/**
 * 位置服务
 * 获取用户当前 GPS 位置
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
 * 位置服务类
 */
export class LocationService {
  private static instance: LocationService | null = null
  private context: common.UIAbilityContext | null = null

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
        return true
      }

      // 请求权限
      console.info('[LocationService] 请求位置权限...')
      const requestResult = await atManager.requestPermissionsFromUser(this.context, permissions)

      const granted = requestResult.authResults.every(result =>
        result === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
      )

      console.info('[LocationService] 权限请求结果: ' + granted)
      return granted
    } catch (error) {
      console.error('[LocationService] 权限检查失败: ' + JSON.stringify(error))
      return false
    }
  }

  /**
   * 获取当前位置（多重定位策略：GPS → 基站 → 被动定位）
   */
  async getCurrentLocation(): Promise<LocationInfo | null> {
    try {
      // 检查位置服务是否启用
      const isEnabled = geoLocationManager.isLocationEnabled()
      if (!isEnabled) {
        console.error('[LocationService] 位置服务未启用')
        return null
      }

      // 策略1: 尝试 GPS 精确定位（优先）
      console.info('[LocationService] 尝试 GPS 定位...')
      const gpsLocation = await this.tryGetLocation('GPS', {
        priority: geoLocationManager.LocationRequestPriority.ACCURACY,
        scenario: geoLocationManager.LocationRequestScenario.UNSET,
        maxAccuracy: 100,
        timeoutMs: 5000 // GPS 超时 5 秒
      })
      
      if (gpsLocation) {
        console.info('[LocationService] ✅ GPS 定位成功')
        return await this.buildLocationInfo(gpsLocation)
      }

      // 策略2: 降级到基站/网络定位（快速但精度低）
      console.info('[LocationService] GPS 失败，尝试基站定位...')
      const networkLocation = await this.tryGetLocation('NETWORK', {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        scenario: geoLocationManager.LocationRequestScenario.UNSET,
        maxAccuracy: 500,
        timeoutMs: 3000 // 基站定位超时 3 秒
      })
      
      if (networkLocation) {
        console.info('[LocationService] ✅ 基站定位成功')
        return await this.buildLocationInfo(networkLocation)
      }

      // 策略3: 使用最后一次定位（被动定位）
      console.info('[LocationService] 基站定位失败，尝试获取最后位置...')
      const lastLocation = await this.getLastKnownLocation()
      if (lastLocation) {
        console.info('[LocationService] ✅ 使用最后已知位置')
        return await this.buildLocationInfo(lastLocation)
      }

      console.error('[LocationService] ❌ 所有定位策略均失败')
      return null
    } catch (error) {
      console.error('[LocationService] 获取位置失败: ' + JSON.stringify(error))
      return null
    }
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
   * 构建位置信息（包含逆地理编码）
   */
  private async buildLocationInfo(location: geoLocationManager.Location): Promise<LocationInfo> {
    const locationInfo: LocationInfo = {
      latitude: location.latitude,
      longitude: location.longitude,
      city: '',
      address: ''
    }

    // 尝试逆地理编码获取城市名
    try {
      const reverseRequest: geoLocationManager.ReverseGeoCodeRequest = {
        latitude: location.latitude,
        longitude: location.longitude,
        maxItems: 1
      }
      const addresses = await geoLocationManager.getAddressesFromLocation(reverseRequest)
      if (addresses.length > 0) {
        const addr = addresses[0]
        locationInfo.city = (addr.administrativeArea || '') + ', ' + (addr.locality || '')
        locationInfo.address = addr.placeName || ''
        console.info('[LocationService] 城市: ' + locationInfo.city)
      }
    } catch (geoError) {
      console.warn('[LocationService] 逆地理编码失败: ' + JSON.stringify(geoError))
      locationInfo.city = '当前位置'
    }

    return locationInfo
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


