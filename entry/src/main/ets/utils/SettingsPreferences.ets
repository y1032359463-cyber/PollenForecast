import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const SETTINGS_PREFERENCES_NAME = 'app_settings';
const DOMAIN = 0x0000;

/**
 * 应用设置的 Preferences 持久化工具
 *
 * 负责：
 * - 在应用启动时从 Preferences 恢复到 AppStorage
 * - 在设置变更时写入 Preferences
 */
export class SettingsPreferences {
  // Preferences 实例（懒加载）
  private static pref: preferences.Preferences | undefined = undefined;

  /**
   * 初始化 Preferences 实例
   */
  static async init(context: common.Context): Promise<void> {
    if (SettingsPreferences.pref) {
      return;
    }
    try {
      SettingsPreferences.pref = await preferences.getPreferences(context, SETTINGS_PREFERENCES_NAME);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to get preferences: %{public}s', JSON.stringify(err));
    }
  }

  private static async getBoolean(key: string, defaultValue: boolean): Promise<boolean> {
    if (!SettingsPreferences.pref) {
      return defaultValue;
    }
    try {
      const value: preferences.ValueType = await SettingsPreferences.pref.get(key, defaultValue);
      return value as boolean;
    } catch (_) {
      return defaultValue;
    }
  }

  private static async getNumber(key: string, defaultValue: number): Promise<number> {
    if (!SettingsPreferences.pref) {
      return defaultValue;
    }
    try {
      const value: preferences.ValueType = await SettingsPreferences.pref.get(key, defaultValue);
      return value as number;
    } catch (_) {
      return defaultValue;
    }
  }

  private static async getString(key: string, defaultValue: string): Promise<string> {
    if (!SettingsPreferences.pref) {
      return defaultValue;
    }
    try {
      const value: preferences.ValueType = await SettingsPreferences.pref.get(key, defaultValue);
      return value as string;
    } catch (_) {
      return defaultValue;
    }
  }

  private static async putBoolean(key: string, value: boolean): Promise<void> {
    if (!SettingsPreferences.pref) {
      return;
    }
    try {
      await SettingsPreferences.pref.put(key, value);
      await SettingsPreferences.pref.flush();
    } catch (_) {}
  }

  private static async putNumber(key: string, value: number): Promise<void> {
    if (!SettingsPreferences.pref) {
      return;
    }
    try {
      await SettingsPreferences.pref.put(key, value);
      await SettingsPreferences.pref.flush();
    } catch (_) {}
  }

  private static async putString(key: string, value: string): Promise<void> {
    if (!SettingsPreferences.pref) {
      return;
    }
    try {
      await SettingsPreferences.pref.put(key, value);
      await SettingsPreferences.pref.flush();
    } catch (_) {}
  }

  /**
   * 从 Preferences 恢复设置到 AppStorage
   * 在应用启动时调用，确保杀进程重启后能还原用户配置
   */
  static async restoreSettingsToAppStorage(): Promise<void> {
    // 通用设置
    const vibrationEnabled = await SettingsPreferences.getBoolean('vibrationEnabled', true);
    AppStorage.setOrCreate('vibrationEnabled', vibrationEnabled);

    const gripDetectionEnabled = await SettingsPreferences.getBoolean('gripDetectionEnabled', false);
    AppStorage.setOrCreate('gripDetectionEnabled', gripDetectionEnabled);

    const appearanceMode = await SettingsPreferences.getNumber('appearanceMode', 0);
    AppStorage.setOrCreate('appearanceMode', appearanceMode);

    const pollenDataSource = await SettingsPreferences.getString('pollenDataSource', 'AUTO');
    AppStorage.setOrCreate('pollenDataSource', pollenDataSource);

    // 通知设置
    const notificationEnabled = await SettingsPreferences.getBoolean('notificationEnabled', false);
    AppStorage.setOrCreate('notificationEnabled', notificationEnabled);

    const pollenAlertEnabled = await SettingsPreferences.getBoolean('pollenAlertEnabled', true);
    AppStorage.setOrCreate('pollenAlertEnabled', pollenAlertEnabled);

    const dailyReportEnabled = await SettingsPreferences.getBoolean('dailyReportEnabled', true);
    AppStorage.setOrCreate('dailyReportEnabled', dailyReportEnabled);

    const dailyReportTime = await SettingsPreferences.getString('dailyReportTime', '08:00');
    AppStorage.setOrCreate('dailyReportTime', dailyReportTime);

    const dailyReminderTime = await SettingsPreferences.getString('dailyReminderTime', '08:00');
    AppStorage.setOrCreate('dailyReminderTime', dailyReminderTime);
  }

  // ===== 对外暴露的设置写入方法 =====

  static async setVibrationEnabled(value: boolean): Promise<void> {
    await SettingsPreferences.putBoolean('vibrationEnabled', value);
  }

  static async setGripDetectionEnabled(value: boolean): Promise<void> {
    await SettingsPreferences.putBoolean('gripDetectionEnabled', value);
  }

  static async setAppearanceMode(value: number): Promise<void> {
    await SettingsPreferences.putNumber('appearanceMode', value);
  }

  static async setPollenDataSource(value: string): Promise<void> {
    await SettingsPreferences.putString('pollenDataSource', value);
  }

  static async setNotificationEnabled(value: boolean): Promise<void> {
    await SettingsPreferences.putBoolean('notificationEnabled', value);
  }

  static async setPollenAlertEnabled(value: boolean): Promise<void> {
    await SettingsPreferences.putBoolean('pollenAlertEnabled', value);
  }

  static async setDailyReportEnabled(value: boolean): Promise<void> {
    await SettingsPreferences.putBoolean('dailyReportEnabled', value);
  }

  static async setDailyReportTime(value: string): Promise<void> {
    await SettingsPreferences.putString('dailyReportTime', value);
  }

  static async setDailyReminderTime(value: string): Promise<void> {
    await SettingsPreferences.putString('dailyReminderTime', value);
  }
}
