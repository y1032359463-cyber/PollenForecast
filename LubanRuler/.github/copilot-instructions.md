# 鲁班尺 (LubanRuler) - AI Coding Agent 指引

> **最后更新**: 2025-12-05 (北京时间)

---

## 🔴 AI 强制工作流程

### 开始工作前
1. **必须先读取** `.claude/CLAUDE.md` 确认项目状态
2. **确认理解**: 最近完成的功能、当前待办事项、已知问题
3. **不依赖对话历史** - 每次都要重新读取项目状态

### 代码修改原则
- ✅ **理解全局再修改** - 先读完整个 build() 函数或相关代码块
- ✅ **一次只改一个问题** - 避免连锁错误
- ✅ 批量操作使用 `multi_replace_string_in_file`
- ❌ **禁止重复修复已解决的问题** - 先确认问题是否真的存在
- ❌ 禁止凭假设修改 - 先用截图/日志确认实际状态

### 完成任务后
1. 更新 `.claude/CLAUDE.md` 的"项目进展追踪"
2. 询问用户当前北京时间并更新时间戳

---

## 项目概览

HarmonyOS NEXT 鲁班尺风水测量应用，实现物理精确的传统中国尺度测量。

- **平台**: HarmonyOS NEXT SDK 6.0.0 / API 20
- **语言**: ArkTS
- **屏幕**: 仅横屏 (`"orientation": "landscape"`)
- **核心**: 物理毫米精度的四行尺子同步滚动

### 文件结构
```
entry/src/main/ets/
├── entryability/EntryAbility.ets  # 入口：沉浸式全屏+状态栏
├── model/LubanCalculator.ets      # 计算引擎：尺度转换+吉凶判断
└── pages/Index.ets                # 主界面：四行尺子UI（核心文件）
```

---

## 核心技术要点

### 1. 物理精度计算 (最关键!)
```typescript
// vp 转换公式 - Index.ets
const pxPerMm = physicalDpi / 25.4
this.vpPerMm = (pxPerMm / this.densityPixels) * this.calibrationFactor
// densityPixels 通常为 2.75
```

### 2. 布局层级结构 (Index.ets build())
```
Stack {
  // 底层：背景色块延伸 + 背景图
  Row {
    Column { 左侧色块(safeAreaLeft宽) }  // 顶部栏/公尺/鲁班/丁兰/英尺色块
    Column { 顶部栏红色 + 背景图(texture_wood/paper) }
  }
  // 主内容层
  Column {
    TopBar()
    Row {
      LeftPanel()      // 测量结果显示
      Stack {
        Scroll { Row { 大吉图片 + 四行尺子 }.border() }
        指示线Column    // position固定在 startImageWidth+1
      }
    }
  }
}
```

### 3. 横屏安全区域
```typescript
@State safeAreaLeft: number = 48  // 默认值，避免预览器中为0
// 实际设备通过 window.AvoidAreaType.TYPE_CUTOUT 获取
```

### 4. 尺子滚动计算
```typescript
// 指示线固定在 startImageWidth+1 位置
// 滚动偏移 0 时显示大吉图片
// 滚动偏移 > startImageWidth+1 时开始测量
onScrollEvent(): void {
  const zeroPointOffset = this.startImageWidth + 1
  const effectiveOffset = offset.xOffset - zeroPointOffset
  this.currentMm = Math.max(0, effectiveOffset / this.vpPerMm)
}
```

---

## ArkTS 语法规范

```typescript
// ❌ 静态方法不能用 this
static calculate(): Result { return this.helper(); }

// ✅ 使用类名
static calculate(): Result { return LubanCalculator.helper(); }
```

- **导出**: `export { ClassName }` (禁止 export default)
- **布局**: `Column/Row/Stack` (禁止 div/flex)
- **滚动**: `onDidScroll` (onScroll 已废弃)

---

## 常见陷阱

| 问题 | 正确做法 |
|-----|---------|
| ForEach 加样式 | 包裹在 Row/Column 中 |
| layoutWeight 异常 | 确保父容器有明确高度 |
| 色块不显示 | 检查 safeAreaLeft 是否为 0 |
| 预览器差异 | 给状态变量设置合理默认值 |

---

## 构建命令
```powershell
ohpm install           # 安装依赖
hvigorw assembleHap    # 构建 HAP
hvigorw clean          # 清理构建
```

## 资源文件
- `resources/base/media/texture_wood.png` - 木纹背景图
- `resources/base/media/texture_paper.png` - 纸张纹理图
- `resources/base/media/app_icon.png` - 大吉图片 (AppScope)
