# API 版本兼容方案（全保留 API 20 功能 + API 17 降级体验）

> **创建时间**: 2025-12-29  
> **目标**: 
> 1. ✅ 全保留 API 20 功能（API 20 设备完整体验）
> 2. ✅ API 17 用户显示功能但禁用，提示升级系统（而非隐藏）

---

## 🎯 方案设计原则

### 1. 功能保留策略
- ✅ **API 20 设备**：完整功能，无任何限制
- ✅ **API 17 设备**：功能可见但禁用，显示升级提示
- ❌ **不隐藏功能**：保持UI一致性，避免功能"消失"的困惑

### 2. 用户体验原则
- **可见性**：功能始终可见，用户知道存在但暂时不可用
- **引导性**：明确提示需要升级系统，而非功能缺失
- **一致性**：UI布局保持一致，不因API版本变化

---

## 🔧 技术实现方案

### 方案一：运行时 API 版本检测 + 条件功能启用（推荐）

#### 1.1 创建 API 版本检测工具类

**文件**: `entry/src/main/ets/utils/ApiVersionUtils.ets`

```typescript
/**
 * API 版本检测工具
 * 用于运行时判断设备 API 版本，实现功能的条件启用
 */

import { featureAbility } from '@kit.AbilityKit'

export class ApiVersionUtils {
  private static currentApiVersion: number = -1

  /**
   * 获取当前设备 API 版本（华为官方推荐方法）
   * @returns API 版本号（如 17, 20）
   */
  static getCurrentApiVersion(): number {
    if (this.currentApiVersion === -1) {
      try {
        // ✅ 华为官方推荐：使用 featureAbility.getContext().constant.DEVICE_API_VERSION
        this.currentApiVersion = featureAbility.getContext().constant.DEVICE_API_VERSION
      } catch (err) {
        console.error('[ApiVersionUtils] 获取API版本失败:', JSON.stringify(err))
        // 默认返回 20，确保 API 20 功能可用
        this.currentApiVersion = 20
      }
    }
    return this.currentApiVersion
  }

  /**
   * 判断是否支持 API 20 特性
   * @returns true 表示支持 API 20，false 表示仅支持 API 17
   */
  static isApi20Supported(): boolean {
    return this.getCurrentApiVersion() >= 20
  }

  /**
   * 判断是否支持特定 API 版本
   * @param minVersion 最低要求的 API 版本
   * @returns true 表示支持
   */
  static isApiVersionSupported(minVersion: number): boolean {
    return this.getCurrentApiVersion() >= minVersion
  }
}
```

#### 1.2 修改 MapView.ets - 智感握姿功能条件启用

**关键修改点**：

