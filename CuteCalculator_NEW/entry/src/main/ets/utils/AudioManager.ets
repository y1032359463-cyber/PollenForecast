/**
 * Audio Manager
 * 音效播放管理器（支持WAV和MP3格式）
 * 
 * 功能：
 * - 播放8-bit复古音效
 * - 根据设置开关控制音效
 * - 内存管理（预加载+释放）
 * 
 * 使用方法：
 * AudioManager.getInstance().play('BUTTON_PRESS');
 */

import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { RetroPixelTheme } from '../common/RetroPixelTheme';
import PreferencesUtils from './PreferencesUtils';

export type AudioEffectType = 'BUTTON_PRESS' | 'CALCULATE_SUCCESS' | 'CLEAR' | 'DELETE' | 'ERROR';

export class AudioManager {
  private static instance: AudioManager;
  private players: Map<AudioEffectType, media.AVPlayer> = new Map();
  private isInitialized: boolean = false;
  
  private constructor() {
    // 私有构造函数，单例模式
  }
  
  /**
   * 获取单例实例
   */
  static getInstance(): AudioManager {
    if (!AudioManager.instance) {
      AudioManager.instance = new AudioManager();
    }
    return AudioManager.instance;
  }
  
  /**
   * 初始化音效播放器（预加载所有音效）
   */
  async initialize(): Promise<void> {
    if (this.isInitialized) {
      console.info('[AudioManager] Already initialized');
      return;
    }
    
    try {
      console.info('[AudioManager] Initializing audio players...');
      
      const effectTypes: AudioEffectType[] = [
        'BUTTON_PRESS',
        'CALCULATE_SUCCESS',
        'CLEAR',
        'DELETE',
        'ERROR'
      ];
      
      for (const type of effectTypes) {
        await this.createPlayer(type);
      }
      
      this.isInitialized = true;
      console.info('[AudioManager] Initialization complete');
    } catch (err) {
      console.error('[AudioManager] Initialization failed:', JSON.stringify(err));
    }
  }
  
  /**
   * 创建单个音效播放器
   */
  private async createPlayer(type: AudioEffectType): Promise<void> {
    try {
      const player = await media.createAVPlayer();
      
      // 设置状态回调
      player.on('stateChange', (state: string) => {
        console.debug(`[AudioManager] Player ${type} state: ${state}`);
      });
      
      // 设置错误回调
      player.on('error', (err: BusinessError) => {
        console.error(`[AudioManager] Player ${type} error:`, JSON.stringify(err));
      });
      
      // 获取音效文件路径
      const audioPath = RetroPixelTheme.getAudioPath(type);
      const rawFd = getContext().resourceManager.getRawFdSync(audioPath);
      const fdSrc: media.AVFileDescriptor = {
        fd: rawFd.fd,
        offset: rawFd.offset,
        length: rawFd.length
      };
      
      player.fdSrc = fdSrc;
      
      // 等待initialized状态后调用prepare
      await new Promise<void>((resolve, reject) => {
        const timeout = setTimeout(() => {
          reject(new Error(`Player ${type} initialize timeout`));
        }, 3000);
        
        const stateHandler = (state: string) => {
          if (state === 'initialized') {
            clearTimeout(timeout);
            player.off('stateChange', stateHandler);
            resolve();
          }
        };
        player.on('stateChange', stateHandler);
      });
      
      // 调用prepare进入prepared状态
      player.prepare();
      
      await new Promise<void>((resolve, reject) => {
        const timeout = setTimeout(() => {
          reject(new Error(`Player ${type} prepare timeout`));
        }, 3000);
        
        const stateHandler = (state: string) => {
          if (state === 'prepared') {
            clearTimeout(timeout);
            player.off('stateChange', stateHandler);
            resolve();
          }
        };
        player.on('stateChange', stateHandler);
      });
      
      // 设置音量和循环模式
      player.loop = false;  // 不循环播放
      if (type === 'BUTTON_PRESS') {
        player.setVolume(0.13);  // 按钮音效13%
      } else {
        player.setVolume(0.6);  // 其他音效60%
      }
      
      this.players.set(type, player);
      console.info(`[AudioManager] Player ${type} created successfully`);
    } catch (err) {
      console.error(`[AudioManager] Failed to create player ${type}:`, JSON.stringify(err));
    }
  }
  
