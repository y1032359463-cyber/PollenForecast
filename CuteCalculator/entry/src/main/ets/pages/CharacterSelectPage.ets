/*
 * CharacterSelectPage - 角色选择页面
 * Character Selection Page
 * 支持深色模式
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
      normalImage: 'whitecat_body',
      description: '经典款，萌萌哒'
    },
    {
      id: 'rabbit',
      name: '皎洁白兔',
      normalImage: 'rabbit_body',
      description: '纯洁优雅,温柔可爱'
    }
  ];

  async aboutToAppear() {
    this.characterType = await PreferencesUtils.getCharacterType();
  }

  build() {
    Column({ space: 0 }) {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })

        Text('选择角色')
          .fontSize(18)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Row()
          .width(24)
          .height(24)
      }
      .width('100%')
      .height(92)
      .padding({ left: 16, right: 16, top: 36 }) // top: 状态栏高度，总高度92=56+36
      .backgroundColor($r('app.color.bg_main'))

      // 角色列表
      Scroll() {
        Column({ space: 20 }) {
          ForEach(this.availableCharacters, (character: CharacterInfo) => {
            this.buildCharacterCard(character);
          })
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .width('100%')
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .friction(0.9)
      .backgroundColor($r('app.color.bg_main'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_main'))
  }

  @Builder
  buildCharacterCard(character: CharacterInfo) {
    Column({ space: 16 }) {
      Image($r(`app.media.${character.normalImage}`))
        .width(200)
        .height(200)
        .objectFit(ImageFit.Contain)
        .borderRadius(16)
        .backgroundColor($r('app.color.btn_normal'))

      Column({ space: 8 }) {
        Text(character.name)
          .fontSize(18)
          .fontColor($r('app.color.text_primary'))
          .fontWeight(FontWeight.Bold)

        Text(character.description)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }

      Button(this.characterType === character.id ? '✓ 已选择' : '选择此角色')
        .width(160)
        .height(44)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.characterType === character.id ? ThemeColors.PRIMARY_ORANGE : $r('app.color.btn_normal'))
        .fontColor(this.characterType === character.id ? '#FFFFFF' : $r('app.color.text_primary'))
        .borderRadius(22)
        .enabled(this.characterType !== character.id)
        .onClick(() => {
          this.selectCharacter(character.id, character.name);
        })
    }
    .width('100%')
    .padding(24)
    .backgroundColor($r('app.color.bg_card'))
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



  private selectCharacter(characterId: string, characterName: string): void {
    this.characterType = characterId;
    PreferencesUtils.setCharacterType(characterId);
    promptAction.showToast({
      message: `已选择 ${characterName}`,
      duration: 2000
    });

    setTimeout(() => {
      router.back();
    }, 500);
  }
}
