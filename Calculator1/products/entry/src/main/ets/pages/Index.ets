import { CommonConstants, RouterModule } from 'lib_foundation';
import { StandardCalculator } from 'module_standard_calculator';

@Entry
@ComponentV2
struct Index {
  aboutToAppear() {
    // 处理卡片路由（保留兼容性）
    let message = AppStorage.get('widget_router') ?? ''
    if (!message || message === 'all') {
      return
    }
  }

  build() {
    Navigation(RouterModule.getStack()) {
      Column() {
        StandardCalculator({
          routerModule: RouterModule.getStack()
        })
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM])
    .backgroundColor($r('sys.color.background_primary'))
    .mode(NavigationMode.Stack);
  }
}