/**
 * 语音助手悬浮按钮组件
 * 全局悬浮在所有页面之上，用于触发语音速记功能
 * 
 * 使用 @hms.ai.speechRecognizer API (CoreSpeechKit)
 * 需要手动采集音频并通过 writeAudio() 写入引擎
 */

import { VoiceParseUtil, type WorkRecordFields } from '../utils/VoiceParseUtil';
import { ThemeManager, type ThemeColors } from '../theme/ThemeManager';
import { router } from '@kit.ArkUI';
import { speechRecognizer } from '@kit.CoreSpeechKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { audio } from '@kit.AudioKit';
// canIUse 是全局函数，不需要导入

// 识别历史记录接口
export interface RecognitionHistoryItem {
  text: string;
  parsedFields: WorkRecordFields;
}

// 性能指标接口
export interface PerformanceMetrics {
  engineInitTime: number | null;
  audioStart: number | null;
  recognitionComplete: number | null;
}

// 配置接口定义
interface RecognitionModesConfig {
  ONLINE: number;
  OFFLINE: number;
}

interface EventCodesConfig {
  AUDIO_START: number;
  AUDIO_END: number;
}

interface CacheConfigType {
  MAX_HISTORY_ITEMS: number;
  MAX_TEMP_DATA_ITEMS: number;
}

interface RecordingConfigType {
  SAMPLE_RATE: number;
  CHANNELS: number;
  SAMPLE_FORMAT: audio.AudioSampleFormat;
  ENCODING_TYPE: audio.AudioEncodingType;
  SOURCE_TYPE: audio.SourceType;
}

interface StatusTextsConfig {
  INITIALIZING: string;
  CHECKING_PERMISSION: string;
  RECORDING: string;
  SPEAKING: string;
  RECOGNIZING: string;
}

// 按钮位置接口
interface ButtonPosition {
  x: number;
  y: number;
}

// 语音助手配置常量
const RECOGNITION_MODES: RecognitionModesConfig = {
  ONLINE: 0,
  OFFLINE: 1
};

const EVENT_CODES: EventCodesConfig = {
  AUDIO_START: 1,
  AUDIO_END: 3
};

const CACHE_CONFIG: CacheConfigType = {
  MAX_HISTORY_ITEMS: 10,
  MAX_TEMP_DATA_ITEMS: 5
};

const RECORDING_CONFIG: RecordingConfigType = {
  SAMPLE_RATE: 16000,
  CHANNELS: 1,
  SAMPLE_FORMAT: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
  ENCODING_TYPE: audio.AudioEncodingType.ENCODING_TYPE_RAW,
  SOURCE_TYPE: audio.SourceType.SOURCE_TYPE_MIC
};

const STATUS_TEXTS: StatusTextsConfig = {
  INITIALIZING: '初始化中...',
  CHECKING_PERMISSION: '检查权限...',
  RECORDING: '正在录音...',
  SPEAKING: '请说话...',
  RECOGNIZING: '识别中...'
};

// 错误信息配置使用函数替代索引签名
function getErrorMessage(errorCode: number, defaultMessage: string): string {
  const errorMessages: Record<number, string> = {
    // 引擎创建错误
    1002200001: '语音服务不可用，请检查：系统版本需 HarmonyOS 5.0+，确保已登录华为账号',
    1002200002: '开始识别失败',
    1002200006: '语音服务忙碌，请关闭其他使用麦克风的应用后重试',
    1002200007: '引擎未初始化',
    1002200008: '语音识别引擎已被销毁',
    1002200009: '内部服务错误，请重启应用或设备',
    // 音频相关错误
    2000100001: '音频设备初始化失败',
    2000100002: '音频采集失败',
    2000100003: '音频写入失败',
    // 权限相关错误
    3000100001: '麦克风权限被拒绝，请在设置中允许麦克风权限',
    3000100002: '权限检查失败'
  };
  return errorMessages[errorCode] || defaultMessage;
}

