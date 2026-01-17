/*
 * SettingsSheet - 设置底部弹窗
 * Settings Bottom Sheet Component
 */

import { ThemeColors } from '../common/ThemeConfig';
import PreferencesUtils from '../utils/PreferencesUtils';
import { promptAction, router } from '@kit.ArkUI';
import { ThemeConfig } from '../utils/ThemeManager';

@CustomDialog
export struct SettingsSheet {
  @Link vibrateEnabled: boolean;
  @Link soundEnabled: boolean;
  @Link characterType: string;
  @Link buttonShape: string;      // 按钮形状
  @Link keyboardTheme: string;    // 键盘主题
  @Link buttonBorder: string;     // 按键边框
  controller: CustomDialogController;
  currentTheme?: ThemeConfig;
  
  // 拖拽相关
  @State dragOffsetY: number = 0;
  @State isDragging: boolean = false;
  @State slideOffsetY: number = 400; // 初始位置在底部外,用于滑入动画
  private startY: number = 0;
  private CLOSE_THRESHOLD: number = 100; // 下滑100vp关闭
  
  aboutToAppear() {
    // 延迟执行入场动画,确保组件已完成渲染
    setTimeout(() => {
      animateTo({
        duration: 300,
        curve: Curve.FastOutSlowIn
      }, () => {
        this.slideOffsetY = 0;
      });
    }, 50);
  }

  /**
   * 关闭弹窗时的滑下动画
   */
  private closeWithAnimation(): void {
    animateTo({
      duration: 250,
      curve: Curve.FastOutLinearIn
    }, () => {
      this.slideOffsetY = 400;
    });
    // 延迟关闭，等待动画完成
    setTimeout(() => {
      this.controller.close();
    }, 250);
  }

  build() {
    Column({ space: 0 }) {
      // 状态栏安全区域占位
      Blank()
        .height(36)
        .width('100%')

      // 顶部拖拽条
      Row() {
        Divider()
          .width(40)
          .height(4)
          .backgroundColor('#E5E5EA')
          .borderRadius(2)
      }
      .width('100%')
      .height(20)
      .justifyContent(FlexAlign.Center)

      // 标题
      Text('设置')
        .fontSize(20)
        .fontColor($r('app.color.text_primary'))
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })

