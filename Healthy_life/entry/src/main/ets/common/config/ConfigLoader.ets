/**
 * 配置加载器
 * 负责从rawfile读取JSON配置文件并解析
 */

import { AppConfig, AppConfigData } from './AppConfig';
import { resourceManager } from '@kit.LocalizationKit';

/**
 * 配置文件加载器
 */
export class ConfigLoader {
  private static CONFIG_FILE_NAME = 'config.json'; // 默认配置文件名

  /**
   * 加载配置文件
   * @param context 应用上下文
   * @param configFileName 配置文件名(可选,默认为config.json)
   */
  public static async load(context: Context, configFileName?: string): Promise<void> {
    try {
      const fileName = configFileName || ConfigLoader.CONFIG_FILE_NAME;
      
      // 获取资源管理器
      const resMgr = context.resourceManager;
      
      // 从rawfile读取配置文件
      const rawFileData = await resMgr.getRawFileContent(fileName);
      
      // 将ArrayBuffer转换为字符串
      const configJson = String.fromCharCode(...new Uint8Array(rawFileData.buffer));
      
      // 解析JSON
      const configData: AppConfigData = JSON.parse(configJson);
      
      // 验证配置数据
      ConfigLoader.validateConfig(configData);
      
      // 设置到全局配置
      AppConfig.getInstance().setConfig(configData);
      
      console.info(`[ConfigLoader] 配置加载成功: ${fileName}`);
    } catch (error) {
      console.error(`[ConfigLoader] 配置加载失败:`, error);
      throw new Error(`配置文件加载失败: ${error}`);
    }
  }

  /**
   * 验证配置数据完整性
   */
  private static validateConfig(config: AppConfigData): void {
    // 验证必需字段
    if (!config.app || !config.app.appName) {
      throw new Error('配置文件缺少app.appName字段');
    }
    
    if (!config.theme || !config.theme.primaryColor) {
      throw new Error('配置文件缺少theme.primaryColor字段');
    }
    
    if (!config.taskTypes || config.taskTypes.length === 0) {
      throw new Error('配置文件缺少taskTypes或taskTypes为空');
    }
    
    // 验证任务类型配置
    config.taskTypes.forEach((taskType, index) => {
      if (!taskType.id || !taskType.name) {
        throw new Error(`taskTypes[${index}]缺少id或name字段`);
      }
    });
    
    console.info('[ConfigLoader] 配置验证通过');
  }

  /**
   * 重新加载配置(用于切换主题/配置)
   */
  public static async reload(context: Context, configFileName: string): Promise<void> {
    await ConfigLoader.load(context, configFileName);
  }

  /**
   * 获取当前配置的应用名称
   */
  public static getCurrentAppName(): string {
    try {
      return AppConfig.getInstance().app.appName;
    } catch {
      return '未加载配置';
    }
  }
}
