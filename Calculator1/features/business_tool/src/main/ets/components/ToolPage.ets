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

import { BaseTitleBuilder, RouterModule, CommonConstants } from 'lib_foundation';

/**
 * 工具项数据模型
 */
interface ToolItem {
  id: string;
  name: string;
  icon: Resource; // 图标资源
  iconBgColor: string;
  description: string;
  routeName: string;
  enabled: boolean;
}

/**
 * 默认主题色 - 系统蓝
 */
const THEME_COLOR: string = '#007DFF';

@ComponentV2
export struct ToolPage {
  // 工具列表数据 - 只显示已启用的工具
  @Local toolList: ToolItem[] = [
    {
      id: 'date_interval',
      name: '日期间隔',
      icon: $r('app.media.ic_date_interval'),
      iconBgColor: '#FF6B35',
      description: '计算两日期间天数',
      routeName: 'DateIntervalPage',
      enabled: true
    },
    {
      id: 'date_calculation',
      name: '日期计算',
      icon: $r('app.media.ic_date_calc'),
      iconBgColor: '#4ECDC4',
      description: '计算日期前后时间',
      routeName: 'DateCalculationPage',
      enabled: true
    },
    {
      id: 'bmi_calculator',
      name: 'BMI计算',
      icon: $r('app.media.ic_bmi'),
      iconBgColor: '#45B7D1',
      description: '身体质量指数计算',
      routeName: 'BmiHome',
      enabled: true
    },
    {
      id: 'exchange_rate',
      name: '汇率计算',
      icon: $r('app.media.ic_exchange'),
      iconBgColor: '#96CEB4',
      description: '多币种汇率换算',
      routeName: 'ExchangeRateCalculatorPage',
      enabled: true
    }
    // 预留接口（待组件开发完成后启用）
    // {
    //   id: 'reserved_1',
    //   name: '金额大写',
    //   icon: $r('app.media.ic_reserved'),
    //   iconBgColor: '#DDA0DD',
    //   description: '数字转中文大写',
    //   routeName: '',
    //   enabled: false
    // },
    // {
    //   id: 'reserved_2',
    //   name: '单位换算',
    //   icon: $r('app.media.ic_reserved'),
    //   iconBgColor: '#F0E68C',
    //   description: '长度/重量/面积换算',
    //   routeName: '',
    //   enabled: false
    // },
    // {
    //   id: 'reserved_3',
    //   name: '房贷计算',
    //   icon: $r('app.media.ic_reserved'),
    //   iconBgColor: '#98D8C8',
    //   description: '等额本息/本金计算',
    //   routeName: '',
    //   enabled: false
    // }
  ];

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          // 工具网格布局
          GridRow({
            columns: 2,
            gutter: { x: 12, y: 12 }
          }) {
            ForEach(this.toolList, (item: ToolItem) => {
              GridCol() {
                this.ToolCardBuilder(item)
              }
            })
          }
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        }
        .width(CommonConstants.FULL_PERCENT)
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .height(CommonConstants.FULL_PERCENT)
    }
    .title(BaseTitleBuilder('工具'))
    .backgroundColor($r('sys.color.background_secondary'))
  }

  /**
   * 工具卡片构建器
   */
  @Builder
  ToolCardBuilder(item: ToolItem) {
    Column() {
      // 图标区域 - 使用SVG图标
      Row() {
        Image(item.icon)
          .width(28)
          .height(28)
          .fillColor(Color.White)
      }
      .width(56)
      .height(56)
      .borderRadius(28)
      .backgroundColor(item.iconBgColor)
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 12 })

      // 工具名称
      Text(item.name)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .margin({ bottom: 4 })

      // 工具描述
      Text(item.description)
        .fontSize(12)
        .fontColor($r('sys.color.font_secondary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding(16)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      if (item.routeName) {
        RouterModule.push({ url: item.routeName });
      }
    })
  }
}
