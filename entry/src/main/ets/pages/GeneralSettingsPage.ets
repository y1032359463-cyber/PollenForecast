/**
 * 通用设置页面
 * 包含：震动反馈、外观模式（跟随系统/浅色/深色）
 * 支持 API 17+ 兼容处理
 */

import { router, promptAction } from '@kit.ArkUI'
import { vibrator } from '@kit.SensorServiceKit'
import { common, ConfigurationConstant } from '@kit.AbilityKit'
import { ApiVersionUtils } from '../utils/ApiVersionUtils'  // API 版本检测工具
import { PollenDataSourceType, POLLEN_DATA_SOURCES, getDataSourceName, PollenDataSourceConfig } from '../model/PollenDataSource'

@Entry
@Component
struct GeneralSettingsPage {
  @StorageLink('safeTop') safeTop: number = 44
  @StorageLink('safeBottom') safeBottom: number = 28
  
  // 设置状态（使用 AppStorage 持久化）
  @StorageLink('vibrationEnabled') vibrationEnabled: boolean = false
  @StorageLink('appearanceMode') appearanceMode: number = 0  // 0=跟随系统, 1=浅色, 2=深色
  @StorageLink('gripDetectionEnabled') gripDetectionEnabled: boolean = false  // 智感握姿开关
  @StorageLink('pollenDataSource') pollenDataSource: string = 'AUTO'  // 数据源选择

  private appearanceModes: string[] = ['跟随系统', '浅色模式', '深色模式']
  
  // 数据源选项
  private getDataSourceOptions(): string[] {
    const result: string[] = []
    for (let i = 0; i < POLLEN_DATA_SOURCES.length; i++) {
      const source = POLLEN_DATA_SOURCES[i]
      if (source.enabled) {
        result.push(source.name)
      }
    }
    return result
  }
  
  // 获取当前选中的数据源索引
  private getCurrentDataSourceIndex(): number {
    const currentType = this.pollenDataSource as PollenDataSourceType
    let foundIndex = 0
    let enabledIndex = 0
    for (let i = 0; i < POLLEN_DATA_SOURCES.length; i++) {
      const source = POLLEN_DATA_SOURCES[i]
      if (source.enabled) {
        if (source.type === currentType) {
          foundIndex = enabledIndex
          break
        }
        enabledIndex++
      }
    }
    return foundIndex
  }

  // 获取启用的数据源列表
  private getEnabledDataSources(): PollenDataSourceConfig[] {
    const result: PollenDataSourceConfig[] = []
    for (let i = 0; i < POLLEN_DATA_SOURCES.length; i++) {
      if (POLLEN_DATA_SOURCES[i].enabled) {
        result.push(POLLEN_DATA_SOURCES[i])
      }
    }
    return result
  }

  // 触发震动反馈
  triggerVibration(): void {
    if (!this.vibrationEnabled) {
      return
    }
    try {
      vibrator.startVibration({
        type: 'time',
        duration: 50  // 50ms 短震动
      }, {
        id: 0,
        usage: 'touch'
      }, (error) => {
        if (error) {
          console.error('震动失败: ' + JSON.stringify(error))
        } else {
          // 调试提示：确认震动代码已执行
          this.getUIContext().getPromptAction().showToast({ message: '震动已触发', duration: 1000 })
        }
      })
    } catch (err) {
      console.error('震动异常: ' + JSON.stringify(err))
    }
  }

  // 转换为有效的 ColorMode
  private getValidColorMode(mode: number): ConfigurationConstant.ColorMode {
    switch (mode) {
      case 0: return ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
      case 1: return ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
      case 2: return ConfigurationConstant.ColorMode.COLOR_MODE_DARK
      default: return ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
    }
  }

