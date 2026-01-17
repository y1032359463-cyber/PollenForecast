# 鸿蒙原生应用 Figma 设计指南

> **完整的 HarmonyOS 设计系统规范 - 供 Figma AI 生成符合鸿蒙标准的原生应用界面**

---

## 📋 目录
1. [设计原则](#设计原则)
2. [颜色系统](#颜色系统)
3. [字体规范](#字体规范)
4. [间距与布局](#间距与布局)
5. [组件规范](#组件规范)
6. [交互规则](#交互规则)
7. [图标系统](#图标系统)
8. [动画效果](#动画效果)
9. [响应式设计](#响应式设计)
10. [无障碍设计](#无障碍设计)

---

## 🎯 设计原则

### 核心价值观
* **自然直观**：遵循用户认知习惯，操作流程自然流畅
* **简洁高效**：减少视觉干扰，突出核心功能，提高操作效率
* **一致统一**：保持设计语言在所有界面的一致性
* **包容开放**：适应不同用户群体和多样化使用场景

### 设计准则
* 以人为本，关注用户情感体验
* 技术与美学完美结合
* 跨设备、跨场景的统一体验
* 优先考虑单手操作便捷性
* 减少层级深度，扁平化信息架构

---

## 🎨 颜色系统

### 主色调（Primary Colors）

#### 华为蓝（品牌色）
```
颜色名称：华为蓝 / Huawei Blue
HEX: #2196F3
RGB: 33, 150, 243
用途：
  - 主要操作按钮
  - 重要信息高亮
  - 链接文本
  - 选中状态
  - Tab 激活状态
```

#### 华为橙（辅助色）
```
颜色名称：华为橙 / Huawei Orange
HEX: #FF9800
RGB: 255, 152, 0
用途：
  - 次要操作按钮
  - 徽章提示
  - 促销标签
```

### 功能色彩（Functional Colors）

```
成功 / Success:
  HEX: #4CAF50
  用途：成功状态、正确操作反馈、完成标志

警告 / Warning:
  HEX: #FF9800
  用途：警告提示、需要注意的内容、风险操作提醒

错误 / Error:
  HEX: #F44336
  用途：错误状态、失败提示、危险操作、表单验证错误

信息 / Info:
  HEX: #2196F3
  用途：一般信息提示、帮助说明
```

### 中性色阶（Neutral Colors）

```
gray-50:  #FAFAFA  // 背景色、最浅灰
gray-100: #F5F5F5  // 页面背景、禁用背景
gray-200: #EEEEEE  // 分割线、边框
gray-300: #E0E0E0  // 输入框边框
gray-400: #BDBDBD  // 占位符文本
gray-500: #9E9E9E  // 辅助文本
gray-600: #757575  // 次要文本
gray-700: #616161  // 正文文本
gray-800: #424242  // 副标题
gray-900: #212121  // 主标题、正文
```

### 颜色使用规范

* **主色使用频率**：在单个屏幕中，主色占比不超过 20%
* **对比度要求**：文字与背景对比度至少 4.5:1（正文），3:1（大字体）
* **色彩层级**：使用颜色深浅表示信息层级，不依赖色相区分
* **禁用状态**：使用 60% 不透明度或 gray-400
* **暗色主题**：自动适配，使用降低饱和度的颜色变体

---

## 📝 字体规范

### 字体家族（Font Family）

```
主字体：HarmonyOS Sans
后备字体：-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif
等宽字体：HarmonyOS Sans Mono, Monaco, Consolas, monospace
```

### 字体大小与行高（Type Scale）

#### Figma 中必须使用的标准字体规格：

```
Display（页面主标题）:
  Font Size: 32px
  Line Height: 40px (125%)
  Font Weight: 700 (Bold)
  用途：页面标题、重要公告标题

Title（章节标题）:
  Font Size: 28px
  Line Height: 36px (129%)
  Font Weight: 700 (Bold)
  用途：章节标题、模块标题

Heading（小节标题）:
  Font Size: 24px
  Line Height: 32px (133%)
  Font Weight: 600 (Semibold)
  用途：小节标题、卡片标题

Subheading（子标题）:
  Font Size: 20px
  Line Height: 28px (140%)
  Font Weight: 600 (Semibold)
  用途：子标题、列表标题

Body Large（重要正文）:
  Font Size: 18px
  Line Height: 26px (144%)
  Font Weight: 400 (Regular)
  用途：重要正文、强调文本

Body（常规正文）:
  Font Size: 16px
  Line Height: 24px (150%)
  Font Weight: 400 (Regular)
  用途：常规正文、描述文本、输入框文本

Body Small（辅助文字）:
  Font Size: 14px
  Line Height: 20px (143%)
  Font Weight: 400 (Regular)
  用途：辅助说明、次要信息、按钮文本

Caption（说明文字）:
  Font Size: 12px
  Line Height: 16px (133%)
  Font Weight: 400 (Regular)
  用途：图片说明、标签、时间戳、版权信息
```

### 字体粗细（Font Weights）

```
Light:   300 - 极少使用，仅用于超大标题
Regular: 400 - 默认正文
Medium:  500 - 按钮文本、标签
Semibold: 600 - 小标题
Bold:    700 - 主标题、强调文本
```

### 字体使用规则

* **可读性优先**：正文最小字号为 14px，移动端不小于 16px
* **行长度限制**：正文行长度不超过 75 个字符（约 600px）
* **字间距**：正文 0，标题 -0.02em
* **文本对齐**：默认左对齐，数字右对齐，标题可居中
* **段落间距**：段落间距为行高的 1.5 倍

---

## 📐 间距与布局

### 基础间距单位（Spacing Scale）

**使用 8px 网格系统，所有间距必须是 4px 的倍数**

```
4px   (xs)   - 极小间距，图标与文字间距
8px   (sm)   - 小间距，行内元素间距
12px  (m-)   - 中小间距，组内元素间距
16px  (md)   - 中等间距，组件内边距、列表项间距
24px  (lg)   - 大间距，组件外边距、卡片内边距
32px  (xl)   - 超大间距，章节间距
48px  (xxl)  - 页面区块间距
64px  (xxxl) - 大型区块分隔
```

### 组件内边距（Component Padding）

```
Button 按钮:
  - Small: 6px 12px (高度 32px)
  - Medium: 8px 16px (高度 40px)
  - Large: 12px 20px (高度 48px)

Card 卡片:
  - 内边距: 16px
  - 标题与内容间距: 12px
  - 内容与操作按钮间距: 16px

Input 输入框:
  - 内边距: 8px 12px (高度 40px)
  - Label 间距: 8px

Modal 模态框:
  - 内边距: 24px
  - 标题与内容间距: 16px
  - 内容与按钮间距: 24px

Page 页面:
  - 左右边距: 16px
  - 顶部边距: 16px
  - 底部边距: 24px
```

### 布局网格（Layout Grid）

#### 手机端（Phone）
```
屏幕宽度: 360px - 428px
列数: 4 列
间距: 16px
边距: 16px
```

#### 平板端（Tablet）
```
屏幕宽度: 768px - 1024px
列数: 8 列
间距: 24px
边距: 32px
```

#### 桌面端（Desktop）
```
屏幕宽度: 1280px+
列数: 12 列
间距: 24px
边距: 48px
最大内容宽度: 1200px
```

### 布局规则

* **使用 Flexbox 或 Grid**：避免绝对定位，除非特殊需求
* **响应式优先**：设计时考虑不同屏幕尺寸的适配
* **垂直韵律**：保持统一的垂直间距节奏
* **对齐原则**：左对齐为主，居中对齐用于特殊场景
* **留白充足**：避免拥挤，给用户呼吸空间

---

## 🧩 组件规范

### Button 按钮

#### 主要按钮（Primary Button）
```
背景色: #2196F3
文字颜色: #FFFFFF
边框: 无
圆角: 8px
内边距: 8px 16px (中号)
字体大小: 16px
字体粗细: 500 (Medium)
最小触摸区域: 44px × 44px

状态变化:
  - Hover: 背景色变为 #1976D2
  - Pressed: 背景色变为 #1565C0，scale(0.98)
  - Disabled: 背景色 #BDBDBD，文字色 #FFFFFF，不透明度 60%
  - Focus: 外边框 2px solid #2196F3，偏移 2px
```

#### 次要按钮（Secondary Button）
```
背景色: transparent
文字颜色: #2196F3
边框: 1px solid #2196F3
圆角: 8px
内边距: 8px 16px
字体大小: 16px
字体粗细: 500

状态变化:
  - Hover: 背景色 #E3F2FD
  - Pressed: 背景色 #BBDEFB，scale(0.98)
  - Disabled: 边框色 #BDBDBD，文字色 #BDBDBD
```

#### 文本按钮（Text Button）
```
背景色: transparent
文字颜色: #2196F3
边框: 无
圆角: 8px
内边距: 8px 16px
字体大小: 16px
字体粗细: 500

状态变化:
  - Hover: 背景色 #E3F2FD
  - Pressed: 背景色 #BBDEFB
```

#### 按钮使用规则
* **每个屏幕最多 1 个主要按钮**
* **按钮标签使用动词**：如"确认"、"保存"、"提交"
* **按钮宽度**：自适应内容，最小宽度 80px
* **按钮组间距**：水平排列间距 8px，垂直排列间距 16px
* **按钮排列顺序**：主要按钮在右侧/底部

---

### Card 卡片

```
背景色: #FFFFFF
圆角: 12px
内边距: 16px
边框: 1px solid #E0E0E0
阴影（Elevation）:
  - Elevation 1: 0 1px 2px rgba(0, 0, 0, 0.05)
  - Elevation 2: 0 4px 6px rgba(0, 0, 0, 0.1)  ← 默认
  - Elevation 3: 0 10px 15px rgba(0, 0, 0, 0.1)
  - Elevation 4: 0 20px 25px rgba(0, 0, 0, 0.1)

结构:
  1. 封面图片（可选）: 宽度 100%，高度 200px，圆角 12px 仅顶部
  2. 标题: 18px Bold，#212121，最多 2 行，超出省略
  3. 内容: 14px Regular，#757575，最多 3 行，超出省略
  4. 操作区（可选）: 底部，右对齐，按钮间距 8px

交互:
  - Hover: 向上移动 2px，阴影增强
  - Pressed: scale(0.98)
```

#### 卡片使用规则
* **内容简洁**：卡片内容不超过 3-4 行
* **操作按钮**：最多 2 个操作按钮
* **卡片间距**：网格布局间距 16px-24px
* **可点击区域**：整个卡片可点击时，显示 cursor: pointer

---

### Input 输入框

```
背景色: #FFFFFF
边框: 1px solid #E0E0E0
圆角: 8px
内边距: 8px 12px
高度: 40px
字体大小: 16px
字体颜色: #212121
占位符颜色: #9E9E9E

结构:
  1. Label（可选）: 14px Medium，#424242，间距 8px
  2. 输入框: 40px 高度
  3. 后缀图标（可选）: 20px，右侧 12px
  4. 错误提示/辅助文本: 12px Regular，#F44336（错误）/#757575（辅助），间距 4px

状态:
  - Default: 边框 #E0E0E0
  - Focus: 边框 2px solid #2196F3，阴影 0 0 0 2px rgba(33, 150, 243, 0.2)
  - Error: 边框 1px solid #F44336
  - Disabled: 背景色 #F5F5F5，文字色 #9E9E9E
```

#### 输入框使用规则
* **标签必填**：除非上下文明确
* **占位符提示**：使用示例值，不是说明文字
* **输入验证**：实时验证或失焦验证
* **错误提示**：具体说明问题和解决方法
* **密码输入**：提供显示/隐藏切换

---

### Navigation Bar 导航栏

```
高度: 56px
背景色: #FFFFFF
边框: 底部 1px solid #E0E0E0
阴影: 0 2px 4px rgba(0, 0, 0, 0.1)
内边距: 0 16px

结构:
  左侧区域:
    - 返回按钮（可选）: 48px × 48px 圆形触摸区域
    - 图标: 24px × 24px，颜色 #212121
  
  中间区域:
    - 标题: 18px Bold，#212121，居中，单行，超出省略
  
  右侧区域:
    - 文字按钮/图标按钮: 48px × 48px 触摸区域
    - 文字颜色: #2196F3

交互:
  - 按钮按下: 背景色 #F5F5F5，圆角 24px
```

#### 导航栏使用规则
* **标题简洁**：不超过 10 个汉字
* **返回按钮**：除首页外，其他页面必须有返回
* **右侧操作**：最多 2 个操作
* **固定位置**：始终固定在顶部，不随内容滚动

---

### Tab Bar 标签栏

```
高度: 56px
背景色: #FFFFFF
边框: 顶部 1px solid #E0E0E0

Tab 项:
  图标: 24px × 24px
  文字: 12px Regular
  间距: 图标与文字 4px
  颜色:
    - 未选中: #757575
    - 选中: #2196F3
  
  指示器:
    - 高度: 2px
    - 颜色: #2196F3
    - 位置: 底部
    - 动画: 滑动切换 300ms ease-in-out

触摸区域: 至少 48px × 48px
```

#### Tab 栏使用规则
* **标签数量**：2-5 个，最多不超过 5 个
* **标签文字**：简洁，2-4 个汉字
* **固定位置**：底部固定（手机）或顶部固定（平板）
* **默认选中**：首次进入默认选中第一个

---

### Dialog 对话框

```
背景色: #FFFFFF
圆角: 16px
最大宽度: 320px
内边距: 24px
阴影: 0 20px 25px rgba(0, 0, 0, 0.15)

结构:
  1. 标题: 20px Semibold，#212121，间距 16px
  2. 内容: 16px Regular，#424242，行高 24px，间距 24px
  3. 操作按钮: 右对齐，间距 8px

遮罩层:
  颜色: rgba(0, 0, 0, 0.5)
  可点击关闭: 是（除强制对话框）

动画:
  进入: 淡入 + 缩放 0.9 → 1.0，300ms
  退出: 淡出 + 缩放 1.0 → 0.95，200ms
```

#### 对话框使用规则
* **标题必填**：清晰说明目的
* **内容简洁**：不超过 3 行，必要时滚动
* **按钮排列**：取消在左，确认在右
* **危险操作**：使用红色按钮，二次确认
* **避免嵌套**：不要在对话框中打开对话框

---

### List 列表

```
列表项高度:
  - 单行文本: 48px
  - 双行文本: 64px
  - 三行文本: 80px

列表项结构:
  左侧图标/头像（可选）: 40px × 40px，右间距 16px
  主要内容:
    - 标题: 16px Medium，#212121
    - 副标题: 14px Regular，#757575，间距 4px
  右侧内容（可选）:
    - 文字: 14px Regular，#757575
    - 图标: 20px × 20px，#757575
    - 操作按钮: 36px × 36px

分割线:
  颜色: #EEEEEE
  高度: 1px
  缩进: 左侧 72px（有图标）/ 16px（无图标）

背景色:
  - Default: #FFFFFF
  - Hover: #F5F5F5
  - Pressed: #EEEEEE
  - Selected: #E3F2FD
```

#### 列表使用规则
* **滑动操作**：左滑显示删除/编辑等操作
* **长按操作**：触发多选模式
* **空状态**：显示友好的空状态提示
* **加载更多**：底部显示加载指示器
* **下拉刷新**：支持下拉刷新操作

---

### Switch 开关

```
宽度: 52px
高度: 32px
圆角: 16px（全圆角）

滑块:
  直径: 28px
  阴影: 0 2px 4px rgba(0, 0, 0, 0.2)

颜色:
  - 关闭: 背景 #E0E0E0，滑块 #FFFFFF
  - 打开: 背景 #2196F3，滑块 #FFFFFF
  - 禁用: 背景 #F5F5F5，滑块 #E0E0E0

动画:
  滑块移动: 200ms ease-in-out
  颜色过渡: 150ms ease
```

---

## 🖼️ 图标系统

### 图标尺寸标准

```
xs:  12px - 辅助图标，标签图标
sm:  16px - 行内图标，按钮图标
md:  20px - 列表图标，输入框图标
lg:  24px - 导航图标，工具栏图标 ← 默认
xl:  32px - 功能图标，标签页图标
xxl: 48px - 大型功能图标，占位图标
```

### 图标风格

* **线性图标**：描边 2px，用于界面导航和操作按钮
* **填充图标**：实心填充，用于状态指示和选中状态
* **双色图标**：主色 + 辅助色，用于品牌展示

### 图标使用规则

* **保持风格一致**：全局使用统一风格的图标集
* **可识别性**：图标含义清晰，必要时配文字
* **可点击区域**：图标按钮最小触摸区域 44px × 44px
* **颜色继承**：图标颜色随上下文文字颜色变化
* **对齐方式**：与文字基线对齐或居中对齐

---

## 🎬 动画效果

### 缓动函数（Easing Functions）

```
ease-in:      cubic-bezier(0.4, 0, 1, 1)      // 加速进入
ease-out:     cubic-bezier(0, 0, 0.2, 1)      // 减速退出 ← 推荐
ease-in-out:  cubic-bezier(0.4, 0, 0.2, 1)    // 先加速后减速
ease-sharp:   cubic-bezier(0.4, 0, 0.6, 1)    // 尖锐过渡
```

### 动画时长（Duration）

```
fast:    150ms  // 简单状态变化（颜色、不透明度）
normal:  300ms  // 中等复杂度动画（位移、缩放） ← 默认
slow:    500ms  // 复杂动画（页面转场）
```

### 常用动画效果

#### 按钮按下
```
Transform: scale(0.98)
Duration: 150ms
Easing: ease-out
```

#### 卡片悬停
```
Transform: translateY(-2px)
Shadow: 增强阴影
Duration: 200ms
Easing: ease-out
```

#### 对话框进入
```
Opacity: 0 → 1
Transform: scale(0.9) → scale(1)
Duration: 300ms
Easing: ease-out
```

#### 列表项滑入
```
Transform: translateX(-20px) → translateX(0)
Opacity: 0 → 1
Duration: 300ms
Easing: ease-out
Stagger: 50ms（多个列表项依次动画）
```

### 动画使用原则

* **性能优先**：只动画 transform 和 opacity
* **避免过度**：不要让所有元素都有动画
* **响应快速**：用户操作反馈必须在 100ms 内
* **可关闭**：尊重系统"减少动画"设置
* **有意义**：动画要传达信息，不是装饰

---

## 📱 响应式设计

### 断点（Breakpoints）

```
xs:  0px    - 360px    // 小屏手机
sm:  640px  - 768px    // 大屏手机
md:  768px  - 1024px   // 平板竖屏
lg:  1024px - 1280px   // 平板横屏 / 小笔记本
xl:  1280px - 1536px   // 桌面
xxl: 1536px+           // 大屏桌面
```

### 响应式布局策略

#### 手机端（xs - sm）
```
- 单列布局为主
- 导航栏高度 56px
- 底部 Tab 栏高度 56px
- 页面左右边距 16px
- 组件全宽度或半宽度（50%）
- 字体大小不低于 16px
```

#### 平板端（md - lg）
```
- 2-3 列布局
- 导航栏可展示更多信息
- 侧边栏宽度 256px
- 页面左右边距 32px
- 利用横向空间展示辅助信息
```

#### 桌面端（xl - xxl）
```
- 3-4 列布局
- 固定最大宽度 1200px，居中显示
- 导航栏横向排列
- 悬浮提示、快捷操作更丰富
- 利用鼠标 hover 状态
```

### 触摸目标尺寸

```
最小触摸区域: 44px × 44px
推荐触摸区域: 48px × 48px
触摸目标间距: 至少 8px
```

---

## ♿ 无障碍设计

### 颜色对比度

```
正文文字（16px 以下）: 至少 4.5:1
大文字（18px Bold 或 24px+）: 至少 3:1
图标和图形: 至少 3:1
UI 组件: 至少 3:1
```

### 焦点指示

```
焦点框样式:
  Border: 2px solid #2196F3
  Border Radius: 继承元素圆角
  Offset: 2px
  Outline: none

键盘导航顺序:
  遵循视觉顺序，从上到下，从左到右
```

### 屏幕阅读器

* **图片 Alt 文本**：所有信息性图片必须有描述
* **按钮标签**：使用语义化的 aria-label
* **表单关联**：Label 必须与 Input 正确关联
* **动态内容**：使用 aria-live 区域通知变化

### 无障碍检查清单

- [ ] 所有交互元素可通过键盘访问
- [ ] 焦点顺序符合逻辑
- [ ] 颜色对比度符合 WCAG AA 标准
- [ ] 不仅依赖颜色传达信息
- [ ] 表单有清晰的错误提示
- [ ] 动画可通过系统设置关闭
- [ ] 文字可放大至 200% 而不破坏布局

---

## 🔧 Figma 设计技巧

### 组件命名规范

```
Button/Primary/Medium
Button/Secondary/Large
Card/Standard/Elevated
Input/Text/Error
Navigation/TopBar/WithBack
```

### 变体（Variants）使用

* **状态变体**：Default, Hover, Pressed, Disabled
* **尺寸变体**：Small, Medium, Large
* **类型变体**：Primary, Secondary, Tertiary

### Auto Layout 设置

```
按钮:
  Direction: Horizontal
  Spacing: 8px
  Padding: 8px 16px
  Resizing: Hug Contents

卡片:
  Direction: Vertical
  Spacing: 12px
  Padding: 16px
  Resizing: Fill Container

列表项:
  Direction: Horizontal
  Spacing: 16px
  Padding: 16px
  Resizing: Fill Container
```

### 样式库（Styles）

创建以下共享样式：
```
颜色样式:
  - Primary/Blue
  - Success/Green
  - Error/Red
  - Neutral/Gray-100 ~ Gray-900

文字样式:
  - Display
  - Title
  - Heading
  - Body
  - Caption

效果样式:
  - Shadow/Elevation-1 ~ Elevation-4
  - Blur/Background
```

---

## ✅ 设计检查清单

### 视觉设计
- [ ] 使用标准颜色系统
- [ ] 字体大小符合规范
- [ ] 间距使用 8px 网格
- [ ] 圆角统一使用 8px 或 12px
- [ ] 阴影层级正确

### 交互设计
- [ ] 所有按钮有 hover/pressed 状态
- [ ] 输入框有 focus/error 状态
- [ ] 触摸区域不小于 44px
- [ ] 有清晰的视觉反馈
- [ ] 动画流畅自然

### 响应式设计
- [ ] 考虑手机/平板/桌面三种屏幕
- [ ] 使用 Auto Layout 实现响应式
- [ ] 文字和图片可缩放
- [ ] 横屏和竖屏都可用

### 无障碍设计
- [ ] 颜色对比度合格
- [ ] 有清晰的焦点指示
- [ ] 不仅依赖颜色区分信息
- [ ] 图标有文字标签

### 一致性
- [ ] 组件风格统一
- [ ] 间距规律一致
- [ ] 交互模式一致
- [ ] 与系统设计语言一致

---

## 📚 参考资源

* **HarmonyOS 设计官网**: https://developer.harmonyos.com/cn/design/
* **组件库**: 使用此指南创建的 Figma 组件库
* **图标库**: HarmonyOS Sans Icons
* **字体**: HarmonyOS Sans 字体家族

---

**最后更新时间**: 2025年10月24日
**版本**: v1.0
**维护者**: Local Database System Team
