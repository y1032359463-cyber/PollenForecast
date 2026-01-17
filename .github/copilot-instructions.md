# HarmonyOS Application Factory - AI Coding Agent Instructions

##  Project Architecture

This is a **HarmonyOS Application Factory** - a multi-project repository for rapid native app development using template-based generation and configuration-driven patterns. Each sub-project is independent with isolated documentation.

**Repository Structure:**
\\\
HarmonyOS_App_Plans/
 .claude/CLAUDE.md          # Factory-level index (READ FIRST)
 PollenForecast/            # Pollen forecast app (P0)
 Healthy_life/              # Health assistant (P0)
 TimeTracker1/              # Work time tracker (P0)
 DaotimeleM/                # Timing & billing tool (P1)  Currently active
 CuteCalculator/            # Cute calculator (P1)
 MoneyTrack1/               # Expense tracker (P1)
\\\

**Critical Workflow:**
1. **ALWAYS read \.claude/CLAUDE.md\ first** - contains project status, priorities, and sub-project index
2. **Then read sub-project's \.claude/CLAUDE.md\ or design docs** (e.g., \DaotimeleM/figma/页面设计.md\)
3. Work in VS Code, **NEVER execute build commands** - user handles builds in DevEco Studio
4. Update relevant CLAUDE.md after completing tasks

##  Absolute Prohibitions

### Build Commands (User-Only Operations)
\\\ash
 NEVER run: hvigorw assembleHap
 NEVER run: hvigorw clean
 NEVER run: npm run build
\\\
**Reason:** SDK environment requires DevEco Studio. AI only writes code; user executes builds.

##  HarmonyOS ArkTS Mandatory Patterns

### Component Structure (Non-Negotiable)
\\\	ypescript
//  CORRECT - Named export with decorators
import router from '@ohos.router';

@Entry
@Component
struct MyPage {
  @State count: number = 0;
  
  build() {
    Column() {
      Text(\Count: \\)
        .fontSize(20)
        .onClick(() => this.count++)
    }
    .width('100%')
    .height('100%')
  }
}

export { MyPage };  //  Named export only

//  WRONG - No default exports
export default MyPage;
\\\

### Styling Syntax
\\\	ypescript
//  Chained method calls
Text('Hello')
  .width(100)
  .height(50)
  .backgroundColor('#FF6B9D')
  .borderRadius(8)

//  WRONG - No CSS-like objects
.style({ width: 100, height: 50 })
\\\

### Layout Components
\\\	ypescript
//  Use ArkUI declarative components
Column() {
  Row() {
    Text('Label').layoutWeight(1)
    Button('Action')
  }
  Grid() { /* grid items */ }
}

//  WRONG - No HTML/web components
<div><span></span></div>
\\\

### Icon Configuration (AppGallery Requirement)
\\\json5
// module.json5
\"icon\": \"\\"  //  Must use layered_image
\"icon\": \"\\"       //  Fails AppGallery review
\\\

### Performance - GPU-Accelerated Transforms
\\\	ypescript
//  FAST - GPU compositing
.transform({ translateY: offset })

//  SLOW - Layout reflow (3-5x slower)
.translate({ y: offset })
\\\

### API 20+ Navigation (Current SDK)
\\\	ypescript
//  Use new APIs
router.replaceNamedRoute({ name: 'PageName' })
context.terminateSelf()  // Exit app properly

//  Deprecated
router.replaceUrl()
router.back()  // Causes black screen in single-page apps
\\\

##  Project-Specific Patterns

### DaotimeleM (Current Project)

**Design Philosophy:** 极简主义 (Extreme Minimalism) - \"越简单越好\"

**Architecture Decisions:**
- **Fixed Left Panel** (not sidebar): 80px permanent category bar with 4 business types
- **Dual Mode:** Merchant (老板端) + Consumer (消费者端) with separate flows
- **QR Code Display:** Pure full-screen split - green WeChat top, blue Alipay bottom, NO overlays
- **Timer Strategy:** TaskPool + Emitter for concurrent countdowns (10+ simultaneous timers)
- **Data Storage:** Preferences for config, SQLite for history records

**Critical Files:**
- \igma/页面设计.md\ - Complete page specifications (9 pages defined)
- \igma/日志.md\ - Technical solutions from CodeGenie (QR codes, timers, layout, storage)

**Component Structure Example:**
\\\	ypescript
// pages/Index.ets - Identity selection with breathing animation
@Entry
@Component
struct Index {
  @State scaleValue1: number = 1;
  
  aboutToAppear() {
    // Breathing effect with setInterval + animateTo
    setInterval(() => {
      animateTo({ duration: 2000, curve: Curve.EaseInOut }, () => {
        this.scaleValue1 = this.scaleValue1 === 1 ? 1.05 : 1;
      });
    }, 2000);
  }
  
  build() {
    Column() {
      Row() {
        Column() { /* Boss button */ }
          .scale({ x: this.scaleValue1, y: this.scaleValue1 })
          .onClick(() => router.pushUrl({ url: 'pages/merchant/MerchantHome' }))
      }
    }
  }
}
\\\

### Storage Patterns (From 日志.md)

**QR Code Images:**
\\\	ypescript
// Save to sandbox
const context = getContext(this);
const path = context.filesDir + \"/qrcode/wechat.png\";

