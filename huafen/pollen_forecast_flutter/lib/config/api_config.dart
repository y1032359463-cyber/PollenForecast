/// API 配置 - 复用鸿蒙项目的服务器配置
class ApiConfig {
  // 花粉数据服务器（多服务器故障转移）
  static const List<ServerConfig> pollenServers = [
    ServerConfig(
      name: '阿里云新加坡',
      url: 'http://47.84.1.164:5000/pollen-api',
      timeout: 30000,
      priority: 1,
    ),
    ServerConfig(
      name: 'AWS Lambda 东京',
      url: 'https://g7d8o7pf5b.execute-api.ap-northeast-1.amazonaws.com/default/pollen-api',
      timeout: 30000,
      priority: 2,
    ),
    ServerConfig(
      name: 'AWS Lambda 新加坡',
      url: 'https://8de0lncs7f.execute-api.ap-southeast-1.amazonaws.com/default/pollen-api-singapore',
      timeout: 30000,
      priority: 3,
    ),
  ];

  // 天气数据服务器（百度云广州）
  static const String weatherBaseUrl = 'http://106.12.143.105:3000';
  
  // 和风天气端点
  static String weatherNow(double lng, double lat) => 
      '$weatherBaseUrl/weather/now?location=$lng,$lat';
  
  static String weather7d(double lng, double lat) => 
      '$weatherBaseUrl/weather/7d?location=$lng,$lat';
  
  static String astronomySun(double lng, double lat, String date) => 
      '$weatherBaseUrl/astronomy/sun?location=$lng,$lat&date=$date';

  // Minshu 花粉 API
  static String minshuPollenDay(String adcode, String recordDate) => 
      '$weatherBaseUrl/minshu/pollen/day?adcode=$adcode&recordDate=$recordDate';
}

class ServerConfig {
  final String name;
  final String url;
  final int timeout;
  final int priority;

  const ServerConfig({
    required this.name,
    required this.url,
    required this.timeout,
    required this.priority,
  });
}
