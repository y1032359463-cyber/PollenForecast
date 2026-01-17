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

import { RouterModule, BaseTitleBuilder, CommonConstants } from 'lib_foundation';
import {
  SettingView,
  SettingGroup,
  SettingItem,
  SettingType,
  SupportedSetting,
  AboutModel,
  WebModel
} from 'app_setting';

/**
 * 默认主题色 - 系统蓝
 */
const THEME_COLOR: string = '#007DFF';

@ComponentV2
export struct SettingPage {
  @Local navPathStack: NavPathStack = RouterModule.getStack();

  // ========== 设置项配置 ==========

  // 振动反馈开关
  @Local vibrationItem: SettingItem = new SettingItem()
    .setItemId('vibration')
    .setType(SettingType.SWITCH)
    .setLabel('振动反馈')
    .setSubLabel('按键时提供触感反馈')
    .setSwitchValue(true)
    .setClickEvent((isOn) => {
      this.vibrationItem.setSwitchValue(isOn as boolean);
      // TODO: 保存振动设置到本地存储
      AppStorage.setOrCreate('vibration_enabled', isOn);
    });

  // 按键音效开关
  @Local soundItem: SettingItem = new SettingItem()
    .setItemId('sound')
    .setType(SettingType.SWITCH)
    .setLabel('按键音效')
    .setSubLabel('按键时播放提示音')
    .setSwitchValue(true)
    .setClickEvent((isOn) => {
      if (isOn) {
        // 开启按键音时,关闭语音播报
        this.ttsItem.setSwitchValue(false);
        AppStorage.setOrCreate('tts_enabled', false);
      }
      this.soundItem.setSwitchValue(isOn as boolean);
      AppStorage.setOrCreate('sound_enabled', isOn);
    });

  // 语音播报开关
  @Local ttsItem: SettingItem = new SettingItem()
    .setItemId('tts')
    .setType(SettingType.SWITCH)
    .setLabel('语音播报')
    .setSubLabel('计算结果语音朗读')
    .setSwitchValue(false)
    .setClickEvent((isOn) => {
      if (isOn) {
        // 开启语音播报时,关闭按键音
        this.soundItem.setSwitchValue(false);
        AppStorage.setOrCreate('sound_enabled', false);
      }
      this.ttsItem.setSwitchValue(isOn as boolean);
      AppStorage.setOrCreate('tts_enabled', isOn);
    });

  // 交互设置组
  @Local interactionGroup: SettingGroup = new SettingGroup()
    .setGroupId('interaction')
    .setTitle('交互设置')
    .setList([
      this.vibrationItem,
      this.soundItem,
      this.ttsItem
    ]);

  // 显示设置组
  @Local displayGroup: SettingGroup = new SettingGroup()
    .setGroupId('display')
    .setTitle('显示设置')
    .setList([
      new SettingItem()
        .setSupportedType(SupportedSetting.LIGHT_DARK_MODE)
        .setSelectIndex(0)
        .setOnChange((colorMode) => {
          // 深浅色模式切换
          console.info(`深浅色模式切换: ${colorMode}`);
        })
    ]);

  // 关于我们组
  @Local aboutGroup: SettingGroup = new SettingGroup()
    .setGroupId('about')
    .setTitle('关于')
    .setList([
      new SettingItem()
        .setSupportedType(SupportedSetting.ABOUT)
        .setExtraParams({
          icpText: '备案号待申请',
          copyrightText: '智算Pro © 2025',
          hotline: '400-000-0000'
        } as AboutModel),
      new SettingItem()
        .setType(SettingType.ROUTER)
        .setLabel('隐私政策')
        .setRouterParam({ routerName: 'AgreementPrivacy' }),
      new SettingItem()
        .setType(SettingType.ROUTER)
        .setLabel('用户协议')
        .setRouterParam({ routerName: 'AgreementPrivacy' })
    ]);

  aboutToAppear(): void {
    // 从本地存储加载设置
    const vibrationEnabled = AppStorage.get<boolean>('vibration_enabled') ?? true;
    const soundEnabled = AppStorage.get<boolean>('sound_enabled') ?? true;
    const ttsEnabled = AppStorage.get<boolean>('tts_enabled') ?? false;

    this.vibrationItem.setSwitchValue(vibrationEnabled);
    this.soundItem.setSwitchValue(soundEnabled);
    this.ttsItem.setSwitchValue(ttsEnabled);
  }

  build() {
    NavDestination() {
      Column() {
        SettingView({
          pathStack: this.navPathStack,
          settingList: [
            this.interactionGroup,
            this.displayGroup,
            this.aboutGroup
          ],
          themeColor: THEME_COLOR
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .title(BaseTitleBuilder('设置'))
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
