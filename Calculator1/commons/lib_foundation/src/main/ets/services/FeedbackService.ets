/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { vibrator } from '@kit.SensorServiceKit';
import { textToSpeech } from '@kit.CoreSpeechKit';
import { media } from '@kit.MediaKit';
import { audio } from '@kit.AudioKit';
import { resourceManager } from '@kit.LocalizationKit';

/**
 * 反馈服务模块 - 提供振动、音效、语音播报功能
 *
 * 使用方法:
 * 1. vibrateFeedback() - 触发振动
 * 2. playKeySound() - 播放按键音
 * 3. speakText('内容') - 语音播报
 */

// 模块级变量
let ttsEngine: textToSpeech.TextToSpeechEngine | null = null;
let isInitialized: boolean = false;
let soundPool: media.SoundPool | null = null;
let soundID: number = -1;
let isSoundPlayerReady: boolean = false;

/**
 * 初始化音效播放器
 */
export async function initSoundPlayer(resMgr: resourceManager.ResourceManager): Promise<void> {
  if (isSoundPlayerReady) {
    return;
  }

  try {
    // 创建音频渲染参数
    const audioRendererInfo: audio.AudioRendererInfo = {
      usage: audio.StreamUsage.STREAM_USAGE_NOTIFICATION,  // 使用通知音效类型
      rendererFlags: 1  // 启用低时延模式
    };

    // 创建 SoundPool 实例(最大播放流数1，只需播放单一按键音)
    soundPool = await media.createSoundPool(1, audioRendererInfo);
    
    // 加载音频资源(需要在 rawfile 目录创建 click.mp3)
    // 注意: 如果没有音频文件，这里会失败，我们提供降级方案
    try {
      const fd = await resMgr.getRawFd('click.mp3');
      soundID = await soundPool.load(fd.fd, fd.offset, fd.length);
      isSoundPlayerReady = true;
      console.info('[FeedbackService] 音效播放器初始化成功，音效ID:', soundID);
    } catch (fileError) {
      console.warn('[FeedbackService] 音效文件不存在，将使用振动替代:', JSON.stringify(fileError));
      isSoundPlayerReady = false;
    }
  } catch (error) {
    console.error('[FeedbackService] 音效播放器初始化失败:', JSON.stringify(error));
    isSoundPlayerReady = false;
  }
}

/**
 * 初始化TTS引擎
 */
export async function initTTS(): Promise<void> {
  if (isInitialized) {
    return;
  }

  try {
    // 创建TTS引擎配置
    const extraParam: Record<string, Object> = {
      'style': 'interaction-broadcast',
      'locate': 'CN',
      'name': 'zh-CN-default'
    };

    const initParams: textToSpeech.CreateEngineParams = {
      language: 'zh-CN',
      person: 0,
      online: 1,
      extraParams: extraParam
    };

    ttsEngine = await textToSpeech.createEngine(initParams);
    isInitialized = true;
    console.info('[FeedbackService] TTS引擎初始化成功');
  } catch (error) {
    console.error('[FeedbackService] TTS引擎初始化失败:', JSON.stringify(error));
    isInitialized = false;
  }
}

/**
 * 触发振动反馈
 * @param duration 振动时长(ms)，默认30ms
 */
export function vibrateFeedback(duration: number = 30): void {
  const enabled = AppStorage.get<boolean>('vibration_enabled') ?? true;
  if (!enabled) {
    return;
  }

  try {
    vibrator.startVibration({
      type: 'time',
      duration: duration
    }, {
      id: 0,
      usage: 'touch'
    }, (error: Error) => {
      if (error) {
        console.error('[FeedbackService] 振动失败:', error.message);
      }
    });
  } catch (error) {
    console.error('[FeedbackService] 振动调用异常:', JSON.stringify(error));
  }
}

/**
 * 播放按键音效
 */
