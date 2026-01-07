/**
 * 地图页面 - Tab3
 * 使用华为 Map Kit 显示地图和花粉信息
 * 支持 API 17+ 兼容处理
 */

import { MapComponent, map, mapCommon } from '@kit.MapKit';
import { LocationService } from '../service/LocationService';
import { promptAction, window } from '@kit.ArkUI';  // window 用于获取 vp 单位屏幕尺寸
import { vibrator } from '@kit.SensorServiceKit';
import { ConfigurationConstant, common } from '@kit.AbilityKit';
import { motion } from '@kit.MultimodalAwarenessKit';  // 智感握姿监听（API 20+）
import { display } from '@kit.ArkUI';  // 获取屏幕尺寸（用于像素密度）
import { ApiVersionUtils } from '../utils/ApiVersionUtils';  // API 版本检测工具

// 城市坐标数据（与 RegionView 保持一致）
interface CityCoordinate {
  lat: number
  lng: number
}

// 花粉标记数据
interface PollenMarkerData {
  cityName: string
  latitude: number
  longitude: number
  pollenValue: number
  pollenLevel: string
  marker?: map.Marker
}

// 城市经纬度映射表
const CITY_COORDINATES: Record<string, CityCoordinate> = {
  '北京市': { lat: 39.9042, lng: 116.4074 },
  '上海市': { lat: 31.2304, lng: 121.4737 },
  '广州市': { lat: 23.1291, lng: 113.2644 },
  '深圳市': { lat: 22.5431, lng: 114.0579 },
  '杭州市': { lat: 30.2741, lng: 120.1551 },
  '成都市': { lat: 30.5728, lng: 104.0668 },
  '武汉市': { lat: 30.5928, lng: 114.3055 },
  '重庆市': { lat: 29.4316, lng: 106.9123 },
  '海南省, 海口市': { lat: 20.0444, lng: 110.1989 },
  '广西壮族自治区, 南宁市': { lat: 22.8170, lng: 108.3665 },
  '贵州省, 贵阳市': { lat: 26.6470, lng: 106.6302 },
  '云南省, 昆明市': { lat: 25.0406, lng: 102.7129 },
  '湖南省, 长沙市': { lat: 28.2278, lng: 112.9388 },
  '江西省, 南昌市': { lat: 28.6829, lng: 115.8579 },
  '福建省, 福州市': { lat: 26.0745, lng: 119.2965 },
  '四川省, 南充市': { lat: 30.8376, lng: 106.1107 },
  '安徽省, 合肥市': { lat: 31.8206, lng: 117.2272 },
  '浙江省, 杭州市': { lat: 30.2741, lng: 120.1551 },
  '陕西省, 西安市': { lat: 34.3416, lng: 108.9398 },
  '江苏省, 无锡市': { lat: 31.4912, lng: 120.3119 },
  '河南省, 郑州市': { lat: 34.7472, lng: 113.6249 }
}

// 热门城市列表（地图上显示标记的城市）
const HOT_CITIES: string[] = ['北京市', '上海市', '广州市', '深圳市', '杭州市', '成都市', '武汉市', '重庆市']

