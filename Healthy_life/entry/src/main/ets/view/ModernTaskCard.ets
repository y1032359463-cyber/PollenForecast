/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { StyleUtils } from '../common/utils/StyleUtils';

/**
 * 现代化任务卡片组件
 * 
 * 设计规范:
 * - 参考Figma ModernTaskCard设计
 * - 圆角: 12px
 * - 内边距: 16px
 * - 阴影: 0 2px 12px rgba(0, 0, 0, 0.06)
 * - 图标: 48px圆形,带渐变背景
 * - 进度条: 6px高,圆角
 * - 交互动画: 点击缩放0.98, 图标悬停放大1.1
 */

@Component
export struct ModernTaskCard {
  @Prop icon: string = '📝'; // emoji图标
  @Prop title: string = '任务';
  @Prop current: number = 0;
  @Prop total: number = 1;
  @Prop unit: string = '次';
  @Prop color: string = '#00C853'; // 任务类型颜色
  onTaskClick?: () => void; // 点击回调
  @State isPressed: boolean = false;

  // 计算完成百分比
  private getProgress(): number {
    if (this.total === 0) return 0;
    return Math.min((this.current / this.total) * 100, 100);
  }

  // 获取任务类型颜色
  private getTaskColor(): string {
    return this.color || StyleUtils.getPrimaryColor();
  }

  build() {
    Column() {
      // 顶部: 图标圆形
      Stack() {
        // 渐变背景圆形
        Circle()
          .width(48)
          .height(48)
          .fill(this.getTaskColor())
          .shadow({
            radius: 12,
            color: this.getTaskColor() + '40', // 25% 透明度
            offsetY: 4
          })

        // Emoji图标
        Text(this.icon)
          .fontSize(24)
          .textAlign(TextAlign.Center)
      }
      .margin({ bottom: 12 })
      .transition({
        type: TransitionType.All,
        scale: { x: this.isPressed ? 1.1 : 1.0, y: this.isPressed ? 1.1 : 1.0 }
      })
      .animation({
        duration: 200,
        curve: Curve.EaseOut
      })

      // 中间: 任务标题
      Text(this.title)
        .fontSize(16)
        .fontWeight(600)
        .fontColor(StyleUtils.getTextPrimaryColor())
        .textAlign(TextAlign.Center)
        .width('100%')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ bottom: 12 })

      // 进度条
      Stack() {
        // 背景轨道
        Row()
          .width('100%')
          .height(6)
          .borderRadius(3)
          .backgroundColor(StyleUtils.getBackgroundColor())

        // 进度填充
        Row()
          .width(`${this.getProgress()}%`)
          .height(6)
          .borderRadius(3)
          .backgroundColor(this.getTaskColor())
          .transition({ type: TransitionType.All })
          .animation({
            duration: 300,
            curve: Curve.EaseOut
          })
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 底部: 进度文本
      Text(`${this.current} / ${this.total} ${this.unit}`)
        .fontSize(14)
        .fontWeight(500)
        .fontColor(StyleUtils.getTextSecondaryColor())
        .textAlign(TextAlign.Center)
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(StyleUtils.getBackgroundColor())
    .borderRadius(12)
    .border({ 
      width: 1, 
      color: '#E0E0E0' 
    })
    .shadow({
      radius: 12,
      color: 'rgba(0, 0, 0, 0.06)',
      offsetY: 2
    })
    .scale({ 
      x: this.isPressed ? 0.98 : 1.0, 
      y: this.isPressed ? 0.98 : 1.0 
    })
    .animation({
      duration: 150,
      curve: Curve.EaseOut
    })
    .onClick(() => {
      if (this.onTaskClick) {
        this.onTaskClick();
      }
    })
    .onTouch((event?: TouchEvent) => {
      if (event) {
        if (event.type === TouchType.Down) {
          this.isPressed = true;
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.isPressed = false;
        }
      }
    })
  }
}
