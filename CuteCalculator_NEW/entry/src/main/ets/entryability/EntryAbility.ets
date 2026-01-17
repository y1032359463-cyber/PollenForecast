import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/MainPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      
      // ✅ 页面加载后再注册字体
      windowStage.getMainWindow().then((mainWindow: window.Window) => {
        try {
          hilog.info(DOMAIN, 'testTag', 'Start registering fonts...');
          const uiContext = mainWindow.getUIContext();
          const fontManager = uiContext.getFont();
          
          // 注册Pacifico字体 (旧主题保留)
          fontManager.registerFont({
            familyName: 'Pacifico',
            familySrc: $rawfile('fonts/Pacifico-Regular.ttf')
          });
          hilog.info(DOMAIN, 'testTag', '✅ Pacifico font registered successfully!');
          
          // 注册Press Start 2P字体 (Retro Pixel主题)
          fontManager.registerFont({
            familyName: 'PressStart2P',
            familySrc: $rawfile('fonts/PressStart2P-Regular.ttf')
          });
          hilog.info(DOMAIN, 'testTag', '✅ PressStart2P font registered successfully!');
        } catch (err) {
          hilog.error(DOMAIN, 'testTag', '❌ Failed to register font: %{public}s', JSON.stringify(err));
        }
      }).catch((err: Error) => {
        hilog.error(DOMAIN, 'testTag', 'Failed to get main window: %{public}s', JSON.stringify(err));
      });
    });

    // 设置沉浸式状态栏和导航栏
    windowStage.getMainWindow().then((mainWindow: window.Window) => {
      // 设置全屏沉浸式布局(新API)
      mainWindow.setWindowLayoutFullScreen(true).then(() => {
        hilog.info(DOMAIN, 'testTag', 'Succeeded in setting full screen layout.');
      }).catch((err: Error) => {
        hilog.error(DOMAIN, 'testTag', 'Failed to set full screen layout. Cause: %{public}s', JSON.stringify(err));
      });

      // 设置状态栏和导航栏透明，显示背景色
      const sysBarProps: window.SystemBarProperties = {
        statusBarColor: '#FFD4A3',  // 主背景色（暖浅橙）
        navigationBarColor: '#FFD4A3',
        statusBarContentColor: '#000000',  // 黑色文字
        navigationBarContentColor: '#000000'
      };
      mainWindow.setWindowSystemBarProperties(sysBarProps).then(() => {
        hilog.info(DOMAIN, 'testTag', 'Succeeded in setting system bar properties.');
      }).catch((err: Error) => {
        hilog.error(DOMAIN, 'testTag', 'Failed to set system bar properties. Cause: %{public}s', JSON.stringify(err));
      });
    }).catch((err: Error) => {
      hilog.error(DOMAIN, 'testTag', 'Failed to get main window. Cause: %{public}s', JSON.stringify(err));
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}