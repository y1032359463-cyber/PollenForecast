import { display, UIContext, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../logger/Index';

const TAG = '[WindowUtil]';

@ObservedV2
export class AvoidAreaSize {
  @Trace top: number = 0;
  @Trace bottom: number = 0;
}

@ObservedV2
export class WindowUtil {
  private static _currentWindow: window.Window;

  public static get currentWindow() {
    return WindowUtil._currentWindow;
  }

  private static _display: display.Display;

  public static get display(): display.Display {
    return WindowUtil._display;
  }

  private static _context: Context;

  public static get context(): Context {
    return WindowUtil._context;
  }

  private static _uiContext: UIContext;

  public static get uiContext(): UIContext {
    return WindowUtil._uiContext;
  }

  public static updateDisplay() {
    WindowUtil._display = display.getDefaultDisplaySync();
  }

  public static async initWindowUtil() {
    await WindowUtil._getCurrentWindow();
    WindowUtil.updateDisplay();
    WindowUtil._getContext();
  }

  public static setFullWindow(isFull: boolean = true) {
    if (WindowUtil._currentWindow) {
      WindowUtil._currentWindow
        .setWindowLayoutFullScreen(isFull)
        .then(() => {
          Logger.info(TAG, 'set full window success');
        })
        .catch((error: BusinessError) => {
          WindowUtil._dealAllError(error);
        });
    }
  }

  private static _getContext() {
    if (WindowUtil._currentWindow) {
      // 从窗口获取 UIContext
      WindowUtil._uiContext = WindowUtil._currentWindow.getUIContext();
      // 使用 UIContext 获取 HostContext
      WindowUtil._context = WindowUtil._uiContext.getHostContext() as Context;
    }
  }

  private static async _getCurrentWindow() {
    try {
      // 注意：此处需要在组件中调用 initWindowUtil 时传入 context
      // 或使用 AppStorage 存储的 context
      const ctx = AppStorage.get<Context>('appContext') as Context;
      if (ctx) {
        const win = await window.getLastWindow(ctx);
        WindowUtil._currentWindow = win;
      } else {
        Logger.warn(TAG, 'Context not found in AppStorage, please set appContext first');
      }
    } catch (error) {
      WindowUtil._dealAllError(error as BusinessError);
    }
  }

  private static _dealAllError(error: BusinessError): void {
    Logger.error(TAG, `errorCode: ${error.code}, errorMsg: ${error.message}`);
  }
}
