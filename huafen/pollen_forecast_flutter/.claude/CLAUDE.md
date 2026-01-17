# 花粉浓度播报 - Flutter 跨平台版 (pollen_forecast_flutter)

> **作用范围**: Flutter 跨平台项目专属文档
> **最后更新**: 2026-01-17 (GPS定位集成完成 + Web版模拟数据 + 编译错误修复)
> **AI 维护者**: Claude + GLM-4.7

---

## ⚠️ AI 必读规则

**文档整理提醒**：读取本文档时，如果发现行数 > 400行，询问用户是否需要整理。

### 🚨 与鸿蒙项目的关系

本项目是 **花粉浓度播报** 的 Flutter 跨平台版本，用于覆盖 iOS 和 Android 用户。

| 项目 | 路径 | 平台 |
|------|------|------|
| 鸿蒙原生 | `C:\HarmonyOS_App_Plans\huafen\PollenForecast\` | HarmonyOS |
| Flutter 跨平台 | `C:\HarmonyOS_App_Plans\huafen\pollen_forecast_flutter\` | iOS + Android |

**共享资源**：两个项目共享相同的后端 API、数据模型设计和 UI 设计规范。

---

## 🚨 当前状态概要

### ⚠️ 当前状态(2026-01-17 更新)

**GPS 定位集成完成** ✅ (2026-01-17 Claude)
- ✅ LocationService 类（GPS 权限检查、获取位置、城市名转换）
- ✅ 首页集成定位功能（initLocation 方法）
- ✅ iOS 权限已配置（Info.plist）
- ✅ 定位失败降级机制（自动使用广州默认坐标）
- ⚠️ Web 版暂时禁用 GPS（等待 iOS 真机测试）
- ⚠️ Web 版使用模拟数据（绕过 CORS 限制）

**花粉地图可视化页面开发完成** ✅
- ✅ 省份分组列表（ExpansionTile 折叠/展开）
- ✅ 色块展示花粉浓度（绿→黄→橙→红→紫）
- ✅ 排序功能（从低到高/从高到低）
- ✅ 城市详情 BottomSheet
- ✅ 临时数据生成（随机花粉指数0-150）
- ✅ 平均值计算（省份平均色块）
- ✅ 默认展开前3个省份

**城市搜索页面开发完成** ✅
- ✅ 搜索框 - 支持中文、拼音、拼音首字母搜索
- ✅ 热门城市列表 - 7个常用城市（北京、上海、广州等）
- ✅ 我的收藏 - 显示用户收藏的城市（最多4个）
- ✅ 搜索结果列表 - 实时过滤（支持3244个区域）
- ✅ 点击城市 - 返回首页并传递城市名称、坐标、adcode
- ✅ 数据模型 - CityItem、DistrictItem、PinyinMapItem
- ✅ 工具类 - loadPinyinMap、loadChinaAreaData、searchCities
- ✅ 单元测试 - 测试搜索、收藏、拼音功能

**数据文件配置完成** ✅
- ✅ assets/data/china_area_full.json - 全国3244个区域数据
- ✅ assets/data/pinyin_map.json - 拼音映射表
- ✅ pubspec.yaml - 已添加数据文件到 assets

**iOS 配置完成** ✅
- Bundle Identifier: `com.eric.PollenForecast`（与鸿蒙版一致）
- 最低支持版本: iOS 12.0+
- 开发环境: Windows + Codemagic CI/CD

**首页 UI 开发完成** ✅
- 花粉指数圆环组件（CustomPainter 绘制）
- 7天预报横向滚动图表
- 防护指南智能切换（根据等级）
- 下拉刷新功能
- 加载状态和错误处理

**设置页面开发完成** ✅ (2026-01-17 GLM-4.7)
- 关于应用对话框（版本信息、应用说明）
- 隐私政策对话框（信息收集、使用、保护说明）
- 用户协议对话框（服务说明、用户责任、免责声明）
- 主题切换功能（深色/浅色模式）
- 版本信息显示（版本号 + 构建号）

**深色模式适配完成** ✅ (2026-01-17 GLM-4.7)
- ThemeService 主题管理服务（浅色/深色主题）
- 设置页面深色模式适配
- 首页深色模式适配
- 城市搜索页面深色模式适配
- 花粉地图页面深色模式适配
- 花粉色块深色模式可读性优化（使用白色文字）
- 主题持久化存储（SharedPreferences）
- 新增依赖：package_info_plus ^5.0.1

**项目基础搭建完成** ✅
- Flutter SDK 安装与验证（Windows 环境）
- 项目创建与依赖配置
- API 配置复用（花粉数据服务器、天气数据服务器）
- 数据模型定义（与鸿蒙项目一致）
- 基础服务类（多服务器故障转移）

**编译错误修复完成** ✅ (2026-01-17 Claude)
- ✅ 修复 pollen_map_screen.dart 编译错误（import、类型问题）
- ✅ 修复 city_utils.dart forEach 参数顺序
- ✅ 删除 city_search_screen.dart 重复类定义
- ✅ 修复 pubspec.yaml 重复配置

 ### 📋 待完成功能

| 优先级 | 功能 | 负责人 | 状态 |
|--------|------|--------|------|
| P0 | iOS 真机测试（GPS + API） | Claude | 📋 待执行 |
| P2 | 花粉地图高级版（详见备选方案） | Claude | 📄 规划中 |
| P2 | 多语言支持 | Claude | 📋 待开发 |

---

## 🗺️ 花粉地图可视化方案

### 核必需求

地图功能的核心是 **数据可视化**，而非定位工具：
- ✅ 按省/市/区分块展示花粉数据
- ✅ 每个区域标注对应的花粉浓度
- ✅ 根据浓度用颜色区分（绿→黄→橙→红→紫）
- ✅ 类似“疫情地图”、“天气雷达图”的展示方式

### 📋 备选方案（已记录）

#### 方案 A：静态地图 + CustomPainter ⭐⭐⭐⭐⭐

**实现思路**：
- 使用中国地图底图（PNG/SVG）
- 用 CustomPainter 在各省/市区域绘制颜色块
- 根据花粉浓度显示不同颜色
- 支持点击省份查看详情

**优势**：
- ✅ 最简单，纯 Flutter 实现，无需第三方 SDK
- ✅ 不依赖网络地图服务
- ✅ 性能好，加载快
- ✅ 完全可控

**劇勣**：
- ⚠️ 需要地图 SVG 数据和省份边界坐标
- ⚠️ 缩放、拖拽需要自己实现

**参考资源**：
- [china_region_map](https://pub.dev/packages/china_region_map) - Flutter 中国地图组件

---

#### 方案 B：Echarts Flutter ⭐⭐⭐⭐

**实现思路**：
- 使用 flutter_echarts 插件
- 加载中国地图 GeoJSON 数据
- 用 Echarts 的地图可视化能力渲染
- 支持省市区下钻

**优势**：
- ✅ 专业的数据可视化库
- ✅ 支持交互（点击、缩放、下钻）
- ✅ 官方提供中国地图 GeoJSON
- ✅ 与 Web 版本一致

**劇勣**：
- ⚠️ 依赖 WebView
- ⚠️ 性能略低于纯 Flutter

**依赖**：
```yaml
dependencies:
  flutter_echarts: ^3.0.0
