/*
 * CharacterDecor Component
 * 卡通角色装饰组件 - 支持左右手独立交替动画
 */

import { CharacterState } from '../common/Constant';
import { ThemeAnimations } from '../common/ThemeConfig';

/**
 * 角色装饰组件（三层设计：身体+左手+右手）
 */
@Component
export struct CharacterDecor {
  @State currentState: CharacterState = CharacterState.NORMAL;  // 当前状态
  @State leftHandOffsetY: number = 0;   // 左手Y轴偏移量
  @State rightHandOffsetY: number = 0;  // 右手Y轴偏移量
  @Link @Watch('onButtonPressChange') buttonPressCounter: number;     // 按键计数器，用于触发动画
  @Link @Watch('onCharacterTypeChange') characterType: string;        // 角色类型(whitecat/rabbit)

  /**
   * 监听角色类型变化，强制刷新组件
   */
  onCharacterTypeChange(): void {
    // 角色切换时，重置手臂位置
    this.leftHandOffsetY = 0;
    this.rightHandOffsetY = 0;
  }

  /**
   * 监听按键，触发左右手交替动画
   */
  onButtonPressChange(): void {
    if (this.buttonPressCounter > 0) {
      this.playButtonPressAnimation();
    }
  }

  build() {
    Stack() {
      // 身体层（固定，最底层）
      Image(this.getBodyImage())
        .width(150)
        .height(150)
        .objectFit(ImageFit.Contain)
        .zIndex(1)

      // 左手层（可动画，向上移动）
      Image(this.getLeftHandImage())
        .width(150)
        .height(150)
        .objectFit(ImageFit.Contain)
        .zIndex(2)
        .translate({ y: this.leftHandOffsetY })
        .animation({
          duration: 80,
          curve: Curve.Sharp
        })

      // 右手层（可动画，向下移动）
      Image(this.getRightHandImage())
        .width(150)
        .height(150)
        .objectFit(ImageFit.Contain)
        .zIndex(2)
        .translate({ y: this.rightHandOffsetY })
        .animation({
          duration: 80,
          curve: Curve.Sharp
        })
    }
    .width('100%')
    .height(160)  // 降低高度，从180改为160
    .alignContent(Alignment.Center)
  }

  /**
   * 根据状态获取身体图片
   */
  private getBodyImage(): Resource {
    if (this.characterType === 'rabbit') {
      return $r('app.media.rabbit_body');
    }
    return $r('app.media.whitecat_body');
  }

  /**
   * 根据状态获取左手图片
   */
  private getLeftHandImage(): Resource {
    if (this.characterType === 'rabbit') {
      return $r('app.media.rabbit_lefthand');
    }
    return $r('app.media.whitecat_lefthand');
  }

  /**
   * 根据状态获取右手图片
   */
  private getRightHandImage(): Resource {
    if (this.characterType === 'rabbit') {
      return $r('app.media.rabbit_righthand');
    }
    return $r('app.media.whitecat_righthand');
  }

  /**
   * 更新角色状态
   */
  public updateState(state: CharacterState): void {
    this.currentState = state;
  }

  /**
   * 播放按键动画 - 左右手交替移动
   * 左手: 向上移动一个手的高度 (-20vp) → 回到原位 (0)
   * 右手: 向下移动一个手的高度 (+20vp) → 回到原位 (0)
   * 效果: 模拟双手在键盘上敲击
   */
  public playButtonPressAnimation(): void {
    // 左手向上，右手向下
    this.leftHandOffsetY = -20;   // 左手上移
    this.rightHandOffsetY = 20;   // 右手下移

    // 延迟后双手回到原位
    setTimeout(() => {
      this.leftHandOffsetY = 0;
      this.rightHandOffsetY = 0;
    }, 60);
  }
}
