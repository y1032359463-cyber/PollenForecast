/**
 * 震动反馈工具类
 * 提供统一的震动反馈接口，根据用户设置决定是否触发震动
 */

import { vibrator } from '@kit.SensorServiceKit'

export class VibrationUtils {
  /**
   * 触发轻量震动反馈（用于按钮点击、切换等操作）
   * 自动检查用户震动设置
   */
  static triggerLight(): void {
    // 从 AppStorage 读取震动设置
    const vibrationEnabled = AppStorage.get<boolean>('vibrationEnabled') ?? false
    
    if (!vibrationEnabled) {
      return
    }

    try {
      vibrator.startVibration({
        type: 'time',
        duration: 15  // 15ms 轻量震动
      }, {
        id: 0,
        usage: 'touch'
      }, (error) => {
        if (error) {
          console.error('[VibrationUtils] 轻量震动失败:', JSON.stringify(error))
        }
      })
    } catch (err) {
      console.error('[VibrationUtils] 轻量震动异常:', JSON.stringify(err))
    }
  }

  /**
   * 触发中等震动反馈（用于重要操作确认）
   */
  static triggerMedium(): void {
    const vibrationEnabled = AppStorage.get<boolean>('vibrationEnabled') ?? false
    
    if (!vibrationEnabled) {
      return
    }

    try {
      vibrator.startVibration({
        type: 'time',
        duration: 35  // 35ms 中等震动
      }, {
        id: 0,
        usage: 'touch'
      }, (error) => {
        if (error) {
          console.error('[VibrationUtils] 中等震动失败:', JSON.stringify(error))
        }
      })
    } catch (err) {
      console.error('[VibrationUtils] 中等震动异常:', JSON.stringify(err))
    }
  }

  /**
   * 触发重度震动反馈（用于警告、错误提示）
   */
  static triggerHeavy(): void {
    const vibrationEnabled = AppStorage.get<boolean>('vibrationEnabled') ?? false
    
    if (!vibrationEnabled) {
      return
    }

    try {
      vibrator.startVibration({
        type: 'time',
        duration: 50  // 50ms 重度震动
      }, {
        id: 0,
        usage: 'alarm'
      }, (error) => {
        if (error) {
          console.error('[VibrationUtils] 重度震动失败:', JSON.stringify(error))
        }
      })
    } catch (err) {
      console.error('[VibrationUtils] 重度震动异常:', JSON.stringify(err))
    }
  }
}