@Preview
@Component
export struct VoiceAssistantButton {
  @StorageProp('themeColors') themeColors: ThemeColors = ThemeManager.getInstance().colors
  @State private isRecording: boolean = false
  @State private statusText: string = ''
  @State private recordingDuration: number = 0 // 录音时长（秒）
  private recordingTimer: number | null = null // 录音时长计时器
  private voiceText: string = ''
  private parsedFields: WorkRecordFields | null = null
  private asrEngine: speechRecognizer.SpeechRecognitionEngine | null = null
  private audioCapturer: audio.AudioCapturer | null = null
  private sessionId: string = ''
  private recognitionResults: string[] = []
  private tempVoiceData: string[] = []
  private recognitionHistory: RecognitionHistoryItem[] = []
  private performanceMetrics: PerformanceMetrics = {
    engineInitTime: null,
    audioStart: null,
    recognitionComplete: null
  }
  
  // 悬浮按钮配置
  @State private buttonPosition: ButtonPosition = { x: 300, y: 600 } // 初始位置
  @State private buttonSize: number = 64 // 按钮尺寸
  @State private buttonScale: number = 1 // 按钮缩放比例
  @State private isDragging: boolean = false // 拖拽状态，用于区分点击和拖拽
  @State private startPosition: ButtonPosition = { x: 0, y: 0 } // 拖拽开始位置
  @State private screenWidth: number = 0 // 屏幕宽度
  @State private screenHeight: number = 0 // 屏幕高度

  // 语音识别状态变化回调
  private async onVoiceRecognized(text: string): Promise<void> {
    this.voiceText = text;
    // 解析语音文本
    this.parsedFields = await VoiceParseUtil.parseWorkRecord(text);

    // 保存到缓存
    if (this.parsedFields) {
      this.saveToCache(text, this.parsedFields);
    }

    // 跳转到添加工时记录页面，并传递解析结果
    try {
      await router.pushUrl({
        url: 'pages/AddRecordPage',
        params: {
          voiceParsedData: this.parsedFields,
          recognitionHistory: this.recognitionHistory
        }
      });
      this.logInfo('页面跳转成功');
    } catch (error) {
      const err = error as BusinessError;
      this.logError(`页面跳转失败: ${err.code}, ${err.message}`);
      this.showError('页面跳转失败，请检查应用配置');
    }
  }

