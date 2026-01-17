# API 版本兼容性

> **分类**: HarmonyOS API 版本差异与降级方案  
> **最后更新**: 2026-01-08  
> **返回**: [← 主知识库](../知识库.md)

---

## 📑 本分类包含

1. [API 版本差异层级](#api-版本差异层级)
2. [API 17 降级方案](#api-17-降级方案)
3. [API 版本检测工具](#api-版本检测工具)

---

## API 版本差异层级

> ✅ **已验证**: 2025-12-29  
> **来源**: 项目实践 + 系统架构差异  
> **适用项目**: 所有 HarmonyOS NEXT 应用

### 核心知识点

**HarmonyOS NEXT 架构版本**：
- **API 17** (HarmonyOS 5.0.0) - 原生鸿蒙5.0设备
- **API 20** (HarmonyOS 6.0.0) - 原生鸿蒙6.0设备

**重要认知**：
- ✅ **API 17 和 API 20 都是 HarmonyOS NEXT**：底层架构相同，差异主要是新特性
- ⚠️ **降级到 API 17 相对可行**：比降级到 API 9 容易得多
- ❌ **API 9 与 API 20 系统底层逻辑完全不同**：API 9 是旧架构，不能简单降级

---

## API 17 降级方案

### Kit 兼容性详情

| Kit 模块 | API 17 支持情况 | 处理方案 |
|---------|----------------|---------|
| `@kit.AbilityKit` | ✅ 完整支持（Stage模型） | 需检查生命周期方法参数差异 |
| `@kit.ArkUI` | ✅ 声明式UI完整支持 | 注意组件属性兼容性 |
| `@kit.MapKit` | ⚠️ 功能受限（5.0基础版） | 需降级地图渲染引擎 |
| `@kit.FormKit` | ⚠️ 服务卡片API部分差异 | 重构卡片布局逻辑 |
| `@kit.NetworkKit` | ✅ 完整支持 | 保持原有实现 |
| `@kit.LocationKit` | ✅ 完整支持 | 保持原有实现 |
| `@kit.MultimodalAwarenessKit` | ❌ 不支持 | **必须移除或条件编译** |

### 关键 API 差异

- 路由参数：API 17 仅支持字符串参数，禁止传递对象类型
- 地图事件：MapMarker 点击事件回调格式不同（`event.latitude` vs `event.value.lat`）
- Ability 生命周期：参数类型差异（`common.Context` vs `AbilityContext`）
- 网络请求：API 17 推荐使用 `@system.http`（但 NetworkKit 仍可用）

### 工作量评估（中型项目）

- 核心架构适配：8-10人日
- UI层适配：5-7人日
- 功能降级：3-5人日
- 全量测试：4-6人日
- **总计**：20-28人日

---

## API 版本检测工具

> ✅ **已验证**: 2026-01-05

**API 版本检测工具类**：
```typescript
// entry/src/main/ets/utils/ApiVersionUtils.ets
import { deviceInfo } from '@kit.BasicServicesKit';

export class ApiVersionUtils {
  private static apiVersion: number | null = null;

  static getApiVersion(): number {
    if (this.apiVersion === null) {
      this.apiVersion = deviceInfo.sdkApiVersion; // ✅ 已验证可用
    }
    return this.apiVersion;
  }

  static isAPI20(): boolean {
    return this.getApiVersion() >= 20;
  }

  static supportsGripDetection(): boolean {
    return this.isAPI20(); // 智感握姿仅 API 20+ 支持
  }
}
```

**条件功能启用**：
```typescript
// 智感握姿条件启用
import { motion } from '@kit.MultimodalAwarenessKit';

if (ApiVersionUtils.isAPI20()) {
  // API 20: 使用 holdingHandChanged
  motion.on('holdingHandChanged', callback);
} else if (ApiVersionUtils.getApiVersion() >= 15) {
  // API 17: 使用 operatingHandChanged（替代方案）
  motion.on('operatingHandChanged', opCallback);
}
```

**UI 降级体验**：
```typescript
// GeneralSettingsPage.ets - 智感握姿开关
Row()
  .onClick(() => {
    if (!ApiVersionUtils.supportsGripDetection()) {
      promptAction.showToast({ message: '此功能需要 HarmonyOS 6.0+' })
      return
    }
  }) {
  Text('智感握姿')
    .fontColor(ApiVersionUtils.supportsGripDetection() 
      ? $r('app.color.text_primary') 
      : $r('app.color.text_secondary'))
  
  Toggle({ type: ToggleType.Switch, isOn: this.gripDetectionEnabled })
    .enabled(ApiVersionUtils.supportsGripDetection()) // API 17 禁用
    .opacity(ApiVersionUtils.supportsGripDetection() ? 1 : 0.5)
}
```

---

## API 17 设备安装问题

> ⚠️ **重要**: 2026-01-08 更新

### 错误信息

```
code:9568297 error: install failed due to older sdk version in the device
```

### 错误含义

**设备上的镜像版本低于编译打包的SDK版本**

### 正确解决方案（非降级）

1. **保持 targetSdkVersion 为 6.0.0(20)**
   - 使用最新特性，保持代码先进性
   - 通过兼容性代码支持低版本设备

2. **更新设备镜像版本**（推荐方案）
   ```bash
   # 查询设备镜像版本
   hdc shell param get const.ohos.apiversion
   
   # 如果镜像版本较低，更新到最新版本
   # 注意：如果镜像版本为10，且应用使用的SDK版本也为10，仍出现该报错，
   # 可能是由于镜像版本较低，未兼容新版本SDK校验规则，请将镜像版本更新为最新版本
   ```

3. **代码层面兼容性处理**
   - 使用 `ApiVersionUtils` 进行运行时版本检测
   - 对API 20特性进行条件判断和降级处理
   - 示例：MapView事件监听、智感握姿功能等

### 错误做法（避免）

❌ **不要降级 targetSdkVersion**
- 降级到 `5.0.0(17)` 会失去API 20的新特性
- 无法使用最新的API和优化
- 不符合"兼容低版本"的目标

### 兼容性配置说明

**build-profile.json5 配置**：
```json5
{
  "targetSdkVersion": "6.0.0(20)",      // ✅ 保持最新
  "compatibleSdkVersion": "6.0.0(20)"  // 兼容版本（通常与targetSdkVersion相同）
}
```

**注意**：`compatibleSdkVersion` 的格式需要与已安装的SDK版本匹配。如果设备镜像版本过低，优先更新设备镜像版本，而不是修改SDK版本配置。

---

## 🔗 相关资源

- HarmonyOS 版本发布说明：查看各版本的系统架构变更
- Kit 模块版本兼容性：确认各 Kit 的最低 API 要求
- 官方迁移指南：查看从 API 17 到 API 20 的迁移文档
- 设备镜像版本查询：`hdc shell param get const.ohos.apiversion`

