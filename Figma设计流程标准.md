# Figma Make AI 设计流程标准

> **适用范围**: 所有 HarmonyOS 应用项目的 UI 设计  
> **最后更新**: 2025-11-14  
> **来源项目**: MoneyTrack1

---

## 📋 流程概述

当需要为 HarmonyOS 应用创建 Figma 设计时，使用 **Figma Make AI** 功能自动生成设计稿，而非手动设计或使用复杂的设计系统文档。

---

## 🎯 核心原则

1. **提示词驱动**: 使用纯文本英文提示词描述设计需求
2. **组件化拆分**: 每个页面/组件对应一个独立的提示词文件
3. **即用即取**: 用户直接复制粘贴提示词到 Figma Make AI，无需编辑
4. **HarmonyOS 风格**: 提示词中明确指定 HarmonyOS 设计语言

---

## 📁 文件组织规范

### 目录结构
```
项目名/
├── figma/
│   ├── 00_使用说明.md          # 使用指南（中文）
│   ├── 01_页面名.txt            # 页面提示词（英文）
│   ├── 02_页面名.txt
│   ├── 03_页面名.txt
│   ├── 04_组件名.txt            # 组件提示词（英文）
│   ├── 05_组件名.txt
│   └── globals2.css            # 样式变量（可选）
└── .claude/
    └── CLAUDE.md               # 记录设计完成情况
```

### 文件命名规范
- **使用说明**: `00_使用说明.md`（中文）
- **页面提示词**: `01-10` 开头，如 `01_首页.txt`、`02_详情页.txt`
- **组件提示词**: `11-99` 开头，如 `11_按钮.txt`、`12_卡片.txt`
- **文件格式**: `.txt` 纯文本，便于复制

### 编号规则
- `00`: 使用说明文档
- `01-10`: 完整页面设计
- `11-20`: 导航类组件（导航栏、Tab栏等）
- `21-30`: 数据展示组件（卡片、列表项等）
- `31-40`: 交互组件（按钮、输入框等）
- `41-50`: 图表组件（统计图、进度条等）
- `51+`: 其他组件

---

## ✍️ 提示词编写规范

### 基本结构
每个提示词文件包含以下部分（英文书写）：

```
1. Design intent（设计意图）
2. Screen size（屏幕尺寸）
3. Layout description（布局描述）
4. Color scheme（色彩方案）
5. Typography（字体规范）
6. Icon/Asset requirements（图标/资源要求）
7. Style notes（风格说明）
```

### 页面提示词模板

```txt
Design a [页面类型] for a [应用类型] app. [页面用途说明].

Screen: 375×812px, [风格描述] style.

Layout:
- [区域1]: [详细描述]
- [区域2]: [详细描述]
- [区域3]: [详细描述]

Color scheme:
- Primary: HarmonyOS blue (#007DFF)
- Background: White (#FFFFFF)
- [其他颜色]: [色值]

Typography:
- [元素]: [字号] [字重] (HarmonyOS Sans)
- [元素]: [字号] [字重]

Icons: [图标风格描述]

Style: Clean, modern, HarmonyOS design language, [具体风格要求].
```

### 组件提示词模板

```txt
Design a [组件名] component for a [应用类型] app. [组件用途].

Component size: [宽]×[高]px

Layout:
- [部分1]: [详细描述]
- [部分2]: [详细描述]

Color scheme:
- [颜色用途]: [色值]
- [颜色用途]: [色值]

Typography:
- [文本元素]: [字号] [字重]

Style: [风格描述], HarmonyOS design language, [交互状态描述].
```

### 关键要素说明

#### 1. Screen Size（屏幕尺寸）
- **标准尺寸**: `375×812px`（iPhone X 基准）
- **适配说明**: 提示词中说明适配手机屏幕即可

#### 2. Color Scheme（色彩方案）
**HarmonyOS 标准色值**:
```
Primary: #007DFF (HarmonyOS Blue)
Background: #FFFFFF (White)
Card Background: #F8F8F8 (Light Gray)
Text Primary: #1C1C1E (Dark Gray)
Text Secondary: #8E8E93 (Medium Gray)
Success: #34C759 (Green)
Error: #FF3B30 (Red)
Warning: #FF9500 (Orange)
```

#### 3. Typography（字体规范）
**HarmonyOS Sans 字体规格**:
```
Display/Title: 32-48px bold
Heading: 20-24px bold
Subheading: 16-18px medium
Body: 14-16px regular
Caption: 12-14px regular
```

#### 4. Icon Style（图标风格）
- **推荐**: Simple line icons, 24×24px, 2px stroke
- **来源**: IconPark、SF Symbols 风格
- **说明**: 提示词中具体描述图标内容，如 "fork & knife for food"

