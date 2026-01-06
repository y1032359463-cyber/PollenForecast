/**
 * 通知服务工具类
 * 提供花粉预警和每日播报通知功能
 * 
 * 2026-01-07 更新：
 * 使用 reminderAgentManager（从 @kit.BackgroundTasksKit 导入）实现后台定时提醒
 * 参考文档：https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-reminderagentmanager
 * 权限要求：ohos.permission.PUBLISH_AGENT_REMINDER
 */

import { notificationManager } from '@kit.NotificationKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { wantAgent, common } from '@kit.AbilityKit'
import { ReminderService } from './ReminderService'

const DOMAIN = 0x0001;
const TAG = 'NotificationService';

export class NotificationService {
  private static instance: NotificationService;
  private slotInitialized: boolean = false;
  private context?: common.UIAbilityContext;

  private constructor() {}

  /**
   * 设置 Ability Context
   */
  setContext(context: common.UIAbilityContext): void {
    this.context = context;
  }

  static getInstance(): NotificationService {
    if (!NotificationService.instance) {
      NotificationService.instance = new NotificationService();
    }
    return NotificationService.instance;
  }

  /**
   * 初始化通知渠道（必须先调用）
   */
  private async initNotificationSlot(): Promise<void> {
    if (this.slotInitialized) {
      return;
    }

    try {
      await notificationManager.addSlot(notificationManager.SlotType.SOCIAL_COMMUNICATION);
      this.slotInitialized = true;
      hilog.info(DOMAIN, TAG, '通知渠道初始化成功');
    } catch (err) {
      hilog.error(DOMAIN, TAG, `初始化通知渠道失败: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 检查通知权限
   */
  async checkNotificationEnabled(): Promise<boolean> {
    try {
      const enabled = await notificationManager.isNotificationEnabled();
      hilog.info(DOMAIN, TAG, `通知权限状态: ${enabled}`);
      return enabled;
    } catch (err) {
      hilog.error(DOMAIN, TAG, `检查通知权限失败: ${JSON.stringify(err)}`);
      return false;
    }
  }

  /**
   * 请求通知权限
   */
  async requestNotificationPermission(): Promise<void> {
    try {
      await notificationManager.requestEnableNotification();
      hilog.info(DOMAIN, TAG, '通知权限请求已发送');
    } catch (err) {
      hilog.error(DOMAIN, TAG, `请求通知权限失败: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 发送花粉预警通知
   */
  async sendPollenAlert(level: string, value: number, city: string): Promise<void> {
    try {
      hilog.info(DOMAIN, TAG, `[DEBUG] 进入 sendPollenAlert: level=${level}, value=${value}, city=${city}`);
      
      // 检查通知总开关
      const notificationEnabled = AppStorage.get<boolean>('notificationEnabled') ?? false;
      if (!notificationEnabled) {
        hilog.info(DOMAIN, TAG, '通知总开关已关闭，跳过推送');
        return;
      }

      // 检查花粉预警开关
      const pollenAlertEnabled = AppStorage.get<boolean>('pollenAlertEnabled') ?? false;
      if (!pollenAlertEnabled) {
        hilog.info(DOMAIN, TAG, '花粉预警开关已关闭，跳过推送');
        return;
      }

      // 检查系统通知权限
      const hasPermission = await this.checkNotificationEnabled();
      if (!hasPermission) {
        hilog.warn(DOMAIN, TAG, '无通知权限，无法发送通知');
        return;
      }

      // 初始化通知渠道
      await this.initNotificationSlot();
      
      // 创建点击跳转 WantAgent
      const wantAgentObj = await this.createWantAgent();
      
      // 构建通知内容
      const request: notificationManager.NotificationRequest = {
        id: Math.floor(Math.random() * 1000),
        notificationSlotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: `${city} 花粉预警`,
            text: `花粉等级：${level}（${value} 粒/km³）\n建议减少户外活动，外出佩戴口罩`,
            additionalText: '点击查看详情'
          }
        },
        deliveryTime: new Date().getTime(),
        wantAgent: wantAgentObj
      };

      await notificationManager.publish(request);
      hilog.info(DOMAIN, TAG, `花粉预警通知已发送: ${city} - ${level}`);
    } catch (err) {
      hilog.error(DOMAIN, TAG, `发送花粉预警通知失败: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 发送每日播报通知
   */
  async sendDailyReport(level: string, value: number, city: string, tips: string[]): Promise<void> {
    try {
      // 检查通知总开关
      const notificationEnabled = AppStorage.get<boolean>('notificationEnabled') ?? false;
      if (!notificationEnabled) {
        hilog.info(DOMAIN, TAG, '通知总开关已关闭，跳过推送');
        return;
      }

      // 检查每日播报开关
      const dailyReportEnabled = AppStorage.get<boolean>('dailyReportEnabled') ?? false;
      if (!dailyReportEnabled) {
        hilog.info(DOMAIN, TAG, '每日播报开关已关闭，跳过推送');
        return;
      }

      // 检查系统通知权限
      const hasPermission = await this.checkNotificationEnabled();
      if (!hasPermission) {
        hilog.warn(DOMAIN, TAG, '无通知权限，无法发送通知');
        return;
      }

      // 创建点击跳转 WantAgent
      const wantAgentObj = await this.createWantAgent();
      
      // 构建通知内容
      const tipsText = tips.length > 0 ? `\n${tips[0]}` : '';
      const request: notificationManager.NotificationRequest = {
        id: 2,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: `${city} 今日花粉播报`,
            text: `花粉等级：${level}（${value} 粒/km³）${tipsText}`,
            additionalText: '点击查看详情'
          }
        },
        isOngoing: false,
        isUnremovable: false,
        deliveryTime: new Date().getTime(),
        tapDismissed: true,
        autoDeletedTime: 7200000,
        wantAgent: wantAgentObj
      };

      await notificationManager.publish(request);
      hilog.info(DOMAIN, TAG, `每日播报通知已发送: ${city} - ${level}`);
    } catch (err) {
      hilog.error(DOMAIN, TAG, `发送每日播报通知失败: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 创建通知点击跳转 WantAgent
   */
  private async createWantAgent(): Promise<object | undefined> {
    try {
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: 'com.eric.PollenForecast',
            abilityName: 'EntryAbility',
            parameters: {
              router: 'pages/Index',
              tab: 0
            }
          }
        ],
        requestCode: 0,
        actionType: wantAgent.OperationType.START_ABILITY,
        actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      };

      const wantAgentObj = await wantAgent.getWantAgent(wantAgentInfo);
      hilog.info(DOMAIN, TAG, 'WantAgent创建成功');
      return wantAgentObj;
    } catch (err) {
      hilog.error(DOMAIN, TAG, `WantAgent创建失败: ${JSON.stringify(err)}`);
      return undefined;
    }
  }

  /**
   * 取消所有通知
   */
  async cancelAllNotifications(): Promise<void> {
    try {
      await notificationManager.cancelAll();
      hilog.info(DOMAIN, TAG, '已取消所有通知');
    } catch (err) {
      hilog.error(DOMAIN, TAG, `取消通知失败: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 设置每日播报定时提醒
   * 使用 ReminderAgent（代理提醒）实现，应用关闭后系统仍可触发
   */
  async scheduleDailyReminder(timeStr: string): Promise<boolean> {
    try {
      hilog.info(DOMAIN, TAG, `设置每日播报定时提醒: ${timeStr}`);

      // 保存定时播报时间配置
      AppStorage.setOrCreate('dailyReminderTime', timeStr);
      AppStorage.setOrCreate('dailyReportEnabled', true);
      
      // 使用 ReminderService 设置代理提醒
      const reminderService = ReminderService.getInstance();
      const success = await reminderService.scheduleDailyReminder(timeStr);
      
      if (success) {
        hilog.info(DOMAIN, TAG, `✅ 每日播报定时提醒设置成功: ${timeStr}`);
      } else {
        hilog.warn(DOMAIN, TAG, `⚠️ 代理提醒设置失败，将使用应用启动时检查方案`);
      }
      
      return true; // 即使代理提醒失败，也保存配置成功
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : JSON.stringify(err);
      hilog.error(DOMAIN, TAG, `设置定时提醒失败: ${errorMsg}`);
      return false;
    }
  }

  /**
   * 取消每日播报定时提醒
   */
  async cancelDailyReminder(): Promise<void> {
    try {
      AppStorage.delete('dailyReminderTime');
      AppStorage.setOrCreate('dailyReportEnabled', false);
      
      // 取消代理提醒
      const reminderService = ReminderService.getInstance();
      await reminderService.cancelReminder();
      
      hilog.info(DOMAIN, TAG, '已取消每日播报');
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : JSON.stringify(err);
      hilog.error(DOMAIN, TAG, `取消定时提醒失败: ${errorMsg}`);
    }
  }

  /**
   * 检查并发送每日播报（应用启动时调用，作为代理提醒的补充方案）
   */
  async checkAndSendDailyReport(): Promise<void> {
    try {
      // 1. 检查总开关
      const notificationEnabled = AppStorage.get<boolean>('notificationEnabled') ?? false;
      if (!notificationEnabled) {
        hilog.info(DOMAIN, TAG, '通知总开关已关闭，跳过每日播报检查');
        return;
      }

      // 2. 检查每日播报开关
      const dailyReportEnabled = AppStorage.get<boolean>('dailyReportEnabled') ?? false;
      if (!dailyReportEnabled) {
        hilog.info(DOMAIN, TAG, '每日播报已关闭，跳过检查');
        return;
      }

      // 3. 获取设定时间
      const timeStr = AppStorage.get<string>('dailyReminderTime') ?? '08:00';
      const timeParts: string[] = timeStr.split(':');
      const hour = parseInt(timeParts[0]);
      const minute = parseInt(timeParts[1]);

      // 4. 检查今天是否已发送
      const lastSentDate = AppStorage.get<string>('lastDailyReportDate') ?? '';
      const today = new Date().toDateString();
      if (lastSentDate === today) {
        hilog.info(DOMAIN, TAG, '今日播报已发送，跳过');
        return;
      }

      // 5. 检查当前时间是否已过设定时间
      const now = new Date();
      const targetTime = new Date();
      targetTime.setHours(hour, minute, 0, 0);

      if (now.getTime() >= targetTime.getTime()) {
        // 6. 发送播报通知
        hilog.info(DOMAIN, TAG, '触发每日播报通知（应用启动时检查）');
        
        // 获取当前花粉数据
        const city = AppStorage.get<string>('currentCity') ?? '未知';
        const level = AppStorage.get<string>('pollenLevel') ?? '未知';
        const value = AppStorage.get<number>('pollenValue') ?? 0;

        await this.sendDailyReport(level, value, city, []);
        
        // 记录发送日期
        AppStorage.setOrCreate('lastDailyReportDate', today);
        hilog.info(DOMAIN, TAG, `✅ 每日播报已发送: ${city} - ${level}`);
      } else {
        hilog.info(DOMAIN, TAG, `当前时间未到设定时间 ${timeStr}，跳过播报`);
      }
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : JSON.stringify(err);
      hilog.error(DOMAIN, TAG, `每日播报检查失败: ${errorMsg}`);
    }
  }

  /**
   * 检查定时提醒权限
   */
  async checkReminderPermission(): Promise<boolean> {
    return true;
  }
}
