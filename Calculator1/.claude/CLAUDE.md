# Calculator1 项目 - HarmonyOS 计算器应用

> **项目类型**: HarmonyOS 普通应用 (已从原子化服务转换)  
> **目标**: 复刻 iOS 应用并集成多个功能组件  
> **最后更新**: 2025年11月27日 20:09 - 菜单UI重构进行中

---

## 🚨 当前工作状态 (2025-11-27 20:09)

### 正在进行的任务
**菜单UI重构** - 将传统下拉菜单改为卡片式布局

#### 用户需求
用户希望菜单内容显示为不同大小的卡片：
1. **历史记录卡片** - 最大，9:16 比例，占屏幕 3/4 面积
2. **设置卡片** - 长条形卡片
3. **工具箱卡片** - 矩形卡片，点击后进入全屏组件页面

#### 当前状态
- ✅ 已移除 Tab 栏，改用菜单按钮
- ✅ 已实现菜单按钮的弹性缩放+旋转动画（科技感交互）
- ✅ 已尝试 `bindMenu` → 状态不更新问题
- ✅ 已改用 `bindPopup` → 可以响应状态变化
- ⏳ **待完成**: 将 popup 内容改为卡片式布局（需要改用 `bindSheet` 或自定义全屏面板）

#### 关键文件
- `components/module_standard_calculator/src/main/ets/components/StandardCalculator.ets`
  - 状态变量: `showMenuPanel`, `menuLevel`, `menuBtnScale`, `menuBtnRotate`
  - Builder: `MenuContentBuilder()` - 需要重构为卡片布局
  - 菜单按钮在 `HeaderInfo()` 中

#### 下一步操作
1. 将 `bindPopup` 改为 `bindSheet` 实现半模态卡片面板
2. 重新设计 `MenuContentBuilder()` 为卡片式网格布局：
   - 历史记录大卡片（可滚动显示历史）
   - 工具箱矩形卡片（2x2 网格：日期间隔/日期计算/BMI/汇率）
   - 设置长条卡片（点击跳转设置页）
3. 添加卡片入场动画

---

## 📋 项目概述

**Calculator1** - 基于华为官方计算器模板,计划复刻 iOS 应用设计,并集成多个功能组件

- **应用 ID**: `com.example.calculator` ✅ 已更新
- **平台**: HarmonyOS NEXT
- **SDK 版本**: API 16 (5.0.4 Release)
- **语言**: ArkTS
- **构建工具**: Hvigor + ohpm
- **当前版本**: v1.0.3
- **开发状态**: 🚧 开发中 - 修复中
- **默认主题色**: #007DFF (系统蓝)

### 项目目标

1. **复刻 iOS 应用** - 参考 `figma/` 目录下的截图设计
2. **集成功能组件** - BMI计算器、汇率计算器、通用设置
3. **优化用户体验** - 采用 HarmonyOS 设计规范
4. **多设备适配** - 支持手机、折叠屏(待定)

---

## 📂 项目结构速查

```
Calculator1/
├── .claude/
│   └── CLAUDE.md              # ⭐ 本文件 - 项目核心指引
├── figma/                     # iOS 应用参考截图和图标资源
│   ├── 图标/                  # SVG图标资源
│   │   ├── ic_bmi.svg        # BMI计算图标
│   │   ├── ic_exchange.svg   # 汇率计算图标
│   │   ├── ic_date_interval.svg  # 日期间隔图标
│   │   ├── ic_date_calc.svg  # 日期计算图标
│   │   ├── setting_select.svg    # 设置Tab选中图标
│   │   └── setting_unselect.svg  # 设置Tab未选中图标
│   └── IMG_09xx.PNG          # 参考设计稿(6张)
├── libs/                      # 第三方组件库 ⚠️ 原"组件/"已重命名
│   ├── bmi/
│   │   └── bmi_calculator/   # BMI计算器组件
│   ├── exchange/
│   │   └── exchange_calculator/  # 汇率计算器组件
│   └── setting/
│       └── app_setting/      # 通用应用设置组件
├── AppScope/
│   └── app.json5             # 应用全局配置
├── commons/
│   └── lib_foundation/       # 公共能力层(路由、工具类)
├── components/               # 业务组件
│   ├── module_base_apis/     # 基础API组件
│   ├── module_date_calculation/  # 日期计算组件
│   └── module_standard_calculator/  # 标准计算器组件
├── features/                 # 业务特性层
│   ├── business_home/        # 首页(计算器)
│   ├── business_tool/        # 工具页
│   └── business_mine/        # 我的页面
├── products/
│   └── entry/                # 应用入口模块
├── build-profile.json5       # 构建配置
├── oh-package.json5          # ohpm依赖
└── README.md                 # 项目说明文档
```

