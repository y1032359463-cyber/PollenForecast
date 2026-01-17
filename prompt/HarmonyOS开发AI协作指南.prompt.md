# HarmonyOS 开发 AI 协作指南（完整版）

> **版本**: 2.0  
> **最后更新**: 2025-12-06  
> **适用项目**: HarmonyOS 应用工厂全系列项目  
> **文件位置**: `c:\HarmonyOS_App_Plans\HarmonyOS开发AI协作指南.md`

---

## 📖 目录

1. [快速开始](#1-快速开始)
2. [核心规则（必读）](#2-核心规则必读)
3. [开发环境配置](#3-开发环境配置)
4. [多模型协作工作流](#4-多模型协作工作流)
5. [ArkTS 编码规范](#5-arkts-编码规范)
6. [Figma 设计落地流程](#6-figma-设计落地流程)
7. [性能优化指南](#7-性能优化指南)
8. [常见问题解决](#8-常见问题解决)
9. [项目管理规范](#9-项目管理规范)
10. [附录：工具与资源](#10-附录工具与资源)

---

## 1. 快速开始

### 1.1 AI 启动检查清单

每次开始工作前，AI 必须完成：

- [ ] 读取 `c:\HarmonyOS_App_Plans\.claude\CLAUDE.md`（工厂总览）
- [ ] 读取目标项目的 `.claude/CLAUDE.md`（项目状态）
- [ ] 确认当前分支：`git branch`
- [ ] 检查未提交的更改：`git status`
- [ ] 不依赖对话历史或摘要

### 1.2 三句话理解本指南

1. **强制规则不能违反**：ArkTS 语法、导出方式、装饰器、API 替换
2. **多模型分工协作**：Claude 架构 + Codex 编码 + Gemini 审查
3. **文档实时更新**：完成任务立即更新 CLAUDE.md

---

## 2. 核心规则（必读）

### 2.1 🔴 代码强制规则（绝对不能违反）

#### 2.1.1 导出语法

```typescript
// ✅ 正确 - 命名导出
export { MyComponent }

// ❌ 错误 - 不支持默认导出
export default MyComponent
```

#### 2.1.2 组件装饰器

```typescript
// ✅ 正确 - 必须有装饰器
@Component
export struct MyComponent {
  build() {
    Text('Hello')
  }
}

// ✅ 入口组件需要 @Entry
@Entry
@Component
export struct MainPage {
  build() {
    Column() {
      Text('Main')
    }
  }
}

// ❌ 错误 - 缺少装饰器
export struct MyComponent {  // 编译错误
  build() {}
}
```

#### 2.1.3 样式写法

```typescript
// ✅ 正确 - 链式调用
Text('Hello')
  .width(100)
  .height(50)
  .backgroundColor('#FF0000')
  .fontSize(16)

// ❌ 错误 - 不支持对象样式
Text('Hello')
  .style({  // 语法错误
    width: 100,
    height: 50
  })
```

#### 2.1.4 布局组件

```typescript
// ✅ 正确 - 使用 ArkUI 组件
Column() {
  Row() {
    Text('Title')
  }
  Stack() {
    Image($r('app.media.icon'))
  }
}

// ❌ 错误 - 不是 HTML
<div>  // 这不是 ArkTS
  <flex>
    <span>Title</span>
  </flex>
</div>
```

#### 2.1.5 图标配置（AppGallery 上架必须）

```json5
// module.json5
{
  "module": {
    "name": "entry",
    "type": "entry",
    // ✅ 正确 - 统一使用 layered_image
    "icon": "$media:layered_image",
    
    // ❌ 错误 - 这些会导致上架失败
    // "icon": "$media:app_icon",
    // "icon": "$media:icon"
  }
}
```

#### 2.1.6 性能优化（关键）

```typescript
// ✅ 正确 - 使用 transform（GPU 合成层）
.transform({ translateY: offset })  // 性能高

// ❌ 错误 - 使用 translate（触发布局重排）
.translate({ y: offset })  // 慢 3-5 倍
```

#### 2.1.7 API 20+ 替换规则

```typescript
// ✅ 路由跳转 - 使用新 API
import { router } from '@kit.ArkUI';
router.replaceNamedRoute({ name: 'PageName' });

// ❌ 已废弃
router.replaceUrl({ url: 'pages/PageName' });

// ✅ 应用退出 - 使用 context
context.terminateSelf();

// ❌ 错误 - 单页应用会黑屏
router.back();
```

### 2.2 文件结构规范

```
ProjectName/
├── entry/
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── entryability/
│   │   │   │   └── EntryAbility.ets
│   │   │   ├── pages/
│   │   │   │   ├── Index.ets          # 入口页面
│   │   │   │   └── SubPage.ets
│   │   │   ├── components/            # 可复用组件
│   │   │   │   └── CustomButton.ets
│   │   │   ├── viewmodel/             # 视图模型
│   │   │   │   └── MainViewModel.ets
│   │   │   └── utils/                 # 工具类
│   │   │       └── DateUtil.ets
│   │   ├── resources/
│   │   │   ├── base/
│   │   │   │   ├── media/             # 图片资源
│   │   │   │   └── profile/
│   │   │   │       └── main_pages.json
│   │   │   └── rawfile/               # 原始文件
│   │   └── module.json5               # 模块配置
│   └── oh-package.json5
├── .claude/
│   └── CLAUDE.md                      # 项目状态文档
├── build-profile.json5
├── hvigorfile.ts
└── oh-package.json5
```

---

## 3. 开发环境配置

### 3.1 全局环境（已确认）

```
DevEco Studio 6.0.1 Beta1
├─ 构建版本: 6.0.1.246 (2025-10-31)
├─ Runtime: OpenJDK 21.0.8+1
├─ Memory: 2048M / Cores: 16
└─ OS: Windows 11.0

HarmonyOS SDK 6.0.0 (API 20)
├─ SDK 路径: C:\Program Files\Huawei\DevEco Studio\sdk
├─ 实际版本: 6.0.0.47 (API 20)
└─ 组件: ets, js, native, toolchains, previewer
```

### 3.2 ⚠️ SDK 路径配置陷阱（AI 常见错误）

```
❌ 错误路径 1: C:\Users\Lenovo\AppData\Local\OpenHarmony\Sdk
   → 这是 ArkUI-X SDK，不是 HarmonyOS SDK

❌ 错误路径 2: C:\Users\Lenovo\AppData\Local\Huawei\Sdk
   → 缺少 HarmonyOS 子目录

✅ 正确路径: C:\Users\Lenovo\AppData\Local\Huawei\Sdk\HarmonyOS
   → 包含 API 版本号子目录（如 20/）

📝 验证方法:
   检查路径下是否有 20/ 目录，内含 toolchains/ets/js/native/previewer

🔧 修复方法:
   在 local.properties 设置:
   sdk.dir=C:\\Users\\Lenovo\\AppData\\Local\\Huawei\\Sdk\\HarmonyOS

💡 最佳实践:
   让 DevEco Studio 自动创建项目，不要手动配置 SDK 路径
```

### 3.3 VS Code 配置

#### settings.json（已恢复）

```json
{
  "github.copilot.chat.localeOverride": "zh-CN",
  "claude-code.useTerminal": true,
  "ets.sdkPath": "c:\\Users\\Lenovo\\AppData\\Local\\OpenHarmony\\Sdk\\20",
  "http.proxy": "http://47.130.102.214:9302",
  "http.proxySupport": "override",
  "http.proxyStrictSsl": false
}
```

### 3.4 项目初始化命令

```powershell
# 进入项目目录
cd c:\HarmonyOS_App_Plans\ProjectName

# 安装依赖
hvigorw --mode module clean

# 构建项目
hvigorw assembleHap --mode module -p module=entry@default

# 查看构建产物
Get-ChildItem build\default\outputs\default\ -Recurse -Filter "*.hap"
```

---

## 4. 多模型协作工作流

### 4.1 三窗口角色分工

| 窗口 | 模型 | 角色 | 主要职责 | 保持状态 |
|------|------|------|----------|----------|
| 窗口 1 | Claude Sonnet 4.5 | 架构师 & 项目记忆 | 读取 CLAUDE.md、分析 Figma、制定任务、更新文档 | ✅ 全程开启 |
| 窗口 2 | GPT-5.1-Codex | 快速编码器 | 生成/修改 ArkTS 代码、重复性任务 | ↺ 按需开启 |
| 窗口 3 | Gemini Pro 2.5 | 质量审查员 | 审查代码、性能优化、边界检查 | ↺ 关键节点开启 |

### 4.2 窗口初始化脚本

#### 窗口 1（Claude - 主控）

```
Follow instructions in HarmonyOS开发AI协作指南.md

我是主控窗口，负责：
1. 架构设计和技术决策
2. 项目状态管理
3. 协调其他模型工作
4. 更新 .claude/CLAUDE.md

请先确认你读取了工作区状态。
```

#### 窗口 2（Codex - 编码）

```
【编码窗口】
项目: [ProjectName]
工作目录: c:\HarmonyOS_App_Plans\[ProjectName]

[粘贴 HarmonyOS_核心规则卡.md 全文]

我负责根据架构指令实现代码，准备就绪。
```

#### 窗口 3（Gemini - 审查）

```
【审查窗口】
项目: [ProjectName]

[粘贴 HarmonyOS_核心规则卡.md 全文]

我负责代码审查/性能诊断，等待输入。
```

### 4.3 标准工作流程

#### 4.3.1 新功能开发流程

```
步骤 1: 窗口 1 (Claude) - 架构设计
├─ 分析需求文档
├─ 设计组件结构
├─ 规划数据流
└─ 输出任务清单

步骤 2: 窗口 2 (Codex) - 代码实现
├─ 根据架构生成代码
├─ 本地测试
└─ 修复简单错误

步骤 3: 问题分流
├─ 简单编译/语法错误 → 继续在 Codex 修复
└─ 复杂逻辑/架构问题 → 回到 Claude 分析

步骤 4: 窗口 3 (Gemini) - 质量审查
├─ 审查代码质量
├─ 检查性能问题
├─ 发现边界情况
└─ 输出问题清单

步骤 5: 修复与优化
└─ 根据审查反馈回 Codex 修复

步骤 6: 窗口 1 (Claude) - 完成记录
└─ 更新 CLAUDE.md 项目进展
```

#### 4.3.2 Figma 组件落地流程

```
步骤 1: 窗口 1 (Claude) - 分析设计
├─ 读取 Figma 链接（使用 mcp_figma_get_design_context）
├─ 对比需求文档
├─ 列出符合/不符点
└─ 生成/优化提示词

步骤 2: 用户操作
└─ 在 Figma Make 中用优化后的提示词重新生成设计

步骤 3: 窗口 1 (Claude) - 确认设计
├─ 再次读取 Figma 设计
├─ 确认符合规范
└─ 输出 ArkTS 组件蓝图

步骤 4: 窗口 2 (Codex) - 实现组件
├─ 根据蓝图生成代码
└─ 本地验证

步骤 5: 窗口 3 (Gemini) - UI 审查
├─ 审查 UI 实现
├─ 检查性能
└─ 验证响应式

步骤 6: 窗口 1 (Claude) - 记录完成
└─ 更新 CLAUDE.md
```

#### 4.3.3 错误升级机制

```
报错发生
    ↓
Codex 尝试修复（最多 2 次）
    ↓ 仍失败
Claude 深度分析（架构/逻辑层面）
    ↓ 仍不确定
Gemini 多角度诊断（性能/边界/兼容性）
```

### 4.4 信息传递模板

#### 4.4.1 Claude → Codex（任务发布）

```
【来自 Claude 的任务】

功能: TimeTracker ExpenseInput
文件: entry/src/main/ets/components/ExpenseInput.ets

要求:
- Props: amount: number, category: string
- @State inputValue: string = ''
- 布局: Column() > TextInput > Button

样式:
- 宽度: 100%
- 高度: 自适应
- 背景: #FFFFFF
- 圆角: 12vp

请实现完整代码。
```

#### 4.4.2 Codex → Gemini（代码审查）

```
【待审查代码 - 来自 Codex】

文件: ExpenseInput.ets
功能: 记账页输入组件

[粘贴完整代码]

请检查:
1. HarmonyOS 规范符合度
2. 性能问题
3. 潜在 bug
4. 代码质量
```

#### 4.4.3 Gemini → Codex（问题清单）

```
【审查问题清单 - 来自 Gemini】

需要修复的问题:

1. 性能优化（高优先级）:
   第 45 行: .translate() 改为 .transform()
   
2. 边界检查（中优先级）:
   第 23 行: 缺少 inputValue 为空的检查
   
3. 规范问题（低优先级）:
   第 12 行: 缺少 @Prop 装饰器

请逐个修复。
```

### 4.5 实战技巧

#### 技巧 1: 窗口标签管理

在每个窗口的第一条消息加标签：

- 窗口 1: `【主控-Claude】ProjectName`
- 窗口 2: `【编码-Codex】快速实现`
- 窗口 3: `【审查-Gemini】质量检查`

#### 技巧 2: 任务优先级分配

```
简单任务（重复性代码）:
  → 直接用窗口 2 (Codex)

中等任务（新功能）:
  → 窗口 1 (Claude) 设计 → 窗口 2 (Codex) 实现

复杂任务（架构变更）:
  → 窗口 1 (Claude) 主导，Codex 协助

关键节点:
  → 窗口 3 (Gemini) 审查
```

#### 技巧 3: 上下文同步

每天工作开始时：

1. 窗口 1 (Claude): "读取项目状态，确认今日任务"
2. 窗口 2 (Codex): [重开窗口，粘贴精简规则卡]
3. 窗口 3 (Gemini): [暂不打开，需要时再开]

---

## 5. ArkTS 编码规范

### 5.1 状态管理

```typescript
// ✅ 正确 - 使用装饰器管理状态
@Component
export struct Counter {
  @State count: number = 0              // 组件内状态
  @Prop title: string                   // 父传子（单向）
  @Link selectedId: number              // 父子双向绑定
  @Provide theme: string = 'light'      // 跨层级传递
  
  build() {
    Column() {
      Text(this.title)
      Text(`Count: ${this.count}`)
      Button('Add')
        .onClick(() => {
          this.count++  // 触发 UI 更新
        })
    }
  }
}

// ❌ 错误 - 普通变量不会触发 UI 更新
export struct Counter {
  count: number = 0  // UI 不会更新
  
  build() {
    Button('Add')
      .onClick(() => {
        this.count++  // UI 不变
      })
  }
}
```

### 5.2 生命周期

```typescript
@Component
export struct LifecycleDemo {
  @State data: string = ''
  
  // ✅ 组件即将出现（异步任务）
  aboutToAppear(): void {
    console.info('Component will appear')
    this.loadData()
  }
  
  // ✅ 组件即将消失（清理资源）
  aboutToDisappear(): void {
    console.info('Component will disappear')
    this.cleanup()
  }
  
  private async loadData() {
    // 加载数据
  }
  
  private cleanup() {
    // 清理定时器、取消请求等
  }
  
  build() {
    Text(this.data)
  }
}
```

### 5.3 条件渲染

```typescript
// ✅ 正确 - 使用 if/else
@Component
export struct ConditionalDemo {
  @State isLoading: boolean = true
  
  build() {
    Column() {
      if (this.isLoading) {
        LoadingProgress()
      } else {
        Text('Data loaded')
      }
    }
  }
}

// ✅ 三元表达式（简单情况）
Text(this.isActive ? 'Active' : 'Inactive')

// ❌ 错误 - 不支持 && 运算符渲染
{this.isLoading && <LoadingProgress />}  // 语法错误
```

### 5.4 列表渲染

```typescript
// ✅ 正确 - 使用 ForEach
@Component
export struct ListDemo {
  @State items: string[] = ['A', 'B', 'C']
  
  build() {
    List() {
      ForEach(
        this.items,
        (item: string, index: number) => {
          ListItem() {
            Text(`${index}: ${item}`)
          }
        },
        (item: string) => item  // keyGenerator
      )
    }
  }
}

// ✅ LazyForEach（大数据量）
class MyDataSource implements IDataSource {
  private dataArray: string[] = []
  
  public totalCount(): number {
    return this.dataArray.length
  }
  
  public getData(index: number): string {
    return this.dataArray[index]
  }
  
  registerDataChangeListener(listener: DataChangeListener): void {}
  unregisterDataChangeListener(listener: DataChangeListener): void {}
}

@Component
export struct LazyListDemo {
  private dataSource = new MyDataSource()
  
  build() {
    List() {
      LazyForEach(
        this.dataSource,
        (item: string) => {
          ListItem() {
            Text(item)
          }
        },
        (item: string) => item
      )
    }
  }
}
```

### 5.5 事件处理

```typescript
@Component
export struct EventDemo {
  @State count: number = 0
  
  build() {
    Column() {
      // ✅ 点击事件
      Button('Click')
        .onClick(() => {
          this.count++
        })
      
      // ✅ 触摸事件
      Text('Touch me')
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            console.info('Touch down')
          }
        })
      
      // ✅ 手势事件
      Text('Swipe')
        .gesture(
          SwipeGesture({ direction: SwipeDirection.Horizontal })
            .onAction((event: GestureEvent) => {
              console.info('Swiped')
            })
        )
    }
  }
}
```

### 5.6 资源引用

```typescript
// ✅ 图片资源
Image($r('app.media.icon'))
  .width(100)
  .height(100)

// ✅ 字符串资源
Text($r('app.string.welcome'))

// ✅ 颜色资源
.backgroundColor($r('app.color.primary'))

// ✅ rawfile 资源
Image($rawfile('images/banner.png'))

// ❌ 错误 - 直接路径不会打包
Image('src/main/resources/media/icon.png')  // 找不到
```

---

## 6. Figma 设计落地流程

### 6.1 Figma 工作流（强制）

```
用户分享 Figma 链接
    ↓
Claude 读取设计 (mcp_figma_get_design_context)
    ↓
对比需求文档，评估符合度
    ↓
发现问题？→ 优化提示词 → 用户重新生成
    ↓ 完全符合
生成 ArkTS 代码
    ↓
本地测试验证
```

**❌ 禁止**: 不评估设计直接编码

### 6.2 Figma 设计评估标准

```typescript
检查项 1: 布局组件
  ✅ 使用 Column/Row/Stack/Grid
  ❌ 使用 flex/div 等 Web 术语

检查项 2: 颜色规范
  ✅ 使用十六进制 (#RRGGBB)
  ❌ 使用 rgb()/rgba()

检查项 3: 尺寸单位
  ✅ 使用 vp（虚拟像素）
  ❌ 使用 px/rem/em

检查项 4: 组件命名
  ✅ PascalCase (MyComponent)
  ❌ kebab-case (my-component)

检查项 5: 状态管理
  ✅ 明确标注 @State/@Prop/@Link
  ❌ 没有状态说明
```

### 6.3 Figma 提示词优化示例

#### 原始提示词（问题版本）

```
创建一个用户资料卡片，包含头像、姓名、简介。
使用柔和的颜色和圆角设计。
```

#### 优化后提示词（HarmonyOS 版本）

```
创建 HarmonyOS 用户资料卡片组件：

布局结构（使用 ArkUI 组件）:
- 最外层: Column 垂直布局
- 头像: Image 组件，尺寸 80vp，圆形裁剪
- 姓名: Text 组件，字号 20fp，字重 FontWeight.Bold
- 简介: Text 组件，字号 14fp，灰色 #666666，最多 2 行

样式规范:
- 卡片背景: #FFFFFF
- 卡片圆角: 16vp
- 内边距: 20vp
- 阴影: shadowRadius 8, shadowColor #00000020

状态管理:
- @Prop userName: string
- @Prop userAvatar: string
- @Prop userBio: string

颜色方案:
- 主色: #007DFF (HarmonyOS 蓝)
- 背景: #FFFFFF
- 文字: #000000, #666666

请确保所有组件和属性符合 ArkTS 语法。
```

---

## 7. 性能优化指南

### 7.1 布局性能

```typescript
// ✅ 高性能 - 使用 transform（GPU 合成）
.transform({ translateY: offset })
.transform({ scale: { x: 1.2, y: 1.2 } })
.transform({ rotate: { angle: 45 } })

// ❌ 低性能 - 使用 translate（触发重排）
.translate({ y: offset })  // 慢 3-5 倍

// ✅ 使用 opacity 实现淡入淡出
.opacity(this.isVisible ? 1 : 0)
.animation({ duration: 300 })

// ❌ 使用 visibility（触发重排）
.visibility(this.isVisible ? Visibility.Visible : Visibility.None)
```

### 7.2 列表性能

```typescript
// ✅ 使用 LazyForEach（虚拟滚动）
List() {
  LazyForEach(
    this.dataSource,
    (item: Item) => {
      ListItem() {
        ItemComponent({ item: item })
      }
    },
    (item: Item) => item.id.toString()
  )
}
.cachedCount(5)  // 缓存 5 个列表项

// ❌ 使用 ForEach（全量渲染，大数据量卡顿）
ForEach(this.largeArray, (item) => {
  ListItem() { /* ... */ }
})
```

### 7.3 图片优化

```typescript
// ✅ 使用合适的图片格式
Image($r('app.media.banner'))
  .width('100%')
  .objectFit(ImageFit.Cover)
  .interpolation(ImageInterpolation.High)  // 高质量缩放

// ✅ 延迟加载
@State imageLoaded: boolean = false

Image(this.imageLoaded ? $r('app.media.large_image') : $r('app.media.placeholder'))
  .onAppear(() => {
    setTimeout(() => {
      this.imageLoaded = true
    }, 100)
  })

// ✅ 使用 WebP 格式（比 PNG 小 30-50%）
Image($rawfile('images/banner.webp'))
```

### 7.4 动画性能

```typescript
// ✅ 使用 animateTo（声明式动画）
Button('Animate')
  .onClick(() => {
    animateTo({
      duration: 300,
      curve: Curve.EaseInOut
    }, () => {
      this.offset = 100
    })
  })

// ✅ 使用 属性动画
.width(this.expanded ? 200 : 100)
.animation({
  duration: 300,
  curve: Curve.EaseInOut
})

// ❌ 避免在动画中修改布局属性
// 使用 transform 代替 width/height 变化
```

### 7.5 内存优化

```typescript
@Component
export struct MemoryOptimizedComponent {
  private timer: number = -1
  private subscription: any = null
  
  aboutToAppear(): void {
    // 启动定时器
    this.timer = setInterval(() => {
      console.info('Timer tick')
    }, 1000)
    
    // 订阅数据
    this.subscription = DataService.subscribe()
  }
  
  aboutToDisappear(): void {
    // ✅ 清理定时器
    if (this.timer !== -1) {
      clearInterval(this.timer)
    }
    
    // ✅ 取消订阅
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }
  
  build() {
    Text('Optimized')
  }
}
```

---

## 8. 常见问题解决

### 8.1 编译错误

#### 错误 1: "Cannot find name 'xxx'"

```typescript
// ❌ 错误 - 忘记导入
router.pushUrl({ url: 'pages/Detail' })

// ✅ 正确 - 添加导入
import { router } from '@kit.ArkUI'
router.pushUrl({ url: 'pages/Detail' })
```

#### 错误 2: "Decorator '@State' cannot be applied to..."

```typescript
// ❌ 错误 - @State 只能用于简单类型和 @Observed 类
@State user: User = new User()  // User 不是 @Observed

// ✅ 正确 - 标记为 @Observed
@Observed
class User {
  name: string = ''
  age: number = 0
}

@Component
export struct UserCard {
  @State user: User = new User()  // 现在可以了
}
```

#### 错误 3: "Property 'xxx' does not exist on type..."

```typescript
// ❌ 错误 - 访问不存在的属性
.gridSpan(2)  // API 20 已废弃

// ✅ 正确 - 使用新 API
.gridColStart(0)
.gridColEnd(2)
```

### 8.2 运行时错误

#### 错误 1: 应用闪退或黑屏

```typescript
// 常见原因 1: 单页应用使用 router.back()
// ❌ 错误
Button('Exit')
  .onClick(() => {
    router.back()  // 单页应用会黑屏
  })

// ✅ 正确
Button('Exit')
  .onClick(() => {
    getContext(this).terminateSelf()  // 正常退出
  })

// 常见原因 2: 状态未初始化
@State data: string  // ❌ 未初始化
@State data: string = ''  // ✅ 初始化
```

#### 错误 2: 列表不更新

```typescript
// ❌ 错误 - 直接修改数组不会触发更新
this.items[0] = 'New value'

// ✅ 正确 - 创建新数组
this.items = [...this.items]
this.items[0] = 'New value'

// ✅ 或使用数组方法
this.items.splice(0, 1, 'New value')
```

### 8.3 性能问题

#### 问题 1: 列表滚动卡顿

```typescript
// 原因分析:
// 1. 使用 ForEach 渲染大量数据
// 2. 列表项过于复杂
// 3. 频繁触发重新渲染

// ✅ 解决方案
// 1. 使用 LazyForEach + cachedCount
// 2. 简化列表项组件
// 3. 使用 @ObjectLink 减少更新范围

@Component
export struct OptimizedListItem {
  @ObjectLink item: Item  // 只有 item 变化时才重新渲染
  
  build() {
    Row() {
      Text(this.item.title)
    }
    .height(60)
  }
}
```

#### 问题 2: 动画不流畅

```typescript
// ❌ 错误 - 在动画中修改布局属性
.width(this.expanded ? 200 : 100)
.height(this.expanded ? 200 : 100)
.animation({ duration: 300 })

// ✅ 正确 - 使用 transform
.width(100)
.height(100)
.transform({
  scaleX: this.expanded ? 2 : 1,
  scaleY: this.expanded ? 2 : 1
})
.animation({ duration: 300 })
```

### 8.4 Figma 落地常见问题

#### 问题 1: 生成的代码无法编译

```
原因: Figma 设计使用了 Web/React 概念

解决方案:
1. 在 Figma 提示词中明确要求使用 ArkUI 组件
2. Claude 读取设计后先评估，不符合就优化提示词
3. 不要直接使用 Figma 生成的代码，而是由 Codex 根据蓝图重写
```

#### 问题 2: UI 效果与设计不符

```
原因: ArkTS 和 Figma 的渲染差异

解决方案:
1. 使用 DevEco 预览器实时查看效果
2. 调整间距、圆角、阴影等参数
3. 使用 @Preview 装饰器快速预览组件
```

---

## 9. 项目管理规范

### 9.1 Git 提交规范

```bash
# 格式: <type>(<scope>): <subject>

# ✅ 正确示例
git commit -m "feat(CuteCalculator): 添加主题切换功能"
git commit -m "fix(TimeTracker): 修复日历视图日期错误"
git commit -m "refactor(Healthy_life): 重构数据存储模块"
git commit -m "docs: 更新 API 文档"
git commit -m "style(CuteCalculator): 统一代码格式"
git commit -m "perf(TimeTracker): 优化列表渲染性能"

# Type 类型:
# feat: 新功能
# fix: 修复 bug
# refactor: 重构
# docs: 文档更新
# style: 代码格式（不影响功能）
# perf: 性能优化
# test: 测试相关
# chore: 构建/工具配置
```

### 9.2 CLAUDE.md 更新规范

#### 9.2.1 必须更新的时机

```
✅ 完成新功能开发
✅ 修复重要 bug
✅ 进行架构调整
✅ 遇到关键问题
✅ 每日工作结束
```

#### 9.2.2 更新模板

```markdown
### 最近更新
**2025-12-06 14:30 (北京时间)** - 功能名称

#### 详细变更
- **功能模块**: 时间范围
  - 用户反馈问题：
    1. ✅ 问题 1 描述 - 已解决
    2. 🔄 问题 2 描述 - 进行中
    3. ❌ 问题 3 描述 - 待处理
  - 解决方案：
    * 方案 1 说明
    * 方案 2 说明
  - 编译问题修复：
    * 修复 1
    * 修复 2
  - 测试结果：
    * 预览器: ✅ 通过
    * 真机: 🔄 待测试
```

### 9.3 任务完成流程（强制）

```
完成任务
    ↓
立即更新 .claude/CLAUDE.md
    ├─ "最近更新"（询问用户北京时间）
    ├─ "已完成功能" / "已知问题" / "优化记录"
    └─ 告知用户: "已更新项目进展"
    ↓
Git 提交
    ├─ git add .
    ├─ git commit -m "feat(项目): 描述"
    └─ git push
```

### 9.4 分支管理

```
main 分支
├─ 稳定发布版本
├─ 只接受来自 develop 的合并
└─ 每个版本打 tag

develop 分支（主开发分支）
├─ 日常开发
├─ 功能开发
└─ Bug 修复

feature/* 分支（可选）
├─ 大型功能开发
└─ 完成后合并到 develop

hotfix/* 分支（紧急修复）
├─ 从 main 创建
└─ 修复后合并到 main 和 develop
```

### 9.5 代码审查检查清单

```
[ ] 代码符合 ArkTS 规范
[ ] 没有使用废弃的 API
[ ] 导出语法正确（export { }）
[ ] 组件有正确的装饰器（@Component）
[ ] 状态管理使用装饰器（@State/@Prop/@Link）
[ ] 性能优化到位（transform 代替 translate）
[ ] 图标配置正确（$media:layered_image）
[ ] 没有内存泄漏（清理定时器/订阅）
[ ] 边界情况处理（空值/异常）
[ ] 代码有适当的注释
[ ] 更新了 CLAUDE.md
```

---

## 10. 附录：工具与资源

### 10.1 官方文档

```
HarmonyOS 官方文档:
https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/

ArkTS 语法参考:
https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-get-started-V5

ArkUI 组件参考:
https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/arkui-ts-components-V5

API 参考:
https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/
```

### 10.2 常用命令速查

```powershell
# 项目构建
hvigorw assembleHap --mode module -p module=entry@default

# 清理构建
hvigorw clean

# 安装依赖
ohpm install

# 查看依赖树
ohpm list

# 运行测试
hvigorw test

# 生成签名
# （在 DevEco Studio 中操作）
```

### 10.3 VS Code 插件推荐

```
必装:
- HarmonyOS Extension Pack
- ArkTS Language Service
- Code Spell Checker

推荐:
- GitLens
- Error Lens
- TODO Highlight
- Better Comments
```

### 10.4 调试技巧

```typescript
// 1. 使用 console 调试
console.info('Info message')
console.warn('Warning message')
console.error('Error message')
console.debug('Debug message', { data: this.data })

// 2. 使用 hilog
import { hilog } from '@kit.PerformanceAnalysisKit'
hilog.info(0x0000, 'MyTag', 'Log message: %{public}s', 'value')

// 3. 使用 @Preview 预览组件
@Preview
@Component
export struct PreviewDemo {
  build() {
    Text('Preview')
  }
}

// 4. 使用断点调试
// 在 DevEco Studio 中设置断点，使用调试器
```

### 10.5 性能分析工具

```
1. DevEco Studio Profiler
   - CPU Profiler: 分析 CPU 使用
   - Memory Profiler: 分析内存占用
   - Network Profiler: 分析网络请求

2. HiPerf（命令行工具）
   - 性能采样
   - 火焰图生成

3. SmartPerf（性能测试工具）
   - 帧率监控
   - 功耗分析
```

### 10.6 错误代码速查

```
常见错误代码:

16000001: Internal error
16000002: Invalid parameter
16000011: Component does not exist
16000050: Internal ability error

解决方法:
1. 检查 API 调用参数
2. 确认权限配置
3. 查看官方文档错误码说明
4. 检查 module.json5 配置
```

### 10.7 快捷键速查（DevEco Studio）

```
常用快捷键:

Ctrl + Space: 代码提示
Ctrl + Q: 快速文档
Ctrl + B: 跳转到定义
Ctrl + Alt + L: 格式化代码
Ctrl + /: 注释/取消注释
Ctrl + D: 复制当前行
Ctrl + Y: 删除当前行
Ctrl + Shift + F: 全局搜索
Alt + Enter: 快速修复
```

### 10.8 参考项目

```
工作区项目参考:

基础架构参考:
└─ Healthy_life/（成熟的模块化架构）

UI 参考:
└─ CuteCalculator/（自定义主题系统）

功能参考:
└─ TimeTracker1/（日历视图、数据统计）
```

---

## 📝 版本历史

### v2.0 (2025-12-06)
- 重建完整协作指南（原文件丢失）
- 整合核心规则卡、多模型协作、项目管理规范
- 新增性能优化、常见问题、工具资源章节
- 扩展至 2000+ 行完整版

### v1.0 (2025-11 之前)
- 初始版本（已丢失）
- 基础协作规范和代码规则

---

## 📞 支持

遇到问题？

1. **查阅本指南**: 大部分问题在第 8 章"常见问题解决"中有答案
2. **查看项目 CLAUDE.md**: 了解项目当前状态和已知问题
3. **使用多模型协作**: Claude 分析 → Codex 实现 → Gemini 审查
4. **更新文档**: 解决问题后更新 CLAUDE.md，避免重复踩坑

---

**最后更新**: 2025-12-06  
**维护者**: AI 团队（Claude Sonnet 4.5 主导）  
**适用范围**: HarmonyOS 应用工厂全系列项目
