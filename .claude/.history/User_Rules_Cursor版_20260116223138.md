# HarmonyOS NEXT API 20 开发与规则红线 (Cursor 版)

> **用途**: 复制到 Cursor Settings → Rules and Commands → User Rules  
> **最后更新**: 2026-01-16  
> **核心目标**: ArkTS 严苛模式零报错、设置项 100% 持久化、文档知识不丢失

---

## 📋 需求转译（复杂需求强制执行）

收到复杂/模糊需求后，先进行**技术转译**并确认：

```
需求理解：[要点列表]
技术映射：涉及文件/模块/API
实现思路：[1-2句话]
风险提示：[如有则列出]
```

**规则**: 复杂需求必须确认后执行 | 简单操作可跳过直接执行

---

## Ⅰ. 工程红线

### 3-Strike 规则
同一问题尝试3次失败 → **停止** → 写入 `当前问题.md` → 告知用户找专家(CodeGenie)

### 禁止操作
- ❌ 不执行构建命令 → 告知用户"请在DevEco Studio中Build"
- ❌ 不修改 `backup/` 目录
- ❌ 不删除知识库已验证内容
- ❌ 不重写已稳定的核心逻辑（EntryAbility初始化链路、SettingsPreferences等）

### 资源管理（强制try-finally）
```typescript
// 标准释放模式 - 按创建相反顺序释放
let imageSource: image.ImageSource | null = null
let pixelMap: image.PixelMap | null = null
try {
  imageSource = image.createImageSource(fd)
  pixelMap = await imageSource.createPixelMap()
  // 业务逻辑
} finally {
  pixelMap?.release()
  imageSource?.release()
  fileIo.closeSync(fd)
}
```

- **批量限流**: 批量图片操作并发数 ≤ 3张，避免内存溢出
- **失败重试**: 单项操作重试 ≤ 3次

### 知识库管理
- 已验证方案 → `知识库.md`（用户说"构建成功/登记吧"后才能写入）
- 待验证方案 → `知识库_中转站.md`
- 只追加不删除（除非明确过时）

---

## Ⅱ. ArkTS 严苛模式语法

### 静态方法约束
- **禁止this**: 静态方法中必须用 `ClassName.staticMember`，禁止 `this.staticMember`

### 对象与数组操作
- **禁止展开运算符**: 严禁 `{...obj}` 或 `[...arr]`
- **对象更新**: 显式创建 `const newObj: T = { a: old.a, b: old.b }`
- **数组复制**: `const newArr: T[] = []; for (let i = 0; i < old.length; i++) { newArr.push(old[i]) }`

### 类型安全
- **禁止 any/unknown**: 必须显式声明类型
- **禁止对象字面量类型**: 不能 `Promise<{a: string}>`，必须先定义 interface
- **类型断言**: 统一用 `value as Type`，禁止 `<Type>value`

### UI 组件限制
- **ListItem扁平化**: ListItem 内部禁止嵌套另一个 ListItem
- **Refresh限制**: 只能有一个子组件
- **@Builder参数**: 必须显式传参 `@Builder MyTab(index: number)`，禁止无参

### 杂项规范
- **catch子句**: 写 `catch (error)`，禁止 `catch (error: Error)`
- **AppStorage**: 全局对象，无需import
- **变量初始化**: Class属性必须在声明时或构造函数内初始化
- **declare module**: 内部类型必须 `export interface`

---

## Ⅲ. 设置持久化原则

### 存储选型
- **核心设置禁用 PersistentStorage** → 使用 `Preferences` 存储

### 状态驱动同步
- Preferences → AppStorage 变量 → UI刷新
- 外观模式：EntryAbility初始化后立即调用 `applicationContext.setColorMode()`

### 持久化5步验证清单
每次修改持久化代码后必须检查：
```
✓ 写入Preferences成功（无异常）
✓ 同步更新AppStorage对应变量
✓ UI立即响应变化
✓ 调用系统API应用配置
✓ 冷启动验证（杀进程重启后配置仍生效）
```

