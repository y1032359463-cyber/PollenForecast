/// 首页 - 花粉指数展示（添加城市搜索和地图入口）
import 'package:flutter/material.dart';
import '../services/pollen_service.dart';
import '../services/location_service.dart';
import '../models/pollen_models.dart';
import '../models/city_models.dart';
import '../screens/city_search_screen.dart';
import '../screens/pollen_map_screen.dart';
import '../screens/settings_screen.dart';
import 'dart:math' as math;

/// 首页
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PollenService _pollenService = PollenService();
  final LocationService _locationService = LocationService();
  PollenForecastResponse? _forecastData;
  bool _isLoading = false;
  String? _errorMessage;
  
  // 当前城市信息
  String _currentCity = '定位中...';
  double? _currentLat;
  double? _currentLng;
  
  // 是否使用 GPS 定位（用户手动选择城市后设为 false）
  bool _isUsingGps = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  /// 初始化定位
  Future<void> _initLocation() async {
    setState(() {
      _isLoading = true;
      _currentCity = '定位中...';
    });

    // TODO: Web 版暂时禁用 GPS，直接使用默认城市
    // iOS 真机测试时再启用
    try {
      // final position = await _locationService.getCurrentLocation();
      
      // if (position != null) {
      //   // GPS 定位成功
      //   final cityName = await _locationService.getCityNameFromCoordinates(
      //     position.latitude,
      //     position.longitude,
      //   );
        
      //   setState(() {
      //     _currentCity = cityName;
      //     _currentLat = position.latitude;
      //     _currentLng = position.longitude;
      //     _isUsingGps = true;
      //   });
        
      //   // 加载花粉数据
      //   await _loadPollenData(
      //     lat: position.latitude,
      //     lng: position.longitude,
      //   );
      // } else {
        // 定位失败，使用默认城市（广州）
        setState(() {
          _currentCity = '广州（默认）';
          _currentLat = 23.12;
          _currentLng = 113.26;
          _isUsingGps = false;
        });
        
        await _loadPollenData();
      // }
    } catch (e) {
      // 定位异常，使用默认城市
      setState(() {
        _currentCity = '广州（默认）';
        _currentLat = 23.12;
        _currentLng = 113.26;
        _isUsingGps = false;
      });
      
      await _loadPollenData();
    }
  }

  /// 加载花粉数据（支持可选坐标参数）
  Future<void> _loadPollenData({double? lat, double? lng}) async {
    // 使用传入的坐标，或使用 GPS / 默认坐标
    final useLat = lat ?? _currentLat ?? 23.12; // 默认广州
    final useLng = lng ?? _currentLng ?? 113.26;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: Web 版暂时使用模拟数据（API 有 CORS 限制）
    // iOS 真机上 API 调用正常
    try {
      // 模拟数据
      await Future.delayed(const Duration(seconds: 1)); // 模拟网络请求
      
      final mockData = PollenForecastResponse(
        indexInfo: null,
        location: '广州',
        dailyInfo: List.generate(7, (index) {
          return PollenDay(
            date: '2026-01-${(17 + index).toString().padLeft(2, '0')}',
            indexInfo: null, // 冬季数据为 null
            plantInfo: [],
          );
        }),
      );

      setState(() {
        _forecastData = mockData;
        _isLoading = false;
      });
      
      // 真实 API 调用（iOS 上使用）
      // final data = await _pollenService.getPollenForecast(
      //   lat: useLat,
      //   lng: useLng,
      //   days: 7,
      // );
      // setState(() {
      //   _forecastData = data;
      //   _isLoading = false;
      // });
    } catch (e) {
      setState(() {
        _errorMessage = '加载失败: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadPollenData,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载中...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadPollenData(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_forecastData == null) {
      return const Center(child: Text('暂无数据'));
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          _buildHeader(),
          _buildPollenIndexCard(),
          _buildForecastCard(),
          _buildProtectionGuide(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 顶部标题栏（添加搜索和地图入口）
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentCity,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _isUsingGps ? '基于GPS定位' : '已手动选择',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, size: 20),
                onPressed: () => _openCitySearch(),
                tooltip: '搜索城市',
              ),
              IconButton(
                icon: const Icon(Icons.map_outlined, size: 20),
                onPressed: () => _openPollenMap(),
                tooltip: '花粉地图',
              ),
              IconButton(
                icon: const Icon(Icons.settings, size: 20),
                onPressed: () => _openSettings(),
                tooltip: '设置',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 打开城市搜索页面
  Future<void> _openCitySearch() async {
    final result = await Navigator.push<CitySearchResult>(
      context,
      MaterialPageRoute(
        builder: (context) => const CitySearchScreen(),
      ),
    );

    // 处理返回结果
    if (result != null) {
      setState(() {
        _currentCity = result.name;
        _currentLat = result.location.lat;
        _currentLng = result.location.lng;
        _isUsingGps = false;
      });

      // 使用新坐标重新加载花粉数据
      await _loadPollenData(
        lat: result.location.lat,
        lng: result.location.lng,
      );
      
      _showToast('已切换到 ${result.name}');
    }
  }

  /// 打开花粉地图页面
  Future<void> _openPollenMap() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PollenMapScreen(),
      ),
    );
  }

  /// 打开设置页面
  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  /// 花粉指数圆环卡片
  Widget _buildPollenIndexCard() {
    final indexInfo = _forecastData?.indexInfo ?? 0;
    final level = PollenLevel.fromValue(indexInfo);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: _PollenRingPainter(
                  value: indexInfo,
                  level: level,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        indexInfo.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(level.color),
                        ),
                      ),
                      Text(
                        level.label,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(level.color),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getHealthSuggestion(level),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 7天预报卡片
  Widget _buildForecastCard() {
    final dailyInfo = _forecastData?.dailyInfo ?? [];
    if (dailyInfo.isEmpty) return const SizedBox();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '未来7天预报',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dailyInfo.length,
                itemBuilder: (context, index) {
                  final day = dailyInfo[index];
                  final level = PollenLevel.fromValue(day.indexInfo);
                  return _buildDayItem(day, level);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 单日预报项
  Widget _buildDayItem(PollenDay day, PollenLevel level) {
    final date = DateTime.tryParse(day.date) ?? DateTime.now();
    final weekday = _getWeekday(date.weekday);
    final dateStr = '${date.month}/${date.day}';

    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          Text(weekday, style: const TextStyle(fontSize: 12)),
          Text(dateStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            height: 60,
            width: 40,
            decoration: BoxDecoration(
              color: Color(level.color).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                (day.indexInfo ?? 0).toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(level.color),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 防护指南卡片
  Widget _buildProtectionGuide() {
    final indexInfo = _forecastData?.indexInfo ?? 0;
    final level = PollenLevel.fromValue(indexInfo);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '防护建议',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._getProtectionAdvice(level).map(
              (advice) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(advice)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekday(int weekday) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[weekday - 1];
  }

  String _getHealthSuggestion(PollenLevel level) {
    switch (level) {
      case PollenLevel.low:
        return '空气质量良好，适合户外活动';
      case PollenLevel.moderate:
        return '轻度过敏者请注意防护';
      case PollenLevel.high:
        return '建议佩戴口罩，减少户外活动';
      case PollenLevel.veryHigh:
        return '尽量避免户外活动，外出请做好防护';
      case PollenLevel.extreme:
        return '强烈建议留在室内，关闭门窗';
    }
  }

  List<String> _getProtectionAdvice(PollenLevel level) {
    if (level == PollenLevel.low) {
      return [
        '空气质量优良，可以正常进行户外活动',
        '保持室内通风',
        '适当进行体育锻炼',
      ];
    } else if (level == PollenLevel.moderate) {
      return [
        '轻度过敏者外出时佩戴口罩',
        '避免在花粉高峰时段外出',
        '回家后清洗面部和手部',
      ];
    } else {
      return [
        '尽量减少户外活动',
        '外出必须佩戴口罩和护目镜',
        '关闭门窗，使用空气净化器',
        '随身携带抗过敏药物',
      ];
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }
}

/// 花粉指数圆环绘制器
class _PollenRingPainter extends CustomPainter {
  final double value;
  final PollenLevel level;

  _PollenRingPainter({required this.value, required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    // 背景圆环
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius, bgPaint);

    // 进度圆环
    final progressPaint = Paint()
      ..color = Color(level.color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (value / 150) * 2 * math.pi; // 假设最大值150
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
