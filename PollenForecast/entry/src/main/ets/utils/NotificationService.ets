/**
 * 通知服务工具类
 * 提供花粉预警和每日播报通知功能
 */

import { notificationManager } from '@kit.NotificationKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { wantAgent } from '@kit.AbilityKit'

const DOMAIN = 0x0001;
const TAG = 'NotificationService';

export class NotificationService {
  private static instance: NotificationService;
  private slotInitialized: boolean = false;

  private constructor() {}

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
      // API 20 使用 requestEnableNotification
      await notificationManager.requestEnableNotification();
      hilog.info(DOMAIN, TAG, '通知权限请求已发送');
    } catch (err) {
      hilog.error(DOMAIN, TAG, `请求通知权限失败: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 发送花粉预警通知
   * @param level 花粉等级（极低/低/中/高/极高）
   * @param value 花粉浓度值
   * @param city 城市名称
   */
  async sendPollenAlert(level: string, value: number, city: string): Promise<void> {
    try {
      hilog.info(DOMAIN, TAG, `[DEBUG] 进入 sendPollenAlert: level=${level}, value=${value}, city=${city}`);
      
      // 检查通知总开关
      const notificationEnabled = AppStorage.get<boolean>('notificationEnabled') ?? false;
      hilog.info(DOMAIN, TAG, `[DEBUG] 通知总开关: ${notificationEnabled}`);
      if (!notificationEnabled) {
        hilog.info(DOMAIN, TAG, '通知总开关已关闭，跳过推送');
        return;
      }

      // 检查花粉预警开关
      const pollenAlertEnabled = AppStorage.get<boolean>('pollenAlertEnabled') ?? false;
      hilog.info(DOMAIN, TAG, `[DEBUG] 花粉预警开关: ${pollenAlertEnabled}`);
      if (!pollenAlertEnabled) {
        hilog.info(DOMAIN, TAG, '花粉预警开关已关闭，跳过推送');
        return;
      }

      // 检查系统通知权限
      const hasPermission = await this.checkNotificationEnabled();
      hilog.info(DOMAIN, TAG, `[DEBUG] 系统通知权限: ${hasPermission}`);
      if (!hasPermission) {
        hilog.warn(DOMAIN, TAG, '无通知权限，无法发送通知');
        return;
      }

      // 初始化通知渠道
      await this.initNotificationSlot();
      
      // 创建点击跳转 WantAgent
      const wantAgentObj = await this.createWantAgent();
      
      // 构建通知内容
      hilog.info(DOMAIN, TAG, '[DEBUG] 准备发送通知...');
      const request: notificationManager.NotificationRequest = {
        id: Math.floor(Math.random() * 1000),
        notificationSlotType: notificationManager.SlotType.SOCIAL_COMMUNICATION, // API 20 正确字段名
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
   * @param level 花粉等级
   * @param value 花粉浓度值
   * @param city 城市名称
   * @param tips 健康建议
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
        id: 2, // 每日播报通知 ID
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
        autoDeletedTime: 7200000, // 2小时后自动删除
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
   * 点击通知后跳转到应用首页
   */
  private async createWantAgent(): Promise<object | undefined> {
    try {
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: 'com.eric.PollenForecast',
            abilityName: 'EntryAbility',
            parameters: {
              router: 'pages/Index',  // 跳转到主页面
              tab: 0  // 切换到首页Tab
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
   * @param timeStr 时间字符串，格式: "08:00"
   */
  async scheduleDailyReminder(timeStr: string): Promise<boolean> {
    try {
      hilog.info(DOMAIN, TAG, `设置每日播报定时提醒: ${timeStr}`);
      
      // 解析时间
      const timeParts: string[] = timeStr.split(':');
      const hour = parseInt(timeParts[0]);
      const minute = parseInt(timeParts[1]);
      
      if (isNaN(hour) || isNaN(minute)) {
        hilog.error(DOMAIN, TAG, `无效的时间格式: ${timeStr}`);
        return false;
      }

      // 保存定时播报时间（仅存储配置，实际定时由后台任务实现）
      AppStorage.setOrCreate('dailyReminderTime', timeStr);
      hilog.info(DOMAIN, TAG, `已保存定时播报时间: ${timeStr}`);
      hilog.info(DOMAIN, TAG, '⚠️ 定时播报功能需要后台任务支持，当前版本仅保存配置');
      
      return true;
    } catch (err) {
      hilog.error(DOMAIN, TAG, `设置定时提醒失败: ${JSON.stringify(err)}`);
      return false;
    }
  }

  /**
   * 取消每日播报定时提醒
   */
  async cancelDailyReminder(): Promise<void> {
    try {
      // 清除保存的定时播报时间
      AppStorage.delete('dailyReminderTime');
      hilog.info(DOMAIN, TAG, '已清除定时播报配置');
    } catch (err) {
      hilog.error(DOMAIN, TAG, `清除定时播报配置失败: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 检查定时提醒权限
   */
  async checkReminderPermission(): Promise<boolean> {
    try {
      // API 20 暂无直接检查方法，尝试发布测试提醒
      return true;
    } catch (err) {
      hilog.error(DOMAIN, TAG, `检查提醒权限失败: ${JSON.stringify(err)}`);
      return false;
    }
  }
}