@Component
export struct MapView {
  // 使用 AppStorage 共享数据
  @StorageLink('currentCity') currentLocation: string = '定位中...'
  @StorageLink('pollenLevel') pollenLevel: string = '加载中...'
  @StorageLink('pollenValue') pollenValue: number = 0
  @StorageLink('updateTime') updateTime: string = '获取中...'
  @StorageLink('latitude') @Watch('onLocationChanged') latitude: number = 23.1291
  @StorageLink('longitude') @Watch('onLocationChanged') longitude: number = 113.2644
  @StorageLink('pollenThemeColor') pollenThemeColor: string = '#4CAF50'  // 花粉主题色
  @State isAnimating: boolean = false
  @State isLocating: boolean = false  // 定位按钮加载状态
  @State holdingHand: 'LEFT' | 'RIGHT' | null = null  // 智感握姿状态
  @State buttonX: number = 0  // 按钮X坐标（aboutToAppear中初始化）
  @State buttonY: number = 0  // 按钮Y坐标（aboutToAppear中初始化）
  private initialButtonY: number = 0  // 存储初始Y坐标（避免Tab bar遮挡）
  @StorageLink('safeTop') safeTop: number = 44
  @StorageLink('safeBottom') safeBottom: number = 28
  @StorageLink('currentColorMode') @Watch('onThemeChanged') currentColorMode: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
  // 地图相关
  private mapOptions?: mapCommon.MapOptions
  private mapController: map.MapComponentController | null = null
  private mapEventManager?: map.MapEventManager // 事件管理器（API 20新增）
  private locationService: LocationService = LocationService.getInstance()
  @State mapReady: boolean = false
  private currentMarker: map.Marker | null = null // 当前位置标记
  private cityMarkers: Map<string, map.Marker> = new Map() // 城市标记集合
  private isUpdating: boolean = false // 防止重复更新
  private gripDebounceTimer: number | null = null // 握姿检测防抖定时器
  private hasShownGripToast: boolean = false // 是否已显示Tips（首次提示）
  private isGripListening: boolean = false // 握姿监听是否活跃
  @StorageLink('vibrationEnabled') vibrationEnabled: boolean = false // 震动反馈开关
  @StorageLink('gripDetectionEnabled') @Watch('onGripDetectionChange') gripDetectionEnabled: boolean = false // 智感握姿开关
  @StorageLink('isAppInBackground') @Watch('onAppBackgroundChange') isAppInBackground: boolean = false // 应用前后台状态

  aboutToAppear(): void {
    // 初始化地图配置（添加 padding 避开顶部卡片）
    this.mapOptions = {
      position: {
        target: {
          latitude: this.latitude,
          longitude: this.longitude
        },
        zoom: 11  // 城市级别缩放（调整为11，更适合城市范围）
      },
      // 预留顶部信息卡片区域（状态栏44 + 卡片高度约140 + 间距24）
      padding: {
        top: 208,
        bottom: 0,
        left: 0,
        right: 0
      },
      // 地图样式
      mapType: mapCommon.MapType.STANDARD,
      // 自定义样式路径（深色模式适配）
      // stylePath: this.currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK
      //   ? 'common/map_dark.json'
      //   : 'common/map_light.json',
      // 限制缩放级别（城市范围）
      minZoom: 9,   // 最小缩放：可以看到周边城市
      maxZoom: 14   // 最大缩放：街道级别，不会太细节
    }
    // 确保按钮初始化时就可见
    this.isAnimating = true

    // 初始化按钮位置（默认右侧 60% 高度）
    const screenWidthPX = display.getDefaultDisplaySync().width
    const screenHeightPX = display.getDefaultDisplaySync().height
    const screenWidthVP = px2vp(screenWidthPX)
    const screenHeightVP = px2vp(screenHeightPX)
    
    this.buttonX = screenWidthVP - 64  // 右侧：屏幕宽度 - 按钮48 - 边距16
    this.initialButtonY = screenHeightVP * 0.6  // 默认 60% 高度
    this.buttonY = this.initialButtonY
    
    console.info(`[MapView] 按钮初始化位置(vp): (${this.buttonX}, ${this.buttonY})`)

    // 启用智感握姿监听
    this.setupGripDetection()

    console.info('[MapView] aboutToAppear: 初始化完成')
  }

  aboutToDisappear(): void {
    // 清理防抖定时器
    if (this.gripDebounceTimer !== null) {
      clearTimeout(this.gripDebounceTimer)
      this.gripDebounceTimer = null
    }

    // 注销智感握姿监听
    this.stopGripDetection()
  }

  // ========== 智感握姿检测 ==========
  // 应用前后台状态变化回调
  onAppBackgroundChange() {
    if (this.isAppInBackground) {
      console.info('[MapView] 应用进入后台，停止握姿监听')
      this.stopGripDetection()
    } else {
      console.info('[MapView] 应用回到前台，检查是否恢复握姿监听')
      // 只有在功能开启且页面可见时才恢复
      if (this.gripDetectionEnabled && this.isAnimating) {
        this.setupGripDetection()
      }
    }
  }