```

---

#### 方案 C：高德地图 + 自定义覆盖物 ⭐⭐⭐

**实现思路**：
- 使用高德地图作为底图
- 在地图上绘制省/市区域多边形（Polygon）
- 根据花粉浓度填充颜色

**优势**：
- ✅ 地图交互体验好
- ✅ 支持缩放、拖拽

**劇勣**：
- ⚠️ 需要省市区边界坐标（GeoJSON）
- ⚠️ 配置复杂
- ⚠️ 依赖第三方服务

**依赖**：
```yaml
dependencies:
  amap_flutter_map: ^3.0.0  # 高德地图
```

---

### 🚀 当前实施方案：列表 + 色块（MVP 简易版）

**为什么先用这个？**
- ✅ 5分钟内可实现
- ✅ 数据清晰直观
- ✅ 支持搜索和排序
- ✅ 先保证核心功能上线

**实现方式**：
```dart
// 伪代码示例
ListView.builder(
  itemBuilder: (context, index) {
    final city = cities[index];
    final pollenLevel = getPollenLevel(city);
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: levelToColor(pollenLevel),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            city.index.toString(),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      title: Text(city.name),
      subtitle: Text('花粉指数: ${city.index}'),
    );
  },
)
```

**升级路径**：
- V1.0: 列表 + 色块（当前版本）
- V1.1: CustomPainter 静态地图（方案 A）
- V2.0: Echarts 互动地图（方案 B）

---

## 👥 开发者职责对照表

| 模块 / 功能 | 主要内容 | 开发者 |
|------------|----------|--------|
| Flutter 项目基础搭建 | 工程创建、依赖配置、目录结构规划 | Claude |
| API 配置与服务层 | `api_config.dart`、`pollen_service.dart`、多服务器故障转移、`test_api.dart` 联调脚本 | Claude |
| GPS 定位功能 | `location_service.dart`、首页集成、iOS 权限配置 | Claude |
| 数据文件配置 | 复制 `china_area_full.json`、`pinyin_map.json`，配置 `pubspec.yaml` 的 assets | Claude |
| iOS 配置 | Info.plist 权限与文案、Bundle ID、iOS 版本配置（与 GLM-4.7 协同） | Claude / GLM-4.7 |
| 首页 UI | 花粉指数圆环、7天预报、防护建议、刷新与状态处理 | Claude |
| 城市搜索页面 | `city_search_screen.dart`、`city_models.dart`、`city_utils.dart` 与相关测试 | GLM-4.7 |
| 花粉地图可视化（简易版） | `pollen_map_screen.dart` 列表+色块、省份分组、排序、BottomSheet | GLM-4.7 |
| 设置页面 | `settings_screen.dart`、主题切换、对话框、版本信息 | GLM-4.7 |
| 深色模式适配 | `theme_service.dart`、全页面深色主题支持、主题持久化 | GLM-4.7 |
| 编译错误修复 | 修复 GLM-4.7 代码的编译问题（import、类型、参数顺序） | Claude |

---

## 🎯 项目概述

| 属性 | 值 |
|------|-----|
| **应用ID** | com.eric.PollenForecast |
| **中文名** | 花粉浓度播报 |
| **版本** | 1.1.0+1 |
| **Flutter SDK** | 3.38.7 |
| **Dart SDK** | 3.10.7 |
| **最低 iOS** | 12.0 |
| **最低 Android** | API 21 (Android 5.0) |
| **状态** | 🔄 基础框架已完成，开发中 |

### 目标平台
- 📱 **iOS**: App Store 发布（通过 Codemagic CI/CD 构建）
- 🤖 **Android**: Google Play 发布

---

## 📂 项目结构

 ```