      // 设置内容 - 2列网格布局，用Scroll包裹
      Scroll() {
        Column({ space: 16 }) {
          // 第一排：角色选择 + 键盘主题
          Row({ space: 16 }) {
            this.buildCharacterCard()
            this.buildKeyboardThemeCard()
          }
          .width('100%')

          // 第二排：按钮形状 + 按键边框（图片主题时禁用）
          Row({ space: 16 }) {
            if (this.keyboardTheme === 'default') {
              this.buildButtonShapeCard()
              this.buildButtonBorderCard()
            } else {
              this.buildDisabledCard('按钮形状', '图片主题不可用')
              this.buildDisabledCard('按键边框', '图片主题不可用')
            }
          }
          .width('100%')

          // 第三排：音效开关 + 震动开关
          Row({ space: 16 }) {
            this.buildSoundCard()
            this.buildVibrateCard()
          }
          .width('100%')

          // 第四排：主题选择（单独一行）
          Row({ space: 16 }) {
            this.buildThemeCard()
            // 空白占位，保持布局一致
            Column()
              .width('calc(50% - 8vp)')
              .aspectRatio(1)
          }
          .width('100%')

          // 第五排：使用条款和隐私政策合并
          this.buildPolicyCard()

          // 预留：广告移除（隐藏）
          // this.buildAdRemovalCard()
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 120 })  // 底部120vp填充，遮盖导航条
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .backgroundColor($r('app.color.bg_main'))
    .borderRadius({ topLeft: 24, topRight: 24 })
    .translate({ y: this.slideOffsetY + this.dragOffsetY })
    .animation({
      duration: this.isDragging ? 0 : 300,
      curve: Curve.EaseOut
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.startY = event.touches[0].y;
        this.isDragging = true;
      } else if (event.type === TouchType.Move) {
        const deltaY = event.touches[0].y - this.startY;
        // 只允许向下拖拽
        if (deltaY > 0) {
          this.dragOffsetY = deltaY;
        }
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isDragging = false;
        // 判断是否需要关闭
        if (this.dragOffsetY > this.CLOSE_THRESHOLD) {
          this.closeWithAnimation();
        }
        this.dragOffsetY = 0;
      }
    })
  }

  /**
   * 角色选择卡片（方形，点击进入角色列表页）
   */
  @Builder
  buildCharacterCard() {
    Column({ space: 8 }) {
      // 当前角色预览图片（使用真实猫咪图片）
      Image($r('app.media.whitecat_body'))
        .width(60)
        .height(60)
        .objectFit(ImageFit.Contain)

      Text('角色选择')
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
        .fontWeight(FontWeight.Medium)

      Text('可爱猫咪')
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('calc(50% - 8vp)')
    .aspectRatio(1) // 方形卡片
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(16)
    .shadow({
      radius: 12,
      color: 'rgba(255, 140, 66, 0.1)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      // 先关闭弹窗，再跳转
      this.controller.close();
      // 延迟跳转，确保弹窗关闭动画完成
      setTimeout(() => {
        router.pushUrl({ url: 'pages/CharacterSelectPage' })
          .catch((err: Error) => {
            promptAction.showToast({ message: '页面跳转失败', duration: 2000 });
          });
      }, 100);
    })
  }

  /**
   * 震动开关卡片（方形，无图标）
   */
  @Builder
  buildVibrateCard() {
    Column({ space: 8 }) {
      // 开关
      Toggle({ type: ToggleType.Switch, isOn: this.vibrateEnabled })
        .selectedColor(ThemeColors.PRIMARY_ORANGE)
        .width(52)
        .height(32)
        .onChange((isOn: boolean) => {
          this.vibrateEnabled = isOn;
          PreferencesUtils.setVibrateEnabled(isOn);
          promptAction.showToast({ message: isOn ? '震动已开启' : '震动已关闭', duration: 2000 });
        })

      Text('按键震动')
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
        .fontWeight(FontWeight.Medium)

      Text(this.vibrateEnabled ? '已开启' : '已关闭')
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('calc(50% - 8vp)')
    .aspectRatio(1) // 方形卡片
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(16)
    .shadow({
      radius: 12,
      color: 'rgba(255, 140, 66, 0.1)',
      offsetX: 0,
      offsetY: 2
    })
  }

  /**
   * 音效开关卡片（方形）
   */
  @Builder
  buildSoundCard() {
    Column({ space: 8 }) {
      // 开关
      Toggle({ type: ToggleType.Switch, isOn: this.soundEnabled })
        .selectedColor(ThemeColors.PRIMARY_ORANGE)
        .width(52)
        .height(32)
        .onChange((isOn: boolean) => {
          this.soundEnabled = isOn;
          PreferencesUtils.setSoundEnabled(isOn);
          promptAction.showToast({ message: isOn ? '音效已开启' : '音效已关闭', duration: 2000 });
        })

      Text('按键音效')
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
        .fontWeight(FontWeight.Medium)

      Text(this.soundEnabled ? '猫咪敲键盘' : '已静音')
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('calc(50% - 8vp)')
    .aspectRatio(1) // 方形卡片
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(16)
    .shadow({
      radius: 12,
      color: 'rgba(255, 140, 66, 0.1)',
      offsetX: 0,
      offsetY: 2
    })
  }

  /**
   * 主题选择卡片（方形）
   */
  @Builder
  buildThemeCard() {
    Column({ space: 8 }) {
      // 主题图标
      Column()
        .width(40)
        .height(40)
        .backgroundColor('#FF8C42')
        .borderRadius(10)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

      Text('主题选择')
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
        .fontWeight(FontWeight.Medium)

      Text('多种风格可选')
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('calc(50% - 8vp)')
    .aspectRatio(1) // 方形卡片
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(16)
    .shadow({
      radius: 12,
      color: 'rgba(255, 140, 66, 0.1)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      // 先关闭弹窗，再跳转
      this.controller.close();
      // 延迟跳转，确保弹窗关闭动画完成
      setTimeout(() => {
        router.pushUrl({ url: 'pages/ThemeSelectPage' })
          .catch((err: Error) => {
            promptAction.showToast({ message: '页面跳转失败', duration: 2000 });
          });
      }, 100);
    })
  }

  /**
   * 使用条款和隐私政策合并卡片（无图标，纯文字）
   */
  @Builder
  buildPolicyCard() {
    Row({ space: 16 }) {
      // 使用条款
      Column({ space: 8 }) {
        Text('使用条款')
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Medium)
      }
      .width('calc(50% - 8vp)')
      .height(60)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.bg_card'))
      .borderRadius(16)
      .shadow({
        radius: 12,
        color: 'rgba(255, 140, 66, 0.1)',
        offsetX: 0,
        offsetY: 2
      })
      .onClick(() => {
        this.showTermsDialog();
      })

      // 隐私政策
      Column({ space: 8 }) {
        Text('隐私政策')
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Medium)
      }
      .width('calc(50% - 8vp)')
      .height(60)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.bg_card'))
      .borderRadius(16)
      .shadow({
        radius: 12,
        color: 'rgba(255, 140, 66, 0.1)',
        offsetX: 0,
        offsetY: 2
      })
      .onClick(() => {
        this.showPrivacyDialog();
      })
    }
    .width('100%')
  }

  /**
   * 显示使用条款对话框
   */
  private showTermsDialog(): void {
    promptAction.showDialog({
      title: '使用条款',
      message: '感谢您使用卡通喵计算器！\n\n本应用为免费计算工具，仅供个人学习和日常使用。\n\n我们承诺不会收集您的任何个人信息。',
      buttons: [
        { text: '我知道了', color: ThemeColors.PRIMARY_ORANGE }
      ]
    }).catch((err: Error) => {
      console.error('Dialog error:', err);
    });
  }

  /**
   * 显示隐私政策对话框
   */
  private showPrivacyDialog(): void {
    promptAction.showDialog({
      title: '隐私政策',
      message: '卡通喵计算器重视您的隐私保护：\n\n✓ 不收集个人信息\n✓ 不上传使用数据\n✓ 所有计算本地完成\n✓ 历史记录仅保存在本地\n\n您的数据安全由HarmonyOS系统保护。',
      buttons: [
        { text: '我知道了', color: ThemeColors.PRIMARY_ORANGE }
      ]
    }).catch((err: Error) => {
      console.error('Dialog error:', err);
    });
  }

  /**
   * 广告移除卡片（预留接口）
   */
  @Builder
  buildAdRemovalCard() {
    Row() {
      Row({ space: 12 }) {
        Column() {
          Text('🚫')
            .fontSize(32)
        }
        .width(60)
        .height(60)
        .backgroundColor('#FFF5E6')
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)

        Column({ space: 4 }) {
          Text('移除广告')
            .fontSize(16)
            .fontColor(ThemeColors.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
          Text('永久享受无广告体验')
            .fontSize(12)
            .fontColor(ThemeColors.TEXT_SECONDARY)
        }
        .alignItems(HorizontalAlign.Start)
      }

      Blank()

      Button('¥6')
        .width(60)
        .height(36)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(ThemeColors.PRIMARY_ORANGE)
        .fontColor('#FFFFFF')
        .borderRadius(18)
        .onClick(() => {
          promptAction.showToast({ message: '功能开发中...', duration: 2000 });
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(16)
    .shadow({ 
      radius: 12, 
      color: 'rgba(255, 140, 66, 0.1)', 
      offsetX: 0, 
      offsetY: 2 
    })
  }

  /**
   * 禁用状态的卡片（图片主题时显示）
   */
  @Builder
  buildDisabledCard(title: string, hint: string) {
    Column({ space: 8 }) {
      // 禁用图标
      Column()
        .width(40)
        .height(40)
        .backgroundColor('#E0E0E0')
        .borderRadius(10)

      Text(title)
        .fontSize(14)
        .fontColor('#999999')
        .fontWeight(FontWeight.Medium)

      Text(hint)
        .fontSize(12)
        .fontColor('#BBBBBB')
    }
    .width('calc(50% - 8vp)')
    .aspectRatio(1)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
    .borderRadius(16)
    .opacity(0.6)
  }

  /**
   * 按钮形状选择卡片
   */
  @Builder
  buildButtonShapeCard() {
    Column({ space: 8 }) {
      // 形状预览图标 - 根据当前选择显示
      if (this.buttonShape === 'circle') {
        Column()
          .width(40)
          .height(40)
          .backgroundColor('#4ECDC4')
          .borderRadius(20) // 圆形
      } else {
        Column()
          .width(40)
          .height(40)
          .backgroundColor('#4ECDC4')
          .borderRadius(10) // 圆角
      }

      Text('按钮形状')
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
        .fontWeight(FontWeight.Medium)

      Text(this.buttonShape === 'circle' ? '圆形' : '圆角方形')
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('calc(50% - 8vp)')
    .aspectRatio(1)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(16)
    .shadow({ 
      radius: 12, 
      color: 'rgba(255, 140, 66, 0.1)', 
      offsetX: 0, 
      offsetY: 2 
    })
    .onClick(() => {
      this.controller.close();
      setTimeout(() => {
        router.pushUrl({ url: 'pages/ButtonShapeSelectPage' })
          .catch((err: Error) => {
            promptAction.showToast({ message: '页面跳转失败', duration: 2000 });
          });
      }, 100);
    })
  }

  /**
   * 键盘主题选择卡片
   */
  @Builder
  buildKeyboardThemeCard() {
    Column({ space: 8 }) {
      // 主题预览图标
      Image(this.getKeyboardThemeIcon())
        .width(40)
        .height(40)
        .objectFit(ImageFit.Contain)

      Text('键盘主题')
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
        .fontWeight(FontWeight.Medium)

      Text(this.getKeyboardThemeName())
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('calc(50% - 8vp)')
    .aspectRatio(1)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(16)
    .shadow({ 
      radius: 12, 
      color: 'rgba(255, 140, 66, 0.1)', 
      offsetX: 0, 
      offsetY: 2 
    })
    .onClick(() => {
      this.controller.close();
      setTimeout(() => {
        router.pushUrl({ url: 'pages/KeyboardThemeSelectPage' })
          .catch((err: Error) => {
            promptAction.showToast({ message: '页面跳转失败', duration: 2000 });
          });
      }, 100);
    })
  }

  /**
   * 按键边框选择卡片
   */
  @Builder
  buildButtonBorderCard() {
    Column({ space: 8 }) {
      // 边框风格预览
      this.buildBorderPreview()

      Text('按键边框')
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
        .fontWeight(FontWeight.Medium)

      Text(this.getButtonBorderName())
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('calc(50% - 8vp)')
    .aspectRatio(1)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(16)
    .shadow({ 
      radius: 12, 
      color: 'rgba(255, 140, 66, 0.1)', 
      offsetX: 0, 
      offsetY: 2 
    })
    .onClick(() => {
      this.controller.close();
      setTimeout(() => {
        router.pushUrl({ url: 'pages/ButtonBorderSelectPage' })
          .catch((err: Error) => {
            promptAction.showToast({ message: '页面跳转失败', duration: 2000 });
          });
      }, 100);
    })
  }

  /**
   * 获取键盘主题图标（用于设置页面预览，使用 normal 状态）
   * 注意：目前只有 catpaw 主题有图片，其他主题返回 catpaw 图片作为占位
   */
  private getKeyboardThemeIcon(): Resource {
    switch (this.keyboardTheme) {
      case 'catpaw': return $rawfile('keyboard_themes/catpaw/catpaw_5_normal.png');
      case 'star': return $rawfile('keyboard_themes/catpaw/catpaw_5_normal.png'); // TODO: 待添加 star 主题图片
      case 'heart': return $rawfile('keyboard_themes/catpaw/catpaw_5_normal.png'); // TODO: 待添加 heart 主题图片
      case 'cloud': return $rawfile('keyboard_themes/catpaw/catpaw_5_normal.png'); // TODO: 待添加 cloud 主题图片
      default: return $rawfile('keyboard_themes/catpaw/catpaw_5_normal.png'); // 使用 catpaw 作为默认图标
    }
  }

  /**
   * 获取键盘主题名称
   */
  private getKeyboardThemeName(): string {
    switch (this.keyboardTheme) {
      case 'catpaw': return '猫爪';
      case 'star': return '星星';
      case 'heart': return '爱心';
      case 'cloud': return '云朵';
      default: return '默认';
    }
  }

  /**
   * 获取按键边框名称
   */
  private getButtonBorderName(): string {
    switch (this.buttonBorder) {
      case 'flat': return '扁平';
      case '3d': return '3D立体';
      case 'neon': return '霓虹发光';
      case 'pixel': return '像素复古';
      default: return '扁平';
    }
  }

  /**
   * 边框预览构建器
   */
  @Builder
  buildBorderPreview() {
    if (this.buttonBorder === 'flat') {
      Column()
        .width(40)
        .height(40)
        .backgroundColor('#FF6B6B')
        .borderRadius(8)
    } else if (this.buttonBorder === '3d') {
      Column()
        .width(40)
        .height(40)
        .backgroundColor('#FF6B6B')
        .borderRadius(8)
        .shadow({ radius: 0, color: '#CC5555', offsetX: 0, offsetY: 4 })
        .border({ width: { bottom: 4 }, color: '#CC5555' })
    } else if (this.buttonBorder === 'neon') {
      Column()
        .width(40)
        .height(40)
        .backgroundColor('rgba(255, 107, 107, 0.3)')
        .borderRadius(8)
        .border({ width: 2, color: '#FF6B6B' })
        .shadow({ radius: 12, color: 'rgba(255, 107, 107, 0.6)', offsetX: 0, offsetY: 0 })
    } else {
      // pixel
      Column()
        .width(40)
        .height(40)
        .backgroundColor('#FF6B6B')
        .borderRadius(0)
        .border({ width: 3, color: '#000000' })
    }
  }
}
