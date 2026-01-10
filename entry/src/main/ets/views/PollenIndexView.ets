/**
 * 花粉指数页面 - Tab1 首页
 * 显示花粉浓度环形图、7天趋势、天气信息
 */

import { PollenService } from '../service/PollenService'
import { LocationService, LocationInfo } from '../service/LocationService'
import { WeatherService, WeatherResponse } from '../service/WeatherService'
import { SeasonHelper, OffSeasonContent } from '../utils/SeasonHelper'
import { vibrator } from '@kit.SensorServiceKit'
import { ConfigurationConstant } from '@kit.AbilityKit'
import {
  PollenForecastResponse,
  DailyInfo,
  PollenLevel,
  levelToText,
  levelToColor,
  formatDateShort,
  getMaxPollenFromDaily,
  getMaxPollenIndexFromDaily,
  getHealthRecommendationsFromDaily
} from '../model/PollenModels'

@Component
export struct PollenIndexView {
  // 使用 StorageLink 共享数据给其他页面
  @StorageLink('currentCity') @Watch('onCityChange') currentCity: string = '定位中...'
  @StorageLink('pollenValue') pollenValue: number = 0
  @StorageLink('pollenLevel') pollenLevel: string = '加载中...'
  @StorageLink('updateTime') updateTime: string = '正在获取数据...'
  @State pollenLevelEnum: PollenLevel = PollenLevel.NONE
  @State isScrolled: boolean = false
  @State isAnimating: boolean = false
  @State isLoading: boolean = true
  @State errorMessage: string = ''
  @State isLocating: boolean = true
  @State healthTips: string[] = []
  @State isPollenSeason: boolean = SeasonHelper.isPollenSeason()
  @State offSeasonContent: OffSeasonContent | null = null
  @State isGuideExpanded: boolean = false  // 防护指南展开状态
  @State showGuideSheet: boolean = false   // 半屏弹窗显示状态
  @State dataSwiperIndex: number = 0       // 数据Swiper当前页索引
  // 长按预览状态
  @State previewVisible: boolean = false
  @State previewData: PreviewData = { title: '', value: '', desc: '', extra: '' }
  @StorageLink('safeTop') safeTop: number = 44
  @StorageLink('safeBottom') safeBottom: number = 28
  @StorageLink('pollenThemeColor') pollenThemeColor: string = '#4CAF50'  // 花粉主题色
  @StorageLink('currentColorMode') currentColorMode: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET

  // 服务
  private pollenService: PollenService = PollenService.getInstance()
  private locationService: LocationService = LocationService.getInstance()
  private weatherService: WeatherService = WeatherService.getInstance()

  // 当前位置（默认广州）
  @StorageLink('latitude') latitude: number = 23.1291
  @StorageLink('longitude') longitude: number = 113.2644

  // 天气数据
  @State weatherData: WeatherItem[] = [
    { icon: $r('app.media.icon_temperature'), value: '24°C', label: '温度' },
    { icon: $r('app.media.icon_temperature'), value: '23°C', label: '体感' },
    { icon: $r('app.media.icon_wind'), value: '4.0m/s', label: '风力' },
    { icon: $r('app.media.icon_arrow_up'), value: '24°C', label: '最高' },
    { icon: $r('app.media.icon_arrow_down'), value: '24°C', label: '最低' },
    { icon: $r('app.media.icon_pressure'), value: '1018', label: '气压(帕)' },
    { icon: $r('app.media.icon_humidity'), value: '43%', label: '湿度' },
    { icon: $r('app.media.icon_sunrise'), value: '06:54', label: '日出' },
    { icon: $r('app.media.icon_sunset'), value: '17:41', label: '日落' }
  ]

  // 7天趋势数据
  @State trendData: TrendItem[] = []
  
  // 本月趋势数据（从 API 数据提取）
  @State monthlyData: MonthDataItem[] = []

