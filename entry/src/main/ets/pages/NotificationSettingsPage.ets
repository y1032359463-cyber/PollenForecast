/**
 * 通知设置页面
 * 包含：通知总开关、花粉预警、每日播报
 */

import { NotificationService } from '../utils/NotificationService'
import { VibrationUtils } from '../utils/VibrationUtils'
import { SettingsPreferences } from '../utils/SettingsPreferences'

@Entry
@Component
struct NotificationSettingsPage {
  @StorageLink('safeTop') safeTop: number = 44
  @StorageLink('safeBottom') safeBottom: number = 28
  
  // 通知设置状态（使用 AppStorage 持久化）
  @StorageLink('notificationEnabled') notificationEnabled: boolean = false
  @StorageLink('pollenAlertEnabled') pollenAlertEnabled: boolean = true
  @StorageLink('dailyReportEnabled') dailyReportEnabled: boolean = true
  @StorageLink('dailyReportTime') dailyReportTime: string = '08:00'

  private notificationService: NotificationService = NotificationService.getInstance()

  async aboutToAppear() {
    // 检查通知权限状态
    const hasPermission = await this.notificationService.checkNotificationEnabled()
    console.info(`[NotificationSettings] 系统通知权限状态: ${hasPermission}, 当前开关: ${this.notificationEnabled}`)
    
    // 如果用户之前开启过但系统权限被关闭，仅提示但不自动关闭
    if (!hasPermission && this.notificationEnabled) {
      console.warn('[NotificationSettings] 系统通知权限已关闭，但用户设置为开启状态')
      // 不再自动修改用户设置，让用户自行决定
    }
  }

