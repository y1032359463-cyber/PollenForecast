/*
 * MainPage - 可爱计算器主页面
 * Main Calculator Page
 */

import { ResultDisplay } from '../components/ResultDisplay';
import { CharacterDecor } from '../components/CharacterDecor';
import { CuteCalcKeyboard } from '../components/CuteCalcKeyboard';
import { SettingsSheet } from '../components/SettingsSheet';
import CalculateUtil from '../common/CalculateUtil';
import { CalcConstants, CharacterState } from '../common/Constant';
import { ThemeColors, DarkThemeColors } from '../common/ThemeConfig';
import { HapticUtils } from '../utils/HapticUtils';
import { SoundUtils } from '../utils/SoundUtils';
import { HistoryUtils } from '../utils/HistoryUtils';
import PreferencesUtils, { AllSettings } from '../utils/PreferencesUtils';
import { ThemeManager, ThemeConfig, ThemeType } from '../utils/ThemeManager';
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { display } from '@kit.ArkUI';
import { router } from '@kit.ArkUI';
import promptAction from '@ohos.promptAction';
import { Configuration, ConfigurationConstant } from '@kit.AbilityKit';

@Entry
@Component
struct MainPage {
  @State expressions: string[] = []; // 表达式数组(华为格式)
  @State displayExpr: string = '0'; // 显示的表达式
  @State result: string = '0'; // 计算结果
  @State characterState: CharacterState = CharacterState.NORMAL;
  @State vibrateEnabled: boolean = true; // 振动开关
  @State soundEnabled: boolean = true; // 音效开关
  @State characterType: string = 'whitecat'; // 角色类型（whitecat/rabbit）
  @State buttonShape: string = 'rounded'; // 按钮形状（circle/rounded）
  @State keyboardTheme: string = 'default'; // 键盘主题（default/catpaw/star/heart/cloud）
  @State buttonBorder: string = 'flat'; // 按键边框（flat/3d/neon/pixel）
  @State buttonPressCounter: number = 0; // 按键计数器，用于触发角色动画
  // 使用 @StorageLink 双向绑定 AppStorage 的深浅色模式状态
  @StorageLink('isDarkMode') @Watch('onDarkModeChange') isDarkMode: boolean = false;
  @State currentTheme: ThemeConfig = ThemeManager.getAllThemes()[0]; // 当前主题配置
  // 设置弹窗控制器
  settingsDialogController: CustomDialogController = new CustomDialogController({
    builder: SettingsSheet({
      vibrateEnabled: $vibrateEnabled,
      soundEnabled: $soundEnabled,
      characterType: $characterType,
      buttonShape: $buttonShape,
      keyboardTheme: $keyboardTheme,
      buttonBorder: $buttonBorder,
      currentTheme: this.currentTheme
    }),
    alignment: DialogAlignment.Bottom,
    customStyle: true,
    autoCancel: false, // 禁用点击遮罩关闭，强制使用下滑手势
    maskColor: 'rgba(0, 0, 0, 0.5)'
    // 不使用openAnimation,由SettingsSheet内部的slideOffsetY控制滑入效果
  })
  // 华为广告配置（符合官方规范）
  @State adHeight: number = 0; // 广告位高度 (0=无广告, 73=小横幅57vp+边距, 160=大横幅144vp+边距)
  @State adLoaded: boolean = false; // 广告加载状态
  private adRefreshTimer: number = -1; // 广告刷新定时器
  // 稳定的点击回调，避免每次渲染都创建新函数导致子组件重绘
  private onBtnClick = (value: string): void => {
    this.handleButtonClick(value);
  }

  async aboutToAppear() {
    // 初始化Preferences
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    await PreferencesUtils.init(context);
    this.vibrateEnabled = await PreferencesUtils.getVibrateEnabled();
    this.soundEnabled = await PreferencesUtils.getSoundEnabled();
    this.characterType = await PreferencesUtils.getCharacterType();
    // 加载新配置
    this.buttonShape = await PreferencesUtils.getButtonShape();
    this.keyboardTheme = await PreferencesUtils.getKeyboardTheme();
    this.buttonBorder = await PreferencesUtils.getButtonBorder();

    // 获取当前主题
    this.currentTheme = await ThemeManager.getCurrentTheme();

    // 先检测系统深色模式
    this.detectDarkMode();

    // 初始化音效播放器
    await SoundUtils.init(context);

    // 初始化华为广告
    this.initHuaweiAd();
  }

