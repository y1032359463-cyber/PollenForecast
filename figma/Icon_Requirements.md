# Healthy_life 应用图标需求清单

> **用途**: 为 Figma 设计和 HarmonyOS 开发准备的完整图标列表  
> **更新时间**: 2025年11月14日

---

## 📋 图标分类总览

| 类别 | 数量 | 用途 |
|------|------|------|
| 导航图标 | 4 | 底部导航栏 |
| 运动类型图标 | 12 | 训练类型选择 |
| 数据指标图标 | 8 | 数据卡片和统计 |
| 操作按钮图标 | 6 | 交互控制 |
| 状态图标 | 4 | 成就和进度 |
| **总计** | **34** | |

---

## 1. 导航图标 (Navigation Icons)

**规格**: 24px × 24px, 2px 描边

| 中文名 | 英文名 | Icon Name | 用途 | 状态 |
|--------|--------|-----------|------|------|
| 首页 | Home | `home` | 底部导航-活动摘要页 | 默认/激活 |
| 训练 | Workout | `dumbbell` | 底部导航-训练库页 | 默认/激活 |
| 统计 | Statistics | `chart_bar` | 底部导航-统计页 | 默认/激活 |
| 我的 | Profile | `person` | 底部导航-个人页 | 默认/激活 |

**Figma 生成提示词**:
```
Create a set of 4 navigation icons for a fitness app bottom tab bar.
Size: 24px × 24px, 2px stroke width, rounded line caps.
Style: Minimal, line-based icons.

Icons needed:
1. Home: Simple house outline
2. Workout: Dumbbell outline
3. Statistics: Bar chart with 3 bars
4. Profile: Person silhouette circle

Create 2 states for each:
- Default: #9E9E9E (gray)
- Active: #007DFF (blue) with slight bold effect

Export as SVG with proper naming: icon_home_default.svg, icon_home_active.svg, etc.
```

---

## 2. 运动类型图标 (Workout Type Icons)

**规格**: 48px × 48px, Emoji 或线性图标

| 中文名 | 英文名 | Emoji | 替代图标 | 配色 |
|--------|--------|-------|----------|------|
| 跑步 | Running | 🏃 | `directions_run` | 橙色 #FF9800 |
| 骑行 | Cycling | 🚴 | `directions_bike` | 蓝色 #2196F3 |
| 瑜伽 | Yoga | 🧘 | `self_improvement` | 绿色 #00C853 |
| 力量训练 | Strength | 🏋️ | `fitness_center` | 红色 #E53935 |
| 游泳 | Swimming | 🏊 | `pool` | 青色 #00BCD4 |
| 步行 | Walking | 🚶 | `directions_walk` | 紫色 #9C27B0 |
| 攀岩 | Climbing | 🧗 | `terrain` | 棕色 #795548 |
| 拳击 | Boxing | 🥊 | `sports_martial_arts` | 深红 #C62828 |
| 篮球 | Basketball | 🏀 | `sports_basketball` | 橙色 #FF6F00 |
| 足球 | Soccer | ⚽ | `sports_soccer` | 绿色 #43A047 |
| 网球 | Tennis | 🎾 | `sports_tennis` | 黄绿 #9CCC65 |
| 冥想 | Meditation | 🧘‍♀️ | `spa` | 淡紫 #BA68C8 |

**Figma 生成提示词**:
```
Create 12 workout type icons for a fitness app.
Size: 48px × 48px circular containers.

Each icon:
- Emoji: 32px centered emoji
- Background: Circular gradient (matching workout color)
- Border radius: 24px (perfect circle)

Workout types with colors:
1. Running 🏃 - Orange gradient (#FF9800 to #FFB74D)
2. Cycling 🚴 - Blue gradient (#2196F3 to #64B5F6)
3. Yoga 🧘 - Green gradient (#00C853 to #69F0AE)
4. Strength 🏋️ - Red gradient (#E53935 to #EF5350)
5. Swimming 🏊 - Cyan gradient (#00BCD4 to #4DD0E1)
6. Walking 🚶 - Purple gradient (#9C27B0 to #BA68C8)
7. Climbing 🧗 - Brown gradient (#795548 to #A1887F)
8. Boxing 🥊 - Deep red gradient (#C62828 to #E53935)
9. Basketball 🏀 - Orange gradient (#FF6F00 to #FF8F00)
10. Soccer ⚽ - Green gradient (#43A047 to #66BB6A)
11. Tennis 🎾 - Yellow-green gradient (#9CCC65 to #AED581)
12. Meditation 🧘‍♀️ - Light purple gradient (#BA68C8 to #CE93D8)

Export as individual components.
```