pollen_forecast_flutter/
 ├── .claude/                    # AI 协作文档
 │   └── CLAUDE.md              # 本文件
 ├── lib/                        # Dart 源码
 │   ├── main.dart              # 入口文件
 │   ├── config/
 │   │   └── api_config.dart    # API 配置（复用鸿蒙项目）
 │   ├── models/
 │   │   ├── pollen_models.dart  # 花粉数据模型
 │   │   └── city_models.dart   # 城市数据模型 ✨ 新增
 │   ├── screens/
 │   │   ├── home_screen.dart   # 首页
 │   │   ├── city_search_screen.dart  # 城市搜索页面 ✨ 新增
 │   │   └── pollen_map_screen.dart  # 花粉地图页面 ✨ 新增
 │   ├── services/
│   │   └── pollen_service.dart # 花粉数据服务
│   │   └── theme_service.dart   # 主题管理服务 ✨ 新增
│   ├── utils/
 │   │   └── city_utils.dart   # 城市工具类（拼音搜索）✨ 新增
 │   ├── widgets/               # 可复用组件（待开发）
 │   └── (空)
 ├── assets/                     # 静态资源
 │   ├── images/                # 图片资源
 │   └── data/
 │       ├── china_area_full.json  # 中国行政区划数据 ✨ 新增
 │       └── pinyin_map.json      # 拼音映射表 ✨ 新增
 ├── ios/                        # iOS 平台配置
 │   └── Runner.xcodeproj/
 │       └── project.pbxproj    # Xcode 项目配置
 ├── android/                    # Android 平台配置
 ├── test/                       # 单元测试
 │   └── city_search_screen_test.dart  # 搜索页面测试 ✨ 新增
 ├── pubspec.yaml               # 依赖配置
 └── README.md                  # 项目说明
