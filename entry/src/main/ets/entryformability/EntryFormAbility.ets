import { FormExtensionAbility, formBindingData, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { WidgetFormData } from '../model/PollenModels';

const PREFERENCES_NAME = 'widget_store';
const KEY_FORM_IDS = 'form_ids';

export default class EntryFormAbility extends FormExtensionAbility {
  
  onAddForm(want: Want) {
    console.info('[EntryFormAbility] onAddForm');
    
    // 保存 formId (异步执行，不阻塞返回)
    const formId = want.parameters?.['ohos.extra.param.key.form_identity'] as string;
    if (formId) {
      this.saveFormId(formId).catch((err: Error) => {
        console.error('[EntryFormAbility] Failed to save formId in background: ' + JSON.stringify(err));
      });
    }

    // 初始化数据
    let formData: WidgetFormData = {
      pollenValue: "45",
      pollenLevel: "中等",
      cityName: "广州"
    };
    return formBindingData.createFormBindingData(formData);
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
  }

  onChangeFormVisibility(newStatus: Record<string, number>) {
    // Called when the form provider receives form events from the system.
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message is received from the form.
  }

  onRemoveForm(formId: string) {
    console.info('[EntryFormAbility] onRemoveForm: ' + formId);
    this.removeFormId(formId).catch((err: Error) => {
        console.error('[EntryFormAbility] Failed to remove formId in background: ' + JSON.stringify(err));
    });
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }

  // ========== 辅助方法 ==========

  private async getPreferences() {
    return await preferences.getPreferences(this.context, PREFERENCES_NAME);
  }

  private async saveFormId(formId: string) {
    try {
      const pref = await this.getPreferences();
      const ids = (await pref.get(KEY_FORM_IDS, [])) as string[];
      if (!ids.includes(formId)) {
        ids.push(formId);
        await pref.put(KEY_FORM_IDS, ids);
        await pref.flush();
        console.info('[EntryFormAbility] Saved formId: ' + formId);
      }
    } catch (err) {
      console.error('[EntryFormAbility] Failed to save formId: ' + JSON.stringify(err));
      // ArkTS 不允许 throw 任意类型，且此处为后台任务，记录日志即可
    }
  }

  private async removeFormId(formId: string) {
    try {
      const pref = await this.getPreferences();
      let ids = (await pref.get(KEY_FORM_IDS, [])) as string[];
      // 检查是否包含该 formId
      let hasFormId = false
      for (let i = 0; i < ids.length; i++) {
        if (ids[i] === formId) {
          hasFormId = true
          break
        }
      }
      if (hasFormId) {
        // 过滤掉该 formId
        const newIds: string[] = []
        for (let i = 0; i < ids.length; i++) {
          if (ids[i] !== formId) {
            newIds.push(ids[i])
          }
        }
        ids = newIds
        await pref.put(KEY_FORM_IDS, ids);
        await pref.flush();
        console.info('[EntryFormAbility] Removed formId: ' + formId);
      }
    } catch (err) {
      console.error('[EntryFormAbility] Failed to remove formId: ' + JSON.stringify(err));
      // ArkTS 不允许 throw 任意类型，且此处为后台任务，记录日志即可
    }
  }
};