export function playKeySound(): void {
  const enabled = AppStorage.get<boolean>('sound_enabled') ?? true;
  if (!enabled) {
    return;
  }

  // 如果音效播放器已就绪，播放音效
  if (isSoundPlayerReady && soundPool && soundID !== -1) {
    try {
      const playParameters: media.PlayParameters = {
        loop: 0,  // 不循环
        rate: 1,  // 正常速度
        leftVolume: 0.5,  // 左声道音量
        rightVolume: 0.5,  // 右声道音量
        priority: 0  // 优先级
      };
      soundPool.play(soundID, playParameters);
    } catch (error) {
      console.error('[FeedbackService] 播放按键音效失败:', JSON.stringify(error));
    }
  } else {
    // 降级方案: 使用短促振动模拟按键音
    try {
      vibrator.startVibration({
        type: 'time',
        duration: 15
      }, {
        id: 0,
        usage: 'touch'
      }, (error: Error) => {
        if (error) {
          console.error('[FeedbackService] 按键音振动失败:', error.message);
        }
      });
    } catch (error) {
      console.error('[FeedbackService] 按键音振动调用异常:', JSON.stringify(error));
    }
  }
}

/**
 * 语音播报
 * @param text 要播报的文本内容
 */
export async function speakText(text: string): Promise<void> {
  const enabled = AppStorage.get<boolean>('tts_enabled') ?? false;
  if (!enabled) {
    return;
  }

  if (!isInitialized || !ttsEngine) {
    await initTTS();
  }

  if (!ttsEngine) {
    console.error('[FeedbackService] TTS引擎不可用');
    return;
  }

  try {
    // 配置语音参数
    const speakParams: textToSpeech.SpeakParams = {
      requestId: Date.now().toString(),
      extraParams: {
        'speed': 1.0,
        'volume': 0.5,  // 降低50%音量
        'pitch': 1.0,
        'audioType': 'pcm'
      }
    };

    // 设置回调
    const speakListener: textToSpeech.SpeakListener = {
      onStart: (requestId: string, response: textToSpeech.StartResponse) => {
        console.info(`[FeedbackService] TTS开始播放: ${requestId}`);
      },
      onComplete: (requestId: string, response: textToSpeech.CompleteResponse) => {
        console.info(`[FeedbackService] TTS播放完成: ${requestId}`);
      },
      onStop: (requestId: string, response: textToSpeech.StopResponse) => {
        console.info(`[FeedbackService] TTS停止: ${requestId}`);
      },
      onError: (requestId: string, errorCode: number, errorMessage: string) => {
        console.error(`[FeedbackService] TTS错误: ${errorCode} - ${errorMessage}`);
      }
    };

    ttsEngine.setListener(speakListener);
    ttsEngine.speak(text, speakParams);
  } catch (error) {
    console.error('[FeedbackService] 语音播报失败:', JSON.stringify(error));
  }
}

/**
 * 停止语音播报
 */
export function stopSpeak(): void {
  if (ttsEngine) {
    try {
      ttsEngine.stop();
    } catch (error) {
      console.error('[FeedbackService] 停止语音播报失败:', JSON.stringify(error));
    }
  }
}

/**
 * 释放音效播放器资源
 */
export function releaseSoundPlayer(): void {
  if (soundPool) {
    try {
      if (soundID !== -1) {
        soundPool.unload(soundID);
        soundID = -1;
      }
      soundPool.release();
      soundPool = null;
      isSoundPlayerReady = false;
      console.info('[FeedbackService] 音效播放器已释放');
    } catch (error) {
      console.error('[FeedbackService] 释放音效播放器失败:', JSON.stringify(error));
    }
  }
}

/**
 * 释放TTS资源
 */
export function releaseTTS(): void {
  if (ttsEngine) {
    try {
      ttsEngine.shutdown();
      ttsEngine = null;
      isInitialized = false;
    } catch (error) {
      console.error('[FeedbackService] 释放TTS资源失败:', JSON.stringify(error));
    }
  }
}

/**
 * 释放所有反馈服务资源
 */
export function releaseAllFeedback(): void {
  releaseSoundPlayer();
  releaseTTS();
}

/**
 * 数字转语音文本
 * @param num 数字字符串
 * @returns 可读的语音文本
 */
export function numberToSpeakText(num: string): string {
  const digitMap: Record<string, string> = {
    '0': '零',
    '1': '一',
    '2': '二',
    '3': '三',
    '4': '四',
    '5': '五',
    '6': '六',
    '7': '七',
    '8': '八',
    '9': '九',
    '.': '点',
    '-': '负',
    '+': '加',
    '×': '乘',
    '÷': '除',
    '=': '等于',
    '%': '百分之'
  };

  let result = '';
  for (const char of num) {
    result += digitMap[char] || char;
  }
  return result;
}
