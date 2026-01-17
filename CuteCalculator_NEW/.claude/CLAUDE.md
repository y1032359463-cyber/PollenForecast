# CuteCalculator_NEW 项目协作中心

> **作用范围**: CuteCalculator_NEW 项目 (新主题计算器应用 - 基于可爱猫咪计算器改造)  
> **最后更新**: 2025-11-24 00:15 (北京时间)  
> **AI 维护者**: GitHub Copilot  
> **父项目**: [返回应用工厂总览](../../.claude/CLAUDE.md)  
> **项目性质**: 🆕 基于旧项目 (CuteCalculator) 复刻，主题待定

---

## 1. 项目概述

**CuteCalculator_NEW (新主题计算器)** - 基于华为官方标准计算器源码和已完成的"可爱猫咪计算器"项目，通过更换主题和UI风格，打造一款差异化的轻量级计算器应用。

- **应用 ID**: 待定 (根据主题确定包名)
- **平台**: HarmonyOS NEXT (API 20, SDK 6.0.0)
- **语言**: ArkTS
- **构建工具**: Hvigor + ohpm
- **当前版本**: v0.0.1-planning
- **项目状态**: **🎨 主题规划阶段** - 确定产品方向中
- **技术基础**: 复用 CuteCalculator 全部代码架构（已完成的计算逻辑、页面导航、设置系统等）
- **差异化策略**: 更换视觉主题 + 增加桌面卡片功能 + 应用轻量级优化方案

---

## 2. 新项目主题规划 🎨

### 当前状态
- ✅ 旧项目 (CuteCalculator) 已完成开发，主题为"可爱猫咪"风格
- ✅ 代码架构已复制到新项目 (CuteCalculator_NEW)
- ⏳ 正在确定新主题方向

### 候选主题方案（2025-11-24讨论）

#### 方案 A：复古像素游戏机 (Retro Pixel) 🕹️
**核心概念**: 致敬 80 年代掌机（GameBoy 风格）

| 维度 | 设计要点 |
|------|---------|
| **视觉风格** | 8-bit 像素字体、绿底黑字液晶屏效果、实体按键质感 |
| **角色设计** | 像素小勇士或小恐龙（代替猫咪） |
| **交互特效** | 滴滴滴的电子音、按键时像素小人会跳跃或攻击 |
| **适合人群** | 怀旧党、游戏玩家、80/90后 |
| **差异点** | 复古音效 + 像素动画 + 游戏化交互 |

#### 方案 B：赛博朋克霓虹 (Cyberpunk Neon) 🌃
**核心概念**: 高科技、未来感、夜间模式

| 维度 | 设计要点 |
|------|---------|
| **视觉风格** | 深色背景、故障风（Glitch）数字显示、发光的霓虹色按键（蓝/紫/粉） |
| **角色设计** | 悬浮的 AI 机器人球体（代替猫咪） |
| **交互特效** | 按键时有光晕扩散效果、科幻数字字体 |
| **适合人群** | 科技爱好者、喜欢酷炫界面的用户、程序员 |
| **差异点** | 光效动画 + 暗黑模式 + 科幻氛围 |

#### 方案 C：机械键盘 ASMR (Mechanical Master) ⌨️
**核心概念**: 极致的手感和听觉享受（解压神器）

| 维度 | 设计要点 |
|------|---------|
| **视觉风格** | 极简工业风、高仿真的键帽（PBT 材质感）、RGB 背光 |
| **核心卖点** | **声音**。内置青轴、红轴、茶轴三种按键音效，"咔哒咔哒"解压 |
| **交互特效** | 配合鸿蒙震动反馈，模拟真实敲击感 |
| **适合人群** | 程序员、文字工作者、ASMR爱好者、解压需求者 |
| **差异点** | 真实机械键盘音效 + 震动反馈 + 极简美学 |

#### 方案 D：禅意木鱼 (Zen Wood) 🪵
**核心概念**: 佛系计算，算账也能很平静

| 维度 | 设计要点 |
|------|---------|
| **视觉风格** | 木质纹理、水墨风、暖色调、国风元素 |
| **角色设计** | 小和尚或水墨熊猫（代替猫咪） |
| **交互特效** | 按键是敲木鱼的声音"笃笃笃"、每次计算结果显示"功德+1" |
| **适合人群** | 喜欢国风、需要解压的年轻人、佛系青年 |
| **差异点** | 木鱼音效 + 功德系统 + 禅意氛围 |

### 技术参考：鸿蒙轻量级应用优化方向

基于《鸿蒙轻量级应用实现路径研究报告》(2025-11-23)，新项目将整合以下优化策略：

1. **体积优化目标**: 控制在 2MB 以内（vs 旧项目约 3-5MB）
   - ✅ 已开启代码混淆 (build-profile.json5)
   - 📋 待实施：字体子集化（Pacifico 315KB → <20KB）
   - 📋 待实施：图片 WebP 化（压缩率 80%）

2. **鸿蒙特色功能**: 桌面卡片（原子化服务）
   - 📋 规划中：2x2 电子宠物伴侣卡片（装饰性）
   - 📋 规划中：2x4 极简计算结果卡片（实用性）

3. **离线优先与隐私**: 保持现有优势
   - ✅ 无网络权限
   - ✅ 本地存储 (Preferences + File API)

### 决策待办
- [x] **用户确定最终主题**（方案A：复古像素游戏机 Retro Pixel）✅ 2025-11-25
- [ ] 根据主题更新包名、应用名称
- [x] 根据主题规划素材需求（角色、字体、配色）✅ 素材已全部准备完成
- [ ] 确定桌面卡片设计方向

#### 方案A素材清单 ✅ 全部完成 (2025-11-25)
**素材位置**: `figma/素材包/`

**字体** (2个):
- ✅ `Press_Start_2P/PressStart2P-Regular.ttf` (116KB) - 经典Game Boy像素字体
- ✅ `VT323/VT323-Regular.ttf` (146KB) - 备选等宽终端字体

**像素角色精灵** (4个状态):
- ✅ `pixel_character_idle.png` (125KB) - 角色待机状态
- ✅ `pixel_character_thinking.png` (138KB) - 角色思考状态  
- ✅ `pixel_character_celebrate.png` (161KB) - 角色庆祝状态
- ✅ `pixel_character_error.png` (171KB) - 角色错误状态

**音效文件** (5个):
- ✅ `sfx_button_press.wav` (14KB) - 按键音效
- ✅ `sfx_calculate_success.mp3` (67KB) - 计算成功音效
- ✅ `sfx_clear.mp3` (33KB) - 清除音效
- ✅ `sfx_delete.wav` (103KB) - 删除音效
- ✅ `sfx_error.wav` (95KB) - 错误音效

**背景素材**:
- ✅ Kenney PICO-8 City Tileset (360个8×8像素tile_0000.png ~ tile_0359.png)
- ✅ `kenney_pico-8-city/Tilemap/tilemap.png` (4KB) - 完整tilemap
- ✅ `kenney_pico-8-city/Tilemap/tilemap_packed.png` (3KB) - 压缩tilemap  
- ✅ `background.png` (20KB) - 背景图
- ✅ `foreground.png` (1.9MB) - 前景图

**Game Boy配色参考**:
- 主色: `#9BBC0F` (亮绿)
- 次色: `#8BAC0F` (中绿)
- 暗色: `#306230` (深绿)
- 背景: `#0F380F` (黑绿)

---

## 3. 项目结构速查