```typescript
import { ApiVersionUtils } from '../utils/ApiVersionUtils'

@Component
export struct MapView {
  // 运行时检测 API 版本
  @State isApi20Supported: boolean = ApiVersionUtils.isApi20Supported()
  
  // 智感握姿相关状态（仅在 API 20 时使用）
  @State holdingHand: 'LEFT' | 'RIGHT' | null = null
  @StorageLink('gripDetectionEnabled') @Watch('onGripDetectionChange') 
  gripDetectionEnabled: boolean = false
  
  // ✅ 华为官方方案：静态导入 + 条件判断（不需要动态导入）
  // MultimodalAwarenessKit 在 API 17 中也有部分功能，不会崩溃

  aboutToAppear(): void {
    // 根据 API 版本选择不同的实现方案
    if (this.isApi20Supported && this.gripDetectionEnabled) {
      this.setupGripDetection() // API 20: 使用 holdingHandChanged
    } else if (!this.isApi20Supported && this.gripDetectionEnabled) {
      this.setupOperatingHandDetection() // API 17: 使用 operatingHandChanged（替代方案）
    }
  }

  // ✅ API 20: 设置智感握姿检测（holdingHandChanged）
  private setupGripDetection(): void {
    if (!this.isApi20Supported) {
      return
    }
    
    try {
      // ✅ 华为官方方案：静态导入 + 条件判断
      import { motion, HoldingHandStatus } from '@kit.MultimodalAwarenessKit'
      import { BusinessError } from '@kit.BasicServicesKit'
      
      const callback = (status: HoldingHandStatus) => {
        // 智感握姿处理逻辑
        this.holdingHand = status === 1 ? 'LEFT' : status === 2 || status === 3 ? 'RIGHT' : null
        // ... 其他逻辑（按钮位置调整等）
      }
      
      motion.on('holdingHandChanged', callback)
      this.isGripListening = true
    } catch (err) {
      const error = err as BusinessError
      console.error(`[MapView] 设置智感握姿失败，错误码: ${error.code}`)
    }
  }

  // ✅ API 17: 设置操作手状态检测（operatingHandChanged - 替代方案）
  private setupOperatingHandDetection(): void {
    try {
      // ✅ 华为官方方案：API 17 使用 operatingHandChanged 作为替代
      import { motion, OperatingHandStatus } from '@kit.MultimodalAwarenessKit'
      import { BusinessError } from '@kit.BasicServicesKit'
      
      const opCallback = (data: OperatingHandStatus) => {
        // 操作手状态处理逻辑（功能相对简单）
        console.info('[MapView] 操作手状态:', data)
        // 注意：operatingHandChanged 功能可能不如 holdingHandChanged 完整
        // 可以根据实际需求决定是否使用
      }
      
      motion.on('operatingHandChanged', opCallback)
      this.isGripListening = true
    } catch (err) {
      const error = err as BusinessError
      console.error(`[MapView] 设置操作手状态失败，错误码: ${error.code}`)
    }
  }

  // 停止智感握姿检测
  private stopGripDetection(): void {
    if (!this.isApi20Supported || !this.motionModule) {
      return
    }
    
    try {
      this.motionModule.off('holdingHandChanged')
      this.isGripListening = false
    } catch (err) {
      console.error('[MapView] 停止智感握姿失败:', JSON.stringify(err))
    }
  }

  // 智感握姿开关变化处理
  private onGripDetectionChange(): void {
    if (!this.isApi20Supported) {
      // API 17 用户尝试开启，显示升级提示
      this.showUpgradePrompt()
      // 重置开关状态
      this.gripDetectionEnabled = false
      return
    }
    
    if (this.gripDetectionEnabled) {
      this.setupGripDetection()
    } else {
      this.stopGripDetection()
    }
  }

  // 显示升级系统提示
  private showUpgradePrompt(): void {
    this.getUIContext().getPromptAction().showDialog({
      title: '需要升级系统',
      message: '智感握姿功能需要 HarmonyOS 6.0 及以上版本支持，请升级系统后使用。',
      buttons: [
        { text: '知道了', color: '#007DFF' }
      ]
    }).then((result) => {
      // 用户确认
    }).catch((err) => {
      console.error('[MapView] 显示升级提示失败:', JSON.stringify(err))
    })
  }

  build() {
    Stack() {
      // ... 地图内容
      
      // 定位按钮（智感握姿仅在 API 20 时生效）
      Button() {
        // ... 按钮内容
      }
      .position({
        x: this.isApi20Supported && this.holdingHand === 'LEFT' 
          ? 16 
          : this.isApi20Supported && this.holdingHand === 'RIGHT'
          ? 'calc(100% - 64vp)'
          : 16,
        y: this.isApi20Supported && this.holdingHand
          ? '60%'
          : `calc(100% - ${this.safeBottom}vp - 128vp)`
      })
      .enabled(true) // 按钮始终可用（定位功能不依赖 API 20）
    }
  }
}
```

#### 1.3 修改 GeneralSettingsPage.ets - 设置项显示但禁用