  // 开关变化回调
  onGripDetectionChange() {
    if (this.gripDetectionEnabled) {
      console.info('[MapView] 智感握姿已开启，启动监听')
      this.setupGripDetection()
    } else {
      console.info('[MapView] 智感握姿已关闭，停止监听并恢复默认位置')
      this.stopGripDetection()
      // 恢复到右侧初始位置
      animateTo({ duration: 150 }, () => {
        const screenWidthVP = px2vp(display.getDefaultDisplaySync().width)
        this.holdingHand = null
        this.buttonX = screenWidthVP - 64
        this.buttonY = this.initialButtonY
      })
    }
  }

  private setupGripDetection() {
    // API 版本检测：智感握姿仅 API 20+ 支持
    if (!ApiVersionUtils.supportsGripDetection()) {
      console.info('[MapView] API 版本不支持智感握姿，跳过')
      return
    }

    // 检查开关状态
    if (!this.gripDetectionEnabled) {
      console.info('[MapView] 智感握姿已关闭，不启动监听')
      return
    }

    // 检查应用是否在后台
    if (this.isAppInBackground) {
      console.info('[MapView] 应用在后台，不启动握姿监听')
      return
    }

    // 防止重复启动
    if (this.isGripListening) {
      console.info('[MapView] 握姿监听已在运行，跳过重复启动')
      return
    }

    try {
      motion.on('holdingHandChanged', (status: motion.HoldingHandStatus) => {
        // 防抖：1秒内只响应一次
        if (this.gripDebounceTimer !== null) {
          clearTimeout(this.gripDebounceTimer)
        }

        this.gripDebounceTimer = setTimeout(() => {
          // 获取屏幕尺寸（px）并转换为 vp
          const screenWidthPX = display.getDefaultDisplaySync().width
          const screenHeightPX = display.getDefaultDisplaySync().height
          const screenWidthVP = px2vp(screenWidthPX)
          const screenHeightVP = px2vp(screenHeightPX)
          
          // HoldingHandStatus: 0=NONE(无握持), 1=LEFT_HAND, 2/3=RIGHT_HAND
          if (status === 0) {
            // 松开手 → 恢复初始位置
            console.info(`[MapView] 握姿释放，恢复初始位置 (status=0)`)
            animateTo({ duration: 150 }, () => {
              this.holdingHand = null
              this.buttonX = screenWidthVP - 64
              this.buttonY = this.initialButtonY
              console.info(`[MapView] 按钮位置恢复(vp): (${this.buttonX}, ${this.buttonY})`)
            })
          } else {
            // 检测到握姿 → 移动到60%高度
            const handType = status === 1 ? 'LEFT' : 'RIGHT'
            console.info(`[MapView] 握手检测: ${handType} (status=${status})`)
            
            this.holdingHand = handType
            
            animateTo({ duration: 150 }, () => {
              this.buttonX = handType === 'LEFT' ? 16 : (screenWidthVP - 64)
              this.buttonY = screenHeightVP * 0.6
              console.info(`[MapView] 按钮位置更新(vp): (${this.buttonX}, ${this.buttonY})，握姿=${handType}`)
            })
          }

          // 震动反馈（仅握姿检测时，释放时不震动）
          if (status !== 0 && this.vibrationEnabled) {
            try {
              vibrator.startVibration({ type: 'time', duration: 15 }, { usage: 'touch' })
            } catch (err) {
              const error = err as Error
              console.error(`[MapView] 震动反馈失败: ${error.message}`)
            }
          }

          // Toast提示（仅首次握姿检测时）
          if (status !== 0 && !this.hasShownGripToast) {
            const handType = status === 1 ? 'LEFT' : 'RIGHT'
            promptAction.showToast({
              message: `已检测到${handType === 'LEFT' ? '左' : '右'}手握持，按钮自动调整位置`,
              duration: 2000
            })
            this.hasShownGripToast = true
          }

          this.gripDebounceTimer = null
        }, 300) // 300ms防抖（优化响应速度）
      })
      this.isGripListening = true
      console.info('[MapView] 智感握姿监听已启动')
    } catch (error) {
      console.error(`[MapView] 智感握姿初始化失败: ${error}`)
    }
  }

