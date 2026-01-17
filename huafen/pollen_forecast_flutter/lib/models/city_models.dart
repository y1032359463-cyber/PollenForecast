/// 城市数据模型（与鸿蒙项目一致）

/// 城市项接口
class CityItem {
  final String name;
  final double distance;
  bool isFavorite;
  bool isTop;
  int? pollenLevel; // 花粉等级 (0-5, -1表示无数据)
  int? pollenIndex; // 花粉指数值
  String? province; // 省份名称
  String? pinyin; // 拼音（用于搜索和排序）
  String? pinyinInitial; // 拼音首字母（用于字母索引）
  bool? hasDistricts; // 是否有下级区县
  List<DistrictItem>? districts; // 区县列表
  String? adcode; // 行政区划代码
  CityCoordinate? location; // 经纬度

  CityItem({
    required this.name,
    required this.distance,
    this.isFavorite = false,
    this.isTop = false,
    this.pollenLevel,
    this.pollenIndex,
    this.province,
    this.pinyin,
    this.pinyinInitial,
    this.hasDistricts,
    this.districts,
    this.adcode,
    this.location,
  });

  factory CityItem.fromJson(Map<String, dynamic> json) {
    // 解析经纬度
    CityCoordinate? location;
    if (json['center'] != null && json['center'] is String) {
      final parts = (json['center'] as String).split(',');
      if (parts.length == 2) {
        location = CityCoordinate(
          lat: double.tryParse(parts[1].trim()) ?? 0.0,
          lng: double.tryParse(parts[0].trim()) ?? 0.0,
        );
      }
    }

    return CityItem(
      name: json['name'] as String? ?? '',
      distance: 0.0,
      isFavorite: false,
      isTop: false,
      province: json['level'] == 'province' ? json['name'] : null,
      hasDistricts: json['districts'] != null && (json['districts'] as List).isNotEmpty,
      districts: json['districts'] != null
          ? (json['districts'] as List).map((d) => DistrictItem.fromJson(d as Map<String, dynamic>)).toList()
          : null,
      adcode: json['adcode'] as String?,
      location: location,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'distance': distance,
      'isFavorite': isFavorite,
      'isTop': isTop,
      'pollenLevel': pollenLevel,
      'pollenIndex': pollenIndex,
      'province': province,
      'pinyin': pinyin,
      'pinyinInitial': pinyinInitial,
      'hasDistricts': hasDistricts,
      'adcode': adcode,
      'location': location?.toJson(),
    };
  }

  /// 创建副本
  CityItem copyWith({
    String? name,
    double? distance,
    bool? isFavorite,
    bool? isTop,
    int? pollenLevel,
    int? pollenIndex,
    String? province,
    String? pinyin,
    String? pinyinInitial,
    bool? hasDistricts,
    List<DistrictItem>? districts,
    String? adcode,
    CityCoordinate? location,
  }) {
    return CityItem(
      name: name ?? this.name,
      distance: distance ?? this.distance,
      isFavorite: isFavorite ?? this.isFavorite,
      isTop: isTop ?? this.isTop,
      pollenLevel: pollenLevel ?? this.pollenLevel,
      pollenIndex: pollenIndex ?? this.pollenIndex,
      province: province ?? this.province,
      pinyin: pinyin ?? this.pinyin,
      pinyinInitial: pinyinInitial ?? this.pinyinInitial,
      hasDistricts: hasDistricts ?? this.hasDistricts,
      districts: districts ?? this.districts,
      adcode: adcode ?? this.adcode,
      location: location ?? this.location,
    );
  }
}

/// 区县项接口
class DistrictItem {
  final String name; // 区县名称
  final String cityName; // 所属城市
  bool isFavorite; // 是否收藏
  bool isTop; // 是否置顶
  final String adcode; // 行政区划代码
  final CityCoordinate location; // 经纬度
  int? pollenLevel; // 花粉等级（可选）
  int? pollenIndex; // 花粉指数值（可选）

  DistrictItem({
    required this.name,
    required this.cityName,
    this.isFavorite = false,
    this.isTop = false,
    required this.adcode,
    required this.location,
    this.pollenLevel,
    this.pollenIndex,
  });

  factory DistrictItem.fromJson(Map<String, dynamic> json) {
    CityCoordinate? location;
    if (json['center'] != null && json['center'] is String) {
      final parts = (json['center'] as String).split(',');
      if (parts.length == 2) {
        location = CityCoordinate(
          lat: double.tryParse(parts[1].trim()) ?? 0.0,
          lng: double.tryParse(parts[0].trim()) ?? 0.0,
        );
      }
    }

    return DistrictItem(
      name: json['name'] as String? ?? '',
      cityName: '', // 需要上级设置
      isFavorite: false,
      isTop: false,
      adcode: json['adcode'] as String? ?? '',
      location: location!,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cityName': cityName,
      'isFavorite': isFavorite,
      'isTop': isTop,
      'adcode': adcode,
      'location': location.toJson(),
      'pollenLevel': pollenLevel,
      'pollenIndex': pollenIndex,
    };
  }
}

/// 城市坐标接口
class CityCoordinate {
  final double lat; // 纬度
  final double lng; // 经度

  CityCoordinate({
    required this.lat,
    required this.lng,
  });

  factory CityCoordinate.fromJson(Map<String, dynamic> json) {
    return CityCoordinate(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}

/// 拼音映射接口
class PinyinMapItem {
  final String name;
  final String pinyin;
  final String initial;
  final String shortInitial;
  final String adcode;
  final String level;

  PinyinMapItem({
    required this.name,
    required this.pinyin,
    required this.initial,
    required this.shortInitial,
    required this.adcode,
    required this.level,
  });

  factory PinyinMapItem.fromJson(Map<String, dynamic> json) {
    return PinyinMapItem(
      name: json['name'] as String? ?? '',
      pinyin: json['pinyin'] as String? ?? '',
      initial: json['initial'] as String? ?? '',
      shortInitial: json['shortInitial'] as String? ?? '',
      adcode: json['adcode'] as String? ?? '',
      level: json['level'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pinyin': pinyin,
      'initial': initial,
      'shortInitial': shortInitial,
      'adcode': adcode,
      'level': level,
    };
  }
}

/// 城市分组接口
class CityGroup {
  final String key; // 分组键（省份名或字母）
  final String title; // 分组标题
  final List<CityItem> cities;
  bool isExpanded; // 是否展开（用于省份分组）

  CityGroup({
    required this.key,
    required this.title,
    required this.cities,
    this.isExpanded = false,
  });
}

/// 搜索结果（返回给首页）
class CitySearchResult {
  final String name;
  final CityCoordinate location;
  final String adcode;

  CitySearchResult({
    required this.name,
    required this.location,
    required this.adcode,
  });
}
