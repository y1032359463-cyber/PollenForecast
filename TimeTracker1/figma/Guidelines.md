# Figma "Make" Mode - TimeTracker Design Guidelines

> **Core Principle**: Create a smooth HarmonyOS-native time tracking app with minimalist design, inspired by modern productivity apps. All design elements follow HarmonyOS Design Language and the variables defined in `globals2.css`.

> **Important Note**: This guide provides Figma AI prompt templates. You need to manually copy these prompts into Figma's "Make" feature to generate designs. AI cannot directly access your Figma account.

---

## 📋 Table of Contents
1. [Universal Design System](#1-universal-design-system)
2. [Design Specifications](#2-design-specifications)
3. [Core Page Prompts](#3-core-page-prompts) - 4 页面提示词
4. [Component Prompts](#4-component-prompts) - 8 组件提示词
5. [Icon System](#5-icon-system)
6. [How to Use](#6-how-to-use)

---

## 1. Universal Design System

### 🎯 Design Context (Add Before Every Prompt)

```
Design System Context:
- App: 工时计 (WorkTimeTracker) - Time logging app for hourly workers
- Style: Minimalist, clean, inspired by Apple Calendar and HarmonyOS Design Language
- Primary Color: HarmonyOS Blue (#2196F3)
- Typography: HarmonyOS Sans font family
  * Display: 32px/40px/Bold (page titles)
  * Title: 28px/36px/Bold (section headers)
  * Heading: 24px/32px/Semibold (card titles)
  * Body: 16px/24px/Regular (default text)
  * Caption: 12px/16px/Regular (labels)
- Spacing: 8px grid system (all spacing must be multiples of 4px)
  * Standard padding: 16px
  * Card spacing: 12px gap
  * Section spacing: 24px
- Border Radius: 
  * Small: 6px (tags, chips)
  * Medium: 8px (inputs, small buttons)
  * Standard: 10px (cards, buttons)
  * Large: 12px (large cards)
- Shadows: Subtle elevation
  * Card: 0 2px 8px rgba(0,0,0,0.06)
  * Floating: 0 4px 12px rgba(0,0,0,0.08)
- Icons: 
  * Use IconPark linear style icons + HarmonyOS Symbol
  * Sizes: 16px (inline), 20px (list), 24px (navigation), 32px (feature)
- Interaction:
  * Minimum touch target: 44px × 44px
  * Animation duration: 300ms (ease-out curve)
- Accessibility: High contrast
  * Light mode: #212121 on white, white on colored backgrounds
  * Dark mode: #FAFAFA on #1C1C1E
```

---

## 2. Design Specifications

### 🎨 Color System

#### Brand Colors (HarmonyOS Standard)
```
Primary Blue:      #2196F3  // Brand color, CTAs, active states
Primary Hover:     #1976D2  // Hover state
Primary Pressed:   #1565C0  // Press state
Primary Light:     #BBDEFB  // Light background
Primary Lighter:   #E3F2FD  // Subtle highlights
```

#### Status Colors
```
Success Green:     #4CAF50  // Completed, positive
Warning Orange:    #FF9800  // Alerts, warnings
Error Red:         #F44336  // Errors, deletions
Info Blue:         #2196F3  // Information
```

#### Gray Scale (Light Mode)
```
gray-50:  #FAFAFA  // Lightest background
gray-100: #F8F9FA  // Page background
gray-200: #F5F5F5  // Secondary background
gray-300: #EEEEEE  // Muted areas
gray-400: #E0E0E0  // Borders, dividers
gray-500: #BDBDBD  // Disabled states
gray-600: #9E9E9E  // Secondary text, placeholders
gray-700: #757575  // Tertiary text
gray-800: #616161  // Body text
gray-900: #212121  // Titles, primary text
```

#### Dark Mode (iOS Style)
```
Background:        #000000  // Pure black
Surface:           #1C1C1E  // Cards, panels
Surface Elevated:  #2C2C2E  // Floating elements
Border:            #38383A  // Dividers
Primary:           #0A84FF  // Accent color (iOS blue)
Text Primary:      #FAFAFA  // Main text
Text Secondary:    #AEAEB2  // Secondary text
Text Tertiary:     #636366  // Tertiary text
```

---

### 📝 Typography Hierarchy

```
Display (Page Title):
  32px / 40px / Bold (700)
  Use case: App title, main headings

Title (Section Header):
  28px / 36px / Bold (700)
  Use case: Modal titles, major sections

Heading (Card Title):
  24px / 32px / Semibold (600)
  Use case: Card headers, dialog titles

Subheading:
  20px / 28px / Semibold (600)
  Use case: List section headers

Body Large:
  18px / 26px / Regular (400)
  Use case: Important body text

Body (Default):
  16px / 24px / Regular (400)  ← Most common
  Use case: Standard text, form inputs

Body Small:
  14px / 20px / Regular (400)
  Use case: Secondary information, captions

Caption:
  12px / 16px / Regular (400)
  Use case: Labels, timestamps, small notes
```

**Font Rules**:
- Minimum body text: 14px (16px on mobile)
- Maximum line length: 75 characters (~600px)
- Line height: 1.5x for body text

---

### 📐 Spacing System (8px Grid)

**All spacing MUST be multiples of 4px**

```
4px   (xs)   - Icon-to-text gap
8px   (sm)   - Inline element spacing
12px  (m-)   - Group element spacing
16px  (md)   - Component padding, list item gap  ← Most common
24px  (lg)   - Component margin, card padding
32px  (xl)   - Section spacing
48px  (xxl)  - Page block spacing
64px  (xxxl) - Major section dividers
```

**Component Padding Standards**:
```
Button:       8px 16px (height 40px)
Card:         16px
Input:        8px 12px (height 40px)
Modal:        24px
Page:         left/right 16px, top 16px, bottom 24px
List Item:    12px 16px (height min 56px)
```

---

### 🔘 Border Radius Standards

```
--radius-sm:  6px   (small tags, chips)
--radius-md:  8px   (inputs, small buttons)
--radius:     10px  (standard buttons, cards)  ← Default
--radius-lg:  12px  (large cards)
--radius-xl:  14px  (dialogs, modals)
```

---

### 🎬 Animation Parameters

```
Duration:
  fast:   150ms  // Color changes, opacity
  normal: 300ms  // Transitions, transforms  ← Default
  slow:   500ms  // Page transitions

Easing:
  ease-out: cubic-bezier(0, 0, 0.2, 1)  ← Recommended

Common Animations:
  Button Press:     scale(0.98) / 150ms
  Card Hover:       translateY(-2px) / 200ms
  Modal Enter:      scale(0.9 → 1) + opacity(0 → 1) / 300ms
  List Item Swipe:  translateX(-100%) / 300ms
```

---

### 🖼️ Icon System

#### Icon Sizes
```
xs:  12px - Helper icons
sm:  16px - Inline icons
md:  20px - List icons
lg:  24px - Navigation icons  ← Default
xl:  32px - Feature icons
xxl: 48px - Large feature icons
```

#### Icon Style
```
Primary Source: IconPark (linear style)
Secondary: HarmonyOS Symbol
Stroke Width: 2px
Minimum Touch Area: 44px × 44px
```

#### Core Icons Needed (15 Icons)
```
time         - Clock icon for time entry
chart        - Statistics/analytics
money        - Wage/payment
user         - Profile/settings
calendar     - Calendar view
setting      - Settings menu
backup       - Data backup
book         - Records/logs
clock        - Time tracking
wallet       - Earnings
theme        - Theme switcher
comment      - Notes/comments
group        - Work groups
share        - Share/export
star         - Favorites/highlights
```

---

## 3. Core Page Prompts

> **Tip**: Combine [Universal Design System](#1-universal-design-system) + specific prompts below when pasting into Figma Make

**Available Prompts**:
- Prompt 1: Time Record Page (首页 - 工时日历)
- Prompt 2: Statistics Page (统计页 - 数据分析)
- Prompt 3: Profile Page (个人中心 - 设置页面)

**对应文件**: `01_首页.txt`, `02_记账页.txt`, `03_统计页.txt`, `08_我的页面.txt`

---

### **Prompt 1: Time Record Page (Main Page - Tab 1)**

```
[Design System Context - see section 1]

Create a mobile time tracking app screen for HarmonyOS.
Screen size: 360px × 780px (standard phone).

Layout Structure:

1. Header Section (56px height):
   - Background: white (#FFFFFF)
   - Title: "Time Log" (24px, bold, #212121)
   - Right button: Calendar icon (24px, #757575)
   - Left/right padding: 16px

2. Month Selector (48px height):
   - Background: #F5F5F5
   - Current month: "November 2025" (18px, semibold, #212121)
   - Left arrow: ← (24px)
   - Right arrow: → (24px)
   - Center aligned
   - Border radius: 8px
   - Margin: 16px horizontal

3. Calendar Grid:
   - 7 columns (Mon-Sun header)
   - Week header: 12px, gray-600, 32px height
   - Day cells: 48px × 48px
   - Cell states:
     * Default: white background
     * Today: blue border (2px solid #2196F3)
     * Selected: blue background (#2196F3), white text
     * Has data: small blue dot below date (6px diameter)
   - Cell content: Date (16px, center aligned)
   - Gap: 4px between cells
   - Padding: 16px

4. Summary Card (120px height):
   - Background: gradient (#2196F3 to #64B5F6)
   - Border radius: 12px
   - Padding: 16px
   - Margin: 16px
   - Content layout:
     * Left: "This Month" (14px, white 0.8 opacity)
            "128 hours" (32px, bold, white)
            "¥3,840" (20px, white 0.9 opacity)
     * Right: Clock icon (48px, white 0.6 opacity)
   - Shadow: 0 4px 12px rgba(33, 150, 243, 0.3)

5. Bottom Navigation (56px height):
   - 3 tabs with equal width
   - Tab 1: Clock icon (24px) + "Time Log" (12px)
   - Tab 2: Chart icon (24px) + "Statistics" (12px)
   - Tab 3: User icon (24px) + "Profile" (12px)
   - Active state: #2196F3 (icon + text)
   - Inactive state: #9E9E9E
   - Background: white
   - Top border: 1px solid #E0E0E0

Page Background: #F8F9FA
```

---

### **Prompt 2: Statistics Page (Tab 2)**

```
[Design System Context - see section 1]

Create a statistics screen for time tracking app.
Screen size: 360px × 780px.

Layout Structure:

1. Header (56px):
   - Title: "Statistics" (24px, bold, #212121)
   - Background: white
   - Padding: 16px

2. Period Selector (48px):
   - 3 toggle buttons: "Week" | "Month" | "Year"
   - Button size: 104px × 32px
   - Active: #2196F3 background, white text
   - Inactive: transparent, #757575 text
   - Border radius: 16px (pill shape)
   - Background: #F5F5F5
   - Padding: 8px
   - Margin: 16px horizontal

3. Time Overview Card (160px):
   - Background: white
   - Border radius: 12px
   - Padding: 20px
   - Margin: 16px
   - Content:
     * Large number: "128" (48px, bold, #2196F3)
     * Unit: "hours" (16px, #757575)
     * Subtitle: "This Month" (14px, #9E9E9E)
     * Change indicator: "+12% from last month" (12px, #4CAF50)
       with up arrow icon (12px)
   - Shadow: 0 2px 8px rgba(0,0,0,0.06)

4. Stats Cards (2×2 Grid):
   - Card size: 164px × 100px
   - Gap: 16px
   - Margin: 16px
   - Card layout:
     * Icon: 32px, top-left
     * Label: 14px, #757575
     * Value: 24px, bold, #212121
   - Card 1: 💰 "Total Earned" "¥3,840"
   - Card 2: 📅 "Days Worked" "18"
   - Card 3: ⏱ "Avg per Day" "7.1 hrs"
   - Card 4: 💵 "Hourly Wage" "¥30/hr"
   - Background: white
   - Border radius: 10px
   - Padding: 16px
   - Shadow: 0 2px 8px rgba(0,0,0,0.06)

5. Chart Section (240px):
   - Title: "Weekly Trend" (18px, bold, #212121)
   - Bar chart: 7 bars (Mon-Sun)
   - Bar color: #2196F3
   - Bar height: varies (max 180px for 10 hours)
   - Bar width: 32px
   - Bar radius: 4px top corners
   - X-axis labels: day names (12px, #9E9E9E)
   - Y-axis: hour markers (12px, #9E9E9E)
   - Background: white
   - Border radius: 12px
   - Padding: 20px
   - Margin: 16px

6. Bottom Navigation (Same as Page 1)

Page Background: #F8F9FA
```

---

### **Prompt 3: Profile Page (Tab 3)**

```
[Design System Context - see section 1]

Create a profile and settings screen for time tracking app.
Screen size: 360px × 780px.

Layout Structure:

1. Header (56px):
   - Title: "Profile" (24px, bold, #212121)
   - Background: white
   - Padding: 16px

2. User Card (140px):
   - Background: gradient (#2196F3 to #64B5F6)
   - Border radius: 12px
   - Padding: 20px
   - Margin: 16px
   - Content:
     * Avatar: 64px circle, white background, user icon (32px, #2196F3)
     * Name: "User Name" (20px, bold, white)
     * Role: "Hourly Worker" (14px, white 0.8 opacity)
     * Member since: "Since Nov 2025" (12px, white 0.7 opacity)
   - Layout: avatar left, text right with 12px gap
   - Shadow: 0 4px 12px rgba(33, 150, 243, 0.3)

3. Settings List:
   - Title: "Settings" (18px, bold, #212121)
   - Margin: 16px top, 16px horizontal
   - List items (6 items):
     * Height: 56px each
     * Background: white
     * Border radius: 10px
     * Padding: 12px 16px
     * Gap: 8px between items
     * Layout: Icon (24px) | Label (16px) | Value (14px, right aligned) | Arrow (16px)
     
   List Items:
   1. 💵 "Hourly Wage" → "¥30/hr"
   2. 📅 "Work Cycle" → "Weekly"
   3. 🎨 "Theme" → "Auto"
   4. 💾 "Backup Data" → ""
   5. 📱 "About" → "v1.0.0"
   6. ⚙️ "Advanced" → ""
   
   - Icon color: #757575
   - Label color: #212121
   - Value color: #9E9E9E
   - Arrow color: #BDBDBD
   - Shadow per item: 0 2px 8px rgba(0,0,0,0.06)

4. VIP Banner (80px) - Interface Only:
   - Background: gradient (#FFD700 to #FFA500)
   - Border radius: 12px
   - Padding: 16px
   - Margin: 16px
   - Content:
     * Icon: ⭐ (32px)
     * Text: "Upgrade to VIP" (16px, bold, white)
     * Subtitle: "Unlock premium features" (12px, white 0.8 opacity)
     * Button: "Learn More" (14px, white, 0.3 opacity background)
   - Layout: icon left, text center, button right
   - Shadow: 0 4px 12px rgba(255, 165, 0, 0.3)

5. Bottom Navigation (Same as Page 1)

Page Background: #F8F9FA
```

---

## 4. Component Prompts

**Available Prompts**:
- Prompt 4: Calendar Day Cell (日历日期单元格)
- Prompt 5: Summary Card (月度统计卡片)
- Prompt 6: Stats Mini Card (统计小卡片)
- Prompt 7: Settings List Item (设置列表项)
- Prompt 8: Bottom Tab Navigation (底部导航栏)
- Prompt 9: User Card (用户信息卡片) **[新增]**
- Prompt 10: Settings List Item (设置项组件) **[新增]**
- Prompt 11: VIP Banner (VIP横幅) **[新增]**

**对应文件**: `04_资产卡片.txt`, `05_账单卡片.txt`, `06_图表组件.txt`, `07_导航栏.txt`, `09_用户卡片.txt`, `10_设置列表项.txt`, `11_VIP横幅.txt`

---

### **Prompt 4: Calendar Day Cell Component**

```
[Design System Context - see section 1]

Create a reusable calendar day cell component.
Canvas: 48px × 48px.

Component States:

1. Default State:
   - Background: white
   - Border: 1px solid #E0E0E0
   - Border radius: 8px
   - Date number: 16px, regular, #212121, center aligned
   - Shadow: none

2. Today State:
   - Background: white
   - Border: 2px solid #2196F3
   - Date color: #2196F3, bold
   - Border radius: 8px

3. Selected State:
   - Background: #2196F3
   - Border: none
   - Date color: white, bold
   - Border radius: 8px
   - Shadow: 0 2px 8px rgba(33, 150, 243, 0.3)

4. Has Data State (add to any state):
   - Small dot below date
   - Dot: 6px diameter, #2196F3, center aligned
   - Position: 4px below date number

5. Inactive Date (other months):
   - Background: transparent
   - Border: none
   - Date color: #BDBDBD
   - Border radius: 8px

Create 5 variants showing all states.
```

---

### **Prompt 5: Summary Card Component**

```
[Design System Context - see section 1]

Create a data summary card component.
Size: 328px × 120px.

Layout:
- Background: gradient (#2196F3 to #64B5F6)
- Border radius: 12px
- Padding: 16px
- Shadow: 0 4px 12px rgba(33, 150, 243, 0.3)

Content Structure:
1. Left Column:
   - Label: "This Month" (14px, regular, white, 0.8 opacity)
   - Value: "128 hours" (32px, bold, white)
   - Secondary: "¥3,840" (20px, semibold, white, 0.9 opacity)
   - Vertical spacing: 4px

2. Right Column:
   - Icon: Clock symbol (48px, white, 0.6 opacity)
   - Positioned: center-right

Create 4 variants with different data:
1. Monthly summary: "128 hours" / "¥3,840"
2. Weekly summary: "32 hours" / "¥960"
3. Daily summary: "7.5 hours" / "¥225"
4. Total earned: "520 hours" / "¥15,600"
```

---

### **Prompt 6: Stats Mini Card Component**

```
[Design System Context - see section 1]

Create a compact statistics card.
Size: 164px × 100px.

Layout:
- Background: white
- Border: 1px solid #E0E0E0
- Border radius: 10px
- Padding: 16px
- Shadow: 0 2px 8px rgba(0,0,0,0.06)

Content Structure:
- Icon: 32px emoji, top-left
- Label: 14px, regular, #757575, 8px below icon
- Value: 24px, bold, #212121, 4px below label

Create 4 variants:
1. 💰 "Total Earned" "¥3,840"
2. 📅 "Days Worked" "18"
3. ⏱ "Avg per Day" "7.1 hrs"
4. 💵 "Hourly Wage" "¥30/hr"

Ensure consistent alignment and spacing across all variants.
```

---

### **Prompt 7: Settings List Item Component**

```
[Design System Context - see section 1]

Create a settings list item component.
Size: 328px × 56px.

Layout:
- Background: white
- Border: 1px solid #E0E0E0
- Border radius: 10px
- Padding: 12px 16px
- Shadow: 0 2px 8px rgba(0,0,0,0.06)

Content Structure (left to right):
1. Icon: 24px, #757575
2. Label: 16px, regular, #212121
3. Value (optional): 14px, regular, #9E9E9E, right aligned
4. Arrow: → (16px, #BDBDBD), far right

Horizontal spacing: 12px between elements

Create 6 variants:
1. 💵 "Hourly Wage" → "¥30/hr" →
2. 📅 "Work Cycle" → "Weekly" →
3. 🎨 "Theme" → "Auto" →
4. 💾 "Backup Data" → →
5. 📱 "About" → "v1.0.0" →
6. ⚙️ "Advanced" → →

Add hover state: background changes to #F5F5F5
Add pressed state: background changes to #EEEEEE
```

---

### **Prompt 8: Bottom Tab Navigation Component**

```
[Design System Context - see section 1]

Create a bottom navigation bar with 3 tabs.
Size: 360px × 56px.

Layout:
- Background: white
- Top border: 1px solid #E0E0E0
- 3 equal-width tabs (120px each)
- No internal dividers

Tab Structure (vertical stack):
- Icon: 24px, center aligned
- Label: 12px, center aligned
- Spacing: 4px between icon and label

Tab Content:
1. Time Log Tab:
   - Icon: Clock symbol (24px)
   - Label: "Time Log"
   
2. Statistics Tab:
   - Icon: Chart/graph symbol (24px)
   - Label: "Statistics"
   
3. Profile Tab:
   - Icon: User symbol (24px)
   - Label: "Profile"

States:
- Active (selected):
  * Icon color: #2196F3
  * Label color: #2196F3
  * Font weight: Semibold (600)
  
- Inactive:
  * Icon color: #9E9E9E
  * Label color: #9E9E9E
  * Font weight: Regular (400)

Create 3 variants showing each tab as active.
Ensure minimum 44px touch target for each tab.
```

---

### **Prompt 9: User Card Component (个人中心)**

```
[Design System Context - see section 1]

Create a user profile card component for profile page.
Size: 328px × 140px.

Layout:
- Background: linear gradient (EXACTLY #2196F3 to #64B5F6, 135 degree angle)
- Border radius: 12px
- Padding: 20px
- Shadow: 0 4px 12px rgba(33, 150, 243, 0.3)

Content Structure (horizontal layout):
1. Left: Avatar
   - Size: 64px × 64px circle
   - Background: white (#FFFFFF)
   - Icon: User symbol (32px, EXACTLY #2196F3, centered)

2. Right: User Info (12px gap from avatar)
   - Name: "用户名称" (20px, bold, white) — Chinese text
   - Role: "小时工" (14px, regular, white 80% opacity) — Chinese text
   - Member since: "注册于 2025年11月" (12px, regular, white 70% opacity) — Chinese text
   - Vertical spacing: 4px between lines

Create 3 variants with different user data:
1. Default: "用户名称" / "小时工" / "注册于 2025年11月"
2. Long name: "王小明" / "自由职业者" / "注册于 2025年1月"
3. VIP user: "张三" / "VIP会员 ⭐" / "注册于 2024年10月"

IMPORTANT: Use Chinese labels, EXACTLY #2196F3 for primary color.
```

---

### **Prompt 10: Settings List Item Component (设置项)**

```
[Design System Context - see section 1]

Create a settings list item component for profile page.
Size: 328px × 56px.

Layout:
- Background: white (#FFFFFF)
- Border: 1px solid #E0E0E0
- Border radius: 10px
- Padding: 12px 16px
- Shadow: 0 2px 8px rgba(0,0,0,0.06)

Content Structure (left to right):
1. Icon: 24px, #757575
2. Label: 16px, regular, #212121
3. Value (optional): 14px, regular, #9E9E9E, right aligned
4. Arrow: → chevron right (16px, #BDBDBD), far right

Horizontal spacing: 12px between elements

Create 6 variants with Chinese labels:
1. 💵 "时薪设置" → "¥30/小时" →
2. 📅 "考勤周期" → "每周" →
3. 🎨 "主题设置" → "跟随系统" →
4. 💾 "数据备份" → →
5. 📱 "关于应用" → "v1.0.0" →
6. ⚙️ "高级设置" → →

Add interaction states:
- Hover state: background changes to #F5F5F5
- Pressed state: background changes to #EEEEEE

IMPORTANT: ALL text must be in Chinese, minimum 56px height for touch.
```

---

### **Prompt 11: VIP Banner Component (VIP横幅)**

```
[Design System Context - see section 1]

Create a VIP upgrade banner component (interface only, non-functional).
Size: 328px × 80px.

Layout:
- Background: linear gradient (#FFD700 to #FFA500, 135 degree angle)
- Border radius: 12px
- Padding: 16px
- Shadow: 0 4px 12px rgba(255, 165, 0, 0.3)

Content Structure (horizontal layout):
1. Left: Icon
   - ⭐ star emoji or icon (32px)

2. Center: Text Info (vertical stack, 4px spacing)
   - Title: "升级VIP会员" (16px, bold, white) — Chinese text
   - Subtitle: "解锁高级功能" (12px, regular, white 80% opacity) — Chinese text

3. Right: Button
   - Text: "了解更多" (14px, white) — Chinese text
   - Background: rgba(255, 255, 255, 0.3)
   - Border radius: 16px (pill shape)
   - Padding: 6px 12px

Horizontal spacing: 12px between elements

Create 2 variants with Chinese text:
1. Default: "升级VIP会员" / "解锁高级功能"
2. Promo: "VIP限时5折" / "活动限时优惠"

IMPORTANT: Use Chinese labels, gold gradient colors.
```

---

## 5. Icon System

### Icon Requirements

#### Primary Icon Source: IconPark
- **Style**: Linear (outlined)
- **Stroke Width**: 2px
- **License**: MIT (free for commercial use)
- **Download**: https://iconpark.oceanengine.com/

#### 15 Core Icons Needed

```
1. time         - Time entry, clock face
2. chart        - Line/bar chart for statistics
3. money        - Currency, earnings
4. user         - Profile, account
5. calendar     - Calendar view, date picker
6. setting      - Settings, preferences
7. backup       - Data backup, cloud sync
8. book         - Records, logs, history
9. clock        - Time tracking, timer
10. wallet      - Earnings, payments
11. theme       - Theme switcher, appearance
12. comment     - Notes, comments
13. group       - Work groups, teams
14. share       - Share, export data
15. star        - Favorites, highlights
```

#### Icon Usage Guidelines

```
Navigation Icons (24px):
- Bottom tabs: clock, chart, user
- Header actions: calendar, setting

List Icons (20px):
- Settings list items
- Menu items

Inline Icons (16px):
- Input field icons
- Breadcrumb icons
- Tag icons

Feature Icons (32px):
- Empty states
- Onboarding screens
- Large cards
```

#### Icon File Naming Convention
```
Format: ic_[name].svg
Examples:
- ic_time.svg
- ic_chart.svg
- ic_user.svg
```

---

## 6. How to Use

### Step 1: Preparation
1. Open Figma and log into your account
2. Create a new file: "TimeTracker UI Design"
3. Have this guide and `globals2.css` ready for reference

### Step 2: Generate Design with AI

#### ⭐ Recommended Workflow (Ensures Consistency)

1. **Copy Universal Design System**:
   - From [Section 1](#1-universal-design-system)
   - Copy the complete "Design System Context" block

2. **Copy Specific Page Prompt**:
   - Choose desired prompt (e.g., Prompt 1: Time Record Page)
   - Copy from "Create a mobile..." onwards

3. **Merge and Paste into Figma**:
   ```
   [Universal Design System Context]
   
   [Specific Page/Component Prompt]
   ```

4. **Open Figma Make Mode**:
   - Click "+" button in toolbar
   - Select "Make with AI" or press `Ctrl/Cmd + /`

5. **Paste Merged Prompt**:
   - Paste complete content into input box

6. **Generate**:
   - Click generate button
   - Figma AI will create design based on unified system

7. **Fine-tune**:
   - Adjust colors, spacing, fonts as needed
   - Ensure compliance with HarmonyOS guidelines

### Step 3: Share Design with AI

1. **Get Share Link**:
   - Click "Share" button (top-right)
   - Set permission: "Anyone with the link can view"
   - Copy link (format: https://figma.com/design/[fileKey]/[fileName]?node-id=1-2)

2. **Provide to AI**:
   - Send link to me
   - I'll use Figma MCP tools to read design
   - Extract component specs and generate ArkTS code

### Step 4: AI Code Generation

I will automatically:
1. Read Figma design node information
2. Extract layout, colors, fonts, spacing parameters
3. Generate HarmonyOS-compliant ArkTS component code
4. Adapt for dark mode and responsive layouts

### Step 5: Code Implementation

1. Integrate generated code into TimeTracker project
2. Debug and optimize performance
3. Test on real HarmonyOS device

---

## 📌 Important Notes

### ⚠️ AI Capability Boundaries

- ✅ **CAN DO**: Generate detailed design prompts
- ✅ **CAN DO**: Read your shared Figma designs and extract specs
- ✅ **CAN DO**: Generate ArkTS code based on designs
- ❌ **CANNOT DO**: Directly log into your Figma account
- ❌ **CANNOT DO**: Automatically create designs in your Figma workspace

### 🎯 Best Practices

1. **Generate Step-by-Step**: Create one page first, test results, then batch generate
2. **Maintain Consistency**: Strictly follow sizes and color values in prompts
3. **Visual Comparison**: Reference modern productivity app screenshots for visual alignment
4. **Iterative Refinement**: Request prompt adjustments for regeneration if needed

### 🔗 Related Resources

- `globals2.css` - Color and style variable definitions
- HarmonyOS Design Guidelines - https://developer.huawei.com/consumer/cn/design/
- IconPark Icon Library - https://iconpark.oceanengine.com/

---

## 📱 Screen Specifications

### Target Device
```
Device: HarmonyOS Phone
Screen Size: 360px × 780px (standard)
DPI: 2x or 3x
Status Bar: 24px (auto-managed by system)
Bottom Navigation: 56px (custom)
Safe Area: Account for notches/home indicators
```

### Responsive Breakpoints
```
Small Phone:  360px - 375px  (most common)
Large Phone:  390px - 428px
Tablet:       768px+
```

---

This guide provides a complete workflow from Figma design to HarmonyOS code for the TimeTracker app. If you have questions, feel free to ask!
