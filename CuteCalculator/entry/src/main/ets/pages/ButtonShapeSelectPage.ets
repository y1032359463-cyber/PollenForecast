/*
 * ButtonShapeSelectPage - 按钮形状选择页面
 */

import { router } from '@kit.ArkUI';
import PreferencesUtils from '../utils/PreferencesUtils';

interface ShapeOption {
  id: string;
  name: string;
  description: string;
}

@Entry
@Component
struct ButtonShapeSelectPage {
  @State selectedShape: string = 'rounded';
  @State shapes: ShapeOption[] = [
    { id: 'rounded', name: '圆角方形', description: '经典圆角按钮，简洁大方' },
    { id: 'circle', name: '圆形', description: '可爱圆形按钮，萌趣十足' }
  ];

  async aboutToAppear() {
    this.selectedShape = await PreferencesUtils.getButtonShape();
  }

  build() {
    Column({ space: 0 }) {
      // 导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .onClick(() => router.back())

        Text('按钮形状')
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
          ForEach(this.shapes, (shape: ShapeOption) => {
            this.buildShapeCard(shape)
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
  buildShapeCard(shape: ShapeOption) {
    Column({ space: 12 }) {
      // 预览区域
      Row({ space: 12 }) {
        ForEach([1, 2, 3, 4], (num: number) => {
          Column()
            .width(50)
            .height(50)
            .backgroundColor($r('app.color.btn_normal'))
            .borderRadius(shape.id === 'circle' ? 25 : 12)
        })
      }
      .padding(16)

      Text(shape.name)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))

      Text(shape.description)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))

      Button(this.selectedShape === shape.id ? '✓ 已选择' : '选择')
        .width(120)
        .height(40)
        .fontSize(14)
        .backgroundColor(this.selectedShape === shape.id ? '#FF8C42' : $r('app.color.bg_card'))
        .fontColor(this.selectedShape === shape.id ? '#FFFFFF' : $r('app.color.text_primary'))
        .borderRadius(20)
        .enabled(this.selectedShape !== shape.id)
        .onClick(() => this.handleSelect(shape.id))
    }
    .width('100%')
    .padding(20)
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(20)
    .border({
      width: this.selectedShape === shape.id ? 3 : 0,
      color: '#FF8C42'
    })
    .shadow({ radius: 12, color: 'rgba(255, 140, 66, 0.15)', offsetX: 0, offsetY: 4 })
  }

  private async handleSelect(shapeId: string) {
    this.selectedShape = shapeId;
    await PreferencesUtils.setButtonShape(shapeId);
    router.back();
  }
}