```

---

## 🔧 技术栈

### 核心依赖

| 依赖 | 版本 | 用途 |
|------|------|------|
| flutter | SDK | 框架核心 |
| dio | ^5.4.0 | 网络请求 |
| provider | ^6.1.1 | 状态管理 |
| shared_preferences | ^2.2.0 | 本地存储 |
| geolocator | ^11.0.0 | GPS 定位 |
| package_info_plus | ^5.0.1 | 版本信息 |
| json_annotation | ^4.8.1 | JSON 序列化 |

### 开发依赖

| 依赖 | 版本 | 用途 |
|------|------|------|
| flutter_lints | ^6.0.0 | 代码检查 |
| build_runner | ^2.4.7 | 代码生成 |
| json_serializable | ^6.7.1 | JSON 代码生成 |

---

## 🌐 API 配置

### 花粉数据服务器（多服务器故障转移）

| 优先级 | 服务器 | URL |
|--------|--------|-----|
| 1 | AWS Lambda 东京 | `https://g7d8o7pf5b.execute-api.ap-northeast-1.amazonaws.com/default/pollen-api` |
| 2 | AWS Lambda 新加坡 | `https://8de0lncs7f.execute-api.ap-southeast-1.amazonaws.com/default/pollen-api-singapore` |
| 3 | 阿里云新加坡 | `http://47.84.1.164:5000/pollen-api` |

### 天气数据服务器

- **基础 URL**: `http://106.12.143.105:3000`
- **端点**:
  - `/weather/now` - 实时天气
  - `/weather/7d` - 7天预报
  - `/minshu/pollen/day` - Minshu 花粉数据

---

## 📈 开发进度

### 已完成 ✅

- [x] **花粉地图可视化页面开发** (2026-01-17)
  - ✅ 省份分组列表（ExpansionTile 折叠/展开）
  - ✅ 色块展示（40x40 圆角矩形）
  - ✅ 花粉等级颜色（绿→黄→橙→红→紫）
  - ✅ 排序功能（从低到高/从高到低）
  - ✅ 城市详情 BottomSheet
  - ✅ 省份平均值计算
  - ✅ 临时数据生成（Random 生成0-150）
  - **开发者**: GLM-4.7
  - **技术细节**：
    - 复用 `china_area_full.json` 和 `pinyin_map.json`
    - 使用 `ExpansionTile` 实现省份折叠
    - 色块颜色与 `PollenLevel.color` 对应
    - 排序支持实时切换
  - **相关文件**:
    - `lib/screens/pollen_map_screen.dart` - 花粉地图页面

- [x] **数据文件配置** (2026-01-17)
  - ✅ 复制 `china_area_full.json` 到 `assets/data/`
  - ✅ 复制 `pinyin_map.json` 到 `assets/data/`
  - ✅ 更新 `pubspec.yaml` 添加数据文件
  - ✅ 共享鸿蒙项目的3244个区域数据

- [x] **iOS 项目配置** (2026-01-17)
  - ✅ Bundle Identifier: `com.eric.PollenForecast`
  - ✅ 最低支持版本: iOS 12.0
  - ✅ Debug/Release/Profile 三个配置均已更新

