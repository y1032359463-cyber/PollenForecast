# Figma "Make" Mode - CuteCalculator Design Guidelines

> **核心原则**: 创建一款温暖可爱的计算器应用，采用橙粉色系配色，卡通猫咪角色互动。遵循 HarmonyOS 设计语言和 `globals.css` 中定义的变量。

> **重要提示**: 本指南提供 Figma AI 提示词模板。你需要手动复制这些提示词到 Figma 的 "Make" 功能中生成设计。AI 无法直接访问你的 Figma 账号。

---

## 📋 目录
1. [通用设计系统](#1-通用设计系统)
2. [设计规范](#2-设计规范)
3. [页面提示词](#3-页面提示词)
4. [组件提示词](#4-组件提示词)
5. [图标系统](#5-图标系统)
6. [使用方法](#6-使用方法)

---

## 1. 通用设计系统

### 🎯 设计上下文（每个提示词前必须添加）

```
Design System Context:
- App: 可爱计算器 (CuteCalculator) - A lovely calculator with hand-drawn cute UI
- Style: Cute, warm, friendly, kawaii aesthetic
- Primary Color: Warm Orange (#FF8C42)
- Secondary Color: Soft Pink (#FFB3C1)
- Background: Cream (#FFF5E6)
- Typography: HarmonyOS Sans / SF Pro Rounded
  * Display: 32px/40px/Bold (titles)
  * Title: 28px/36px/Semibold (headers)
  * Body Large: 28px/36px/Semibold (button text)
  * Body: 24px/32px/Regular (expression text)
  * Result: 48px/56px/Bold (result display)
  * Caption: 14px/20px/Regular (small labels)
- Spacing: 8px grid system (all spacing must be multiples of 4px)
  * Button gap: 8px
  * Component padding: 16px
  * Section spacing: 24px
  * Page padding: 20px
- Border Radius:
  * Buttons: 20px (16vp)
  * Cards: 16px (12vp)
  * Character container: 16px
- Shadows:
  * Button: 0 4px 12px rgba(193, 119, 53, 0.15)
  * Card: 0 4px 16px rgba(255, 140, 66, 0.2)
  * Floating: 0 6px 20px rgba(255, 140, 66, 0.25)
- Character Design:
  * Style: Cute cartoon cat with movable arms
  * Export: LAYERED (body + arms separate)
  * Arm animation: Vertical movement 20-30px range
- Icons:
  * Style: Rounded, friendly, simple
  * Sizes: 24px (navigation), 32px (feature)
- Interaction:
  * Minimum touch target: 44px × 44px
  * Animation duration: 150ms press, 300ms character
  * Press effect: scale(0.95)
- Accessibility:
  * High contrast text on colored buttons (#FFFFFF on #FF8C42)
  * Clear visual hierarchy
  * Large touch targets
```

---

## 2. 设计规范

### 🎨 颜色系统

#### 品牌色（可爱风格）
```
主题橙色:           #FF8C42  // 主色调、等号按钮、CTA
主题橙色-深色:      #E67A2E  // Hover 状态
主题橙色-浅色:      #FFA15C  // Press 状态
主题橙色-极浅:      #FFE4CC  // 边框、高亮

主题粉色:           #FFB3C1  // 次要色、装饰
主题粉色-深色:      #E69FAD  // Hover 状态
主题粉色-浅色:      #FFC7D5  // 腮红、柔和背景
```

#### 功能色
```
背景-奶油色:        #FFF5E6  // 页面背景、数字按钮
背景-白色:          #FFFFFF  // 卡片、输入框
背景-极浅:          #FFFBF5  // 微妙高亮

运算符橙:           #FFB366  // 运算符按钮 (+,-,×,÷,%)
清空红:             #FF6B6B  // 清空按钮(C)
删除灰:             #D1D1D6  // 删除按钮(DEL)

成功绿:             #4CAF50  // 成功状态（保留）
```

#### 文字颜色
```
主文字-深棕:        #C17735  // 标题、数字、主要文本
次要文字-灰:        #8E8E93  // 副标题、说明文字
白色文字:           #FFFFFF  // 按钮上的白色文字
```

#### 深色模式（可选）
```
背景:               #1C1C1E  // 纯黑背景
卡片:               #2C2C2E  // 卡片背景
边框:               #48484A  // 分隔线

主色-亮橙:          #FF9F5C  // 主题色调整
主文字:             #FAFAFA  // 白色主文字
次要文字:           #AEAEB2  // 灰色次要文字
```

---

### 📝 字体层级

```
Display (页面标题):
  32px / 40px / Bold (700)
  使用场景: 应用标题"可爱计算器"

Title (区域标题):
  28px / 36px / Semibold (600)
  使用场景: 设置页面标题、对话框标题

Button Text (按钮文字):
  28px / 36px / Semibold (600)
  使用场景: 所有计算器按钮上的数字/符号

Expression Text (表达式):
  24px / 32px / Regular (400)
  使用场景: 当前输入的计算表达式

Result Display (结果显示):
  48px / 56px / Bold (700)  ← 最大最醒目
  使用场景: 计算结果数字

Caption (说明文字):
  14px / 20px / Regular (400)
  使用场景: 按钮标签、小提示
```

**字体规则**:
- 最小文字: 14px
- 行高: 1.4x（按钮）, 1.5x（正文）
- 字体: HarmonyOS Sans (首选) 或 SF Pro Rounded

---

### 📐 间距系统（8px 网格）

**所有间距必须是 4px 的倍数**

```
4px   (xs)   - 图标与文字间隙
8px   (sm)   - 按钮之间的间距  ← 计算器键盘专用
12px  (m-)   - 组内元素间距
16px  (md)   - 组件内边距、卡片 padding
20px  (lg)   - 页面左右边距
24px  (xl)   - 区域之间的间距
32px  (xxl)  - 大区块间距
```

**组件内边距标准**:
```
按钮:         无内边距（图片素材）
结果卡片:     20px
页面:         left/right 20px, top 16px, bottom safe area
角色容器:     16px
```

---

### 🔘 圆角规范

```
--radius-button:   20px   (按钮 @3x = 60px)
--radius-card:     16px   (卡片)
--radius-container: 16px  (容器)
--radius-large:    24px   (对话框)
```

**注意**: Figma 设计时使用 @3x 尺寸，圆角也要 ×3

---

### 🎬 动画参数

```
Duration:
  fast:   100ms  // 按钮按压
  normal: 200ms  // 手臂动画回弹
  slow:   300ms  // 角色状态切换

Easing:
  ease-out: cubic-bezier(0, 0, 0.2, 1)  ← 推荐

常用动画:
  按钮按压:     scale(0.95) / 100ms
  手臂下移:     translateY(30px) / 80ms
  手臂回弹:     translateY(0) / 120ms
  状态切换:     opacity fade / 300ms
```

---

### 🖼️ 图标系统

#### 图标尺寸
```
sm:  16px - 内联小图标
md:  20px - 列表图标
lg:  24px - 导航图标  ← 默认
xl:  32px - 特征图标
```

#### 图标风格
```
风格: 圆润、友好、简洁
描边: 2px
颜色: 单色或双色
最小触摸区域: 44px × 44px
```

#### 所需图标（8个）
```
ic_history      - 历史记录（时钟倒转）
ic_settings     - 设置（齿轮）
ic_back         - 返回（左箭头）
ic_arrow_right  - 右箭头
ic_theme        - 主题切换（月亮/太阳）
ic_vibrate      - 振动开关（震动符号）
ic_character    - 角色选择（猫爪）
ic_clear_data   - 清空数据（垃圾桶）
```

---

## 3. 页面提示词

> **提示**: 使用时结合 [通用设计系统](#1-通用设计系统) + 下方具体提示词

**可用提示词**:
- Prompt 1: 主计算器界面（唯一页面）

**对应文件**: `01_主计算器界面.txt`

---

### **Prompt 1: 主计算器界面（Main Calculator Page)**

```
[Design System Context - see section 1]

Create a mobile cute calculator app screen for HarmonyOS.
Screen size: 360px × 780px (standard phone).

Layout Structure:

1. Header Section (56px height):
   - Background: gradient (#FF8C42 to #FFB3C1)
   - Left: App title "可爱计算器" (20px, bold, white)
   - Right: Two icons (24px each, white, 16px gap)
     * History icon (clock)
     * Settings icon (gear)
   - Padding: 16px horizontal
   - Shadow: 0 2px 8px rgba(255, 140, 66, 0.3)

2. Character Section (180px height):
   - Background: #FFF5E6
   - Cute cat character (150×150px)
   - Position: center horizontally
   - Style: kawaii cartoon, orange-pink colors
   - Visible arms (for animation)
   - Expression: happy smile

3. Result Display (140px height):
   - Background: white card
   - Border radius: 16px
   - Padding: 20px
   - Margin: 0 20px
   - Shadow: 0 4px 12px rgba(0, 0, 0, 0.08)
   
   Content:
   - Expression text (top):
     * Font: 24px, regular, #8E8E93
     * Align: right
     * Example: "123 + 456"
   
   - Result text (bottom):
     * Font: 48px, bold, #C17735
     * Align: right
     * Example: "579"

4. Keyboard Section (480px height):
   - Background: #FFF5E6
   - Grid: 4 columns × 5 rows
   - Button size: 80×80px (standard)
   - Gap: 8px between buttons
   - Padding: 20px horizontal, 16px vertical
   
   Button Layout:
   Row 1: C    | DEL  | %    | ÷
   Row 2: 7    | 8    | 9    | ×
   Row 3: 4    | 5    | 6    | -
   Row 4: 1    | 2    | 3    | +
   Row 5: 0 (double width) | .    | =
   
   Button Colors (see separate component prompts):
   - Numbers (0-9): #FFF5E6 background, #C17735 text
   - Operators (+,-,×,÷,%): #FFB366 background, white text
   - Equal (=): #FF8C42 background, white text (TALL: 168×80px)
   - Clear (C): #FF6B6B background, white text
   - Delete (DEL): #D1D1D6 background, #C17735 text
   - Dot (.): #FFF5E6 background, #C17735 text

5. Safe Area (Bottom):
   - Height: 24px (for gesture bar)
   - Background: #FFF5E6

Design Notes:
- All buttons have 20px border radius (@3x = 60px)
- Shadows: 0 4px 12px rgba(193, 119, 53, 0.15)
- Smooth gradient transitions
- Character should have clear separation (body + arms)
- High contrast for accessibility
- Minimum 44px touch targets

Page Background: #FFF5E6 (cream color)
```

---

## 4. 组件提示词

**可用提示词**:
- Prompt 2: 数字按钮（0-9）
- Prompt 3: 运算符按钮（+,-,×,÷,%）
- Prompt 4: 功能按钮（=,C,DEL,.）
- Prompt 5: 卡通角色（猫咪4状态×2层）
- Prompt 6: 结果显示卡片
- Prompt 7: 导航图标组

**对应文件**: `02_数字按钮素材.txt`, `03_运算符按钮素材.txt`, `04_功能按钮素材.txt`, `05_卡通角色素材.txt`, `06_结果卡片.txt`, `07_导航图标.txt`

---

### **Prompt 2: 数字按钮组件（已在独立文件中）**

参见 `02_数字按钮素材.txt`

---

### **Prompt 3: 运算符按钮组件（已在独立文件中）**

参见 `03_运算符按钮素材.txt`

---

### **Prompt 4: 功能按钮组件（已在独立文件中）**

参见 `04_功能按钮素材.txt`

---

### **Prompt 5: 卡通角色组件（已在独立文件中）**

参见 `05_卡通角色素材.txt`

---

### **Prompt 6: 结果显示卡片组件**

```
[Design System Context - see section 1]

Create a result display card component for cute calculator.
Size: 320px × 140px (@3x scale: 960px × 420px).

Layout:
- Background: white (#FFFFFF)
- Border: 1px solid #FFE4CC (light orange border)
- Border radius: 16px (@3x = 48px)
- Padding: 20px (@3x = 60px)
- Shadow: 0 4px 12px rgba(0, 0, 0, 0.08)

Content Structure (vertical stack):

1. Expression Text (top):
   - Font: 24px, regular, #8E8E93
   - Text align: right
   - Line height: 32px
   - Max lines: 2
   - Example: "123 + 456 - 78"

2. Spacer: 8px vertical gap

3. Result Text (bottom):
   - Font: 48px, bold, #C17735
   - Text align: right
   - Line height: 56px
   - Max lines: 1
   - Example: "501"

Create 4 variants with different expressions:
1. Simple: "8 + 2" → "10"
2. Medium: "123 × 4" → "492"
3. Complex: "789 - 456 + 12" → "345"
4. Decimal: "25 ÷ 4" → "6.25"

Design Notes:
- Ensure text doesn't overflow
- Right-aligned for natural reading of numbers
- Clear visual hierarchy (result larger than expression)
- Subtle card elevation
```

---

### **Prompt 7: 导航图标组件**

```
[Design System Context - see section 1]

Create a set of navigation icons for cute calculator app.
Canvas: 24px × 24px per icon (@3x scale: 72px × 72px).

Icon Style:
- Style: Rounded, friendly, simple
- Stroke width: 2px
- Color: Single color (will be applied dynamically)
- Background: Transparent
- Minimum visual weight for 24px size

Icons Needed (8 icons):

1. ic_history
   - Design: Clock with counter-clockwise arrow
   - Represents: History / past records

2. ic_settings
   - Design: Gear/cog wheel
   - Represents: Settings / preferences

3. ic_back
   - Design: Left-pointing chevron arrow
   - Represents: Back / return

4. ic_arrow_right
   - Design: Right-pointing chevron arrow
   - Represents: Navigate forward / more info

5. ic_theme
   - Design: Sun/moon toggle symbol
   - Represents: Theme switcher

6. ic_vibrate
   - Design: Phone with vibration waves
   - Represents: Vibration toggle

7. ic_character
   - Design: Cute paw print
   - Represents: Character selection

8. ic_clear_data
   - Design: Trash bin
   - Represents: Clear history / delete data

Export Requirements:
- Format: SVG (vector)
- Size: 72px × 72px (@3x)
- Stroke: 2px
- Colors: Use #000000 (will be tinted in code)
- Naming: ic_[name].svg

Design Notes:
- Ensure clear recognition at 24px display size
- Consistent stroke weight across all icons
- Rounded line caps and joins
- Centered within canvas
- Minimum 2px gap from edges
```

---

## 5. 图标系统

### 图标需求

#### 主要图标来源: IconPark 或手绘
- **风格**: 圆润、友好
- **描边宽度**: 2px
- **导出**: SVG 矢量格式
- **许可**: MIT (可商用)

#### 8个核心图标

```
1. ic_history      - 历史记录
2. ic_settings     - 设置
3. ic_back         - 返回
4. ic_arrow_right  - 前进箭头
5. ic_theme        - 主题切换
6. ic_vibrate      - 振动开关
7. ic_character    - 角色选择
8. ic_clear_data   - 清空数据
```

#### 图标使用指南

```
导航图标 (24px):
- 顶部导航栏: ic_history, ic_settings
- 返回按钮: ic_back

列表图标 (20px):
- 设置列表项

内联图标 (16px):
- 开关旁边的标识
```

#### 图标文件命名规范
```
格式: ic_[名称].svg
示例:
- ic_history.svg
- ic_settings.svg
- ic_back.svg
```

---

## 6. 使用方法

### 步骤 1: 准备工作
1. 打开 Figma 并登录账号
2. 创建新文件: "CuteCalculator UI Design"
3. 准备好本指南和 `globals.css` 作为参考

### 步骤 2: 用 AI 生成设计

#### ⭐ 推荐工作流（确保一致性）

1. **复制通用设计系统**:
   - 从 [第1节](#1-通用设计系统)
   - 复制完整的 "Design System Context" 块

2. **复制具体页面/组件提示词**:
   - 选择所需提示词（例如 Prompt 2: 数字按钮）
   - 从 "Create a..." 开始复制

3. **合并并粘贴到 Figma**:
   ```
   [Design System Context]
   
   [Specific Prompt]
   ```

4. **打开 Figma Make 模式**:
   - 快捷键: `Cmd/Ctrl + /`
   - 或点击顶部 "Resources" → "Make"

5. **粘贴合并后的提示词**

6. **点击生成**

7. **检查并调整**:
   - 颜色是否精确（#FF8C42, #FFB3C1, #FFF5E6）
   - 尺寸是否正确（200×200px @3x = 600px）
   - 圆角是否符合（48px @3x）
   - 阴影效果是否正确

### 步骤 3: 分享设计给 AI 评估
1. 点击 Figma 右上角 "Share"
2. 设置为 "Anyone with the link can view"
3. 复制链接
4. 在 VS Code 中告诉 AI: "请查看我的 Figma 设计: [链接]"

### 步骤 4: 导出素材
1. 选中要导出的元素
2. 右侧面板 → "Export" 区域
3. 添加导出设置:
   - Format: PNG
   - Size: 3x
   - (角色素材: 分层导出 body + arms)
4. 点击 "Export"

### 步骤 5: 命名和组织
按照规范命名:
```
buttons/
  btn_0.png ~ btn_9.png
  btn_plus.png, btn_minus.png, btn_multiply.png, btn_divide.png
  btn_equal.png, btn_clear.png, btn_delete.png, btn_dot.png, btn_percent.png

characters/
  cat_normal_body.png, cat_normal_arms.png
  cat_calculating_body.png, cat_calculating_arms.png
  cat_result_body.png, cat_result_arms.png
  cat_error_body.png, cat_error_arms.png

icons/
  ic_history.svg, ic_settings.svg
  ic_back.svg, ic_arrow_right.svg
  (其他图标...)
```

---

## 📊 设计检查清单

### 颜色检查
- [ ] 主题橙 #FF8C42 精确匹配
- [ ] 主题粉 #FFB3C1 精确匹配
- [ ] 奶油背景 #FFF5E6 精确匹配
- [ ] 文字棕色 #C17735 精确匹配
- [ ] 白色文字 #FFFFFF 用于彩色按钮

### 尺寸检查
- [ ] 标准按钮: 600×600px (@3x)
- [ ] 数字0按钮: 1248×600px (双倍宽)
- [ ] 等号按钮: 600×1248px (双倍高)
- [ ] 角色素材: 900×900px (@3x)
- [ ] 图标: 72×72px (@3x)

### 导出检查
- [ ] PNG 格式（按钮、角色）
- [ ] SVG 格式（图标）
- [ ] @3x 倍率
- [ ] 透明背景（按钮和角色）
- [ ] 角色分层导出（body + arms）

### 细节检查
- [ ] 圆角 48px (@3x)
- [ ] 阴影效果正确
- [ ] 文字对齐正确
- [ ] 渐变方向正确
- [ ] 触摸区域足够大（44px最小）

---

## 🚀 快速开始指南

### 第一次使用
1. 阅读完整的设计规范（本文档）
2. 理解颜色系统和尺寸标准
3. 从最简单的开始：数字按钮（Prompt 2）

### 生成第一个设计
1. 复制通用设计系统
2. 复制 Prompt 2（数字按钮）
3. 在 Figma Make 中生成
4. 分享链接给 AI 评估

### 完成所有素材
建议顺序:
1. ✅ 数字按钮（02）- 最简单
2. ✅ 运算符按钮（03）
3. ✅ 功能按钮（04）
4. ✅ 导航图标（07）
5. ✅ 结果卡片（06）
6. ✅ 卡通角色（05）- 最复杂
7. ✅ 主界面（01）- 组合前面所有

**预计时间**: 熟练后 2-3 小时完成所有设计

---

## ⚠️ 常见问题

**Q: 为什么要用 @3x 尺寸？**  
A: HarmonyOS 使用 vp 单位。@3x 确保高分辨率屏幕清晰。200px @3x = 66.7vp。

**Q: 颜色必须完全精确吗？**  
A: 是的！#FF8C42 不等于 #FF8C43。视觉一致性很重要。

**Q: Figma Make 不理解中文？**  
A: 使用提供的英文提示词。需要修改告诉 AI 即可。

**Q: 角色怎么分层导出？**  
A: 身体和手臂放在不同 Frame，分别选中导出。

**Q: 可以手绘代替 Figma 吗？**  
A: 可以！只要符合尺寸、颜色、透明背景等规范。

**Q: 导出文件太大怎么办？**  
A: 使用 TinyPNG 或类似工具压缩，确保质量不损失太多。

---

**准备好了吗？开始创建你的可爱计算器设计！** 🎨🐱✨
