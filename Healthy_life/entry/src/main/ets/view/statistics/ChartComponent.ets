/**
 * 数据统计图表组件
 * 使用Canvas绘制周完成度折线图和月汇总柱状图
 */

import { CommonConstants as Const } from '../../common/constants/CommonConstants';
import { ChartDataPoint } from '../../common/utils/StatisticsService';

/**
 * 折线图组件
 */
@Component
export struct LineChart {
  @Prop chartData: ChartDataPoint[] = [];
  @Prop chartTitle: string = '周完成度趋势';
  @Prop primaryColor: string = '#52C41A';
  @State canvasWidth: number = 0;
  @State canvasHeight: number = 200;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  /**
   * 绘制折线图
   */
  drawLineChart() {
    const ctx = this.context;
    const padding = 40;
    const chartWidth = this.canvasWidth - padding * 2;
    const chartHeight = this.canvasHeight - padding * 2;

    // 清空画布
    ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    if (this.chartData.length === 0) {
      this.drawEmptyState(ctx);
      return;
    }

    // 绘制背景网格
    this.drawGrid(ctx, padding, chartWidth, chartHeight);

    // 绘制数据线
    this.drawDataLine(ctx, padding, chartWidth, chartHeight);

    // 绘制数据点
    this.drawDataPoints(ctx, padding, chartWidth, chartHeight);

    // 绘制X轴标签
    this.drawXAxisLabels(ctx, padding, chartWidth, chartHeight);

    // 绘制Y轴标签
    this.drawYAxisLabels(ctx, padding, chartHeight);
  }

  /**
   * 绘制空状态
   */
  drawEmptyState(ctx: CanvasRenderingContext2D) {
    ctx.font = '14px HarmonyOS Sans';
    ctx.fillStyle = '#999999';
    ctx.textAlign = 'center';
    ctx.fillText('暂无数据', this.canvasWidth / 2, this.canvasHeight / 2);
  }

  /**
   * 绘制网格背景
   */
  drawGrid(ctx: CanvasRenderingContext2D, padding: number, width: number, height: number) {
    ctx.strokeStyle = '#F0F0F0';
    ctx.lineWidth = 1;

    // 绘制横线(5条)
    for (let i = 0; i <= 5; i++) {
      const y = padding + (height / 5) * i;
      ctx.beginPath();
      ctx.moveTo(padding, y);
      ctx.lineTo(padding + width, y);
      ctx.stroke();
    }

    // 绘制竖线
    const step = width / (this.chartData.length - 1 || 1);
    for (let i = 0; i < this.chartData.length; i++) {
      const x = padding + step * i;
      ctx.beginPath();
      ctx.moveTo(x, padding);
      ctx.lineTo(x, padding + height);
      ctx.stroke();
    }
  }

  /**
   * 绘制数据线
   */
  drawDataLine(ctx: CanvasRenderingContext2D, padding: number, width: number, height: number) {
    ctx.strokeStyle = this.primaryColor;
    ctx.lineWidth = 2;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';

    const step = width / (this.chartData.length - 1 || 1);

    ctx.beginPath();
    this.chartData.forEach((point, index) => {
      const x = padding + step * index;
      const y = padding + height - (point.value / 100) * height;

      if (index === 0) {
        ctx.moveTo(x, y);
      } else {
        ctx.lineTo(x, y);
      }
    });
    ctx.stroke();

    // 绘制渐变填充
    const gradient = ctx.createLinearGradient(0, padding, 0, padding + height);
    gradient.addColorStop(0, this.primaryColor + '30');
    gradient.addColorStop(1, this.primaryColor + '00');

    ctx.fillStyle = gradient;
    ctx.beginPath();
    ctx.moveTo(padding, padding + height);
    this.chartData.forEach((point, index) => {
      const x = padding + step * index;
      const y = padding + height - (point.value / 100) * height;
      ctx.lineTo(x, y);
    });
    ctx.lineTo(padding + width, padding + height);
    ctx.closePath();
    ctx.fill();
  }

  /**
   * 绘制数据点
   */
  drawDataPoints(ctx: CanvasRenderingContext2D, padding: number, width: number, height: number) {
    const step = width / (this.chartData.length - 1 || 1);

    this.chartData.forEach((point, index) => {
      const x = padding + step * index;
      const y = padding + height - (point.value / 100) * height;

      // 外圆
      ctx.fillStyle = '#FFFFFF';
      ctx.beginPath();
      ctx.arc(x, y, 6, 0, Math.PI * 2);
      ctx.fill();

      // 内圆
      ctx.fillStyle = this.primaryColor;
      ctx.beginPath();
      ctx.arc(x, y, 4, 0, Math.PI * 2);
      ctx.fill();
    });
  }

  /**
   * 绘制X轴标签
   */
  drawXAxisLabels(ctx: CanvasRenderingContext2D, padding: number, width: number, height: number) {
    ctx.font = '12px HarmonyOS Sans';
    ctx.fillStyle = '#999999';
    ctx.textAlign = 'center';

    const step = width / (this.chartData.length - 1 || 1);

    this.chartData.forEach((point, index) => {
      const x = padding + step * index;
      const y = padding + height + 20;
      ctx.fillText(point.label, x, y);
    });
  }

