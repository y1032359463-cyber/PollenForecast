/*
 * PreferencesUtils - Simplified version
 * 简化的偏好设置工具类
 */

import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

/**
 * 简化的偏好设置管理类
 */
class PreferencesUtils {
  private dataPreferences: preferences.Preferences | null = null;
  private readonly STORE_NAME = 'cutecalculator_preferences';
  private readonly KEY_VIBRATE = 'vibrate_enabled';
  private readonly KEY_CHARACTER = 'character_type';
  private readonly KEY_SOUND = 'sound_enabled'; // 音效开关
  private readonly KEY_THEME = 'theme_type'; // 主题类型
  private readonly KEY_BUTTON_SHAPE = 'button_shape';      // 按钮形状
  private readonly KEY_KEYBOARD_THEME = 'keyboard_theme';  // 键盘主题
  private readonly KEY_BUTTON_BORDER = 'button_border';    // 按键边框

  /**
   * 初始化 Preferences
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    try {
      this.dataPreferences = await preferences.getPreferences(context, this.STORE_NAME);
    } catch (err) {
      console.error('Failed to init preferences:', JSON.stringify(err));
    }
  }

  /**
   * 获取振动开关状态
   */
  async getVibrateEnabled(): Promise<boolean> {
    if (this.dataPreferences === null) {
      return true; // 默认开启
    }
    try {
      const value = await this.dataPreferences.get(this.KEY_VIBRATE, true);
      return value as boolean;
    } catch (err) {
      console.error('Failed to get vibrate enabled:', JSON.stringify(err));
      return true;
    }
  }

