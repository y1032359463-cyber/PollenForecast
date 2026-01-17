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

export { RouterModule, NavRouterInfo } from './src/main/ets/router/RouterModule';

export * from './src/main/ets/common/Constant';

export { Logger } from './src/main/ets/utils/Logger';

export { BaseTitleBuilder } from './src/main/ets/components/BaseTitleBuilder';

export { BaseNavTitle } from './src/main/ets/components/BaseNavTitle';

// 反馈服务 - 振动/音效/语音播报
export {
  vibrateFeedback,
  playKeySound,
  speakText,
  stopSpeak,
  initTTS,
  releaseTTS,
  initSoundPlayer,
  releaseSoundPlayer,
  releaseAllFeedback,
  numberToSpeakText
} from './src/main/ets/services/FeedbackService';