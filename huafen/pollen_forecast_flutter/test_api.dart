import 'package:dio/dio.dart';

/// API 连接测试脚本
void main() async {
  print('开始测试花粉 API 连接...\n');

  final dio = Dio();
  final servers = [
    'https://g7d8o7pf5b.execute-api.ap-northeast-1.amazonaws.com/default/pollen-api',
    'https://8de0lncs7f.execute-api.ap-southeast-1.amazonaws.com/default/pollen-api-singapore',
    'http://47.84.1.164:5000/pollen-api',
  ];

  // 测试坐标：广州（23.12, 113.26）
  const lat = 23.12;
  const lng = 113.26;
  const days = 5;

  for (var i = 0; i < servers.length; i++) {
    final server = servers[i];
    print('[$i+1] 测试服务器: $server');
    
    try {
      final stopwatch = Stopwatch()..start();
      final response = await dio.get(
        server,
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'days': days,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      stopwatch.stop();

      if (response.statusCode == 200) {
        print('✅ 成功！响应时间: ${stopwatch.elapsedMilliseconds}ms');
        
        final data = response.data;
        print('   - indexInfo: ${data['indexInfo']}');
        print('   - dailyInfo 条数: ${data['dailyInfo']?.length ?? 0}');
        
        if (data['dailyInfo'] != null && data['dailyInfo'].isNotEmpty) {
          final firstDay = data['dailyInfo'][0];
          print('   - 第一天日期: ${firstDay['date']}');
          print('   - 第一天指数: ${firstDay['indexInfo']}');
        }
        print('');
      } else {
        print('❌ 失败！状态码: ${response.statusCode}\n');
      }
    } catch (e) {
      print('❌ 错误: $e\n');
    }
  }

  print('测试完成！');
}
