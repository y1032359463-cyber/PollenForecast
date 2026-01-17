/*
 * CharacterSelectPage - 角色选择页面
 * Character Selection Page
 */

import { ThemeColors } from '../common/ThemeConfig';
import PreferencesUtils from '../utils/PreferencesUtils';
import { promptAction, router } from '@kit.ArkUI';

interface CharacterInfo {
  id: string;
  name: string;
  normalImage: string;
  description: string;
}

@Entry
@Component
struct CharacterSelectPage {
  @State characterType: string = 'whitecat'; // 默认白猫
  @State availableCharacters: CharacterInfo[] = [
    {
      id: 'whitecat',
      name: '白色猫咪',
      normalImage: 'whitecat_body', // 对应 resources/base/media/whitecat_body.png
      description: '经典款，萌萌哒'
    },
    {
      id: 'rabbit',
      name: '皎洁白兔',
      normalImage: 'rabbit_body', // 对应 resources/base/media/rabbit_body.png
      description: '纯洁优雅,温柔可爱'
    }
    // 预留更多角色
  ];

  async aboutToAppear() {
    // 加载当前选择的角色
    this.characterType = await PreferencesUtils.getCharacterType();
  }

  build() {
    Column({ space: 0 }) {
      // 状态栏安全区域占位
      Blank()
        .height(48)  // 状态栏高度约48vp
      
      // 顶部导航栏
      Row() {
        // 返回按钮
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor(ThemeColors.TEXT_PRIMARY)
          .onClick(() => {
            router.back();
          })

        Text('选择角色')
          .fontSize(18)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位，保持居中
        Row()
          .width(24)
          .height(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(ThemeColors.BG_MAIN)

      // 角色列表
      Scroll() {
        Column({ space: 20 }) {
          ForEach(this.availableCharacters, (character: CharacterInfo) => {
            this.buildCharacterCard(character);
          })

          // 预留更多角色
          this.buildComingSoonCard();
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .width('100%')
      .scrollable(ScrollDirection.Vertical)  // 明确启用垂直滚动
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)  // 边界回弹效果
      .friction(0.9)  // 增加摩擦力，使回弹更明显
      .backgroundColor(ThemeColors.BG_MAIN)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BG_MAIN)
  }

  /**
   * 角色卡片
   */
  @Builder
  buildCharacterCard(character: CharacterInfo) {
    Column({ space: 16 }) {
      // 角色预览图
      Image($r(`app.media.${character.normalImage}`))
        .width(200)
        .height(200)
        .objectFit(ImageFit.Contain)
        .borderRadius(16)
        .backgroundColor('#FFF5E6')

      // 角色信息
      Column({ space: 8 }) {
        Text(character.name)
          .fontSize(18)
          .fontColor(ThemeColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)

        Text(character.description)
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_SECONDARY)
      }

      // 选择按钮
      Button(this.characterType === character.id ? '✓ 已选择' : '选择此角色')
        .width(160)
        .height(44)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.characterType === character.id ? ThemeColors.PRIMARY_ORANGE : '#F5F5F5')
        .fontColor(this.characterType === character.id ? '#FFFFFF' : ThemeColors.TEXT_PRIMARY)
        .borderRadius(22)
        .enabled(this.characterType !== character.id)
        .onClick(() => {
          this.selectCharacter(character.id, character.name);
        })
    }
    .width('100%')
    .padding(24)
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(20)
    .border({
      width: this.characterType === character.id ? 3 : 0,
      color: ThemeColors.PRIMARY_ORANGE
    })
    .shadow({
      radius: 12,
      color: 'rgba(255, 140, 66, 0.15)',
      offsetX: 0,
      offsetY: 4
    })
  }

  /**
   * 敬请期待卡片
   */
  @Builder
  buildComingSoonCard() {
    Column({ space: 16 }) {
      // 占位图标
      Text('🔒')
        .fontSize(80)
        .opacity(0.3)

      Column({ space: 8 }) {
        Text('更多角色')
          .fontSize(18)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .fontWeight(FontWeight.Bold)

        Text('敬请期待...')
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_SECONDARY)
      }
    }
    .width('100%')
    .padding(48)
    .backgroundColor(ThemeColors.BG_CARD)
    .borderRadius(20)
    .opacity(0.6)
  }

  /**
   * 选择角色
   */
  private selectCharacter(characterId: string, characterName: string): void {
    this.characterType = characterId;
    PreferencesUtils.setCharacterType(characterId);
    promptAction.showToast({
      message: `已选择 ${characterName}`,
      duration: 2000
    });

    // 延迟返回，让用户看到选择效果
    setTimeout(() => {
      router.back();
    }, 500);
  }
}
