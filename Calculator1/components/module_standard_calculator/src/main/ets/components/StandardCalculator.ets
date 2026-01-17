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
import { StandardCalcKeyboard } from './StandardCalcKeyboard';
import { ScienceCalcKeyboard } from './ScienceCalcKeyboard';
import { CalcConstants, CalculatorType } from '../common/Constant';
import { CalculatorVM } from '../viewmodel/CalculatorVM';
import { BreakpointModel, BreakpointStorage, BreakpointSystem, BreakpointTypeEnum } from '../utils/BreakpointSystem';
import { HistoryUtils, HistoryItem } from '../utils/HistoryUtils';

// 华为广告横幅高度常量 (单位: vp)
// 标准横幅: 32vp(紧凑) / 50vp(标准) / 90vp(大型)
const AD_BANNER_HEIGHT: number = 50;
// 导航条安全距离
const NAV_SAFE_MARGIN: number = 8;
// 历史记录最大显示条数
const MAX_HISTORY_DISPLAY: number = 5;

@Entry
@ComponentV2
export struct StandardCalculator {
  @Local text: string = '标准计算器';
  @Local result: string = '0'
  @Local expression: string = '0'
  @Local calculatorType: CalculatorType = CalculatorType.StandardCalc;
  @Local showResultDialog: boolean = false;
  @Param routerModule: NavPathStack = new NavPathStack()
  scrollerResult: Scroller = new Scroller();
  scrollerExpression: Scroller = new Scroller();
  historyScroller: Scroller = new Scroller();
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Local historyList: HistoryItem[] = HistoryUtils.getHistoryResult();
  // 菜单展开状态: 'none' | 'tool' | 'setting'
  @Local expandedMenu: string = 'none';
  // 菜单当前层级: 'main' | 'tool' | 'setting'
  @Local menuLevel: string = 'main';
  // 菜单按钮动画状态
  @Local menuBtnScale: number = 1;
  @Local menuBtnRotate: number = 0;
  // 菜单面板显示状态 - 使用 bindSheet
  @Local showMenuSheet: boolean = false;
  // 卡片入场动画状态
  @Local cardAnimateIn: boolean = false;

  aboutToAppear(): void {
    CalculatorVM.setStack(this.routerModule);
    BreakpointSystem.register(this.getUIContext())
  }

  aboutToDisappear(): void {
    BreakpointSystem.unregister()
  }

  build() {
    Column() {
      this.HeaderInfo();
      // 历史记录显示区域 - 利用原Tab栏空间
      this.HistoryDisplayBuilder();
      this.ResultBuilder();
      // 键盘区域 - 使用layoutWeight自适应填满剩余空间
      Column() {
        if (this.calculatorType === CalculatorType.StandardCalc) {
          StandardCalcKeyboard({
            changeResult: (result, expression) => {
              this.result = result || ' ';
              this.expression = expression;
              // 刷新历史记录列表
              this.historyList = HistoryUtils.getHistoryResult();
              // 滚动到最新记录
              this.historyScroller.scrollEdge(Edge.Bottom);
            }
          })
        } else {
          ScienceCalcKeyboard({
            result: this.result,
            expression: this.expression,
            changeResult: (result, expression) => {
              this.result = result || ' ';
              this.expression = expression;
              // 刷新历史记录列表
              this.historyList = HistoryUtils.getHistoryResult();
              // 滚动到最新记录
              this.historyScroller.scrollEdge(Edge.Bottom);
            },
          });
        }
      }
      .layoutWeight(1)
      .width(CalcConstants.FULL_PERCENT)

      // 华为广告横幅占位区域 (保持与导航条安全距离)
      this.AdBannerPlaceholder();
    }
    .height(CalcConstants.FULL_PERCENT)
    .padding({ left: 8, right: 8 })
  }

  // 广告横幅占位组件 (保持与底部导航条安全距离)
  @Builder
  AdBannerPlaceholder() {
    Row() {
      Text('广告位')
        .fontSize(14)
        .fontColor($r('sys.color.font_tertiary'))
    }
    .width(CalcConstants.FULL_PERCENT)
    .height(AD_BANNER_HEIGHT)
    .backgroundColor($r('sys.color.background_secondary'))
    .borderRadius(8)
    .justifyContent(FlexAlign.Center)
    .margin({ top: 8, bottom: NAV_SAFE_MARGIN })
  }