```typescript
import { ApiVersionUtils } from '../utils/ApiVersionUtils'

@Component
export struct GeneralSettingsPage {
  @State isApi20Supported: boolean = ApiVersionUtils.isApi20Supported()
  @StorageLink('gripDetectionEnabled') gripDetectionEnabled: boolean = false

  build() {
    Column() {
      // ... 其他设置项
      
      // 智感握姿设置项（始终显示）
      Row() {
        Column() {
          Text('智感握姿')
            .fontSize(16)
            .fontColor(this.isApi20Supported ? $r('app.color.text_primary') : $r('app.color.text_disabled'))
          
          if (!this.isApi20Supported) {
            Text('需要 HarmonyOS 6.0+')
              .fontSize(12)
              .fontColor($r('app.color.text_disabled'))
              .margin({ top: 4 })
          } else {
            Text('根据握持手势自动调整按钮位置')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 4 })
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        
        Toggle({ 
          type: ToggleType.Switch, 
          isOn: this.gripDetectionEnabled 
        })
        .enabled(this.isApi20Supported) // API 17 时禁用
        .selectedColor(this.isApi20Supported ? $r('app.color.toggle_on') : $r('app.color.toggle_disabled'))
        .switchPointColor(this.isApi20Supported ? Color.White : $r('app.color.toggle_disabled'))
        .onChange((isOn: boolean) => {
          if (!this.isApi20Supported) {
            // API 17 用户点击，显示升级提示
            this.showUpgradePrompt()
            return
          }
          this.gripDetectionEnabled = isOn
        })
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor($r('app.color.item_background'))
      .borderRadius(8)
      .opacity(this.isApi20Supported ? 1 : 0.6) // API 17 时降低透明度
    }
  }

  private showUpgradePrompt(): void {
    this.getUIContext().getPromptAction().showDialog({
      title: '需要升级系统',
      message: '智感握姿功能需要 HarmonyOS 6.0 及以上版本支持。\n\n请前往"设置 > 系统和更新 > 软件更新"升级系统。',
      buttons: [
        { text: '知道了', color: '#007DFF' },
        { 
          text: '前往设置', 
          color: '#007DFF',
          action: () => {
            // 跳转到系统设置（如支持）
            // 或显示更详细的升级指引
          }
        }
      ]
    })
  }
}
```

---

## 📋 实施步骤

### Step 1: 创建 API 版本检测工具（1小时）

1. ✅ 创建 `ApiVersionUtils.ets`
2. ✅ 实现 `getCurrentApiVersion()` 方法
3. ✅ 实现 `isApi20Supported()` 方法
4. ✅ 测试 API 版本检测准确性

### Step 2: 修改 MapView.ets（2-3小时）

1. ✅ 导入 `ApiVersionUtils`
2. ✅ 添加 `@State isApi20Supported` 状态
3. ✅ 修改 `aboutToAppear()` - 条件加载 MultimodalAwarenessKit
4. ✅ 修改 `setupGripDetection()` - 添加 API 版本检查
5. ✅ 修改 `onGripDetectionChange()` - 添加升级提示
6. ✅ 修改按钮位置逻辑 - 仅在 API 20 时响应握姿
7. ✅ 添加 `showUpgradePrompt()` 方法

### Step 3: 修改 GeneralSettingsPage.ets（1小时）

1. ✅ 导入 `ApiVersionUtils`
2. ✅ 添加 `@State isApi20Supported` 状态
3. ✅ 修改智感握姿设置项 UI：
   - 显示但禁用（API 17）
   - 显示升级提示文字
   - 降低透明度
4. ✅ 修改 Toggle 组件：
   - `enabled(this.isApi20Supported)`
   - 禁用时显示灰色样式
5. ✅ 添加 `showUpgradePrompt()` 方法

### Step 4: 配置文件修改（0.5小时）

#### 4.1 修改 build-profile.json5
```json5
{
  "app": {
    "products": [{
      "name": "default",
      "targetSdkVersion": "5.0.0(17)",  // 降级到 API 17
      "compatibleSdkVersion": "5.0.0(17)"
    }]
  }
}
```

#### 4.2 修改 module.json5
```json5
{
  "module": {
    "requestPermissions": [
      // 保留 DETECT_GESTURE 权限（API 20 设备需要）
      // API 17 设备会自动忽略不支持的权限
      {
        "name": "ohos.permission.DETECT_GESTURE",
        "reason": "$string:detect_gesture_permission_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      }
    ]
  }
}
```

**注意**：权限声明可以保留，API 17 设备会自动忽略不支持的权限，不会报错。

### Step 5: 资源文件添加（0.5小时）

#### 5.1 添加颜色资源

**entry/src/main/resources/base/element/color.json**:
```json
{
  "color": [
    {
      "name": "text_disabled",
      "value": "#999999"
    },
    {
      "name": "toggle_disabled",
      "value": "#CCCCCC"
    }
  ]
}
```