// Load in component
Image(\ile://\/qrcode/wechat.png\)
  .width('80%')
  .aspectRatio(1)
  .objectFit(ImageFit.Contain)
  .interpolation(ImageInterpolation.High)
\\\

**Countdown Timers:**
\\\	ypescript
import { taskpool, emitter } from '@kit.ArkTS';

@Concurrent
async function countdownTask(seconds: number, eventId: number) {
  let remaining = seconds;
  while (remaining > 0) {
    await new Promise(resolve => setTimeout(resolve, 1000));
    remaining--;
    emitter.emit({ eventId }, { remaining });
  }
}

// Start timer
const task = new taskpool.Task(countdownTask, 3600, 1001);
taskpool.execute(task);
\\\

**Preferences Usage:**
\\\	ypescript
// Save business config
const config = { theme: 'dark', businesses: ['pool', 'chess'] };
await preferences.put('user_config', JSON.stringify(config));

// Load config
const data = await preferences.get('user_config', '{}');
const config = JSON.parse(data as string);
\\\

**Database Schema:**
\\\	ypescript
const SQL_CREATE_TABLE = \
  CREATE TABLE IF NOT EXISTS history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    business_type TEXT NOT NULL,
    resource_name TEXT,
    start_time INTEGER,
    end_time INTEGER,
    duration INTEGER,
    fee REAL
  )\;
\\\

##  UI/UX Conventions

### Fixed Left Panel Layout
\\\	ypescript
Row() {
  // Left panel - always visible, 80px width
  Column() {
    ForEach(businessTypes, (item) => {
      Column() {
        Text(item.icon).fontSize(32)
        Text(item.name).fontSize(12)
        if (isAdded(item)) Text('')
      }
      .onClick(() => handleBusinessClick(item))
    })
  }
  .width(80)
  .backgroundColor('#FAFAFA')
  
  // Right content - flexible width
  Column() { /* main content */ }
    .layoutWeight(1)
}
\\\

### QR Code Page (Pure Display)
\\\	ypescript
// NO countdown, NO buttons, ONLY QR codes
Column() {
  // WeChat - green background, top half
  Stack() {
    Column().backgroundColor('#09BB07')
    Image(\('qrcode/wechat.png'))
      .width('80%').aspectRatio(1)
  }.layoutWeight(1)
  
  // Alipay - blue background, bottom half
  Stack() {
    Column().backgroundColor('#1677FF')
    Image(\('qrcode/alipay.png'))
      .width('80%').aspectRatio(1)
  }.layoutWeight(1)
}
\\\

### Breathing Button Animation
\\\	ypescript
// For identity selection buttons
setInterval(() => {
  animateTo({
    duration: 2000,
    curve: Curve.EaseInOut,
    iterations: 1,
    playMode: PlayMode.Alternate
  }, () => {
    this.scaleValue = this.scaleValue === 1 ? 1.05 : 1;
    this.opacityValue = this.opacityValue === 1 ? 0.85 : 1;
  });
}, 2000);
\\\

##  Documentation Protocol

### After Completing Work
1. **Update \.claude/CLAUDE.md\** with:
   - Date: Ask user for Beijing time (北京时间)
   - Section: \"最近更新\" (Recent Updates)
   - Status:  (completed) /  (in progress) /  (todo)
   - Details: What was changed and why

2. **Update sub-project docs** if applicable:
   - \DaotimeleM/figma/页面设计.md\ for UI changes
   - \DaotimeleM/figma/日志.md\ for technical decisions

### Example Update Format
\\\markdown
### 最近更新
**2025-12-11** - DaotimeleM 页面框架搭建
-  身份选择页（呼吸动效按钮）
-  老板端主页（固定左栏+业务卡片）
-  收款码页面（绿微信+蓝支付宝）
-  待实现：TaskPool倒计时逻辑
\\\

##  Development Environment

**SDK:** HarmonyOS 6.0.0 (API 20) - Stable version
**IDE:** DevEco Studio 6.0.1 Beta1 (user-operated only)
**Language:** ArkTS (TypeScript-like with decorators)
**Build Tool:** hvigorw (user executes, AI never touches)

**SDK Path Issues (Common Trap):**
-  Correct: \C:\Users\Lenovo\AppData\Local\Huawei\Sdk\HarmonyOS\
-  Wrong: \C:\Users\Lenovo\AppData\Local\OpenHarmony\Sdk\ (ArkUI-X SDK)
- **Fix:** Copy \local.properties\ from working project (e.g., Healthy_life)

##  Current Focus (as of 2025-12-11)

**Active Project:** DaotimeleM (到时间了吗)
**Phase:** Initial implementation - page framework complete, core logic pending
**Next Steps:**
1. Implement TaskPool countdown timers with Emitter events
2. Add Preferences for business configuration storage
3. Integrate photo picker for QR code upload
4. Build SQLite schema for history records

**Read First:** \DaotimeleM/figma/页面设计.md\ for complete page specs

##  Key Reference Files

- \.claude/CLAUDE.md\ - Factory-level project index (start here)
- \.claude/HarmonyOS_核心规则卡.md\ - Quick reference card (<500 words)
- \DaotimeleM/figma/页面设计.md\ - Complete UI specifications
- \DaotimeleM/figma/日志.md\ - Technical solutions (storage, timers, layout)

##  Quick Checks Before Coding

- [ ] Read factory-level CLAUDE.md for project status
- [ ] Read sub-project design docs
- [ ] Verified target SDK version (API 20)
- [ ] Using correct component decorators (@Entry, @Component, @State)
- [ ] Using named exports only (no default exports)
- [ ] Chained styling methods (no CSS objects)
- [ ] No build commands in code
- [ ] Plan to update CLAUDE.md after completion