  // 历史记录实时显示区域
  @Builder
  HistoryDisplayBuilder() {
    Column() {
      if (this.historyList.length > 0) {
        Scroll(this.historyScroller) {
          Column({ space: 4 }) {
            ForEach(this.historyList.slice(-MAX_HISTORY_DISPLAY), (item: HistoryItem) => {
              Row() {
                Text(item.value)
                  .fontSize(14)
                  .fontColor($r('sys.color.font_secondary'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width(CalcConstants.FULL_PERCENT)
              .justifyContent(FlexAlign.End)
              .padding({ left: 16, right: 16 })
            }, (item: HistoryItem) => item.id.toString())
          }
          .width(CalcConstants.FULL_PERCENT)
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
        .width(CalcConstants.FULL_PERCENT)
        .height(CalcConstants.FULL_PERCENT)
      } else {
        // 空状态提示
        Row() {
          Text('暂无历史记录')
            .fontSize(12)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .width(CalcConstants.FULL_PERCENT)
        .height(CalcConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width(CalcConstants.FULL_PERCENT)
    .height(80)
    .backgroundColor($r('sys.color.background_tertiary'))
    .borderRadius(12)
    .padding({ top: 8, bottom: 8 })
    .margin({ bottom: 8 })
  }

  // ==================== 卡片式菜单面板 Builder ====================
  // 半模态卡片面板内容 - 三种卡片布局
  @Builder
  MenuSheetBuilder() {
    Column() {
      // 顶部拖拽指示条
      Row() {
        Column()
          .width(40)
          .height(4)
          .backgroundColor($r('sys.color.font_quaternary'))
          .borderRadius(2)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 8, bottom: 16 })

      // 卡片网格布局
      Column({ space: 12 }) {
        // 第一行: 历史记录大卡片 (9:16 比例，占主要面积)
        this.HistoryCardBuilder()

        // 第二行: 工具箱卡片 + 设置卡片
        Row({ space: 12 }) {
          // 工具箱矩形卡片
          this.ToolboxCardBuilder()
          // 设置长条卡片
          this.SettingCardBuilder()
        }
        .width('100%')
      }
      .padding({ left: 16, right: 16, bottom: 24 })
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
  }

  // 历史记录大卡片 - 9:16 比例，可滚动显示历史
  @Builder
  HistoryCardBuilder() {
    Column() {
      // 卡片标题栏
      Row() {
        Image($r('app.media.ic_history'))
          .width(20)
          .height(20)
          .fillColor($r('sys.color.font_on_primary'))
          .margin({ right: 8 })
        Text('历史记录')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
        Blank()
        Text('查看全部 ›')
          .fontSize(12)
          .fontColor($r('sys.color.font_on_primary'))
          .opacity(0.8)
          .onClick(() => {
            this.showMenuSheet = false;
            this.routerModule.pushPathByName('HistoryResult', null);
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      // 历史记录列表
      if (this.historyList.length > 0) {
        Scroll() {
          Column({ space: 8 }) {
            ForEach(this.historyList.slice(-8).reverse(), (item: HistoryItem) => {
              Row() {
                Text(item.value)
                  .fontSize(14)
                  .fontColor($r('sys.color.font_on_primary'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .opacity(0.9)
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .backgroundColor('rgba(255,255,255,0.1)')
              .borderRadius(8)
            }, (item: HistoryItem) => item.id.toString())
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 12 })
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1)
      } else {
        // 空状态
        Column() {
          Text('📝')
            .fontSize(32)
            .margin({ bottom: 8 })
          Text('暂无计算历史')
            .fontSize(14)
            .fontColor($r('sys.color.font_on_primary'))
            .opacity(0.6)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height(280) // 约 9:16 比例的高度
    .backgroundColor($r('sys.color.comp_background_emphasize'))
    .borderRadius(20)
    .clip(true)
    .scale({ x: this.cardAnimateIn ? 1 : 0.9, y: this.cardAnimateIn ? 1 : 0.9 })
    .opacity(this.cardAnimateIn ? 1 : 0)
    .translate({ y: this.cardAnimateIn ? 0 : 20 })
    .animation({
      duration: 350,
      curve: Curve.EaseOut,
      delay: 0
    })
  }

  // 工具箱矩形卡片 - 点击进入工具页
  @Builder
  ToolboxCardBuilder() {
    Column() {
      // 图标区域
      Column() {
        Image($r('app.media.ic_toolbox'))
          .width(32)
          .height(32)
          .fillColor($r('sys.color.font_primary'))
      }
      .width(56)
      .height(56)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(16)
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 12 })

      Text('工具箱')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .margin({ bottom: 4 })

      Text('日期 · BMI · 汇率')
        .fontSize(12)
        .fontColor($r('sys.color.font_secondary'))

      // 工具图标预览
      Row({ space: 8 }) {
        Text('📅').fontSize(16)
        Text('⚖️').fontSize(16)
        Text('💱').fontSize(16)
        Text('🗓️').fontSize(16)
      }
      .margin({ top: 12 })
    }
    .layoutWeight(1)
    .height(160)
    .padding(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(20)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .scale({ x: this.cardAnimateIn ? 1 : 0.9, y: this.cardAnimateIn ? 1 : 0.9 })
    .opacity(this.cardAnimateIn ? 1 : 0)
    .translate({ y: this.cardAnimateIn ? 0 : 20 })
    .animation({
      duration: 350,
      curve: Curve.EaseOut,
      delay: 80
    })
    .onClick(() => {
      this.showMenuSheet = false;
      this.routerModule.pushPathByName('ToolPage', null);
    })
  }

  // 设置长条卡片
  @Builder
  SettingCardBuilder() {
    Column() {
      // 图标区域
      Column() {
        Image($r('app.media.ic_settings'))
          .width(32)
          .height(32)
          .fillColor($r('sys.color.font_primary'))
      }
      .width(56)
      .height(56)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(16)
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 12 })

      Text('设置')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .margin({ bottom: 4 })

      Text('振动 · 音效 · 语音')
        .fontSize(12)
        .fontColor($r('sys.color.font_secondary'))

      // 设置图标预览
      Row({ space: 8 }) {
        Text('📳').fontSize(16)
        Text('🔊').fontSize(16)
        Text('🗣️').fontSize(16)
      }
      .margin({ top: 12 })
    }
    .layoutWeight(1)
    .height(160)
    .padding(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(20)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .scale({ x: this.cardAnimateIn ? 1 : 0.9, y: this.cardAnimateIn ? 1 : 0.9 })
    .opacity(this.cardAnimateIn ? 1 : 0)
    .translate({ y: this.cardAnimateIn ? 0 : 20 })
    .animation({
      duration: 350,
      curve: Curve.EaseOut,
      delay: 160
    })
    .onClick(() => {
      this.showMenuSheet = false;
      this.routerModule.pushPathByName('SettingPage', null);
    })
  }

  // 处理菜单点击 - 扩展支持更多路由
  handleMenuClick(menuId: string) {
    this.showMenuSheet = false;
    switch (menuId) {
      case 'history':
        this.routerModule.pushPathByName('HistoryResult', null);
        break;
      case 'tool':
        this.routerModule.pushPathByName('ToolPage', null);
        break;
      case 'setting':
        this.routerModule.pushPathByName('SettingPage', null);
        break;
      case 'date_interval':
        this.routerModule.pushPathByName('DateIntervalPage', null);
        break;
      case 'date_calc':
        this.routerModule.pushPathByName('DateCalculationPage', null);
        break;
      case 'bmi':
        this.routerModule.pushPathByName('BmiHome', null);
        break;
      case 'exchange':
        this.routerModule.pushPathByName('ExchangeRateCalculatorPage', null);
        break;
      case 'about':
        this.routerModule.pushPathByName('SettingPage', null);
        break;
    }
  }

  @Builder
  ResultBuilder() {
    Row() {
      Column() {
        Scroll(this.scrollerExpression) {
          Text(this.expression)
            .textStyle()
            .fontSize(new BreakpointModel<number>({
              [BreakpointTypeEnum.TABLET_LANDSCAPE]: 19,
              [BreakpointTypeEnum.LG_WIDE]: 19,
              [BreakpointTypeEnum.LG_NORMAL]: 38,
            }).getValue(this.curBreakpoint.height)).onSizeChange(() => {
            this.scrollerExpression.scrollEdge(Edge.End)
          })
        }
        .margin({
          bottom: new BreakpointModel<number>({
            [BreakpointTypeEnum.TABLET_LANDSCAPE]: 5,
            [BreakpointTypeEnum.LG_WIDE]: 5,
            [BreakpointTypeEnum.LG_NORMAL]: 10,
          }).getValue(this.curBreakpoint.height)
        })
        .width(CalcConstants.FULL_PERCENT)
        .scrollBar(BarState.Off)
        .align(Alignment.End)
        .scrollable(ScrollDirection.Horizontal)

        Scroll(this.scrollerResult) {
          Text(this.result)
            .textStyle()
            .fontSize(new BreakpointModel<number>({
              [BreakpointTypeEnum.TABLET_LANDSCAPE]: 15,
              [BreakpointTypeEnum.LG_WIDE]: 15,
              [BreakpointTypeEnum.LG_NORMAL]: 30,
            }).getValue(this.curBreakpoint.height)).onSizeChange(() => {
            this.scrollerResult.scrollEdge(Edge.End)
          })
        }
        .width(CalcConstants.FULL_PERCENT)
        .alignSelf(ItemAlign.End)
        .scrollBar(BarState.Off)
        .align(Alignment.End)
        .scrollable(ScrollDirection.Horizontal)
      }
      .width(CalcConstants.FULL_PERCENT)
      .height(CalcConstants.FULL_PERCENT)
      .alignItems(HorizontalAlign.End)
      .justifyContent(FlexAlign.End)
    }
    .height(new BreakpointModel<number>({
      [BreakpointTypeEnum.TABLET_LANDSCAPE]: 61,
      [BreakpointTypeEnum.LG_WIDE]: 61,
      [BreakpointTypeEnum.LG_NORMAL]: 121,
    }).getValue(this.curBreakpoint.height))
    .backgroundColor($r('sys.color.background_tertiary'))
    .padding({
      top: 12,
      bottom: 12,
      left: 16,
      right: 16
    })
    .borderRadius(16)
    .width(CalcConstants.FULL_PERCENT)
    .margin({ bottom: 12 })
  }

  @Builder
  HeaderInfo() {
    Row() {
      Row() {
        Column() {
          Text('标准计算器').calculatorTitleStyle()
            .fontColor(CalculatorType.StandardCalc === this.calculatorType ? $r('sys.color.font_on_primary') :
            $r('sys.color.font_tertiary'))
        }.margin({ right: 8 }).calculatorColumnStyle()
        .backgroundColor(CalculatorType.StandardCalc === this.calculatorType ?
        $r('sys.color.comp_background_emphasize') : $r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.calculatorType = CalculatorType.StandardCalc;
          this.expression = '0';
          this.result = '0';
        })

        Column() {
          Text('科学计算器').calculatorTitleStyle()
            .fontColor(CalculatorType.ScienceCalc === this.calculatorType ? $r('sys.color.font_on_primary') :
            $r('sys.color.font_tertiary'))
        }.calculatorColumnStyle()
        .backgroundColor(CalculatorType.ScienceCalc === this.calculatorType ?
        $r('sys.color.comp_background_emphasize') : $r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.calculatorType = CalculatorType.ScienceCalc;
          this.expression = '0';
          this.result = '0';
        })

      }

      // 菜单按钮 (三条杠图标) - 绑定半模态卡片面板
      Row() {
        Image($r('app.media.ic_menu'))
          .width(24)
          .height(24)
          .fillColor($r('sys.color.font_primary'))
      }
      .width(40)
      .height(40)
      .backgroundColor($r('sys.color.background_tertiary'))
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)
      .scale({ x: this.menuBtnScale, y: this.menuBtnScale })
      .rotate({ z: 1, angle: this.menuBtnRotate })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          // 按下时：弹性缩放 + 轻微旋转
          animateTo({
            duration: 150,
            curve: Curve.EaseOut
          }, () => {
            this.menuBtnScale = 0.85;
            this.menuBtnRotate = -8;
          });
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          // 松开时：弹性回弹
          animateTo({
            duration: 300,
            curve: Curve.Friction
          }, () => {
            this.menuBtnScale = 1;
            this.menuBtnRotate = 0;
          });
        }
      })
      .onClick(() => {
        // 重置动画状态，打开卡片面板
        this.cardAnimateIn = false;
        this.showMenuSheet = true;
      })
      .bindSheet($$this.showMenuSheet, this.MenuSheetBuilder(), {
        height: SheetSize.FIT_CONTENT,
        dragBar: false,
        showClose: false,
        backgroundColor: $r('sys.color.background_primary'),
        blurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
        onAppear: () => {
          // 面板出现后触发卡片入场动画
          setTimeout(() => {
            this.cardAnimateIn = true;
          }, 50);
        },
        onDisappear: () => {
          this.cardAnimateIn = false;
        }
      })
    }.justifyContent(FlexAlign.SpaceBetween).width('100%')
    .height(60).padding({ top: 10, bottom: 10 })
  }
}

@Extend(Text)
function textStyle() {
  .fontColor($r('sys.color.font_primary'))
  .maxLines(1)
}


@Extend(Text)
function calculatorTitleStyle() {
  .fontSize($r('sys.float.Body_M'))
  .maxLines(1)
}

@Extend(Column)
function calculatorColumnStyle() {
  .padding({
    top: 10,
    bottom: 10,
    left: 16,
    right: 16
  })
  .borderRadius(21)
}