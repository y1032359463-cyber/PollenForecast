/*
 * CharacterDecor Component
 * 像素角色装饰组件 - Retro Pixel Theme
 * 
 * 支持4种状态：
 * - IDLE: 待机状态（默认）
 * - THINKING: 思考状态（输入数字时）
 * - CELEBRATE: 庆祝状态（计算成功）
 * - ERROR: 错误状态（计算错误）
 */

import { RetroPixelTheme } from '../common/RetroPixelTheme';

export enum PixelCharacterState {
  IDLE = 'IDLE',
  THINKING = 'THINKING',
  CELEBRATE = 'CELEBRATE',
  ERROR = 'ERROR'
}

/**
 * 像素角色装饰组件
 */
@Component
export struct CharacterDecor {
  @State currentState: PixelCharacterState = PixelCharacterState.IDLE;
  @State scaleValue: number = 1.0;  // 缩放动画
  @State opacityValue: number = 1.0;  // 透明度

  build() {
    Stack() {
      // 像素角色图片
      Image(this.getCharacterImage())
        .width(120)
        .height(120)
        .objectFit(ImageFit.Contain)
        .scale({ x: this.scaleValue, y: this.scaleValue })
        .opacity(this.opacityValue)
        .animation({
          duration: 200,
          curve: Curve.FastOutSlowIn
        })
    }
    .width('100%')
    .height(140)
    .alignContent(Alignment.Center)
  }

  /**
   * 根据状态获取角色图片路径
   */
  private getCharacterImage(): string {
    const imagePath = RetroPixelTheme.getCharacterPath(this.currentState);
    return imagePath;
  }

  /**
   * 更新角色状态
   * @param state 新状态
   */
  public updateState(state: PixelCharacterState): void {
    if (this.currentState === state) {
      return;
    }

    // 切换动画：缩小 → 切换图片 → 恢复
    this.scaleValue = 0.8;
    this.opacityValue = 0.7;

    setTimeout(() => {
      this.currentState = state;
      this.scaleValue = 1.0;
      this.opacityValue = 1.0;
    }, 100);
  }

  /**
   * 播放庆祝动画（跳跃效果）
   */
  public playCelebrateAnimation(): void {
    this.updateState(PixelCharacterState.CELEBRATE);

    // 跳跃动画：放大 → 缩小 → 恢夏
    this.scaleValue = 1.2;
    setTimeout(() => {
      this.scaleValue = 0.9;
      setTimeout(() => {
        this.scaleValue = 1.0;
      }, 150);
    }, 150);
  }

  /**
   * 播放错误动画（抖动效果）
   */
  public playErrorAnimation(): void {
    this.updateState(PixelCharacterState.ERROR);

    // 抖动动画：左右晃动
    let shakeCount = 0;
    const shakeInterval = setInterval(() => {
      this.scaleValue = shakeCount % 2 === 0 ? 1.1 : 0.9;
      shakeCount++;

      if (shakeCount >= 4) {
        clearInterval(shakeInterval);
        this.scaleValue = 1.0;
      }
    }, 100);
  }

  /**
   * 播放思考动画（闪烁效果）
   */
  public playThinkingAnimation(): void {
    this.updateState(PixelCharacterState.THINKING);

    // 闪烁动画
    this.opacityValue = 0.6;
    setTimeout(() => {
      this.opacityValue = 1.0;
    }, 200);
  }

  /**
   * 重置为待机状态
   */
  public resetToIdle(): void {
    this.updateState(PixelCharacterState.IDLE);
  }
}
