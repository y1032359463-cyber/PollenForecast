/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { HomeStore } from '../../viewmodel/HomeViewModel';
import { WeekCalendar } from './WeekCalendarComponent';
import { CommonConstants as Const } from '../../common/constants/CommonConstants';
import HealthText from '../../view/HealthTextComponent';
import { GreetingCard } from './GreetingCard';

@Extend(Text)
function titleTextStyle() {
  .fontSize($r('app.float.default_16'))
  .fontWeight(Const.FONT_WEIGHT_500)
  .width(Const.THOUSANDTH_1000)
  .fontFamily($r('app.string.HarmonyHeiTi_Medium'))
  .fontColor($r(`app.element.color.titleColor`))
}

@Component
export default struct HomeTopView {
  @Link homeStore: HomeStore;

  /**
   * 获取问候语 (根据时间)
   */
  private getGreeting(): string {
    const hour = new Date().getHours();
    if (hour < 6) return '深夜好';
    if (hour < 9) return '早安';
    if (hour < 12) return '上午好';
    if (hour < 14) return '中午好';
    if (hour < 18) return '下午好';
    if (hour < 22) return '晚上好';
    return '夜深了';
  }

  /**
   * 获取励志消息
   */
  private getMotivationalMessage(): string {
    const messages = [
      '今天也要元气满满哦！',
      '每一天都是新的开始',
      '坚持就是胜利',
      '你已经很棒了',
      '继续加油，未来可期'
    ];
    const dayOfYear = Math.floor((Date.now() - new Date(new Date().getFullYear(), 0, 0).getTime()) / 86400000);
    return messages[dayOfYear % messages.length];
  }

  build() {
    Column() {
      // 问候卡片 (新增)
      GreetingCard({
        greeting: this.getGreeting(),
        userName: '朋友',
        message: this.getMotivationalMessage(),
        primaryColor: '#00C853'
      })
        .margin({ 
          top: $r('app.float.default_16'),
          left: $r('app.float.default_16'), 
          right: $r('app.float.default_16') 
        })

      // 原有进度显示
      Text($r('app.string.target_progress'))
        .titleTextStyle()
        .opacity(Const.OPACITY_6)
        .padding({ left: $r('app.float.default_24'), top: $r('app.float.default_16') })
      Row() {
        HealthText({
          title: this.homeStore.getDonePercent(),
          fontSize: $r('app.float.default_72'),
          fontFamily: $r('app.string.HarmonyHeiTi_Bold'),
          fontWeight: Const.FONT_WEIGHT_700
        })
        Text('%')
          .titleTextStyle()
          .fontSize($r('app.float.default_40'))
          .margin({ top: $r('app.float.default_12'), left: $r('app.float.default_8') })
      }
      .width(Const.THOUSANDTH_1000)
      .padding({ left: $r('app.float.default_24') })

      WeekCalendar({ homeStore: this.homeStore })
    }
    .height(Const.THOUSANDTH_500 + 100)  // 增加高度以容纳问候卡片
    .backgroundImagePosition({ x: 0, y: 0 })
    .backgroundImage($r('app.media.ic_home_bg'))
    .backgroundImageSize({ width: Const.THOUSANDTH_1000, height: Const.THOUSANDTH_900 })
    .justifyContent(FlexAlign.Start)  // 改为从顶部开始
    .padding({ top: $r('app.float.default_12') })
  }
}