#### 5.2 添加字符串资源

**entry/src/main/resources/base/element/string.json**:
```json
{
  "string": [
    {
      "name": "upgrade_prompt_title",
      "value": "需要升级系统"
    },
    {
      "name": "upgrade_prompt_message",
      "value": "此功能需要 HarmonyOS 6.0 及以上版本支持，请升级系统后使用。"
    },
    {
      "name": "grip_detection_requires_upgrade",
      "value": "需要 HarmonyOS 6.0+"
    }
  ]
}
```

### Step 6: 测试验证（2-3小时）

#### 6.1 API 20 设备测试
- [ ] 智感握姿功能正常启用
- [ ] 设置开关可以正常切换
- [ ] 按钮位置随握姿变化
- [ ] 无任何错误或警告

#### 6.2 API 17 设备测试
- [ ] 智感握姿设置项显示但禁用
- [ ] 显示"需要 HarmonyOS 6.0+"提示
- [ ] 点击开关显示升级提示对话框
- [ ] 地图定位按钮正常（不受影响）
- [ ] 无崩溃或错误

---

## 🎨 UI/UX 设计规范

### API 17 用户界面规范

| 元素 | API 20 状态 | API 17 状态 |
|------|------------|------------|
| **设置项文字** | 正常颜色（`text_primary`） | 灰色（`text_disabled`） |
| **设置项描述** | 功能说明 | "需要 HarmonyOS 6.0+" |
| **Toggle 开关** | 正常颜色，可点击 | 灰色，禁用状态 |
| **整体透明度** | 100% | 60%（视觉上表示不可用） |
| **点击反馈** | 切换开关 | 显示升级提示对话框 |

### 升级提示对话框设计

**标题**: "需要升级系统"  
**内容**: 
```
此功能需要 HarmonyOS 6.0 及以上版本支持。

请前往"设置 > 系统和更新 > 软件更新"升级系统。
```

**按钮**:
- "知道了"（默认）
- "前往设置"（可选，如系统支持跳转）

---

## ⚠️ 注意事项

### 1. 动态导入的限制
- ArkTS 不支持真正的动态 `import()`，需要使用 `try-catch` 包裹
- 如果导入失败，降级为不支持状态

### 2. API 版本检测的准确性
- `systemInfo.getSystemInfoSync()` 是推荐方法
- 如果检测失败，默认返回 20（保守策略，确保功能可用）

### 3. 权限处理
- `DETECT_GESTURE` 权限可以保留在 `module.json5` 中
- API 17 设备会自动忽略不支持的权限，不会报错
- API 20 设备正常申请和使用权限

### 4. 编译时检查
- 使用条件编译可能导致编译警告
- 建议使用 `try-catch` 包裹 API 20 特有代码
- 或使用类型断言避免编译错误

---

## 📊 方案对比

| 方案 | 优点 | 缺点 | 推荐度 |
|------|------|------|--------|
| **方案一：运行时检测+条件启用** | ✅ 全保留功能<br>✅ UI一致性<br>✅ 用户体验好 | ⚠️ 代码复杂度稍高 | ⭐⭐⭐⭐⭐ |
| **方案二：隐藏功能** | ✅ 代码简单 | ❌ UI不一致<br>❌ 用户困惑 | ⭐⭐ |
| **方案三：多版本构建** | ✅ 完全隔离 | ❌ 维护成本高<br>❌ 需要两套代码 | ⭐⭐⭐ |

---

## 🎯 最终效果

### API 20 用户
- ✅ 看到完整的智感握姿设置项
- ✅ 可以正常开启/关闭功能
- ✅ 地图按钮位置随握姿自动调整
- ✅ 完整的功能体验

### API 17 用户
- ✅ 看到智感握姿设置项（但禁用状态）
- ✅ 看到"需要 HarmonyOS 6.0+"提示
- ✅ 点击开关时显示升级提示对话框
- ✅ 明确知道需要升级系统才能使用
- ✅ 其他功能（定位、地图等）完全正常

---

**最后更新**: 2025-12-29  
**状态**: 📋 待实施

