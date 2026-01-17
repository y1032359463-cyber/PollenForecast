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

import { DateCalculation } from 'module_date_calculation/src/main/ets/components/dateCalculation/DateCalculation';
import { LuckyDays } from 'module_date_calculation';

/**
 * 默认主题色 - 系统蓝
 */
const THEME_COLOR: string = '#007DFF';

@Builder
export function DateCalculationPageBuilder() {
  DateCalculationPage();
}

@ComponentV2
export struct DateCalculationPage {
  build() {
    NavDestination() {
      Column() {
        DateCalculation({
          startDate: new Date(),
          buttonColor: THEME_COLOR,
          textColor: '#ffffff',
          onSearch: (calculateInfo: LuckyDays) => {
            console.info(`日期计算结果: ${JSON.stringify(calculateInfo)}`);
          }
        })
      }
      .height('100%')
      .padding({ left: 8, right: 8 })
    }
    .title('日期计算')
    .backgroundColor($r('sys.color.background_primary'))
  }
}