  // 停止握姿检测（页面不可见时调用）
  private stopGripDetection() {
    if (!this.isGripListening) {
      return
    }

    try {
      motion.off('holdingHandChanged')
      this.isGripListening = false
      console.info('[MapView] 智感握姿监听已停止（页面不可见）')
    } catch (error) {
      console.error(`[MapView] 停止监听失败: ${error}`)
    }
  }

  // 监听经纬度变化（作为双重保障，但在跨Tab场景可能不触发）
  onLocationChanged(): void {
    console.info('[MapView] @Watch 触发')
    if (this.mapReady && this.mapController && !this.isUpdating) {
      this.isUpdating = true
      console.info(`[MapView] 位置变化: (${this.latitude}, ${this.longitude})`)
      // 使用setTimeout替代requestAnimationFrame
      setTimeout(() => {
        this.moveCameraToLocation(this.latitude, this.longitude)
        this.isUpdating = false
      }, 0)
    }
  }

  // 监听主题变化（使用自定义样式文件实现深色模式）
  onThemeChanged(): void {
    console.info(`[MapView] 主题变化: ${this.currentColorMode}`)
    if (this.mapReady && this.mapController) {
      try {
        // 使用自定义样式文件切换主题（需要先创建样式文件）
        // const stylePath = this.currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK
        //   ? 'common/map_dark.json'
        //   : 'common/map_light.json'
        // this.mapController.setMapStylePath(stylePath)
        // console.info(`[MapView] 地图样式已切换为: ${stylePath}`)
        
        // TODO: 创建自定义样式文件后启用上述代码
        console.info('[MapView] 地图深色模式暂未启用（需要自定义样式文件）')
      } catch (err) {
        console.error(`[MapView] 切换地图样式失败: ${JSON.stringify(err)}`)
      }
    }
  }

  // 地图初始化回调
  callback = (err: Error, controller: map.MapComponentController) => {
    if (!err) {
      this.mapController = controller
      this.mapReady = true
      console.info('[MapView] 地图初始化成功')

      // API 版本检测
      const apiVersion = ApiVersionUtils.getApiVersion()
      console.info(`[MapView] 当前 API 版本: ${apiVersion}，${ApiVersionUtils.getVersionDescription()}`)

      // ========== 事件监听兼容处理 ==========
      if (ApiVersionUtils.supportsMapEventManager()) {
        // API 20+: 使用 MapEventManager
        try {
          this.mapEventManager = controller.getEventManager()
          
          // 添加相机空闲监听（缩放级别变化时触发）
          this.mapEventManager.on('cameraIdle', async () => {
            await this.onCameraChanged()
          })
          
          // 添加标记点击监听（全局只绑定一次）
          this.mapEventManager.on('markerClick', (clickedMarker: map.Marker) => {
            this.handleMarkerClick(clickedMarker)
          })
          
          // 添加定位按钮点击监听（使用自定义按钮，此事件不再使用）
          this.mapEventManager.on('myLocationClick', async () => {
            console.info('[MapView] 系统定位按钮被点击（已禁用，使用自定义按钮）')
          })
          
          console.info('[MapView] ✅ MapEventManager 初始化成功（API 20+）')
        } catch (e) {
          console.warn('[MapView] MapEventManager 初始化失败:', JSON.stringify(e))
        }
      } else {
        // API 17-19: 事件监听待真机验证
        // TODO: API 17 真机验证后实现 controller.on() 事件监听
        console.warn('[MapView] API 17-19 设备，事件监听功能受限（待真机验证）')
        console.warn('[MapView] 地图标记点击和相机移动事件可能不可用')
      }

      // ========== 禁用系统定位控件（使用自定义按钮）==========
      setTimeout(() => {
        if (!this.mapController) {
          return
        }
        try {
          // 关闭系统定位功能
          this.mapController.setMyLocationEnabled(false)
          
          // 隐藏系统定位按钮
          this.mapController.setMyLocationControlsEnabled(false)
          
          // 隐藏缩放按钮
          this.mapController.setZoomControlsEnabled(false)
          
          console.info('[MapView] 系统定位控件已禁用，使用自定义按钮')
        } catch (e) {
          console.warn('[MapView] 禁用系统控件失败:', JSON.stringify(e))
        }
      }, 200)

      // 添加当前位置标记
      this.addCurrentLocationMarker()
      
      // 添加热门城市标记
      this.addHotCityMarkers()
    } else {
      console.error('[MapView] 地图初始化失败:', JSON.stringify(err))
    }
  }

