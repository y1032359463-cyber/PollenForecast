/**
 * GlobalContext.ts
 * 
 * 提供一个全局可访问的 UIAbilityContext。
 * 在应用启动时（如 EntryAbility 的 onCreate），必须调用 `GlobalContext.setContext(this.context)` 进行初始化。
 */
import { common } from '@kit.AbilityKit';
type UIAbilityContext = common.UIAbilityContext;

export namespace GlobalContext {
  let context: UIAbilityContext | null = null;
  
  /**
   * 设置全局上下文。
   * @param ctx - UIAbility 的上下文。
   */
  export function setContext(ctx: UIAbilityContext): void {
    context = ctx;
  }
  
  /**
   * 获取全局上下文。
   * @returns 返回已设置的 UIAbilityContext，如果未设置则返回 null。
   */
  export function getContext(): UIAbilityContext | null {
    return context;
  }
}
