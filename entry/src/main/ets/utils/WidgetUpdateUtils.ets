import { formBindingData, formProvider } from '@kit.FormKit';
import { WidgetFormData } from '../model/PollenModels';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

const PREFERENCES_NAME = 'widget_store';
const KEY_FORM_IDS = 'form_ids';

/**
 * 服务卡片更新工具类
 */
export class WidgetUpdateUtils {
  /**
   * 更新所有已保存的卡片
   * @param context UIAbilityContext 或 ApplicationContext
   * @param data 卡片数据
   */
  static async updateWidget(context: common.Context, data: WidgetFormData): Promise<void> {
    try {
      // 1. 获取保存的 formIds
      const pref = await preferences.getPreferences(context, PREFERENCES_NAME);
      const formIds = (await pref.get(KEY_FORM_IDS, [])) as string[];

      if (formIds.length === 0) {
        console.warn('[WidgetUpdateUtils] 没有找到活跃的卡片 ID');
        return;
      }

      console.info(`[WidgetUpdateUtils] 准备更新 ${formIds.length} 个卡片, 数据: ${JSON.stringify(data)}`);

      // 2. 创建绑定数据
      const bindingData = formBindingData.createFormBindingData(data);

      // 3. 遍历更新每个卡片
      for (const formId of formIds) {
        try {
          await formProvider.updateForm(formId, bindingData);
          console.info(`[WidgetUpdateUtils] 卡片 ${formId} 更新成功`);
        } catch (err) {
          const error = err as BusinessError;
          console.error(`[WidgetUpdateUtils] 卡片 ${formId} 更新失败: ${error.code} - ${error.message}`);
          
          // 如果卡片不存在（可能已被用户删除但未回调 onRemoveForm），考虑从列表中移除
          // 错误码 16501001: ID invalid (示例，具体需查文档)
        }
      }
    } catch (error) {
      console.error(`[WidgetUpdateUtils] 全局更新失败: ${JSON.stringify(error)}`);
    }
  }
}
