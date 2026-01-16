---
trigger: always_on
---
# User Rules 建议内容

> **用途**: 复制到 Cursor Settings → Rules and Commands → User Rules  
> **最后更新**: 2026-01-08

---

## HarmonyOS NEXT API 20 开发规范

### 知识库管理
- 已验证方案 → 写入 知识库.md
- 待验证方案 → 写入 知识库_中转站.md
- 只追加不删除（除非明确过时）
- 用户确认"构建成功/登记吧"后才能更新

### 3-Strike 规则
同一问题尝试3次失败后：停止 → 写入当前问题.md → 告知用户问CodeGenie

### 禁止操作
- 不执行构建命令
- 不删除知识库已验证内容
- 不在 backup/ 目录修改文件

### 🚨 文档整理硬规则（必须遵守）
**核心原则**：先转移，确认成功后再删除

**整理流程**：
1. 第一步：转移内容到对应文件（开发日志.md、知识库/分类文件.md、问题记录.md）
2. 第二步：确认转移成功（检查目标文件存在且内容完整）
3. 第三步：删除原内容（只有确认转移成功后才能删除，保留链接）

**禁止操作**：
- ❌ 禁止未转移就删除
- ❌ 禁止转移未确认就删除
- ❌ 禁止一次性删除大量内容而不验证

### ArkTS 致命语法
- catch子句禁止类型注解：catch (error) 不是 catch (error: Error)
- AppStorage无需导入：直接用全局对象
- @Builder必须参数传递：@Builder Tab(safeBottom: number) 不是 @Builder Tab()
- declare module内类型必须 export interface
- **展开运算符禁止**：禁止使用 `{...obj}` 和 `[...arr]`，必须显式创建对象/数组
- **对象字面量类型禁止**：不能使用 `Promise<{a: string}>`，必须定义接口
- **嵌套 ListItem 禁止**：ListItem 内部不能嵌套另一个 ListItem，必须扁平化
- **Refresh 组件限制**：Refresh 只能有一个子组件

### API 20 废弃替代
- getContext(this) → this.getUIContext().getHostContext()
- animateTo → this.getUIContext().animateTo()
- promptAction.* → this.getUIContext().getPromptAction().*
- router.* → this.getUIContext().getRouter().*

### 文件操作
- 媒体库URI：fileIo.statSync(fd) 不是 statSync(uri)
- URI格式：用 fileUri.getUriFromPath(path) 不是手动拼接
- WRITE_IMAGEVIDEO 普通应用不可用，用 showAssetsCreationDialog 替代

### 资源必须释放
imageSource.release() / pixelMap.release() / packer.release() / fileIo.closeSync(file)

### 已验证错误方案（避坑）
- SaveButton API不存在
- Refresh指示器无法隐藏
- Sheet中直接调ShareController会失效（需先关Sheet+100ms延迟）
- 只设置isStatusBarLightIcon会导致字体灰色（必须同时设statusBarContentColor）

### ArkTS 语法限制详细规则
**展开运算符替代方案**：
- 对象复制：`const newObj: Type = { name: old.name, ... }` 显式列出所有字段
- 数组复制：`const newArr: Type[] = []; for (let i = 0; i < old.length; i++) { newArr.push(old[i]) }`
- 对象更新：不能 `{...obj, key: value}`，必须显式创建新对象

**ListItem 扁平化规则**：
- 错误：`ListItem() { ForEach(cities, (c) => ListItem() {...}) }` 
- 正确：`ListItem() { 标题 }` 然后 `ForEach(cities, (c) => ListItem() {...})` 作为同级

### 缓存问题
修改Native/.d.ts后报旧错误：删除 entry\build 再 Rebuild

---

## 📋 文档健康度检测

**规则**：读取指导文档时，如果发现文档行数过多，询问用户是否需要整理。

**阈值参考**：
- 知识库.md > 500行 → 建议整理
- 知识库_中转站.md > 300行 → 建议整理
- 当前问题.md > 100行 → 建议整理
- CLAUDE.md > 600行 → 建议整理
- 问题记录.md > 200行 → 建议整理

**询问方式**："检测到 [文件名] 已达到 [行数] 行，建议整理。是否现在整理？"

