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
  private readonly KEY_CHARACTER = 'character_type';  // 新增：角色类型key
  private readonly KEY_SOUND = 'sound_enabled';  // 新增：音效开关key

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
  async getSound(): Promise<boolean> {
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
  async setSound(enabled: boolean): Promise<void> {
    if (this.dataPreferences === null) {
      return;
    }
    try {
      await this.dataPreferences.put(this.KEY_SOUND, enabled);
      await this.dataPreferences.flush();
      console.info(`[PreferencesUtils] setSound: ${enabled} saved successfully`);
    } catch (err) {
      console.error('Failed to set sound enabled:', JSON.stringify(err));
    }
  }
}

export default new PreferencesUtils();
