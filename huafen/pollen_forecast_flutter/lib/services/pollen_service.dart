import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/pollen_models.dart';

/// 花粉服务 - 支持多服务器故障转移
class PollenService {
  static final PollenService _instance = PollenService._internal();
  factory PollenService() => _instance;
  PollenService._internal();

  final Dio _dio = Dio();
  int _currentServerIndex = 0;

  /// 获取花粉预报数据
  Future<PollenForecastResponse> getPollenForecast({
    required double lat,
    required double lng,
    int days = 5,
  }) async {
    // 按优先级尝试服务器
    for (var i = 0; i < ApiConfig.pollenServers.length; i++) {
      final server = ApiConfig.pollenServers[i];
      try {
        final response = await _dio.get(
          server.url,
          queryParameters: {
            'lat': lat,
            'lng': lng,
            'days': days,
          },
          options: Options(
            receiveTimeout: Duration(milliseconds: server.timeout),
            sendTimeout: Duration(milliseconds: server.timeout),
          ),
        );

        if (response.statusCode == 200) {
          _currentServerIndex = i;
          return PollenForecastResponse.fromJson(response.data);
        }
      } catch (e) {
        // 尝试下一个服务器
        if (i == ApiConfig.pollenServers.length - 1) {
          rethrow; // 所有服务器都失败，抛出异常
        }
        continue;
      }
    }

    throw Exception('所有服务器都无法连接');
  }
}
