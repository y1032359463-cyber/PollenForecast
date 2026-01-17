/// 城市搜索页面
/// 功能：搜索框、热门城市、我的收藏、搜索结果
/// 参考：PollenForecast/entry/src/main/ets/views/RegionView.ets

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/city_utils.dart';
import '../models/city_models.dart';

/// 城市搜索页面
class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  // 收藏的城市列表（最多4个）
  final List<String> favoriteCities = [];
  
  // 搜索框控制器
  final TextEditingController searchController = TextEditingController();
  
  // 所有城市数据
  List<CityItem> allCities = [];
  
  // 搜索结果
  List<CityItem> searchResults = [];
  
  // 热门城市列表
  List<String> hotCities = [];
  
  // Tab 当前索引：0=热门城市，1=我的收藏
  int currentTabIndex = 0;
  
  // 是否正在搜索
  bool isSearching = false;
  
  // 收藏数量上限
  static const int MAX_FAVORITES = 4;

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
    
    // 获取热门城市
    hotCities = getHotCities();
    
    // 加载收藏的城市
    await _loadFavorites();
    
    print('✅ 数据初始化完成');
    print('   - 所有城市: ${allCities.length} 个');
    print('   - 热门城市: ${hotCities.length} 个');
    print('   - 收藏城市: ${favoriteCities.length} 个');
  }

  /// 加载收藏的城市
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favoriteCities') ?? [];
    
    // 限制最多4个收藏
    favoriteCities.clear();
    favoriteCities.addAll(favorites.take(MAX_FAVORITES));
    
    setState(() {});
  }

  /// 保存收藏的城市
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteCities', favoriteCities);
  }

  /// 搜索城市
  void _onSearchChanged(String keyword) {
    setState(() {
      isSearching = keyword.trim().isNotEmpty;
      if (keyword.trim().isEmpty) {
        searchResults.clear();
      } else {
        searchResults = searchCities(allCities, keyword);
      }
    });
  }

  /// 切换到该城市并返回首页
  void _selectCity(String cityName) {
    // 从城市列表中查找该城市
    CityItem? selectedCity;
    
    // 先在搜索结果中查找
    if (isSearching && searchResults.isNotEmpty) {
      selectedCity = searchResults.firstWhere((c) => c.name == cityName, orElse: () => allCities.firstWhere((c) => c.name.contains(cityName)));
    } else {
      // 在热门城市或收藏中查找
      selectedCity = allCities.firstWhere(
        (c) => c.name == cityName,
        orElse: () => allCities.firstWhere(
          (c) => c.name.contains(cityName),
          orElse: () => CityItem(name: cityName, distance: 0.0),
        ),
      );
    }

    // 返回搜索结果
    if (selectedCity.location != null) {
      Navigator.pop(context, CitySearchResult(
        name: selectedCity.name,
        location: selectedCity.location!,
        adcode: selectedCity.adcode ?? '',
      ));
      
      print('✅ 选择城市: ${selectedCity.name}');
    } else {
      // 使用默认坐标（北京）
      Navigator.pop(context, CitySearchResult(
        name: selectedCity.name,
        location: CityCoordinate(lat: 39.9042, lng: 116.4074),
        adcode: selectedCity.adcode ?? '',
      ));
      
      print('⚠️ 城市 ${selectedCity.name} 没有坐标，使用默认坐标');
    }
  }

  /// 切换收藏状态
  Future<void> _toggleFavorite(String cityName) async {
    setState(() {
      if (favoriteCities.contains(cityName)) {
        favoriteCities.remove(cityName);
        _showToast('已取消收藏 $cityName');
      } else {
        if (favoriteCities.length >= MAX_FAVORITES) {
          _showToast('最多只能收藏 $MAX_FAVORITES 个城市');
          return;
        }
        favoriteCities.add(cityName);
        _showToast('已收藏 $cityName');
      }
    });

    await _saveFavorites();

    // 如果在搜索模式下，更新搜索结果
    if (isSearching) {
      final updatedResults = searchCities(allCities, searchController.text);
      setState(() {
        searchResults = updatedResults;
      });
    }
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('选择城市'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 搜索框
          _buildSearchBar(),
          
          // Tab 切换
          _buildTabBar(),
          
          // 内容区域
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  /// 搜索框
  Widget _buildSearchBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: '搜索城市（支持拼音）',
          hintStyle: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
          prefixIcon: Icon(
            Icons.search,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  onPressed: () {
                    searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2.0,
            ),
          ),
          filled: true,
          fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
      ),
    );
  }

  /// Tab 栏
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('热门城市', 0),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: _buildTabButton('我的收藏', 1),
          ),
        ],
      ),
    );
  }

  /// Tab 按钮
  Widget _buildTabButton(String title, int index) {
    final isSelected = currentTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  /// 内容区域
  Widget _buildContent() {
    if (isSearching) {
      // 显示搜索结果
      if (searchResults.isEmpty) {
        return _buildEmptyState('未找到匹配的城市');
      }
      return _buildCityList(searchResults, isFavoriteMode: false);
    } else {
      // 显示热门城市或收藏
      if (currentTabIndex == 0) {
        // 热门城市
        return _buildHotCities();
      } else {
        // 我的收藏
        if (favoriteCities.isEmpty) {
          return _buildEmptyState('暂无收藏的城市\n点击右侧星号添加收藏');
        }
        
        // 从所有城市中筛选收藏的城市
        final favoriteCityItems = allCities.where((city) {
          return favoriteCities.contains(city.name);
        }).toList();
        
        return _buildCityList(favoriteCityItems, isFavoriteMode: true);
      }
    }
  }

  /// 热门城市网格
  Widget _buildHotCities() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 2.5,
        ),
        itemCount: hotCities.length,
        itemBuilder: (context, index) {
          final cityName = hotCities[index];
          return _buildCityCard(cityName, isFavorite: favoriteCities.contains(cityName));
        },
      ),
    );
  }

  /// 城市列表（ListView）
  Widget _buildCityList(List<CityItem> cities, {required bool isFavoriteMode}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        return _buildCityListItem(city, isFavoriteMode);
      },
    );
  }

  /// 城市列表项
  Widget _buildCityListItem(CityItem city, bool isFavoriteMode) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isFavorite = favoriteCities.contains(city.name);
    
    return Card(
      color: isDarkMode ? Colors.grey.shade800 : null,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        title: Text(
          city.name,
          style: TextStyle(
            fontSize: 16.0,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        trailing: isFavoriteMode
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? Colors.amber : (isDarkMode ? Colors.grey.shade400 : Colors.grey),
                    ),
                    onPressed: () => _toggleFavorite(city.name),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ],
              )
            : Icon(
                Icons.chevron_right,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
        onTap: () => _selectCity(city.name),
      ),
    );
  }

  /// 城市卡片（热门城市网格）
  Widget _buildCityCard(String cityName, {required bool isFavorite}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      color: isDarkMode ? Colors.grey.shade800 : null,
      child: InkWell(
        onTap: () => _selectCity(cityName),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                cityName,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4.0),
              GestureDetector(
                onTap: () => _toggleFavorite(cityName),
                child: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.amber : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade400),
                  size: 20.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 空状态提示
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_city,
            size: 64.0,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16.0),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
