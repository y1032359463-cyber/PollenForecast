# DevEco Testing 图标检测问题咨询

## 基本信息
- **应用名称**: TimeTracker（工时计）
- **包名**: com.eric.TimeTracker
- **DevEco Studio版本**: 5.0.5.315
- **API版本**: 12 (HarmonyOS NEXT)
- **检测工具**: DevEco Testing - UX基础质量测试
- **问题类型**: 视觉规格 - 应用图标配置

---

## 问题描述

**测试项**: 应用图标具备前景层和背景层，图标尺寸与可见度尺寸满足要求  
**检测结果**: ❌ 不通过  
**错误信息**: "应用未配置圆角矩形图标的前景图和后景图，标准要求尺寸1024px*1024px且目前尺寸1024px*1024px，但未进行图标再处理"

---

## 当前配置详情

### 1. 图标资源配置

#### AppScope 模块 (`AppScope/resources/base/media/`)
```
├── app_icon.png         1024×1024px ✅
├── foreground.png       1024×1024px ✅
├── background.png       1024×1024px ✅
├── startIcon.png        1024×1024px ✅
└── layered_image.json   ✅
```

**layered_image.json 内容**:
```json
{
  "layered-image": {
    "background": "$media:background",
    "foreground": "$media:foreground"
  }
}
```

#### entry 模块 (`entry/src/main/resources/base/media/`)
```
├── foreground.png       1024×1024px ✅
├── background.png       1024×1024px ✅
├── startIcon.png        1024×1024px ✅
└── layered_image.json   ✅
```

### 2. 配置文件引用

#### app.json5 (AppScope/)
```json5
{
  "app": {
    "bundleName": "com.eric.TimeTracker",
    "icon": "$media:layered_image",  // ✅ 引用自适应图标
    "label": "$string:app_name",
    "minAPIVersion": 12,
    "targetAPIVersion": 12
  }
}
```

#### module.json5 (entry/src/main/)
```json5
{
  "module": {
    "abilities": [
      {
        "name": "EntryAbility",
        "icon": "$media:layered_image",        // ✅
        "startWindowIcon": "$media:layered_image"  // ✅
      }
    ]
  }
}
```

---

## 已尝试的解决方案

### 尝试1: 升级图标尺寸
- ❌ 将 foreground.png 和 background.png 从 432×432 升级到 1024×1024
- **结果**: 仍然检测失败

### 尝试2: 配置 layered_image.json
- ❌ 创建标准的 layered-image 配置文件
- ❌ 在 app.json5 和 module.json5 中引用 `$media:layered_image`
- **结果**: 仍然检测失败

### 尝试3: 同步 entry 模块资源
- ❌ 将 AppScope 的图标同步到 entry/src/main/resources/base/media/
- ❌ 确保两个模块的图标尺寸一致
- **结果**: 仍然检测失败

### 尝试4: 添加 startIcon.png
- ❌ 复制 app_icon.png 为 startIcon.png (1024×1024)
- **结果**: 仍然检测失败

---

## 疑问

### 问题1: layered_image.json 格式是否正确？
是否需要特殊的 JSON 结构或额外的元数据？

### 问题2: 是否需要使用 Image Asset 工具生成？
错误信息提到"未进行图标再处理"，是否必须通过 DevEco Studio 的 Image Asset 工具生成图标？
- 如果是，工具的正确使用步骤是什么？

### 问题3: 资源目录结构是否正确？
- 是否需要在所有密度目录（ldpi/mdpi/xldpi等）都放置图标？
- 还是只需要 base 目录？

### 问题4: 是否需要额外的配置文件？
- 是否需要在 module.json5 中添加 iconType 或其他元数据？
- 是否需要特殊的资源索引文件？

### 问题5: 检测工具的具体检查逻辑？
DevEco Testing 检测自适应图标时，具体检查哪些内容？
- 文件命名规则？
- JSON 格式规范？
- 资源引用方式？

---

## 参考标准

**华为官方文档**: [通用应用 UX 体验标准 - 2.1.4.3.1 应用图标](https://developer.huawei.com/consumer/cn/doc/design-guides/ux-guidelines-general-0000001760708152)

**标准要求**:
> 应用图标资源必须分为前景图和背景图两层，尺寸要求必须为 1024 px * 1024 px，资源不允许自行裁切圆角，不允许在资源内添加内间距。

---

## 附件

### 图标文件截图
- foreground.png: 1024×1024px PNG（透明背景，时钟图标）
- background.png: 1024×1024px PNG（蓝色渐变背景）

### DevEco Testing 测试报告
- 测试类型: UX基础质量测试
- 测试项: 视觉规格 - 应用图标
- 测试时间: 2025-11-22
- 测试结果: 不通过（0%）

---

## 期望解答

1. **配置步骤**: 正确配置自适应图标的完整步骤（包括工具使用）
2. **检查清单**: DevEco Testing 检测自适应图标的完整检查项
3. **示例代码**: 能通过检测的标准配置示例
4. **常见错误**: 类似问题的典型原因和解决方案

---

**联系方式**: [填写你的联系方式]  
**紧急程度**: 高（准备应用上架）