---

## 3. 数据指标图标 (Data Metric Icons)

**规格**: 32px × 32px, Emoji 或单色图标

| 中文名 | 英文名 | Emoji | Icon Name | 用途 | 颜色 |
|--------|--------|-------|-----------|------|------|
| 卡路里 | Calories | 🔥 | `local_fire_department` | 消耗统计 | 橙色 #FF9800 |
| 步数 | Steps | 👟 | `directions_walk` | 步数统计 | 蓝色 #007DFF |
| 距离 | Distance | 🚶 | `straighten` | 运动距离 | 绿色 #00C853 |
| 时长 | Duration | ⏱ | `timer` | 活动时长 | 紫色 #9C27B0 |
| 心率 | Heart Rate | ❤️ | `favorite` | 心率监测 | 红色 #FA114F |
| 配速 | Pace | 📊 | `speed` | 跑步配速 | 青色 #00BCD4 |
| 海拔 | Elevation | ⛰ | `terrain` | 爬升高度 | 棕色 #795548 |
| 步频 | Cadence | 🎵 | `graphic_eq` | 步频统计 | 黄色 #FFC107 |

**Figma 生成提示词**:
```
Create 8 data metric icons for fitness statistics.
Size: 32px × 32px emoji icons.

Icons with context:
1. 🔥 Calories - with orange glow
2. 👟 Steps - with blue accent
3. 🚶 Distance - with green accent
4. ⏱ Duration - with purple accent
5. ❤️ Heart Rate - with red accent
6. 📊 Pace - with cyan accent
7. ⛰ Elevation - with brown accent
8. 🎵 Cadence - with yellow accent

Style: Colorful emoji with subtle shadow (0 2px 4px rgba(0,0,0,0.1))
```

---

## 4. 操作按钮图标 (Action Button Icons)

**规格**: 24px - 32px, 线性图标

| 中文名 | 英文名 | Icon Name | 用途 | 尺寸 |
|--------|--------|-----------|------|------|
| 播放 | Play | `play_arrow` | 开始训练 | 32px |
| 暂停 | Pause | `pause` | 暂停训练 | 32px |
| 停止 | Stop | `stop` | 停止训练 | 32px |
| 添加 | Add | `add` | 新增记录 | 24px |
| 编辑 | Edit | `edit` | 编辑数据 | 24px |
| 分享 | Share | `share` | 分享成就 | 24px |

**Figma 生成提示词**:
```
Create 6 action button icons for fitness app controls.
Style: Rounded line icons, 2px stroke.

Large controls (32px):
1. Play: Right-pointing triangle in circle
2. Pause: Two vertical bars in circle
3. Stop: Square in circle

Small controls (24px):
4. Add: Plus sign in circle
5. Edit: Pencil icon
6. Share: Share arrow icon

Colors:
- Primary action (Play): #007DFF
- Destructive (Stop): #E53935
- Neutral (others): #212121

Export with states: default, pressed (0.7 opacity)
```

---

## 5. 状态图标 (Status Icons)

**规格**: 40px - 56px, 带背景

| 中文名 | 英文名 | Icon Name | 用途 | 样式 |
|--------|--------|-----------|------|------|
| 奖杯 | Trophy | `emoji_events` | 成就徽章 | 金色渐变 |
| 勋章 | Medal | `military_tech` | 完成里程碑 | 银色渐变 |
| 火焰 | Streak | `whatshot` | 连续打卡 | 橙红渐变 |
| 目标 | Target | `track_changes` | 目标达成 | 绿色渐变 |

**Figma 生成提示词**:
```
Create 4 achievement badge icons for fitness app.
Size: 56px × 56px circular badges.

Badges:
1. Trophy 🏆 - Gold gradient (#FFD700 to #FFA500)
   - Background: Radial gold shine
   - Icon: Trophy emoji 40px

2. Medal 🥈 - Silver gradient (#C0C0C0 to #E8E8E8)
   - Background: Radial silver shine
   - Icon: Medal emoji 40px

3. Streak 🔥 - Orange-red gradient (#FF9800 to #FA114F)
   - Background: Fire glow effect
   - Icon: Fire emoji 40px

4. Target 🎯 - Green gradient (#00C853 to #69F0AE)
   - Background: Success radial glow
   - Icon: Target emoji 40px

Style: Glossy 3D effect with subtle shadow (0 4px 12px rgba(0,0,0,0.15))
```

---

## 6. 系统功能图标 (System Function Icons)

**规格**: 20px × 20px, 单色

