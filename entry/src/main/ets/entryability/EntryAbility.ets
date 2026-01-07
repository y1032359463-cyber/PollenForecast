import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window, display } from '@kit.ArkUI';
import { LocationService } from '../service/LocationService';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { NotificationService } from '../utils/NotificationService';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private mainWindowInstance?: window.Window;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.info('🟡 [EntryAbility] onCreate 调用');
    
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }

    // 初始化共享数据
    AppStorage.setOrCreate('currentCity', '定位中...');
    AppStorage.setOrCreate('pollenValue', 0);
    AppStorage.setOrCreate('pollenLevel', '加载中...');
    AppStorage.setOrCreate('updateTime', '获取中...');
    AppStorage.setOrCreate('latitude', 23.1291);
    AppStorage.setOrCreate('longitude', 113.2644);
    
    // 初始化花粉主题色（默认绿色 - 极低等级）
    AppStorage.setOrCreate('pollenThemeColor', '#4CAF50');

    // 初始化主题状态（让 MapView 能响应主题切换）
    AppStorage.setOrCreate('currentColorMode', this.context.config.colorMode);

    // 初始化应用前后台状态
    AppStorage.setOrCreate('isAppInBackground', false);

    // 初始化通知设置（默认关闭）
    AppStorage.setOrCreate('notificationEnabled', false);
    AppStorage.setOrCreate('pollenAlertEnabled', true);
    AppStorage.setOrCreate('dailyReportEnabled', true);
    AppStorage.setOrCreate('dailyReportTime', '08:00');

    // 初始化数据源选择（默认自动选择）
    AppStorage.setOrCreate('pollenDataSource', 'AUTO');

    // 设置 LocationService 的 context
    LocationService.getInstance().setContext(this.context);

    // 设置 NotificationService 的 context（用于 WorkScheduler）
    NotificationService.getInstance().setContext(this.context);

    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    console.info('🔵 [EntryAbility] onWindowStageCreate 调用');

    // 在窗口创建阶段请求权限（修正生命周期）
    console.info('🔵 [EntryAbility] 准备请求定位权限');
    this.requestLocationPermissions();
    
    // 请求代理提醒权限（用于定时通知）
    console.info('🔵 [EntryAbility] 准备请求代理提醒权限');
    this.requestReminderPermission();

    // 获取主窗口并设置沉浸式状态栏
    const mainWindow = windowStage.getMainWindowSync();
    this.mainWindowInstance = mainWindow;

    // 1. 设置全屏布局（内容延伸到状态栏下方）
    try {
      mainWindow.setWindowLayoutFullScreen(true);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', '设置全屏失败: %{public}s', JSON.stringify(err));
    }

    // 2. 根据当前主题设置状态栏
    try {
      this.updateStatusBarForTheme(mainWindow);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', '更新状态栏失败: %{public}s', JSON.stringify(err));
    }

    // 3. 动态获取安全区域高度并存储到 AppStorage
    try {
      // 获取状态栏高度（TYPE_SYSTEM）
      const topArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const statusBarHeight = topArea.topRect.height;
      
      // 获取导航栏高度（TYPE_NAVIGATION_INDICATOR）
      const bottomArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      const navBarHeight = bottomArea.bottomRect.height;
      
      let density = 3; // 默认屏幕密度
      try {
        density = display.getDefaultDisplaySync().densityPixels;
      } catch (displayErr) {
        hilog.error(DOMAIN, 'testTag', '获取屏幕密度失败: %{public}s', JSON.stringify(displayErr));
      }
      
      const safeTop = statusBarHeight / density;
      const safeBottom = navBarHeight / density;

      AppStorage.setOrCreate('safeTop', safeTop);
      AppStorage.setOrCreate('safeBottom', safeBottom);
      hilog.info(DOMAIN, 'testTag', `SafeArea - top: ${safeTop}vp, bottom: ${safeBottom}vp`);
    } catch (err) {
      // 获取失败时使用默认值
      AppStorage.setOrCreate('safeTop', 44);
      AppStorage.setOrCreate('safeBottom', 28);
      hilog.error(DOMAIN, 'testTag', 'Failed to get avoidArea: %{public}s', JSON.stringify(err));
    }

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  /**
   * 根据主题更新状态栏样式
   */
  private updateStatusBarForTheme(mainWindow: window.Window, colorMode?: number): void {
    try {
      // 优先使用传入的 colorMode，否则从 context 读取
      const currentColorMode = colorMode ?? this.context.config.colorMode;
      
      let systemBarProperties: window.SystemBarProperties;
      
      // 判断当前是深色还是浅色模式
      if (currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
        // 深色模式：完全透明状态栏 + 白色图标
        systemBarProperties = {
          statusBarColor: '#00000000',        // 完全透明
          statusBarContentColor: '#FFFFFF',   // 白色文字/图标
          isStatusBarLightIcon: true          // 亮色图标
        };
        hilog.info(DOMAIN, 'testTag', '状态栏设置：深色模式（透明背景+白色图标）');
      } else {
        // 浅色模式：完全透明状态栏 + 深色图标（适配浅色导航栏）
        systemBarProperties = {
          statusBarColor: '#00000000',        // 完全透明
          statusBarContentColor: '#000000',   // 纯黑文字/图标
          isStatusBarLightIcon: false         // 深色图标
        };
        hilog.info(DOMAIN, 'testTag', '状态栏设置：浅色模式（透明背景+深色图标）');
      }
      
      mainWindow.setWindowSystemBarProperties(systemBarProperties);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', '设置状态栏失败: %{public}s', JSON.stringify(err));
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has come to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
    
    // 通知所有组件应用已回到前台
    AppStorage.setOrCreate('isAppInBackground', false);
    console.info('🟢 [EntryAbility] 应用回到前台，允许传感器恢复');

    // 检查是否需要发送每日播报（应用启动时检查）
    this.checkAndSendDailyReport();
  }

  /**
   * 检查并发送每日播报（应用启动时调用）
   * 调用 NotificationService 的统一方法
   */
  private async checkAndSendDailyReport(): Promise<void> {
    try {
      const notificationService = NotificationService.getInstance();
      await notificationService.checkAndSendDailyReport();
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', `检查每日播报失败: ${JSON.stringify(err)}`);
    }
  }

  /**
   * 配置变化回调（包括主题切换）
   */
  onConfigurationUpdate(newConfig: import('@kit.AbilityKit').Configuration): void {
    hilog.info(DOMAIN, 'testTag', '配置更新 - ColorMode: %{public}d', newConfig.colorMode ?? 0);
    
    // 更新 AppStorage 中的主题状态（让 MapView 响应）
    const newColorMode = newConfig.colorMode ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
    AppStorage.setOrCreate('currentColorMode', newColorMode);
    
    // 主题变化时更新状态栏（传递新的 colorMode）
    if (this.mainWindowInstance) {
      this.updateStatusBarForTheme(this.mainWindowInstance, newColorMode);
    }
  }

  /**
   * 请求定位权限（动态权限请求）
   */
  private async requestLocationPermissions(): Promise<void> {
    console.info('🟢 [EntryAbility] requestLocationPermissions 开始执行');
    
    const permissions: Array<Permissions> = [
      'ohos.permission.LOCATION',
      'ohos.permission.APPROXIMATELY_LOCATION'
    ];

    try {
      console.info('🟢 [EntryAbility] 创建权限管理器');
      const atManager = abilityAccessCtrl.createAtManager();
      
      console.info('🟢 [EntryAbility] 请求权限: ' + JSON.stringify(permissions));
      const grantStatus = await atManager.requestPermissionsFromUser(this.context, permissions);
      
      console.info('🟢 [EntryAbility] 权限请求结果: ' + JSON.stringify(grantStatus));
      console.info('🟢 [EntryAbility] 权限结果数组: ' + JSON.stringify(grantStatus.authResults));
      
      // 检查权限是否被授予
      if (grantStatus.authResults.every(result => result === 0)) {
        console.info('✅ [EntryAbility] 定位权限已授予');
        hilog.info(DOMAIN, 'testTag', '✅ 定位权限已授予');
      } else {
        console.warn('⚠️ [EntryAbility] 定位权限被拒绝');
        hilog.warn(DOMAIN, 'testTag', '⚠️ 定位权限被拒绝');
      }
    } catch (err) {
      console.error('❌ [EntryAbility] 请求定位权限失败: ' + JSON.stringify(err));
      hilog.error(DOMAIN, 'testTag', '❌ 请求定位权限失败: %{public}s', JSON.stringify(err));
    }
  }

  /**
   * 请求代理提醒权限（用于定时通知）
   * 权限：ohos.permission.PUBLISH_AGENT_REMINDER
   */
  private async requestReminderPermission(): Promise<void> {
    console.info('🟢 [EntryAbility] requestReminderPermission 开始执行');
    
    const permissions: Array<Permissions> = [
      'ohos.permission.PUBLISH_AGENT_REMINDER'
    ];

    try {
      const atManager = abilityAccessCtrl.createAtManager();
      
      console.info('🔔 [EntryAbility] 请求代理提醒权限');
      const grantStatus = await atManager.requestPermissionsFromUser(this.context, permissions);
      
      console.info('🔔 [EntryAbility] 代理提醒权限结果: ' + JSON.stringify(grantStatus.authResults));
      
      // 检查权限是否被授予
      if (grantStatus.authResults[0] === 0) {
        console.info('✅ [EntryAbility] 代理提醒权限已授予');
        hilog.info(DOMAIN, 'testTag', '✅ 代理提醒权限已授予');
      } else {
        console.warn('⚠️ [EntryAbility] 代理提醒权限被拒绝');
        hilog.warn(DOMAIN, 'testTag', '⚠️ 代理提醒权限被拒绝');
      }
    } catch (err) {
      console.error('❌ [EntryAbility] 请求代理提醒权限失败: ' + JSON.stringify(err));
      hilog.error(DOMAIN, 'testTag', '❌ 请求代理提醒权限失败: %{public}s', JSON.stringify(err));
    }
  }
}