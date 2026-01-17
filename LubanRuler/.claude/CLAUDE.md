# 鲁班尺 (LubanRuler) - 项目指引文档

> **文档类型**: 项目级 CLAUDE.md  
> **最近更新**: 2025-12-05 00:46 (北京时间) - 四行尺子对齐问题调试中

---

## 项目概述

**鲁班尺** - 传统中国风水测量工具的数字化应用

- **应用 ID**: com.eric.LubanRuler
- **平台**: HarmonyOS NEXT (API 20)
- **语言**: ArkTS
- **构建工具**: Hvigor + ohpm
- **当前版本**: v1.0.0
- **开发状态**: 开发中
- **屏幕方向**: 仅横屏 (landscape)

### 核心功能
- 📏 鲁班尺测量 (1尺=42.9cm, 8大格32小格)
- 📐 丁兰尺测量 (1尺=38.78cm, 10大格40小格)
- 🔄 厘米/英寸双单位支持
- 📖 吉凶含义展示 (点击弹窗显示)

---

## 项目结构速查

```
LubanRuler/
├── .claude/
│   └── CLAUDE.md              # 📋 本文件 - 项目指引
├── AppScope/
│   ├── app.json5              # 应用配置 (bundleName, icon)
│   └── resources/base/element/
│       └── string.json        # 应用名称: "鲁班尺"
├── entry/
│   └── src/main/
│       ├── ets/
│       │   ├── entryability/
│       │   │   └── EntryAbility.ets    # 入口能力 (沉浸式状态栏)
│       │   ├── model/
│       │   │   └── LubanCalculator.ets # 核心计算引擎
│       │   └── pages/
│       │       └── Index.ets           # 主页面 (尺子UI)
│       ├── module.json5       # 模块配置 (横屏锁定)
│       └── resources/
├── build-profile.json5        # 构建配置 (SDK 6.0.0/API 20)
└── oh-package.json5           # 依赖配置
```

### 关键文件说明

| 文件 | 作用 | 要点 |
|------|------|------|
| `LubanCalculator.ets` | 鲁班尺/丁兰尺计算逻辑 | 静态方法使用 `LubanCalculator.` 而非 `this.` |
| `Index.ets` | 主界面UI | 横屏布局: 工具栏+左侧结果面板+尺子区域 |
| `EntryAbility.ets` | 应用入口 | 沉浸式全屏 + 状态栏颜色配置 |
| `module.json5` | 模块配置 | `"orientation": "landscape"` 锁定横屏 |

---

## 开发环境

### 工具链版本
- **DevEco Studio**: 6.0.0+
- **HarmonyOS SDK**: 6.0.0(20) / API 20
- **Node.js**: 通过 DevEco Studio 内置
- **ohpm**: 内置版本

### 构建命令
```powershell
# 安装依赖
ohpm install

# 构建 HAP
hvigorw assembleHap

# 清理构建
hvigorw clean
```

---

## 项目进展追踪

### 最近更新
**2025-12-05 00:46 (北京时间)** - 四行尺子对齐问题调试中

### 已完成功能 ✅

