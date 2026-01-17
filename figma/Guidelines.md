# Figma "Make" 模式 - Healthy_life 健康应用设计指南

> **核心原则**: 参考 Apple Fitness 设计风格，打造符合 HarmonyOS 规范的健康应用 UI。所有设计元素应遵循 `globals2.css` 中定义的变量,以确保与最终代码实现一致。

> **重要说明**: 本指南提供 Figma AI 提示词模板，你需要手动将提示词复制到 Figma 的 "Make" 功能中生成设计。AI 无法直接访问你的 Figma 账户。

---

## 📋 目录
1. [全局风格提示词](#1-全局风格提示词-universal-style-guide)
2. [设计规范速查](#2-设计规范速查)
3. [核心页面设计提示](#3-核心页面设计提示-prompts-for-make-mode)
4. [核心组件设计提示](#4-核心组件设计提示)
5. [如何使用](#5-如何使用)

---

## 1. 全局风格提示词 (Universal Style Guide)

### 🎯 统一设计语言 (在每个提示词前添加)

```
Design System Context:
- Style: Modern, clean, inspired by Apple Fitness and HarmonyOS Design Language
- Color palette: Primary blue (#007DFF), vibrant gradients for data cards
- Typography: System font, clear hierarchy (24px titles, 16px body, 14px captions)
- Spacing: 8px grid system (16px standard padding, 12px card gaps, 24px section spacing)
- Border radius: 12px for cards, 24px for buttons
- Shadows: Subtle elevation (0 2px 8px rgba(0,0,0,0.06) for cards)
- Icons: Emoji-based (48px for features, 32px for actions, 24px for labels)
- Interaction: Smooth transitions, clear feedback, minimum 44px touch targets
- Accessibility: High contrast text (#212121 on white, white on colored backgrounds)
```

### 📝 使用方法

**方式 1 - 单次使用（推荐初次测试）**
```
将上面的 "Design System Context" 内容 + 具体页面提示词一起粘贴到 Figma Make
```

**方式 2 - 批量使用（推荐批量生成）**
```
先在 Figma 中创建一个 Text Layer 包含 Design System Context
然后在生成时引用："Following the design system in [Text Layer Name], create..."
```

---

## 2. 设计规范速查

### 🎨 颜色系统

#### 主色调（参考 Apple Fitness + HarmonyOS）
```
主蓝色（品牌色）: #007DFF        // HarmonyOS 标准蓝
深蓝色: #0062CC                  // 按压态
浅蓝色: #4DA3FF                  // 悬停态
```

#### 运动类型颜色（参考 Apple Fitness）
```
跑步/跳绳: #FF9800    // 橙色
瑜伽/拉伸: #00C853    // 绿色
力量训练: #E53935     // 红色
骑行: #2196F3         // 蓝色
游泳: #00BCD4         // 青色
步行: #9C27B0         // 紫色
```

#### Activity Rings 配色
```
Move Ring (活动):    #FA114F    // 红色
Exercise Ring (锻炼): #92E82A    // 绿色
Stand Ring (站立):    #00F0FF    // 青色
```

#### 中性色阶（使用最频繁）
```
gray-50:  #FAFAFA  // 最浅背景
gray-100: #F8F9FA  // 页面背景
gray-200: #F5F5F5  // 次级背景
gray-300: #EEEEEE  // 静音区域
gray-400: #E0E0E0  // 边框/分割线
gray-500: #BDBDBD  // 开关背景
gray-600: #9E9E9E  // 次要文本/占位符
gray-700: #757575  // 辅助文本
gray-800: #616161  // 正文
gray-900: #212121  // 主标题/前景色
```

#### 暗色模式
```
背景: #1A1A1A
卡片: #262626
边框: #404040
主色: #69F0AE (浅绿)
前景: #FAFAFA
```

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
- 正文最小字号 14px,移动端不小于 16px
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
Page:    左右 16px,顶部 16px,底部 24px
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
  背景: #00C853
  文字: #FFFFFF
  圆角: 8px
  高度: 40px
  内边距: 8px 16px

Secondary（次要）:
  背景: transparent
  边框: 1px solid #00C853
  文字: #00C853

Tertiary（文本按钮）:
  背景: 无
  文字: #00C853
  
最小触摸区域: 44px × 44px
```

#### Card 卡片
```
背景: #FFFFFF
圆角: 12px
内边距: 16px
边框: 1px solid #E0E0E0
阴影: 0 2px 12px rgba(0, 0, 0, 0.06)
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
  边框: 2px solid #00C853
  阴影: 0 0 0 2px rgba(0, 200, 83, 0.2)
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

## 3. 核心页面设计提示 (Prompts for Make Mode)

> **提示**: 使用时将 [第 1 节的全局风格提示词](#1-全局风格提示词-universal-style-guide) + 下面的具体提示词一起粘贴到 Figma Make

### **Prompt 1: Activity Summary Page (Homepage)**

```
[Design System Context - see section 1]

Create a mobile app screen for a HarmonyOS fitness app, inspired by Apple Fitness. 
Screen size: 360px × 780px (standard HarmonyOS phone).

Layout Structure:
1. Top Section (180px height):
   - 3 concentric Activity Rings centered
   - Inner ring (Move): #FA114F, 75% progress
   - Middle ring (Exercise): #92E82A, 60% progress
   - Outer ring (Stand): #00F0FF, 80% progress
   - Ring width: 12px, gap: 6px
   - Below rings: "238 / 350 CAL" (16px, bold)

2. Data Cards Section:
   - 2 horizontal cards with 12px gap
   - Card 1 (Left): 
     Background: gradient (#007DFF to #4DA3FF)
     Icon: 👟 (24px)
     Title: "Steps" (14px, white, regular)
     Value: "8,432" (24px, white, bold)
     Subtitle: "Goal 10,000" (12px, white 0.7 opacity)
   
   - Card 2 (Right):
     Background: gradient (#00C853 to #69F0AE)
     Icon: 🚶 (24px)
     Title: "Distance" (14px, white, regular)
     Value: "6.2 km" (24px, white, bold)

3. Workout Sessions Section:
   - Title: "Recent Workouts" (18px, bold, #212121)
   - List of 3 workout cards (16px vertical gap):
     * Card: white background, 12px radius, 16px padding
     * Layout: Icon (40px) | Title + Duration + Calories | Play button (32px)
     * Example: 🏃 "Running" "30 min" "245 Cal"

4. Awards Section:
   - Title: "Achievements" (18px, bold)
   - Horizontal scroll: 4 circular badges (56px diameter)
   - Badge: gradient background, icon, subtle shadow

Background: #F5F5F5
Spacing: 16px page padding, 24px section gaps
Border radius: 12px for cards
```

### **Prompt 2: Workout Library Page (Exercise Types)**

```
[Design System Context - see section 1]

Create a mobile fitness app screen showing workout types in a grid layout.
Screen size: 360px × 780px.

Header:
- Title: "Workout Types" (24px, bold, #212121)
- Background: white
- Height: 56px

Grid Layout (3 columns):
- 12 workout type cards
- Card size: 108px × 120px
- Gap: 8px horizontal, 12px vertical
- 16px page padding

Each Card:
- Background: white
- Border: 1px solid #E0E0E0 (default)
- Border: 2px solid #007DFF (selected state)
- Border radius: 12px
- Center aligned content
- Padding: 16px

Card Content:
- Icon: 48px emoji at top
- Label: 14px, regular, #212121
- 8px gap between icon and label

Workout Types:
1. 🏃 "Running" 
2. 🚴 "Cycling"
3. 🧘 "Yoga"
4. 🏋️ "Strength"
5. 🏊 "Swimming"
6. 🚶 "Walking"
7. 🧗 "Climbing"
8. 🥊 "Boxing"
9. 🏀 "Basketball"
10. ⚽ "Soccer"
11. 🎾 "Tennis"
12. 🧘‍♀️ "Meditation"

Selected state: Cards 1, 3, 5 have blue border

Background: #FAFAFA
```

### **Prompt 3: Workout Detail Page (Training Details)**

```
[Design System Context - see section 1]

Create a mobile fitness app screen for workout details.
Screen size: 360px × 780px.

Top Section (200px):
- Background: gradient (#FF9800 to #FFB74D)
- Large workout icon: 80px emoji 🏃
- Workout title: "Outdoor Running" (24px, bold, white)
- Quick stats row:
  * "30 min" | "245 Cal" | "5.2 km"
  * 14px, white, 0.9 opacity
  * Separated by vertical dividers

Content Section (white background):
1. Description Card:
   - Title: "Description" (16px, bold)
   - Text: "Improve cardio fitness and burn calories with this outdoor running workout. Great for all levels." (14px, gray)
   - Background: white, 12px radius, 16px padding

2. Stats Grid (2×2):
   - Card 1: "Avg Pace" "5'32\"/km"
   - Card 2: "Heart Rate" "142 bpm"
   - Card 3: "Elevation" "+28m"
   - Card 4: "Cadence" "168 spm"
   - Each card: white, 12px radius, centered text

3. Action Button:
   - Text: "Start Workout" (16px, bold, white)
   - Background: #007DFF
   - Height: 48px, full width
   - Border radius: 24px
   - Box shadow: 0 4px 12px rgba(0, 125, 255, 0.3)

Spacing: 16px padding, 16px gaps between sections
```

## 3. 核心组件设计提示

### **Prompt 4: Activity Rings Component (Progress Rings)**

```
Create an Activity Rings component similar to Apple Watch.
Canvas: 200px × 200px, transparent background.

Three concentric rings:
1. Inner Ring (Move):
   - Color: #FA114F (red)
   - Radius: 50px (from center)
   - Stroke width: 12px
   - Progress: 75% (270 degree arc)
   - Rounded line caps

2. Middle Ring (Exercise):
   - Color: #92E82A (green)
   - Radius: 68px
   - Stroke width: 12px
   - Progress: 60% (216 degree arc)

3. Outer Ring (Stand):
   - Color: #00F0FF (cyan)
   - Radius: 86px
   - Stroke width: 12px
   - Progress: 80% (288 degree arc)

Background track: #E0E0E0, 0.3 opacity
All rings start from 12 o'clock position, clockwise
Add subtle glow effect to each ring (0 0 8px rgba with ring color, 0.5 opacity)
```

### **Prompt 5: Workout Card Component (Training Card)**

```
[Design System Context - see section 1]

Create a horizontal workout card component.
Size: 328px × 80px.

Layout (left to right):
1. Icon Container:
   - Size: 48px × 48px
   - Background: gradient based on workout type
   - Border radius: 24px (circular)
   - Centered emoji icon: 32px

2. Content Column:
   - Workout name: 16px, bold, #212121
   - Duration: 14px, regular, #757575
   - Calories: 14px, regular, #757575
   - Example layout: "Running" | "30 min · 245 Cal"

3. Action Button:
   - Icon: ▶ (play symbol)
   - Size: 32px × 32px
   - Background: #007DFF
   - Color: white
   - Border radius: 16px

Card Background: white
Border: 1px solid #E0E0E0
Border radius: 12px
Padding: 16px
Shadow: 0 2px 8px rgba(0, 0, 0, 0.06)
```

### **Prompt 6: Data Card Component (Stats Card)**

```
[Design System Context - see section 1]

Create a compact data display card.
Size: 160px × 120px.

Layout:
- Icon: 32px emoji at top (🔥 for calories)
- Label: "Burned" (12px, white, 0.8 opacity)
- Value: "245" (28px, bold, white)
- Unit: "Cal" (14px, white, 0.8 opacity)

Background: gradient (#FF9800 to #FFB74D)
Border radius: 12px
Padding: 16px
Center aligned content
Shadow: 0 4px 12px rgba(255, 152, 0, 0.2)

Create 4 variants:
1. Calories: 🔥 "Burned" "245 Cal" orange gradient (#FF9800 to #FFB74D)
2. Steps: 👟 "Steps" "8,432" blue gradient (#007DFF to #4DA3FF)
3. Distance: 🚶 "Distance" "6.2 km" green gradient (#00C853 to #69F0AE)
4. Time: ⏱ "Active" "52 min" purple gradient (#9C27B0 to #BA68C8)
```

### **Prompt 7: App Icon (Layered Icon)**

> **Note**: HarmonyOS icons are layered. Generate foreground and background separately.

**Foreground:**
```
Create a modern fitness app icon foreground.
Canvas: 1024px × 1024px, transparent background.

Design: Simplified Activity Rings
- 3 concentric circles (strokes only, no fill)
- Inner ring: red (#FA114F), 120px radius, 40px stroke width
- Middle ring: green (#92E82A), 180px radius, 40px stroke width
- Outer ring: cyan (#00F0FF), 240px radius, 40px stroke width
- All rings 75% complete (270 degree arc)
- Start at 12 o'clock position, clockwise direction
- Rounded line caps

Content occupies 70% of canvas (leave 15% margins on all sides)
No background color, no shadow effects
```

**Background:**
```
Create a gradient background for fitness app icon.
Canvas: 1024px × 1024px.

Gradient: linear gradient from top-left to bottom-right
- Start color: #007DFF (HarmonyOS blue)
- End color: #00C6FF (light cyan)

Solid gradient fill, no patterns or textures
```

---

## 5. 如何使用（完整工作流程）

### 步骤 1: 准备工作
1. 打开 Figma，登录你的账户
2. 创建新文件："Healthy_life UI Design"
3. 准备好 `globals2.css` 文件内容（颜色变量）

### 步骤 2: 使用 AI 生成设计

#### ⭐ 推荐方法（保证风格一致）
1. **复制全局风格提示词**: 
   - 从 [第 1 节](#1-全局风格提示词-universal-style-guide) 复制 "Design System Context" 完整内容
   
2. **复制具体页面提示词**: 
   - 选择需要的 Prompt（如 Prompt 1: Activity Summary 页面）
   - 复制从 "Create a mobile app..." 开始的完整内容
   
3. **合并粘贴到 Figma**:
   ```
   [全局风格提示词]
   
   [具体页面提示词]
   ```
   
4. **打开 Figma Make 模式**: 
   - 点击左上角 "+" 按钮
   - 选择 "Make with AI" 或按快捷键 `Ctrl/Cmd + /`
   
5. **粘贴合并后的提示词**: 完整内容粘贴到输入框

6. **生成设计**: 点击生成，Figma AI 会根据统一的设计系统创建

7. **微调细节**: 根据需要调整颜色、间距、字体等

### 步骤 3: 分享设计给 AI
1. **获取分享链接**:
   - 点击右上角 "Share" 按钮
   - 设置权限为 "Anyone with the link can view"
   - 复制链接（格式：https://figma.com/design/[fileKey]/[fileName]?node-id=1-2）

2. **提供给 AI**:
   - 将链接发送给我
   - 我会使用 Figma MCP 工具读取设计
   - 提取组件规格并生成 ArkTS 代码

### 步骤 4: AI 代码生成
我会自动执行：
1. 读取 Figma 设计节点信息
2. 提取布局、颜色、字体、间距等参数
3. 生成符合 HarmonyOS 规范的 ArkTS 组件代码
4. 适配深色模式和响应式布局

### 步骤 5: 代码实施
1. 将生成的代码集成到 `Healthy_life` 项目
2. 调试和优化性能
3. 真机测试

---

## 📌 重要提示

### ⚠️ AI 的能力边界
- ✅ **能做**: 生成详细的设计提示词
- ✅ **能做**: 读取你分享的 Figma 设计并提取规格
- ✅ **能做**: 根据设计生成 ArkTS 代码
- ❌ **不能做**: 直接登录你的 Figma 账户
- ❌ **不能做**: 在你的 Figma 中自动创建设计

### 🎯 最佳实践
1. **分步生成**: 先生成单个页面，测试效果后再批量生成
2. **保持一致**: 严格按照提示词中的尺寸和颜色值
3. **截图对比**: 参考 Apple Fitness 截图进行视觉比对
4. **迭代优化**: 生成后可以要求我调整提示词重新生成

### 🔗 相关资源
- `globals2.css` - 颜色和样式变量定义
- Apple Fitness 参考截图 - 用户提供
- HarmonyOS 设计规范 - https://developer.huawei.com/consumer/cn/design/

---

这套指南为你提供了一个完整的 Figma 设计到 HarmonyOS 代码的工作流程。如有疑问，请随时询问！