  /**
   * 绘制Y轴标签
   */
  drawYAxisLabels(ctx: CanvasRenderingContext2D, padding: number, height: number) {
    ctx.font = '12px HarmonyOS Sans';
    ctx.fillStyle = '#999999';
    ctx.textAlign = 'right';

    for (let i = 0; i <= 5; i++) {
      const value = 100 - i * 20;
      const y = padding + (height / 5) * i + 5;
      ctx.fillText(value + '%', padding - 10, y);
    }
  }

  build() {
    Column() {
      // 标题
      Text(this.chartTitle)
        .fontSize($r('app.float.default_16'))
        .fontWeight(Const.FONT_WEIGHT_500)
        .fontColor($r('app.color.titleColor'))
        .margin({ bottom: 16 })

      // 图表画布
      Canvas(this.context)
        .width('100%')
        .height(this.canvasHeight)
        .onReady(() => {
          this.drawLineChart();
        })
        .onAreaChange((oldValue: Area, newValue: Area) => {
          this.canvasWidth = newValue.width as number;
          this.drawLineChart();
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.start_window_background'))
    .borderRadius(12)
  }
}

/**
 * 柱状图组件
 */
@Component
export struct BarChart {
  @Prop chartData: ChartDataPoint[] = [];
  @Prop chartTitle: string = '月任务完成统计';
  @Prop primaryColor: string = '#52C41A';
  @State canvasWidth: number = 0;
  @State canvasHeight: number = 200;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  /**
   * 绘制柱状图
   */
  drawBarChart() {
    const ctx = this.context;
    const padding = 40;
    const chartWidth = this.canvasWidth - padding * 2;
    const chartHeight = this.canvasHeight - padding * 2;

    // 清空画布
    ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    if (this.chartData.length === 0) {
      this.drawEmptyState(ctx);
      return;
    }

    // 绘制Y轴标签
    this.drawYAxisLabels(ctx, padding, chartHeight);

    // 绘制柱子
    this.drawBars(ctx, padding, chartWidth, chartHeight);

    // 绘制X轴标签
    this.drawXAxisLabels(ctx, padding, chartWidth, chartHeight);
  }

  /**
   * 绘制空状态
   */
  drawEmptyState(ctx: CanvasRenderingContext2D) {
    ctx.font = '14px HarmonyOS Sans';
    ctx.fillStyle = '#999999';
    ctx.textAlign = 'center';
    ctx.fillText('暂无数据', this.canvasWidth / 2, this.canvasHeight / 2);
  }

  /**
   * 绘制柱子
   */
  drawBars(ctx: CanvasRenderingContext2D, padding: number, width: number, height: number) {
    const barWidth = (width / this.chartData.length) * 0.6;
    const barSpacing = (width / this.chartData.length) * 0.4;

    this.chartData.forEach((point, index) => {
      const x = padding + (width / this.chartData.length) * index + barSpacing / 2;
      const barHeight = (point.value / 100) * height;
      const y = padding + height - barHeight;

      // 绘制柱子
      ctx.fillStyle = this.primaryColor;
      ctx.fillRect(x, y, barWidth, barHeight);

      // 绘制数值标签
      ctx.font = '12px HarmonyOS Sans';
      ctx.fillStyle = '#333333';
      ctx.textAlign = 'center';
      ctx.fillText(point.value.toFixed(0) + '%', x + barWidth / 2, y - 5);
    });
  }

  /**
   * 绘制X轴标签
   */
  drawXAxisLabels(ctx: CanvasRenderingContext2D, padding: number, width: number, height: number) {
    ctx.font = '12px HarmonyOS Sans';
    ctx.fillStyle = '#999999';
    ctx.textAlign = 'center';

    this.chartData.forEach((point, index) => {
      const x = padding + (width / this.chartData.length) * index + (width / this.chartData.length) / 2;
      const y = padding + height + 20;
      ctx.fillText(point.label, x, y);
    });
  }

  /**
   * 绘制Y轴标签
   */
  drawYAxisLabels(ctx: CanvasRenderingContext2D, padding: number, height: number) {
    ctx.font = '12px HarmonyOS Sans';
    ctx.fillStyle = '#999999';
    ctx.textAlign = 'right';

    for (let i = 0; i <= 5; i++) {
      const value = 100 - i * 20;
      const y = padding + (height / 5) * i + 5;
      ctx.fillText(value + '%', padding - 10, y);
    }
  }

  build() {
    Column() {
      // 标题
      Text(this.chartTitle)
        .fontSize($r('app.float.default_16'))
        .fontWeight(Const.FONT_WEIGHT_500)
        .fontColor($r('app.color.titleColor'))
        .margin({ bottom: 16 })

      // 图表画布
      Canvas(this.context)
        .width('100%')
        .height(this.canvasHeight)
        .onReady(() => {
          this.drawBarChart();
        })
        .onAreaChange((oldValue: Area, newValue: Area) => {
          this.canvasWidth = newValue.width as number;
          this.drawBarChart();
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.start_window_background'))
    .borderRadius(12)
  }
}