```
CuteCalculator/
├── entry/src/main/
│   ├── ets/
│   │   ├── entryability/
│   │   │   └── EntryAbility.ets           # 应用生命周期
│   │   ├── pages/
│   │   │   ├── MainPage.ets               # 主计算器页面
│   │   │   ├── HistoryPage.ets            # 历史记录页面
│   │   │   └── SettingsPage.ets           # 设置页面
│   │   ├── components/
│   │   │   ├── CuteCalcKeyboard.ets       # 可爱键盘组件
│   │   │   ├── CuteButton.ets             # 可爱按钮组件
│   │   │   ├── CharacterDecor.ets         # 角色装饰组件
│   │   │   └── ResultDisplay.ets          # 结果显示组件
│   │   ├── common/
│   │   │   ├── CalculateUtil.ets          # 计算核心(华为源码)
│   │   │   ├── CheckEmptyUtil.ets         # 工具类(华为源码)
│   │   │   ├── Constant.ets               # 常量定义
│   │   │   └── ThemeConfig.ets            # 主题配置
│   │   └── utils/
│   │       ├── HistoryUtils.ets           # 历史记录(华为源码)
│   │       ├── HapticUtils.ets            # 振动反馈
│   │       └── PreferencesUtils.ets       # 设置存储
│   └── resources/
│       └── base/
│           ├── element/                    # 字符串/颜色资源
│           ├── media/
│           │   ├── buttons/                # 按钮图片素材
│           │   │   ├── btn_0.png
│           │   │   ├── btn_1.png ~ btn_9.png
│           │   │   ├── btn_plus.png
│           │   │   ├── btn_minus.png
│           │   │   ├── btn_multiply.png
│           │   │   ├── btn_divide.png
│           │   │   ├── btn_equal.png
│           │   │   ├── btn_clear.png
│           │   │   ├── btn_delete.png
│           │   │   └── btn_dot.png
│           │   ├── characters/             # 卡通角色素材
│           │   │   ├── cat_normal.png
│           │   │   ├── cat_calculating.png
│           │   │   ├── cat_result.png
│           │   │   └── cat_error.png
│           │   └── icons/                  # 图标素材
│           │       ├── app_icon_fg.svg
│           │       ├── app_icon_bg.svg
│           │       ├── ic_history.png
│           │       └── ic_settings.png
│           └── profile/
│               └── main_pages.json         # 页面配置
│
├── AppScope/
│   ├── app.json5                           # 应用全局配置
│   └── resources/base/
│       ├── element/
│       │   └── string.json                 # 全局字符串
│       └── media/
│           └── layered_image/              # 分层图标
│               ├── foreground.png
│               └── background.png
│
├── .claude/
│   └── CLAUDE.md                           # 项目协作文档
│
├── figma/
│   ├── 00_使用说明.md                      # Figma使用指南
│   ├── 01_主计算器界面.txt                 # 主界面提示词
│   ├── 02_历史记录页面.txt                 # 历史页面提示词
│   └── 03_设置页面.txt                     # 设置页面提示词
│
├── build-profile.json5                     # 构建配置
├── oh-package.json5                        # ohpm依赖
├── local.properties                        # SDK路径配置
└── hvigorfile.ts                           # Hvigor构建脚本
```

### 关键文件说明（待主题确定后更新）
- **CalculateUtil.ets**: 华为官方计算核心逻辑（完全保留，不修改）
- **CuteButton.ets**: 可配置按钮组件（需根据新主题更新样式）
- **CharacterDecor.ets**: 角色装饰组件（需根据新主题更换素材和动画）
- **ThemeConfig.ets**: 主题配置文件（**核心改造点**：颜色、字体、风格）

---

## 3. 开发环境

### 工具链版本（继承工厂级配置）
- **DevEco Studio**: 6.0.1 Beta1
- **HarmonyOS SDK**: 6.0.0.47 (API 20)
- **SDK 位置**: `C:\Program Files\Huawei\DevEco Studio\sdk`
- **Node.js**: v18.20.1 (DevEco Studio 自带)
- **ohpm**: 内置
- **hvigorw**: DevEco Studio tools 目录

### local.properties 配置
```properties
sdk.dir=C:\\Program Files\\Huawei\\DevEco Studio\\sdk
nodejs.dir=C:\\Program Files\\nodejs
```

### 项目依赖（待配置）
```json5
// oh-package.json5
{
  "dependencies": {
    // 基础依赖由 DevEco Studio 自动管理
  }
}
```

---

## 4. 快速命令参考

### 推荐构建方式（DevEco Studio IDE）
```
1. 打开 DevEco Studio
2. File → Open → 选择 CuteCalculator 项目
3. Build → Make Module 'entry'
```

### 命令行构建（高级用户）
```powershell
# 初始化依赖
cd C:\HarmonyOS_App_Plans\CuteCalculator
ohpm install

# 清理构建
node "C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js" clean

# 调试构建
node "C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js" assembleHap --mode module

# Release构建
node "C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.js" assembleHap --mode module -p buildMode=release
```

---

## 5. 项目进展追踪

### 最近更新
**2025-11-25 01:26** - Retro Pixel主题基础设施完成 ✅

### 新主题开发进度 (Retro Pixel Game Boy)

#### ✅ 阶段1: 素材准备与资源部署 (2025-11-25 完成)
- **素材清单验证**: ✅ 完成
  - 字体: Press Start 2P (116KB), VT323 (146KB)
  - 角色精灵: 4状态PNG (idle 125KB, thinking 138KB, celebrate 161KB, error 171KB)
  - 音效: 5个文件 (button_press 14KB, calculate_success 67KB, clear 33KB, delete 103KB, error 95KB)
  - 背景: background.png (20KB), foreground.png (1.9MB), tilemap.png (4KB)
  - Kenney PICO-8 tiles: 360个8×8像素tile

- **资源部署**: ✅ 完成
  - 复制到 `entry/src/main/resources/rawfile/` 规范目录
  - 字体 → `rawfile/fonts/`
  - 角色 → `rawfile/characters/`
  - 音效 → `rawfile/audio/`
  - 背景 → `rawfile/backgrounds/`

#### ✅ 阶段2: 核心代码实现 (2025-11-25 完成)
- **RetroPixelTheme.ets**: ✅ 完成
  - Game Boy DMG-01 经典配色 (4色绿阶)
  - 资源路径管理 (字体/角色/音效/背景)
  - UI尺寸配置 (按键圆角4/高度56/间距8)
  - 动画时长配置
  - 工具方法 (getFontPath/getCharacterPath/getAudioPath/getBackgroundPath)

- **AudioManager.ets**: ✅ 完成
  - AVPlayer音效播放器管理
  - 预加载机制 (initialize方法)
  - 音效开关检测 (PreferencesUtils.getSound)
  - 5种音效类型支持 (BUTTON_PRESS/CALCULATE_SUCCESS/CLEAR/DELETE/ERROR)
  - 资源释放管理 (release方法)
  - 音量控制 (setVolume方法)

- **CharacterDecor.ets**: ✅ 完成
  - 重写为像素角色组件 (移除旧的三层结构)
  - 4种状态支持 (IDLE/THINKING/CELEBRATE/ERROR)
  - 状态切换动画 (缩放+透明度)
  - 专属动画方法:
    - `playCelebrateAnimation()` - 跳跃效果
    - `playErrorAnimation()` - 抖动效果
    - `playThinkingAnimation()` - 闪烁效果
    - `resetToIdle()` - 重置待机

- **PreferencesUtils.ets**: ✅ 扩展
  - 新增 `KEY_SOUND` 常量
  - 新增 `getSound()` 方法 (默认true)
  - 新增 `setSound(enabled: boolean)` 方法

