/*
 * ButtonBorderSelectPage - 按键边框选择页面
 */

import { router } from '@kit.ArkUI';
import PreferencesUtils from '../utils/PreferencesUtils';

interface BorderOption {
  id: string;
  name: string;
  description: string;
}

@Entry
@Component
struct ButtonBorderSelectPage {
  @State selectedBorder: string = 'flat';
  @State borders: BorderOption[] = [
    { id: 'flat', name: '扁平', description: '简洁无边框设计，现代简约' },
    { id: '3d', name: '3D立体', description: '立体浮雕效果，层次感强' },
    { id: 'neon', name: '霓虹发光', description: '炫酷发光边框，科技感十足' },
    { id: 'pixel', name: '像素复古', description: '经典像素风格，怀旧有趣' }
  ];

  async aboutToAppear() {
    this.selectedBorder = await PreferencesUtils.getButtonBorder();
  }

  build() {
    Column({ space: 0 }) {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .onClick(() => router.back())

        Text('按键边框')
          .fontSize(18)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Row().width(24).height(24)
      }
      .width('100%')
      .height(92)
      .padding({ left: 16, right: 16, top: 36 }) // top: 状态栏高度，总高度92=56+36
      .backgroundColor($r('app.color.bg_main'))

      // 选项列表
      Scroll() {
        Column({ space: 20 }) {
          ForEach(this.borders, (border: BorderOption) => {
            this.buildBorderCard(border)
          })
          Blank().height(100)
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_main'))
  }

  @Builder
  buildBorderCard(border: BorderOption) {
    Column({ space: 12 }) {
      // 预览区域
      Row({ space: 12 }) {
        ForEach(['1', '2', '3', '+'], (key: string) => {
          this.buildBorderPreview(border.id)
        })
      }
      .padding(16)

      Text(border.name)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      Text(border.description)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))

      Button(this.selectedBorder === border.id ? '✓ 已选择' : '选择')
        .width(120)
        .height(40)
        .fontSize(14)
        .backgroundColor(this.selectedBorder === border.id ? '#FF8C42' : $r('app.color.bg_card'))
        .fontColor(this.selectedBorder === border.id ? '#FFFFFF' : $r('app.color.text_primary'))
        .borderRadius(20)
        .enabled(this.selectedBorder !== border.id)
        .onClick(() => this.handleSelect(border.id))
    }
    .width('100%')
    .padding(20)
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(20)
    .border({ 
      width: this.selectedBorder === border.id ? 3 : 0, 
      color: '#FF8C42' 
    })
    .shadow({ radius: 12, color: 'rgba(255, 140, 66, 0.15)', offsetX: 0, offsetY: 4 })
  }

  /**
   * 边框预览构建器
   */
  @Builder
  buildBorderPreview(borderType: string) {
    if (borderType === 'flat') {
      Column()
        .width(50)
        .height(50)
        .backgroundColor('#FF6B6B')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
    } else if (borderType === '3d') {
      Column()
        .width(50)
        .height(50)
        .backgroundColor('#FF6B6B')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .shadow({ radius: 0, color: '#CC5555', offsetX: 0, offsetY: 4 })
        .border({ width: { bottom: 4 }, color: '#CC5555' })
    } else if (borderType === 'neon') {
      Column()
        .width(50)
        .height(50)
        .backgroundColor('rgba(255, 107, 107, 0.3)')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .border({ width: 2, color: '#FF6B6B' })
        .shadow({ radius: 12, color: 'rgba(255, 107, 107, 0.6)', offsetX: 0, offsetY: 0 })
    } else {
      // pixel
      Column()
        .width(50)
        .height(50)
        .backgroundColor('#FF6B6B')
        .borderRadius(0)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .border({ width: 3, color: '#000000' })
    }
  }

  private async handleSelect(borderId: string) {
    this.selectedBorder = borderId;
    await PreferencesUtils.setButtonBorder(borderId);
    router.back();
  }
}