- [x] **首页 UI 开发** (2026-01-17)
  - ✅ 花粉指数圆环组件（CustomPainter）
  - ✅ 7天预报横向滚动列表
  - ✅ 防护建议卡片
  - ✅ 下拉刷新（RefreshIndicator）
  - ✅ 加载/错误状态处理

- [x] **设置页面开发** (2026-01-17 GLM-4.7)
  - ✅ 设置页面框架（Scaffold + AppBar）
  - ✅ 外观设置分组（深色模式 Switch）
  - ✅ 关于分组（关于应用、隐私政策、用户协议）
  - ✅ 版本信息分组（版本号、构建号）
  - ✅ 对话框组件（关于、隐私政策、用户协议）
  - ✅ 主题持久化（SharedPreferences）
  - ✅ 版本信息获取（package_info_plus）
  - **开发者**: GLM-4.7
  - **相关文件**:
    - `lib/screens/settings_screen.dart` - 设置页面

- [x] **深色模式适配** (2026-01-17 GLM-4.7)
  - ✅ ThemeService 主题管理服务（单例模式）
  - ✅ lightTheme 浅色主题配置
  - ✅ darkTheme 深色主题配置
  - ✅ getPollenColor 花粉等级颜色（深色/浅色自适应）
  - ✅ main.dart 应用入口集成（ListenableBuilder）
  - ✅ 设置页面深色适配（卡片、文字、对话框）
  - ✅ 首页深色适配（圆环、列表、卡片）
  - ✅ 城市搜索页面深色适配（搜索框、列表、图标）
  - ✅ 花粉地图页面深色适配（省份卡片、城市列表、BottomSheet）
  - ✅ 色块可读性优化（白色文字 + 高对比度）
  - ✅ 主题切换实时生效
  - ✅ 主题持久化存储
  - **开发者**: GLM-4.7
  - **相关文件**:
    - `lib/services/theme_service.dart` - 主题管理服务
    - `lib/main.dart` - 应用入口（主题集成）
    - `lib/screens/settings_screen.dart` - 设置页面
    - `lib/screens/home_screen.dart` - 首页
    - `lib/screens/city_search_screen.dart` - 城市搜索
    - `lib/screens/pollen_map_screen.dart` - 花粉地图

- [x] **项目基础搭建** (2026-01-17)
  - ✅ Flutter 项目创建
  - ✅ 依赖配置（dio、provider、geolocator 等）
  - ✅ API 配置复用
  - ✅ 数据模型定义
  - ✅ 服务层实现（多服务器故障转移）

- [x] **GPS 定位功能集成** (2026-01-17 Claude)
  - ✅ 创建 `LocationService` 类
    - `checkPermission()` - 检查定位权限
    - `getCurrentLocation()` - 获取当前位置
    - `getCityNameFromCoordinates()` - 坐标转城市名（简化版）
  - ✅ 首页集成
    - `_initLocation()` - 初始化定位方法
    - 定位失败降级机制（使用广州默认坐标）
  - ✅ iOS 权限配置
    - `NSLocationWhenInUseUsageDescription`
    - `NSLocationAlwaysAndWhenInUseUsageDescription`
  - ⚠️ Web 版限制
    - GPS 代码暂时注释（等待 iOS 真机测试）
    - 使用模拟数据（绕过 CORS 限制）
  - **开发者**: Claude
  - **相关文件**:
    - `lib/services/location_service.dart` - GPS 服务类
    - `lib/screens/home_screen.dart` - 首页集成
    - `ios/Runner/Info.plist` - iOS 权限配置

- [x] **编译错误修复** (2026-01-17 Claude)
  - ✅ `pollen_map_screen.dart`
    - 修复 `import 'dart:math'` 为 `import 'dart:math' as math;`
    - 修复 `children: null` 为 `children: []`
    - 修复 `onTap: _onCityTap` 为 `onTap: () => _onCityTap(city)`
  - ✅ `city_utils.dart`
    - 修复 `forEach((cityList, province)` 为 `forEach((province, cityList)`
  - ✅ `city_search_screen.dart`
    - 删除重复的 `CitySearchResult` 类定义（使用 `city_models.dart` 中的）
  - ✅ `pubspec.yaml`
    - 删除重复的 assets 配置
  - ✅ `api_config.dart`
    - 调整服务器优先级（阿里云优先）
    - 增加超时时间到 30 秒
  - **开发者**: Claude
  - **相关文件**: 多个文件