| 中文名 | 英文名 | Icon Name | 用途 |
|--------|--------|-----------|------|
| 设置 | Settings | `settings` | 设置入口 |
| 通知 | Notification | `notifications` | 通知中心 |
| 搜索 | Search | `search` | 搜索功能 |
| 筛选 | Filter | `filter_list` | 数据筛选 |
| 刷新 | Refresh | `refresh` | 刷新数据 |
| 更多 | More | `more_horiz` | 更多选项 |
| 返回 | Back | `arrow_back` | 返回上页 |
| 关闭 | Close | `close` | 关闭弹窗 |

**Figma 生成提示词**:
```
Create 8 system function icons for app interface.
Size: 20px × 20px, 1.5px stroke, minimal style.

Icons:
1. Settings: Gear icon
2. Notification: Bell icon
3. Search: Magnifying glass
4. Filter: Funnel icon
5. Refresh: Circular arrow
6. More: Three horizontal dots
7. Back: Left arrow
8. Close: X mark

Color: #212121 (dark) for light theme, #FAFAFA (light) for dark theme
Style: Clean, rounded line icons matching HarmonyOS design language
```

---

## 7. Activity Rings 图标元素

**规格**: 可缩放矢量图形

| 元素名 | 英文名 | 颜色 | 描述 |
|--------|--------|------|------|
| 活动环 | Move Ring | #FA114F | 内环-红色 |
| 锻炼环 | Exercise Ring | #92E82A | 中环-绿色 |
| 站立环 | Stand Ring | #00F0FF | 外环-青色 |

**Figma 生成提示词** (已在 Prompt 4 中):
```
Create Activity Rings component (see Prompt 4 in Guidelines.md)
- 3 concentric progress rings
- Customizable progress percentage
- Glow effect on each ring
```

---

## 📦 HarmonyOS 资源导出规范

### SVG 导出设置
```
- 格式: SVG
- 精度: Decimal places = 2
- 布尔运算: Outline strokes
- 文本: Convert to outlines
- 命名: icon_[category]_[name]_[state].svg
```

### 命名规范示例
```
icon_nav_home_default.svg          // 导航-首页-默认态
icon_nav_home_active.svg           // 导航-首页-激活态
icon_workout_running.svg           // 运动-跑步
icon_data_calories.svg             // 数据-卡路里
icon_action_play.svg               // 操作-播放
icon_status_trophy.svg             // 状态-奖杯
icon_system_settings.svg           // 系统-设置
```

---

## 🎨 图标设计检查清单

- [ ] **尺寸规范**: 所有图标符合指定尺寸（20px/24px/32px/48px）
- [ ] **描边一致**: 线性图标统一 2px 描边，系统图标 1.5px
- [ ] **圆角统一**: 所有线端使用圆角 (rounded line caps)
- [ ] **颜色准确**: 严格遵守色值表（#007DFF、#FF9800 等）
- [ ] **可读性**: 24px 尺寸下清晰可辨
- [ ] **触摸区域**: 最小 44px × 44px 触摸热区
- [ ] **状态变体**: 交互图标包含默认/激活/按下态
- [ ] **深色适配**: 提供深色模式变体（浅色图标）
- [ ] **导出格式**: SVG 矢量格式，可缩放
- [ ] **命名规范**: 符合 icon_[category]_[name]_[state] 格式

---

## 🔗 相关资源

- **HarmonyOS 图标库**: https://developer.huawei.com/consumer/cn/design/harmonyos-icon/
- **Material Symbols**: https://fonts.google.com/icons (备用参考)
- **Apple SF Symbols**: https://developer.apple.com/sf-symbols/ (风格参考)
- **Figma 设计指南**: `Guidelines.md`

---

## 📝 开发集成说明

### ArkTS 中使用图标
```typescript
// 1. 使用 SymbolGlyph (系统图标)
SymbolGlyph($r('sys.symbol.home'))
  .fontSize(24)
  .fontColor('#007DFF')

// 2. 使用自定义 SVG
Image($r('app.media.icon_workout_running'))
  .width(48)
  .height(48)
  .fillColor('#FF9800')

// 3. 使用 Emoji
Text('🏃')
  .fontSize(48)
```

### 资源目录结构
```
entry/src/main/resources/
├── base/
│   ├── media/
│   │   ├── icon_nav_home_default.svg
│   │   ├── icon_nav_home_active.svg
│   │   ├── icon_workout_running.svg
│   │   └── ...
│   └── profile/
│       └── main_pages.json
```

---

**最后更新**: 2025年11月14日  
**维护者**: Eric  
**总图标数**: 34 个（不含状态变体）
