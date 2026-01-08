/**
 * API 版本检测工具
 * 用于 API 17 和 API 20 兼容性处理
 */

import { deviceInfo } from '@kit.BasicServicesKit';

// 缓存 API 版本（模块级变量）
let cachedApiVersion: number = -1;

/**
 * 获取当前设备 API 版本
 * @returns API 版本号（如 17、20）
 */
function getApiVersionInternal(): number {
  if (cachedApiVersion === -1) {
    try {
      // 使用 HarmonyOS 独有接口的版本判断方法
      // 计算方式: M*10000 + S*100 + F → 6*10000 + 0*100 + 0 = 60000
      if (deviceInfo.distributionOSApiVersion >= 60000) {
        cachedApiVersion = 20; // API 20 (HarmonyOS 6.0.0)
      } else if (deviceInfo.distributionOSApiVersion >= 50000) {
        cachedApiVersion = 17; // API 17 (HarmonyOS 5.0.0)
      } else {
        cachedApiVersion = deviceInfo.sdkApiVersion; // 备用方案
      }
      console.info(`[ApiVersionUtils] 当前设备 API 版本: ${cachedApiVersion}, distributionOSApiVersion: ${deviceInfo.distributionOSApiVersion}`);
    } catch (err) {
      console.error('[ApiVersionUtils] 获取 API 版本失败:', JSON.stringify(err));
      cachedApiVersion = 20; // 默认假设 API 20
    }
  }
  return cachedApiVersion;
}

/**
 * API 版本工具类（使用静态方法封装）
 * 注意：ArkTS 静态方法中不能使用 this，需要用类名调用
 */
export class ApiVersionUtils {
  /**
   * 获取当前设备 API 版本
   */
  static getApiVersion(): number {
    return getApiVersionInternal();
  }

  /**
   * 是否为 API 20+
   */
  static isAPI20(): boolean {
    return getApiVersionInternal() >= 20;
  }

  /**
   * 是否为 API 17-19（需要兼容处理）
   */
  static isAPI17To19(): boolean {
    const version = getApiVersionInternal();
    return version >= 17 && version < 20;
  }

  /**
   * 是否支持 MapEventManager（API 20+）
   */
  static supportsMapEventManager(): boolean {
    return getApiVersionInternal() >= 20;
  }

  /**
   * 是否支持智感握姿（API 20+）
   */
  static supportsGripDetection(): boolean {
    return getApiVersionInternal() >= 20;
  }

  /**
   * 获取 API 版本描述
   */
  static getVersionDescription(): string {
    const version = getApiVersionInternal();
    if (version >= 20) {
      return `HarmonyOS 6.0+ (API ${version})`;
    } else if (version >= 17) {
      return `HarmonyOS 5.0 (API ${version})`;
    } else {
      return `HarmonyOS 旧版本 (API ${version})`;
    }
  }
}