  // 显示时间选择器对话框
  showTimePickerDialog() {
    // 解析当前时间（格式: "08:00"）
    const timeParts = this.dailyReportTime.split(':')
    const currentHour = parseInt(timeParts[0]) || 8
    const currentMinute = parseInt(timeParts[1]) || 0

    TimePickerDialog.show({
      selected: new Date(2024, 0, 1, currentHour, currentMinute), // 只关心时分
      onAccept: async (value: TimePickerResult) => {
        // 格式化为 HH:mm
        const hour = value.hour !== undefined ? value.hour.toString().padStart(2, '0') : '08'
        const minute = value.minute !== undefined ? value.minute.toString().padStart(2, '0') : '00'
        this.dailyReportTime = `${hour}:${minute}`
        
        // 震动反馈
        VibrationUtils.triggerMedium()
        
        // 保存到 AppStorage
        AppStorage.setOrCreate('dailyReportTime', this.dailyReportTime)
        SettingsPreferences.setDailyReportTime(this.dailyReportTime)
        
        // 如果每日播报开关已开启，更新定时提醒
        if (this.dailyReportEnabled && this.notificationEnabled) {
          const success = await this.notificationService.scheduleDailyReminder(this.dailyReportTime)
          if (success) {
            this.getUIContext().getPromptAction().showToast({
              message: `播报时间已设置为 ${this.dailyReportTime}`,
              duration: 1500
            })
          } else {
            this.getUIContext().getPromptAction().showToast({
              message: '设置定时提醒失败，请检查权限',
              duration: 2000
            })
          }
        } else {
          this.getUIContext().getPromptAction().showToast({
            message: `播报时间已设置为 ${this.dailyReportTime}`,
            duration: 1500
          })
        }
        
        console.info(`[NotificationSettings] 播报时间已更新: ${this.dailyReportTime}`)
      },
      onCancel: () => {
        console.info('[NotificationSettings] 取消时间选择')
      }
    })
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
            VibrationUtils.triggerLight()
            this.getUIContext().getRouter().back()
          })

        Text('通知设置')
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
          // ===== 通知总开关 =====
          Row() {
            Column() {
              Text('通知总开关')
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
              Text('关闭后将不再接收任何通知')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)

            Blank()

            Toggle({ type: ToggleType.Switch, isOn: this.notificationEnabled })
              .selectedColor('#4CAF50')
              .switchPointColor(Color.White)
              .onChange(async (isOn: boolean) => {
                VibrationUtils.triggerMedium()
                
                if (isOn) {
                  // 开启通知，先检查系统权限
                  const hasPermission = await this.notificationService.checkNotificationEnabled()
                  if (!hasPermission) {
                    // 请求通知权限
                    await this.notificationService.requestNotificationPermission()
                    // 再次检查权限
                    const granted = await this.notificationService.checkNotificationEnabled()
                    this.notificationEnabled = granted
                    if (!granted) {
                      this.getUIContext().getPromptAction().showToast({
                        message: '请在系统设置中开启通知权限',
                        duration: 2000
                      })
                    }
                  } else {
                    this.notificationEnabled = true
                  }
                } else {
                  // 关闭通知
                  this.notificationEnabled = false
                  // 取消所有已发送的通知
                  await this.notificationService.cancelAllNotifications()
                  // 取消定时提醒
                  await this.notificationService.cancelDailyReminder()
                  this.getUIContext().getPromptAction().showToast({
                    message: '通知已关闭',
                    duration: 1500
                  })
                }
                // 保存到 AppStorage
                AppStorage.setOrCreate('notificationEnabled', this.notificationEnabled)
                SettingsPreferences.setNotificationEnabled(this.notificationEnabled)
                console.info(`通知总开关: ${this.notificationEnabled ? '开启' : '关闭'}`)
              })
          }
          .width('100%')
          .height(70)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .padding({ left: 16, right: 16 })
          .opacity(1)

          // ===== 花粉预警 =====
          Column() {
            Row() {
              Column() {
                Text('花粉预警')
                  .fontSize(16)
                  .fontColor($r('app.color.text_primary'))
                Text('当花粉浓度达到中度或以上时提醒')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)

              Blank()

              Toggle({ type: ToggleType.Switch, isOn: this.pollenAlertEnabled })
                .selectedColor('#4CAF50')
                .switchPointColor(Color.White)
                .enabled(this.notificationEnabled)
                .onChange((isOn: boolean) => {
                  VibrationUtils.triggerLight()
                  this.pollenAlertEnabled = isOn
                  SettingsPreferences.setPollenAlertEnabled(this.pollenAlertEnabled)
                  console.info(`花粉预警: ${isOn ? '开启' : '关闭'}`)
                })
            }
            .width('100%')
            .height(70)
            .padding({ left: 16, right: 16 })

            Divider()
              .color($r('app.color.divider_color'))
              .margin({ left: 16 })

            // 说明文字
            Text('当花粉浓度超过 100 粒/km³ 时，将向您推送预警通知')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          }
          .width('100%')
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .margin({ top: 16 })
          .opacity(this.notificationEnabled ? 1 : 0.5)

          // ===== 每日播报 =====
          Column() {
            Row() {
              Column() {
                Text('每日播报')
                  .fontSize(16)
                  .fontColor($r('app.color.text_primary'))
                Text('每天固定时间推送当日花粉情况')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)

              Blank()

              Toggle({ type: ToggleType.Switch, isOn: this.dailyReportEnabled })
                .selectedColor('#4CAF50')
                .switchPointColor(Color.White)
                .enabled(this.notificationEnabled)
                .onChange(async (isOn: boolean) => {
                  VibrationUtils.triggerLight()
                  this.dailyReportEnabled = isOn
                  
                  // 保存到 AppStorage
                  AppStorage.setOrCreate('dailyReportEnabled', isOn)
                  SettingsPreferences.setDailyReportEnabled(this.dailyReportEnabled)
                  
                  if (isOn && this.notificationEnabled) {
                    // 开启：设置定时提醒
                    const success = await this.notificationService.scheduleDailyReminder(this.dailyReportTime)
                    if (success) {
                      this.getUIContext().getPromptAction().showToast({
                        message: `每日播报已开启，将在 ${this.dailyReportTime} 提醒`,
                        duration: 2000
                      })
                    } else {
                      this.dailyReportEnabled = false
                      this.getUIContext().getPromptAction().showToast({
                        message: '设置定时提醒失败，请检查权限',
                        duration: 2000
                      })
                    }
                  } else {
                    // 关闭：取消定时提醒
                    await this.notificationService.cancelDailyReminder()
                    this.getUIContext().getPromptAction().showToast({
                      message: '每日播报已关闭',
                      duration: 1500
                    })
                  }
                  
                  console.info(`每日播报: ${isOn ? '开启' : '关闭'}`)
                })
            }
            .width('100%')
            .height(70)
            .padding({ left: 16, right: 16 })

            if (this.dailyReportEnabled) {
              Divider()
                .color($r('app.color.divider_color'))
                .margin({ left: 16 })

              // 播报时间设置
              Row() {
                Text('播报时间')
                  .fontSize(14)
                  .fontColor($r('app.color.text_primary'))

                Blank()

                Text(this.dailyReportTime)
                  .fontSize(16)
                  .fontColor('#4CAF50')
                  .fontWeight(FontWeight.Medium)

                Text('›')
                  .fontSize(20)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ left: 8 })
              }
              .width('100%')
              .height(50)
              .padding({ left: 16, right: 16 })
              .onClick(() => {
                VibrationUtils.triggerLight()
                // 打开时间选择器
                this.showTimePickerDialog()
              })
            }
          }
          .width('100%')
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
          .margin({ top: 16 })
          .opacity(this.notificationEnabled ? 1 : 0.5)

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
