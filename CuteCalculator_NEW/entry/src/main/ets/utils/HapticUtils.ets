/*
 * HapticUtils - 振动反馈工具类
 * Haptic Feedback Utility
 */

import { vibrator } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 振动反馈工具类
 */
export class HapticUtils {
  /**
   * 按键振动反馈
   */
  static buttonVibrate(): void {
    try {
      vibrator.startVibration({
        type: 'time',
        duration: 20  // 短促振动20ms
      }, {
        usage: 'touch'
      });
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Failed to start vibration. Code: ${err.code}, message: ${err.message}`);
    }
  }

  /**
   * 等号振动反馈(稍强)
   */
  static equalVibrate(): void {
    try {
      vibrator.startVibration({
        type: 'time',
        duration: 50  // 较长振动50ms
      }, {
        usage: 'touch'
      });
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Failed to start vibration. Code: ${err.code}, message: ${err.message}`);
    }
  }

  /**
   * 错误振动反馈
   */
  static errorVibrate(): void {
    try {
      // 连续两次短振动表示错误
      vibrator.startVibration({
        type: 'time',
        duration: 30
      }, {
        usage: 'touch'
      });

      setTimeout(() => {
        vibrator.startVibration({
          type: 'time',
          duration: 30
        }, {
          usage: 'touch'
        });
      }, 100);
    } catch (error) {
      let err = error as BusinessError;
      console.error(`Failed to start vibration. Code: ${err.code}, message: ${err.message}`);
    }
  }
}
