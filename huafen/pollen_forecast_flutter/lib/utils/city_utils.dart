/// 城市工具类 - 提供拼音转换、搜索等功能
/// 参考 PollenForecast/entry/src/main/ets/utils/CityUtils.ets

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/city_models.dart';

/// 拼音映射表（常用城市）
const Map<String, String> PINYIN_MAP = {
  '北京': 'beijing',
  '上海': 'shanghai',
  '广州': 'guangzhou',
  '深圳': 'shenzhen',
  '杭州': 'hangzhou',
  '成都': 'chengdu',
  '武汉': 'wuhan',
  '重庆': 'chongqing',
  '西安': 'xian',
  '南京': 'nanjing',
  '天津': 'tianjin',
  '海口': 'haikou',
  '南宁': 'nanning',
  '贵阳': 'guiyang',
  '六盘水': 'liupanshui',
  '昆明': 'kunming',
  '长沙': 'changsha',
  '南昌': 'nanchang',
  '福州': 'fuzhou',
  '南充': 'nanchong',
  '合肥': 'hefei',
  '无锡': 'wuxi',
  '郑州': 'zhengzhou',
  '海南': 'hainan',
  '广西': 'guangxi',
  '贵州': 'guizhou',
  '云南': 'yunnan',
  '湖南': 'hunan',
  '江西': 'jiangxi',
  '福建': 'fujian',
  '湖北': 'hubei',
  '四川': 'sichuan',
  '安徽': 'anhui',
  '浙江': 'zhejiang',
  '陕西': 'shanxi',
  '江苏': 'jiangsu',
  '河南': 'henan',
};

/// 完整拼音映射表（从 pinyin_map.json 加载）
List<PinyinMapItem> PINYIN_MAP_DATA = [];
Map<String, PinyinMapItem> PINYIN_MAP_LOOKUP = {};

/// 是否已加载拼音映射表
bool PINYIN_MAP_LOADED = false;

/// 加载拼音映射表
Future<void> loadPinyinMap() async {
  if (PINYIN_MAP_LOADED) {
    return;
  }

  try {
    // 读取 assets/data/pinyin_map.json
    final data = await rootBundle.loadString('assets/data/pinyin_map.json');
    final List<dynamic> jsonList = jsonDecode(data);
    PINYIN_MAP_DATA = jsonList.map((json) => PinyinMapItem.fromJson(json as Map<String, dynamic>)).toList();

    // 构建查找表
    PINYIN_MAP_LOOKUP.clear();
    for (final item in PINYIN_MAP_DATA) {
      final key = item.name.replaceAll(RegExp(r'市|县|区$'), '');
      PINYIN_MAP_LOOKUP[key] = item;
    }

    PINYIN_MAP_LOADED = true;
    print('✅ 拼音映射表加载成功，共 ${PINYIN_MAP_DATA.length} 条记录');
  } catch (error) {
    print('❌ 加载拼音映射表失败: $error');
  }
}

/// 加载中国行政区划数据
Future<List<CityItem>> loadChinaAreaData() async {
  try {
    // 读取 assets/data/china_area_full.json
    final data = await rootBundle.loadString('assets/data/china_area_full.json');
    final Map<String, dynamic> jsonMap = jsonDecode(data);
    
    final List<CityItem> cities = [];
    
    // 递归解析城市数据
    void parseArea(Map<String, dynamic> area, String? province, String? parentName) {
      final name = area['name'] as String;
      final level = area['level'] as String;
      final adcode = area['adcode'] as String?;
      final center = area['center'] as String?;
      
      CityCoordinate? location;
      if (center != null) {
        final parts = center.split(',');
        if (parts.length == 2) {
          location = CityCoordinate(
            lat: double.tryParse(parts[1].trim()) ?? 0.0,
            lng: double.tryParse(parts[0].trim()) ?? 0.0,
          );
        }
      }

      // 获取拼音信息
      String? pinyin;
      String? pinyinInitial;
      
      if (PINYIN_MAP_LOADED) {
        final key = name.replaceAll(RegExp(r'市|县|区$'), '');
        final pinyinInfo = PINYIN_MAP_LOOKUP[key];
        if (pinyinInfo != null) {
          pinyin = pinyinInfo.pinyin;
          pinyinInitial = pinyinInfo.shortInitial;
        }
      }

      // 构建城市项
      final city = CityItem(
        name: parentName != null ? name : '$parentName $name',
        distance: 0.0,
        province: level == 'province' ? name : (province ?? ''),
        pinyin: pinyin,
        pinyinInitial: pinyinInitial,
        adcode: adcode,
        location: location,
      );

      if (level != 'district') {
        cities.add(city);
      }

      // 递归处理子级区域
      if (area['districts'] != null) {
        final List<dynamic> districts = area['districts'];
        for (final district in districts) {
          parseArea(district as Map<String, dynamic>, level == 'province' ? name : province, name);
        }
      }
    }

    parseArea(jsonMap, null, null);

    print('✅ 中国行政区划数据加载成功，共 ${cities.length} 个城市');
    return cities;
  } catch (error) {
    print('❌ 加载中国行政区划数据失败: $error');
    return [];
  }
}

