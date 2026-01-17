/*
 * SettingsPage - 设置页面
 * Settings Page
 * 支持深色模式自动适配
 */

import { ThemeColors, ThemeSizes } from '../common/ThemeConfig';
import PreferencesUtils from '../utils/PreferencesUtils';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct SettingsPage {
  @State vibrateEnabled: boolean = true;      // 振动开关
  @State characterType: string = 'cat';       // 角色类型

  async aboutToAppear() {
    // 加载设置
    this.vibrateEnabled = await PreferencesUtils.getVibrateEnabled();
    this.characterType = await PreferencesUtils.getCharacterType();
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor($r('app.color.text_primary'))
          .onClick(() => {
            router.back({ url: 'pages/MainPage' });
          })

        Text('设置')
          .fontSize(20)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
      }
      .width('100%')
      .height(92)
      .padding({ left: 20, right: 20, top: 36 }) // top: 状态栏高度，总高度92=56+36

      // 设置列表
      Column() {
        // 振动开关
        Row() {
          Text('按键振动')
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))

          Blank()

          Toggle({ type: ToggleType.Switch, isOn: this.vibrateEnabled })
            .selectedColor(ThemeColors.PRIMARY_ORANGE)
            .onChange((isOn: boolean) => {
              this.vibrateEnabled = isOn;
              PreferencesUtils.setVibrateEnabled(isOn);
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 20, right: 20 })
        .backgroundColor($r('app.color.bg_card'))

        Divider()
          .strokeWidth(0.5)
          .color($r('app.color.border_color'))

        // 角色选择
        Row() {
          Text('角色选择')
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))

          Blank()

          Text(this.getCharacterName())
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))

          Image($r('app.media.ic_arrow_right'))
            .width(20)
            .height(20)
            .fillColor($r('app.color.text_secondary'))
            .margin({ left: 8 })
        }
        .width('100%')
        .height(56)
        .padding({ left: 20, right: 20 })
        .backgroundColor($r('app.color.bg_card'))
        .onClick(() => {
          this.showCharacterPicker();
        })
      }
      .width('100%')
      .margin({ top: 16 })
      .borderRadius(12)

      // 关于分组
      Column() {
        Row() {
          Text('关于')
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))

          Blank()

          Text('v1.0.0')
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .height(56)
        .padding({ left: 20, right: 20 })
        .backgroundColor($r('app.color.bg_card'))
        .onClick(() => {
          this.showAboutDialog();
        })
      }
      .width('100%')
      .margin({ top: 16 })
      .borderRadius(12)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_main'))
  }

  /**
   * 获取角色名称
   */
  private getCharacterName(): string {
    switch (this.characterType) {
      case 'cat':
        return '可爱猫咪';
      default:
        return '可爱猫咪';
    }
  }

  /**
   * 显示角色选择器
   */
  private showCharacterPicker(): void {
    promptAction.showDialog({
      title: '选择角色',
      message: '当前可用角色：',
      buttons: [
        { text: '取消', color: ThemeColors.TEXT_SECONDARY },
        { text: '可爱猫咪 🐱', color: ThemeColors.PRIMARY_ORANGE }
      ]
    }).then((data: promptAction.ShowDialogSuccessResponse) => {
      if (data.index === 1) {
        this.characterType = 'cat';
        PreferencesUtils.setCharacterType('cat');
        promptAction.showToast({ message: '已选择可爱猫咪', duration: 2000 });
      }
    }).catch((err: Error) => {
      console.error('Dialog error:', err);
    });
  }

  /**
   * 显示关于对话框
   */
  private showAboutDialog(): void {
    promptAction.showDialog({
      title: '可爱计算器',
      message: '版本: v1.0.0\n\n一个可爱风格的HarmonyOS计算器\n\n© 2025',
      buttons: [
        { text: '确定', color: ThemeColors.PRIMARY_ORANGE }
      ]
    }).catch((err: Error) => {
      console.error('Dialog error:', err);
    });
  }
}
