# HarmonyOS 花粉浓度播报项目 - TRAE_CN 项目规则

## 🎯 核心规则

### 1. 代码规范

#### ArkTS 语法规范
- ✅ 使用 `export { ClassName }` (禁止 `export default`)
- ✅ 使用 `Column/Row/Stack/Flex` (禁止 div/flex 等 Web 标签)
- ✅ 使用 `onDidScroll` (onScroll 已废弃)
- ✅ 组件命名: PascalCase
- ✅ 文件命名: PascalCase.ets
- ❌ **禁止使用 `any` 类型** - ArkTS 严格模式不允许

#### 组件装饰器
- ✅ 页面组件必须使用 `@Component + @Entry` 装饰器
- ✅ 普通组件使用 `@Component` 装饰器

#### 样式规范
- ✅ 使用链式样式 `.width(100).height(50)` 而非对象式
- ✅ 避免过多内联样式，使用常量或主题

### 2. ⚠️ ArkUI 常见陷阱（重要！）

| 错误用法 | 正确用法 | 说明 |
|---------|---------|------|
| `Row().wrap(true)` | `Flex({ wrap: FlexWrap.Wrap })` | Row 不支持换行，用 Flex |
| `as any` | 明确类型 | ArkTS 禁止 any 类型 |
| `onScroll()` | `onDidScroll()` | onScroll 已废弃 |
| `animateTo()` | 使用 `.animation()` 属性 | animateTo 已废弃 |
| `px2vp()` | `value / display.densityPixels` | px2vp 已废弃，需手动计算 |
| ForEach 直接加样式 | 包裹在 Row/Column 中 | ForEach 返回的是数组 |
| `AlertDialog.show()` | `this.getUIContext().getPromptAction().showDialog()` | **API 20 静态方法已废弃** |
| `promptAction.showDialog()` | `this.getUIContext().getPromptAction().showDialog()` | **必须通过 UIContext 调用** |
| `router.pushUrl()` | `this.getUIContext().getRouter().pushUrl()` | **必须通过 UIContext 调用** |
| `getContext(this)` | `this.getUIContext().getHostContext()` | **getContext 已废弃** |
| `DialogAlignment` | `DialogAlignmentEx` | **从 @ohos.promptAction 导入** |
| `confirm/cancel` 参数 | `buttons[]` 数组 | **按钮改为数组，用 result.index 判断** |

### 3. 布局组件选择指南

| 需求 | 推荐组件 |
|------|---------|
| 垂直排列 | `Column` |
| 水平排列（不换行） | `Row` |
| 水平排列（需要换行） | `Flex({ wrap: FlexWrap.Wrap })` |
| 层叠布局 | `Stack` |
| 网格布局 | `Grid` + `GridItem` |
| 列表滚动 | `List` + `ListItem` |

### 4. 项目结构

```
PollenForecast/
├── entry/src/main/ets/
│   ├── entryability/  # 入口Ability
│   ├── pages/         # 页面
│   ├── views/         # 视图组件
│   ├── viewmodel/     # 视图模型
│   ├── model/         # 数据模型
│   ├── service/       # 服务层
│   └── utils/         # 工具类
```

### 5. API 配置

**AWS Lambda + API Gateway：**
```
https://iigtw47lrd.execute-api.ap-southeast-1.amazonaws.com/default/pollen-api?lat=23.12&lng=113.26&days=5
```

**Google Pollen API Key：**
```
AIzaSyCqWhX-k3H5kONC2WV3DtcIs8PtkwdmMH8
```

### 6. 开发流程

1. **开始工作前**: 必须先读取 `.claude/CLAUDE.md` 确认项目状态
2. **代码修改前**: 确认要使用的 API 在 ArkUI 中存在
3. **代码修改**: 理解全局再修改，一次只改一个问题
4. **完成任务后**: 更新 `.claude/CLAUDE.md` 的项目进展追踪

### 7. 与 GitHub Copilot 协作

- **TRAE_CN 负责**: UI 组件开发、代码格式化、简单功能实现
- **GitHub Copilot 负责**: 复杂逻辑、API 集成、跨模块问题、架构设计
- **遇到编译错误**: 把构建日志发给 GitHub Copilot 处理

## 🎨 UI设计规范

### 主题色板
- 主色调: `#4CAF50` (健康绿)
- 低风险: `#E8F5E9` (浅绿背景)
- 中风险: `#FFF3E0` (浅橙背景)
- 高风险: `#FFEBEE` (浅红背景)
- 极高风险: `#F44336` (红色警告)

---

**遵循规范，高效开发！** 🎉