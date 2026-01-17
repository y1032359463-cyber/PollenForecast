/**
 * 应用配置常量
 */
export class AppConfig {
  // 应用信息
  static readonly APP_NAME = '去哪拉';
  static readonly APP_VERSION = '1.0.0';
  
  // 地图配置
  static readonly HUAWEI_MAP_KEY = 'YOUR_HUAWEI_MAP_KEY';  // TODO: 替换为真实 API Key
  static readonly AMAP_KEY = 'YOUR_AMAP_KEY';              // TODO: 替换为真实 API Key
  
  // 搜索范围（米）
  static readonly SEARCH_RADIUS_DEFAULT = 5000;   // 默认5公里
  static readonly SEARCH_RADIUS_MIN = 500;        // 最小500米
  static readonly SEARCH_RADIUS_MAX = 10000;      // 最大10公里
  
  // 去重距离阈值（米）
  static readonly DEDUP_DISTANCE = 50;            // 50米内视为同一厕所
  
  // 数据更新频率
  static readonly UPDATE_INTERVAL_HOTSPOT = 24 * 60 * 60 * 1000;     // 热点区域：1天
  static readonly UPDATE_INTERVAL_URBAN = 7 * 24 * 60 * 60 * 1000;   // 城市区域：7天
  static readonly UPDATE_INTERVAL_SUBURBAN = 30 * 24 * 60 * 60 * 1000; // 郊区：30天
  
  // 缓存配置
  static readonly CACHE_GRID_SIZE = 0.01;         // 缓存网格大小（约1公里）
  static readonly CACHE_MAX_AGE = 7 * 24 * 60 * 60 * 1000; // 缓存过期时间：7天
  
  // 分页配置
  static readonly PAGE_SIZE = 20;                 // 列表每页数量
  
  // 定位配置
  static readonly LOCATION_TIMEOUT = 10000;       // 定位超时：10秒
  static readonly LOCATION_MAX_AGE = 60000;       // 位置最大缓存时间：1分钟
}

/**
 * 地图配置（别名）
 */
export class MapConfig extends AppConfig {
  // 应用信息
  static readonly APP_NAME = '去哪拉';
  static readonly APP_VERSION = '1.0.0';
  
  // 地图配置
  static readonly HUAWEI_MAP_KEY = 'YOUR_HUAWEI_MAP_KEY';  // TODO: 替换为真实 API Key
  static readonly AMAP_KEY = 'YOUR_AMAP_KEY';              // TODO: 替换为真实 API Key
  
  // 搜索范围（米）
  static readonly SEARCH_RADIUS_DEFAULT = 5000;   // 默认5公里
  static readonly SEARCH_RADIUS_MIN = 500;        // 最小500米
  static readonly SEARCH_RADIUS_MAX = 10000;      // 最大10公里
  
  // 去重距离阈值（米）
  static readonly DEDUP_DISTANCE = 50;            // 50米内视为同一厕所
  
  // 数据更新频率
  static readonly UPDATE_INTERVAL_HOTSPOT = 24 * 60 * 60 * 1000;     // 热点区域：1天
  static readonly UPDATE_INTERVAL_URBAN = 7 * 24 * 60 * 60 * 1000;   // 城市区域：7天
  static readonly UPDATE_INTERVAL_SUBURBAN = 30 * 24 * 60 * 60 * 1000; // 郊区：30天
  
  // 缓存配置
  static readonly CACHE_GRID_SIZE = 0.01;         // 缓存网格大小（约1公里）
  static readonly CACHE_MAX_AGE = 7 * 24 * 60 * 60 * 1000; // 缓存过期时间：7天
  
  // 分页配置
  static readonly PAGE_SIZE = 20;                 // 列表每页数量
  
  // 定位配置
  static readonly LOCATION_TIMEOUT = 10000;       // 定位超时：10秒
  static readonly LOCATION_MAX_AGE = 60000;       // 位置最大缓存时间：1分钟
}

/**
 * 地图图层类型
 */
export enum MapLayerType {
  SIMPLE = 'simple',          // 简洁模式（默认）
  STANDARD = 'standard',      // 标准地图
  SATELLITE = 'satellite',    // 卫星地图
  NIGHT = 'night'            // 夜间模式
}

/**
 * 地图缩放级别
 */
export class MapZoomLevels {
  static readonly CITY = 12;          // 城市级别
  static readonly DISTRICT = 14;      // 区域级别
  static readonly STREET = 16;        // 街道级别（默认）
  static readonly BUILDING = 18;      // 建筑级别
}

export { AppConfig as Config };
