/// GPS 定位服务
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// 检查定位权限
  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 检查定位服务是否启用
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // 检查权限
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// 获取当前位置
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('获取位置失败: $e');
      return null;
    }
  }

  /// 获取城市名称（反向地理编码 - 简化版，使用坐标判断）
  Future<String> getCityNameFromCoordinates(double lat, double lng) async {
    // 简化版：根据坐标范围判断城市
    // 实际应用中应该调用反向地理编码 API
    
    // 广州范围
    if (lat >= 22.5 && lat <= 23.9 && lng >= 112.9 && lng <= 113.8) {
      return '广州';
    }
    
    // 北京范围
    if (lat >= 39.4 && lat <= 41.1 && lng >= 115.4 && lng <= 117.5) {
      return '北京';
    }
    
    // 上海范围
    if (lat >= 30.7 && lat <= 31.5 && lng >= 121.0 && lng <= 122.0) {
      return '上海';
    }
    
    // 深圳范围
    if (lat >= 22.4 && lat <= 22.9 && lng >= 113.7 && lng <= 114.6) {
      return '深圳';
    }
    
    // 默认显示坐标
    return '${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)}';
  }
}