  private scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    // 初始化季节状态
    this.isPollenSeason = SeasonHelper.isPollenSeason()
    if (!this.isPollenSeason) {
      this.offSeasonContent = SeasonHelper.getOffSeasonContent()
    }
    this.initLocation()
  }

  // 初始化位置（优化：快速响应）
  async initLocation(): Promise<void> {
    this.isLocating = true
    const startTime = Date.now()

    try {
      // 1. 优先使用缓存位置（毫秒级响应）
      const cachedLocation = this.locationService.getCachedLocation()
      if (cachedLocation) {
        this.latitude = cachedLocation.latitude
        this.longitude = cachedLocation.longitude
        this.currentCity = cachedLocation.city || '当前位置'
        this.isLocating = false
        console.info(`[PollenIndexView] ⚡ 使用缓存位置 (${Date.now() - startTime}ms)`)
        // 先加载数据，后台更新位置
        this.loadPollenData()
        this.updateLocationInBackground()
        return
      }

      // 2. 检查并请求权限
      const hasPermission = await this.locationService.checkAndRequestPermission()

      if (hasPermission) {
        // 3. 快速定位（优先基站，2秒内返回）
        const location = await this.locationService.getQuickLocation()

        if (location !== null) {
          this.latitude = location.latitude
          this.longitude = location.longitude
          this.currentCity = location.city || '当前位置'
          console.info(`[PollenIndexView] ⚡ 快速定位成功 (${Date.now() - startTime}ms): ${this.currentCity}`)
        } else {
          // 使用默认位置
          const defaultLocation = this.locationService.getDefaultLocation()
          this.latitude = defaultLocation.latitude
          this.longitude = defaultLocation.longitude
          this.currentCity = defaultLocation.city
          console.warn(`[PollenIndexView] 定位失败，使用默认位置 (${Date.now() - startTime}ms)`)
        }
        
        // 订阅位置更新（城市名异步回调）
        this.subscribeLocationUpdates()
      } else {
        // 无权限，使用默认位置
        const defaultLocation = this.locationService.getDefaultLocation()
        this.latitude = defaultLocation.latitude
        this.longitude = defaultLocation.longitude
        this.currentCity = defaultLocation.city
        console.warn('[PollenIndexView] 无位置权限，使用默认位置')
      }
    } catch (error) {
      console.error('[PollenIndexView] 定位异常: ' + JSON.stringify(error))
      // 使用默认位置
      const defaultLocation = this.locationService.getDefaultLocation()
      this.latitude = defaultLocation.latitude
      this.longitude = defaultLocation.longitude
      this.currentCity = defaultLocation.city
    }

    this.isLocating = false
    
    // 加载花粉数据
    this.loadPollenData()
  }

  // 后台更新位置
  private updateLocationInBackground(): void {
    this.locationService.checkAndRequestPermission().then((hasPermission) => {
      if (hasPermission) {
        this.subscribeLocationUpdates()
      }
    })
  }

  // 订阅位置更新
  private subscribeLocationUpdates(): void {
    this.locationService.onLocationChange((location) => {
      // 只更新城市名（坐标变化小时不重新加载数据）
      if (location.city && location.city !== '当前位置' && location.city !== this.currentCity) {
        console.info(`[PollenIndexView] 📍 城市名更新: ${location.city}`)
        this.currentCity = location.city
      }
    })
  }

  // 城市变化时重新加载数据
  onCityChange(): void {
    console.info('[PollenIndexView] 城市变化: ' + this.currentCity)
    if (this.currentCity !== '定位中...' && this.currentCity !== '') {
      this.loadPollenData()
    }
  }

  // 加载花粉数据（优化：天气先返回，花粉静默刷新）
  async loadPollenData(): Promise<void> {
    this.isLoading = true
    this.errorMessage = ''

    try {
      // 第一步：快速刷新天气数据（约300ms）
      const weatherPromise = this.weatherService.getWeather(this.latitude, this.longitude)
      
      // 第二步：花粉数据后台静默请求（不阻塞UI）
      const pollenPromise = this.pollenService.getPollenForecast(this.latitude, this.longitude, 5)
      
      // 先等天气数据返回，快速结束刷新动画
      const weatherResponse: WeatherResponse | null = await weatherPromise
      
      // 天气数据到达后立即更新UI并结束刷新
      if (weatherResponse !== null) {
        this.weatherData = [
          { icon: $r('app.media.icon_temperature'), value: `${weatherResponse.temperature}°C`, label: '温度' },
          { icon: $r('app.media.icon_temperature'), value: `${weatherResponse.feelsLike}°C`, label: '体感' },
          { icon: $r('app.media.icon_wind'), value: `${weatherResponse.windSpeed}m/s`, label: '风力' },
          { icon: $r('app.media.icon_arrow_up'), value: weatherResponse.tempMax ? `${weatherResponse.tempMax}°C` : '--', label: '最高' },
          { icon: $r('app.media.icon_arrow_down'), value: weatherResponse.tempMin ? `${weatherResponse.tempMin}°C` : '--', label: '最低' },
          { icon: $r('app.media.icon_pressure'), value: `${weatherResponse.pressure}`, label: '气压(帕)' },
          { icon: $r('app.media.icon_humidity'), value: `${weatherResponse.humidity}%`, label: '湿度' },
          { icon: $r('app.media.icon_sunrise'), value: weatherResponse.sunrise, label: '日出' },
          { icon: $r('app.media.icon_sunset'), value: weatherResponse.sunset, label: '日落' }
        ]
        console.info('[PollenIndexView] 天气数据快速刷新完成')
      }
      
      // 🔴 关键：天气刷新后立即结束刷新动画，提升用户体感
      this.isLoading = false
      this.updateTime = '刚刚更新'
      
      // 第三步：静默等待花粉数据（后台更新，不影响用户操作）
      const pollenResponse: PollenForecastResponse | null = await pollenPromise
      console.info('[PollenIndexView] 花粉响应: ' + JSON.stringify(pollenResponse))

      // 处理花粉数据
      if (pollenResponse !== null) {
        // 初始化趋势数据
        const newTrend: TrendItem[] = []
        
        // 处理花粉数据
        if (pollenResponse.dailyInfo && pollenResponse.dailyInfo.length > 0) {
          // 解析今日数据
          const todayInfo: DailyInfo = pollenResponse.dailyInfo[0]
          this.pollenValue = getMaxPollenIndexFromDaily(todayInfo)
          this.pollenLevelEnum = getMaxPollenFromDaily(todayInfo)
          this.healthTips = getHealthRecommendationsFromDaily(todayInfo)
          
          // 更新全局主题色
          AppStorage.setOrCreate('pollenThemeColor', levelToColor(this.pollenLevelEnum))
          
          // 判断是否有有效数据
          if (this.pollenValue > 0) {
            this.pollenLevel = levelToText(this.pollenLevelEnum)
            this.updateTime = '刚刚更新'
          } else {
            // 冬季或无花粉季节 - 数据正常但无花粉活动
            this.pollenLevel = '极低'
            this.updateTime = '非花粉季'
          }
          
          // 解析趋势数据
          for (let i = 0; i < pollenResponse.dailyInfo.length; i++) {
            const dayInfo: DailyInfo = pollenResponse.dailyInfo[i]
            const dateLabel = formatDateShort(dayInfo.date)
            const indexValue = getMaxPollenIndexFromDaily(dayInfo)
            
            // 添加调试日志
            console.info(`[DEBUG] 第${i+1}天: date=${dateLabel}, indexValue=${indexValue}`)
            
            const item: TrendItem = {
              date: dateLabel,
              value: indexValue > 0 ? indexValue : 0
            }
            newTrend.push(item)
          }
          
          // 如果没有有效的趋势数据，生成占位数据
          if (newTrend.length === 0) {
            console.info('[DEBUG] 生成占位趋势数据')
            for (let i = 0; i < 5; i++) {
              const today = new Date()
              today.setDate(today.getDate() + i)
              const dateLabel = `${today.getMonth() + 1}/${today.getDate()}`
              newTrend.push({ date: dateLabel, value: 0 })
            }
          }
          
          console.info(`[DEBUG] 最终趋势数据: ${JSON.stringify(newTrend)}`)
        } else {
          // 无每日数据，但响应有效
          this.pollenValue = 0
          this.pollenLevel = '极低'
          // updateTime 已在天气刷新时设置，此处不覆盖
          
          // 生成占位趋势数据
          console.info('[DEBUG] 无每日数据，生成占位趋势数据')
          for (let i = 0; i < 5; i++) {
            const today = new Date()
            today.setDate(today.getDate() + i)
            const dateLabel = `${today.getMonth() + 1}/${today.getDate()}`
            newTrend.push({ date: dateLabel, value: 0 })
          }
        }
        
        this.trendData = newTrend
        
        // 更新本月趋势数据（从 trendData 提取）
        this.updateMonthlyData(newTrend)
        
        console.info(`[DEBUG] 花粉数据静默更新完成，趋势数据长度: ${newTrend.length}`)
        
        // 🔴 天气数据已在前面处理，这里不再重复处理
        // 🔴 isLoading 已在天气刷新后设为 false，这里不再设置
      } else {
        // 花粉响应为null，静默失败不影响用户
        console.warn('[PollenIndexView] 花粉数据获取失败，使用默认数据')
        this.pollenValue = 0
        this.pollenLevel = '极低'
        this.trendData = [
          { date: '暂无', value: 0 },
          { date: '数据', value: 0 }
        ]
        // 不设置 isLoading，因为天气已刷新成功
      }
    } catch (error) {
      console.error('[PollenIndexView] 加载数据失败: ' + JSON.stringify(error))
      // 只有刷新动画还在时才结束
      if (this.isLoading) {
        this.isLoading = false
        this.errorMessage = '数据加载失败，请检查网络'
        this.updateTime = '获取失败'
      }
      // 使用默认数据
      this.pollenValue = 0
      this.pollenLevel = '极低'
      const defaultTrend: TrendItem[] = [
        { date: '暂无', value: 0 },
        { date: '数据', value: 0 }
      ]
      this.trendData = defaultTrend
    }
  }

  // 格式化更新时间
  formatUpdateTime(year: number, month: number, day: number): string {
    const now = new Date()
    const dataDate = new Date(year, month - 1, day)
    const diffMs = now.getTime() - dataDate.getTime()
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60))

    if (diffHours < 1) {
      return '刚刚更新'
    } else if (diffHours < 24) {
      return `${diffHours} 小时前`
    } else {
      const diffDays = Math.floor(diffHours / 24)
      return `${diffDays} 天前`
    }
  }

  build() {
    Column() {  // 改用 Column 作为根容器，避免导航栏遮挡刷新指示器
      // 固定顶部导航栏（始终位于顶部）
      this.TopNavBar()

      // 下拉刷新包裹器（自定义空白刷新指示器，使用导航栏的 LoadingProgress）
      Refresh({ refreshing: $$this.isLoading, builder: this.customRefreshingContent }) {
        // 可滚动内容
        Scroll(this.scroller) {
          Column() {
            // 主卡片 - 花粉浓度环形图
            this.PollenMainCard()

            // 数据总览 Swiper（5天预报 + 本月趋势 + 全年趋势）
            this.DataOverviewSwiper()

            // 防护指南
            this.HealthGuideSection()

            // 天气情况
            this.WeatherSection()

            // 底部间距（TabBar高度 + 安全距离 + 额外间距）
            Blank().height(56 + this.safeBottom + 16)
          }
          .width('100%')
          .padding({ 
            top: this.safeTop + 48,  // 状态栏高度 + 导航栏高度
            left: 16, 
            right: 16 
          })
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .onDidScroll(() => {
          const yOffset = this.scroller.currentOffset().yOffset
          this.isScrolled = yOffset > 20
        })
      }
      .onRefreshing(() => {
        this.loadPollenData()
      })
      .pullToRefresh(true)
      .layoutWeight(1)  // 关键：占据剩余空间
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
        // 强制停止加载动画（避免后台资源占用）
        if (this.isLoading) {
          this.isLoading = false
        }
      }
    })
  }

  // ========== 自定义空白刷新指示器（隐藏默认图标） ==========
  @Builder
  customRefreshingContent() {
    // 空内容，不显示任何刷新图标
  }

  // ========== 顶部导航栏 ==========
  @Builder
  TopNavBar() {
    Column() {
      // 状态栏占位
      Row()
        .height(this.safeTop)
        .width('100%')

      // 导航栏内容
      Row() {
        // 左侧：位置图标和城市名
        Row() {
          Image($r('app.media.icon_location'))
            .width(18)
            .height(18)
            .fillColor($r('app.color.icon_primary'))
            .accessibilityText('定位图标')
          Text(this.currentCity)
            .fontSize(17)
            .fontColor($r('app.color.text_primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ left: 6 })
            .accessibilityText(`当前城市：${this.currentCity}`)
          
          // 加载指示器（数据加载中时显示）
          if (this.isLoading) {
            LoadingProgress()
              .width(16)
              .height(16)
              .color($r('app.color.icon_primary'))
              .margin({ left: 8 })
              .accessibilityText('数据加载中')
          }
        }
        .accessibilityText(`当前位置：${this.currentCity}${this.isLoading ? '，正在加载数据' : ''}`)
        .accessibilityGroup(true)
        
        // 中间空白区域
        Blank()
        
        // 右侧：数据来源感谢信息
        Text('感谢北京敏舒科技有限责任公司对数据的支持')
          .fontSize(10)
          .fontColor(this.getDataSourceTextColor())
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .opacity(0.8)
          .width('45%')  // 设置固定宽度，避免挤压城市名
          .textAlign(TextAlign.End)  // 右对齐
          .accessibilityText('数据来源：感谢北京敏舒科技有限责任公司对数据的支持')
      }
      .width('100%')
      .height(48)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .position({ x: 0, y: 0 })
    .zIndex(999)  // 确保导航栏始终在最上层，避免滚动内容遮挡
    // 浅色半透明背景 + 毛玻璃效果（适配深色状态栏图标）
    .backgroundColor($r('app.color.navbar_background'))
    .backdropBlur(40)
    .border({
      width: { bottom: 0.5 },
      color: $r('app.color.navbar_border')
    })
    .shadow({
      radius: 10,
      color: 'rgba(0, 0, 0, 0.06)',
      offsetY: 2
    })
  }

  // ========== 主花粉卡片 ==========
  @Builder
  PollenMainCard() {
    Column() {
      // 环形进度条区域
      Stack() {
        // 背景圆环
        Circle()
          .width(180)
          .height(180)
          .fill(Color.Transparent)
          .stroke('#333333')
          .strokeWidth(12)

        // 进度圆环（根据花粉等级显示颜色）
        Circle()
          .width(180)
          .height(180)
          .fill(Color.Transparent)
          .stroke(this.getLevelColor())
          .strokeWidth(12)
          .strokeDashArray([this.getProgressLength(), 565])
          .rotate({ angle: -90 })

        // 中心内容
        Column() {
          Row() {
            Text('☀️')
              .fontSize(24)
            Text(this.pollenValue.toString())
              .fontSize(48)
              .fontColor($r('app.color.text_primary'))
              .fontWeight(FontWeight.Bold)
              .margin({ left: 4 })
          }

          Text('粒/km³')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 4 })

          Text(this.pollenLevel)
            .fontSize(18)
            .fontColor(this.getLevelColor())
            .fontWeight(FontWeight.Medium)
            .margin({ top: 8 })
        }
        .accessibilityText(`当前花粉浓度${this.pollenValue}粒每立方千米，${this.pollenLevel}级别`)
        .accessibilityGroup(true)
      }
      .width(200)
      .height(200)
      .margin({ top: 20 })

      // 更新时间
      Text(this.updateTime)
        .fontSize(13)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 16 })
        .accessibilityText(`数据更新时间：${this.updateTime}`)

      // 非花粉季提示
      if (this.pollenValue === 0 && this.updateTime === '非花粉季') {
        Text('当前为非花粉季，花粉活动极低，适合户外活动')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8, bottom: 20 })
          .textAlign(TextAlign.Center)
          .width('80%')
      } else {
        Blank().height(20)
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .padding({ top: 20, bottom: 20 })
    .margin({ top: 16 })
    // 卡片入场动画（性能优化）
    .opacity(this.isAnimating ? 1 : 0)
    .translate({ x: this.isAnimating ? 0 : 60 })
    .animation({
      duration: 280,
      delay: 0,
      curve: Curve.EaseOut
    })
  }

  // ========== 数据总览 Swiper（5天预报 + 本月趋势 + 全年趋势） ==========
  @Builder
  DataOverviewSwiper() {
    Stack() {
      Column() {
        // 顶部 Tab 指示器
        Row({ space: 0 }) {
          ForEach(['5天预报', '本月趋势', '全年趋势'], (tab: string, index: number) => {
            Column() {
              Text(tab)
                .fontSize(14)
                .fontColor(this.dataSwiperIndex === index ? this.pollenThemeColor : $r('app.color.text_secondary'))
                .fontWeight(this.dataSwiperIndex === index ? FontWeight.Medium : FontWeight.Normal)
              
              // 下划线指示器
              Row()
                .width(this.dataSwiperIndex === index ? 24 : 0)
                .height(3)
                .backgroundColor('#4CAF50')
                .borderRadius(2)
                .margin({ top: 6 })
                .animation({ duration: 200, curve: Curve.EaseOut })
            }
            .layoutWeight(1)
            .accessibilityText(`${tab}${this.dataSwiperIndex === index ? '，已选中' : ''}，双击切换`)
            .onClick(() => {
              this.dataSwiperIndex = index
            })
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 8 })
        .accessibilityText('数据查看选项卡，当前显示' + ['5天预报', '本月趋势', '全年趋势'][this.dataSwiperIndex])

        // Swiper 内容区
        Swiper() {
          // 第1页：5天预报
          this.FiveDayForecastPage()
          
          // 第2页：本月趋势
          this.MonthlyTrendPage()
          
          // 第3页：全年趋势
          this.YearlyTrendPage()
        }
        .index(this.dataSwiperIndex)
        .indicator(false)
        .loop(false)
        .onChange((index: number) => {
          this.dataSwiperIndex = index
        })
        .height(240)
      }
      .width('100%')

      // 长按预览浮窗
      if (this.previewVisible) {
        Column() {
          Text(this.previewData.title)
            .fontSize(13)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
          Text(this.previewData.value)
            .fontSize(22)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .margin({ top: 4 })
          Text(this.previewData.desc)
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.8)')
            .margin({ top: 4 })
          if (this.previewData.extra.length > 0) {
            Text(this.previewData.extra)
              .fontSize(11)
              .fontColor('rgba(255,255,255,0.7)')
              .margin({ top: 4 })
          }
        }
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('rgba(0,0,0,0.85)')
        .borderRadius(12)
        .shadow({ radius: 20, color: 'rgba(0,0,0,0.3)', offsetY: 4 })
        .animation({ duration: 150, curve: Curve.EaseOut })
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .margin({ top: 16 })
    // 卡片入场动画
    .opacity(this.isAnimating ? 1 : 0)
    .translate({ x: this.isAnimating ? 0 : 60 })
    .animation({
      duration: 280,
      delay: 80,
      curve: Curve.EaseOut
    })
  }

  // 第1页：5天预报（复用原 TrendSection 逻辑）
  @Builder
  FiveDayForecastPage() {
    Column() {
      if (this.trendData.length === 0 || this.trendData.every((item: TrendItem) => item.value === 0)) {
        // 非花粉季提示
        Column() {
          Text('🌿')
            .fontSize(40)
          Text('非花粉季')
            .fontSize(18)
            .fontColor($r('app.color.text_primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ top: 12 })
          Text('当前花粉活动极低，5天内无明显花粉预报')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 8 })
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .accessibilityText('当前为非花粉季，花粉活动极低，5天内无明显花粉预报')
      } else {
        // 柱状图
        Row() {
          ForEach(this.trendData, (item: TrendItem, index: number) => {
            Column() {
              Text(item.value.toString())
                .fontSize(11)
                .fontColor(item.value > 0 ? this.pollenThemeColor : '#808080')
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 4 })
              
              Column()
                .width(32)
                .height(Math.max(8, item.value * 1.5))
                .backgroundColor(item.value > 0 ? this.pollenThemeColor : '#E0E0E0')
                .borderRadius(6)

              Text(item.date)
                .fontSize(11)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 8 })
            }
            .justifyContent(FlexAlign.End)
            .height(160)
            .accessibilityText(`${item.date}，花粉浓度${item.value}粒每立方千米，长按查看详情`)
            .gesture(
              LongPressGesture({ repeat: false, duration: 220 })
                .onAction(() => {
                  this.triggerVibration()
                  this.showDayPreview(item, index)
                })
                .onActionEnd(() => {
                  this.previewVisible = false
                })
            )
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      }
    }
    .width('100%')
    .height('100%')
  }

  // 第2页：本月趋势（30天折线图概念）
  @Builder
  MonthlyTrendPage() {
    Column() {
      // 月份标题
      Row() {
        Text(this.getCurrentMonthName())
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        
        Blank()
        
        Text('长按查看详情')
          .fontSize(11)
          .fontColor($r('app.color.text_secondary'))
          .opacity(0.6)
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 })

      // 本月趋势曲线图
      Stack() {
        // 渐变背景区域
        Polygon({ width: '100%', height: 120 })
          .points(this.buildGradientArea(this.monthlyData.map(item => {
            const trendItem: TrendItem = { date: item.label, value: item.value }
            return trendItem
          }), 120, 1.2))
          .fill('#42A5F5')
          .opacity(0.15)
        
        // 曲线
        Polyline({ width: '100%', height: 120 })
          .points(this.buildCurvePath(this.monthlyData.map(item => {
            const trendItem: TrendItem = { date: item.label, value: item.value }
            return trendItem
          }), 120, 1.2))
          .stroke('#42A5F5')
          .strokeWidth(2.5)
          .strokeLineCap(LineCapStyle.Round)
          .strokeLineJoin(LineJoinStyle.Round)
        
        // 数据点和标签
        Row() {
          ForEach(this.getMonthlyData(), (item: MonthDataItem, index: number) => {
            Column() {
              // 数据点
              Circle()
                .width(6)
                .height(6)
                .fill('#42A5F5')
                .position({ y: 120 - Math.max(4, item.value * 1.2) })
              
              // 日期标签
              Text(item.label)
                .fontSize(9)
                .fontColor($r('app.color.text_secondary'))
                .position({ y: 125 })
            }
            .width('10%')
            .height(135)
            .justifyContent(FlexAlign.End)
            .gesture(
              LongPressGesture({ repeat: false, duration: 220 })
                .onAction(() => {
                  this.triggerVibration()
                  this.showMonthPreview(item, index)
                })
                .onActionEnd(() => {
                  this.previewVisible = false
                })
            )
          })
        }
        .width('100%')
        .height(135)
      }
      .width('100%')
      .height(135)
      .padding({ left: 8, right: 8 })

      // 本月统计
      Row() {
        Column() {
          Text('本月均值')
            .fontSize(11)
            .fontColor($r('app.color.text_secondary'))
          Text(this.isPollenSeason ? '32' : '0')
            .fontSize(16)
            .fontColor('#42A5F5')
            .fontWeight(FontWeight.Medium)
        }
        
        Column() {
          Text('最高值')
            .fontSize(11)
            .fontColor($r('app.color.text_secondary'))
          Text(this.isPollenSeason ? '68' : '0')
            .fontSize(16)
            .fontColor(this.pollenThemeColor)
            .fontWeight(FontWeight.Medium)
        }
        
        Column() {
          Text('适宜外出')
            .fontSize(11)
            .fontColor($r('app.color.text_secondary'))
          Text(this.isPollenSeason ? '18天' : '30天')
            .fontSize(16)
            .fontColor('#4CAF50')
            .fontWeight(FontWeight.Medium)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .padding({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .padding({ top: 8 })
  }

  // 第3页：全年趋势（静态数据，永远可用）
  @Builder
  YearlyTrendPage() {
    Column() {
      // 年份标题
      Row() {
        Text('2025年花粉趋势')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        
        Blank()
        
        Row() {
          Circle().width(6).height(6).fill(this.pollenThemeColor)
          Text('高峰期')
            .fontSize(10)
            .fontColor($r('app.color.text_secondary'))
            .margin({ left: 4 })
          
          Circle().width(6).height(6).fill('#42A5F5').margin({ left: 8 })
          Text('过渡期')
            .fontSize(10)
            .fontColor($r('app.color.text_secondary'))
            .margin({ left: 4 })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 })

      // 全年趋势曲线图
      Stack() {
        // 渐变背景区域
        Polygon({ width: '100%', height: 100 })
          .points(this.buildGradientArea(this.getYearlyData().map(item => {
            const trendItem: TrendItem = { date: item.month, value: item.value }
            return trendItem
          }), 100, 1.0))
          .fill(this.pollenThemeColor)
          .opacity(0.12)
        
        // 曲线
        Polyline({ width: '100%', height: 100 })
          .points(this.buildCurvePath(this.getYearlyData().map(item => {
            const trendItem: TrendItem = { date: item.month, value: item.value }
            return trendItem
          }), 100, 1.0))
          .stroke(this.pollenThemeColor)
          .strokeWidth(2.5)
          .strokeLineCap(LineCapStyle.Round)
          .strokeLineJoin(LineJoinStyle.Round)
        
        // 数据点和标签
        Row() {
          ForEach(this.getYearlyData(), (item: YearDataItem, index: number) => {
            Column() {
              // 数据点（高峰期加大）
              Circle()
                .width(item.isPeak ? 7 : 5)
                .height(item.isPeak ? 7 : 5)
                .fill(this.pollenThemeColor)
                .position({ y: 100 - Math.max(4, item.value * 1.0) })
              
              // 月份标签
              Text(item.month)
                .fontSize(9)
                .fontColor(item.isCurrent ? this.pollenThemeColor : $r('app.color.text_secondary'))
                .fontWeight(item.isCurrent ? FontWeight.Bold : FontWeight.Normal)
                .position({ y: 105 })
            }
            .width(`${100/12}%`)
            .height(115)
            .justifyContent(FlexAlign.End)
            .gesture(
              LongPressGesture({ repeat: false, duration: 220 })
                .onAction(() => {
                  this.triggerVibration()
                  this.showYearPreview(item, index)
                })
                .onActionEnd(() => {
                  this.previewVisible = false
                })
            )
          })
        }
        .width('100%')
        .height(115)
      }
      .width('100%')
      .height(115)
      .padding({ left: 8, right: 8 })

      // 花粉季提示
      Row() {
        Text('📅')
          .fontSize(14)
        Text('春季花粉季 3-5月 | 秋季花粉季 8-10月')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .margin({ left: 6 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .padding({ top: 8 })
  }

  // 获取当前月份名称
  private getCurrentMonthName(): string {
    const month = new Date().getMonth() + 1
    return `${month}月花粉趋势`
  }

  // 获取本月数据（模拟30天，每3天一组）
  // 更新本月趋势数据（从 trendData 提取）
  private updateMonthlyData(trendData: TrendItem[]): void {
    const data: MonthDataItem[] = []
    
    // 使用 API 返回的真实数据（最多10天）
    const maxDays = Math.min(trendData.length, 10)
    for (let i = 0; i < maxDays; i++) {
      const item = trendData[i]
      data.push({ 
        label: item.date,  // 使用真实日期标签（如 "12/15"）
        value: item.value 
      })
    }
    
    // 如果数据不足10天，填充占位数据
    if (data.length < 10) {
      const today = new Date()
      for (let i = data.length; i < 10; i++) {
        const futureDate = new Date(today.getTime() + i * 24 * 60 * 60 * 1000)
        const dateLabel = `${futureDate.getMonth() + 1}/${futureDate.getDate()}`
        data.push({ 
          label: dateLabel, 
          value: 0  // 未来数据显示为0
        })
      }
    }
    
    this.monthlyData = data
  }

  private getMonthlyData(): MonthDataItem[] {
    // 直接返回从 API 提取的数据
    return this.monthlyData
  }

  // 获取全年数据（根据纬度和当前数据动态生成）
  private getYearlyData(): YearDataItem[] {
    const currentMonth = new Date().getMonth() + 1
    const currentValue = this.pollenValue  // 当前花粉浓度
    
    // 根据纬度判断气候类型
    // 南方（纬度<30°）：2-4月高峰 | 北方（纬度≥30°）：3-5月高峰
    const isSouthern = this.latitude < 30
    
    // 基础模板（相对值，0-100）
    const baseTemplate = isSouthern ? 
      // 南方：早春高峰
      [8, 60, 85, 70, 30, 15, 10, 40, 65, 50, 20, 10] :
      // 北方：春季高峰
      [5, 15, 70, 90, 75, 25, 12, 45, 70, 55, 18, 8]
    
    // 根据当前月份和实际浓度调整缩放系数
    let scaleFactor = 1.0
    if (currentValue > 0 && baseTemplate[currentMonth - 1] > 0) {
      scaleFactor = currentValue / baseTemplate[currentMonth - 1]
    }
    
    // 生成动态数据
    return baseTemplate.map((baseValue, index) => {
      const month = index + 1
      const adjustedValue = Math.round(baseValue * scaleFactor)
      const isPeak = baseValue >= 60  // 基础值≥60视为高峰期
      
      const yearItem: YearDataItem = {
        month: `${month}月`,
        value: adjustedValue,
        isPeak: isPeak,
        isCurrent: month === currentMonth
      }
      return yearItem
    })
  }

  // ========== 曲线图辅助函数 ==========
  
  // 构建曲线路径点（用于 Polyline）
  private buildCurvePath(data: TrendItem[], height: number, scale: number): Array<[number, number]> {
    const points: Array<[number, number]> = []
    const width = 100  // 百分比宽度
    const count = data.length
    
    if (count === 0) return [[0, height], [width, height]]
    
    for (let i = 0; i < count; i++) {
      const x = (width / (count - 1)) * i
      const y = height - Math.max(4, data[i].value * scale)
      points.push([x, y])
    }
    
    return points
  }
  
  // 构建渐变区域（用于 Polygon）
  private buildGradientArea(data: TrendItem[], height: number, scale: number): Array<[number, number]> {
    const points: Array<[number, number]> = []
    const width = 100
    const count = data.length
    
    if (count === 0) return [[0, height], [width, height], [width, height], [0, height]]
    
    // 左下角起点
    points.push([0, height])
    
    // 曲线顶部路径
    for (let i = 0; i < count; i++) {
      const x = (width / (count - 1)) * i
      const y = height - Math.max(4, data[i].value * scale)
      points.push([x, y])
    }
    
    // 右下角终点
    points.push([width, height])
    
    return points
  }

  // ========== 长按预览方法 ==========

  // 触发短震动反馈
  private triggerVibration(): void {
    try {
      const effect: vibrator.VibrateEffect = {
        type: 'time',
        duration: 30  // 30ms 短震动
      }
      const attribute: vibrator.VibrateAttribute = {
        usage: 'touch'
      }
      vibrator.startVibration(effect, attribute)
    } catch (e) {
      // 忽略震动失败
    }
  }
  
  // 5天预报 - 长按显示某天详情
  private showDayPreview(item: TrendItem, index: number): void {
    const today = new Date()
    const targetDate = new Date(today.getTime() + index * 24 * 60 * 60 * 1000)
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    const weekDay = weekDays[targetDate.getDay()]
    
    const levelText = item.value === 0 ? '无花粉' : 
                      item.value < 30 ? '低浓度' : 
                      item.value < 60 ? '中浓度' : '高浓度'
    
    const previewItem: PreviewData = {
      title: `${targetDate.getMonth() + 1}月${targetDate.getDate()}日 ${weekDay}`,
      value: `${item.value} 粒/km³`,
      desc: levelText,
      extra: item.value === 0 ? '适合户外活动' : item.value < 30 ? '可正常外出' : '建议做好防护'
    }
    this.previewData = previewItem
    this.previewVisible = true
  }

  // 本月趋势 - 长按显示某时段详情
  private showMonthPreview(item: MonthDataItem, index: number): void {
    const startDay = index * 3 + 1
    const endDay = Math.min((index + 1) * 3, 30)
    const month = new Date().getMonth() + 1
    
    const previewItem: PreviewData = {
      title: `${month}月${startDay}-${endDay}日`,
      value: `${item.value} 粒/km³`,
      desc: item.value === 0 ? '非花粉季' : `日均浓度`,
      extra: item.value === 0 ? '花粉活动极低' : item.value < 30 ? '花粉浓度较低' : '注意防护'
    }
    this.previewData = previewItem
    this.previewVisible = true
  }

  // 全年趋势 - 长按显示某月详情
  private showYearPreview(item: YearDataItem, index: number): void {
    const monthPollenTypes: string[] = [
      '柏树、榆树萌动',      // 1月
      '柏树、杨树初花',      // 2月
      '柏树、杨树、柳树',    // 3月 - 春季高峰
      '杨树、柳树、榆树',    // 4月 - 春季高峰
      '松树、法桐、杨絮',    // 5月 - 春季高峰
      '禾本科草类',          // 6月
      '禾本科草类',          // 7月
      '蒿草、豚草初花',      // 8月 - 秋季高峰
      '蒿草、豚草高峰',      // 9月 - 秋季高峰
      '蒿草、葎草',          // 10月 - 秋季高峰
      '花粉减少',            // 11月
      '花粉休眠期'           // 12月
    ]
    
    const previewItem: PreviewData = {
      title: item.month,
      value: item.isPeak ? '⚠️ 高峰期' : (item.value > 20 ? '📊 过渡期' : '✅ 低风险'),
      desc: `预计浓度: ${item.value}`,
      extra: `主要花粉: ${monthPollenTypes[index]}`
    }
    this.previewData = previewItem
    this.previewVisible = true
  }

  // ========== 天气情况 ==========
  @Builder
  WeatherSection() {
    Column() {
      Text('天气情况')
        .fontSize(16)
        .fontColor($r('app.color.text_primary'))
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .padding({ left: 16, bottom: 12 })

      // 3x3 网格
      Grid() {
        ForEach(this.weatherData, (item: WeatherItem) => {
          GridItem() {
            Column() {
              Image(item.icon)
                .width(24)
                .height(24)
                .fillColor(this.pollenThemeColor)
              Text(item.value)
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
                .fontWeight(FontWeight.Medium)
                .margin({ top: 6 })
              Text(item.label)
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 4 })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr')
      .width('100%')
      .height(240)
      .padding({ left: 8, right: 8 })
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .padding({ top: 16, bottom: 16 })
    .margin({ top: 16 })
    // 卡片入场动画（性能优化）
    .opacity(this.isAnimating ? 1 : 0)
    .translate({ x: this.isAnimating ? 0 : 60 })
    .animation({
      duration: 280,
      delay: 120,
      curve: Curve.EaseOut
    })
  }

  // ========== 防护指南（三层渐进式） ==========
  @Builder
  HealthGuideSection() {
    Column() {
      // 标题栏（可点击展开/折叠）
      Row() {
        Image($r('app.media.icon_shield'))
          .width(16)
          .height(16)
          .fillColor($r('app.color.icon_primary'))
        Text(this.isPollenSeason ? '防护指南' : (this.offSeasonContent?.title ?? '季节提示'))
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Medium)
          .margin({ left: 6 })
        
        Blank()
        
        // 季节标签
        Text(SeasonHelper.getSeasonDescription())
          .fontSize(11)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(10)
        
        // 展开/折叠图标
        Image($r('app.media.icon_arrow_down'))
          .width(14)
          .height(14)
          .fillColor('#757575')
          .rotate({ angle: this.isGuideExpanded ? 180 : 0 })
          .animation({ duration: 200, curve: Curve.EaseOut })
          .margin({ left: 8 })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        this.isGuideExpanded = !this.isGuideExpanded
      })

      // 防护指南内容
      Column() {
        if (this.isPollenSeason) {
          this.PollenSeasonGuide()
        } else {
          this.OffSeasonGuide()
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(16)
    .padding({ top: 16, bottom: 16 })
    .margin({ top: 16 })
    .opacity(this.isAnimating ? 1 : 0)
    .translate({ x: this.isAnimating ? 0 : 60 })
    .animation({
      duration: 280,
      delay: 40,
      curve: Curve.EaseOut
    })
    // 半屏弹窗
    .bindSheet($$this.showGuideSheet, this.GuideDetailSheet(), {
      height: SheetSize.MEDIUM,
      dragBar: true,
      showClose: true,
      title: { title: this.isPollenSeason ? '详细防护指南' : '季节健康提示' }
    })
  }

  // 花粉季防护指南（三层渐进）
  @Builder
  PollenSeasonGuide() {
    Column({ space: 8 }) {
      if (this.healthTips.length === 0) {
        // 无数据时的提示
        Text('当前空气质量良好，无特别防护建议')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .textAlign(TextAlign.Center)
          .padding(16)
      } else {
        // 第一层：精简折叠（显示前3条核心信息）
        ForEach(this.healthTips.slice(0, 3), (tip: string) => {
          Row() {
            Text(tip)
              .fontSize(14)
              .fontColor('#2E7D32')
          }
          .width('100%')
          .backgroundColor('#E8F5E9')
          .padding(12)
          .borderRadius(8)
        })

        // 第二层：展开显示剩余建议
        if (this.isGuideExpanded && this.healthTips.length > 3) {
          ForEach(this.healthTips.slice(3), (tip: string) => {
            Row() {
              Text(tip)
                .fontSize(14)
                .fontColor('#2E7D32')
            }
            .width('100%')
            .backgroundColor('#E8F5E9')
            .padding(12)
            .borderRadius(8)
          })
        }

        // 展开/收起按钮 或 查看更多按钮
        if (this.healthTips.length > 3) {
          Row() {
            Text(this.isGuideExpanded ? '收起' : `展开全部 (${this.healthTips.length}条)`)
              .fontSize(13)
              .fontColor('#4CAF50')
            Image($r('app.media.icon_arrow_down'))
              .width(12)
              .height(12)
              .fillColor('#4CAF50')
              .rotate({ angle: this.isGuideExpanded ? 180 : 0 })
              .margin({ left: 4 })
          }
          .justifyContent(FlexAlign.Center)
          .padding({ top: 8 })
          .onClick(() => {
            this.isGuideExpanded = !this.isGuideExpanded
          })
        }

        // 第三层：查看更多详情按钮
        if (this.isGuideExpanded) {
          Row() {
            Text('查看详细防护指南')
              .fontSize(13)
              .fontColor('#1976D2')
            Image($r('app.media.icon_arrow_up'))
              .width(12)
              .height(12)
              .fillColor('#1976D2')
              .margin({ left: 4 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 12, bottom: 4 })
          .onClick(() => {
            this.showGuideSheet = true
          })
        }
      }
    }
    .padding({ top: 8 })
  }

  // 非花粉季提示内容（三层渐进）
  @Builder
  OffSeasonGuide() {
    Column({ space: 12 }) {
      if (this.offSeasonContent !== null) {
        // 第一层：精简描述
        Text(this.offSeasonContent.description)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .lineHeight(22)

        // 精简提示（显示前3条）
        Column({ space: 8 }) {
          ForEach(this.offSeasonContent.tips.slice(0, this.isGuideExpanded ? this.offSeasonContent.tips.length : 3), (tip: string) => {
            Row() {
              Text(tip)
                .fontSize(14)
                .fontColor('#1565C0')
            }
            .width('100%')
            .backgroundColor('#E3F2FD')
            .padding(12)
            .borderRadius(8)
          })
        }

        // 展开/收起按钮
        if (this.offSeasonContent.tips.length > 3) {
          Row() {
            Text(this.isGuideExpanded ? '收起' : `展开全部 (${this.offSeasonContent.tips.length}条)`)
              .fontSize(13)
              .fontColor('#1976D2')
            Image($r('app.media.icon_arrow_down'))
              .width(12)
              .height(12)
              .fillColor('#1976D2')
              .rotate({ angle: this.isGuideExpanded ? 180 : 0 })
              .margin({ left: 4 })
          }
          .justifyContent(FlexAlign.Center)
          .padding({ top: 8 })
          .onClick(() => {
            this.isGuideExpanded = !this.isGuideExpanded
          })
        }

        // 下季预告（展开时显示）
        if (this.isGuideExpanded && this.offSeasonContent.nextSeasonHint.length > 0) {
          Row() {
            Image($r('app.media.icon_calendar'))
              .width(14)
              .height(14)
              .fillColor('#FF9800')
            Text(this.offSeasonContent.nextSeasonHint)
              .fontSize(12)
              .fontColor('#FF9800')
              .margin({ left: 6 })
          }
          .width('100%')
          .backgroundColor('#FFF8E1')
          .padding(10)
          .borderRadius(8)
          .margin({ top: 4 })

          // 第三层：查看更多
          Row() {
            Text('查看季节健康指南')
              .fontSize(13)
              .fontColor('#1976D2')
            Image($r('app.media.icon_arrow_up'))
              .width(12)
              .height(12)
              .fillColor('#1976D2')
              .margin({ left: 4 })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 12, bottom: 4 })
          .onClick(() => {
            this.showGuideSheet = true
          })
        }
      }
    }
    .padding({ top: 8 })
  }

  // 第三层：半屏详细指南弹窗
  @Builder
  GuideDetailSheet() {
    Scroll() {
      Column({ space: 16 }) {
        if (this.isPollenSeason) {
          // 花粉季详细指南
          this.DetailSection('🎯 核心防护要点', [
            '外出必戴口罩（N95效果最佳）',
            '佩戴护目镜或太阳镜',
            '花粉高峰期（10:00-16:00）减少外出',
            '回家后立即洗手、洗脸、清洗鼻腔'
          ])

          this.DetailSection('🏠 居家防护', [
            '关闭门窗，使用空气净化器',
            '定期清洗床单、窗帘等织物',
            '使用吸尘器清洁地面（带HEPA滤网）',
            '避免在室外晾晒衣物'
          ])

          this.DetailSection('🚗 出行建议', [
            '开车时关闭车窗，使用内循环',
            '选择清晨或雨后外出（花粉较少）',
            '避免去公园、郊外等花粉密集区',
            '随身携带抗过敏药物（遵医嘱）'
          ])

          this.DetailSection('⚠️ 注意事项', [
            '关注每日花粉浓度预报',
            '记录过敏症状，了解自己的过敏原',
            '症状严重时及时就医',
            '保持充足睡眠，增强免疫力'
          ])
        } else {
          // 非花粉季详细指南
          this.DetailSection('🌿 当前季节特点', [
            SeasonHelper.getSeasonDescription(),
            this.offSeasonContent?.description ?? ''
          ])

          this.DetailSection('💪 增强体质建议', [
            '适当户外运动，呼吸新鲜空气',
            '均衡饮食，多吃蔬果',
            '保持规律作息，充足睡眠',
            '适度锻炼，提高免疫力'
          ])

          this.DetailSection('🏠 家居清洁', [
            '趁非花粉季进行大扫除',
            '清洗空调滤网和净化器滤芯',
            '清洁窗帘、地毯等易积尘物品',
            '检查门窗密封性'
          ])

          this.DetailSection('📅 下季准备', [
            this.offSeasonContent?.nextSeasonHint ?? '关注花粉季预报',
            '提前准备防护用品（口罩、护目镜）',
            '了解当地主要致敏花粉种类',
            '如有需要，提前咨询医生'
          ])
        }
      }
      .padding(20)
    }
    .width('100%')
    .height('100%')
  }

  // 详情分区构建器
  @Builder
  DetailSection(title: string, items: string[]) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')

      Column({ space: 6 }) {
        ForEach(items, (item: string) => {
          if (item.length > 0) {
            Row() {
              Text('•')
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
                .margin({ right: 8 })
              Text(item)
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
                .layoutWeight(1)
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)
          }
        })
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.card_background'))
    .padding(16)
    .borderRadius(12)
  }

  // 获取数据来源文本颜色（确保对比度 ≥ 4.1:1，符合华为无障碍要求）
  private getDataSourceTextColor(): string {
    // 根据主题动态选择颜色
    if (this.currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      return '#CCCCCC'  // 深色模式：对比度约 4.2:1 (vs #1A1A1A)
    } else {
      return '#555555'  // 浅色模式：对比度约 4.2:1 (vs #F1F3F5)
    }
  }

  // ========== 工具方法 ==========
  getLevelColor(): string {
    // 当花粉值为0时，显示淡灰色
    if (this.pollenValue === 0) {
      return '#4A4A4A'
    }
    // 使用服务层的颜色函数
    return levelToColor(this.pollenLevelEnum)
  }

  getProgressLength(): number {
    // 环形进度，最大值100对应完整圆周565
    // 当花粉值为0时，显示完整的淡色环
    if (this.pollenValue === 0) {
      return 565
    }
    const progress = Math.min(this.pollenValue, 100) / 100
    return progress * 565
  }
}

// 天气项数据接口
interface WeatherItem {
  icon: Resource
  value: string
  label: string
}

// 趋势数据接口
interface TrendItem {
  date: string
  value: number
}

// 本月数据项接口
interface MonthDataItem {
  label: string
  value: number
}

// 全年数据项接口
interface YearDataItem {
  month: string
  value: number
  isPeak: boolean
  isCurrent: boolean
}

// 长按预览数据接口
interface PreviewData {
  title: string
  value: string
  desc: string
  extra: string
}