  /**
   * 检测系统深色模式并初始化 AppStorage
   */
  private detectDarkMode(): void {
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const colorMode = context.config.colorMode;
      const darkMode = colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      
      // 初始化时同步到 AppStorage（确保与 EntryAbility 一致）
      AppStorage.setOrCreate('isDarkMode', darkMode);

      // 动态更新状态栏颜色
      this.updateSystemBarColor();
    } catch (error) {
      AppStorage.setOrCreate('isDarkMode', false);
    }
  }

  /**
   * 深浅色模式变化时的回调（由 @Watch 触发）
   */
  onDarkModeChange(): void {
    // 深浅色模式变化时更新状态栏颜色
    this.updateSystemBarColor();
  }

  /**
   * 更新状态栏颜色以匹配当前主题
   * 根据系统深色/浅色模式自动切换
   */
  private updateSystemBarColor(): void {
    try {
      window.getLastWindow(this.getUIContext().getHostContext()).then((mainWindow: window.Window) => {
        // 根据深色模式选择对应的颜色
        const statusBarBg = this.isDarkMode ? '#2C2C2E' : '#FFD4A3';
        const statusBarContent = this.isDarkMode ? '#FFFFFF' : '#000000';
        
        const sysBarProps: window.SystemBarProperties = {
          statusBarColor: statusBarBg,
          navigationBarColor: statusBarBg,
          statusBarContentColor: statusBarContent,
          navigationBarContentColor: statusBarContent
        };
        mainWindow.setWindowSystemBarProperties(sysBarProps);
      });
    } catch (error) {
      // 忽略错误
      console.error('Failed to update system bar color:', JSON.stringify(error));
    }
  }

  /**
   * 判断颜色是否为亮色
   * @param color 颜色值（十六进制字符串）
   * @returns 是否为亮色
   */
  private isLightColor(color: string): boolean {
    // 移除#号
    color = color.replace('#', '');
    
    // 将十六进制转换为RGB
    const r = parseInt(color.substring(0, 2), 16);
    const g = parseInt(color.substring(2, 4), 16);
    const b = parseInt(color.substring(4, 6), 16);
    
    // 计算亮度（使用相对亮度公式）
    const brightness = (r * 299 + g * 587 + b * 114) / 1000;
    
    // 亮度大于128视为亮色
    return brightness > 128;
  }

  /**
   * 获取当前主题背景色
   * 使用系统资源引用，自动适配亮/暗色模式
   */
  private getBackgroundColor(): ResourceColor {
    return $r('app.color.bg_main');
  }

  /**
   * 页面显示时回调（从设置页返回时会触发）
   * 性能优化：使用批量读取减少异步调用次数
   */
  onPageShow() {
    // 批量获取所有配置（一次异步调用代替多次）
    PreferencesUtils.getAllSettings().then((settings: AllSettings) => {
      // 只更新变化的状态，减少重渲染
      if (settings.characterType !== this.characterType) {
        this.characterType = settings.characterType;
      }
      if (settings.buttonShape !== this.buttonShape) {
        this.buttonShape = settings.buttonShape;
      }
      if (settings.keyboardTheme !== this.keyboardTheme) {
        this.keyboardTheme = settings.keyboardTheme;
      }
      if (settings.buttonBorder !== this.buttonBorder) {
        this.buttonBorder = settings.buttonBorder;
      }
    });
    
    // 非阻塞加载主题，传递深色模式状态
    ThemeManager.getCurrentTheme(this.isDarkMode).then((newTheme: ThemeConfig) => {
      if (newTheme.type !== this.currentTheme.type || newTheme.bgMain !== this.currentTheme.bgMain) {
        this.currentTheme = newTheme;
        // 主题变化时更新状态栏颜色
        this.updateSystemBarColor();
      }
    });
    
    // 重新检测深色模式（用户可能在后台切换了系统主题）
    this.detectDarkMode();
  }

  aboutToDisappear() {
    // 清理广告刷新定时器
    if (this.adRefreshTimer !== -1) {
      clearInterval(this.adRefreshTimer);
      this.adRefreshTimer = -1;
    }
  }

  /**
   * 初始化华为广告
   * TODO: 需在 oh-package.json5 中添加 "@kit.AdsKit": "^1.0.0"
   * TODO: 需在 module.json5 中添加 OAID 权限
   */
  private initHuaweiAd() {
    // TODO: 接入华为广告SDK
    // 参考代码:
    // import { advertising } from '@kit.AdsKit';
    // import { deviceAttributes } from '@kit.DeviceAttributesKit';
    //
    // try {
    //   // 1. 获取设备OAID（提升广告填充率）
    //   const oaid = await deviceAttributes.getOAID();
    //
    //   // 2. 配置广告参数（必须符合华为规范）
    //   const adParams = {
    //     adType: 8,                    // 横幅广告类型
    //     adId: 'testw6vs28auh3',       // 测试ID（上线前替换正式ID）
    //     adHeight: 144,                // 57 或 144 (vp)
    //     oaid: oaid,                   // 设备OAID
    //     refreshTime: 60000            // 刷新间隔 30000~120000ms
    //   };
    //
    //   // 3. 加载广告
    //   advertising.showBannerAd(adParams, (error, data) => {
    //     if (!error) {
    //       this.adLoaded = true;
    //       // 根据实际广告高度设置容器高度
    //       // 小横幅: 57vp + 16vp边距 = 73vp
    //       // 大横幅: 144vp + 16vp边距 = 160vp
    //       this.adHeight = adParams.adHeight === 57 ? 73 : 160;
    //     }
    //   });
    // } catch (error) {
    //   console.error('华为广告初始化失败:', error);
    // }

    // 临时测试: 模拟广告加载（开发阶段使用）
    setTimeout(() => {
      this.adLoaded = true;
      this.adHeight = 73; // 使用小横幅尺寸 (57vp + 16vp边距)
    }, 1000);
  }

  build() {
    Scroll() {
      Column() {
        // 图片预加载容器（不可见，用于提前加载所有角色图片到缓存）
        Stack() {
          // 白猫角色图片预加载
          Image($r('app.media.whitecat_body'))
            .width(1)
            .height(1)
            .visibility(Visibility.None)
          Image($r('app.media.whitecat_lefthand'))
            .width(1)
            .height(1)
            .visibility(Visibility.None)
          Image($r('app.media.whitecat_righthand'))
            .width(1)
            .height(1)
            .visibility(Visibility.None)

          // 兔子角色图片预加载
          Image($r('app.media.rabbit_body'))
            .width(1)
            .height(1)
            .visibility(Visibility.None)
          Image($r('app.media.rabbit_lefthand'))
            .width(1)
            .height(1)
            .visibility(Visibility.None)
          Image($r('app.media.rabbit_righthand'))
            .width(1)
            .height(1)
            .visibility(Visibility.None)
        }
        .width(0)
        .height(0)

        // 状态栏安全区域占位
        Blank()
          .height(48) // 状态栏高度约48vp

        // 第1排: 卡通互动 - 优化高度，适配小窗模式
        Row() {
          // 卡通角色 (左侧)
          CharacterDecor({
            buttonPressCounter: $buttonPressCounter,
            characterType: $characterType
          })
            .layoutWeight(1)
            .height(this.isSmallWindow() ? 120 : 160) // 小窗模式下减小高度

          // 历史记录按钮
          Button() {
            Text('历史')
              .fontSize(16)
              .fontColor('#FFFFFF')
          }
          .width(64)
          .height(40)
          .backgroundColor('#FF8C42')
          .borderRadius(20)
          .margin({ left: 8 })
          .onClick(() => {
            this.navigateToHistory();
          })

          // 设置按钮
          Button() {
            Text('设置')
              .fontSize(16)
              .fontColor('#FFFFFF')
          }
          .width(64)
          .height(40)
          .backgroundColor('#FF8C42')
          .borderRadius(20)
          .margin({ left: 8 })
          .onClick(() => {
            this.navigateToSettings();
          })
        }
        .width('100%')
        .height(this.isSmallWindow() ? 140 : 180) // 小窗模式下减小高度
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 8
        })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        // 第2排: 结果显示区域
        ResultDisplay({
          expression: this.displayExpr,
          result: this.result
        })

        // 第3排: 可爱键盘 - 优化高度，适配小窗模式
        CuteCalcKeyboard({
          onButtonClick: this.onBtnClick,
          buttonShape: this.buttonShape,
          keyboardTheme: this.keyboardTheme,
          buttonBorder: this.buttonBorder
        })
        // 小窗模式下使用固定高度，避免过高
          .height(this.isSmallWindow() ? 300 : undefined)
          .layoutWeight(this.isSmallWindow() ? 0 : 1) // 小窗模式下禁用自动填充

        // 小窗模式下隐藏广告相关内容，节省空间
        if (!this.isSmallWindow()) {
          // 与广告位保持固定20vp间隔
          Blank()
            .height(20)

          // 底部广告位（固定高度，符合华为规范）
          this.buildAdContainer()
        }
      }
      .width('100%')
      .backgroundColor(this.getBackgroundColor())
    }
    .width('100%')
    .height('100%')
    .height('100%') // 确保不超出父容器高度，使用height替代maxHeight
    .scrollable(ScrollDirection.Vertical) // 明确启用垂直滚动
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring) // 边界回弹效果
    .friction(0.9) // 增加摩擦力，使回弹更明显
    .align(Alignment.TopStart)
  }

  /**
   * 判断是否为小窗模式
   */
  private isSmallWindow(): boolean {
    // 获取当前窗口宽度，小于400vp视为小窗模式
    try {
      const defaultDisplay: display.Display = display.getDefaultDisplaySync();
      const winWidth: number = defaultDisplay.width;
      return winWidth < 400;
    } catch (error) {
      // 异常情况下默认返回false
      return false;
    }
  }

  /**
   * 构建华为广告容器
   * 符合官方规范: 仅支持 360vp×57vp 或 360vp×144vp
   * 固定高度: 57vp (小横幅) 或 144vp (大横幅) + 20vp底部安全区
   */
  @Builder
  buildAdContainer() {
    Column() {
      if (this.adLoaded && this.adHeight > 0) {
        // 华为横幅广告容器（固定高度）
        Column() {
          // TODO: 替换为实际的华为广告组件
          // 示例: HuaweiBannerAd({ adId: 'testw6vs28auh3', height: 57 })

          // 临时占位（开发阶段）
          Column() {
            Text('🎯 华为横幅广告位')
              .fontSize(14)
              .fontColor(Color.Transparent)
              .fontWeight(FontWeight.Medium)
            Text(this.adHeight === 73 ? '360vp × 57vp' : '360vp × 144vp')
              .fontSize(12)
              .fontColor(Color.Transparent)
              .margin({ top: 4 })
            Text('adId: testw6vs28auh3')
              .fontSize(10)
              .fontColor(Color.Transparent)
              .margin({ top: 2 })
          }
          .width('100%')
          .height(this.adHeight === 73 ? 57 : 144) // 使用固定高度（华为规范）
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(255, 245, 230, 0.8)') // 奶油色半透明
          .borderRadius({ topLeft: 16, topRight: 16 })
          .border({
            width: { top: 1 },
            color: 'rgba(255, 140, 66, 0.2)'
          })
          .shadow({
            radius: 8,
            color: 'rgba(255, 140, 66, 0.08)',
            offsetX: 0,
            offsetY: -2
          })
        }
        .width('100%')
      } else {
        // 无广告时显示20vp的底部安全区
        Blank()
          .height(0)
      }
    }
    .width('100%')
    .height(this.adLoaded ? (this.adHeight === 73 ? 77 : 164) : 20) // 广告高度 + 20vp底部安全区
    .animation({
      duration: 200,
      curve: Curve.Sharp
    })
  }

  /**
   * 处理按钮点击
   */
  private handleButtonClick(value: string): void {
    // 触发角色手臂动画（通过增加计数器）
    this.buttonPressCounter++;

    // 振动反馈
    if (this.vibrateEnabled) {
      if (value === CalcConstants.EQUAL) {
        HapticUtils.equalVibrate();
      } else {
        HapticUtils.buttonVibrate();
      }
    }

    // 音效反馈
    if (this.soundEnabled) {
      if (value === CalcConstants.EQUAL) {
        SoundUtils.playEqualSound();
      } else if (value === CalcConstants.CLEAR) {
        SoundUtils.playClearSound();
      } else {
        SoundUtils.playKeySound();
      }
    }

    // 根据按钮类型处理
    if (value === CalcConstants.CLEAR) {
      this.handleClear();
    } else if (value === CalcConstants.DELETE || value === CalcConstants.DEL || value === 'del') {
      this.handleDelete();
    } else if (value === CalcConstants.EQUAL) {
      this.handleEqual();
    } else {
      this.handleInput(value);
    }
  }

  /**
   * 处理清空
   */
  private handleClear(): void {
    this.expressions = [];
    this.displayExpr = ''; // 上方表达式框清空
    this.result = '0'; // 下方结果框显示0
    this.characterState = CharacterState.NORMAL;
  }

  /**
   * 处理删除(华为官方方式)
   */
  private handleDelete(): void {
    const len = this.expressions.length;
    if (len === 0) {
      return;
    }

    const lastValue = this.expressions[len - 1];

    // 如果最后一个是运算符，直接删除整个元素
    if (this.isOperator(lastValue)) {
      this.expressions.pop();
    } else {
      // 如果最后一个是数字
      if (lastValue.length === 1) {
        // 只有一个字符，删除整个元素
        this.expressions.pop();
      } else {
        // 多个字符，删除最后一个字符
        this.expressions[len - 1] = lastValue.slice(0, -1);
      }
    }

    this.updateDisplay();

    if (this.expressions.length === 0) {
      this.displayExpr = ''; // 上方表达式框清空
      this.result = '0'; // 下方结果框显示0
      this.characterState = CharacterState.NORMAL;
    }
  }

  /**
   * 处理输入(华为官方方式: 表达式数组直接存储)
   */
  private handleInput(value: string): void {
    // 如果当前显示的是计算结果（expressions为空但displayExpr不为空），清空重新开始
    if (this.expressions.length === 0 && this.displayExpr !== '' && !this.isOperator(value)) {
      this.displayExpr = ''; // 清空上方表达式框
      this.result = '0'; // 重置下方结果框
      this.characterState = CharacterState.NORMAL;
    }

    const len = this.expressions.length;

    // 判断是数字/小数点 还是 运算符
    if (this.isOperator(value)) {
      // 运算符: 如果最后一个元素是运算符，替换；否则添加
      if (len > 0) {
        const lastValue = this.expressions[len - 1];
        if (this.isOperator(lastValue)) {
          // 替换运算符
          this.expressions[len - 1] = value;
        } else {
          // 添加运算符
          this.expressions.push(value);
        }
      }
    } else {
      // 数字或小数点: 如果最后一个元素是数字，追加；否则添加新元素
      if (len === 0) {
        // 首次输入
        this.expressions.push(value);
      } else {
        const lastValue = this.expressions[len - 1];
        if (this.isOperator(lastValue)) {
          // 上一个是运算符，添加新数字
          this.expressions.push(value);
        } else {
          // 上一个是数字，追加
          if (value === '.' && lastValue.indexOf('.') !== -1) {
            // 已有小数点，不再添加
            return;
          }
          // 特殊处理: 如果当前数字是"0"，且输入非小数点的数字，替换"0"
          if (lastValue === '0' && value !== '.') {
            this.expressions[len - 1] = value;
          } else {
            this.expressions[len - 1] = lastValue + value;
          }
        }
      }
    }

    // 只在首次输入数字时更新状态
    if (!this.isOperator(value) && this.characterState !== CharacterState.CALCULATING) {
      this.characterState = CharacterState.CALCULATING;
    }
    this.updateDisplay();
  }

  /**
   * 更新显示(修改逻辑: 输入时在result框显示)
   */
  private updateDisplay(): void {
    const currentExpr = this.expressions.join('');
    // 输入阶段：expression保持空白，result显示当前输入
    this.displayExpr = '';
    this.result = currentExpr.length === 0 ? '0' : currentExpr;
  }

  /**
   * 判断是否为运算符
   */
  private isOperator(value: string): boolean {
    return CalcConstants.OPERATORS.indexOf(value) !== -1;
  }

  /**
   * 导航到历史记录页面
   */
  private navigateToHistory(): void {
    router.pushUrl({ url: 'pages/HistoryPage' }, router.RouterMode.Single).catch((err: Error) => {
      promptAction.showToast({ message: '页面跳转失败', duration: 2000 });
    });
  }

  /**
   * 导航到设置页面（改为打开底部弹窗）
   */
  private navigateToSettings(): void {
    this.settingsDialogController.open();
  }

  /**
   * 处理等号(使用华为CalculateUtil)
   */
  private handleEqual(): void {
    if (this.expressions.length === 0) {
      return;
    }

    // 先保存原始表达式用于显示
    const originalExpr = this.expressions.join('');

    // 如果最后一个是运算符，移除它
    const len = this.expressions.length;
    const lastValue = this.expressions[len - 1];
    if (this.isOperator(lastValue)) {
      this.expressions.pop();
    }

    if (this.expressions.length === 0) {
      return;
    }

    try {
      // 使用华为的 CalculateUtil.parseExpression 计算
      const calcResult = CalculateUtil.parseExpression(this.expressions);

      this.result = calcResult;

      if (this.result === 'Error' || this.result === 'NaN' || !this.result) {
        this.characterState = CharacterState.ERROR;
        this.result = 'Error';
        if (this.vibrateEnabled) {
          HapticUtils.errorVibrate();
        }
      } else {
        this.characterState = CharacterState.RESULT;

        // 保存到历史记录（使用之前保存的原始表达式）
        const fullExpression = originalExpr + ' = ' + this.result;
        HistoryUtils.updateHistoryResult(fullExpression);

        // 修改显示逻辑：表达式移到上方expression框，结果显示在result框
        this.displayExpr = originalExpr; // 表达式显示在上方
        // this.result 已经是计算结果，保持不变
        this.expressions = []; // 清空内部数组
      }
    } catch (error) {
      this.result = 'Error';
      this.characterState = CharacterState.ERROR;
      if (this.vibrateEnabled) {
        HapticUtils.errorVibrate();
      }
    }
  }
}