#### 5. Style Notes（风格说明）
必须包含的关键词:
- `HarmonyOS design language` 或 `iOS/HarmonyOS style`
- `Clean, modern, minimalist`
- `Rounded corners (12px)`
- `Subtle shadows`

---

## 📄 使用说明文档模板

### 00_使用说明.md

````markdown
# [项目名] Figma Make AI 提示词使用说明

## 如何使用这些提示词

1. **打开 Figma**，选择你要生成设计的画板
2. **点击 Make AI 按钮**（通常在工具栏或右键菜单）
3. **复制对应的提示词文件内容**（整个文件内容）
4. **粘贴到 Make AI 输入框**
5. **点击生成**，等待 AI 完成设计

## 提示词文件列表

### 页面提示词（完整页面设计）
- `01_[页面名].txt` - [页面描述]
- `02_[页面名].txt` - [页面描述]
- `03_[页面名].txt` - [页面描述]

### 组件提示词（单独组件）
- `11_[组件名].txt` - [组件描述]
- `12_[组件名].txt` - [组件描述]

## 设计规范

- **颜色**: 基于 HarmonyOS 设计语言
- **字体**: 使用 HarmonyOS Sans
- **尺寸**: 适配手机屏幕（375×812 基准）
- **风格**: 现代、简洁、[应用特定风格]

## 注意事项

⚠️ **每次只生成一个页面/组件**，不要把多个提示词混在一起使用
✅ **可以多次生成调整**，直到满意为止
📱 **记得设置正确的画板尺寸**（Frame size）
````

---

## 🎨 实战案例：MoneyTrack1 记账应用

### 项目背景
- **应用类型**: 个人理财记账应用
- **设计需求**: 3 个页面 + 4 个组件
- **风格定位**: 现代、简洁、金融感

### 文件清单

#### 页面提示词
1. **01_首页.txt** - 资产总览页面
   - 总资产显示
   - 快捷操作按钮
   - 资产卡片列表
   - 最近交易记录

2. **02_记账页.txt** - 账单录入页面
   - 金额输入
   - 类型切换（支出/收入）
   - 分类选择
   - 详细信息录入

3. **03_统计页.txt** - 数据统计页面
   - 周期选择
   - 收支汇总
   - 饼图/折线图
   - 分类排行

#### 组件提示词
4. **04_资产卡片.txt** - 资产展示卡片（335×96px）
5. **05_账单卡片.txt** - 账单列表项（335×72px）
6. **06_图表组件.txt** - 支出分析图表（335×280px）
7. **07_导航栏.txt** - 底部导航栏（375×80px）

### 提示词示例（节选）

```txt
Design a mobile app home page for a personal finance management app called MoneyTrack1. This is the main dashboard showing financial overview.

Screen: 375×812px, iOS style, clean and modern financial app aesthetic.

Layout:
- Top section: Total assets display with large number "$12,589.00" in bold, subtitle "Total Assets" below
- Quick action row: 4 circular buttons (Add Income, Add Expense, Transfer, Budget) with icons
- Assets section: 3-4 cards showing different asset types (Cash, Bank Account, Credit Card, Investment) with icons, names, and amounts
- Recent transactions section: List of 5 recent transactions with category icons, descriptions, amounts (positive in green, negative in red)
- Bottom: Navigation bar with 3 tabs (Home - active, Statistics, Profile) with icons

Color scheme: 
- Primary: HarmonyOS blue (#007DFF)
- Background: White (#FFFFFF)
- Card background: Light gray (#F8F8F8)
- Text: Dark gray (#1C1C1E)
- Positive amount: Green (#34C759)
- Negative amount: Red (#FF3B30)

Typography:
- Use HarmonyOS Sans or SF Pro Display
- Header: 32px bold
- Card title: 16px medium
- Amount: 20px bold
- Body text: 14px regular

Style: Clean, minimalist, with subtle shadows on cards, rounded corners (12px), modern iOS/HarmonyOS design language.
```

---

## 🤖 AI 执行流程

### 创建设计提示词的标准步骤

#### 步骤 1: 分析应用需求
```
1. 了解应用类型和核心功能
2. 确定需要设计的页面数量
3. 识别需要独立设计的组件
4. 确定设计风格定位
```

#### 步骤 2: 创建文件结构
```
1. 在项目下创建 figma/ 目录
2. 创建 00_使用说明.md
3. 为每个页面创建 01-10 开头的 .txt 文件
4. 为每个组件创建 11+ 开头的 .txt 文件
```

