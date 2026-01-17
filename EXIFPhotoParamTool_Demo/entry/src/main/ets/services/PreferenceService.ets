/**
 * 用户偏好服务
 * 管理UI风格、首次启动标记、RAW解析模式等设置
 */
import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { UIStyle, UserPreferences, DEFAULT_PREFERENCES } from '../models/PhotoRecord'

// RAW解析模式类型（与ExifParserService保持一致）
export type RawParseMode = 'embedded_jpeg' | 'libraw'

const PREFERENCES_NAME = 'exif_memo_preferences'
const KEY_UI_STYLE = 'ui_style'
const KEY_FIRST_LAUNCH = 'is_first_launch'
const KEY_LAST_BACKUP = 'last_backup_time'
const KEY_RAW_PARSE_MODE = 'raw_parse_mode'

export class PreferenceService {
  private context: common.UIAbilityContext
  private dataPreferences: preferences.Preferences | null = null

  constructor(context: common.UIAbilityContext) {
    this.context = context
  }

  // 初始化Preferences
  async init(): Promise<void> {
    try {
      this.dataPreferences = await preferences.getPreferences(this.context, PREFERENCES_NAME)
    } catch (err) {
      hilog.error(0x0021, 'Storage', 'PreferenceService init failed:' + err)
    }
  }

  // 获取UI风格
  async getUIStyle(): Promise<UIStyle> {
    if (!this.dataPreferences) {
      await this.init()
    }
    try {
      const value = await this.dataPreferences?.get(KEY_UI_STYLE, DEFAULT_PREFERENCES.uiStyle)
      return value as UIStyle
    } catch (err) {
      hilog.error(0x0021, 'Storage', 'getUIStyle failed:' + err)
      return DEFAULT_PREFERENCES.uiStyle
    }
  }

  // 设置UI风格
  async setUIStyle(style: UIStyle): Promise<void> {
    if (!this.dataPreferences) {
      await this.init()
    }
    try {
      await this.dataPreferences?.put(KEY_UI_STYLE, style)
      await this.dataPreferences?.flush()
    } catch (err) {
      hilog.error(0x0021, 'Storage', 'setUIStyle failed:' + err)
    }
  }

  // 检查是否首次启动
  async isFirstLaunch(): Promise<boolean> {
    if (!this.dataPreferences) {
      await this.init()
    }
    try {
      const value = await this.dataPreferences?.get(KEY_FIRST_LAUNCH, true)
      return value as boolean
    } catch (err) {
      hilog.error(0x0021, 'Storage', 'isFirstLaunch failed:' + err)
      return true
    }
  }

  // 标记已完成首次启动
  async markFirstLaunchDone(): Promise<void> {
    if (!this.dataPreferences) {
      await this.init()
    }
    try {
      await this.dataPreferences?.put(KEY_FIRST_LAUNCH, false)
      await this.dataPreferences?.flush()
    } catch (err) {
      hilog.error(0x0021, 'Storage', 'markFirstLaunchDone failed:' + err)
    }
  }

  // 获取所有偏好设置
  async getAllPreferences(): Promise<UserPreferences> {
    const uiStyle = await this.getUIStyle()
    const isFirstLaunch = await this.isFirstLaunch()
    
    let lastBackupTime: number | undefined
    try {
      const value = await this.dataPreferences?.get(KEY_LAST_BACKUP, 0)
      lastBackupTime = value as number
      if (lastBackupTime === 0) {
        lastBackupTime = undefined
      }
    } catch (err) {
      lastBackupTime = undefined
    }

    return {
      uiStyle,
      isFirstLaunch,
      lastBackupTime
    }
  }

  // 获取RAW解析模式
  async getRawParseMode(): Promise<RawParseMode> {
    if (!this.dataPreferences) {
      await this.init()
    }
    try {
      const value = await this.dataPreferences?.get(KEY_RAW_PARSE_MODE, 'embedded_jpeg')
      return value as RawParseMode
    } catch (err) {
      hilog.error(0x0021, 'Storage', 'getRawParseMode failed:' + err)
      return 'embedded_jpeg'
    }
  }

  // 设置RAW解析模式
  async setRawParseMode(mode: RawParseMode): Promise<void> {
    if (!this.dataPreferences) {
      await this.init()
    }
    try {
      await this.dataPreferences?.put(KEY_RAW_PARSE_MODE, mode)
      await this.dataPreferences?.flush()
      hilog.info(0x0021, 'Storage', `[Preference] RAW解析模式已保存: ${mode}`)
    } catch (err) {
      hilog.error(0x0021, 'Storage', 'setRawParseMode failed:' + err)
    }
  }

  // 重置所有偏好（用于测试）
  async resetAll(): Promise<void> {
    if (!this.dataPreferences) {
      await this.init()
    }
    try {
      await this.dataPreferences?.clear()
      await this.dataPreferences?.flush()
    } catch (err) {
      hilog.error(0x0021, 'Storage', 'resetAll failed:' + err)
    }
  }
}