### 进行中 🔄

- 暂无

### 待开发 📋

- [ ] **iOS 真机测试** (P0 最高优先级)
  - GPS 定位功能测试
  - 真实 API 调用测试
  - 主题切换测试
  - 城市搜索测试
  - 花粉地图测试
  - 设置页面测试
- [ ] **Codemagic CI/CD 配置** (P0)
  - GitHub 仓库配置
  - 构建流程配置
  - iOS 签名配置
- [ ] **花粉地图高级版** (P2)
  - 调研 `china_region_map` 插件
  - CustomPainter 实现方案
  - 地图 SVG/GeoJSON 数据准备
- [ ] **多语言支持** (P2)
  - 配置 Flutter Intl 插件
  - 提取中文字符串
  - 翻译为英文

---

## 🎨 UI 设计规范

### 花粉浓度等级（与鸿蒙项目一致）

| 等级 | 数值范围 | 颜色代码 | 标签 |
|------|----------|----------|------|
| 1级 | 0-30 | `0xFF4CAF50` | 低 |
| 2级 | 31-60 | `0xFFFFC107` | 中 |
| 3级 | 61-90 | `0xFFFF9800` | 高 |
| 4级 | 91-120 | `0xFFF44336` | 很高 |
| 5级 | >120 | `0xFF9C27B0` | 极高 |

### 主题色板

| 用途 | 颜色 |
|------|------|
| 主色调 | `#4CAF50` (健康绿) |
| 低风险 | `#E8F5E9` |
| 中风险 | `#FFF3E0` |
| 高风险 | `#FFEBEE` |
| 极高风险 | `#F44336` |

---

## 🚀 开发指南

### 本地运行

```bash
# 进入项目目录
cd C:\HarmonyOS_App_Plans\huafen\pollen_forecast_flutter

# 获取依赖
flutter pub get

# 运行 Web 版（快速测试）
flutter run -d chrome

# 运行 Android 模拟器
flutter run -d android

# 构建 APK
flutter build apk --release
```

### iOS 构建（Codemagic CI/CD）

由于 Windows 环境无法直接构建 iOS，使用 Codemagic 云构建：

1. 推送代码到 GitHub
2. 在 Codemagic 配置构建流程
3. 自动构建并签名 IPA
4. 下载或直接上传到 App Store Connect

### 代码生成

```bash
# 生成 JSON 序列化代码
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## ⚠️ 注意事项

### Windows 开发限制

- ❌ 无法直接运行 iOS 模拟器
- ❌ 无法直接构建 IPA
- ✅ 可以修改 iOS 配置文件（如 `project.pbxproj`）
- ✅ 可以通过 Web 版测试 UI

### Web 版开发限制 (2026-01-17 新增)

- ❌ GPS 定位功能不可用（浏览器权限限制）
- ❌ API 调用有 CORS 限制（国外服务器被增或超时）
- ✅ 使用模拟数据测试 UI 功能
- ✅ 可以测试城市搜索、花粉地图、设置页面
- ⚠️ 真实功能需要 iOS 真机测试

### API 兼容性

- 花粉 API 返回的数据格式与鸿蒙版一致
- 冬季（12月-2月）花粉数据可能为空或低值
- 建议使用广州坐标（23.12, 113.26）测试

---

## 🔗 相关资源

### 项目文档

- 鸿蒙项目文档: `../PollenForecast/.claude/CLAUDE.md`
- 知识库: `C:\HarmonyOS_App_Plans\.claude\知识库.md`

### 外部资源

- [Flutter 官方文档](https://flutter.dev/docs)
- [Dart 语言指南](https://dart.dev/guides)
- [Codemagic CI/CD](https://codemagic.io/)

---

**记住**: 与鸿蒙项目保持 API 和设计规范的一致性！
