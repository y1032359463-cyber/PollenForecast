/**
 * 提醒服务
 * 负责每日推送通知
 */

import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

/**
 * 提醒服务类
 */
export class ReminderService {
  private static instance: ReminderService;
  private context: common.UIAbilityContext | null = null;

  private constructor() {}

  static getInstance(): ReminderService {
    if (!ReminderService.instance) {
      ReminderService.instance = new ReminderService();
    }
    return ReminderService.instance;
  }

  /**
   * 初始化服务
   */
  init(context: common.UIAbilityContext) {
    this.context = context;
  }

  /**
   * 请求通知权限
   */
  async requestNotificationPermission(): Promise<boolean> {
    if (!this.context) {
      console.error('ReminderService: Context not initialized');
      return false;
    }

    try {
      await notificationManager.requestEnableNotification(this.context);
      console.info('ReminderService: Notification permission granted');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      console.error(`ReminderService: Permission denied, code: ${err.code}, message: ${err.message}`);
      return false;
    }
  }

  /**
   * 发送每日打卡提醒
   */
  async sendDailyReminder(message: string = '今天还有任务未完成哦!') {
    try {
      const notificationRequest: notificationManager.NotificationRequest = {
        id: 1,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: '打卡提醒',
            text: message
          }
        }
      };

      await notificationManager.publish(notificationRequest);
      console.info('ReminderService: Daily reminder sent');
    } catch (error) {
      const err = error as BusinessError;
      console.error(`ReminderService: Failed to send reminder, code: ${err.code}`);
    }
  }

  /**
   * 发送成就解锁通知
   */
  async sendAchievementNotification(achievementName: string, description: string) {
    try {
      const notificationRequest: notificationManager.NotificationRequest = {
        id: 2,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: '🏆 成就解锁!',
            text: `恭喜解锁 "${achievementName}" - ${description}`
          }
        }
      };

      await notificationManager.publish(notificationRequest);
      console.info('ReminderService: Achievement notification sent');
    } catch (error) {
      const err = error as BusinessError;
      console.error(`ReminderService: Failed to send achievement notification, code: ${err.code}`);
    }
  }

  /**
   * 发送连续打卡鼓励
   */
  async sendStreakNotification(days: number) {
    try {
      const notificationRequest: notificationManager.NotificationRequest = {
        id: 3,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: '🔥 连续打卡',
            text: `太棒了!你已连续打卡${days}天,继续保持!`
          }
        }
      };

      await notificationManager.publish(notificationRequest);
      console.info('ReminderService: Streak notification sent');
    } catch (error) {
      const err = error as BusinessError;
      console.error(`ReminderService: Failed to send streak notification, code: ${err.code}`);
    }
  }

  /**
   * 取消所有通知
   */
  async cancelAllNotifications() {
    try {
      await notificationManager.cancelAll();
      console.info('ReminderService: All notifications cancelled');
    } catch (error) {
      const err = error as BusinessError;
      console.error(`ReminderService: Failed to cancel notifications, code: ${err.code}`);
    }
  }
}
