/// 花粉地图可视化页面（简易版：列表+色块）
/// 功能：省份分组、色块展示、排序功能
/// 参考：PollenForecast/entry/src/main/ets/views/RegionView.ets

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/pollen_models.dart';
import '../models/city_models.dart';
import '../utils/city_utils.dart';
import '../services/theme_service.dart';

/// 花粉地图页面
class PollenMapScreen extends StatefulWidget {
  const PollenMapScreen({super.key});

  @override
  State<PollenMapScreen> createState() => _PollenMapScreenState();
}

class _PollenMapScreenState extends State<PollenMapScreen> {
  // 所有城市数据
  List<CityItem> allCities = [];
  
  // 省份分组数据
  Map<String, List<CityItem>> provinceMap = {};
  
  // 排序方向：true=从低到高，false=从高到低
  bool isAscending = true;
  
  // 展开的省份列表
  List<String> expandedProvinces = [];
  
  // 是否正在加载数据
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  /// 初始化数据
  Future<void> _initData() async {
    // 加载拼音映射表
    await loadPinyinMap();
    
    // 加载城市数据
    allCities = await loadChinaAreaData();
    
    // 为每个城市生成临时花粉指数（随机数0-150）
    final random = math.Random();
    for (final city in allCities) {
      final index = random.nextInt(151); // 0-150
      city.pollenIndex = index;
      city.pollenLevel = PollenLevel.fromValue(index.toDouble()).index;
    }
    
    // 按省份分组
    _groupByProvince();
    
    // 默认展开前3个省份
    _sortProvinces();
    expandedProvinces = provinceMap.keys.take(3).toList();
    
    setState(() {
      isLoading = false;
    });
    
    print('✅ 数据初始化完成');
    print('   - 所有城市: ${allCities.length} 个');
    print('   - 省份数量: ${provinceMap.length} 个');
  }

  /// 按省份分组
  void _groupByProvince() {
    provinceMap.clear();
    
    for (final city in allCities) {
      final province = city.province ?? extractProvince(city.name);
      
      if (!provinceMap.containsKey(province)) {
        provinceMap[province] = [];
      }
      
      provinceMap[province]!.add(city);
    }
  }

  /// 排序城市
  void _sortCities() {
    for (final province in provinceMap.keys) {
      final cities = provinceMap[province]!;
      
      cities.sort((a, b) {
        final aIndex = a.pollenIndex ?? 0;
        final bIndex = b.pollenIndex ?? 0;
        
        if (isAscending) {
          return aIndex.compareTo(bIndex);
        } else {
          return bIndex.compareTo(aIndex);
        }
      });
    }
  }

  /// 排序省份（按平均花粉指数）
  void _sortProvinces() {
    final sortedProvinces = provinceMap.keys.toList();
    
    // 计算每个省份的平均花粉指数
    final avgIndexMap = <String, double>{};
    for (final province in sortedProvinces) {
      final cities = provinceMap[province]!;
      if (cities.isEmpty) continue;
      
      final sum = cities.fold<int>(
        0,
        (sum, city) => sum + (city.pollenIndex ?? 0),
      );
      final avg = sum / cities.length;
      avgIndexMap[province] = avg;
    }
    
    // 按平均值排序
    sortedProvinces.sort((a, b) {
      final avgA = avgIndexMap[a] ?? 0;
      final avgB = avgIndexMap[b] ?? 0;
      return isAscending ? avgA.compareTo(avgB) : avgB.compareTo(avgA);
    });
    
    // 重新构建 provinceMap 保持排序顺序
    final newMap = <String, List<CityItem>>{};
    for (final province in sortedProvinces) {
      newMap[province] = provinceMap[province]!;
    }
    
    provinceMap = newMap;
  }

  /// 切换排序方向
  void _toggleSort() {
    setState(() {
      isAscending = !isAscending;
    });
    
    _sortProvinces();
    _sortCities();
  }

  /// 获取花粉等级文字
  String _getPollenLevelText(int level) {
    switch (level) {
      case 1:
        return '低';
      case 2:
        return '中';
      case 3:
        return '高';
      case 4:
        return '很高';
      case 5:
        return '极高';
      default:
        return '无';
    }
  }

  /// 获取花粉等级颜色
  Color _getPollenColor(int level) {
    return ThemeService.getPollenColor(
      level,
      isDarkMode: Theme.of(context).brightness == Brightness.dark,
    );
  }

  /// 点击城市
  void _onCityTap(CityItem city) {
    // 显示 BottomSheet
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildCityDetailSheet(city),
    );
  }

  /// 构建城市详情 BottomSheet
  Widget _buildCityDetailSheet(CityItem city) {
    final level = city.pollenLevel ?? 0;
    final color = _getPollenColor(level);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 城市名称和色块
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Center(
                  child: Text(
                    (city.pollenIndex ?? 0).toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '花粉指数: ${city.pollenIndex ?? 0}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // 花粉等级说明
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8.0),
          ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '花粉等级: ${_getPollenLevelText(level)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('关闭'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: 跳转到首页并加载该城市数据
                    Navigator.pop(context); // 返回上一级
                    _showToast('已切换到 ${city.name}');
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('查看详情'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 显示 Toast
  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('花粉地图'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('加载城市数据...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('花粉地图'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          // 排序按钮
          TextButton.icon(
            onPressed: _toggleSort,
            icon: Icon(
              isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: Text(
              isAscending ? '从低到高' : '从高到低',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: provinceMap.length,
        itemBuilder: (context, index) {
          final province = provinceMap.keys.toList()[index];
          final cities = provinceMap[province]!;
          
          return _buildProvinceCard(province, cities);
        },
      ),
    );
  }

  /// 构建省份卡片
  Widget _buildProvinceCard(String province, List<CityItem> cities) {
    final isExpanded = expandedProvinces.contains(province);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // 计算平均花粉指数
    final avgIndex = cities.isEmpty
        ? 0.0
        : cities.fold<int>(
            0,
            (sum, city) => sum + (city.pollenIndex ?? 0),
          ) / cities.length;
    
    final avgLevel = PollenLevel.fromValue(avgIndex);
    final avgColor = _getPollenColor(avgLevel.index);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: isDarkMode ? Colors.grey.shade800 : null,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 8.0),
        title: Row(
          children: [
            // 左侧：省份平均色块
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: avgColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  avgLevel.index.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 中间：省份名称
            Expanded(
              child: Text(
                province,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            // 右侧：展开图标
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ],
        ),
        children: isExpanded ? cities.map((city) => _buildCityItem(city)).toList() : [],
        onExpansionChanged: (expanded) {
          setState(() {
            if (expanded) {
              if (!expandedProvinces.contains(province)) {
                expandedProvinces.add(province);
              }
            } else {
              expandedProvinces.remove(province);
            }
          });
        },
      ),
    );
  }

  /// 构建城市列表项
  Widget _buildCityItem(CityItem city) {
    final level = city.pollenLevel ?? 0;
    final color = _getPollenColor(level);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: // 左侧：色块
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  (city.pollenIndex ?? 0).toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        title: // 中间：城市名称
            Text(
              city.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
        trailing: // 右侧：等级文字
            Text(
              _getPollenLevelText(level),
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
        onTap: () => _onCityTap(city),
      ),
    );
  }
}