#### 📋 阶段3: 组件适配 (待实施)
- **CuteCalcKeyboard.ets**: 🔄 待改造
  - 应用RetroPixelTheme按键样式
  - 数字按键: `BUTTON_NUMBER_BG` (#8BAC0F绿) + `BUTTON_NUMBER_TEXT` (#0F380F黑绿)
  - 运算符按键: `BUTTON_OPERATOR_BG` (#306230深绿) + `BUTTON_OPERATOR_TEXT` (#9BBC0F亮绿)
  - 等号按键: `BUTTON_EQUAL_BG` (#9BBC0F亮绿) + `BUTTON_EQUAL_TEXT` (#0F380F黑绿)
  - 清除按键: `BUTTON_CLEAR_BG` (#8B0000红) + `BUTTON_CLEAR_TEXT` (#FFE4E1浅红)
  - 按键圆角: 4 (像素化效果)
  - 集成音效播放: `AudioManager.getInstance().play('BUTTON_PRESS')`

- **ResultDisplay.ets**: 🔄 待改造
  - 应用Game Boy液晶屏效果
  - 背景色: `COLOR_BACKGROUND` (#0F380F黑绿)
  - 边框: 3px, `COLOR_SHELL` (#E8E8E8浅灰)
  - 表达式文字: `COLOR_OPERATOR` (#306230深绿), 字体Press Start 2P
  - 结果文字: `COLOR_RESULT` (#9BBC0F亮绿), 字体Press Start 2P
  - 错误文字: `COLOR_ERROR` (#8B0000红)

- **SettingsSheet.ets**: 🔄 待改造
  - 添加"音效"开关卡片
  - 图标: 🔊/🔇
  - Toggle绑定: `PreferencesUtils.getSound()` / `setSound()`
  - 保持现有振动开关、角色选择、条款政策功能

#### 📋 阶段4: 主页集成 (待实施)
- **MainPage.ets**: 🔄 待改造 (528行，复杂度高)
  - **导入模块**:
    - 添加 `RetroPixelTheme`, `AudioManager`, `PixelCharacterState`
    - 移除 `ThemeColors`, `CharacterState`
  - **状态变量**:
    - `characterState` 改为 `PixelCharacterState.IDLE`
    - 移除 `buttonPressCounter`, `characterType`
  - **生命周期**:
    - `aboutToAppear`: 初始化 `AudioManager.getInstance().initialize()`
    - `aboutToDisappear`: 释放 `AudioManager.getInstance().release()`
  - **按键处理**:
    - `handleButtonClick`: 集成音效播放逻辑
    - 数字/运算符 → `play('BUTTON_PRESS')` + `playThinkingAnimation()`
    - 等号 → `play('CALCULATE_SUCCESS')` + `playCelebrateAnimation()`
    - 清除 → `play('CLEAR')` + `resetToIdle()`
    - 删除 → `play('DELETE')`
    - 错误 → `play('ERROR')` + `playErrorAnimation()`
  - **主题配色**:
    - 全局替换 `ThemeColors.*` → `RetroPixelTheme.*`
    - 背景色: `COLOR_BACKGROUND`
    - 按键区域: 应用Game Boy外壳色
  - **角色预加载**:
    - 移除白猫/兔子图片预加载
    - 添加4个像素角色状态预加载

- **EntryAbility.ets**: 🔄 待添加
  - 注册Press Start 2P字体到全局
  - 在 `onWindowStageCreate` 生命周期中:
    ```typescript
    const uiContext = windowStage.getMainWindowSync().getUIContext();
    uiContext.getFont().registerFont({
      familyName: 'PressStart2P',
      familySrc: 'rawfile/fonts/PressStart2P-Regular.ttf'
    });
    ```

#### 📋 阶段5: 测试与优化 (待实施)
- **功能测试**:
  - [ ] 音效播放正常 (5种音效)
  - [ ] 角色状态切换正常 (4种状态+动画)
  - [ ] 按键样式正确显示 (Game Boy配色)
  - [ ] 字体正确加载 (Press Start 2P)
  - [ ] 设置开关持久化 (音效/振动)

- **体积优化** (目标<2MB):
  - [ ] 字体子集化 (PressStart2P 116KB → 优化)
  - [ ] 图片WebP化 (foreground.png 1.9MB → 压缩)
  - [ ] 代码混淆 (已启用)
  - [ ] 资源压缩

- **性能优化**:
  - [ ] 音效预加载时机优化
  - [ ] 角色图片缓存策略
  - [ ] 动画性能测试

#### 🎯 技术难点与解决方案
1. **字体注册**:
   - 问题: Press Start 2P字体需全局注册
   - 方案: EntryAbility.onWindowStageCreate中使用uiContext.getFont().registerFont

2. **音效异步播放**:
   - 问题: AVPlayer初始化异步，按键需同步响应
   - 方案: AboutToAppear中预加载所有音效，play方法内部处理async

3. **组件引用方式**:
   - 问题: 旧CharacterDecor使用@Link双向绑定
   - 方案: 新组件通过.id()获取引用，调用公开方法

4. **主题配色适配**:
   - 问题: Game Boy绿色在不同设备显示效果可能不同
   - 方案: 提供亮度调节选项 (可选)

#### 📊 资源占用预估
- **应用体积**: 预估 1.5MB - 2.0MB
  - 代码: ~300KB (混淆后)
  - 字体: 262KB (2个字体)
  - 角色: 610KB (4张PNG)
  - 音效: 313KB (5个文件)
  - 背景: 1.92MB (3张图)
  - **优化空间**: foreground.png (1.9MB) → WebP压缩至<500KB

- **内存占用**: 预估 15MB - 20MB
  - 音效预加载: ~2MB
  - 图片缓存: ~5MB
  - UI渲染: ~8MB

---

### 从旧项目继承的功能 ✅（无需重新开发）
- **计算器显示逻辑优化**: 2025-11-23 17:30 - 符合标准计算器习惯 ✅
  - ✅ 输入阶段：上方expression框保持空白，下方result框显示当前输入
  - ✅ 按等号后：表达式移到上方expression框，结果显示在result框
  - ✅ 表达式保存优化：在删除尾部运算符前保存原始表达式
  - ✅ 下一轮输入：自动清空上方表达式，新输入显示在下方
  - ✅ 历史记录：保存完整表达式（如 `12+34 = 46`）

- **ResultDisplay布局精细调整**: 2025-11-23 17:30 - 数字完美显示 ✅
  - ✅ 字号优化：expression 16px，result 36px（在100px容器中合理）
  - ✅ 固定高度：expression 20px，result 44px（明确空间分配）
  - ✅ 顶部对齐：`justifyContent: FlexAlign.Start`（避免分散对齐）
  - ✅ 间距调整：两行文本间距4px，上下padding 12px
  - ✅ 位置下移：`margin top: 48vp`（进一步优化与卡通区域间距）
  - ✅ 布局计算：12+20+4+44+12=92px < 100px ✅（8px余量）

- **应用图标集成**: 2025-11-23 16:00 - 三图标全部就位 ✅
  - ✅ background.png → AppScope/resources/base/media/
  - ✅ foreground.png → AppScope/resources/base/media/
  - ✅ startIcon.png → entry/src/main/resources/base/media/
  - ✅ 使用分层图标配置 `$media:layered_image`

- **Pacifico字体集成**: 2025-11-23 16:30 - 字体系统完整实现 ✅
  - ✅ 字体文件部署: Pacifico-Regular.ttf (315KB, SIL授权)
  - ✅ 生命周期修正: onCreate → onWindowStageCreate
  - ✅ API修正: font.registerFont → uiContext.font.registerFont
  - ✅ UI上下文注册: mainWindow.getUIContext()
  - ✅ 字体回退机制: 'Pacifico, HarmonyOS Sans'
  - ✅ 应用范围: CuteButton + ResultDisplay

- **状态栏布局优化**: 2025-11-23 16:20 - 沉浸式全屏适配 ✅
  - ✅ 移除顶部标题栏(避免遮挡)
  - ✅ 状态栏颜色设置为背景色 #FFD4A3
  - ✅ 使用Blank占位符预留48vp状态栏空间
  - ✅ 卡通区域padding恢复正常(top: 8)
  - ✅ 底部预留120vp导航栏安全距离

- **角色切换修复**: 2025-11-23 04:30 - PreferencesUtils持久化修复 ✅
  - ✅ 修复getCharacterType: 从硬编码改为实际读取storage
  - ✅ 修复setCharacterType: 添加put + flush持久化
  - ✅ 统一character type: 'cat' → 'whitecat'/'rabbit'
  - ✅ MainPage添加onPageShow生命周期
  - ✅ CharacterDecor添加@Watch监听

- **项目结构创建**: 2025-11-22 20:10 - 创建完整的目录结构 ✅
  - ✅ entry/src/main/ets 代码目录
  - ✅ resources/base/media 资源目录(buttons/characters/icons)
  - ✅ AppScope 全局配置目录
  - ✅ .claude 项目协作目录
  - ✅ figma 设计提示词目录

- **配置文件**: 2025-11-22 20:15 - 所有配置文件已创建 ✅
  - ✅ app.json5 (包名、图标配置)
  - ✅ module.json5 (EntryAbility、权限)
  - ✅ build-profile.json5 (API 20 兼容)
  - ✅ oh-package.json5 (Hvigor依赖)
  - ✅ local.properties (SDK路径)

- **核心源码**: 2025-11-22 20:20 - 华为官方源码已复制 ✅
  - ✅ CalculateUtil.ets (计算核心)
  - ✅ CheckEmptyUtil.ets (工具类)
  - ✅ HistoryUtils.ets (历史记录)

- **组件框架**: 2025-11-22 20:30 - 所有组件框架已创建 ✅
  - ✅ ThemeConfig.ets (主题配置)
  - ✅ CuteButton.ets (按钮组件 - 改为文字+背景色)
  - ✅ CharacterDecor.ets (角色组件 - 分层动画)
  - ✅ ResultDisplay.ets (结果显示)
  - ✅ CuteCalcKeyboard.ets (键盘组件)

- **页面框架**: 2025-11-22 20:40 - 所有页面框架已创建 ✅
  - ✅ MainPage.ets (主计算器 - 含广告位)
  - ✅ HistoryPage.ets (历史记录)
  - ✅ SettingsPage.ets (设置页面)

- **工具类**: 2025-11-22 20:45 - 辅助工具已创建 ✅
  - ✅ HapticUtils.ets (振动反馈)
  - ✅ PreferencesUtils.ets (设置存储)
  - ✅ HistoryUtils.ets (历史记录管理 - 基于AppStorageV2)

- **计算功能**: 2025-11-23 01:30 - 华为官方计算逻辑集成 ✅
  - ✅ 修复表达式数组管理（采用华为官方方式）
  - ✅ 实现inputSymbol/inputOperators/inputDelete/getResult方法
  - ✅ 集成CalculateUtil.parseExpression计算引擎
  - ✅ 修复ResultDisplay组件（@State改为@Prop）
  - ✅ 实时显示表达式和计算结果

- **历史记录功能**: 2025-11-23 02:00 - 完整功能实现 ✅
  - ✅ HistoryPage页面实现（列表展示、清空确认）
  - ✅ 计算结果自动保存到历史记录
  - ✅ 反向显示（最新记录在上）
  - ✅ 卡片式设计（带删除按钮、点击复制）
  - ✅ 页面导航（router.back返回主页）

- **设置功能**: 2025-11-23 02:10 - 完整功能实现 ✅
  - ✅ SettingsPage页面实现
  - ✅ 振动开关（Toggle组件 + PreferencesUtils）
  - ✅ 角色选择（对话框选择器）
  - ✅ 关于页面（版本信息v1.0.0）
  - ✅ 页面导航（router.back返回主页）

- **页面导航**: 2025-11-23 02:15 - 三页面互联完成 ✅
  - ✅ MainPage顶部标题栏导航按钮
  - ✅ MainPage卡通区域右侧橙色按钮
  - ✅ router.pushUrl实现页面跳转
  - ✅ router.back实现返回主页
  - ✅ main_pages.json配置完成

- **设置底部弹窗**: 2025-11-23 02:50 - 全新设置交互方式 ✅
  - ✅ SettingsSheet组件（CustomDialog底部弹出）
  - ✅ 角色选择（大图标卡片+选择按钮）
  - ✅ 震动开关（卡片式Toggle）
  - ✅ 使用条款和隐私政策（对话框）
  - ✅ 预留广告移除接口

- **设置弹窗全面优化**: 2025-11-23 03:15 - 6大UX优化完成 ✅
  - ✅ **方形卡片2×2布局**: 每排2个功能，方形卡片整齐排列
  - ✅ **角色选择页面**: 点击跳转CharacterSelectPage，展示猫咪图片
  - ✅ **纯文字简洁设计**: 震动/条款/政策移除图标emoji，仅文字
  - ✅ **政策合并显示**: 使用条款和隐私政策并排在第二排
  - ✅ **底部弹出动画**: openAnimation 300ms FastOutSlowIn曲线
  - ✅ **安全距离保护**: offset dy:-20vp，避免遮挡导航栏
  - ✅ **下滑关闭手势**: onTouch监听拖拽，超过100vp关闭弹窗

- **计算结果优化**: 2025-11-23 02:45 - 修复显示问题 ✅
  - ✅ 修复问题1：历史记录保存完整表达式（3+5×2 = 13）
  - ✅ 修复问题2：计算后清空表达式框，只显示结果
  - ✅ 修复问题3：下次输入数字自动清零重新开始

- **UI方案优化**: 2025-11-22 22:00 - 采用代码优先方案 ✅
  - ✅ 输入框使用 linearGradient 玻璃质感
  - ✅ 数字/符号使用 fontFamily 手绘字体
  - ✅ 按钮使用 backgroundColor + 颜色分层
  - ✅ 角色采用分层设计（body + arms）
  - ✅ 角色动画通过 @Link 实现（10vp垂直移动）

- **华为广告集成**: 2025-11-22 22:20 - 广告位规范集成 ✅
  - ✅ 符合华为官方规范（57vp/144vp）
  - ✅ 动态高度支持（0/73/160vp）
  - ✅ OAID获取逻辑预留
  - ✅ 刷新时间限制（30-120秒）
  - ✅ 完整接入文档（华为广告接入指南.md）

- **设计文档**: 2025-11-22 22:30 - 完整设计系统 ✅
  - ✅ globals.css (CSS变量)
  - ✅ Guidelines.md (600+行综合指南)
  - ✅ 00_使用说明.md (9步工作流)
  - ✅ 01_主计算器界面.txt (含设计上下文)
  - ✅ 02-05.txt (组件提示词)

### 新项目开发规划 🆕

#### P0（主题确定阶段）⏳ 进行中
- ⏳ **确定最终主题**: 从 A/B/C/D 中选择或提出新方案
- ⏳ **更新应用配置**: 根据主题修改包名、应用名称、图标
- ⏳ **规划素材需求**: 列出需要准备的角色、字体、配色方案
- ⏳ **设计桌面卡片**: 确定卡片类型（装饰性/实用性/两者兼具）

#### P1（主题素材准备）📋 待执行
- ✅ **配置文件**: app.json5, module.json5, build-profile.json5, oh-package.json5
- 📋 **角色素材绘制/获取**: 根据主题准备 4 种状态素材（分层或单层，取决于主题）
- 📋 **字体选择/制作**: 根据主题风格选择合适字体
  - 像素风 → 8-bit 字体
  - 赛博朋克 → 科幻字体
  - 机械键盘 → 无衬线字体
  - 禅意木鱼 → 书法字体
- 📋 **字体子集化**: 将字体文件从 300KB+ 压缩到 <20KB（仅保留 0-9 和运算符）
- 📋 **素材 WebP 化**: 将所有图片转换为 WebP 格式（压缩率 80%）
- 📋 **配色方案确定**: 更新 ThemeConfig.ets 的颜色常量

#### P2（主题代码改造）📋 待执行
- 📋 **ThemeConfig.ets**: 完全重写颜色、字体、风格配置
- 📋 **CharacterDecor.ets**: 更换角色素材引用，调整动画逻辑
- 📋 **CuteButton.ets**: 根据主题更新按钮样式（保留组件逻辑）
- 📋 **ResultDisplay.ets**: 根据主题更新显示样式（保留数据逻辑）
- 📋 **MainPage.ets**: 根据主题调整整体布局和配色
- 📋 **音效集成**: 如果主题需要音效（如机械键盘、木鱼），添加音频资源

#### P3（桌面卡片开发）📋 待执行
- 📋 **创建 FormExtension**: 实现桌面卡片能力
- 📋 **卡片 UI 设计**: 根据主题设计 2x2 或 2x4 卡片
- 📋 **卡片交互**: 点击跳转、数据同步
- 📋 **卡片配置**: 在 module.json5 中配置卡片能力

#### P4（轻量级优化）📋 待执行
- ✅ **代码混淆**: 已开启（build-profile.json5）
- 📋 **资源清理**: 移除旧项目无用的猫咪相关素材
- 📋 **依赖优化**: 检查并移除未使用的库
- 📋 **体积测试**: 确保最终 HAP 包 < 2MB

#### P5（测试与发布）📋 待执行
- 📋 **功能测试**: 验证所有继承功能正常（计算、历史、设置）
- 📋 **主题一致性**: 确保所有页面风格统一
- 📋 **性能测试**: 启动速度、流畅度
- 📋 **真机测试**: 不同设备适配
- 📋 **AppGallery 准备**: 签名、截图、描述

### 从旧项目继承的已知问题 ⚠️
（这些问题在主题改造过程中一并解决）

- ⚠️ **Deprecated API警告**（12个WARN）:
  - `router.pushUrl()` 需要添加 RouterMode 参数
  - `router.back()` 需要添加 url 参数
  - `promptAction.showToast()` 需要添加 duration 参数
  - `promptAction.showDialog()` 回调式改为Promise式
  - 影响: 不影响功能，但需要更新为新API
  - 状态: 部分已修复，还有剩余警告
  - 优先级: P3阶段修复

- ⚠️ **Lint代码风格警告**（91个WARN）:
  - 魔法数字警告（No magic number）
  - 多余空格警告（Multiple spaces found）
  - 函数空格警告（Unexpected space before brace）
  - 影响: 不影响编译和功能，仅代码风格问题
  - 状态: 暂时忽略，P5阶段统一优化
  - 优先级: 低（不阻塞开发）

### 新项目特别注意事项 ⚠️

#### 核心原则（继承自旧项目经验）
1. **不要破坏已有功能**: 旧项目的计算逻辑、页面导航、设置系统已经稳定，改造时只改 UI 和主题，不改逻辑。
2. **先读源码再实现**: 旧项目教训 - 必须完整理解数据结构后再动手（避免表达式数组管理错误）。
3. **删除前先确认**: 旧项目教训 - 删除任何代码前必须询问用户（避免误删已有功能）。
4. **不主动执行构建**: 旧项目教训 - 永远不要主动运行编译命令，只修复代码。

#### 资源管理规范
1. **资源命名规范**: 新主题的素材命名应统一，例如：
   - 像素风: `pixel_character_normal.png`
   - 赛博朋克: `cyber_robot_idle.png`
   - 机械键盘: `mech_keycap_01.png`
   - 禅意木鱼: `zen_monk_normal.png`
2. **配色文档**: 每个主题必须在 `figma/` 目录下创建独立的配色文档（如 `retro_colors.md`）。
3. **字体子集化**: 根据旧项目经验，字体文件必须子集化（仅保留 `0-9 + - × ÷ = . %` 等字符）。

#### 技术陷阱提醒（继承自旧项目）
1. **表达式数组管理**:
   - ✅ 正确: `expressions = ["3", "+", "5", "×", "2"]` 混合存储
   - ❌ 错误: `expressions = ["3", "5", "2"]` + `operators = ["+", "×"]` 分离存储
   - 原因: CalculateUtil.parseExpression 期望混合数组格式

2. **组件数据同步**:
   - ✅ 父组件传递: 使用 `@Prop` 装饰器
   - ❌ 组件内部: 不要使用 `@State`（无法同步父组件数据）
   - 示例: ResultDisplay 的 expression 和 result 必须是 @Prop

3. **字体注册生命周期** ⚠️ 非常重要：
   - ✅ 正确位置: `onWindowStageCreate()` 中
   - ✅ 正确API: `uiContext.font.registerFont()`
   - ✅ 正确获取: `mainWindow.getUIContext()`
   - ❌ 错误位置: `onCreate()` 中（UI上下文未初始化）
   - ❌ 错误API: 全局 `font.registerFont()`（无效）
   - 原因: 字体注册必须在UI上下文初始化后才能生效

4. **API版本兼容性**:
   - HarmonyOS NEXT API 20 弃用了部分旧API
   - 必须添加明确的参数（RouterMode、duration等）
   - 回调式改为Promise式（showDialog、showToast）

### 旧项目 AI 操作失误记录（新项目必读）🔴

以下是旧项目开发过程中的失误记录，新项目必须避免重蹈覆辙：

1. **2025-11-23 01:00 - 计算逻辑理解偏差** ⚠️ 严重
   - 问题: 最初使用了错误的表达式管理方式（分离的expressions和operators数组）
   - 正确方式: 华为官方使用单一expressions数组，数字和运算符混合存储
   - 教训: **必须先完整阅读官方源码，理解数据结构后再实现**
   - 新项目对策: 主题改造时不修改计算逻辑，只替换UI层

2. **2025-11-23 02:00 - 删除已有UI组件** ⚠️ 中等
   - 问题: 优化布局时误删除卡通区域的历史和设置按钮
   - 原因: 误认为顶部标题栏按钮足够，忽略了用户原有设计
   - 教训: **删除任何代码前必须询问用户确认**
   - 新项目对策: 主题改造时保留所有页面结构，仅更换颜色和素材

3. **2025-11-23 02:30 - 主动执行构建命令** ⚠️ 轻微
   - 问题: 修复代码后主动运行 hvigorw 构建命令
   - 原因: 想验证修复效果，但用户不希望AI主动构建
   - 教训: **永远不要主动执行构建/运行命令，只修复代码**
   - 新项目对策: 只提供修改建议，等待用户手动编译测试

4. **2025-11-23 16:30 - 字体注册生命周期错误** ⚠️ 严重
   - 问题: 尝试3轮才找到正确的字体注册方式
   - 根本原因: 不了解HarmonyOS的UI上下文初始化时机
   - 教训: **字体必须在onWindowStageCreate中通过uiContext注册**
   - 新项目对策: 如需更换字体，直接复用旧项目的正确实现方式

### 开发注意事项 📌
1. **表达式数组管理**:
   - ✅ 正确: `expressions = ["3", "+", "5", "×", "2"]` 混合存储
   - ❌ 错误: `expressions = ["3", "5", "2"]` + `operators = ["+", "×"]` 分离存储
   - 原因: CalculateUtil.parseExpression 期望混合数组格式

2. **组件数据同步**:
   - ✅ 父组件传递: 使用 `@Prop` 装饰器
   - ❌ 组件内部: 不要使用 `@State`（无法同步父组件数据）
   - 示例: ResultDisplay 的 expression 和 result 必须是 @Prop

3. **页面导航规范**:
   - ✅ 推荐: 使用顶部标题栏的图标按钮（简洁专业）
   - ✅ 可选: 卡通区域的橙色圆角按钮（可爱风格）
   - 注意: 两套按钮可以共存，不要随意删除

4. **API版本兼容性**:
   - HarmonyOS NEXT API 20 弃用了部分旧API
   - 必须添加明确的参数（RouterMode、duration等）
   - 回调式改为Promise式（showDialog、showToast）

5. **HistoryUtils依赖**:
   - 需要 AppStorageMap 常量类（定义在Constant.ets）
   - 使用 AppStorageV2 + @ObservedV2 实现响应式存储
   - 不要误导入小写的 historyUtils（不存在）

6. **PreferencesUtils方法**:
   - 必须实现 setCharacterType 方法（即使是预留功能）
   - 避免调用不存在的方法导致编译错误

### 性能优化记录 ⚡
- 暂无（待实施后记录）

---

## 6. 关键决策记录

### 2025-11-22 20:10 - 项目初始化和架构确定
- **背景**: 用户希望制作类似AppStore"可爱计算器"的应用，使用手绘UI素材
- **方案**: 
  1. **基于华为官方源码**: 保留 CalculateUtil.ets 计算核心逻辑(完全不修改)
  2. **UI完全改造**: 使用用户手绘的按钮和角色图片素材
  3. **简化功能**: 不要折扣计算器、不要科学计算器，只保留标准计算功能
  4. **角色动画**: 卡通角色分层设计（身体层固定+手臂层可动），每次按键时手臂上下活动
- **技术选型**:
  - SDK: API 20 (6.0.0) 稳定版
  - 图片格式: PNG @3x (200×200px)
  - 角色风格: 卡通可爱(猫咪为主)，**分层导出**（body + arms）
  - 角色动画: 手臂垂直平移动画，范围20-30px
  - 配色: 橙粉色调(#FF8C42, #FFB3C1)
- **架构优势**:
  - ✅ 计算逻辑稳定可靠(华为官方代码)
  - ✅ UI完全可控(用户自定义素材)
  - ✅ 交互生动有趣(角色手臂按键动画)
  - ✅ 开发周期短(1-2周)
  - ✅ 学习价值高(UI素材制作+动画实现)
- **影响**: 
  - 需要用户准备34+个UI素材文件（18个按钮 + 8个角色分层 + 图标等）
  - Figma设计和素材绘制将占用主要时间
  - 代码开发相对简单(复用华为源码)
  - 角色动画通过 @Link 实现组件间通信

### 2025-11-22 20:00 - 不采用折扣计算和科学计算功能
- **背景**: 原始参考应用有折扣计算功能，用户认为用处不大
- **决策**: 只保留标准四则运算计算器功能
- **理由**: 
  1. 折扣计算使用频率低
  2. 科学计算器复杂度高，不适合可爱风格
  3. 专注核心功能，保持简洁
- **影响**: 
  - 减少开发工作量
  - UI设计更简洁
  - 应用定位更明确(日常基础计算)

### 2025-11-22 22:00 - UI实现方案重大优化（代码优先）
- **背景**: 原方案需要26个PNG素材（18个按钮+8个角色），工作量大
- **用户方案**: 
  1. 输入框用 linearGradient 模拟玻璃质感
  2. 数字符号用 fontFamily 手绘字体
  3. 按钮用 backgroundColor 颜色分层
  4. 只有卡通角色必须用图片（无法代码绘制）
- **决策**: 完全采纳用户方案
- **理由**: 
  1. 时间节省70%（26个文件→8个文件）
  2. 包体积减少70%（~2MB→~600KB）
  3. 可维护性高（改代码比改图快）
  4. 灵活性强（颜色/字体随时可调）
- **技术实现**:
  - 输入框: Column + linearGradient + shadow
  - 按钮: Text + backgroundColor + borderRadius
  - 字体: resources/rawfile/fonts/cute_font.ttf
  - 角色: Stack(body + arms.translate)
- **影响**: 
  - Figma工作量大幅减少（只需设计角色）
  - 代码灵活度提升（支持主题切换）
  - 开发周期缩短（素材准备快）

### 2025-11-22 22:20 - 华为广告位规范集成
- **背景**: 用户希望预留广告位，后续接入华为广告
- **华为规范限制**: 
  - 横幅广告仅支持 360vp×57vp 或 360vp×144vp
  - 刷新时间必须在 30000~120000ms 范围
  - 必须获取设备OAID提升填充率
  - 测试ID: testw6vs28auh3
- **决策**: 采用动态高度广告位设计
- **技术实现**:
  ```typescript
  @State adHeight: number = 0;  // 0=无广告, 73=小横幅, 160=大横幅
  // 动态展开/收起，平滑动画300ms
  ```
- **影响**: 
  - 无广告时仅占24vp安全区
  - 有广告时自动扩展到73/160vp
  - 符合华为审核要求
  - 预留广告SDK接口（代码已注释）

### 2025-11-23 01:30 - 计算功能实现和表达式管理修复
- **背景**: 初始实现的计算逻辑无法正常工作，按钮点击后无结果
- **问题分析**:
  1. 使用了错误的表达式管理方式（分离的expressions和operators数组）
  2. CalculateUtil.parseExpression期望的是混合数组格式
  3. ResultDisplay使用@State导致父组件数据无法同步
- **解决方案**:
  1. 采用华为官方方式：`expressions = ["3", "+", "5", "×", "2"]` 混合存储
  2. 实现inputSymbol（数字输入）、inputOperators（运算符）、inputDelete（删除）、getResult（计算）
  3. ResultDisplay改用@Prop装饰器，支持父组件数据同步
- **技术细节**:
  - 数字输入：追加到最后一个元素（多位数）
  - 运算符输入：push新元素到数组
  - 删除操作：运算符删除整个元素，数字逐字符删除
  - 计算结果：移除尾部运算符后调用CalculateUtil.parseExpression
- **影响**: 
  - 计算功能正常工作
  - 表达式和结果实时显示
  - 符合华为官方计算器的实现模式

### 2025-11-23 02:10 - 历史记录和设置功能集成
- **背景**: 用户要求完善历史记录和设置页面功能
- **实现内容**:
  1. **HistoryPage**:
     - 使用HistoryUtils加载历史记录
     - 反向显示（最新在上）
     - 卡片式设计（删除按钮、点击复制）
     - 清空确认对话框
     - router.back返回主页
  2. **SettingsPage**:
     - 振动开关（Toggle + PreferencesUtils）
     - 角色选择对话框
     - 关于页面（版本v1.0.0）
     - router.back返回主页
  3. **MainPage导航**:
     - 修复HistoryUtils导入（大写）
     - 实现navigateToHistory/navigateToSettings方法
     - 顶部标题栏图标按钮可点击
     - 卡通区域橙色按钮可点击
- **编译修复**:
  - 添加AppStorageMap到Constant.ets
  - 添加setCharacterType到PreferencesUtils.ets
  - 添加promptAction导入到SettingsPage.ets
  - 更新deprecated API（RouterMode、duration、Promise式）
- **影响**: 
  - 三个页面互联完成
  - 历史记录自动保存和显示
  - 设置可持久化存储
  - 还有部分deprecated警告待修复

### 2025-11-23 02:50 - 计算结果显示优化和设置交互重构
- **背景**: 用户反馈5个问题需要优化
- **问题列表**:
  1. 计算过程没有记录，历史记录不显示
  2. 计算结果后表达式框不清零，需手动删除
  3. 设置改为底部弹出卡片
  4. 设置内容改为中大型图标
  5. 设置功能调整（角色选择+震动开关+使用条款/隐私政策+预留广告移除）
- **解决方案**:
  1. **修复历史记录保存**:
     - 保存格式改为完整表达式：`3+5×2 = 13`
     - 在handleEqual()中调用HistoryUtils.updateHistoryResult()
  2. **修复计算结果显示**:
     - 计算后清空expressions数组
     - displayExpr只显示结果
     - 下次输入数字时自动清零重新开始
  3. **重构设置交互**:
     - 创建SettingsSheet组件（CustomDialog底部弹出）
     - 使用@Link双向绑定vibrateEnabled和characterType
     - MainPage改用settingsDialogController.open()
  4. **设置UI优化**:
     - 角色选择：100×100图标卡片+名字+选择按钮
     - 震动开关：60×60图标+状态文字+Toggle
     - 使用条款/隐私政策：50×50图标+箭头+对话框
     - 预留广告移除接口（buildAdRemovalCard方法）
- **技术实现**:
  ```typescript
  // 设置弹窗控制器
  settingsDialogController: CustomDialogController = new CustomDialogController({
    builder: SettingsSheet({ vibrateEnabled: $vibrateEnabled, characterType: $characterType }),
    alignment: DialogAlignment.Bottom,
    customStyle: true
  })
  ```
- **影响**: 
  - 历史记录正常显示完整计算过程
  - 计算体验更流畅（自动清零）
  - 设置交互更现代化（底部Sheet）
  - UI更美观（大图标卡片）
  - 预留广告移除功能接口

### 2025-11-23 16:30 - Pacifico字体集成的生命周期决策
- **背景**: 尝试3轮字体注册均失败，需找到根本原因
- **问题演变**:
  1. **第一轮**: 路径问题
     - 尝试: `'/resources/rawfile/fonts/...'` 和 `$rawfile()`
     - 结果: 字体仍未生效
  2. **第二轮**: 生命周期问题
     - 尝试: 从onCreate()移至onWindowStageCreate()
     - 结果: 字体仍未生效
  3. **第三轮**: API使用问题
     - 发现: 必须使用 `uiContext.font.registerFont()` 而非全局 `font.registerFont()`
     - 结果: ✅ 问题解决
- **关键决策**: 为什么必须在onWindowStageCreate中通过UIContext注册字体？
  - **技术原因**:
    | 阶段 | onCreate() | onWindowStageCreate() |
    |------|-----------|---------------------|
    | UI上下文 | ❌ 未初始化 | ✅ 已初始化 |
    | Window对象 | ❌ 不可用 | ✅ 可用 |
    | UIContext | ❌ 无法获取 | ✅ 通过mainWindow获取 |
    | 字体API | ❌ 全局API无效 | ✅ uiContext.font生效 |
  
  - **错误示范** (onCreate中注册):
    ```typescript
    import { font } from '@kit.ArkUI';
    onCreate() {
      font.registerFont({  // ❌ UI上下文未初始化，注册失败
        familyName: 'Pacifico',
        familySrc: $rawfile('fonts/Pacifico-Regular.ttf')
      });
    }
    ```
  
  - **正确实现** (onWindowStageCreate中注册):
    ```typescript
    onWindowStageCreate(windowStage: window.WindowStage) {
      windowStage.loadContent('pages/MainPage', (err) => {
        if (err.code) return;
        
        windowStage.getMainWindow().then((mainWindow) => {
          // 关键：获取UI上下文
          const uiContext = mainWindow.getUIContext();
          
          // 通过UIContext注册字体
          uiContext.font.registerFont({
            familyName: 'Pacifico',
            familySrc: $rawfile('fonts/Pacifico-Regular.ttf')
          });
          
          hilog.info('Pacifico registered successfully via UIContext');
        });
      });
    }
    ```

- **字体回退机制**:
  - **目的**: 如果Pacifico加载失败，自动回退到系统字体
  - **实现**: `.fontFamily('Pacifico, HarmonyOS Sans')`
  - **应用位置**: CuteButton.ets、ResultDisplay.ets
  - **好处**: 提升应用健壮性，避免字体加载失败导致白屏

- **验证方法**:
  1. 查看Log窗口: `Pacifico registered successfully via UIContext`
  2. 观察UI: 数字和结果应显示为手写字体
  3. 如果显示为系统字体: 检查ttf文件是否存在于rawfile/fonts/

- **经验总结**:
  - ✅ 字体注册必须在 `onWindowStageCreate()` 中
  - ✅ 必须使用 `uiContext.font.registerFont()`
  - ✅ 必须通过 `mainWindow.getUIContext()` 获取上下文
  - ✅ 添加字体回退机制提升健壮性
  - ❌ 不要在 `onCreate()` 中注册字体
  - ❌ 不要使用全局 `font.registerFont()`

- **影响**:
  - Pacifico手写字体成功应用到计算器数字和结果
  - UI更具亲和力和童趣感
  - 为后续字体集成提供标准流程

---

## 7. 开发约定

### 代码规范
- **命名约定**:
  - 组件: PascalCase (`CuteButton.ets`)
  - 变量/函数: camelCase (`buttonClick`)
  - 常量: UPPER_SNAKE_CASE (`THEME_ORANGE`)
  - 私有成员: 前缀下划线 (`private _data`)

- **图标配置规范** (强制):
  ```json5
  // ✅ 必须统一使用
  "icon": "$media:layered_image"
  
  // ❌ 永远不要使用
  "icon": "$media:app_icon"
  "icon": "$media:icon"
  ```

- **资源引用方式**:
  ```typescript
  // 按钮图片
  Image($r('app.media.btn_0'))
  
  // 角色图片
  Image($r('app.media.cat_normal'))
  ```

- **注释要求**:
  - 组件参数使用 JSDoc 注释
  - 复杂逻辑必须添加注释
  - 华为源码保持原有注释

### Git 规范
- **Commit 格式**:
  ```
  feat(CuteCalculator): 添加可爱按钮组件
  fix(CuteCalculator): 修复计算精度问题
  refactor(CuteCalculator): 重构键盘布局
  docs(CuteCalculator): 更新UI素材设计规范
  ```

- **分支策略**: 
  - 主分支: `develop`
  - 功能完成立即 commit + push
  - 一个 commit 只做一件事

---

## 8. UI素材设计规范

### 核心颜色系统
```typescript
// 主色调
PRIMARY_ORANGE = '#FF8C42'    // 主题橙
PRIMARY_PINK = '#FFB3C1'      // 主题粉

// 背景色
BG_MAIN = '#FFF5E6'           // 主背景(奶油色)
BG_CARD = '#FFFFFF'           // 卡片背景

// 按钮色
BTN_NORMAL = '#FFF5E6'        // 数字按钮
BTN_OPERATOR = '#FFB366'      // 运算符按钮
BTN_EQUAL = '#FF8C42'         // 等号按钮
BTN_CLEAR = '#FF6B6B'         // 清空按钮
BTN_DEL = '#D1D1D6'           // 删除按钮

// 文字色
TEXT_PRIMARY = '#C17735'      // 主文字(深棕)
TEXT_WHITE = '#FFFFFF'        // 白色文字
TEXT_SECONDARY = '#8E8E93'    // 次要文字
```

### 按钮素材规格
```
数字按钮 (0-9):
  - 尺寸: 200×200px (@3x)
  - 格式: PNG 透明背景
  - 圆角: 48px
  - 背景色: #FFF5E6
  - 文字: 80px Bold #C17735

运算符按钮 (+,-,×,÷):
  - 尺寸: 200×200px (@3x)
  - 背景色: #FFB366
  - 符号: 80px #FFFFFF

特殊按钮:
  - 等号: 200×416px (双倍高) #FF8C42
  - 数字0: 416×200px (双倍宽)
  - 清空C: 200×200px #FF6B6B
  - 删除: 200×200px #D1D1D6
```

### 角色素材规格（重要！用户正在绘制）
```
卡通角色(猫咪) - 分层设计:
  
  【尺寸要求】✅ 更新
  - 画布大小: 1024×1024px (正方形，标准图标尺寸)
  - 安全区域: 居中 900×900px（四周留白62px）
  - 导出格式: PNG 透明背景
  - 分辨率: 300 DPI
  
  【分层结构】（关键！）
  ├── 身体层 (body): 
  │   └── 包含: 头部、身体、耳朵、表情、尾巴
  │   └── 特征: 完全静止，不做动画
  │
  └── 手臂层 (arms):
      └── 包含: 左手臂 + 右手臂（两只手都要画！）
      └── 特征: 单独图层，可垂直移动
      └── 位置: 与身体层完美对齐（叠加后看起来像一个整体）
  
  【4种表情状态】
  1. normal (正常):
     - 表情: 微笑、眼睛睁开 😊
     - 手臂: 自然下垂，轻松姿态
     - 配色: 身体橙色#FF8C42，手臂粉色#FFB3C1
  
  2. calculating (计算中):
     - 表情: 专注、眼睛盯着计算 🤔
     - 手臂: 一只手抬起（像在按计算器）
     - 特效: 可选添加小星星✨
  
  3. result (结果):
     - 表情: 开心、眼睛笑眯眯 😄
     - 手臂: 双手举起庆祝姿态
     - 特效: 可选添加闪光💫
  
  4. error (错误):
     - 表情: 惊讶、眼睛睁大 😮
     - 手臂: 双手捂脸或摊手
     - 配色: 可以稍微变暗表示错误
  
  【最终导出】
  4种状态 × 2层 = 8个PNG文件:
  ✅ cat_normal_body.png        (1024×1024px, 透明背景)
  ✅ cat_normal_arms.png        (1024×1024px, 透明背景)
  ✅ cat_calculating_body.png   (1024×1024px, 透明背景)
  ✅ cat_calculating_arms.png   (1024×1024px, 透明背景)
  ✅ cat_result_body.png        (1024×1024px, 透明背景)
  ✅ cat_result_arms.png        (1024×1024px, 透明背景)
  ✅ cat_error_body.png         (1024×1024px, 透明背景)
  ✅ cat_error_arms.png         (1024×1024px, 透明背景)
  
  【手臂动画效果】
  - 触发时机: 用户每次按键
  - 动画轨迹: arms层 垂直向下10vp → 回弹到0vp
  - 动画时长: 下移80ms → 回弹120ms（总200ms）
  - 动画曲线: Curve.EaseOut（自然回弹）
  - 视觉效果: 就像猫咪的手在按计算器按键！
  
  【图层对齐关键点】
  ⚠️ 非常重要！body和arms必须完美对齐：
  1. 两个图层使用相同的1024×1024px画布
  2. 身体和手臂的连接处必须无缝衔接
  3. 导出时保持透明背景
  4. 测试方法: 在PS/AI中叠加两层，应该看起来像完整的猫咪
  
  【显示尺寸】
  - 代码中设置: width(150).height(150)  // 单位vp
  - 实际显示: 约150×150vp（根据设备DPI自动缩放）
  - 高分辨率素材确保在所有设备上清晰显示
```

**详细设计规范**: 参见 `UI素材设计规范.md`

---

## 9. Figma设计提示词

### 提示词文件列表
```
figma/
├── 00_使用说明.md              # 中文使用指南
├── 01_主计算器界面.txt         # 主界面提示词(英文)
├── 02_历史记录页面.txt         # 历史页面提示词
└── 03_设置页面.txt             # 设置页面提示词
```

### 使用流程
```
1. 打开 .txt 文件复制提示词
2. 在 Figma 中使用 Make AI 功能
3. 粘贴提示词生成设计
4. 调整细节(颜色、间距)
5. 分享 Figma Make 链接给 AI
6. AI 评估设计符合度
7. 如有问题,AI 优化提示词
8. 重新生成直到符合要求
9. AI 生成 ArkTS 代码
```

**注意**: Figma Make 文件可以被 AI 直接读取!

---

## 10. 故障排除

### SDK 路径配置
```properties
# ✅ 正确配置
sdk.dir=C:\\Program Files\\Huawei\\DevEco Studio\\sdk
nodejs.dir=C:\\Program Files\\nodejs

# ❌ 错误配置
sdk.dir=C:\\Users\\Lenovo\\AppData\\Local\\OpenHarmony\\Sdk
```

### 常见编译错误
| 错误信息 | 原因 | 解决方案 |
|---------|------|---------|
| SDK component missing | SDK路径错误 | 检查 local.properties |
| Cannot find module | 依赖未安装 | 运行 ohpm install |
| 装饰器解析错误 | ESLint配置问题 | 正常现象,不影响编译 |

### 图片资源加载失败
- **原因**: 资源路径错误或文件名不匹配
- **解决**: 检查文件命名规范,使用 `$r('app.media.xxx')`

---

## 11. 相关资源

### 项目文档
- **实施方案**: `可爱计算器改造方案.md` (根目录)
- **UI设计规范**: `UI素材设计规范.md` (项目目录)
- **工厂级文档**: `../../.claude/CLAUDE.md`

### 华为官方资源
- 计算器源码: `计算器源码/module_standard_calculator/`
- HarmonyOS 文档: https://developer.huawei.com/consumer/cn/doc/
- ArkTS API: https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/

### 设计参考
- AppStore 可爱计算器截图(已提供)
- Figma Make AI: https://help.figma.com/

---

## 12. 下一步行动

### 立即执行（最高优先级）🔥
- [ ] **用户确定最终主题**: 从 A/B/C/D 中选择，或提出新方案
- [ ] **更新项目文档**: 根据主题更新 CLAUDE.md 的第 1、8、9 章节

### 主题确定后立即执行 📋
1. **更新应用配置**:
   - [ ] 修改包名（app.json5 中的 bundleName）
   - [ ] 修改应用名称（string.json 中的 app_name）
   - [ ] 设计新应用图标（foreground.png, background.png）

2. **规划素材清单**:
   - [ ] 列出需要的角色素材数量和状态
   - [ ] 确定字体选择（系统字体 or 自定义字体）
   - [ ] 确定配色方案（主色、背景色、按钮色）

3. **创建主题设计文档**:
   - [ ] 在 `figma/` 目录创建新主题设计文档
   - [ ] 编写 Figma 提示词（如有需要）

### 代码改造执行计划 🛠️
（主题确定后，按此顺序执行）

1. **ThemeConfig.ets 改造**（核心）
2. **CharacterDecor.ets 素材替换**
3. **按钮组件样式更新**
4. **页面配色调整**
5. **音效集成**（如主题需要）
6. **桌面卡片开发**

### 当前等待项 ⏳
- ⏳ **用户决策**: 选择最终主题
- ⏳ **素材准备**: 根据主题开始绘制/获取素材
- ⏳ **字体准备**: 根据主题选择/制作字体

---

## 附录：关键决策详细记录

### 2025-11-23 03:15 - 设置弹窗UX全面优化（6大优化点）✨

**背景**: 用户对02:50版本的设置弹窗提出6个细节优化需求

**问题清单**:
1. 设置里面是方形图标，不是长方形，并做成2排，每排2个功能
2. 角色选择按键：点击进去才看到角色，角色用真实猫咪图片展示
3. 震动/使用条款/隐私政策移除图标，只保留文字
4. 使用条款和隐私政策合并在一起
5. 弹窗从底部原大小弹出，有动画效果
6. 距离导航栏保持20vp安全距离
7. 顶部拖拽条需要支持下滑关闭手势

**解决方案**:

1️⃣ **方形卡片2×2布局**
```typescript
// 第一排：角色选择 + 震动开关
Row({ space: 16 }) {
  buildCharacterCard()  // width: calc(50% - 8vp), aspectRatio: 1
  buildVibrateCard()    // width: calc(50% - 8vp), aspectRatio: 1
}

// 第二排：使用条款 + 隐私政策
Row({ space: 16 }) {
  使用条款卡片  // width: calc(50% - 8vp), height: 60
  隐私政策卡片  // width: calc(50% - 8vp), height: 60
}
```

2️⃣ **角色选择独立页面**
- 创建 `CharacterSelectPage.ets`
- 点击卡片 → `router.pushUrl({ url: 'pages/CharacterSelectPage' })`
- 页面布局：顶部导航栏 + 滚动角色列表
- 角色卡片：200×200图片预览 + 角色名称 + 描述 + 选择按钮
- 图片资源：`$r('app.media.cat_normal')` (暂用SVG占位)
- 已选中状态：橙色边框 + ✓已选择按钮

3️⃣ **纯文字简洁设计**
- 移除所有emoji图标 (📳🔒📜)
- 卡片内容：
  - 角色选择：🐱图标 + "角色选择" + "可爱猫咪"
  - 震动开关：Toggle + "按键震动" + "已开启/已关闭"
  - 使用条款：仅文字 "使用条款"
  - 隐私政策：仅文字 "隐私政策"

4️⃣ **底部弹出动画**
```typescript
CustomDialogController({
  openAnimation: {
    duration: 300,
    curve: Curve.FastOutSlowIn,
    playMode: PlayMode.Normal
  },
  closeAnimation: {
    duration: 250,
    curve: Curve.FastOutLinearIn,
    playMode: PlayMode.Normal
  }
})
```

5️⃣ **安全距离保护**
```typescript
offset: { dx: 0, dy: -20 }  // 距离底部导航栏20vp
```

6️⃣ **下滑关闭手势**
```typescript
@State dragOffsetY: number = 0;
@State isDragging: boolean = false;
private CLOSE_THRESHOLD: number = 100; // 下滑100vp关闭

.onTouch((event: TouchEvent) => {
  if (event.type === TouchType.Down) {
    this.startY = event.touches[0].y;
    this.isDragging = true;
  } else if (event.type === TouchType.Move) {
    const deltaY = event.touches[0].y - this.startY;
    if (deltaY > 0) {  // 只允许向下拖拽
      this.dragOffsetY = deltaY;
    }
  } else if (event.type === TouchType.Up) {
    this.isDragging = false;
    if (this.dragOffsetY > this.CLOSE_THRESHOLD) {
      this.controller.close();  // 关闭弹窗
    }
    this.dragOffsetY = 0;  // 重置位置
  }
})
.translate({ y: this.dragOffsetY })  // 跟随手指
.animation({
  duration: this.isDragging ? 0 : 300,  // 拖拽时无动画，释放时有动画
  curve: Curve.EaseOut
})
```

**新增文件**:
- `CharacterSelectPage.ets` (186行) - 角色选择页面
- `ic_back.svg` - 返回按钮图标
- `cat_normal.svg` - 临时占位猫咪图标（等待用户PNG）

**修改文件**:
- `SettingsSheet.ets` - 重构为2×2方形卡片布局 + 手势支持
- `MainPage.ets` - 更新CustomDialogController配置（动画+安全距离）

**技术要点**:
- `aspectRatio(1)` 实现方形卡片
- `calc(50% - 8vp)` 实现2列等宽布局
- `TouchEvent` 监听实现手势拖拽
- `translate()` + `animation()` 实现流畅动画
- `FastOutSlowIn` 曲线符合Material Design规范

**影响**:
- ✅ 设置界面更整洁美观（方形卡片2×2网格）
- ✅ 角色选择体验更好（独立页面+大图预览）
- ✅ 交互更流畅（手势关闭+动画过渡）
- ✅ 符合HarmonyOS设计规范（安全距离+底部弹出）
- ⏳ 等待用户提供真实猫咪PNG替换SVG占位图

---

**记住**: 这是项目级文档,工厂级总览请查看 `../../.claude/CLAUDE.md`

**核心原则**:
- ✅ 保留华为计算核心逻辑(不修改)
- ✅ UI完全自定义(手绘素材)
- ✅ 功能简洁专注(标准计算器)
- ✅ 开发周期可控(1-2周)
