# API 版本兼容实施清单（全保留 + 降级体验）

> **创建时间**: 2025-12-29  
> **目标**: 全保留 API 20 功能，API 17 用户显示但禁用并提示升级

---

## ✅ 实施清单

### Phase 1: 创建工具类（1小时）

- [ ] **创建 `entry/src/main/ets/utils/ApiVersionUtils.ets`**
  - [ ] 实现 `getCurrentApiVersion()` 方法
  - [ ] 实现 `isApi20Supported()` 方法
  - [ ] 实现 `isApiVersionSupported(minVersion)` 方法
  - [ ] 添加错误处理和日志

### Phase 2: 修改 MapView.ets（2-3小时）

- [ ] **导入和状态**
  - [ ] 导入 `ApiVersionUtils`
  - [ ] 添加 `@State isApi20Supported: boolean`
  - [ ] 添加 `private motionModule: any = null`

- [ ] **条件加载模块**
  - [ ] 修改 `aboutToAppear()` - 条件导入 `MultimodalAwarenessKit`
  - [ ] 使用 `try-catch` 包裹导入逻辑
  - [ ] 导入失败时降级为不支持

- [ ] **功能启用逻辑**
  - [ ] 修改 `setupGripDetection()` - 添加 API 版本检查
  - [ ] 修改 `stopGripDetection()` - 添加 API 版本检查
  - [ ] 修改 `onGripDetectionChange()` - 添加升级提示

- [ ] **升级提示**
  - [ ] 添加 `showUpgradePrompt()` 方法
  - [ ] 显示对话框提示升级系统

- [ ] **按钮位置逻辑**
  - [ ] 修改按钮 `position` - 仅在 API 20 时响应握姿
  - [ ] API 17 时使用默认位置

### Phase 3: 修改 GeneralSettingsPage.ets（1小时）

- [ ] **导入和状态**
  - [ ] 导入 `ApiVersionUtils`
  - [ ] 添加 `@State isApi20Supported: boolean`

- [ ] **UI 修改**
  - [ ] 修改智感握姿设置项文字颜色（API 17 时灰色）
  - [ ] 修改描述文字（API 17 时显示"需要 HarmonyOS 6.0+"）
  - [ ] 修改 Toggle 组件：
    - [ ] `.enabled(this.isApi20Supported)`
    - [ ] 禁用时灰色样式
  - [ ] 添加整体透明度（API 17 时 60%）

- [ ] **交互逻辑**
  - [ ] 修改 `onChange` - API 17 时显示升级提示
  - [ ] 添加 `showUpgradePrompt()` 方法

### Phase 4: 配置文件修改（0.5小时）

- [ ] **修改 `build-profile.json5`**
  ```json5
  {
    "app": {
      "products": [{
        "targetSdkVersion": "5.0.0(17)",
        "compatibleSdkVersion": "5.0.0(17)"
      }]
    }
  }
  ```

- [ ] **保留 `module.json5` 权限**
  - [ ] 保留 `ohos.permission.DETECT_GESTURE`（API 17 自动忽略）

### Phase 5: 资源文件添加（0.5小时）

- [ ] **添加颜色资源** (`base/element/color.json`)
  - [ ] `text_disabled: "#999999"`
  - [ ] `toggle_disabled: "#CCCCCC"`

- [ ] **添加字符串资源** (`base/element/string.json`)
  - [ ] `upgrade_prompt_title: "需要升级系统"`
  - [ ] `upgrade_prompt_message: "此功能需要 HarmonyOS 6.0 及以上版本支持..."`
  - [ ] `grip_detection_requires_upgrade: "需要 HarmonyOS 6.0+"`

### Phase 6: 测试验证（2-3小时）

- [ ] **API 20 设备测试**
  - [ ] 智感握姿功能正常启用
  - [ ] 设置开关可以正常切换
  - [ ] 按钮位置随握姿变化
  - [ ] 无任何错误或警告

- [ ] **API 17 设备测试**
  - [ ] 智感握姿设置项显示但禁用
  - [ ] 显示"需要 HarmonyOS 6.0+"提示
  - [ ] 点击开关显示升级提示对话框
  - [ ] 地图定位按钮正常（不受影响）
  - [ ] 无崩溃或错误

- [ ] **兼容性测试**
  - [ ] 使用 `hdc shell aa checkapi --target 17` 扫描
  - [ ] 编译无警告
  - [ ] 运行时无错误

---

## 📝 关键代码片段

### ApiVersionUtils.ets
```typescript
import { systemInfo } from '@kit.SystemInfoKit'

export class ApiVersionUtils {
  private static currentApiVersion: number = -1

  static getCurrentApiVersion(): number {
    if (this.currentApiVersion === -1) {
      try {
        const deviceInfo = systemInfo.getSystemInfoSync()
        this.currentApiVersion = deviceInfo.apiVersion || 20
      } catch (err) {
        console.error('[ApiVersionUtils] 获取API版本失败:', JSON.stringify(err))
        this.currentApiVersion = 20 // 默认返回20，确保功能可用
      }
    }
    return this.currentApiVersion
  }

  static isApi20Supported(): boolean {
    return this.getCurrentApiVersion() >= 20
  }
}
```

### GeneralSettingsPage.ets 关键修改
```typescript
@State isApi20Supported: boolean = ApiVersionUtils.isApi20Supported()

// UI部分
Text('智感握姿')
  .fontColor(this.isApi20Supported ? $r('app.color.text_primary') : $r('app.color.text_disabled'))

if (!this.isApi20Supported) {
  Text('需要 HarmonyOS 6.0+')
    .fontColor($r('app.color.text_disabled'))
}

Toggle({ type: ToggleType.Switch, isOn: this.gripDetectionEnabled })
  .enabled(this.isApi20Supported)
  .onChange((isOn: boolean) => {
    if (!this.isApi20Supported) {
      this.showUpgradePrompt()
      return
    }
    this.gripDetectionEnabled = isOn
  })
```

---

## ⚠️ 注意事项

1. **动态导入限制**：ArkTS 不支持真正的动态 `import()`，需要使用 `try-catch` 包裹
2. **API 版本检测**：如果检测失败，默认返回 20（保守策略）
3. **权限处理**：`DETECT_GESTURE` 权限可以保留，API 17 自动忽略
4. **编译警告**：条件编译可能导致编译警告，使用 `try-catch` 处理

---

**最后更新**: 2025-12-29  
**状态**: 📋 待实施

