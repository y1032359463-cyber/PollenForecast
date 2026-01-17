import { LubanCalculator, MeasureResult } from '../model/LubanCalculator'
import { display, window } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'

/**
 * 鲁班尺主界面
 */
@Entry
@Component
struct Index {
  // ============ 状态变量 ============
  @State currentMm: number = 0
  @State inputText: string = '0'
  @State measureResult: MeasureResult = LubanCalculator.measure(0)

  // ============ 设置相关 ============
  @State showSettings: boolean = false
  @State backgroundType: number = 0  // 0=木纹, 1=纸张

  // ============ 屏幕物理参数 ============
  @State vpPerMm: number = 2.5
  @State densityPixels: number = 2.75
  @State safeAreaLeft: number = 48  // 默认值，避免预览器中为0

  // ✅ 窗口尺寸状态
  @StorageLink('windowWidth') @Watch('onWindowSizeChange') windowWidth: number = 0
  @StorageLink('windowHeight') windowHeight: number = 0
  @StorageLink('cutoutAreaLeft') @Watch('onCutoutAreaChange') cutoutAreaLeftPx: number = 0

  // 安全区域常量
  private readonly DEFAULT_SAFE_AREA_VP: number = 48
  private readonly MIN_SAFE_AREA_VP: number = 24
  private readonly calibrationFactor: number = 0.99

  // ============ 尺子滚动控制 ============
  private scroller: Scroller = new Scroller()

  // ============ 布局常量 ============
  private readonly leftPanelWidth: number = 100
  private readonly topBarHeight: number = 48
  private readonly rowHeightGongchi: number = 56
  private readonly rowHeightLuban: number = 80
  private readonly rowHeightDinglan: number = 80
  private readonly rowHeightYingchi: number = 56
  private readonly rulerLengthCm: number = 300
  // 四行总高度 = 56+80+80+56 = 272vp，图片为正方形
  private readonly rulerTotalHeight: number = 272
  private readonly startImageWidth: number = 272  // app_icon图片宽度 = 总高度

  // 指示线偏移（等于左侧面板总宽度）- 使用 @State 确保响应式
  @State indicatorOffset: number = 150

  // ============ 颜色常量 ============
  private readonly colorTopBar: string = '#C62828'
  private readonly colorGongchi: string = '#F5EBD8'
  private readonly colorGongchiText: string = '#5D4E37'
  private readonly colorLubanGood: string = '#8B0000'
  private readonly colorLubanBad: string = '#4A4A4A'
  private readonly colorLubanMinorGood: string = '#C62828'
  private readonly colorLubanMinorBad: string = '#5A5A5A'
  private readonly colorDinglanGood: string = '#C62828'
  private readonly colorDinglanBad: string = '#455A64'
  private readonly colorDinglanMinorGood: string = '#C62828'
  private readonly colorDinglanMinorBad: string = '#546E7A'
  private readonly colorYingchi: string = '#F5A623'
  private readonly colorYingchiText: string = '#5D4037'
  private readonly colorIndicator: string = '#FFD700'
  private readonly colorIndicatorArrow: string = '#E53935'

  // ============ 生命周期 ============
  aboutToAppear(): void {
    this.initScreenParams()
    this.initSafeArea()
    this.updateIndicatorOffset()
    this.updateMeasure()
  }

  // 更新指示线偏移 (左侧面板 + 大吉图片)
  updateIndicatorOffset(): void {
    this.indicatorOffset = this.leftPanelWidth + this.safeAreaLeft + this.startImageWidth
  }

  initScreenParams(): void {
    try {
      const displayInfo = display.getDefaultDisplaySync()
      this.densityPixels = displayInfo.densityPixels || 2.75
      let physicalDpi = displayInfo.xDPI
      if (!physicalDpi || physicalDpi <= 0) {
        physicalDpi = displayInfo.yDPI
      }
      if (!physicalDpi || physicalDpi <= 0) {
        physicalDpi = displayInfo.densityDPI
      }
      const pxPerMm = physicalDpi / 25.4
      this.vpPerMm = (pxPerMm / this.densityPixels) * this.calibrationFactor
      hilog.info(0x0000, 'LubanRuler', `vpPerMm: ${this.vpPerMm.toFixed(4)}`)
    } catch (e) {
      this.vpPerMm = 2.5
    }
  }

