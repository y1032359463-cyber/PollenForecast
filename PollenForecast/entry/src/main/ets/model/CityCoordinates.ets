/**
 * 城市经纬度映射表
 * 存储中国主要城市的经纬度坐标 (GCJ-02坐标系)
 */

export class CityCoordinate {
  latitude: number = 0
  longitude: number = 0

  constructor(latitude: number, longitude: number) {
    this.latitude = latitude
    this.longitude = longitude
  }
}

/**
 * 根据城市名获取经纬度
 * @param cityName 城市名称
 * @returns 经纬度坐标,如果未找到则返回广州的坐标
 */
export function getCityCoordinate(cityName: string): CityCoordinate {
  // 去除城市名中的"市"、"省"等后缀
  const cleanName = cityName.replace(/[市省]/g, '')
  
  // 广东省城市
  if (cleanName === '广州' || cleanName.includes('广州')) return new CityCoordinate(23.1291, 113.2644)
  if (cleanName === '深圳' || cleanName.includes('深圳')) return new CityCoordinate(22.5431, 114.0579)
  if (cleanName === '珠海' || cleanName.includes('珠海')) return new CityCoordinate(22.2711, 113.5767)
  if (cleanName === '汕头' || cleanName.includes('汕头')) return new CityCoordinate(23.3540, 116.6818)
  if (cleanName === '佛山' || cleanName.includes('佛山')) return new CityCoordinate(23.0218, 113.1219)
  if (cleanName === '东莞' || cleanName.includes('东莞')) return new CityCoordinate(23.0205, 113.7518)
  if (cleanName === '中山' || cleanName.includes('中山')) return new CityCoordinate(22.5171, 113.3926)
  if (cleanName === '惠州' || cleanName.includes('惠州')) return new CityCoordinate(23.1115, 114.4152)
  if (cleanName === '江门' || cleanName.includes('江门')) return new CityCoordinate(22.5790, 113.0815)
  if (cleanName === '湛江' || cleanName.includes('湛江')) return new CityCoordinate(21.2707, 110.3577)
  if (cleanName === '茂名' || cleanName.includes('茂名')) return new CityCoordinate(21.6631, 110.9253)
  if (cleanName === '肇庆' || cleanName.includes('肇庆')) return new CityCoordinate(23.0786, 112.4653)
  if (cleanName === '梅州' || cleanName.includes('梅州')) return new CityCoordinate(24.2888, 116.1178)
  if (cleanName === '汕尾' || cleanName.includes('汕尾')) return new CityCoordinate(22.7787, 115.3750)
  if (cleanName === '河源' || cleanName.includes('河源')) return new CityCoordinate(23.7433, 114.7005)
  if (cleanName === '阳江' || cleanName.includes('阳江')) return new CityCoordinate(21.8578, 111.9827)
  if (cleanName === '清远' || cleanName.includes('清远')) return new CityCoordinate(23.6817, 113.0561)
  if (cleanName === '潮州' || cleanName.includes('潮州')) return new CityCoordinate(23.6567, 116.6226)
  if (cleanName === '揭阳' || cleanName.includes('揭阳')) return new CityCoordinate(23.5494, 116.3728)
  if (cleanName === '云浮' || cleanName.includes('云浮')) return new CityCoordinate(22.9150, 112.0440)
  
  // 直辖市
  if (cleanName === '北京' || cleanName.includes('北京')) return new CityCoordinate(39.9042, 116.4074)
  if (cleanName === '上海' || cleanName.includes('上海')) return new CityCoordinate(31.2304, 121.4737)
  if (cleanName === '天津' || cleanName.includes('天津')) return new CityCoordinate(39.0842, 117.2010)
  if (cleanName === '重庆' || cleanName.includes('重庆')) return new CityCoordinate(29.5630, 106.5516)
  
  // 省会城市
  if (cleanName === '南京' || cleanName.includes('南京')) return new CityCoordinate(32.0603, 118.7969)
  if (cleanName === '杭州' || cleanName.includes('杭州')) return new CityCoordinate(30.2741, 120.1551)
  if (cleanName === '武汉' || cleanName.includes('武汉')) return new CityCoordinate(30.5928, 114.3055)
  if (cleanName === '成都' || cleanName.includes('成都')) return new CityCoordinate(30.5728, 104.0668)
  if (cleanName === '西安' || cleanName.includes('西安')) return new CityCoordinate(34.3416, 108.9398)
  if (cleanName === '郑州' || cleanName.includes('郑州')) return new CityCoordinate(34.7466, 113.6253)
  if (cleanName === '长沙' || cleanName.includes('长沙')) return new CityCoordinate(28.2282, 112.9388)
  if (cleanName === '南宁' || cleanName.includes('南宁')) return new CityCoordinate(22.8170, 108.3665)
  if (cleanName === '昆明' || cleanName.includes('昆明')) return new CityCoordinate(25.0406, 102.7123)
  if (cleanName === '贵阳' || cleanName.includes('贵阳')) return new CityCoordinate(26.6470, 106.6302)
  if (cleanName === '兰州' || cleanName.includes('兰州')) return new CityCoordinate(36.0611, 103.8343)
  if (cleanName === '银川' || cleanName.includes('银川')) return new CityCoordinate(38.4872, 106.2309)
  if (cleanName === '西宁' || cleanName.includes('西宁')) return new CityCoordinate(36.6171, 101.7782)
  if (cleanName === '拉萨' || cleanName.includes('拉萨')) return new CityCoordinate(29.6470, 91.1172)
  if (cleanName === '沈阳' || cleanName.includes('沈阳')) return new CityCoordinate(41.8057, 123.4328)
  if (cleanName === '长春' || cleanName.includes('长春')) return new CityCoordinate(43.8171, 125.3235)
  if (cleanName === '哈尔滨' || cleanName.includes('哈尔滨')) return new CityCoordinate(45.8038, 126.5340)
  if (cleanName === '石家庄' || cleanName.includes('石家庄')) return new CityCoordinate(38.0428, 114.5149)
  if (cleanName === '太原' || cleanName.includes('太原')) return new CityCoordinate(37.8706, 112.5489)
  if (cleanName === '济南' || cleanName.includes('济南')) return new CityCoordinate(36.6512, 117.1205)
  if (cleanName === '合肥' || cleanName.includes('合肥')) return new CityCoordinate(31.8206, 117.2272)
  if (cleanName === '南昌' || cleanName.includes('南昌')) return new CityCoordinate(28.6820, 115.8579)
  if (cleanName === '福州' || cleanName.includes('福州')) return new CityCoordinate(26.0745, 119.2965)
  if (cleanName === '海口' || cleanName.includes('海口')) return new CityCoordinate(20.0444, 110.1999)
  
  // 其他重点城市
  if (cleanName === '苏州' || cleanName.includes('苏州')) return new CityCoordinate(31.2989, 120.5853)
  if (cleanName === '无锡' || cleanName.includes('无锡')) return new CityCoordinate(31.4912, 120.3119)
  if (cleanName === '宁波' || cleanName.includes('宁波')) return new CityCoordinate(29.8683, 121.5440)
  if (cleanName === '厦门' || cleanName.includes('厦门')) return new CityCoordinate(24.4798, 118.0894)
  if (cleanName === '青岛' || cleanName.includes('青岛')) return new CityCoordinate(36.0671, 120.3826)
  if (cleanName === '大连' || cleanName.includes('大连')) return new CityCoordinate(38.9140, 121.6147)
  if (cleanName === '三亚' || cleanName.includes('三亚')) return new CityCoordinate(18.2528, 109.5122)
  if (cleanName === '温州' || cleanName.includes('温州')) return new CityCoordinate(28.0006, 120.6724)
  if (cleanName === '洛阳' || cleanName.includes('洛阳')) return new CityCoordinate(34.6197, 112.4540)
  if (cleanName === '乌鲁木齐' || cleanName.includes('乌鲁木齐')) return new CityCoordinate(43.8256, 87.6168)
  
  // 默认返回广州坐标
  console.warn(`[CityCoordinates] 未找到城市 ${cityName} 的坐标，使用广州作为默认位置`)
  return new CityCoordinate(23.1291, 113.2644)
}
