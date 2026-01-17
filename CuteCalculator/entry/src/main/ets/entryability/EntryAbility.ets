import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private isDarkMode: boolean = false;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
      // 检测当前系统主题
      this.isDarkMode = this.context.config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      // 初始化 AppStorage 的深浅色模式状态
      AppStorage.setOrCreate('isDarkMode', this.isDarkMode);
      hilog.info(DOMAIN, 'testTag', 'Initial isDarkMode: %{public}s', String(this.isDarkMode));
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  /**
   * 监听系统配置变化（包括深浅色模式切换）
   * 通过 AppStorage 通知 MainPage 更新状态栏颜色
   */
  onConfigurationUpdate(newConfig: Configuration): void {
    hilog.info(DOMAIN, 'testTag', 'onConfigurationUpdate called, colorMode: %{public}s', String(newConfig.colorMode));
    
    const newIsDarkMode = newConfig.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    
    // 只有主题真正变化时才更新
    if (this.isDarkMode !== newIsDarkMode) {
      this.isDarkMode = newIsDarkMode;
      // 通过 AppStorage 通知 MainPage
      AppStorage.set('isDarkMode', this.isDarkMode);
      hilog.info(DOMAIN, 'testTag', 'Theme changed, isDarkMode: %{public}s', String(this.isDarkMode));
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 先获取主窗口，设置沉浸式布局和状态栏颜色
    windowStage.getMainWindow().then((mainWindow: window.Window) => {
      // 设置全屏沉浸式布局(新API)
      mainWindow.setWindowLayoutFullScreen(true).then(() => {
        hilog.info(DOMAIN, 'testTag', 'Succeeded in setting full screen layout.');
      }).catch((err: Error) => {
        hilog.error(DOMAIN, 'testTag', 'Failed to set full screen layout. Cause: %{public}s', JSON.stringify(err));
      });

      // 移除状态栏颜色设置逻辑，状态栏颜色由应用主题控制
      // 只设置全屏布局，状态栏颜色将在MainPage中根据主题动态设置
    }).catch((err: Error) => {
      hilog.error(DOMAIN, 'testTag', 'Failed to get main window. Cause: %{public}s', JSON.stringify(err));
    });

    windowStage.loadContent('pages/MainPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      
      // ✅ 页面加载后再注册字体
      windowStage.getMainWindow().then((mainWindow: window.Window) => {
        try {
          hilog.info(DOMAIN, 'testTag', 'Start registering Pacifico font...');
          const uiContext = mainWindow.getUIContext();
          const fontManager = uiContext.getFont();
          fontManager.registerFont({
            familyName: 'Pacifico',
            familySrc: $rawfile('fonts/Pacifico-Regular.ttf')
          });
          hilog.info(DOMAIN, 'testTag', '✅ Pacifico font registered successfully!');
        } catch (err) {
          hilog.error(DOMAIN, 'testTag', '❌ Failed to register font: %{public}s', JSON.stringify(err));
        }
      }).catch((err: Error) => {
        hilog.error(DOMAIN, 'testTag', 'Failed to get main window: %{public}s', JSON.stringify(err));
      });
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