  // 生成唯一会话ID
  private generateSessionId(): string {
    return `session_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
  }

  // 释放引擎资源
  private releaseEngine(): void {
    if (this.asrEngine) {
      try {
        this.asrEngine.shutdown();
        this.asrEngine = null;
        this.logInfo('语音识别引擎已释放');
      } catch (error) {
        this.logError(`释放语音识别引擎失败: ${error}`);
      }
    }
  }

  // 初始化语音识别引擎
  private async initAsrEngine(): Promise<void> {
    // 确保之前的引擎已释放（单实例限制）
    this.releaseEngine();

    try {
      // 直接使用离线模式，从日志看离线模式可以成功
      const initParams: speechRecognizer.CreateEngineParams = {
        language: 'zh-CN',
        online: RECOGNITION_MODES.OFFLINE // 直接使用离线模式，更可靠
      };

      this.logInfo('正在创建语音识别引擎(离线模式)...');
      
      // 记录引擎初始化开始时间
      this.performanceMetrics.engineInitTime = Date.now();
      
      // 创建语音识别引擎 (Promise 方式)
      this.asrEngine = await speechRecognizer.createEngine(initParams);
      this.logInfo('语音识别引擎创建成功');

      // 设置监听器
      this.setupListener();

      // 开始识别
      this.startAsrSession();

    } catch (error) {
      const err = error as BusinessError;
      this.logError(`创建语音识别引擎失败: ${err.code}, ${err.message}`);
      this.showError('语音识别引擎初始化失败，请重试');
      this.isRecording = false;
    }
  }

  // 处理引擎创建错误
  private handleEngineCreationError(error: BusinessError): void {
    // 引擎创建失败，给出详细提示
    const errorCode = error.code;
    const errorMessage = error.message;
    
    const errorMsg = getErrorMessage(errorCode, `语音识别初始化失败: ${errorMessage || errorCode}`);
    
    this.showError(errorMsg);
    this.isRecording = false;
  }

  // 设置识别监听器
  private setupListener(): void {
    if (!this.asrEngine) {
      return;
    }

    const listener: speechRecognizer.RecognitionListener = {
      // 开始识别回调
      onStart: (sessionId: string, eventMessage: string): void => {
        this.logInfo(`开始识别: ${sessionId}, ${eventMessage}`);
        this.statusText = STATUS_TEXTS.RECORDING;
        // 开始录音时长计时
        this.startRecordingTimer();
      },
      // 事件回调
      onEvent: (sessionId: string, eventCode: number, eventMessage: string): void => {
        this.logInfo(`事件: ${sessionId}, code=${eventCode}, msg=${eventMessage}`);
        
        // 处理不同事件
        switch (eventCode) {
          case EVENT_CODES.AUDIO_START:
            this.statusText = STATUS_TEXTS.SPEAKING;
            this.performanceMetrics.audioStart = Date.now();
            break;
          case EVENT_CODES.AUDIO_END:
            this.statusText = STATUS_TEXTS.RECOGNIZING;
            break;
          default:
            this.logInfo(`未知事件代码: ${eventCode}`);
            break;
        }
      },
      // 识别结果回调
      onResult: (sessionId: string, result: speechRecognizer.SpeechRecognitionResult): void => {
        this.logInfo(`识别结果: result="${result.result}", isFinal=${result.isFinal}, isLast=${result.isLast}`);
        if (result.result && result.result.length > 0) {
          // 无论是临时结果还是最终结果，都保存
          if (result.isFinal) {
            this.recognitionResults.push(result.result);
            this.logInfo(`保存最终结果: ${result.result}`);
          }
          // 显示给用户
          this.statusText = result.result;
        }
      },
      // 识别完成回调
      onComplete: (sessionId: string, eventMessage: string): void => {
        this.logInfo(`识别完成: ${sessionId}, ${eventMessage}`);
        this.handleRecognitionComplete();
      },
      // 错误回调
      onError: (sessionId: string, errorCode: number, errorMessage: string): void => {
        this.logError(`识别错误: ${sessionId}, code=${errorCode}, msg=${errorMessage}`);
        this.handleRecognitionError(errorCode, errorMessage);
      }
    };

    this.asrEngine.setListener(listener);
  }

  // 获取语音识别启动参数
  private getStartAsrParams(): speechRecognizer.StartParams {
    return {
      sessionId: this.sessionId,
      audioInfo: {
        audioType: 'pcm',
        sampleRate: 16000,
        soundChannel: 1,
        sampleBit: 16
      },
      extraParams: {}
    };
  }

  // 开始语音识别会话
  private startAsrSession(): void {
    if (!this.asrEngine) {
      this.logError('语音识别引擎未初始化');
      this.isRecording = false;
      return;
    }

    try {
      // 生成会话ID
      this.sessionId = this.generateSessionId();
      this.recognitionResults = [];

      // 获取语音识别启动参数
      const startParams = this.getStartAsrParams();

      // 开始语音识别
      this.asrEngine.startListening(startParams);
      this.logInfo('语音识别已启动');

      // 启动音频采集
      this.startAudioCapture();

    } catch (error) {
      const err = error as BusinessError;
      this.logError(`开始语音识别失败: ${err.code}, ${err.message}`);
      this.showError('开始语音识别失败');
      this.isRecording = false;
    }
  }

  // 获取音频采集配置
  private getAudioCapturerOptions(): audio.AudioCapturerOptions {
    // 音频采集配置（需要与 speechRecognizer 的 audioInfo 匹配）
    const audioStreamInfo: audio.AudioStreamInfo = {
      samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
      channels: audio.AudioChannel.CHANNEL_1,
      sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
      encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
    };

    const audioCapturerInfo: audio.AudioCapturerInfo = {
      source: audio.SourceType.SOURCE_TYPE_MIC,
      capturerFlags: 0
    };

    return {
      streamInfo: audioStreamInfo,
      capturerInfo: audioCapturerInfo
    };
  }

  // 启动音频采集
  private async startAudioCapture(): Promise<void> {
    try {
      // 获取音频采集配置
      const audioCapturerOptions = this.getAudioCapturerOptions();

      // 创建音频采集器
      this.audioCapturer = await audio.createAudioCapturer(audioCapturerOptions);
      this.logInfo('音频采集器创建成功');

      // 设置读取回调
      this.audioCapturer.on('readData', (buffer: ArrayBuffer) => {
        if (this.asrEngine && this.sessionId && this.isRecording) {
          try {
            // 将音频数据写入语音识别引擎
            // writeAudio 需要 Uint8Array，长度必须是 640 或 1280
            const audioData = new Uint8Array(buffer);
            this.asrEngine.writeAudio(this.sessionId, audioData);
          } catch (e) {
            this.logWarn('写入音频数据失败');
          }
        }
      });

      // 开始采集
      await this.audioCapturer.start();
      this.logInfo('音频采集已启动');
      this.statusText = STATUS_TEXTS.SPEAKING;

    } catch (error) {
      const err = error as BusinessError;
      this.logError(`启动音频采集失败: ${err.code}, ${err.message}`);
      this.showError('启动麦克风失败');
      this.destroyEngine();
      this.isRecording = false;
    }
  }

  // 停止音频采集
  private async stopAudioCapture(): Promise<void> {
    if (this.audioCapturer) {
      try {
        await this.audioCapturer.stop();
        await this.audioCapturer.release();
        this.audioCapturer = null;
        this.logInfo('音频采集已停止');
      } catch (e) {
        this.logWarn('停止音频采集失败');
      }
    }
  }

  // 开始录音时长计时
  private startRecordingTimer(): void {
    this.recordingDuration = 0;
    this.recordingTimer = setInterval(() => {
      this.recordingDuration++;
    }, 1000);
  }

  // 停止录音时长计时
  private stopRecordingTimer(): void {
    if (this.recordingTimer) {
      clearInterval(this.recordingTimer);
      this.recordingTimer = null;
    }
  }

  // 格式化录音时长
  private formatDuration(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
  }

  // 记录性能指标
  private logPerformanceMetrics(): void {
    if (this.performanceMetrics.engineInitTime && this.performanceMetrics.recognitionComplete) {
      const totalTime = this.performanceMetrics.recognitionComplete - this.performanceMetrics.engineInitTime;
      this.logInfo(`性能指标: 总识别时间 ${totalTime}ms`);
      
      if (this.performanceMetrics.audioStart) {
        const initTime = this.performanceMetrics.audioStart - this.performanceMetrics.engineInitTime;
        const recognitionTime = this.performanceMetrics.recognitionComplete - this.performanceMetrics.audioStart;
        this.logInfo(`性能指标: 初始化 ${initTime}ms, 识别 ${recognitionTime}ms`);
      }
    }
  }

  // 保存识别结果到缓存
  private saveToCache(text: string, parsedFields: WorkRecordFields): void {
    // 保存到临时存储，用于重复识别
    this.tempVoiceData.push(text);
    // 限制临时存储大小
    if (this.tempVoiceData.length > CACHE_CONFIG.MAX_TEMP_DATA_ITEMS) {
      this.tempVoiceData.shift();
    }

    // 保存到识别历史
    const historyItem: RecognitionHistoryItem = {
      text: text,
      parsedFields: parsedFields
    };
    this.recognitionHistory.unshift(historyItem);
    // 限制历史记录大小
    if (this.recognitionHistory.length > CACHE_CONFIG.MAX_HISTORY_ITEMS) {
      this.recognitionHistory.pop();
    }
  }

  // 从缓存中获取最近的识别结果
  private getRecentRecognitionResult(): RecognitionHistoryItem | null {
    if (this.recognitionHistory.length > 0) {
      return this.recognitionHistory[0];
    }
    return null;
  }

  // 清理缓存
  private clearCache(): void {
    this.tempVoiceData = [];
    this.recognitionHistory = [];
    this.logInfo('缓存已清理');
  }

  // 处理识别完成
  private handleRecognitionComplete(): void {
    // 停止录音时长计时
    this.stopRecordingTimer();
    
    const finalText = this.recognitionResults.join('');
    this.logInfo(`最终识别结果: ${finalText}`);
    
    // 记录性能指标
    this.performanceMetrics.recognitionComplete = Date.now();
    this.logPerformanceMetrics();

    // 先销毁引擎
    this.destroyEngine();
    this.isRecording = false;

    if (finalText && finalText.trim().length > 0) {
      this.onVoiceRecognized(finalText);
    } else {
      this.showError('未识别到语音内容，请对着麦克风说话');
    }
  }

  // 处理识别错误
  private handleRecognitionError(errorCode: number, errorMsg: string): void {
    try {
      const errorMessage = getErrorMessage(errorCode, `语音识别失败: ${errorMsg}`);

      this.showError(errorMessage);
      this.destroyEngine();
      this.isRecording = false;
      this.logError(`语音识别错误处理完成，错误代码: ${errorCode}`);
    } catch (error) {
      // 确保在错误处理过程中发生的错误不会导致应用崩溃
      const err = error as BusinessError;
      this.logError(`处理识别错误时发生异常: ${err.code}, ${err.message}`);
      // 强制重置状态
      this.isRecording = false;
      this.isDragging = false;
      this.statusText = '';
      // 尝试释放资源
      try {
        this.destroyEngine();
      } catch (e) {
        this.logError(`释放资源时发生异常: ${e}`);
      }
    }
  }

  // 停止录音
  private stopRecording(): void {
    this.statusText = '识别中...';

    // 先停止音频采集
    this.stopAudioCapture();

    // 停止语音识别（不销毁引擎，等待识别完成回调）
    if (this.asrEngine && this.sessionId) {
      try {
        // 调用 finish 而不是 cancel，让引擎完成当前识别
        this.asrEngine.finish(this.sessionId);
        this.logInfo('已发送停止录音指令，等待识别完成...');
      } catch (error) {
        this.logError(`停止录音失败: ${error}`);
        this.destroyEngine();
        this.isRecording = false;
      }
    }
  }

  // 销毁引擎（在识别完成后调用）
  private destroyEngine(): void {
    try {
      this.statusText = '';
      // 确保音频采集已停止
      this.stopAudioCapture();
      
      if (this.asrEngine) {
        try {
          this.asrEngine.shutdown();
          this.asrEngine = null;
          this.logInfo('语音识别引擎已销毁');
        } catch (error) {
          const err = error as BusinessError;
          this.logError(`销毁语音识别引擎失败: ${err.code}, ${err.message}`);
        }
      }
      
      // 停止录音时长计时
      this.stopRecordingTimer();
      
      // 重置性能指标
      this.performanceMetrics = {
        engineInitTime: null,
        audioStart: null,
        recognitionComplete: null
      };
      
      this.logInfo('资源销毁完成');
    } catch (error) {
      const err = error as BusinessError;
      this.logError(`销毁引擎时发生异常: ${err.code}, ${err.message}`);
      // 确保引擎引用被清空，避免内存泄漏
      this.asrEngine = null;
      // 停止录音时长计时
      this.stopRecordingTimer();
    }
  }

  // 检查设备是否支持语音识别
  private checkDeviceSupport(): boolean {
    let isSpeechSupported: boolean = false;
    try {
      // 检查语音识别能力
      isSpeechSupported = canIUse('SystemCapability.AI.SpeechRecognizer');
      this.logInfo(`设备语音识别支持: ${isSpeechSupported}`);
      
      return isSpeechSupported;
    } catch (e) {
      this.logWarn('canIUse 检查失败，尝试继续');
      // 如果检查失败，继续尝试，但记录警告
      return true;
    }
  }

  // 开始录音
  private startRecording(): void {
    // 先检查设备是否支持语音识别
    const isSpeechSupported = this.checkDeviceSupport();
    
    if (!isSpeechSupported) {
      this.showError('当前设备不支持语音识别功能');
      return;
    }
    
    this.isRecording = true;
    this.statusText = STATUS_TEXTS.CHECKING_PERMISSION;
    this.checkPermissionAndStart();
  }

  // 检查麦克风权限
  private async checkPermissionAndStart(): Promise<void> {
    try {
      const atManager = abilityAccessCtrl.createAtManager();
      const permissions: Permissions[] = ['ohos.permission.MICROPHONE'];
      
      // 获取当前应用的 tokenId
      const context = getContext(this) as common.UIAbilityContext;
      const tokenId = context.applicationInfo.accessTokenId;
      
      // 检查权限状态
      const grantStatus = await atManager.checkAccessToken(tokenId, permissions[0]);
      
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        // 已有权限，直接开始识别
        this.logInfo('麦克风权限已授予');
        this.statusText = STATUS_TEXTS.INITIALIZING;
        this.initAsrEngine();
      } else {
        // 请求权限
        this.logInfo('请求麦克风权限');
        const requestResult = await atManager.requestPermissionsFromUser(context, permissions);
        
        if (requestResult.authResults[0] === 0) {
          // 用户授权
          this.logInfo('用户授予麦克风权限');
          this.statusText = STATUS_TEXTS.INITIALIZING;
          this.initAsrEngine();
        } else {
          // 用户拒绝
          this.logError('用户拒绝麦克风权限');
          this.showError('需要麦克风权限才能使用语音功能');
          this.isRecording = false;
        }
      }
    } catch (error) {
      const err = error as BusinessError;
      this.logError(`权限检查失败: ${err.code}, ${err.message}`);
      // 权限检查失败，尝试直接启动（可能在某些情况下不需要动态权限）
      this.statusText = STATUS_TEXTS.INITIALIZING;
      this.initAsrEngine();
    }
  }

  // 显示错误提示
  private showError(message: string): void {
    // 简短消息用 Toast，长消息用 Dialog
    if (message.length > 50) {
      // 长消息：使用简化版本的 Toast
      const shortMsg = message.split('\n')[0]; // 只取第一行
      promptAction.showToast({
        message: shortMsg,
        duration: 5000
      });
      // 完整消息打印到日志，添加时间戳和详细上下文
      console.error(`[VoiceAssistant] [${new Date().toISOString()}] ERROR: ${message}`);
    } else {
      promptAction.showToast({
        message: message,
        duration: 3000
      });
      // 记录错误日志
      console.error(`[VoiceAssistant] [${new Date().toISOString()}] ERROR: ${message}`);
    }
  }

  // 优化日志记录，添加时间戳和结构化信息
  private logInfo(message: string, data?: string | number | boolean | object): void {
    if (data) {
      console.info(`[VoiceAssistant] [${new Date().toISOString()}] INFO: ${message} - ${JSON.stringify(data)}`);
    } else {
      console.info(`[VoiceAssistant] [${new Date().toISOString()}] INFO: ${message}`);
    }
  }

  // 优化日志记录，添加时间戳和结构化信息
  private logWarn(message: string, data?: string | number | boolean | object): void {
    if (data) {
      console.warn(`[VoiceAssistant] [${new Date().toISOString()}] WARN: ${message} - ${JSON.stringify(data)}`);
    } else {
      console.warn(`[VoiceAssistant] [${new Date().toISOString()}] WARN: ${message}`);
    }
  }

  // 优化日志记录，添加时间戳和结构化信息
  private logError(message: string, error?: Error | string | number | object): void {
    if (error) {
      const errorInfo = error instanceof Error ? error.message : JSON.stringify(error);
      console.error(`[VoiceAssistant] [${new Date().toISOString()}] ERROR: ${message} - ${errorInfo}`);
    } else {
      console.error(`[VoiceAssistant] [${new Date().toISOString()}] ERROR: ${message}`);
    }
  }

  build() {
    Stack() {
      // 悬浮按钮
      Column() {
        Image($r('app.media.ic_add'))
          .width(32)
          .height(32)
          .fillColor(this.themeColors.surfaceBackground)
      }
      .width(this.buttonSize)
      .height(this.buttonSize)
      .borderRadius(this.buttonSize / 2)
      .backgroundColor(this.isRecording ? this.themeColors.errorColor : this.themeColors.primaryColor)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .shadow({
        radius: 10,
        color: this.themeColors.shadowColor,
        offsetX: 0,
        offsetY: 4
      })
      .onTouch((event) => {
        if (event.type === TouchType.Down) {
          // 按下开始录音并添加缩放动画
          this.buttonScale = 0.9;
          if (!this.isRecording && !this.isDragging) {
            this.startRecording();
          }
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          // 松开或取消时停止录音并恢复缩放
          this.buttonScale = 1;
          if (this.isRecording && !this.isDragging) {
            this.stopRecording();
          }
        }
      })
      .gesture(
        // 添加拖拽手势，设置为单指拖拽
        PanGesture({
          fingers: 1, // 限制为单指拖拽
          distance: 5 // 设置最小拖拽距离，防止误触
        })
          .onActionStart((event: GestureEvent) => {
            // 开始拖拽，设置拖拽状态
            this.isDragging = true;
            // 记录初始位置，用于计算相对位移
            this.startPosition = { x: this.buttonPosition.x, y: this.buttonPosition.y };
          })
          .onActionUpdate((event: GestureEvent) => {
            // 初始化屏幕尺寸（如果尚未初始化）
            if (this.screenWidth === 0 || this.screenHeight === 0) {
              this.initScreenSize();
            }
            
            // 使用offsetX和offsetY计算新位置，实现1:1的手指滑动与按钮移动比例
            const newX: number = this.startPosition.x + event.offsetX;
            const newY: number = this.startPosition.y + event.offsetY;
            
            // 边界检查，确保按钮始终在屏幕范围内
            const boundedX: number = Math.max(this.buttonSize / 2, Math.min(newX, this.screenWidth - this.buttonSize / 2));
            const boundedY: number = Math.max(this.buttonSize / 2, Math.min(newY, this.screenHeight - this.buttonSize / 2));
            
            const newPos: ButtonPosition = {
              x: boundedX,
              y: boundedY
            };
            this.buttonPosition = newPos;
          })
          .onActionEnd(() => {
            // 结束拖拽，重置拖拽状态
            this.isDragging = false;
          })
          .onActionCancel(() => {
            // 取消拖拽，重置拖拽状态
            this.isDragging = false;
          })
      )
      .scale({ x: this.buttonScale, y: this.buttonScale })
      .animation({
        duration: 300,
        curve: Curve.EaseInOut
      })

      // 录音状态指示器
      if (this.isRecording) {
        Column() {
          // 录音状态文本
          Text(this.statusText || '正在录音...')
            .fontSize(14)
            .fontColor(this.themeColors.textPrimary)
            .backgroundColor(this.themeColors.surfaceBackground)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(16)
            .shadow({
              radius: 8,
              color: this.themeColors.shadowColor,
              offsetX: 0,
              offsetY: 2
            })
          
          // 录音时长显示
          if (this.recordingDuration > 0) {
            Text(this.formatDuration(this.recordingDuration))
              .fontSize(12)
              .fontColor(this.themeColors.textSecondary)
              .backgroundColor(this.themeColors.surfaceBackground)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(12)
              .margin({ top: 8 })
              .shadow({
                radius: 6,
                color: this.themeColors.shadowColor,
                offsetX: 0,
                offsetY: 2
              })
          }
        }
        .margin({ bottom: 80 })
      }
    }
    .position(this.buttonPosition)
    .zIndex(9999)
  }

  // 初始化屏幕尺寸 - 使用默认值
  private initScreenSize(): void {
    // 使用常用设备的默认屏幕尺寸
    this.screenWidth = 1080;
    this.screenHeight = 2340;
  }
}