### 关键目录说明

- **figma/**: iOS应用设计参考截图 (6张PNG)
- **组件/**: 未集成的组件库 (BMI/汇率/设置)
- **components/**: 已有的计算器和日期计算组件
- **features/**: 三大业务模块 (计算器/工具/我的)
- **products/entry**: 应用主入口

---

## 🛠️ 开发环境

### 推荐工具链版本
- **DevEco Studio**: 5.0.4 Release 及以上
- **HarmonyOS SDK**: 5.0.4(16) Release
- **Node.js**: 最新 LTS 版本
- **ohpm**: 内置于 DevEco Studio
- **hvigorw**: 项目内置

### 当前SDK配置
```json5
"targetSdkVersion": "5.0.4(16)",
"compatibleSdkVersion": "5.0.4(16)",
"runtimeOS": "HarmonyOS"
```

⚠️ **SDK版本警告**: 
- 当前使用 API 16 (SDK 5.0.4)
- 建议升级到 **API 20+ (SDK 6.0.0+)** 以避免过期API问题
- 升级后需更新部分API (如 `router.replaceUrl()` → `router.replaceNamedRoute()`)

---

## ⚡ 快速命令参考

### 依赖管理
```powershell
# 安装依赖
ohpm install

# 查看依赖树
ohpm list

# 更新依赖
ohpm update
```

### 构建命令
```powershell
# Debug 构建
hvigorw assembleHap --mode module

# Release 构建
hvigorw assembleHap --mode module -p buildMode=release

# 清理构建
hvigorw clean
```

### 代码检查
```powershell
# ESLint 检查 (如已配置)
npm run lint
```

---

## 📊 项目进展追踪

### 最近更新
**2025年11月25日 下午** - 完成组件功能评估，创建详细开发方案文档  
**2025年11月25日 下午** - 用户确认设置组件功能清单（10项保留，5项去除）  
**2025年11月25日 晚上** - 详细分析 iOS 计算器截图，明确 UI 设计和功能需求

### 📋 待开发功能 (优先级排序)

> **详细方案文档**: `.claude/开发方案与功能评估.md`  
> **iOS UI 分析**: `.claude/iOS应用UI分析.md` ⭐ 新增  
> **功能清单状态**: ✅ 已完成 iOS 应用分析，等待最终确认开始开发

#### 第一阶段: 需求分析与设计 (P0 - 未开始)
- [ ] **分析 iOS 应用截图** - 确定主要功能和UI布局
- [ ] **制定 Figma 提示词** - 为每个页面创建设计提示词
- [ ] **评估组件集成方案** - 确定 BMI/汇率/设置组件的集成方式
- [ ] **确定架构调整** - 是否需要修改现有模板结构

#### 第二阶段: Figma 设计生成 (P0 - 未开始)
- [ ] **创建首页设计** - 使用 Figma Make AI 生成
- [ ] **创建功能页设计** - BMI/汇率/工具等页面
- [ ] **创建设置页设计** - 用户设置和关于页面
- [ ] **AI 评估设计** - 对比需求并优化提示词

#### 第三阶段: 组件集成 (P1 - 未开始)
- [ ] **集成 BMI 计算器** - 添加到项目模块
- [ ] **集成汇率计算器** - 添加到项目模块
- [ ] **集成通用设置组件** - 替换现有设置页
- [ ] **路由配置** - 配置组件之间的导航

#### 第四阶段: UI 开发 (P1 - 未开始)
- [ ] **实现主页** - 基于 Figma 设计
- [ ] **实现功能页** - BMI/汇率/工具页面
- [ ] **实现设置页** - 用户设置和关于
- [ ] **统一主题** - 应用 HarmonyOS 设计规范

#### 第五阶段: 功能完善 (P2 - 未开始)
- [ ] **深色模式支持** - 实现主题切换
- [ ] **数据持久化** - 保存用户数据和历史记录
- [ ] **动画效果** - 页面转场和交互动画
- [ ] **错误处理** - 完善异常处理逻辑

#### 第六阶段: 测试与优化 (P2 - 未开始)
- [ ] **功能测试** - 验证所有功能正常
- [ ] **性能优化** - 优化启动速度和流畅度
- [ ] **多设备适配** - 测试不同屏幕尺寸
- [ ] **AppGallery 准备** - 图标、签名、审核准备

### 进行中功能 🔄
- 🔄 **菜单卡片式UI重构** - 将下拉菜单改为卡片布局面板（详见上方"当前工作状态"）

### 已完成功能 ✅
- **2025-11-27** - 实现 FeedbackService 反馈服务（振动/按键音/TTS语音播报）
- **2025-11-27** - 实现 TTS 自然中文数字朗读（如"一万两千三百"而非"1-2-3-0-0"）
- **2025-11-27** - 实现按键音 SoundPool 播放 + 振动反馈
- **2025-11-27** - 实现设置页振动/按键音/TTS开关，按键音与TTS互斥
- **2025-11-27** - 移除 Tab 栏，改用菜单按钮
- **2025-11-27** - 实现菜单按钮弹性缩放+旋转动画（科技感交互）
- **2025-11-27** - 尝试 bindMenu/bindPopup 实现子菜单切换
- **2025-11-25 上午** - 创建项目 CLAUDE.md 文档
- **2025-11-25 上午** - 分析项目结构和组件库
- **2025-11-25 下午** - 完成三个组件的详细功能评估
- **2025-11-25 下午** - 创建开发方案与功能评估文档
- **2025-11-25 下午** - 设计颜色主题选择功能方案
- **2025-11-25 晚上** - 详细分析 iOS 计算器 UI 设计（6张截图）
- **2025-11-25 晚上** - 创建 iOS 应用 UI 分析文档
- **2025-11-26** - 完成图标资源更新（工具页SVG图标+Tab栏设置图标）
- **2025-11-26** - 修复构建错误：重命名中文目录（组件/ → libs/）
- **2025-11-26** - 修复 FeedbackService.ets ArkTS 编译错误（重写为模块函数）
- **2025-11-26** - 修复资源冲突：删除重复的 setting_select.png/setting_unselect.png
- **2025-11-26** - 修复原子化服务配置：所有模块 installationFree 改为 false
- **2025-11-26** - 修复包名：bundleName 从 com.atomicservice.xxxxxx 改为 com.example.calculator

### 已知问题 ⚠️
- **SDK 版本过时**: 当前使用 API 16，建议升级到 API 20+
- **⚠️ 签名配置需更新**: bundleName 已更改，需要在 DevEco Studio 中重新生成签名
- **缺少图标资源**: `ic_chevron_left` 不存在，已用 Unicode 符号 `‹` 替代

---

## 🔧 FeedbackService 反馈服务 (已实现)

### 文件位置
`commons/lib_foundation/src/main/ets/services/FeedbackService.ets`

### 功能说明
| 功能 | API | 说明 |
|------|-----|------|
| 振动反馈 | `vibrateFeedback()` | 短振动 20ms |
| 按键音 | `playKeySound()` | SoundPool 播放 click.mp3，失败时回退振动 |
| TTS语音 | `speakText(text)` | 语音朗读，音量 0.5 |
| 数字转中文 | `numberToSpeakText(num)` | 自然朗读（支持万/亿/兆/小数/负数/百分比）|

### 资源文件
- `commons/lib_foundation/src/main/resources/rawfile/click.mp3` - 按键音效

### 初始化
在 `EntryAbility.ets` 中：
- `onCreate`: 调用 `initSoundPlayer(context.resourceManager)` 和 `initTTS()`
- `onDestroy`: 调用 `releaseAllFeedback()`

### 设置页互斥逻辑
在 `SettingPage.ets` 中，按键音和TTS开关互斥（开启一个自动关闭另一个）

---

## 🎨 设计资源

### iOS 参考截图
位置: `C:\HarmonyOS_App_Plans\Calculator1\figma\`

| 文件名 | 说明 |
|-------|------|
| IMG_0948.PNG | 待分析 |
| IMG_0949.PNG | 待分析 |
| IMG_0950.PNG | 待分析 |
| IMG_0951.PNG | 待分析 |
| IMG_0952.PNG | 待分析 |
| IMG_0953.PNG | 待分析 |

⚠️ **待办**: 需要逐一分析截图，明确每个页面的功能和设计要点

### Figma 提示词 (待创建)
按照协作指南中的"Figma 设计流程标准"，需要创建:
- `figma/00_使用说明.md` - 中文使用指南
- `figma/01_xxx.txt` - 页面提示词
- `figma/11_xxx.txt` - 组件提示词

---

## 🧩 组件库分析

### 已下载组件 (未集成)

#### 1. BMI 计算器 (bmi_calculator)
- **路径**: `libs/bmi/bmi_calculator/`
- **功能**: BMI 计算和记录
- **入口**: `BmiHome` (NavPathStack 路由)
- **依赖**: 独立 HAR 模块
- **状态**: ✅ 已集成

#### 2. 汇率计算器 (exchange_calculator)
- **路径**: `libs/exchange/exchange_calculator/`
- **功能**: 多币种实时汇率计算
- **入口**: `ExchangeRateCalculatorPage` (NavPathStack 路由)
- **依赖**: 独立 HAR 模块
- **状态**: ✅ 已集成

#### 3. 通用设置组件 (app_setting)
- **路径**: `libs/setting/app_setting/`
- **功能**: 
  - 深色模式切换
  - 振动/按键音/TTS开关
  - 清除缓存
  - 检测版本
  - 关于页面
  - 隐私协议
- **状态**: ✅ 已集成

### 已有组件 (已集成)

#### 1. 标准计算器 (module_standard_calculator)
- **功能**: 标准计算器、科学计算器、历史记录
- **状态**: ✅ 已集成

#### 2. 日期计算 (module_date_calculation)
- **功能**: 日期间隔计算、日期前后推算
- **状态**: ✅ 已集成

#### 3. 基础API组件 (module_base_apis)
- **功能**: 基础函数、模态框、弹窗、选择器等
- **状态**: ✅ 已集成

---

## 🔧 集成组件的步骤 (待执行)

### 步骤1: 添加模块到构建配置
```json5
// build-profile.json5
"modules": [
  // ... 现有模块
  {
    "name": "bmi_calculator",
    "srcPath": "./组件/BMI组件/bmi_calculator"
  },
  {
    "name": "exchange_calculator",
    "srcPath": "./组件/汇率组件/exchange_calculator"
  },
  {
    "name": "app_setting",
    "srcPath": "./组件/设置组件/app_setting"
  }
]
```

### 步骤2: 添加依赖到 oh-package.json5
```json5
// oh-package.json5
"dependencies": {
  // ... 现有依赖
  "bmi_calculator": "file:./组件/BMI组件/bmi_calculator",
  "exchange_calculator": "file:./组件/汇率组件/exchange_calculator",
  "app_setting": "file:./组件/设置组件/app_setting"
}
```

### 步骤3: 在页面中引入和使用
```typescript
// 示例: 使用 BMI 计算器
@Entry
@ComponentV2
export struct ToolPage {
  @Local pageStack: NavPathStack = new NavPathStack();
  
  build() {
    Navigation(this.pageStack) {
      Button('BMI计算').onClick(() => {
        this.pageStack.pushPathByName('BmiHome', null);
      });
    }
  }
}
```

### 步骤4: 配置路由
需要在路由配置中注册新组件的路由名称

---

## 🎯 开发约定

### 代码规范
- **装饰器**: 必须使用 `@Component` + `@Entry`
- **导出**: 使用 `export { xxx }`, 避免 `export default`
- **样式**: 链式调用 `.width(100).height(50)`, 避免对象式
- **布局**: 使用 `Column/Row/Stack`, 避免 `div/flex`
- **图标**: 统一使用 `"$media:layered_image"` (AppGallery 要求)

### 性能优化
- 使用 `transform({ translateY })` 而非 `translate()`
- 避免频繁的布局重排
- LazyForEach 用于大列表 (>50项)

### API 使用规范
- ⚠️ **过期 API 检查**: 
  - `router.replaceUrl()` → `router.replaceNamedRoute()` (API 20+)
  - `router.back()` → `context.terminateSelf()` (单页应用退出)
  - `getContext(this)` → 需类型转换 `as common.UIAbilityContext`

### Git 规范
- 分支命名: `feature/xxx`, `bugfix/xxx`, `hotfix/xxx`
- Commit 格式: `feat: xxx`, `fix: xxx`, `refactor: xxx`
- PR 流程: 代码审查 → 测试通过 → 合并主分支

---

## 🚀 开发路线图

### 当前阶段: 📋 项目规划 (第0周)

**本周任务**:
1. ✅ 创建 CLAUDE.md 文档
2. ⏳ 分析 iOS 应用截图
3. ⏳ 确定功能清单和优先级
4. ⏳ 制定 Figma 设计提示词

**下一步**:
- 查看 figma 目录下的 6 张 iOS 截图
- 确定需要复刻的核心功能
- 评估是否需要集成所有三个组件
- 确定是否需要重新设计 UI 还是沿用模板风格

### 预计开发周期

| 阶段 | 周期 | 状态 |
|-----|------|------|
| 需求分析与设计 | 1周 | ⏳ 进行中 |
| Figma 设计生成 | 1周 | ❌ 未开始 |
| 组件集成 | 1周 | ❌ 未开始 |
| UI 开发 | 2周 | ❌ 未开始 |
| 功能完善 | 1周 | ❌ 未开始 |
| 测试与优化 | 1周 | ❌ 未开始 |
| **总计** | **7周** | **14% 完成** |

---

## 📌 关键决策记录

### 2025-11-25 - 项目初始化与需求确认
- **背景**: 基于华为官方计算器模板，需要复刻 iOS 计算器应用
- **决策**: 
  1. 创建项目级 CLAUDE.md 文档
  2. 分析现有模板和下载的组件
  3. 制定分阶段开发计划
- **理由**: 遵循协作指南要求，先理解项目再动手
- **影响**: 明确了项目目标和技术路线

### 2025-11-25 - 用户功能需求确认（第二轮）
- **背景**: 用户提出关键问题，确认细节需求
- **用户确认**:
  1. ❌ **推送功能** - 当前不需要（未来可能需要）
  2. ✅ **汇率组件** - 确认集成（经检查：无需网络，离线使用）
  3. ✅ **业务隐私声明** - 确认需要（法律合规 + 用户信任）
  4. ⚠️ **iOS 截图** - AI 无法直接查看图片，建议转为 Figma 设计
- **技术发现**:
  - 汇率组件使用**静态数据**（2025-08-13），完全离线
  - 无需申请网络权限
  - 22 种货币硬编码在 `Constants.ets`
- **最终功能清单**: 10 项保留，5 项去除（详见方案文档）
- **影响**: 
  - 减少了不必要的功能（推送、账号系统）
  - 明确了隐私合规要求
  - 确认了离线使用的技术路线

### 2025-11-25 - iOS 应用 UI 详细分析
- **背景**: 用户提供了 6 张 iOS 计算器应用截图
- **分析内容**:
  1. ✅ **主题色**: #E85D4C (橙红色) - 不是蓝色！
  2. ✅ **颜色选择入口**: 右上角宝石图标 + 通用设置第一项
  3. ✅ **菜单结构**: 侧边抽屉菜单，4 个可折叠分组
  4. ✅ **功能模块**: 实用功能正好对应 BMI/汇率/日期计算器
  5. ✅ **开关样式**: iOS 风格 Toggle（橙红色背景）
  6. ✅ **按钮设计**: 圆形按钮，深灰/浅灰/橙红三种颜色
- **关键发现**:
  - 颜色主题切换是**核心功能**（右上角显眼位置）
  - 默认主题色是橙红色 #E85D4C，而非 HarmonyOS 的系统蓝
  - 菜单分组：计算器/实用功能/通用设置/其他
  - iOS 风格的开关需要自定义实现
- **技术要点**:
  - 侧边抽屉导航（代替 Tab 栏）
  - 可折叠分组菜单
  - 主题色动态切换（影响运算符按钮、开关等）
  - 圆形按钮布局（4×4 网格）
- **影响**: 
  - 明确了默认橙红色主题
  - 确认了侧边菜单导航结构
  - 需要实现 iOS 风格组件

### 待决策事项（需要用户确认）
- [x] **BMI/汇率组件** - ✅ 已集成
- [x] **颜色主题方案** - ✅ 使用系统蓝 #007DFF
- [ ] **iOS 截图分析** - 是否需要转为 Figma 设计以便 AI 分析？

### 2025-11-26 - 架构重构与组件集成
- **背景**: 完成三Tab架构改造，集成BMI、汇率、设置组件
- **完成内容**:
  1. ✅ **Tab结构改造** - "我的"改为"设置"，集成app_setting组件
  2. ✅ **工具页重构** - 卡片网格布局，4个已启用工具
  3. ✅ **组件集成** - BMI计算器、汇率计算器已集成
  4. ✅ **日期功能拆分** - 日期间隔、日期计算独立入口
  5. ✅ **反馈服务** - 创建FeedbackService（振动/音效/语音播报）
  6. ✅ **预留接口** - 3个预留位置（金额大写/单位换算/房贷计算）已注释隐藏
- **隐藏功能**（免费版本）:
  - ❌ 会员入口和VIP页面（代码保留，入口隐藏）
  - ❌ 预留工具接口（代码注释保留）
- **技术决策**:
  - 默认主题色：系统蓝 #007DFF
  - 工具图标：暂用emoji，后续替换PNG/SVG

### 2025-11-26 - 汇率更新方案决策
- **背景**: 讨论汇率组件的数据更新方案
- **当前状态**: 使用硬编码静态汇率数据（2025-08-13）
- **决策**: ⏸️ **暂不实现实时汇率更新**
- **理由**:
  1. 当前为免费版本，优先保证基础功能稳定
  2. API调用次数有限（1500次/月），多用户场景不可持续
  3. 需要服务器支持才能实现可靠的汇率更新
- **未来规划**: 
  - 待应用上架后，根据用户量决定是否搭建服务器
  - 服务器方案：定时获取汇率 → 缓存 → 客户端请求服务器
  - 推荐API：Exchange Rate API（免费1500次/月）
- **备注**: 当前汇率数据仅供参考，界面已提示"汇率有波动，仅供数据参考"

---

## ⚠️ 已知限制

### 环境要求
- **DevEco Studio**: 5.0.4 Release 及以上
- **HarmonyOS SDK**: 5.0.4(16) 及以上
- **设备**: 华为手机 (双折叠和阔折叠待定)
- **系统**: HarmonyOS 5.0.4(16) 及以上

### 权限需求
- 暂无特殊权限需求

### 已知问题
1. **应用包名未配置**: 需要在 AppGallery Connect 创建应用并更新 bundleName
2. **签名配置缺失**: 需要配置签名证书才能打包 Release 版本
3. **组件未集成**: 三个组件库需要手动添加到构建配置
4. **设计稿未分析**: iOS 截图尚未详细分析功能需求

---

## 📄 项目文档索引

### 核心文档
- **`.claude/CLAUDE.md`** (本文件) - 项目总览和状态追踪
- **`.claude/开发方案与功能评估.md`** - 详细开发方案和组件功能评估

### 参考文档
- `README.md` - 项目概述和快速入门
- `组件/BMI组件/bmi_calculator/README.md` - BMI 计算器使用说明
- `组件/汇率组件/exchange_calculator/README.md` - 汇率计算器使用说明
- `组件/设置组件/app_setting/README.md` - 通用设置组件使用说明

---

## 🔗 相关资源

### 官方文档
- [HarmonyOS 开发者文档](https://developer.huawei.com/consumer/cn/harmonyos/)
- [ArkTS 语法指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started-V5)
- [HarmonyOS 设计规范](https://developer.huawei.com/consumer/cn/design/harmonyos/)

### 项目文档
- README.md - 项目概述和快速入门
- 组件 README - 各组件的使用说明
- HarmonyOS开发AI协作指南.prompt.md - 工作区协作规范

### 工具链
- [DevEco Studio 下载](https://developer.huawei.com/consumer/cn/deveco-studio/)
- [ohpm 文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-ohpm-V5)
- [Hvigor 构建工具](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-hvigor-V5)

---

## 📞 协作说明

### AI 工作规范
1. **每次对话开始前**: 必须先读取此 CLAUDE.md
2. **完成任务后**: 立即更新"项目进展追踪"
3. **重要决策**: 记录到"关键决策记录"
4. **发现问题**: 添加到"已知问题"

### 用户协作要求
1. **提供北京时间**: AI 记录时间戳时需询问
2. **确认设计需求**: 分析截图后需用户确认
3. **技术决策**: 重要决策前需用户同意
4. **测试验证**: 功能完成后需用户测试

### 时间记录规范
- 所有时间使用 **北京时间 (UTC+8)**
- 格式: `YYYY-MM-DD HH:mm`
- AI 记录前必须询问用户当前时间

---

## 🎯 下一步行动建议

### 立即执行 (本次对话)
1. **分析 iOS 截图** - 查看 figma 目录下的 6 张图片
2. **确定功能清单** - 列出需要实现的核心功能
3. **评估组件使用** - 确定哪些组件需要集成
4. **制定详细规划** - 给出具体的开发步骤

### 待用户确认
1. **是否需要升级 SDK**: API 16 → API 20+
2. **应用包名**: 更新 app.json5 中的 bundleName
3. **设计风格**: 完全复刻 iOS 还是融入 HarmonyOS 风格
4. **设备支持**: 手机 / 折叠屏 / 平板

---

*本文档由 AI 根据 HarmonyOS 开发协作指南创建，会随项目进展实时更新*