  // 移动相机到指定位置（API 20 正确实现）
  async moveCameraToLocation(latitude: number, longitude: number, zoom?: number): Promise<void> {
    if (!this.mapController) {
      console.warn('[MapView] 地图控制器未初始化')
      return
    }

    try {
      console.info(`[MapView] 开始移动相机到: (${latitude}, ${longitude})`)

      // 1. 创建 CameraPosition 对象
      const cameraPosition: mapCommon.CameraPosition = {
        target: { latitude: latitude, longitude: longitude },
        zoom: zoom ?? 12,
        tilt: 0,
        bearing: 0
      }

      // 2. 通过 newCameraPosition() 工厂方法生成 CameraUpdate
      const cameraUpdate = map.newCameraPosition(cameraPosition)

      // 3. 使用 animateCamera 实现动画移动（1000ms 动画时长）
      await this.mapController.animateCamera(cameraUpdate, 1000)
      
      console.info('[MapView] ✅ 相机移动成功')

      // 更新位置标记
      await this.updateLocationMarker()
    } catch (err) {
      const error = err as Error
      console.error('[MapView] ❌ 移动相机失败 - 错误信息:', error.message || '未知错误')
      
      // 降级方案：仅更新标记点
      await this.updateLocationMarker()
    }
  }

  // 相机变化处理（控制Marker可见性）
  async onCameraChanged(): Promise<void> {
    if (!this.mapController) {
      return
    }

    try {
      const cameraPosition = await this.mapController.getCameraPosition()
      const zoomLevel = cameraPosition.zoom
      
      // 缩放级别 > 14 时隐藏当前位置Marker（避免与蓝色定位点重叠）
      // 缩放级别 <= 14 时显示当前位置Marker（城市级别，需要红色标记点）
      if (this.currentMarker) {
        this.currentMarker.setVisible(zoomLevel <= 14)
        console.info(`[MapView] 缩放级别 ${zoomLevel.toFixed(1)}, Marker可见性: ${zoomLevel <= 14}`)
      }
    } catch (e) {
      console.warn('[MapView] 获取相机位置失败:', JSON.stringify(e))
    }
  }

  // 更新位置标记(删除旧标记并添加新标记)
  async updateLocationMarker(): Promise<void> {
    if (!this.mapController) {
      return
    }

    try {
      // 删除旧标记
      if (this.currentMarker) {
        try {
          await this.currentMarker.remove()
        } catch (e) {
          console.warn('[MapView] 删除旧标记失败:', JSON.stringify(e))
        }
      }

      // 添加新标记
      const markerOptions: mapCommon.MarkerOptions = {
        position: {
          latitude: this.latitude,
          longitude: this.longitude
        },
        title: this.currentLocation
      }
      this.currentMarker = await this.mapController.addMarker(markerOptions)
      console.info('[MapView] 位置标记已更新')
    } catch (err) {
      console.error('[MapView] 更新标记失败:', JSON.stringify(err))
    }
  }

  // 添加当前位置标记(初始化时调用)
  async addCurrentLocationMarker(): Promise<void> {
    await this.updateLocationMarker()
  }

