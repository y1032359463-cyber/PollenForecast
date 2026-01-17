import { ThemeManager, ThemeMode } from '@ohos/commonlib';

@Entry
@Component
struct SplashPage {
  @StorageLink('currentThemeMode') currentThemeMode: string = ThemeManager.getInstance().getThemeMode();
  private themeManager = ThemeManager.getInstance();

  aboutToAppear() {
    console.info('[SplashPage] 启动页加载, 当前主题:', this.currentThemeMode);
    // 3.5秒后跳转到主页（确保首页+日历组件完全加载，消除白屏块）
    setTimeout(() => {
      // 这里会自动跳转,因为EntryAbility会处理路由
    }, 3500);
  }

  build() {
    Column() {
      // 启动页图标 - 纯图标不带圆角矩形背景
      Image($r('app.media.foreground'))
        .width(180)
        .height(180)
        .objectFit(ImageFit.Contain)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeManager.colors.background) // 使用主题背景色
    .justifyContent(FlexAlign.Center)
  }
}