  /**
   * 播放指定音效
   * @param type 音效类型
   */
  async play(type: AudioEffectType): Promise<void> {
    // 检查音效开关
    const soundEnabled = await PreferencesUtils.getSound();
    if (!soundEnabled) {
      console.debug('[AudioManager] Sound is disabled by user settings');
      return;
    }
    
    // 检查是否初始化
    if (!this.isInitialized) {
      console.warn('[AudioManager] Not initialized, initializing now...');
      await this.initialize();
    }
    
    const player = this.players.get(type);
    if (!player) {
      console.error(`[AudioManager] Player not found for type: ${type}`);
      return;
    }
    
    try {
      // 如果正在播放,先停止回到起点
      if (player.state === 'playing') {
        await player.seek(0);  // 回到起点立即重播
        console.debug(`[AudioManager] Replaying sound: ${type}`);
        return;
      }
      
      // 如果已完成,回到起点
      if (player.state === 'completed') {
        await player.seek(0);
      }
      
      // 如果已停止,需要reset
      if (player.state === 'stopped') {
        await player.reset();
        
        const audioPath = RetroPixelTheme.getAudioPath(type);
        const rawFd = getContext().resourceManager.getRawFdSync(audioPath);
        const fdSrc: media.AVFileDescriptor = {
          fd: rawFd.fd,
          offset: rawFd.offset,
          length: rawFd.length
        };
        player.fdSrc = fdSrc;
        
        await new Promise<void>((resolve) => {
          const stateHandler = (state: string) => {
            if (state === 'initialized') {
              player.off('stateChange', stateHandler);
              resolve();
            }
          };
          player.on('stateChange', stateHandler);
        });
        
        player.prepare();
        await new Promise<void>((resolve) => {
          const stateHandler = (state: string) => {
            if (state === 'prepared') {
              player.off('stateChange', stateHandler);
              resolve();
            }
          };
          player.on('stateChange', stateHandler);
        });
      }
      
      // 播放音效
      await player.play();
      console.debug(`[AudioManager] Playing sound: ${type}`);
    } catch (err) {
      console.error(`[AudioManager] Failed to play ${type}:`, JSON.stringify(err));
    }
  }
  
  /**
   * 停止所有音效
   */
  async stopAll(): Promise<void> {
    console.info('[AudioManager] Stopping all audio players');
    
    this.players.forEach(async (player: media.AVPlayer, type: string) => {
      try {
        await player.stop();
      } catch (err) {
        console.error(`[AudioManager] Failed to stop ${type}:`, JSON.stringify(err));
      }
    });
  }
  
  /**
   * 释放资源
   */
  async release(): Promise<void> {
    console.info('[AudioManager] Releasing audio resources');
    
    this.players.forEach(async (player: media.AVPlayer, type: string) => {
      try {
        await player.release();
      } catch (err) {
        console.error(`[AudioManager] Failed to release ${type}:`, JSON.stringify(err));
      }
    });
    
    this.players.clear();
    this.isInitialized = false;
  }
  
  /**
   * 设置音量（0.0 ~ 1.0）
   * @param volume 音量值
   */
  async setVolume(volume: number): Promise<void> {
    const clampedVolume = Math.max(0, Math.min(1, volume));
    
    for (const player of this.players.values()) {
      try {
        player.setVolume(clampedVolume);
      } catch (err) {
        console.error('[AudioManager] Failed to set volume:', JSON.stringify(err));
      }
    }
  }
}

export default AudioManager;
