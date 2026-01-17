/*
 * SoundUtils - 按键音效工具类
 * Button Sound Effect Utility
 * 
 * 使用 SoundPool 播放短音效，符合华为音频规格：
 * - 短音、瞬态音场景使用 share 焦点策略，不打断其他音频
 */

import { media } from '@kit.MediaKit';
import { audio } from '@kit.AudioKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 按键音效工具类
 * 使用 SoundPool 播放短音效（符合华为音频规格-26）
 */
export class SoundUtils {
  private static soundPool: media.SoundPool | null = null;
  private static isInitialized: boolean = false;
  private static context: common.UIAbilityContext | null = null;
  
  // 音效ID缓存
  private static keySoundId: number = -1;
  private static enterSoundId: number = -1;
  private static clearSoundId: number = -1;

  /**
   * 初始化音效播放器
   * 使用 SoundPool，焦点策略为 share，不打断其他音频
   */
  static async init(context: common.UIAbilityContext): Promise<void> {
    if (SoundUtils.isInitialized) {
      return;
    }

    SoundUtils.context = context;

    try {
      // 创建音频渲染信息，使用 SONIFICATION 类型（适合短音效）
      const audioRendererInfo: audio.AudioRendererInfo = {
        usage: audio.StreamUsage.STREAM_USAGE_NOTIFICATION,  // 通知音，适合短音效
        rendererFlags: 0
      };

      // 创建 SoundPool，最多同时播放3个音效
      SoundUtils.soundPool = await media.createSoundPool(3, audioRendererInfo);
      
      // 预加载音效文件
      await SoundUtils.preloadSounds();
      
      SoundUtils.isInitialized = true;
      console.info('[SoundUtils] SoundPool initialized successfully');
    } catch (error) {
      const err = error as BusinessError;
      console.error(`[SoundUtils] Failed to create SoundPool. Code: ${err.code}, message: ${err.message}`);
    }
  }

  /**
   * 预加载所有音效
   */
  private static async preloadSounds(): Promise<void> {
    if (!SoundUtils.soundPool || !SoundUtils.context) {
      return;
    }

    try {
      const resourceManager = SoundUtils.context.resourceManager;

      // 加载按键音效
      try {
        const keyFd = await resourceManager.getRawFd('sounds/key_click.mp3');
        SoundUtils.keySoundId = await SoundUtils.soundPool.load(keyFd.fd, keyFd.offset, keyFd.length);
        console.info(`[SoundUtils] key_click loaded, id: ${SoundUtils.keySoundId}`);
      } catch (e) {
        console.warn('[SoundUtils] key_click.mp3 not found, skip');
      }

      // 加载等号音效
      try {
        const enterFd = await resourceManager.getRawFd('sounds/key_enter.mp3');
        SoundUtils.enterSoundId = await SoundUtils.soundPool.load(enterFd.fd, enterFd.offset, enterFd.length);
        console.info(`[SoundUtils] key_enter loaded, id: ${SoundUtils.enterSoundId}`);
      } catch (e) {
        console.warn('[SoundUtils] key_enter.mp3 not found, skip');
      }

      // 加载清除音效
      try {
        const clearFd = await resourceManager.getRawFd('sounds/key_clear.mp3');
        SoundUtils.clearSoundId = await SoundUtils.soundPool.load(clearFd.fd, clearFd.offset, clearFd.length);
        console.info(`[SoundUtils] key_clear loaded, id: ${SoundUtils.clearSoundId}`);
      } catch (e) {
        console.warn('[SoundUtils] key_clear.mp3 not found, skip');
      }
    } catch (error) {
      console.error('[SoundUtils] Failed to preload sounds');
    }
  }

  /**
   * 播放按键音效（猫咪敲键盘声）
   */
  static async playKeySound(): Promise<void> {
    if (!SoundUtils.soundPool || SoundUtils.keySoundId < 0) {
      return;
    }

    try {
      // 播放参数：循环次数0（不循环），左右声道1.0，播放速率1.0，优先级0，音量0.6
      const playParams: media.PlayParameters = {
        loop: 0,
        rate: 1.0,
        leftVolume: 0.6,
        rightVolume: 0.6,
        priority: 0
      };
      await SoundUtils.soundPool.play(SoundUtils.keySoundId, playParams);
    } catch (error) {
      // 静默处理错误，不影响用户体验
    }
  }

  /**
   * 播放等号音效（稍长的敲击声）
   */
  static async playEqualSound(): Promise<void> {
    if (!SoundUtils.soundPool || SoundUtils.enterSoundId < 0) {
      return;
    }

    try {
      const playParams: media.PlayParameters = {
        loop: 0,
        rate: 1.0,
        leftVolume: 0.7,
        rightVolume: 0.7,
        priority: 0
      };
      await SoundUtils.soundPool.play(SoundUtils.enterSoundId, playParams);
    } catch (error) {
      // 静默处理
    }
  }

  /**
   * 播放清除音效
   */
  static async playClearSound(): Promise<void> {
    if (!SoundUtils.soundPool || SoundUtils.clearSoundId < 0) {
      return;
    }

    try {
      const playParams: media.PlayParameters = {
        loop: 0,
        rate: 1.0,
        leftVolume: 0.7,
        rightVolume: 0.7,
        priority: 0
      };
      await SoundUtils.soundPool.play(SoundUtils.clearSoundId, playParams);
    } catch (error) {
      // 静默处理
    }
  }

  /**
   * 释放资源
   */
  static release(): void {
    if (SoundUtils.soundPool) {
      SoundUtils.soundPool.release();
      SoundUtils.soundPool = null;
    }
    SoundUtils.keySoundId = -1;
    SoundUtils.enterSoundId = -1;
    SoundUtils.clearSoundId = -1;
    SoundUtils.isInitialized = false;
    SoundUtils.context = null;
  }
}