#### 步骤 3: 编写提示词
```
1. 使用英文编写（Figma AI 更好理解）
2. 明确指定屏幕尺寸和组件尺寸
3. 详细描述布局结构（从上到下）
4. 提供完整的色彩方案（含色值）
5. 指定字体规格（字号和字重）
6. 说明图标风格和内容
7. 强调 HarmonyOS 设计语言
```

#### 步骤 4: 更新项目文档
```
1. 在项目 CLAUDE.md 中记录设计完成情况
2. 添加到"已完成功能"清单
3. 记录关键决策（如为什么选择这种组件拆分方式）
```

### AI 强制执行规则

✅ **必须遵守**:
1. 提示词使用 `.txt` 格式，不用 `.md`
2. 提示词使用英文，不用中文
3. 每个文件只包含一个页面或组件的提示词
4. 使用说明必须是中文的 `.md` 文件
5. 必须在 CLAUDE.md 中记录完成情况

❌ **严禁**:
1. 创建复杂的 Markdown 格式提示词
2. 把多个页面/组件混在一个文件中
3. 使用中文编写提示词（Make AI 英文理解更好）
4. 创建过于理论化的设计系统文档
5. 忘记更新项目 CLAUDE.md

---

## 📊 质量检查清单

### 提示词质量检查

- [ ] 文件格式为 `.txt`（不是 `.md`）
- [ ] 使用英文编写
- [ ] 包含明确的屏幕/组件尺寸
- [ ] 详细描述布局结构
- [ ] 提供完整色彩方案（含色值）
- [ ] 指定字体规格（字号和字重）
- [ ] 说明图标风格
- [ ] 强调 HarmonyOS 设计语言
- [ ] 可以直接复制粘贴使用

### 文件组织检查

- [ ] 创建了 `figma/` 目录
- [ ] 创建了 `00_使用说明.md`
- [ ] 页面提示词使用 `01-10` 编号
- [ ] 组件提示词使用 `11+` 编号
- [ ] 文件命名清晰易懂
- [ ] 更新了项目 CLAUDE.md

---

## 🎯 使用效果

### 用户体验
- ✅ **即用即取**: 打开 `.txt` 文件，全选复制，粘贴到 Figma Make AI
- ✅ **无需编辑**: 提示词已经完整，不需要修改
- ✅ **快速迭代**: 生成不满意可以调整提示词重新生成

### AI 生成质量
- ✅ **风格统一**: 所有提示词都强调 HarmonyOS 设计语言
- ✅ **尺寸准确**: 明确指定尺寸，生成结果符合预期
- ✅ **细节完整**: 详细描述布局，生成结果包含所有元素

---

## 📝 CLAUDE.md 记录模板

### 在项目 CLAUDE.md 中添加

```markdown
## 6. Figma 设计提示词

### 📁 文件位置
`[项目名]/figma/` 目录下，包含以下文件：

### 页面提示词（完整页面）
- `01_[页面名].txt` - [页面描述]
- `02_[页面名].txt` - [页面描述]
- `03_[页面名].txt` - [页面描述]

### 组件提示词（独立组件）
- `11_[组件名].txt` - [组件描述]
- `12_[组件名].txt` - [组件描述]

### 使用方法
1. 打开 Figma，创建或选择画板
2. 点击 Make AI 功能
3. 复制对应的 `.txt` 文件全部内容
4. 粘贴到 Make AI 输入框
5. 生成设计

**详细说明**: 参考 `00_使用说明.md`

---

## 7. 关键决策记录

### [日期] - Figma 提示词格式调整
- **背景**: 用户使用 Figma Make AI 功能，需要简洁的提示词
- **方案**: 创建 `.txt` 格式提示词文件，每个文件对应一个页面或组件
- **理由**: Make AI 只需要纯文本提示词，复杂的 Markdown 格式不必要
- **影响**: 用户可以直接复制粘贴使用，大幅提升效率
```

---

## 🔗 相关资源

### 官方设计资源
- [HarmonyOS 设计指南](https://developer.huawei.com/consumer/cn/design/)
- [HarmonyOS Sans 字体](https://developer.huawei.com/consumer/cn/design/font/)
- [HarmonyOS 图标库](https://developer.huawei.com/consumer/cn/design/icon/)

### 参考项目
- **MoneyTrack1**: 记账应用设计提示词案例
- **Healthy_life**: 健康应用设计（如已完成）

### Figma 工具
- [Figma Make AI 使用指南](https://help.figma.com/hc/en-us/articles/...)
- [IconPark 图标库](https://iconpark.oceanengine.com/)

---

**版本历史**:
- **2025-11-14**: 初版创建，基于 MoneyTrack1 项目实践总结

**维护建议**:
- 每次创建新项目的设计提示词后，总结经验优化此流程
- 收集用户反馈，持续改进提示词编写规范
- 记录 Figma Make AI 的新功能和最佳实践