  /**
   * 设置振动开关状态
   */
  async setVibrateEnabled(enabled: boolean): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      await this.dataPreferences.put(this.KEY_VIBRATE, enabled);
      await this.dataPreferences.flush();
    } catch (err) {
      console.error('Failed to set vibrate enabled:', JSON.stringify(err));
    }
  }

  /**
   * 获取角色类型
   */
  async getCharacterType(): Promise<string> {
    if (this.dataPreferences === null) {
      return 'whitecat'; // 默认白猫
    }
    try {
      const value = await this.dataPreferences.get(this.KEY_CHARACTER, 'whitecat');
      console.info(`[PreferencesUtils] getCharacterType: ${value}`);
      return value as string;
    } catch (err) {
      console.error('Failed to get character type:', JSON.stringify(err));
      return 'whitecat';
    }
  }

  /**
   * 设置角色类型
   */
  async setCharacterType(type: string): Promise<void> {
    if (this.dataPreferences === null) {
      console.error('[PreferencesUtils] setCharacterType failed: dataPreferences is null');
      return;
    }
    try {
      await this.dataPreferences.put(this.KEY_CHARACTER, type);
      await this.dataPreferences.flush();
      console.info(`[PreferencesUtils] setCharacterType: ${type} saved successfully`);
    } catch (err) {
      console.error('Failed to set character type:', JSON.stringify(err));
    }
  }

  /**
   * 获取音效开关状态
   */
  async getSoundEnabled(): Promise<boolean> {
    if (this.dataPreferences === null) {
      return true; // 默认开启
    }
    try {
      const value = await this.dataPreferences.get(this.KEY_SOUND, true);
      return value as boolean;
    } catch (err) {
      console.error('Failed to get sound enabled:', JSON.stringify(err));
      return true;
    }
  }

  /**
   * 设置音效开关状态
   */
  async setSoundEnabled(enabled: boolean): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      await this.dataPreferences.put(this.KEY_SOUND, enabled);
      await this.dataPreferences.flush();
    } catch (err) {
      console.error('Failed to set sound enabled:', JSON.stringify(err));
    }
  }

  /**
   * 获取主题类型
   */
  async getThemeType(): Promise<string> {
    if (this.dataPreferences === null) {
      return 'default'; // 默认主题
    }
    try {
      const value = await this.dataPreferences.get(this.KEY_THEME, 'default');
      return value as string;
    } catch (err) {
      console.error('Failed to get theme type:', JSON.stringify(err));
      return 'default';
    }
  }

  /**
   * 设置主题类型
   */
  async setThemeType(themeType: string): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      await this.dataPreferences.put(this.KEY_THEME, themeType);
      await this.dataPreferences.flush();
    } catch (err) {
      console.error('Failed to set theme type:', JSON.stringify(err));
    }
  }

  /**
   * 获取按钮形状
   * @returns 'circle' | 'rounded'，默认 'rounded'
   */
  async getButtonShape(): Promise<string> {
    if (this.dataPreferences === null) {
      return 'rounded'; // 默认圆角方形
    }
    try {
      const value = await this.dataPreferences.get(this.KEY_BUTTON_SHAPE, 'rounded');
      return value as string;
    } catch (err) {
      console.error('Failed to get button shape:', JSON.stringify(err));
      return 'rounded';
    }
  }

  /**
   * 设置按钮形状
   */
  async setButtonShape(shape: string): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      await this.dataPreferences.put(this.KEY_BUTTON_SHAPE, shape);
      await this.dataPreferences.flush();
    } catch (err) {
      console.error('Failed to set button shape:', JSON.stringify(err));
    }
  }

  /**
   * 获取键盘主题
   * @returns 'default' | 'catpaw' | 'star' | 'heart' | 'cloud'，默认 'default'
   */
  async getKeyboardTheme(): Promise<string> {
    if (this.dataPreferences === null) {
      return 'default'; // 默认主题
    }
    try {
      const value = await this.dataPreferences.get(this.KEY_KEYBOARD_THEME, 'default');
      return value as string;
    } catch (err) {
      console.error('Failed to get keyboard theme:', JSON.stringify(err));
      return 'default';
    }
  }

  /**
   * 设置键盘主题
   */
  async setKeyboardTheme(theme: string): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      await this.dataPreferences.put(this.KEY_KEYBOARD_THEME, theme);
      await this.dataPreferences.flush();
    } catch (err) {
      console.error('Failed to set keyboard theme:', JSON.stringify(err));
    }
  }

  /**
   * 获取按键边框风格
   * @returns 'flat' | '3d' | 'neon' | 'pixel'，默认 'flat'
   */
  async getButtonBorder(): Promise<string> {
    if (this.dataPreferences === null) {
      return 'flat'; // 默认扁平
    }
    try {
      const value = await this.dataPreferences.get(this.KEY_BUTTON_BORDER, 'flat');
      return value as string;
    } catch (err) {
      console.error('Failed to get button border:', JSON.stringify(err));
      return 'flat';
    }
  }

  /**
   * 设置按键边框风格
   */
  async setButtonBorder(border: string): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      await this.dataPreferences.put(this.KEY_BUTTON_BORDER, border);
      await this.dataPreferences.flush();
    } catch (err) {
      console.error('Failed to set button border:', JSON.stringify(err));
    }
  }

  /**
   * 批量获取所有配置（性能优化：一次数据库访问）
   * @returns 包含所有配置的 AllSettings 对象
   */
  async getAllSettings(): Promise<AllSettings> {
    const defaults = new AllSettings();

    if (this.dataPreferences === null) {
      return defaults;
    }

    try {
      // 并行获取所有配置
      const results = await Promise.all([
        this.dataPreferences.get(this.KEY_CHARACTER, defaults.characterType),
        this.dataPreferences.get(this.KEY_BUTTON_SHAPE, defaults.buttonShape),
        this.dataPreferences.get(this.KEY_KEYBOARD_THEME, defaults.keyboardTheme),
        this.dataPreferences.get(this.KEY_BUTTON_BORDER, defaults.buttonBorder),
        this.dataPreferences.get(this.KEY_VIBRATE, defaults.vibrateEnabled),
        this.dataPreferences.get(this.KEY_SOUND, defaults.soundEnabled)
      ]);

      const settings = new AllSettings();
      settings.characterType = results[0] as string;
      settings.buttonShape = results[1] as string;
      settings.keyboardTheme = results[2] as string;
      settings.buttonBorder = results[3] as string;
      settings.vibrateEnabled = results[4] as boolean;
      settings.soundEnabled = results[5] as boolean;
      return settings;
    } catch (err) {
      console.error('Failed to get all settings:', JSON.stringify(err));
      return defaults;
    }
  }
}

/**
 * 所有配置项的类
 */
export class AllSettings {
  characterType: string = 'whitecat';
  buttonShape: string = 'rounded';
  keyboardTheme: string = 'default';
  buttonBorder: string = 'flat';
  vibrateEnabled: boolean = true;
  soundEnabled: boolean = true;
}

export default new PreferencesUtils();
