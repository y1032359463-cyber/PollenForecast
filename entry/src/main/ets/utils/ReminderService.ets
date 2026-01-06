/**
 * 代理提醒服务
 * 使用 reminderAgentManager 实现后台定时提醒（应用关闭后仍能触发）
 * 
 * 正确导入方式：从 @kit.BackgroundTasksKit 导入
 * 参考文档：https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-reminderagentmanager
 * 
 * 权限要求：ohos.permission.PUBLISH_AGENT_REMINDER
 */

import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0001;
const TAG = 'ReminderService';

// 提醒ID存储key
const REMINDER_ID_KEY = 'dailyReminderAgentId';

export class ReminderService {
  private static instance: ReminderService;
  private reminderId: number = -1;

  private constructor() {
    // 从 AppStorage 恢复提醒ID
    const savedId = AppStorage.get<number>(REMINDER_ID_KEY);
    if (savedId !== undefined && savedId !== -1) {
      this.reminderId = savedId;
      hilog.info(DOMAIN, TAG, `恢复已保存的提醒ID: ${this.reminderId}`);
    }
  }

  static getInstance(): ReminderService {
    if (!ReminderService.instance) {
      ReminderService.instance = new ReminderService();
    }
    return ReminderService.instance;
  }

  /**
   * 取消所有提醒（清理旧数据）
   */
  async cancelAllReminders(): Promise<void> {
    try {
      // 使用 cancelAllReminders API 直接取消所有提醒
      await reminderAgentManager.cancelAllReminders();
      
      this.reminderId = -1;
      AppStorage.delete(REMINDER_ID_KEY);
      hilog.info(DOMAIN, TAG, `✅ 已清理所有旧提醒`);
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `清理旧提醒失败: ${error.code} - ${error.message}`);
    }
  }

  /**
   * 设置每日定时提醒
   * @param timeStr 时间字符串，格式 "HH:mm"
   * @returns 是否设置成功
   */
  async scheduleDailyReminder(timeStr: string): Promise<boolean> {
    try {
      hilog.info(DOMAIN, TAG, `设置每日提醒: ${timeStr}`);

      // 解析时间
      const timeParts: string[] = timeStr.split(':');
      const hour = parseInt(timeParts[0]);
      const minute = parseInt(timeParts[1]);

      if (isNaN(hour) || isNaN(minute)) {
        hilog.error(DOMAIN, TAG, `无效的时间格式: ${timeStr}`);
        return false;
      }

      // ⚠️ 先清理所有旧提醒（解决数量超限问题）
      await this.cancelAllReminders();

      // 创建闹钟提醒请求（每天重复）
      const reminderRequest: reminderAgentManager.ReminderRequestAlarm = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_ALARM,
        hour: hour,
        minute: minute,
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // 每天
        title: '🌼 花粉浓度播报',
        content: '今日花粉浓度信息已更新，点击查看详情',
        snoozeContent: '稍后提醒',
        ringDuration: 10  // 响铃10秒
      };

      // 发布提醒
      this.reminderId = await reminderAgentManager.publishReminder(reminderRequest);
      
      // 保存提醒ID
      AppStorage.setOrCreate(REMINDER_ID_KEY, this.reminderId);
      
      hilog.info(DOMAIN, TAG, `✅ 每日提醒设置成功，ID: ${this.reminderId}`);
      return true;

    } catch (err) {
      const error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `设置提醒失败: ${error.code} - ${error.message}`);
      return false;
    }
  }

  /**
   * 取消提醒
   */
  async cancelReminder(): Promise<void> {
    try {
      if (this.reminderId !== -1) {
        await reminderAgentManager.cancelReminder(this.reminderId);
        hilog.info(DOMAIN, TAG, `已取消提醒，ID: ${this.reminderId}`);
        
        this.reminderId = -1;
        AppStorage.delete(REMINDER_ID_KEY);
      }
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `取消提醒失败: ${error.code} - ${error.message}`);
    }
  }

  /**
   * 获取所有有效提醒
   */
  async getValidReminders(): Promise<reminderAgentManager.ReminderRequest[]> {
    try {
      const reminders = await reminderAgentManager.getValidReminders();
      hilog.info(DOMAIN, TAG, `当前有效提醒数量: ${reminders.length}`);
      return reminders;
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `获取提醒失败: ${error.code} - ${error.message}`);
      return [];
    }
  }
}