  initSafeArea(): void {
    try {
      const mainWindow = AppStorage.get<window.Window>('mainWindow')
      if (mainWindow) {
        const avoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_CUTOUT)
        const cutoutLeftPx = avoidArea.leftRect.width
        if (cutoutLeftPx > 0) {
          this.safeAreaLeft = (cutoutLeftPx / this.densityPixels) + this.MIN_SAFE_AREA_VP
        } else {
          this.safeAreaLeft = this.DEFAULT_SAFE_AREA_VP
        }
      } else {
        this.safeAreaLeft = this.DEFAULT_SAFE_AREA_VP
      }
    } catch (e) {
      this.safeAreaLeft = this.DEFAULT_SAFE_AREA_VP
    }
  }

  reCalculateSafeArea(): void {
    if (this.cutoutAreaLeftPx > 0) {
      this.safeAreaLeft = (this.cutoutAreaLeftPx / this.densityPixels) + this.MIN_SAFE_AREA_VP
    } else {
      this.safeAreaLeft = this.DEFAULT_SAFE_AREA_VP
    }
    this.updateIndicatorOffset()
  }

  onWindowSizeChange(): void {
    this.initScreenParams()
    this.reCalculateSafeArea()
  }

  onCutoutAreaChange(): void {
    this.reCalculateSafeArea()
  }

  // 精确宽度计算
  getAbsolutePosition(mm: number): number {
    const MICRON = 1000
    const microns = Math.round(mm * MICRON)
    const vpPerMicron = this.vpPerMm / MICRON
    return microns * vpPerMicron
  }

  getSegmentWidth(startMm: number, endMm: number): number {
    return this.getAbsolutePosition(endMm) - this.getAbsolutePosition(startMm)
  }

  updateMeasure(): void {
    this.measureResult = LubanCalculator.measure(this.currentMm)
  }

  onScrollEvent(): void {
    const offset = this.scroller.currentOffset()
    // 指示线固定在 startImageWidth+1 位置
    // 当 xOffset=0 时，指示线对准图片内部（大吉图片区域）
    // 当 xOffset=startImageWidth+1 时，指示线对准刻度0的位置
    // 测量值 = (xOffset - startImageWidth - 1) / vpPerMm
    const zeroPointOffset = this.startImageWidth + 1  // 刻度0对应的滚动偏移
    const effectiveOffset = offset.xOffset - zeroPointOffset
    // 只有滚动超过图片区域才开始计数
    if (effectiveOffset >= 0) {
      this.currentMm = effectiveOffset / this.vpPerMm
    } else {
      this.currentMm = 0  // 在图片区域内显示0
    }
    this.inputText = this.currentMm.toFixed(1)
    this.updateMeasure()
  }

  generateArray(count: number): number[] {
    const result: number[] = []
    for (let i = 0; i < count; i++) {
      result.push(i)
    }
    return result
  }

  // ============ UI 构建 ============
  build() {
    Stack() {
      // 底层：全屏背景（右侧用背景图，左侧用对应颜色）
      Row() {
        // 左侧安全区域色块 - 用 Stack 叠加确保位置正确
        Stack() {
          // 先铺一层英尺颜色作为底色
          Column().width('100%').height('100%').backgroundColor(this.colorYingchi)
          // 再叠加上面的色块
          Column() {
            Row().width('100%').height(this.topBarHeight).backgroundColor(this.colorTopBar)
            Row().width('100%').height(this.rowHeightGongchi).backgroundColor(this.colorGongchi)
            Row().width('100%').height(this.rowHeightLuban)
              .backgroundColor(this.measureResult.lubanResult.isGood ? this.colorLubanGood : this.colorLubanBad)
            Row().width('100%').height(this.rowHeightDinglan)
              .backgroundColor(this.measureResult.dinglanResult.isGood ? this.colorDinglanGood : this.colorDinglanBad)
            Row().width('100%').height(this.rowHeightYingchi).backgroundColor(this.colorYingchi)
          }
        }
        .width(this.safeAreaLeft)
        .height('100%')

        // 右侧背景图区域
        Column() {
          // 顶部栏占位（红色背景）
          Row().width('100%').height(this.topBarHeight).backgroundColor(this.colorTopBar)
          // 尺子区域背景图
          Image(this.backgroundType === 0 ? $r('app.media.texture_wood') : $r('app.media.texture_paper'))
            .width('100%')
            .layoutWeight(1)
            .objectFit(ImageFit.Cover)
        }
        .width('100%')
        .height('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')

      // 主内容层
      Column() {
        // 顶部栏
        this.TopBar()
        // 尺子区域
        Row() {
          // 左侧信息面板
          this.LeftPanel()
          // 右侧滚动尺子区域
          Stack() {
            // 尺子滚动层
            Scroll(this.scroller) {
              // 尺子整体加1vp黑色边框
              Row() {
                // 前缀图片 - app_icon 正方形
                Image($r('app.media.app_icon'))
                  .width(this.startImageWidth)
                  .height(this.rulerTotalHeight)
                  .objectFit(ImageFit.Cover)

                // 四行尺子组合
                Column() {
                  this.GongchiRuler()
                  this.LubanRulerRow()
                  this.DinglanRulerRow()
                  this.YingchiRuler()
                }
              }
              .border({ width: 1, color: '#000000' })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.None)
            .onDidScroll(() => {
              this.onScrollEvent()
            })

            // 固定指示线 - 紧贴图片右边缘
            Column() {
              Stack()
                .width(0)
                .height(0)
                .border({
                  width: { left: 6, right: 6, top: 0, bottom: 10 },
                  color: { left: Color.Transparent, right: Color.Transparent, top: Color.Transparent, bottom: this.colorIndicatorArrow }
                })
                .margin({ left: -6 })
              Column()
                .width(1.5)
                .layoutWeight(1)
                .backgroundColor(this.colorIndicator)
                .margin({ left: -0.75 })
            }
            .height('100%')
            .alignItems(HorizontalAlign.Start)
            .position({ x: this.startImageWidth + 1, y: 0 })
          }
          .width('100%')
          .layoutWeight(1)
          .alignContent(Alignment.Start)
        }
        .width('100%')
        .layoutWeight(1)

        // 设置面板
        if (this.showSettings) {
          this.SettingsPanel()
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  // ============ 设置面板 ============
  @Builder
  SettingsPanel() {
    Column() {
      // 标题
      Row() {
        Text('背景设置').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
        Blank()
        Text('×').fontSize(20).fontColor('#666666')
          .onClick(() => { this.showSettings = false })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .borderWidth({ bottom: 1 })
      .borderColor('#E0E0E0')

      // 背景选项
      Row() {
        // 木纹背景选项
        Column() {
          Stack() {
            Image($r('app.media.texture_wood'))
              .width(80).height(60).borderRadius(8)
              .objectFit(ImageFit.Cover)
            if (this.backgroundType === 0) {
              Column()
                .width(80).height(60).borderRadius(8)
                .border({ width: 3, color: '#E53935' })
            }
          }
          Text('木纹').fontSize(12).fontColor('#333333').margin({ top: 6 })
        }
        .onClick(() => { this.backgroundType = 0 })
        .margin({ right: 24 })

        // 纸张背景选项
        Column() {
          Stack() {
            Image($r('app.media.texture_paper'))
              .width(80).height(60).borderRadius(8)
              .objectFit(ImageFit.Cover)
            if (this.backgroundType === 1) {
              Column()
                .width(80).height(60).borderRadius(8)
                .border({ width: 3, color: '#E53935' })
            }
          }
          Text('纸张').fontSize(12).fontColor('#333333').margin({ top: 6 })
        }
        .onClick(() => { this.backgroundType = 1 })
      }
      .padding(16)
    }
    .width(220)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#00000040', offsetX: 0, offsetY: 2 })
    .position({ x: this.safeAreaLeft + 16, y: this.topBarHeight + 8 })
  }

  // ============ 顶部栏 ============
  @Builder
  TopBar() {
    Row() {
      Image($r('app.media.ic_menu'))
        .width(24)
        .height(24)
        .fillColor('#FFFFFF')
        .margin({ left: this.safeAreaLeft + 16 })
        .onClick(() => {
          this.showSettings = !this.showSettings
        })
      Blank()
      Row() {
        Button({ type: ButtonType.Circle }) {
          Text('−').fontSize(22).fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
        }
        .width(32).height(32).backgroundColor('#E53935')
        .onClick(() => { this.adjustValue(-1) })

        Row() {
          TextInput({ text: this.inputText })
            .type(InputType.NUMBER_DECIMAL)
            .width(60).height(32).fontSize(16).fontColor('#333333')
            .textAlign(TextAlign.Center).backgroundColor(Color.Transparent)
            .onChange((value: string) => { this.inputText = value })
            .onSubmit(() => { this.onInputConfirm() })
          Text('毫米').fontSize(11).fontColor('#FFFFFF').backgroundColor('#666666')
            .padding({ left: 6, right: 6, top: 3, bottom: 3 }).borderRadius(3).margin({ left: 4 })
        }
        .height(32).backgroundColor('#FFFFFF').borderRadius(6)
        .padding({ left: 8, right: 4 }).margin({ left: 10, right: 10 })

        Button({ type: ButtonType.Circle }) {
          Text('+').fontSize(22).fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
        }
        .width(32).height(32).backgroundColor('#E53935')
        .onClick(() => { this.adjustValue(1) })
      }
      Blank()
      Row() {
        Image($r('app.media.ic_compass')).width(24).height(24).fillColor('#FFFFFF')
        Image($r('app.media.ic_grid')).width(24).height(24).fillColor('#FFFFFF').margin({ left: 20 })
      }
      .margin({ right: this.safeAreaLeft + 16 })
    }
    .width('100%').height(this.topBarHeight).backgroundColor(this.colorTopBar)
  }

  adjustValue(delta: number): void {
    this.currentMm = Math.max(0, this.currentMm + delta)
    this.inputText = this.currentMm.toFixed(1)
    this.updateMeasure()
    this.scrollToCurrentPosition()
  }

  onInputConfirm(): void {
    const num = parseFloat(this.inputText)
    if (!isNaN(num) && num >= 0) {
      this.currentMm = num
      this.updateMeasure()
      this.scrollToCurrentPosition()
    }
  }

  scrollToCurrentPosition(): void {
    // 滚动到指定 mm 位置
    // 刻度0对应的滚动偏移是 startImageWidth+1
    const zeroPointOffset = this.startImageWidth + 1
    const targetOffset = this.currentMm * this.vpPerMm + zeroPointOffset
    this.scroller.scrollTo({ xOffset: targetOffset, yOffset: 0, animation: { duration: 300 } })
  }

  // ============ 左侧固定面板 ============
  @Builder
  LeftPanel() {
    Column() {
      // 公尺信息行
      Stack({ alignContent: Alignment.End }) {
        Column() {
          Text('公尺').fontSize(11).fontColor(this.colorGongchiText).margin({ bottom: 2 })
          Text(`${this.measureResult.gongchi.toFixed(2)}厘米`).fontSize(13).fontWeight(FontWeight.Bold).fontColor(this.colorGongchiText)
        }.width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        Column().width(10).height(10).borderRadius(5).backgroundColor('#FFFFFF').border({ width: 1.5, color: '#BDBDBD' }).margin({ right: 6 })
      }.width('100%').height(this.rowHeightGongchi).backgroundColor(this.colorGongchi)

      // 鲁班尺信息行
      Stack({ alignContent: Alignment.End }) {
        Column() {
          Text('(42.90) 鲁班尺').fontSize(9).fontColor('#FFFFFF').opacity(0.8).margin({ bottom: 2 })
          Text(`${this.measureResult.lubanResult.majorWord} - ${this.measureResult.lubanResult.minorWord}`)
            .fontSize(13).fontWeight(FontWeight.Bold).fontColor(this.measureResult.lubanResult.isGood ? '#FFE082' : '#FFFFFF')
        }.width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        Column().width(10).height(10).borderRadius(5)
          .backgroundColor(this.measureResult.lubanResult.isGood ? '#FFD54F' : '#FFFFFF')
          .border({ width: 1.5, color: this.measureResult.lubanResult.isGood ? '#FFC107' : '#BDBDBD' }).margin({ right: 6 })
      }.width('100%').height(this.rowHeightLuban).backgroundColor(this.measureResult.lubanResult.isGood ? this.colorLubanGood : this.colorLubanBad)

      // 丁兰尺信息行
      Stack({ alignContent: Alignment.End }) {
        Column() {
          Text('(38.78) 丁兰尺').fontSize(9).fontColor('#FFFFFF').opacity(0.8).margin({ bottom: 2 })
          Text(`${this.measureResult.dinglanResult.majorWord} - ${this.measureResult.dinglanResult.minorWord}`)
            .fontSize(13).fontWeight(FontWeight.Bold).fontColor(this.measureResult.dinglanResult.isGood ? '#FFE082' : '#FFFFFF')
        }.width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        Column().width(10).height(10).borderRadius(5)
          .backgroundColor(this.measureResult.dinglanResult.isGood ? '#FFD54F' : '#FFFFFF')
          .border({ width: 1.5, color: this.measureResult.dinglanResult.isGood ? '#FFC107' : '#BDBDBD' }).margin({ right: 6 })
      }.width('100%').height(this.rowHeightDinglan).backgroundColor(this.measureResult.dinglanResult.isGood ? this.colorDinglanGood : this.colorDinglanBad)

      // 英尺信息行
      Stack({ alignContent: Alignment.End }) {
        Column() {
          Text('(30.48) 英尺').fontSize(9).fontColor(this.colorYingchiText).opacity(0.8).margin({ bottom: 2 })
          Text(`${this.measureResult.yingchi.toFixed(2)}英寸`).fontSize(13).fontWeight(FontWeight.Bold).fontColor(this.colorYingchiText)
        }.width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        Column().width(10).height(10).borderRadius(5).backgroundColor('#FFFFFF').border({ width: 1.5, color: '#BDBDBD' }).margin({ right: 6 })
      }.width('100%').height(this.rowHeightYingchi).backgroundColor(this.colorYingchi)
    }
    .width(this.leftPanelWidth + this.safeAreaLeft)
    .padding({ left: this.safeAreaLeft })
  }

  // ============ 公尺刻度尺 ============
  @Builder
  GongchiRuler() {
    Row() {
      ForEach(this.generateArray(this.rulerLengthCm), (cm: number) => {
        Stack() {
          Column() {
            if (cm > 0) {
              Text(`${cm}`)
                .fontSize(cm % 10 === 0 ? 14 : 10)
                .fontWeight(cm % 10 === 0 ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(cm % 10 === 0 ? '#E53935' : this.colorGongchiText)
            }
          }.width('100%').height('100%').alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.End).padding({ bottom: 4 })

          Row() {
            ForEach(this.generateArray(10), (mm: number) => {
              Column() {
                Column()
                  .width(mm === 0 ? 1.5 : 0.5)
                  .height(mm === 0 ? '50%' : (mm === 5 ? '35%' : '20%'))
                  .backgroundColor('#333333')
              }
              .width(this.getSegmentWidth(cm * 10 + mm, cm * 10 + mm + 1))
              .height('100%').alignItems(HorizontalAlign.Start)
            })
          }.width('100%').height('100%').alignItems(VerticalAlign.Top)
        }
        .width(this.getSegmentWidth(cm * 10, (cm + 1) * 10))
        .height(this.rowHeightGongchi).backgroundColor(this.colorGongchi)
      })
    }
    .width(this.getAbsolutePosition(this.rulerLengthCm * 10))
    .height(this.rowHeightGongchi)
  }

  // ============ 鲁班尺行 ============
  @Builder
  LubanRulerRow() {
    Row() {
      ForEach(this.generateArray(Math.ceil(this.rulerLengthCm / LubanCalculator.LUBAN_MAJOR_UNIT)), (majorIdx: number) => {
        Column() {
          Row() {
            ForEach(this.generateArray(4), (minorIdx: number) => {
              Column() {
                Text(LubanCalculator.LUBAN_MINOR_WORDS[majorIdx % 8][minorIdx]).fontSize(11).fontColor('#FFFFFF').maxLines(1)
              }
              .width(this.getSegmentWidth(
                (majorIdx * 4 + minorIdx) * LubanCalculator.LUBAN_MINOR_UNIT * 10,
                (majorIdx * 4 + minorIdx + 1) * LubanCalculator.LUBAN_MINOR_UNIT * 10
              ))
              .height('100%')
              .backgroundColor(LubanCalculator.LUBAN_MINOR_GOOD[majorIdx % 8][minorIdx] ? this.colorLubanMinorGood : this.colorLubanMinorBad)
              .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
              .border({ width: { right: 0.5 }, color: '#00000030' })
            })
          }.width('100%').height('50%')

          Row() {
            Text(LubanCalculator.LUBAN_MAJOR_WORDS[majorIdx % 8]).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          }
          .width('100%').height('50%')
          .backgroundColor(LubanCalculator.LUBAN_MAJOR_GOOD[majorIdx % 8] ? this.colorLubanGood : this.colorLubanBad)
          .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
          .border({ width: { left: 1 }, color: '#00000050' })
        }
        .width(this.getSegmentWidth(
          majorIdx * LubanCalculator.LUBAN_MAJOR_UNIT * 10,
          (majorIdx + 1) * LubanCalculator.LUBAN_MAJOR_UNIT * 10
        ))
        .height(this.rowHeightLuban)
      })
    }
    .width(this.getAbsolutePosition(this.rulerLengthCm * 10))
    .height(this.rowHeightLuban)
  }

  // ============ 丁兰尺行 ============
  @Builder
  DinglanRulerRow() {
    Row() {
      ForEach(this.generateArray(Math.ceil(this.rulerLengthCm / LubanCalculator.DINGLAN_MAJOR_UNIT)), (majorIdx: number) => {
        Column() {
          Row() {
            ForEach(this.generateArray(4), (minorIdx: number) => {
              Column() {
                Text(LubanCalculator.DINGLAN_MINOR_WORDS[majorIdx % 10][minorIdx]).fontSize(11).fontColor('#FFFFFF').maxLines(1)
              }
              .width(this.getSegmentWidth(
                (majorIdx * 4 + minorIdx) * LubanCalculator.DINGLAN_MINOR_UNIT * 10,
                (majorIdx * 4 + minorIdx + 1) * LubanCalculator.DINGLAN_MINOR_UNIT * 10
              ))
              .height('100%')
              .backgroundColor(LubanCalculator.DINGLAN_MINOR_GOOD[majorIdx % 10][minorIdx] ? this.colorDinglanMinorGood : this.colorDinglanMinorBad)
              .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
              .border({ width: { right: 0.5 }, color: '#00000030' })
            })
          }.width('100%').height('50%')

          Row() {
            Text(LubanCalculator.DINGLAN_MAJOR_WORDS[majorIdx % 10]).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          }
          .width('100%').height('50%')
          .backgroundColor(LubanCalculator.DINGLAN_MAJOR_GOOD[majorIdx % 10] ? this.colorDinglanGood : this.colorDinglanBad)
          .justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
          .border({ width: { left: 1 }, color: '#00000050' })
        }
        .width(this.getSegmentWidth(
          majorIdx * LubanCalculator.DINGLAN_MAJOR_UNIT * 10,
          (majorIdx + 1) * LubanCalculator.DINGLAN_MAJOR_UNIT * 10
        ))
        .height(this.rowHeightDinglan)
      })
    }
    .width(this.getAbsolutePosition(this.rulerLengthCm * 10))
    .height(this.rowHeightDinglan)
  }

  // ============ 英尺刻度尺 ============
  @Builder
  YingchiRuler() {
    Row() {
      ForEach(this.generateArray(Math.ceil(this.rulerLengthCm / 2.54)), (inch: number) => {
        Stack() {
          Column() {
            if (inch > 0) {
              Text(`${inch}`).fontSize(11).fontColor(this.colorYingchiText)
            }
          }.width('100%').height('100%').alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.Start).padding({ top: 4, left: 2 })

          Row() {
            ForEach(this.generateArray(8), (eighth: number) => {
              Column() {
                Column()
                  .width(eighth === 0 ? 1 : 0.5)
                  .height(eighth === 0 ? '45%' : (eighth === 4 ? '30%' : '18%'))
                  .backgroundColor(this.colorYingchiText)
              }
              .width(this.getSegmentWidth(inch * 25.4 + eighth * (25.4 / 8), inch * 25.4 + (eighth + 1) * (25.4 / 8)))
              .height('100%').alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.End)
            })
          }.width('100%').height('100%').alignItems(VerticalAlign.Bottom)
        }
        .width(this.getSegmentWidth(inch * 25.4, (inch + 1) * 25.4))
        .height(this.rowHeightYingchi).backgroundColor(this.colorYingchi)
      })
    }
    .width(this.getAbsolutePosition(this.rulerLengthCm * 10))
    .height(this.rowHeightYingchi)
  }
}
