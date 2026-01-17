/**
 * 语音输入引导页面
 * 首次使用时展示，介绍语音速记功能的使用方法和典型模板
 */

import { ThemeManager, type ThemeColors } from '@ohos/commonlib';
import { router } from '@kit.ArkUI';
import storageUtils from '@ohos/commonlib';

// 语音模板示例数据
const VOICE_TEMPLATES = [
  {
    id: 1,
    title: '计时类',
    example: '6月15日 砌墙 8小时 加班2小时',
    description: '适用于按小时计算的工作记录'
  },
  {
    id: 2,
    title: '计件类',
    example: '6月15日 搬运 50件 每件10元',
    description: '适用于按数量计算的工作记录'
  },
  {
    id: 3,
    title: '简化类',
    example: '今天 打扫卫生 3小时',
    description: '适用于简单的工作记录'
  },
  {
    id: 4,
    title: '无日期类',
    example: '安装设备 4小时 加班1小时',
    description: '默认使用当前日期'
  }
];

@Entry
@Component
export struct VoiceGuidePage {
  @StorageProp('themeColors') themeColors: ThemeColors = ThemeManager.getInstance().colors
  @State showAgain: boolean = true

  // 跳过引导
  private async skipGuide(): Promise<void> {
    await this.saveGuidePreference();
    router.back();
  }

  // 保存引导偏好设置
  private async saveGuidePreference(): Promise<void> {
    try {
      // 确保存储工具已初始化
      await storageUtils.init();
      await storageUtils.set('showVoiceGuide', this.showAgain);
    } catch (error) {
      console.error(`保存引导偏好设置失败: ${error}`);
    }
  }

  // 开始使用
  private async startUsing(): Promise<void> {
    await this.saveGuidePreference();
    router.back();
  }

  build() {
    Column({
      space: 20
    }) {
      // 标题
      Text('语音速记功能引导')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeColors.textPrimary)
        .margin({ top: 40 })

      // 引导内容
      Scroll() {
        Column({
          space: 20
        }) {
          // 功能介绍
          Text('语音速记功能可以帮助您快速记录工时，只需说出工作内容，系统会自动解析并填充表单。')
            .fontSize(16)
            .fontColor(this.themeColors.textSecondary)
            .textAlign(TextAlign.Center)
            .padding({ left: 20, right: 20 })

          // 模板示例
          Text('典型语音模板示例：')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeColors.textPrimary)
            .margin({ top: 20 })

          // 模板列表
          ForEach(VOICE_TEMPLATES, (template) => {
            Column() {
              Text(template.title)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeColors.primaryColor)
                .margin({ bottom: 8 })

              Text(template.example)
                .fontSize(16)
                .fontColor(this.themeColors.textPrimary)
                .backgroundColor(this.themeColors.surfaceVariant)
                .padding(12)
                .borderRadius(8)
                .margin({ bottom: 8 })

              Text(template.description)
                .fontSize(14)
                .fontColor(this.themeColors.textSecondary)
            }
            .padding({ left: 20, right: 20 })
          }, (template) => template.id.toString())

          // 使用提示
          Text('使用提示：')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeColors.textPrimary)
            .margin({ top: 20 })

          Column({
            space: 10
          }) {
            Text('• 点击悬浮麦克风按钮开始录音')
              .fontSize(14)
              .fontColor(this.themeColors.textSecondary)
            Text('• 清晰说出工作内容，包括日期、任务和时长/数量')
              .fontSize(14)
              .fontColor(this.themeColors.textSecondary)
            Text('• 系统会自动解析并跳转到添加工时页面')
              .fontSize(14)
              .fontColor(this.themeColors.textSecondary)
          }
          .padding({ left: 20, right: 20 })
        }
      }
      .flexGrow(1)

      // 不再显示选项
      Row({
        space: 10
      }) {
        Checkbox()
          .checked(this.showAgain)
          .onChange((isChecked) => {
            this.showAgain = isChecked;
          })

        Text('不再显示此引导')
          .fontSize(14)
          .fontColor(this.themeColors.textSecondary)
      }
      .margin({ bottom: 20 })

      // 底部按钮
      Column({
        space: 15
      }) {
        Button('开始使用')
          .width('80%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.themeColors.primaryColor)
          .textAlign(TextAlign.Center)
          .borderRadius(24)
          .onClick(() => {
            this.startUsing();
          })

        Button('跳过')
          .width('80%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.themeColors.surfaceVariant)
          .textAlign(TextAlign.Center)
          .borderRadius(24)
          .onClick(() => {
            this.skipGuide();
          })
      }
      .margin({ bottom: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColors.surfaceBackground)
  }
}
