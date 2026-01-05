/**
 * API 版本检测工具类
 * 用于 API 17 和 API 20 兼容性处理
 */

import { deviceInfo } from '@kit.BasicServicesKit';

export class ApiVersionUtils {
  private static apiVersion: number | null = null;

  /**
   * 获取当前设备 API 版本
   * @returns API 版本号（如 17、20）
   */
  static getApiVersion(): number {
    if (this.apiVersion === null) {
      try {
        // 使用 deviceInfo.sdkApiVersion 获取 API 版本
        this.apiVersion = deviceInfo.sdkApiVersion;
        console.info(`[ApiVersionUtils] 当前设备 API 版本: ${this.apiVersion}`);
      } catch (err) {
        console.error('[ApiVersionUtils] 获取 API 版本失败:', JSON.stringify(err));
        this.apiVersion = 20; // 默认假设 API 20
      }
    }
    return this.apiVersion;
  }

  /**
   * 是否为 API 20+
   * @returns true 表示 API 20 或更高版本
   */
  static isAPI20(): boolean {
    return this.getApiVersion() >= 20;
  }

  /**
   * 是否为 API 17-19（需要兼容处理）
   * @returns true 表示 API 17-19
   */
  static isAPI17To19(): boolean {
    const version = this.getApiVersion();
    return version >= 17 && version < 20;
  }

  /**
   * 是否支持 MapEventManager（API 20+）
   * @returns true 表示支持 MapEventManager
   */
  static supportsMapEventManager(): boolean {
    return this.isAPI20();
  }

  /**
   * 是否支持智感握姿（API 20+）
   * @returns true 表示支持智感握姿
   */
  static supportsGripDetection(): boolean {
    return this.isAPI20();
  }

  /**
   * 获取 API 版本描述
   * @returns 版本描述字符串
   */
  static getVersionDescription(): string {
    const version = this.getApiVersion();
    if (version >= 20) {
      return `HarmonyOS 6.0+ (API ${version})`;
    } else if (version >= 17) {
      return `HarmonyOS 5.0 (API ${version})`;
    } else {
      return `HarmonyOS 旧版本 (API ${version})`;
    }
  }
}

