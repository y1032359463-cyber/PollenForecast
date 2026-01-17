# Figma "Make" 模式 - HarmonyOS 应用工厂设计指南

> **核心原则**: 简洁、现代、配置驱动。所有设计元素应遵循 `globals.css` 中定义的变量，以确保与最终代码实现一致。
> 
> **完整规范参考**: 详见 `Guidelines2.md` - 完整的 HarmonyOS 设计系统规范文档

---

## 📋 目录
1. [设计规范速查](#1-设计规范速查)
2. [核心组件设计提示](#2-核心组件设计提示-prompts-for-make-mode)
3. [如何使用](#3-如何使用)

---

## 1. 设计规范速查

> **本章节浓缩自 `Guidelines2.md`，提供 Figma AI 生成设计时的核心约束**

### 🎨 颜色系统

#### 主色调
```
华为蓝（品牌色）: #2196F3
华为橙（辅助色）: #FF9800
```

#### 功能色彩
```
成功 Success: #4CAF50
警告 Warning:  #FF9800
错误 Error:    #F44336
信息 Info:     #2196F3
```

#### 中性色阶（使用最频繁）
```
gray-50:  #FAFAFA  // 背景色
gray-100: #F5F5F5  // 页面背景
gray-200: #EEEEEE  // 分割线
gray-300: #E0E0E0  // 输入框边框
gray-400: #BDBDBD  // 占位符
gray-500: #9E9E9E  // 辅助文本
gray-600: #757575  // 次要文本
gray-700: #616161  // 正文
gray-900: #212121  // 主标题
```

#### 颜色对比度要求
- 正文文字（< 16px）：至少 4.5:1
- 大文字（≥ 18px Bold）：至少 3:1

---

### 📝 字体规范

#### HarmonyOS 标准字体规格
```
Display（页面主标题）:
  32px / 40px / Bold (700)

Title（章节标题）:
  28px / 36px / Bold (700)

Heading（小节标题）:
  24px / 32px / Semibold (600)

Subheading（子标题）:
  20px / 28px / Semibold (600)

Body Large（重要正文）:
  18px / 26px / Regular (400)

Body（常规正文）:
  16px / 24px / Regular (400)  ← 默认正文

Body Small（辅助文字）:
  14px / 20px / Regular (400)

Caption（说明文字）:
  12px / 16px / Regular (400)
```

**字体使用规则**:
- 正文最小字号 14px，移动端不小于 16px
- 行长度不超过 75 个字符（约 600px）

---

### 📐 间距系统

**8px 网格系统 - 所有间距必须是 4px 的倍数**

```
4px   (xs)   - 图标与文字间距
8px   (sm)   - 行内元素间距
12px  (m-)   - 组内元素间距
16px  (md)   - 组件内边距、列表项间距  ← 最常用
24px  (lg)   - 组件外边距、卡片内边距
32px  (xl)   - 章节间距
48px  (xxl)  - 页面区块间距
64px  (xxxl) - 大型区块分隔
```

**组件内边距标准**:
```
Button:  8px 16px (高度 40px)
Card:    16px
Input:   8px 12px (高度 40px)
Modal:   24px
Page:    左右 16px，顶部 16px，底部 24px
```

---

### 🔘 圆角规范

```
--radius-sm:  6px   (小标签)
--radius-md:  8px   (输入框、小按钮)
--radius:     10px  (标准按钮、卡片)  ← 默认
--radius-lg:  12px  (大卡片)
--radius-xl:  14px  (对话框)
```

---

### 🧩 核心组件规则

#### Button 按钮
```
Primary（主要）:
  背景: #2196F3
  文字: #FFFFFF
  圆角: 8px
  高度: 40px
  内边距: 8px 16px

Secondary（次要）:
  背景: transparent
  边框: 1px solid #2196F3
  文字: #2196F3

Tertiary（文本按钮）:
  背景: 无
  文字: #2196F3
  
最小触摸区域: 44px × 44px
```

#### Card 卡片
```
背景: #FFFFFF
圆角: 12px
内边距: 16px
边框: 1px solid #E0E0E0
阴影: 0 4px 6px rgba(0, 0, 0, 0.1)
```

#### Input 输入框
```
背景: #FFFFFF
边框: 1px solid #E0E0E0
圆角: 8px
内边距: 8px 12px
高度: 40px
字体: 16px Regular

Focus 状态:
  边框: 2px solid #2196F3
  阴影: 0 0 0 2px rgba(33, 150, 243, 0.2)
```

---

### 🎬 动画效果

```
Duration（时长）:
  fast:   150ms  // 颜色、不透明度
  normal: 300ms  // 位移、缩放  ← 默认
  slow:   500ms  // 页面转场

Easing（缓动）:
  ease-out: cubic-bezier(0, 0, 0.2, 1)  ← 推荐

常用动画:
  按钮按下: scale(0.98) / 150ms
  卡片悬停: translateY(-2px) / 200ms
  对话框进入: scale(0.9 → 1) + opacity(0 → 1) / 300ms
```

---

### 🖼️ 图标系统

```
xs:  12px - 辅助图标
sm:  16px - 行内图标
md:  20px - 列表图标
lg:  24px - 导航图标  ← 默认
xl:  32px - 功能图标
xxl: 48px - 大型图标

描边宽度: 2px
最小触摸区域: 44px × 44px
```

---

### 📱 响应式断点

```
xs:  0px    - 360px    // 小屏手机
sm:  640px  - 768px    // 大屏手机
md:  768px  - 1024px   // 平板
lg:  1024px - 1280px   // 桌面
xl:  1280px+           // 大屏桌面
```

---

## 2. 核心组件设计提示 (Prompts for Make Mode)

---

## 2. 核心组件设计提示 (Prompts for Make Mode)

### **Prompt 1: 创建应用主页 (Homepage)**

```
Create a mobile app screen for a HarmonyOS habit tracking app. The screen size is 1080x2400px.
Use a clean and modern design.
The background color is var(--background).
The layout should be a single column.
At the top, there is a header with the text "Today's Tasks" in a 24px font, font-weight 500.
Below the header, create a list of 3 task cards.
The cards should be vertically stacked with 16px spacing between them.
Each card should have a width of 100% with 16px horizontal padding on the screen.
```

### **Prompt 2: 设计核心任务卡片 (Task Card)**

```
Create a responsive task card component for a mobile app.
The card's background color is var(--card).
It has a border-radius of var(--radius) (10px) and a subtle border using var(--border).
The card has a fixed height of 80px and horizontal padding of 16px.
Inside the card, use a flexbox layout with space-between alignment.

On the left side:
- An icon placeholder (a 32x32px circle).
- To the right of the icon, display the task title "Drink Water" with font-size 16px and font-weight 500, color var(--foreground).
- Below the title, show progress text "3 / 8 cups" with font-size 14px, color var(--muted-foreground).

On the right side:
- A circular progress bar with a 40px diameter. The track color is var(--muted) and the progress fill color is var(--primary). Show 60% progress.
- Inside the circle, display the text "60%" with font-size 12px.
```

### **Prompt 3: 设计按钮 (Buttons)**

```
Create a set of three button variants based on our design system. All buttons have a border-radius of var(--radius) (10px) and a height of 48px.

1.  **Primary Button**:
    - Background color: var(--primary).
    - Text color: var(--primary-foreground).
    - Label: "Complete Task".
    - It should have a bold and solid appearance.

2.  **Secondary Button**:
    - Transparent background.
    - 1px border using var(--border).
    - Text color: var(--foreground).
    - Label: "Edit Task".

3.  **Tertiary Button (Text Button)**:
    - No background, no border.
    - Text color: var(--muted-foreground).
    - Label: "Skip".
```

### **Prompt 4: 设计应用图标 (App Icon)**

> **注意**: 鸿蒙图标是分层的，请分别生成前景和背景。

**前景 (Foreground):**
```
Create a simple, modern SVG icon for a habit tracking app.
The design should be a stylized checkmark combined with a leaf.
Use a single, solid color: var(--primary-foreground).
The icon should be centered on a 1024x1024px transparent canvas, with the main content occupying about 80% of the space to leave safe margins.
No background color.
```

**背景 (Background):**
```
Create a 1024x1024px SVG background.
It should be a solid color fill using var(--primary).
```

---

## 3. 如何使用

1.  **复制提示**: 将上面 ` ``` ` 中的提示文本完整复制。
2.  **粘贴到 Figma**: 在 Figma 的 "Make" 模式输入框中粘贴。
3.  **生成与调整**: AI 会根据 `globals.css` 的变量和您的提示生成设计。您可以在此基础上进行微调，以达到最佳效果。

这套指南为您提供了一个很好的起点，可以快速生成符合我们项目规范的UI组件。
