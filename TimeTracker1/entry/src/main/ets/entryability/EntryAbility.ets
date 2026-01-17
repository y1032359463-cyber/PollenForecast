import { AbilityConstant, ConfigurationConstant, UIAbility, Want, common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { storageUtils, GlobalContext, ThemeManager, ThemeMode, EventBus } from '@ohos/commonlib';
import type { WorkRecord } from '@ohos/commonlib';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      // 设置全局上下文
      GlobalContext.setContext(this.context);
      
      // 初始化 AppStorage 中的上下文（供其他模块使用）
      AppStorage.setOrCreate<Context>('appContext', this.context);
      AppStorage.setOrCreate<common.UIAbilityContext>('uiAbilityContext', this.context);
      
      // 初始化 EventBus
      EventBus.init(this.context);
      
      // 初始化主题管理器
      ThemeManager.getInstance().init(this.context);
      
      // 初始化AppStorage中的主题颜色和主题模式(供所有页面使用)
      const initialColors = ThemeManager.getInstance().colors;
      const initialMode = ThemeManager.getInstance().getThemeMode();
      
      AppStorage.setOrCreate('themeColors', initialColors);
      AppStorage.setOrCreate('currentThemeMode', initialMode);
      
      hilog.info(DOMAIN, 'testTag', '🎨 初始化主题: mode=%{public}s, background=%{public}s', 
        initialMode, initialColors.background);
      
      // 初始化数据持久化工具
      storageUtils.init().then(async () => {
        hilog.info(DOMAIN, 'testTag', 'StorageUtils initialized successfully');
        // 添加测试数据（仅首次启动）
        await this.initTestData();
      }).catch((err: Error) => {
        hilog.error(DOMAIN, 'testTag', 'Failed to initialize StorageUtils: %{public}s', err.message);
      });
      
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

    // 先加载启动页
    windowStage.loadContent('pages/SplashPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      
      // 设置沉浸式状态栏
      windowStage.getMainWindow().then((mainWindow: window.Window) => {
        // 获取状态栏高度
        const avoidArea: window.AvoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        const statusBarHeight: number = avoidArea.topRect.height;
        AppStorage.setOrCreate('statusBarHeight', statusBarHeight);
        hilog.info(DOMAIN, 'testTag', 'StatusBar height: %{public}d', statusBarHeight);
        
        // 设置全屏布局（延伸到状态栏）
        mainWindow.setWindowLayoutFullScreen(true);
      });
      
      // 2秒后跳转到主页
      setTimeout(() => {
        windowStage.loadContent('pages/Index', (err) => {
          if (err.code) {
            hilog.error(DOMAIN, 'testTag', 'Failed to load Index page. Cause: %{public}s', JSON.stringify(err));
            return;
          }
          hilog.info(DOMAIN, 'testTag', 'Succeeded in loading Index page.');
        });
      }, 2000);
      
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the splash content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
    
    // 检查是否需要刷新系统主题 (用户可能在后台切换了系统主题)
    const themeManager = ThemeManager.getInstance();
    if (themeManager.getThemeMode() === ThemeMode.AUTO) {
      hilog.info(DOMAIN, 'testTag', '🎨 应用前台,检查系统主题');
      themeManager.refreshSystemTheme();
      
      // 更新AppStorage
      const colors = themeManager.colors;
      const newColors: import('@ohos/commonlib').ThemeColors = {
        background: colors.background,
        cardBackground: colors.cardBackground,
        surfaceBackground: colors.surfaceBackground,
        textPrimary: colors.textPrimary,
        textSecondary: colors.textSecondary,
        textHint: colors.textHint,
        primaryColor: colors.primaryColor,
        primaryLight: colors.primaryLight,
        primaryDark: colors.primaryDark,
        successColor: colors.successColor,
        warningColor: colors.warningColor,
        errorColor: colors.errorColor,
        dividerColor: colors.dividerColor,
        borderColor: colors.borderColor,
        shadowColor: colors.shadowColor
      };
      AppStorage.set('themeColors', newColors);
    }
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  /**
   * 监听系统配置变化(如主题切换)
   */
  onConfigurationUpdate(newConfig: import('@kit.AbilityKit').Configuration): void {
    hilog.info(DOMAIN, 'testTag', '🎨 系统配置变化 colorMode: %{public}d', newConfig.colorMode ?? -1);
    
    // 如果用户设置的是"跟随系统",则更新主题
    const themeManager = ThemeManager.getInstance();
    const currentMode = themeManager.getThemeMode();
    
    hilog.info(DOMAIN, 'testTag', '🎨 当前主题模式: %{public}s', currentMode);
    
    if (currentMode === ThemeMode.AUTO) {
      hilog.info(DOMAIN, 'testTag', '🎨 AUTO模式,开始刷新系统主题');
      
      // 使用专门的刷新方法,不重新初始化context
      themeManager.refreshSystemTheme();
      
      // 手动创建新的颜色对象,触发AppStorage监听
      const colors = themeManager.colors;
      const newColors: import('@ohos/commonlib').ThemeColors = {
        background: colors.background,
        cardBackground: colors.cardBackground,
        surfaceBackground: colors.surfaceBackground,
        textPrimary: colors.textPrimary,
        textSecondary: colors.textSecondary,
        textHint: colors.textHint,
        primaryColor: colors.primaryColor,
        primaryLight: colors.primaryLight,
        primaryDark: colors.primaryDark,
        successColor: colors.successColor,
        warningColor: colors.warningColor,
        errorColor: colors.errorColor,
        dividerColor: colors.dividerColor,
        borderColor: colors.borderColor,
        shadowColor: colors.shadowColor
      };
      
      AppStorage.set('themeColors', newColors);
      AppStorage.set('currentThemeMode', ThemeMode.AUTO);
      
      hilog.info(DOMAIN, 'testTag', '🎨 系统主题已更新: background=%{public}s', newColors.background);
    } else {
      hilog.info(DOMAIN, 'testTag', '🎨 非AUTO模式,跳过系统主题刷新');
    }
  }

  /**
   * 初始化测试数据（仅首次启动时添加）
   */
  private async initTestData(): Promise<void> {
    try {
      const records = await storageUtils.getAllWorkRecords();
      if (records.length > 0) {
        hilog.info(DOMAIN, 'testTag', 'Test data already exists, skip initialization');
        return;
      }

      // 当前日期
      const today = new Date();
      const currentYear = today.getFullYear();
      const currentMonth = today.getMonth();

      // 添加6条测试记录（本月不同日期）
      const testRecords: WorkRecord[] = [
        {
          id: `test_${Date.now()}_1`,
          date: `${currentYear}-${(currentMonth + 1).toString().padStart(2, '0')}-15`,
          startTime: '09:00',
          endTime: '17:00',
          duration: 8,
          projectType: 'dev',
          projectName: 'TimeTracker开发',
          hourlyWage: 50,
          allowance: 20,
          deduction: 0,
          remarks: '完成首页日历功能',
          createdAt: new Date().toISOString()
        },
        {
          id: `test_${Date.now()}_2`,
          date: `${currentYear}-${(currentMonth + 1).toString().padStart(2, '0')}-16`,
          startTime: '10:00',
          endTime: '18:00',
          duration: 8,
          projectType: 'design',
          projectName: 'UI设计优化',
          hourlyWage: 60,
          allowance: 0,
          deduction: 0,
          remarks: 'Figma设计审查',
          createdAt: new Date().toISOString()
        },
        {
          id: `test_${Date.now()}_3`,
          date: `${currentYear}-${(currentMonth + 1).toString().padStart(2, '0')}-17`,
          startTime: '14:00',
          endTime: '18:00',
          duration: 4,
          projectType: 'meeting',
          projectName: '项目评审',
          hourlyWage: 40,
          allowance: 15,
          deduction: 0,
          remarks: '技术方案讨论',
          createdAt: new Date().toISOString()
        },
        {
          id: `test_${Date.now()}_4`,
          date: `${currentYear}-${(currentMonth + 1).toString().padStart(2, '0')}-18`,
          startTime: '09:00',
          endTime: '12:00',
          duration: 3,
          projectType: 'test',
          projectName: 'Bug修复',
          hourlyWage: 45,
          allowance: 0,
          deduction: 5,
          remarks: '修复日历组件问题',
          createdAt: new Date().toISOString()
        },
        {
          id: `test_${Date.now()}_5`,
          date: `${currentYear}-${(currentMonth + 1).toString().padStart(2, '0')}-19`,
          startTime: '09:00',
          endTime: '18:00',
          duration: 9,
          projectType: 'dev',
          projectName: 'ProfilePage开发',
          hourlyWage: 50,
          allowance: 30,
          deduction: 0,
          remarks: '完成个人中心页面',
          createdAt: new Date().toISOString()
        },
        {
          id: `test_${Date.now()}_6`,
          date: `${today.getFullYear()}-${(today.getMonth() + 1).toString().padStart(2, '0')}-${today.getDate().toString().padStart(2, '0')}`,
          startTime: '09:00',
          endTime: '13:00',
          duration: 4,
          projectType: 'doc',
          projectName: '技术文档编写',
          hourlyWage: 35,
          allowance: 0,
          deduction: 0,
          remarks: '编写API文档',
          createdAt: new Date().toISOString()
        }
      ];

      for (const record of testRecords) {
        await storageUtils.saveWorkRecord(record);
      }

      hilog.info(DOMAIN, 'testTag', `Initialized ${testRecords.length} test records successfully`);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to initialize test data: %{public}s', JSON.stringify(err));
    }
  }
}