/// 提取省份名称
/// 格式：省份 城市名 或 城市名
String extractProvince(String cityName) {
  // 如果包含空格，提取省份部分
  final parts = cityName.split(' ');
  if (parts.length > 1) {
    return parts[0];
  }

  // 常见省份列表
  const provinces = [
    '北京', '上海', '天津', '重庆',
    '海南', '广西', '贵州', '云南', '湖南', '江西', '福建',
    '湖北', '四川', '安徽', '浙江', '陕西', '江苏', '河南',
  ];

  // 检查是否是直辖市或自治区
  for (final province in provinces) {
    if (cityName.startsWith(province)) {
      return province;
    }
  }

  return '其他';
}

/// 获取城市拼音
String getCityPinyin(String cityName) {
  if (cityName.trim().isEmpty) {
    return '';
  }

  // 先检查完整匹配
  if (PINYIN_MAP.containsKey(cityName)) {
    return PINYIN_MAP[cityName]!;
  }

  // 提取城市名（去掉省份）
  final cityPart = cityName.split(' ').last;

  // 去掉"市"、"县"、"区"等后缀
  final cityWithoutSuffix = cityPart.replaceAll(RegExp(r'市|县|区$'), '');
  if (PINYIN_MAP.containsKey(cityWithoutSuffix)) {
    return '${PINYIN_MAP[cityWithoutSuffix]}shi';
  }

  if (PINYIN_MAP.containsKey(cityPart)) {
    return PINYIN_MAP[cityPart]!;
  }

  return '';
}

/// 获取拼音首字母
String getPinyinInitial(String cityName) {
  if (cityName.trim().isEmpty) {
    return '#';
  }

  final pinyin = getCityPinyin(cityName);
  if (pinyin.isNotEmpty) {
    return pinyin[0].toUpperCase();
  }

  return '#';
}

/// 搜索城市（支持中文、拼音、拼音首字母前缀匹配）
List<CityItem> searchCities(List<CityItem> cities, String keyword) {
  if (keyword.trim().isEmpty) {
    return cities;
  }

  final lowerKeyword = keyword.toLowerCase().trim();
  final List<CityItem> result = [];

  for (final city in cities) {
    bool matched = false;

    // 1. 中文匹配
    if (city.name.contains(keyword)) {
      matched = true;
    }

    // 2. 拼音完整匹配
    if (!matched && city.pinyin != null) {
      final pinyin = city.pinyin!.toLowerCase();
      if (pinyin.contains(lowerKeyword)) {
        matched = true;
      }
    }

    // 3. 拼音首字母完全匹配
    if (!matched && city.pinyinInitial != null) {
      final initial = city.pinyinInitial!.toLowerCase();
      if (initial == lowerKeyword) {
        matched = true;
      }
    }

    // 4. 拼音首字母前缀匹配
    if (!matched && city.pinyinInitial != null) {
      final initial = city.pinyinInitial!.toLowerCase();
      if (initial.startsWith(lowerKeyword)) {
        matched = true;
      }
    }

    // 5. 从完整拼音映射表搜索
    if (!matched && PINYIN_MAP_LOADED && PINYIN_MAP_LOOKUP.isNotEmpty) {
      final key = city.name.replaceAll(RegExp(r'市|县|区$'), '');
      final pinyinInfo = PINYIN_MAP_LOOKUP[key];
      if (pinyinInfo != null && pinyinInfo.initial.toLowerCase().startsWith(lowerKeyword)) {
        matched = true;
      }
    }

    if (matched) {
      result.add(city);
    }
  }

  return result;
}

/// 按省份分组城市
List<CityGroup> groupCitiesByProvince(List<CityItem> cities) {
  final Map<String, List<CityItem>> groups = {};

  for (final city in cities) {
    final province = city.province ?? extractProvince(city.name);
    if (!groups.containsKey(province)) {
      groups[province] = [];
    }
    groups[province]!.add(city);
  }

  // 转换为数组并排序
  final List<CityGroup> result = [];
  groups.forEach((province, cityList) {
    result.add(CityGroup(
      key: province,
      title: province,
      cities: cityList,
      isExpanded: true, // 默认展开
    ));
  });

  // 按省份名排序
  result.sort((a, b) {
    // 特殊省份优先
    const specialProvinces = ['北京', '上海', '天津', '重庆', '广东', '江苏', '浙江'];
    final aIndex = specialProvinces.indexOf(a.title);
    final bIndex = specialProvinces.indexOf(b.title);

    if (aIndex != -1 && bIndex != -1) {
      return aIndex - bIndex;
    }
    if (aIndex != -1) return -1;
    if (bIndex != -1) return 1;

    return a.title.compareTo(b.title);
  });

  return result;
}

/// 热门城市列表（7个）
List<String> getHotCities() {
  return [
    '北京市',
    '上海市',
    '广州市',
    '深圳市',
    '杭州市',
    '成都市',
    '武汉市',
  ];
}
