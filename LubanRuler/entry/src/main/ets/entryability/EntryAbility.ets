import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;
const TAG = 'LubanRuler';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageCreate');

    // 获取主窗口并设置沉浸式全屏
    windowStage.getMainWindow((err, mainWindow) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to get main window. Cause: %{public}s', JSON.stringify(err));
        return;
      }

      // ✅ 将窗口实例存入 AppStorage，供页面组件使用
      AppStorage.setOrCreate('mainWindow', mainWindow);
      hilog.info(DOMAIN, TAG, 'Main window stored in AppStorage');

      // 设置全屏沉浸式布局
      mainWindow.setWindowLayoutFullScreen(true, (err) => {
        if (err.code) {
          hilog.error(DOMAIN, TAG, 'Failed to set full screen. Cause: %{public}s', JSON.stringify(err));
          return;
        }
        hilog.info(DOMAIN, TAG, 'Succeeded in setting full screen.');
      });

      // 设置状态栏和导航栏属性（沉浸式）
      const systemBarProperties: window.SystemBarProperties = {
        statusBarColor: '#D4380D',           // 状态栏背景色
        navigationBarColor: '#000000',        // 导航栏背景色
        statusBarContentColor: '#FFFFFF',     // 状态栏文字颜色（白色）
        navigationBarContentColor: '#FFFFFF'  // 导航栏文字颜色
      };
      mainWindow.setWindowSystemBarProperties(systemBarProperties, (err) => {
        if (err.code) {
          hilog.error(DOMAIN, TAG, 'Failed to set system bar. Cause: %{public}s', JSON.stringify(err));
          return;
        }
        hilog.info(DOMAIN, TAG, 'Succeeded in setting system bar.');
      });

      // ✅ 监听窗口尺寸变化（即使固定横屏也可能因分屏等原因变化）
      mainWindow.on('windowSizeChange', (size: window.Size) => {
        hilog.info(DOMAIN, TAG, `Window size changed: ${size.width} x ${size.height}`);
        // 通过 AppStorage 通知页面更新
        AppStorage.setOrCreate('windowWidth', size.width);
        AppStorage.setOrCreate('windowHeight', size.height);
      });

      // ✅ 监听避让区域变化（处理摄像头挖孔区域动态变化）
      mainWindow.on('avoidAreaChange', (data) => {
        if (data.type === window.AvoidAreaType.TYPE_CUTOUT) {
          hilog.info(DOMAIN, TAG, `Cutout area changed: left=${data.area.leftRect.width}`);
          AppStorage.setOrCreate('cutoutAreaLeft', data.area.leftRect.width);
        }
      });
    });

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageDestroy');

    // ✅ 移除窗口监听，清理资源
    const mainWindow = AppStorage.get<window.Window>('mainWindow');
    if (mainWindow) {
      try {
        mainWindow.off('windowSizeChange');
        mainWindow.off('avoidAreaChange');
      } catch (e) {
        hilog.warn(DOMAIN, TAG, 'Failed to remove window listeners: %{public}s', JSON.stringify(e));
      }
    }
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onBackground');
  }
}