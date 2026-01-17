/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { CommonConstants } from 'lib_foundation';

/**
 * 默认主题色 - 系统蓝
 */
const THEME_COLOR: string = '#007DFF';

@Builder
export function VipPageBuilder() {
  VipPage();
}

@ComponentV2
export struct VipPage {
  build() {
    NavDestination() {
      Column() {
        // 会员卡片
        Column() {
          Row() {
            Text('💎')
              .fontSize(40)
            Column() {
              Text('智算Pro 会员')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFD700')
              Text('解锁更多高级功能')
                .fontSize(14)
                .fontColor('#FFF8E1')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 16 })
          }
          .width('100%')
          .padding(24)
        }
        .width('100%')
        .borderRadius(16)
        .linearGradient({
          direction: GradientDirection.RightBottom,
          colors: [['#2C2C2C', 0], ['#1A1A1A', 1]]
        })
        .margin({ bottom: 24 })

        // 会员权益列表
        Column() {
          Text('会员专享权益')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .width('100%')
            .margin({ bottom: 16 })

          this.VipBenefitItem('🚫', '去除广告', '畅享无广告体验')
          this.VipBenefitItem('🎨', '专属主题', '多款精美主题任选')
          this.VipBenefitItem('☁️', '云端同步', '数据多端同步')
          this.VipBenefitItem('📊', '高级统计', '详细使用分析')
          this.VipBenefitItem('🔮', '优先体验', '新功能抢先体验')
        }
        .width('100%')
        .padding(16)
        .borderRadius(16)
        .backgroundColor($r('sys.color.comp_background_list_card'))

        Blank()

        // 开通会员按钮
        Button('敬请期待')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#E0E0E0')
          .fontColor('#999999')
          .borderRadius(24)
          .enabled(false)
          .margin({ bottom: 24 })

        Text('会员功能正在开发中，敬请期待')
          .fontSize(12)
          .fontColor($r('sys.color.font_tertiary'))
          .margin({ bottom: 16 })
      }
      .width('100%')
      .height('100%')
      .padding(16)
    }
    .title('会员中心')
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  VipBenefitItem(icon: string, title: string, desc: string) {
    Row() {
      Text(icon)
        .fontSize(24)
        .width(40)
        .textAlign(TextAlign.Center)

      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
        Text(desc)
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      Text('✓')
        .fontSize(16)
        .fontColor('#4CAF50')
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }
}
