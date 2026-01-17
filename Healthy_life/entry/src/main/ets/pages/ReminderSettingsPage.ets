/**
 * 提醒设置页面
 * 用户可配置每日提醒时间
 */

import { ReminderService } from '../common/utils/ReminderService';
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import router from '@ohos.router';

@Entry
@Component
struct ReminderSettingsPage {
  @State reminderEnabled: boolean = false;
  @State reminderTime: string = '09:00';
  @State permissionGranted: boolean = false;
  private reminderService = ReminderService.getInstance();

  aboutToAppear() {
    this.loadSettings();
  }

  /**
   * 加载提醒设置
   */
  async loadSettings() {
    try {
      const dataPreferences = await preferences.getPreferences(getContext(), 'reminder_settings');
      this.reminderEnabled = await dataPreferences.get('enabled', false) as boolean;
      this.reminderTime = await dataPreferences.get('time', '09:00') as string;
      this.permissionGranted = await dataPreferences.get('permission', false) as boolean;
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Failed to load settings, code: ${err.code}`);
    }
  }

  /**
   * 保存提醒设置
   */
  async saveSettings() {
    try {
      const dataPreferences = await preferences.getPreferences(getContext(), 'reminder_settings');
      await dataPreferences.put('enabled', this.reminderEnabled);
      await dataPreferences.put('time', this.reminderTime);
      await dataPreferences.put('permission', this.permissionGranted);
      await dataPreferences.flush();
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Failed to save settings, code: ${err.code}`);
    }
  }

  /**
   * 请求通知权限
   */
  async requestPermission() {
    const granted = await this.reminderService.requestNotificationPermission();
    this.permissionGranted = granted;
    await this.saveSettings();
  }

  /**
   * 测试发送通知
   */
  async sendTestNotification() {
    if (!this.permissionGranted) {
      await this.requestPermission();
    }
    
    if (this.permissionGranted) {
      await this.reminderService.sendDailyReminder('这是一条测试通知');
    }
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('←')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.getUIContext().getRouter().back();
          })

        Text('提醒设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 12 })
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.Start)

      // 权限状态卡片
      Column() {
        Row() {
          Text('通知权限')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          
          Blank()
          
          Text(this.permissionGranted ? '已授权' : '未授权')
            .fontSize(14)
            .fontColor(this.permissionGranted ? '#4CAF50' : '#FF5252')
        }
        .width('100%')
        .margin({ bottom: 8 })

        if (!this.permissionGranted) {
          Button('请求权限')
            .width('100%')
            .backgroundColor('#FF6B35')
            .onClick(() => {
              this.requestPermission();
            })
        }
      }
      .width('90%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 16 })

      // 提醒开关
      Column() {
        Row() {
          Column() {
            Text('每日提醒')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            
            Text('在设定时间提醒您完成打卡')
              .fontSize(12)
              .fontColor('#999999')
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Toggle({ type: ToggleType.Switch, isOn: this.reminderEnabled })
            .onChange((isOn: boolean) => {
              this.reminderEnabled = isOn;
              this.saveSettings();
            })
        }
        .width('100%')
        .padding(16)
      }
      .width('90%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 16 })

      // 提醒时间选择
      if (this.reminderEnabled) {
        Column() {
          Row() {
            Text('提醒时间')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)

            Blank()

            Text(this.reminderTime)
              .fontSize(16)
              .fontColor('#FF6B35')
          }
          .width('100%')
          .padding(16)

          Text('时间选择功能需连接系统时间选择器')
            .fontSize(12)
            .fontColor('#999999')
            .padding({ left: 16, right: 16, bottom: 16 })
        }
        .width('90%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ top: 16 })
      }

      // 测试通知按钮
      Button('发送测试通知')
        .width('90%')
        .margin({ top: 24 })
        .backgroundColor('#4CAF50')
        .onClick(() => {
          this.sendTestNotification();
        })

      // 说明文字
      Text('提醒功能需要通知权限,首次使用请授权')
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 16 })
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