#### 基础架构
- [x] 项目初始化 (bundleName: com.eric.LubanRuler)
- [x] 横屏模式锁定 (module.json5 orientation)
- [x] 沉浸式状态栏 (红色主题 #D4380D)

#### 核心功能
- [x] 鲁班尺计算引擎 (8格: 财病离义官劫害本)
- [x] 丁兰尺计算引擎 (10格: 丁害旺苦义官死兴失财)
- [x] 厘米/英寸单位换算

#### UI 实现
- [x] 主界面布局 (工具栏+结果面板+尺子区域)
- [x] 尺子滚动交互
- [x] 吉凶结果弹窗

#### Bug 修复
- [x] ArkTS 语法修复 (静态方法不能用 this)
- [x] 箭头函数返回类型声明 (: void)
- [x] onScroll → onDidScroll API 更新
- [x] 尺子零点对齐 (左侦50%空白)
- [x] 横屏安全距离优化 (基于 CodeGenie 指导)
  - 左侧面板 padding: 24 → 48vp
  - 工具栏左右边距: 60 → 48vp (对称补偿)
  - 面板宽度: 160 → 180 (适应更大 padding)
- [x] 添加窗口尺寸变化监听 (windowSizeChange)
- [x] 刻度对齐修复 (统一使用毫米基准计算宽度)

#### UI 优化 (2025-12-04)
- [x] 顶部输入框居中 + 加减按钮 (adjustValue)
- [x] 尺子左侧空白区域改为木纹图片 (texture_wood.png)
- [x] 摄像头安全区域处理 (safeAreaLeft + window.AvoidAreaType.TYPE_CUTOUT)
- [x] 输入框与滚动位置同步 (inputText 双向绑定)

### 进行中功能 🔄
- [ ] **四行尺子对齐问题** - 公尺/鲁班尺/丁兰尺/英尺的 X 坐标不一致
  - 已确认问题：DevEco Inspector 显示四行 Image 的 X 坐标分别为 630/604/415/434 px
  - 原因：组件布局方案中各行 ForEach 生成的元素宽度累加不一致
  - 当前方案：统一左侧填充为 Column + 添加 onAreaChange 日志调试

### 待开发功能 📋
- [ ] 应用图标设计与集成
- [ ] 启动页设计
- [ ] 收藏/历史记录功能

### 已知问题 ⚠️

#### 🔴 四行尺子对齐偏移 (2025-12-05)
**问题描述**: 指示线指向公尺刻度"10"时，左侧面板显示 9.34cm（偏移约 6.6mm）
- **现象**: 丁兰尺对齐正确，公尺/鲁班尺/英尺均有偏移
- **设备参数**: vpPerMm=6.2715, densityPixels=2.75, safeAreaLeft=50.06vp
- **根本原因**: 组件布局方案中 ForEach 循环次数和元素宽度不同，导致各行总宽度累积误差
- **解决进度**: 正在调试混合方案（组件+Canvas局部优化）

---

## ⚠️ AI 错误登记

### 2025-12-05: 代码重建时丢失 Canvas 方案
**错误描述**: 
- 原本项目使用 Canvas 绘制尺子刻度，在代码被破坏后重建时，AI 错误地改为组件布局方案（ForEach 循环生成大量组件）
- 组件方案导致 13000+ 个组件，且各行宽度累积误差导致对齐问题

**影响**:
- 四行尺子的 X 坐标不一致（最大差异 215px）
- 同一毫米数在不同尺子上的视觉位置不对齐
- 性能问题：组件数量过多

**后续措施**:
- 考虑恢复 Canvas 绘制方案
- 或采用混合方案：组件结构 + Canvas 局部绘制刻度线

---

## 技术要点

### 0. 物理精度计算 (最关键!)
HarmonyOS 使用 vp (虚拟像素) 而非 px，必须通过 densityPixels 转换：
```typescript
// 正确公式 - Index.ets
const pxPerMm = physicalDpi / 25.4
this.vpPerMm = (pxPerMm / this.densityPixels) * this.calibrationFactor

// 获取屏幕参数
const displayInfo = display.getDefaultDisplaySync()
this.densityPixels = displayInfo.densityPixels  // 通常 2.75
```

### 1. ArkTS 静态方法规范
```typescript
// ❌ 错误 - 静态方法不能用 this
static calculate(): Result {
  return this.helper();  // 编译错误
}

// ✅ 正确 - 使用类名
static calculate(): Result {
  return LubanCalculator.helper();
}
```

### 2. 横屏模式安全距离 (⚠️ 基于 CodeGenie 指导)
横屏时状态栏/摄像头挖孔区在**左侧**，需要：
```typescript
// 左侧面板添加左边距 (48vp 避让区域)
.padding({ left: 48, right: 8 })

// 工具栏图标左右对称 (48vp)
.margin({ left: 48 })   // 左侧
.margin({ right: 48 })  // 右侧对称补偿

// 窗口尺寸变化监听
mainWindow.on('windowSizeChange', (size: window.Size) => {
  this.winWidth = size.width
  this.winHeight = size.height
})
```

### 3. 鲁班尺核心常量
```typescript
const CM_PER_LUBAN = 42.9;   // 1鲁班尺 = 42.9cm
const CM_PER_DINGLAN = 38.78; // 1丁兰尺 = 38.78cm
const CM_PER_INCH = 2.54;     // 1英寸 = 2.54cm

// 鲁班尺8格
const LUBAN_DIVISIONS = ['财', '病', '离', '义', '官', '劫', '害', '本'];

// 丁兰尺10格  
const DINGLAN_DIVISIONS = ['丁', '害', '旺', '苦', '义', '官', '死', '兴', '失', '财'];
```

---

## 开发约定

### 代码规范
- **导出方式**: `export { ClassName }` (禁止 export default)
- **装饰器**: 页面必须有 `@Entry` + `@Component`
- **样式**: 链式调用 `.width(100).height(50)`
- **布局**: 使用 `Column/Row/Stack` (禁止 div/flex)

### Git 规范
- **分支**: `main` (主分支), `feature/*` (功能分支)
- **提交**: 中文描述，简洁明了

---

## 横屏 UI 适配规范 (来源: CodeGenie)

> 以下规范来自 CodeGenie AI 建议，适用于本项目的固定横屏场景

### 1. 布局与适配核心原则

#### 宽高比适配
横屏宽高比通常为 16:9 或 21:9，使用百分比布局：
```typescript
// ✅ 使用百分比布局避免固定尺寸
Row() {
  Image($r('app.media.banner'))
    .width('100%')
    .aspectRatio(2.4)  // 按比例控制高度
}
```

#### 多列布局优化
```typescript
// 利用横屏宽度优势实现多内容并列
GridRow() {
  GridCol({ span: { xs: 12, sm: 6, md: 4 } })  // 横屏下显示4列
}
```

### 2. 避让区域处理 (⚠️ 重点)

| 区域类型 | 处理方案 | 本项目场景 |
|---------|---------|-----------|
| **左侧摄像头挖孔区** | 左侧预留 48vp 安全区域 | 左侧结果面板 |
| 折叠屏铰链区 | 弹性布局自动避让 | 暂不考虑 |
| 系统手势操作区 | 底部保留 48vp | 底部工具栏 |

#### 左侧挖孔区特殊处理
```typescript
// 横屏模式下左侧挖孔区需特殊处理
// 关键操作按钮/文本应避开屏幕左边缘至少 48vp
.padding({ left: 48 })

// 滚动区域设置左内边距
Scroll() { ... }
  .padding({ left: 48 })
```

#### 沉浸式布局安全区设置
```typescript
windowClass.setWindowLayoutFullScreen(true)
  .setSystemBarEnable(['status', 'navigation'])
  .setWindowLayoutSafetyArea({ left: 24, right: 24 })
```

### 3. 交互设计优化

#### 操作热区定位
- ✅ 高频操作按钮集中在屏幕**右侧** (符合右手操作习惯)
- ✅ 滑动操作轨迹**水平方向**优先

#### 左侧边缘手势调整
```typescript
// 左侧边缘滑动操作手势识别区域缩进 32vp
// 长按操作持续时间建议 500ms
Gesture({ direction: GestureDirection.Horizontal })
  .onActionStart(() => { /* 显示滑动指示器 */ })
```

### 4. 视觉平衡原则

- **左侧挖孔区对称补偿**: 右侧对应区域保留等宽空白
- **非对称布局时**: 核心内容偏向屏幕中央

### 5. 性能优化建议

- 布局嵌套深度不超过 **3层**
- 使用 `@Extend` 封装公共样式
- 复杂场景考虑 `<Canvas>` 自定义绘制

### 6. 窗口变化监听 (即使固定横屏)
```typescript
on('windowSizeChange', (data) => {
  this.winWidth = data.width
  // 重新计算安全区域
})
```

---

## 参考资源

### iOS 参考应用
- 用户提供了 iOS 鲁班尺应用截图作为 UI 参考
- 布局: 横屏 + 左侧结果面板 + 右侧双尺子滚动

### CodeGenie 设计指导
- 详细文档: `figma/日志.md`
- 包含横屏适配、避让区域、交互设计等规范

### 相关文档
- [HarmonyOS 官方文档](https://developer.harmonyos.com/)
- [ArkTS 语法规范](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/)

---

## 🤖 AI 工作流程规范

### 每次对话开始
1. ✅ 读取本文件确认项目状态
2. ✅ 确认最近完成的功能
3. ✅ 确认当前待办事项

### 完成任务后
1. ✅ 立即更新"项目进展追踪"
2. ✅ 更新"最近更新"时间戳 (询问用户北京时间)
3. ✅ 告知用户: "已更新项目进展"

---

**文档维护者**: AI 助手  
**项目负责人**: Eric
