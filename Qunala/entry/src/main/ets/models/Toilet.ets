/**
 * 厕所数据模型
 */

/**
 * 数据来源枚举
 */
export enum ToiletDataSource {
  GOVERNMENT = 'government',     // 政府官方
  MAP_AMAP = 'amap',            // 高德地图
  MAP_HUAWEI = 'huawei',        // 华为地图
  MAP_BAIDU = 'baidu',          // 百度地图
  USER_REPORT = 'user',         // 用户上报
  THIRD_PARTY = 'third_party'   // 第三方平台
}

/**
 * 厕所类型
 */
export enum ToiletType {
  PUBLIC = 'public',             // 公共厕所
  MALL = 'mall',                 // 商场
  RESTAURANT = 'restaurant',     // 餐厅
  HOSPITAL = 'hospital',         // 医院
  PARK = 'park',                 // 公园
  GAS_STATION = 'gas_station',   // 加油站
  TRANSPORT = 'transport',       // 交通枢纽
  OTHER = 'other'
}

/**
 * 厕所状态
 */
export enum ToiletStatus {
  AVAILABLE = 'available',       // 可用/空闲
  CROWDED = 'crowded',          // 拥挤
  CLOSED = 'closed',            // 关闭
  MAINTENANCE = 'maintenance',   // 维修中
  UNKNOWN = 'unknown'           // 未知
}

/**
 * 设施信息
 */
export interface Facility {
  name: string;                  // 设施名称
  icon: string;                  // 图标
  available: boolean;            // 是否可用
}

/**
 * 数据源信息
 */
export interface DataSourceInfo {
  source: ToiletDataSource;      // 来源
  sourceId: string;              // 来源系统中的ID
  fetchedAt: number;             // 获取时间
  reliability: number;           // 可靠性评分（0-100）
  dataFields: string[];          // 该来源提供的字段
}

/**
 * 来源ID映射（用于去重）
 */
export interface SourceIdMap {
  source: ToiletDataSource;
  id: string;
}

/**
 * 厕所信息完整模型
 */
export interface Toilet {
  // 基础标识
  id: string;                    // 唯一ID（多源去重后生成）
  originalIds: SourceIdMap[];    // 原始来源ID映射
  
  // 位置信息
  name: string;                  // 厕所名称
  latitude: number;              // 纬度
  longitude: number;             // 经度
  address: string;               // 详细地址
  province?: string;             // 省份
  city?: string;                 // 城市
  district?: string;             // 区县
  
  // 类型与分类
  type: ToiletType;              // 厕所类型
  category?: string;             // 所属场所（商场名/公园名等）
  floor?: string;                // 楼层（如"3F"）
  
  // 设施信息
  facilities: Facility[];        // 设施列表
  hasDisabledAccess: boolean;    // 无障碍通道
  hasBabyRoom: boolean;          // 母婴室
  hasTissue: boolean;            // 纸巾供应
  hasHandSoap: boolean;          // 洗手液
  hasDryer: boolean;             // 烘干机
  
  // 状态信息
  status: ToiletStatus;          // 当前状态
  isOpen24Hours: boolean;        // 是否24小时
  openingHours?: string;         // 营业时间（如"06:00-22:00"）
  
  // 评价信息
  rating: number;                // 综合评分（0-5）
  reviewCount: number;           // 评价数量
  
  // 距离（运行时计算）
  distance?: number;             // 距离用户的距离（米）
  
  // 联系方式
  phone?: string;                // 联系电话
  
  // 图片
  images?: string[];             // 图片URL数组
  
  // 数据来源（核心 - 多源聚合）
  dataSources: DataSourceInfo[]; // 多个数据源信息
  primarySource: ToiletDataSource; // 主要数据源
  confidenceScore: number;       // 置信度评分（0-100）
  
  // 时间戳
  createdAt: number;             // 创建时间
  updatedAt: number;             // 更新时间
  verifiedAt?: number;           // 验证时间
  
  // 用户互动
  favoriteCount?: number;        // 收藏数
  reportCount?: number;          // 报告问题数
}

/**
 * 厕所原始数据（聚合前）
 */
export interface ToiletRawData {
  source: ToiletDataSource;
  sourceId: string;
  name: string;
  latitude: number;
  longitude: number;
  address: string;
  type?: ToiletType;
  hasDisabledAccess?: boolean;
  hasBabyRoom?: boolean;
  hasTissue?: boolean;
  rating?: number;
  rawData: Record<string, Object>;  // 原始数据
}

/**
 * 创建默认厕所对象
 */
export function createDefaultToilet(): Toilet {
  return {
    id: '',
    originalIds: [],
    name: '',
    latitude: 0,
    longitude: 0,
    address: '',
    type: ToiletType.PUBLIC,
    facilities: [],
    hasDisabledAccess: false,
    hasBabyRoom: false,
    hasTissue: false,
    hasHandSoap: false,
    hasDryer: false,
    status: ToiletStatus.UNKNOWN,
    isOpen24Hours: false,
    rating: 0,
    reviewCount: 0,
    dataSources: [],
    primarySource: ToiletDataSource.USER_REPORT,
    confidenceScore: 0,
    createdAt: Date.now(),
    updatedAt: Date.now()
  };
}
