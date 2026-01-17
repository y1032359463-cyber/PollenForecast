/// 花粉数据模型 - 复用鸿蒙项目的数据结构
class PollenForecastResponse {
  final double? indexInfo;
  final List<PollenDay> dailyInfo;
  final String? location;

  PollenForecastResponse({
    this.indexInfo,
    required this.dailyInfo,
    this.location,
  });

  factory PollenForecastResponse.fromJson(Map<String, dynamic> json) {
    return PollenForecastResponse(
      indexInfo: json['indexInfo']?.toDouble(),
      dailyInfo: (json['dailyInfo'] as List<dynamic>?)
              ?.map((e) => PollenDay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      location: json['location'] as String?,
    );
  }
}

class PollenDay {
  final String date;
  final double? indexInfo;
  final List<PlantInfo>? plantInfo;

  PollenDay({
    required this.date,
    this.indexInfo,
    this.plantInfo,
  });

  factory PollenDay.fromJson(Map<String, dynamic> json) {
    return PollenDay(
      date: json['date'] as String,
      indexInfo: json['indexInfo']?.toDouble(),
      plantInfo: json['plantInfo'] != null
          ? (json['plantInfo'] as List<dynamic>)
              .map((e) => PlantInfo.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class PlantInfo {
  final String? type;
  final String? name;
  final double? indexInfo;

  PlantInfo({
    this.type,
    this.name,
    this.indexInfo,
  });

  factory PlantInfo.fromJson(Map<String, dynamic> json) {
    return PlantInfo(
      type: json['type'] as String?,
      name: json['name'] as String?,
      indexInfo: json['indexInfo']?.toDouble(),
    );
  }
}

/// 花粉等级枚举
enum PollenLevel {
  low(0, 30, '低', 0xFF4CAF50),
  moderate(31, 60, '中等', 0xFFFFC107),
  high(61, 90, '高', 0xFFFF9800),
  veryHigh(91, 120, '很高', 0xFFF44336),
  extreme(121, double.infinity, '极高', 0xFF9C27B0);

  final double min;
  final double max;
  final String label;
  final int color;

  const PollenLevel(this.min, this.max, this.label, this.color);

  static PollenLevel fromValue(double? value) {
    if (value == null) return low;
    for (var level in PollenLevel.values) {
      if (value >= level.min && value <= level.max) {
        return level;
      }
    }
    return extreme;
  }
}