  // 应用外观模式
  applyAppearanceMode(mode: number): void {
    console.info(`切换外观模式: ${this.appearanceModes[mode]}`)
    
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext
      const applicationContext = context.getApplicationContext()
      const colorMode = this.getValidColorMode(mode)
      
      // 使用 ApplicationContext.setColorMode
      applicationContext.setColorMode(colorMode)
      console.info(`主题已切换为: ${colorMode}`)
      
      // 强制刷新UI
      this.forceRefreshUI()
      
    } catch (err) {
      console.error(`主题切换失败: ${JSON.stringify(err)}`)
    }
  }

  @Builder
  forceRefreshUI() {
    Column() {}
  }

  build() {
    Column() {
      // 顶部安全距离
      Blank().height(this.safeTop)

      // 导航栏
      Row() {
        // 返回按钮
        Text('‹')
          .fontSize(32)
          .fontColor($r('app.color.text_primary'))
          .onClick(() => {
            this.getUIContext().getRouter().back()
          })

        Text('通用')
          .fontSize(20)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })

        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      // 设置内容
      Scroll() {
        Column() {
          // ===== 震动反馈 =====
          Row() {
            Column() {
              Text('震动反馈')
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
              Text('操作时提供触感反馈')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)

            Blank()

            Toggle({ type: ToggleType.Switch, isOn: this.vibrationEnabled })
              .selectedColor('#4CAF50')
              .switchPointColor(Color.White)
              .onChange((isOn: boolean) => {
                this.vibrationEnabled = isOn
                console.info(`震动反馈: ${isOn ? '开启' : '关闭'}`)
                // 开启时触发一次震动作为反馈
                if (isOn) {
                  this.triggerVibration()
                }
              })
          }
          .width('100%')
          .height(70)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .padding({ left: 16, right: 16 })

          // ===== 智感握姿（API 20+ 专属功能）=====
          Row() {
            Column() {
              Row() {
                Text('智感握姿')
                  .fontSize(16)
                  .fontColor(ApiVersionUtils.supportsGripDetection() 
                    ? $r('app.color.text_primary') 
                    : $r('app.color.text_secondary'))
                
                // API 17-19：显示"需升级"标签
                if (!ApiVersionUtils.supportsGripDetection()) {
                  Text('需升级')
                    .fontSize(10)
                    .fontColor(Color.White)
                    .backgroundColor('#FF9800')
                    .borderRadius(4)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    .margin({ left: 8 })
                }
              }
              
              Text(ApiVersionUtils.supportsGripDetection()
                ? '自动识别左右手握持，调整定位按钮位置'
                : '此功能需要 HarmonyOS 6.0+（API 20）')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)

            Blank()

            Toggle({ type: ToggleType.Switch, isOn: this.gripDetectionEnabled })
              .selectedColor('#4CAF50')
              .switchPointColor(Color.White)
              .enabled(ApiVersionUtils.supportsGripDetection())  // API 17 禁用
              .opacity(ApiVersionUtils.supportsGripDetection() ? 1 : 0.5)
              .onChange((isOn: boolean) => {
                this.gripDetectionEnabled = isOn
                console.info(`智感握姿: ${isOn ? '开启' : '关闭'}`)
                // 开启时触发震动反馈
                if (isOn && this.vibrationEnabled) {
                  this.triggerVibration()
                }
              })
          }
          .width('100%')
          .height(70)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .padding({ left: 16, right: 16 })
          .margin({ top: 12 })
          .onClick(() => {
            // API 17-19：点击时显示升级提示
            if (!ApiVersionUtils.supportsGripDetection()) {
              this.getUIContext().getPromptAction().showToast({
                message: '智感握姿需要 HarmonyOS 6.0+（API 20）',
                duration: 2000
              })
            }
          })

          // ===== 外观模式 =====
          Column() {
            Text('外观模式')
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
              .padding({ bottom: 8 })

            Column() {
              ForEach(this.appearanceModes, (mode: string, index: number) => {
                Row() {
                  Text(mode)
                    .fontSize(16)
                    .fontColor($r('app.color.text_primary'))

                  Blank()

                  if (this.appearanceMode === index) {
                    Text('✓')
                      .fontSize(18)
                      .fontColor('#4CAF50')
                  }
                }
                .width('100%')
                .height(50)
                .padding({ left: 16, right: 16 })
                .onClick(() => {
                  this.appearanceMode = index
                  this.applyAppearanceMode(index)
                  this.triggerVibration()  // 选择时触发震动反馈
                })

                if (index < this.appearanceModes.length - 1) {
                  Divider()
                    .color($r('app.color.divider_color'))
                    .margin({ left: 16 })
                }
              })
            }
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(12)
          }
          .width('100%')
          .margin({ top: 24 })

          // 说明文字
          Text('选择"跟随系统"时，应用会根据系统设置自动切换深色或浅色模式。')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')
            .margin({ top: 12 })
            .padding({ left: 4, right: 4 })

          // ===== 数据源选择 =====
          Column() {
            Text('数据源')
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
              .padding({ bottom: 8 })

            Column() {
              ForEach(this.getEnabledDataSources(), (source: PollenDataSourceConfig, index: number) => {
                Row() {
                  Column() {
                    Text(source.name)
                      .fontSize(16)
                      .fontColor($r('app.color.text_primary'))
                    Text(source.description)
                      .fontSize(12)
                      .fontColor($r('app.color.text_secondary'))
                      .margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Blank()

                  if (this.pollenDataSource === source.type) {
                    Text('✓')
                      .fontSize(18)
                      .fontColor('#4CAF50')
                  }
                }
                .width('100%')
                .height(60)
                .padding({ left: 16, right: 16 })
                .onClick(() => {
                  this.pollenDataSource = source.type
                  console.info(`数据源已切换为: ${source.name} (${source.type})`)
                  if (this.vibrationEnabled) {
                    this.triggerVibration()
                  }
                  this.getUIContext().getPromptAction().showToast({
                    message: `已切换到 ${source.name}`,
                    duration: 1500
                  })
                })

                if (index < this.getEnabledDataSources().length - 1) {
                  Divider()
                    .color($r('app.color.divider_color'))
                    .margin({ left: 16 })
                }
              })
            }
            .backgroundColor($r('app.color.card_background'))
            .borderRadius(12)
          }
          .width('100%')
          .margin({ top: 24 })

          // 数据源说明文字
          Text('选择不同的数据源获取花粉数据。自动选择会根据网络和位置自动选择最佳数据源。')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')
            .margin({ top: 12 })
            .padding({ left: 4, right: 4 })

          // 底部间距
          Blank().height(this.safeBottom + 32)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
