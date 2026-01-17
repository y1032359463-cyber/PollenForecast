import { common } from '@kit.AbilityKit';

export enum EventKey {
  GLOBAL_REFRESH_EVENT = 'globalRefreshEvent',
}

// 导出常量供直接使用
export const GLOBAL_REFRESH_EVENT = EventKey.GLOBAL_REFRESH_EVENT;

export class EventBus {
  private _eventHub: common.EventHub | null = null;
  private static _instance: EventBus;

  // 初始化方法，需要在应用启动时调用
  public static init(context: common.UIAbilityContext): void {
    if (!EventBus._instance) {
      EventBus._instance = new EventBus();
    }
    EventBus._instance._eventHub = context.eventHub;
  }

  // 从 AppStorage 获取 context 初始化
  private getEventHub(): common.EventHub {
    if (!this._eventHub) {
      const ctx = AppStorage.get<common.UIAbilityContext>('uiAbilityContext');
      if (ctx) {
        this._eventHub = ctx.eventHub;
      } else {
        console.error('[EventBus] UIAbilityContext not found, please call EventBus.init() first');
        throw new Error('EventBus not initialized');
      }
    }
    return this._eventHub;
  }

  public static get instance(): EventBus {
    if (!EventBus._instance) {
      EventBus._instance = new EventBus();
    }
    return EventBus._instance;
  }

  public emit(eventKey: EventKey | string, ...args: Object[]) {
    this.getEventHub().emit(eventKey, ...args);
  }

  public on(eventKey: string, callback: Function) {
    this.getEventHub().on(eventKey, callback);
  }

  public off(eventKey: string, callback?: Function) {
    this.getEventHub().off(eventKey, callback);
  }
}
