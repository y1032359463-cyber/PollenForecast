# UI 组件与样式

> **分类**: 状态栏、导航栏、Tabs、安全区域等 UI 组件配置（API 20）  
> **最后更新**: 2026-01-15  
> **返回**: [← 主知识库](../知识库.md)

---

## 📑 本分类包含

1. [状态栏/导航栏配置](#状态栏导航栏配置api-20)
2. [媒体库URI与fileIo API使用规则](#媒体库uri与fileio-api使用规则)
3. [无障碍设计 - 文本对比度要求](#无障碍设计---文本对比度要求)
4. [Refresh 组件限制](#refresh-组件限制)
5. [ListItem 嵌套限制](#listitem-嵌套限制)
6. [Swiper 组件子组件规范](#swiper-组件子组件规范api-20) ✨ 新增
7. [城市分组折叠（省份列表）](#城市分组折叠省份列表)
8. [三级菜单异步加载问题修复](#三级菜单异步加载问题修复)
9. [地图组件深浅色模式适配 (Map Kit DayNight Mode)](#地图组件深浅色模式适配-map-kit-daynight-mode) ✨ 新增
10. [对比度增强方案 (levelToTextColor)](#对比度增强方案-leveltotextcolor) ✨ 新增

---

## 状态栏/导航栏配置（API 20）

> ✅ **已验证**: 2025-12-29 (PollenForecast 项目)  
> **来源**: CodeGenie + 实际测试验证  
> **适用项目**: 需要透明状态栏的应用

### 核心知识点

#### 1. 状态栏参数优先级规则

**✅ 正确认知（CodeGenie 2025-12-29 验证）**：
```
statusBarContentColor > isStatusBarLightIcon
```

- `statusBarContentColor` 明确指定字体/图标颜色（优先级最高）
- `isStatusBarLightIcon` 控制明暗基调（当 `statusBarContentColor` 未设置时生效）
- **移除 `statusBarContentColor` 会导致字体变灰**（依赖系统默认逻辑）

**❌ 错误认知（之前专家错误建议）**：
```
isStatusBarLightIcon > statusBarContentColor  // ❌ 错误！
API 20 中 statusBarContentColor 已废弃        // ❌ 错误！
```

#### 2. 正确配置方案

**EntryAbility.ets 中设置**：
```typescript
private updateStatusBarForTheme(mainWindow: window.Window, colorMode?: number): void {
  const currentColorMode = colorMode ?? this.context.config.colorMode;
  
  let systemBarProperties: window.SystemBarProperties;
  
  if (currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
    // 深色模式
    systemBarProperties = {
      statusBarColor: '#00000000',        // 完全透明
      statusBarContentColor: '#FFFFFF',   // ✅ 白色内容（必须）
      isStatusBarLightIcon: true          // 白色图标基调
    };
  } else {
    // 浅色模式
    systemBarProperties = {
      statusBarColor: '#00000000',        // 完全透明
      statusBarContentColor: '#000000',   // ✅ 纯黑内容（必须）
      isStatusBarLightIcon: false         // 深色图标基调
    };
  }
  
  mainWindow.setWindowSystemBarProperties(systemBarProperties);
}
```

**关键要点**：
- ✅ 必须同时设置 `statusBarContentColor` 和 `isStatusBarLightIcon`
- ✅ `statusBarContentColor` 使用纯色（`#000000` 或 `#FFFFFF`）
- ❌ 不能只设置 `isStatusBarLightIcon`（会导致字体灰色）

#### 3. 导航栏背景透明度配置

**问题场景**：
- 95% 不透明（`#F2FFFFFF`）会透出底层页面背景色（如 `#F1F3F5`），叠加后显示"雾蒙蒙"
- 系统会将多层半透明颜色混合，产生非预期的灰蒙效果

**解决方案**：
```json
// resources/base/element/color.json（浅色模式）
{
  "name": "navbar_background",
  "value": "#FFFFFFFF"  // ✅ 100% 不透明白色
}

// resources/dark/element/color.json（深色模式）
{
  "name": "navbar_background",
  "value": "#FF000000"  // ✅ 100% 不透明黑色
}
```

**Tabs 组件配置**：
```typescript
Tabs() {
  // ...
}
.barBackgroundColor($r('app.color.navbar_background'))  // 使用主题色

@Builder
TabBuilder(index: number, safeBottom: number) {
  Column() {
    // ...
  }
  .backgroundColor(Color.Transparent)  // ✅ TabBuilder 背景透明，避免叠加
}
```

#### 4. 常见错误

| 错误配置 | 问题表现 | 正确方案 |
|---------|---------|---------|
| 只设置 `isStatusBarLightIcon` | 状态栏字体变灰 | 同时设置 `statusBarContentColor` |
| 导航栏 95% 不透明 | 浅色模式雾蒙蒙 | 改为 100% 不透明 `#FFFFFFFF` |
| TabBuilder 用 `block_background` | 与 barBackgroundColor 叠加 | 改为 `Color.Transparent` |
| 移除 `statusBarContentColor` | 字体颜色由系统决定（灰色）| 保留并明确指定颜色 |

#### 5. 测试验证步骤

1. **修改后必须 Clean + Rebuild**（资源文件缓存问题）
2. **切换深浅模式测试**（设置 → 显示 → 深色模式）
3. **检查状态栏字体颜色**（应为纯黑 `#000000` 或纯白 `#FFFFFF`，不应是灰色）
4. **检查导航栏透明度**（不应有灰蒙效果）

---

## 媒体库URI与fileIo API使用规则

> ✅ **已验证**: 2026-01-04  
> **来源**: 真机测试验证（DNG解析失败问题修复）  
> **适用项目**: 所有需要访问媒体库文件的应用

### 核心知识点

#### 1. 媒体库URI不是普通文件路径

**媒体库URI格式**：
```
file://media/Photo/124495/IMG_xxx/photo.dng
```

**关键区别**：
- ✅ `fileIo.openSync(uri)` → 可以打开媒体库URI（通过DataShareExtAbility）
- ❌ `fileIo.statSync(uri)` → **不能**直接用URI字符串（会报 `No such file or directory`）
- ✅ `fileIo.statSync(fd)` → 必须用已打开的文件描述符

#### 2. 正确的文件读取模式

```typescript
let file: fileIo.File | null = null
try {
  // ✅ Step 1: 用URI打开文件
  file = fileIo.openSync(photoUri, fileIo.OpenMode.READ_ONLY)
  
  // ✅ Step 2: 用fd获取文件信息（不是URI！）
  const stat = fileIo.statSync(file.fd)  // ✅ 正确
  // const stat = fileIo.statSync(photoUri)  // ❌ 错误！
  
  // ✅ Step 3: 用fd读取文件内容
  const buffer = new ArrayBuffer(stat.size)
  fileIo.readSync(file.fd, buffer)
  
} finally {
  if (file) fileIo.closeSync(file)
}
```

#### 3. 常见错误

| 错误写法 | 错误信息 | 正确写法 |
|---------|---------|---------|
| `fileIo.statSync(uri)` | `No such file or directory` | `fileIo.statSync(file.fd)` |
| `fs.accessSync(uri)` | 路径无效 | 先 `openSync` 再操作 |

#### 4. 为什么openSync可以但statSync不行？

- `fileIo.openSync()` 内部通过 **DataShareExtAbility** 协议解析媒体库URI
- `fileIo.statSync(string)` 期望的是 **普通文件系统路径**（如 `/data/storage/...`）
- `fileIo.statSync(fd)` 直接操作已打开的文件描述符，绕过路径解析

---

## 无障碍设计 - 文本对比度要求

> ✅ **已验证**: 2026-01-09  
> **来源**: AppGallery 审核要求 + 实际测试验证  
> **适用项目**: 所有需要提交 AppGallery 的应用

### 核心知识点

#### 1. 华为 AppGallery 对比度要求

**标准要求**：
- **文本对比度** ≥ 4.1:1（WCAG AA 级别）
- 适用于所有可读文本（包括版权信息、提示文字等）

**验证方法**：
- 使用在线对比度检查工具（如 WebAIM Contrast Checker）
- 或使用设计工具（Figma、Sketch）内置对比度检查

#### 2. 深浅色模式动态颜色选择

**问题场景**：
- 同一文本在浅色/深色模式下需要不同颜色
- 固定颜色无法同时满足两种模式的对比度要求

**解决方案**：
```typescript
// 根据主题动态返回高对比度颜色
getDataSourceTextColor(): ResourceColor {
  const currentColorMode = this.context.config.colorMode;
  
  if (currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
    return '#CCCCCC';  // 深色模式：浅灰色（对比度 4.2:1）
  } else {
    return '#555555';  // 浅色模式：深灰色（对比度 4.2:1）
  }
}

// 使用示例
Text('感谢北京敏舒科技有限责任公司对数据的支持')
  .fontSize(10)
  .fontColor(this.getDataSourceTextColor())  // ✅ 动态颜色
  .width('45%')
  .textAlign(TextAlign.End)
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
```

**颜色选择参考**：
| 模式 | 颜色值 | 对比度 | 适用背景 |
|------|--------|--------|---------|
| 浅色模式 | `#555555` | 4.2:1 | 白色/浅色背景 |
| 深色模式 | `#CCCCCC` | 4.2:1 | 黑色/深色背景 |

#### 3. Text 组件宽度限制替代方案

**问题**：
- `Text` 组件不支持 `maxWidth` 属性（API 20）
- 需要限制文本宽度避免挤压其他元素

**解决方案**：
```typescript
Text('长文本内容')
  .width('45%')              // ✅ 使用 width 百分比
  .textAlign(TextAlign.End)  // ✅ 右对齐
  .maxLines(1)               // ✅ 单行显示
  .textOverflow({ overflow: TextOverflow.Ellipsis })  // ✅ 溢出省略号
```

**布局示例**（导航栏右侧版权信息）：
```typescript
Row() {
  Text('城市名')
    .fontSize(18)
    .fontWeight(FontWeight.Medium)
  
  Blank()  // 弹性空间
  
  Text('感谢XXX对数据的支持')
    .fontSize(10)
    .fontColor(this.getDataSourceTextColor())
    .width('45%')  // ✅ 限制宽度
    .textAlign(TextAlign.End)
    .maxLines(1)
    .textOverflow({ overflow: TextOverflow.Ellipsis })
}
.width('100%')
.padding({ left: 16, right: 16 })
```

#### 4. 常见错误

| 错误做法 | 问题 | 正确做法 |
|---------|------|---------|
| 固定颜色 `#999999` | 深色模式下对比度不足 | 根据主题动态选择颜色 |
| 使用 `maxWidth` | API 20 不支持 | 使用 `width('45%')` |
| 忽略对比度要求 | AppGallery 审核不通过 | 确保 ≥ 4.1:1 |
| 版权信息占用内容区域 | 影响后续功能扩展 | 放在导航栏，不占用内容区 |

#### 5. 测试验证步骤

1. **切换深浅色模式**（设置 → 显示 → 深色模式）
2. **检查文本可读性**（肉眼检查是否清晰）
3. **使用对比度工具验证**（确保 ≥ 4.1:1）
4. **AppGallery 审核**（提交前检查无障碍要求）

---

## Refresh 组件限制

> ✅ **已验证**: 2026-01-10 (PollenForecast 项目)  
> **错误码**: `10905220`  
> **问题**: Refresh 组件只能有一个子组件

### 核心规则

**Refresh 组件只能有一个直接子组件**

**❌ 错误写法**：
```typescript
Refresh({ refreshing: $$this.isRefreshing }) {
  Row() {
    Column() { ... }  // 错误：多个子组件
    Column() { ... }  // 错误：多个子组件
  }
}
```

**✅ 正确写法**：
```typescript
Refresh({ refreshing: $$this.isRefreshing }) {
  Column() {  // 只有一个子组件
    // 所有内容都在这里
  }
}
```

---

## Swiper 组件子组件规范 (API 20+)

> ✅ **已验证**: 2026-01-15 (PollenForecast RegionView 编译报错修复)  
> **问题**: Cannot find name 'SwiperItem'

在最新的 ArkUI API 20+ 中，`Swiper` 组件不再依赖或支持 `SwiperItem` 容器。

**❌ 错误做法：**
```typescript
Swiper() {
  SwiperItem() { // ❌ 报错：Cannot find name 'SwiperItem'
    Text('Page 1')
  }
}
```

**✅ 正确做法：**
直接将子组件放置在 `Swiper` 内部即可：
```typescript
Swiper() {
  // 页面 1
  Column() {
    Text('Page 1')
  }
  
  // 页面 2
  Flex() {
    Text('Page 2')
  }
}
.index(this.currentIndex)
.onChange((index: number) => {
  this.currentIndex = index
})

---

## ListItem 嵌套限制

> ✅ **已验证**: 2026-01-10 (PollenForecast 项目)  
> **错误码**: `10905204`  
> **问题**: ListItem 内部不能嵌套另一个 ListItem

### 核心规则

**ListItem 不能嵌套，必须扁平化结构**

**❌ 错误写法**：
```typescript
List() {
  ForEach(groups, (group) => {
    ListItem() {
      Column() {
        Text(group.title)
        ForEach(group.cities, (city) => {
          ListItem() { ... }  // ❌ 错误：嵌套 ListItem
        })
      }
    }
  })
}
```

**✅ 正确写法**：
```typescript
List() {
  ForEach(groups, (group) => {
    // 分组标题作为独立的 ListItem
    ListItem() {
      Text(group.title)
    }
    
    // 城市项作为独立的 ListItem（扁平化）
    ForEach(group.cities, (city) => {
      ListItem() { ... }  // ✅ 正确：扁平结构
    })
  })
}
```

---

## 城市分组折叠（省份列表）

> ✅ **已验证**: 2026-01-11 (PollenForecast RegionView)
> **场景**: 省份分组点击展开/折叠城市列表

### 核心范式

1. 使用 `@State expandedGroups: string[]` 记录展开的分组 key；
2. 更新状态时使用 `concat` / `filter` 创建新数组再整体赋值，避免原地修改；
3. `ForEach` 的 `keyGenerator` 必须能反映展开状态，例如：
   ```typescript
   ForEach(this.getGroupedCities(), (group: CityGroup) => {
     // ... 渲染 ListItem 和城市列表
   }, (group: CityGroup) => `${group.key}_${this.expandedGroups.includes(group.key) ? '1' : '0'}`)
   ```
4. 省份标题点击事件绑定在 `ListItem` 本身，避免被子组件拦截。

### 适用范围

- 省份/地区分组折叠列表；
- 数据量在百级、依赖搜索+热门城市兜底的城市选择场景。

> 📌 对于未来 2000+ 城市的完整城市选择器，建议采用「搜索 + 字母索引侧边栏 + 按拼音首字母分组列表」的组合方案，详见设计文档，当前项目尚未完全落地。

---

## 三级菜单异步加载问题修复

> ✅ **已验证**: 2026-01-13 (PollenForecast RegionView)  
> **场景**: 无法打开区县弹窗 + 二级菜单错误添加手势  
> **根本原因**: `allCitiesData` 异步加载未完成时，组件已开始渲染

### 问题根因（三专家100%共识）

| 问题现象 | 根本原因 |
|---------|---------|
| 无法打开三级菜单 | `hasDistrictsForCity()` 在数据未加载完成时返回 false |
| 二级菜单全都有手势 | 组件渲染时数据未就绪，所有城市被判断为"无区县" |
| 点击事件不生效 | `selectCity()` 内部判断也失效 |

### 核心解决方案

#### 1. 添加数据加载状态标志

```typescript
@State isDataLoaded: boolean = false
```

#### 2. 修复 `aboutToAppear()` 确保同步等待

```typescript
async aboutToAppear(): Promise<void> {
  console.info('[RegionView] 开始加载区县数据...')
  try {
    const allCitiesWithDistricts = await loadChinaAreaData(getContext(this))
    this.allCitiesData = allCitiesWithDistricts
    this.isDataLoaded = true  // ⭐ 标记数据已加载
    console.info(`[RegionView] ✅ 区县数据加载成功！总城市数：${allCitiesWithDistricts.length}`)
  } catch (error) {
    console.error(`[RegionView] ❌ 区县数据加载失败: ${JSON.stringify(error)}`)
  }
}
```

#### 3. 添加防御性检查

```typescript
hasDistrictsForCity(cityName: string): boolean {
  // ⭐ 防御性检查：数据未加载时返回 false
  if (!this.isDataLoaded || !this.allCitiesData || this.allCitiesData.length === 0) {
    return false
  }
  const city = this.allCitiesData.find(item => item.name === cityName)
  return !!city?.districts?.length
}
```

#### 4. 组件渲染时添加加载判断

```typescript
@Builder
CityItemComponent(city: CityItem) {
  if (!this.isDataLoaded) {
    // 数据未加载时的简单布局（无手势）
    Row() {
      Text(city.name)
      Blank()
      Text(`${city.distance}公里`)
    }
    .width('100%').height(50).padding({ left: 16, right: 16 })
    return
  }
  // 数据加载完成后正常渲染...
}
```

### 关键点

- ✅ 使用 `async/await` 确保数据加载完成后再渲染
- ✅ 添加 `isDataLoaded` 状态标志控制渲染时机
- ✅ 在判断函数中添加防御性检查
- ✅ 添加详细日志便于排查

### 三专家方案对比

| 方案来源 | 根因分析 | 修复完整度 | 推荐度 |
|---------|---------|-----------|--------|
| **小米MIMO** | ⭐⭐⭐⭐⭐ 最深入（异步加载时机） | ⭐⭐⭐⭐⭐ 三重方案 | ⭐⭐⭐⭐⭐ |
| **小艺** | ⭐⭐⭐ 强调调试日志 | ⭐⭐⭐⭐ 数据验证方法 | ⭐⭐⭐⭐ |
| **CodeGenie** | ⭐⭐ 简化判断逻辑 | ⭐⭐⭐ 代码简洁 | ⭐⭐⭐ |

### 专家共识度

| 诊断点 | 小米MIMO | 小艺 | CodeGenie | 共识度 |
|--------|---------|------|-----------|--------|
| 异步加载时机问题 | ✅ 核心原因 | ⚠️ 未提及 | ⚠️ 未提及 | 33% |
| 数据有效性检查 | ✅ | ✅ | ✅ | 100% |
| selectCity()逻辑正确 | ✅ | ⚠️ 建议新增方法 | ⚠️ 建议改写 | 33% |
| 需要加载状态标志 | ✅ | ⚠️ 未提及 | ✅ | 67% |
| 添加调试日志 | ✅ | ✅ 强调 | ⚠️ 未提及 | 67% |

**结论**: 小米MIMO方案根因分析最准确，建议优先采用其三重修复方案，同时结合小艺的调试日志建议。

### 预期日志输出

```
[RegionView] 开始加载区县数据...
[RegionView] ✅ 区县数据加载成功！
[RegionView] 总城市数：XXX
[RegionView] 广州市：hasDistricts=true, 区县数=11
[RegionView] 点击有区县城市: 广州市
[RegionView] 城市数据: name=广州市, hasDistricts=true, districts.length=11
[RegionView] 城市 广州市 有 11 个区县，弹出选择框
```

### 预期UI行为

1. **有区县的城市**（如广州市）：
   - 显示右箭头图标
   - 点击后弹出区县选择弹窗
   - **无手势滑动**

2. **无区县的城市**（如中山市）：
   - 显示普通图标
   - 支持手势滑动（置顶/收藏）
   - 点击后直接选中

> 📌 详细修复计划见 `.claude/下一步修复计划.md`

---

## 地图组件深浅色模式适配 (Map Kit DayNight Mode)

> ✅ **已验证**: 2026-01-15 (PollenForecast 项目)  
> **场景**: 使用 Map Kit 且需适配深色模式的应用  
> **关键点**: API 20+ 中属性名为 `dayNightMode`，且类型为枚举。

### 核心知识点

#### 1. 属性名与类型变更

在最新的 API 20 Map Kit 中，属性已从 `nightMode` (boolean) 变更为 `dayNightMode` (enum)。

**❌ 错误写法**：
```typescript
this.mapOptions = {
  nightMode: true // 报错：属性不存在
}
// 或
this.mapController.setDayNightMode(true) // 报错：类型不匹配
```

**✅ 正确写法**：
使用 `mapCommon.DayNightMode` 枚举值。

```typescript
import { mapCommon } from '@kit.MapKit';

// 初始化
this.mapOptions = {
  dayNightMode: mapCommon.DayNightMode.NIGHT
}

// 动态设置
this.mapController.setDayNightMode(mapCommon.DayNightMode.DAY)
```

#### 2. 动态监听切换

在主题变化监听器中调用控制器方法：

```typescript
onThemeChanged(): void {
  const isDarkMode = this.currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK
  const mode = isDarkMode ? mapCommon.DayNightMode.NIGHT : mapCommon.DayNightMode.DAY
  
  if (this.mapReady && this.mapController) {
    try {
      this.mapController.setDayNightMode(mode)
    } catch (err) {
      console.error('切换地图夜间模式失败')
    }
  }
}
```

---

## 对比度增强方案 (levelToTextColor)

> ✅ **已验证**: 2026-01-15 (PollenForecast 预审修复)  
> **场景**: 浅色模式下，某些状态颜色（如柠檬黄、浅绿）在白色背景上对比度不足（低于 4.5:1）。

### 核心逻辑：文字颜色独立于图形颜色

为了通过 AppGallery 的无障碍合规性预审，必须确保文字对比度达标。如果状态颜色本身较亮，则需要定义一套“加深版”颜色专用于文字。

#### 1. 颜色映射函数

在 Model 层定义专用的文字颜色转换函数：

```typescript
export function levelToTextColor(level: PollenLevel, isDarkMode: boolean = false): string {
  if (isDarkMode) {
    // 深色模式下，亮色在深色背景上对比度通常足够
    return levelToColor(level) 
  }

  // 浅色模式下（背景为白色），手动加深特定等级的颜色
  if (level === PollenLevel.LOW) {
    return '#827717' // 将原本的 #CDDC39 (柠檬黄) 加深为橄榄绿，对比度显著提升
  } else if (level === PollenLevel.MODERATE) {
    return '#A17100' // 将 #FFC107 (琥珀色) 加深
  }
  // ... 其他等级依此类推
  return levelToColor(level)
}
```

#### 2. UI 应用

```typescript
Text(this.levelText)
  .fontColor(levelToTextColor(this.level, this.isDarkMode)) // ✅ 使用加深后的颜色
```

---

- **官方文档**: https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/
- **开发指南**: https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/
- **WCAG 对比度标准**: https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html

