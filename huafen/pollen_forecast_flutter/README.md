# 花粉浓度播报 - Flutter 版本

> 跨平台版本（iOS + Android），复用鸿蒙项目的服务器 API 和业务逻辑

## 📋 项目状态

✅ **已完成**：
- Flutter 项目创建和基础配置
- 依赖包安装（dio、provider、geolocator 等）
- API 配置（复用鸿蒙项目的服务器端点）
- 数据模型定义（PollenForecastResponse、PollenDay 等）
- 基础服务类（PollenService 多服务器故障转移）

📋 **待开发**：
- UI 页面（首页、区域选择、地图、设置）
- GPS 定位集成
- 城市搜索和收藏功能
- 地图集成（Google Maps / 高德地图）

## 🚀 快速开始

### 1. 运行项目（Web 版，用于快速测试）

```bash
flutter run -d chrome
```

### 2. 运行 Android 版本（需要 Android Studio 和模拟器）

```bash
flutter run
```

### 3. 构建 iOS 版本（需要 Codemagic CI/CD 或 Mac）

```bash
flutter build ios
```

## 📁 项目结构

```
lib/
├── config/          # API 配置
│   └── api_config.dart
├── models/          # 数据模型
│   └── pollen_models.dart
├── services/        # 服务层
│   └── pollen_service.dart
├── screens/         # 页面
│   └── home_screen.dart
├── widgets/         # 组件（待开发）
├── utils/           # 工具类（待开发）
└── main.dart        # 入口文件
```

## 🔗 API 配置

项目已配置以下 API 端点（复用鸿蒙项目）：

- **花粉数据**：AWS Lambda 东京/新加坡 + 阿里云（多服务器故障转移）
- **天气数据**：百度云广州服务器（和风天气 + Minshu 花粉 API）

详见 `lib/config/api_config.dart`

## 📱 下一步开发计划

1. **首页 UI** - 花粉指数圆环、7天预报列表
2. **定位服务** - 集成 geolocator，获取当前位置
3. **区域选择页** - 城市搜索、收藏功能
4. **地图页** - 集成地图 SDK
5. **设置页** - 主题切换、数据源选择

## 🛠 技术栈

- **Flutter**: 3.38.7
- **Dart**: 3.10.7
- **状态管理**: Provider
- **网络请求**: Dio
- **定位**: Geolocator
- **存储**: SharedPreferences

## 📝 注意事项

- iOS 构建需要在 macOS 环境或使用 Codemagic 等 CI/CD 服务
- Android 开发需要安装 Android Studio 和 Android SDK
- Web 版本可以用于快速开发和测试