  // 添加热门城市标记
  async addHotCityMarkers(): Promise<void> {
    if (!this.mapController) {
      console.warn('[MapView] 地图控制器未初始化，无法添加城市标记')
      return
    }

    console.info('[MapView] 开始添加热门城市标记')

    for (const cityName of HOT_CITIES) {
      const coord = CITY_COORDINATES[cityName]
      if (!coord) {
        console.warn(`[MapView] 未找到城市坐标: ${cityName}`)
        continue
      }

      // 跳过当前城市（避免重复标记）
      if (cityName === this.currentLocation) {
        continue
      }

      try {
        const markerOptions: mapCommon.MarkerOptions = {
          position: {
            latitude: coord.lat,
            longitude: coord.lng
          },
          title: cityName,
          snippet: '点击查看花粉信息',
          clickable: true,
          alpha: 0.9
        }

        const marker = await this.mapController.addMarker(markerOptions)
        this.cityMarkers.set(cityName, marker)
        
        console.info(`[MapView] 添加城市标记成功: ${cityName}`)
      } catch (err) {
        console.error(`[MapView] 添加城市标记失败: ${cityName}`, JSON.stringify(err))
      }
    }

    console.info(`[MapView] 热门城市标记添加完成，共 ${this.cityMarkers.size} 个`)
  }

  // 处理标记点击事件
  async handleMarkerClick(marker: map.Marker): Promise<void> {
    try {
      const title = marker.getTitle()
      console.info(`[MapView] 标记被点击: ${title}`)

      // 如果是当前位置标记，不处理
      if (title === this.currentLocation) {
        return
      }

      // 触发震动反馈
      if (this.vibrationEnabled) {
        try {
          vibrator.startVibration({
            type: 'time',
            duration: 30
          }, {
            id: 0,
            usage: 'touch'
          })
        } catch (e) {
          // 忽略震动错误
        }
      }

      // 获取城市坐标
      const coord = CITY_COORDINATES[title]
      if (!coord) {
        console.warn(`[MapView] 未找到城市坐标: ${title}`)
        return
      }

      // 更新全局位置数据（触发其他页面数据刷新）
      AppStorage.setOrCreate('latitude', coord.lat)
      AppStorage.setOrCreate('longitude', coord.lng)
      AppStorage.setOrCreate('currentCity', title)

      // 移动相机到该城市
      await this.moveCameraToLocation(coord.lat, coord.lng, 11)

      // 显示提示
      promptAction.showToast({
        message: `已切换到 ${title}`,
        duration: 2000
      })

      console.info(`[MapView] 成功切换到城市: ${title}`)
    } catch (err) {
      console.error('[MapView] 处理标记点击失败:', JSON.stringify(err))
    }
  }

  // 根据花粉等级获取颜色
  getPollenLevelColor(level: string): string {
    switch (level) {
      case '极低': return '#4CAF50'  // 绿色
      case '低': return '#8BC34A'    // 浅绿
      case '中等': return '#FF9800'  // 橙色
      case '高': return '#F44336'    // 红色
      case '极高': return '#9C27B0'  // 紫色
      default: return '#9E9E9E'      // 灰色
    }
  }

  // 定位到当前位置(重新获取GPS定位)
  async locateToCurrentPosition(): Promise<void> {
    try {
      const location = await this.locationService.getCurrentLocation()
      if (location) {
        // 更新全局坐标(会触发 onLocationChanged)
        AppStorage.setOrCreate('latitude', location.latitude)
        AppStorage.setOrCreate('longitude', location.longitude)

        console.info('[MapView] GPS定位成功:', location.latitude, location.longitude)
        // 注意: 城市名由 PollenIndexView 的 loadPollenData 自动更新
      }
    } catch (err) {
      console.error('[MapView] GPS定位失败:', JSON.stringify(err))
    }
  }