---

## Ⅳ. API 20 废弃替代

| 废弃用法 | 替代方案 |
|---------|---------|
| `getContext(this)` | `this.getUIContext().getHostContext()` |
| `animateTo` | `this.getUIContext().animateTo()` |
| `promptAction.*` | `this.getUIContext().getPromptAction().*` |
| `router.*` | `this.getUIContext().getRouter().*` |
| `PhotoViewPicker` | 使用新版API |
| 手动拼接URI | `fileUri.getUriFromPath(path)` |
| `fileIo.statSync(uri)` | `fileIo.statSync(fd)` (媒体库URI) |
| `WRITE_IMAGEVIDEO` | `showAssetsCreationDialog` |

---

## Ⅴ. 文档整理与保护

### 🚨 文档整理硬规则
1. **先转移**: 内容完整转移到目标文件
2. **后确认**: 读取目标文件确认写入成功
3. **再删除**: 确认后方可删除原内容

**禁止**: ❌未转移就删除 | ❌转移未确认就删除 | ❌一次性删大量内容

### 文档健康度检测
| 文件 | 阈值 |
|------|------|
| 知识库.md | > 500行 |
| 知识库_中转站.md | > 300行 |
| 当前问题.md | > 100行 |
| CLAUDE.md | > 600行 |

超过阈值时询问："检测到 [文件名] 已达到 [行数] 行，建议整理。是否现在整理？"

---

## Ⅵ. 避坑清单（高频问题）

- ❌ SaveButton API 不存在
- ⚠️ Refresh 指示器无法隐藏
- ⚠️ Sheet中调ShareController → 先关Sheet + 100ms延迟
- ⚠️ 只设 isStatusBarLightIcon → 字体灰色（必须同时设 statusBarContentColor）
- ⚠️ Native/.d.ts 修改后报旧错 → 删 `entry\build` + Rebuild
- ⚠️ desiredSize + desiredRegion 不兼容 → 两步法：先裁切再 scale()
- ⚠️ bindSheet 多个绑定同一组件会冲突 → 独立空容器绑定

---

## Ⅶ. 深度推理框架（复杂问题启用）

**触发条件**: 多模块交互 / 多方案权衡 / 需求模糊 / 架构设计

### 三步流程
1. **拆解**: 已知 vs 未知 vs 潜在需求 → 核心问题一句话
2. **解构**: ≥3方案 + 可行性 + 约束边界
3. **重组**: 优先级排序 → 推荐方案 + 风险预案

### 简化版输出
```
问题: [一句话]
方案A/B/C: [各一句话]
推荐: [方案X] 因为 [理由]
风险: [应对]
```

### 与现有规则配合
- 已验证方案 → 知识库.md
- 待验证方案 → 知识库_中转站.md
- 3次未解决 → 3-Strike规则 → 当前问题.md

---

## Ⅷ. 专家咨询规范

**整理问题给专家时，开头必须说明环境**:

```markdown
## 🔴 环境说明（重要！）

| 项目 | 版本 |
|------|------|
| 开发工具 | DevEco Studio 6.0.0 |
| 目标平台 | HarmonyOS NEXT |
| API 版本 | API 20（最新版） |
| 语言 | ArkTS（不是 Java/Kotlin） |
```

**原因**: 不同API版本接口差异大，不说明环境会导致专家给出旧版/错误的API

---

## 📁 快速定位

| 需要... | 查看文件 |
|---------|----------|
| 项目状态 | `.claude/CLAUDE.md` |
| 已验证方案 | `.claude/知识库.md` |
| 待验证方案 | `.claude/知识库_中转站.md` |
| 问题追踪 | `.claude/当前问题.md` |
| EXIF解析 | `entry/src/main/ets/services/ExifParserService.ets` |
| Native C++ | `entry/src/main/cpp/` |

---

**技术栈**: DevEco 6.0 + HarmonyOS NEXT API 20 + ArkTS + Native C++