  build() {
    Stack() {
      // 华为地图组件(全屏显示)
      if (this.mapOptions) {
        MapComponent({
          mapOptions: this.mapOptions,
          mapCallback: this.callback
        })
          .width('100%')
          .height('100%')
          .hitTestBehavior(HitTestMode.Transparent) // 允许事件穿透到上层按钮
      }

      // 顶部毛玻璃信息卡片
      this.TopInfoCard()

      // 自定义定位按钮（智感握姿适配）
      this.customLocationButton()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .clip(false)  // 允许子组件超出 Stack 范围（防止按钮被裁剪）
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean) => {
      if (isVisible) {
        console.info('[MapView] 页面可见 - 开始同步数据')

        // 重新启动握姿检测（仅在应用前台时）
        if (!this.isAppInBackground) {
          this.setupGripDetection()
        } else {
          console.info('[MapView] 应用在后台，跳过启动握姿监听')
        }

        // 强制从 AppStorage 读取最新数据
        const newLat = AppStorage.get<number>('latitude')
        const newLng = AppStorage.get<number>('longitude')

        console.info(`[MapView] AppStorage读取: (${newLat}, ${newLng})`)
        console.info(`[MapView] 当前组件值: (${this.latitude}, ${this.longitude})`)

        // 手动同步 @StorageLink
        if (newLat !== undefined && newLat !== this.latitude) {
          this.latitude = newLat
          console.info('[MapView] 同步latitude:', newLat)
        }
        if (newLng !== undefined && newLng !== this.longitude) {
          this.longitude = newLng
          console.info('[MapView] 同步longitude:', newLng)
        }

        // 重置防抖标志，确保地图可以跳转
        this.isUpdating = false

        // 如果地图已初始化且数据有变化，触发地图跳转
        if (this.mapReady && this.mapController && newLat !== undefined && newLng !== undefined) {
          console.info('[MapView] 触发地图跳转')
          // 添加延迟确保地图完全渲染
          setTimeout(() => {
            this.moveCameraToLocation(newLat, newLng)
          }, 300)
        }

        // 页面可见时触发动画
        setTimeout(() => {
          this.getUIContext().animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
            this.isAnimating = true
          })
        }, 50)
      } else {
        // 页面不可见时停止监听
        console.info('[MapView] 页面不可见 - 停止握姿监听')
        
        // 停止握姿检测（节省电量）
        this.stopGripDetection()
        this.isAnimating = false
      }
    })
  }

  // ========== 顶部毛玻璃信息卡片 ==========
  @Builder
  TopInfoCard() {
    Column({ space: 8 }) {
      // 位置信息
      Row({ space: 8 }) {
        Image($r('app.media.icon_location'))
          .width(16)
          .height(16)
          .fillColor($r('app.color.text_primary'))
        Text(this.currentLocation)
          .fontSize(15)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(500)
      }
      .width('100%')

      // 花粉等级
      Row({ space: 8 }) {
        SymbolGlyph($r('sys.symbol.leaf'))
          .fontSize(16)
          .fontColor([$r('app.color.text_primary')])
        Text(`花粉等级: ${this.pollenLevel}`)
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))
        Text(`(${this.pollenValue} 粒/km³)`)
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')

      // 更新时间
      Row({ space: 8 }) {
        SymbolGlyph($r('sys.symbol.calendar'))
          .fontSize(16)
          .fontColor([$r('app.color.text_primary')])
        Text(`更新: ${this.updateTime}`)
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
    }
    .width('calc(100% - 32vp)')
    .padding({
      top: 12,
      bottom: 12,
      left: 20,
      right: 20
    })
    .backdropBlur(20)
    .backgroundColor($r('app.color.card_background'))
    .opacity(0.95)
    .borderRadius(16)
    .shadow({
      radius: 12,
      color: $r('app.color.divider_color'),
      offsetY: 4
    })
    .position({ x: 16, y: this.safeTop + 12 })
    .zIndex(10)
    // 入场动画：从上往下滑入
    .opacity(this.isAnimating ? 1 : 0)
    .translate({ y: this.isAnimating ? 0 : -20 })
    .animation({
      duration: 300,
      curve: Curve.EaseOut,
      delay: 0
    })
  }

  // ========== 定位按钮点击处理（优化：快速响应）==========
  private async handleCustomLocationClick() {
    if (this.isLocating) {
      return  // 防止重复点击
    }

    // 震动反馈
    if (this.vibrationEnabled) {
      try {
        vibrator.startVibration({ type: 'time', duration: 15 }, { usage: 'touch' })
      } catch (err) {
        const error = err as Error
        console.error(`[MapView] 震动反馈失败: ${error.message}`)
      }
    }

    this.isLocating = true
    const startTime = Date.now()
    
    try {
      // 1. 优先使用缓存位置（毫秒级响应）
      const cachedLocation = this.locationService.getCachedLocation()
      if (cachedLocation) {
        // 立即更新 UI
        AppStorage.setOrCreate('latitude', cachedLocation.latitude)
        AppStorage.setOrCreate('longitude', cachedLocation.longitude)
        if (cachedLocation.city && cachedLocation.city !== '当前位置') {
          AppStorage.setOrCreate('currentCity', cachedLocation.city)
        }
        // 移动地图
        this.moveCameraToLocation(cachedLocation.latitude, cachedLocation.longitude)
        
        console.info(`[MapView] ⚡ 使用缓存位置 (${Date.now() - startTime}ms)`)
        
        // 后台获取更精确位置
        this.updateLocationInBackground()
        
        promptAction.showToast({
          message: '定位成功',
          duration: 1000
        })
        this.isLocating = false
        return
      }

      // 2. 快速定位（基站优先，2秒内返回）
      const location = await this.locationService.getQuickLocation()
      if (location) {
        // 更新 AppStorage（触发同步更新）
        AppStorage.setOrCreate('latitude', location.latitude)
        AppStorage.setOrCreate('longitude', location.longitude)
        if (location.city && location.city !== '当前位置') {
          AppStorage.setOrCreate('currentCity', location.city)
        }
        // 移动地图
        this.moveCameraToLocation(location.latitude, location.longitude)

        console.info(`[MapView] ⚡ 快速定位成功 (${Date.now() - startTime}ms)`)
        promptAction.showToast({
          message: '定位成功',
          duration: 1000
        })
      } else {
        promptAction.showToast({
          message: '定位失败，请检查权限设置',
          duration: 2000
        })
      }
    } catch (error) {
      console.error(`[MapView] 定位失败: ${error}`)
      promptAction.showToast({
        message: '定位异常',
        duration: 2000
      })
    } finally {
      this.isLocating = false
    }
  }

  // 后台更新更精确位置
  private updateLocationInBackground(): void {
    setTimeout(async () => {
      try {
        const location = await this.locationService.getCurrentLocation()
        if (location) {
          AppStorage.setOrCreate('latitude', location.latitude)
          AppStorage.setOrCreate('longitude', location.longitude)
          if (location.city && location.city !== '当前位置') {
            AppStorage.setOrCreate('currentCity', location.city)
          }
          console.info('[MapView] 🔄 后台位置已更新')
        }
      } catch (e) {
        console.warn('[MapView] 后台更新位置失败')
      }
    }, 100)
  }

  // ========== 自定义定位浮动按钮 ==========
  @Builder
  customLocationButton() {
    Button({ type: ButtonType.Circle }) {
      if (this.isLocating) {
        // 加载状态：显示旋转图标
        LoadingProgress()
          .width(20)
          .height(20)
          .color(this.pollenThemeColor)
      } else {
        // 正常状态：显示定位图标
        Image($r('app.media.icon_location'))
          .width(24)
          .height(24)
          .fillColor(this.pollenThemeColor)
      }
    }
    .width(48)
    .height(48)
    .backgroundColor($r('app.color.card_background'))
    .shadow({
      radius: 12,
      color: $r('app.color.divider_color'),
      offsetY: 4
    })
    .enabled(!this.isLocating)
    .onClick(() => this.handleCustomLocationClick())
    .onTouch((event: TouchEvent) => {
      // 按下缩放效果
      if (event.type === TouchType.Down) {
        animateTo({ duration: 100, curve: Curve.Sharp }, () => {
          this.buttonX = this.buttonX - 2  // 轻微缩小（通过位置模拟）
        })
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        animateTo({ duration: 100, curve: Curve.Sharp }, () => {
          this.buttonX = this.holdingHand === 'LEFT' ? 16 : 
            (px2vp(display.getDefaultDisplaySync().width) - 64)
        })
      }
    })
    .position({
      x: this.buttonX,
      y: this.buttonY
    })
    .zIndex(100)
  }
}
