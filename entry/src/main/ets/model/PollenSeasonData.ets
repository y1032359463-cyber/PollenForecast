/**
 * 城市花粉季节静态数据库
 * 数据来源：公开气象资料整理（2020-2024年）
 * 仅供参考，实际情况可能因年份和气候变化有所差异
 */

export interface PollenSeasonInfo {
  cityCode: string          // 城市代码（行政区划代码）
  cityName: string          // 城市名称
  seasons: SeasonPeriod[]   // 花粉季节列表
}

export interface SeasonPeriod {
  name: string              // 季节名称（春季/秋季）
  startMonth: number        // 开始月份 (1-12)
  endMonth: number          // 结束月份 (1-12)
  peakMonth: number         // 高峰月份 (1-12)
  level: number             // 风险等级 (1-5, 5最高)
  mainAllergens: string[]   // 主要过敏原
  tips: string[]            // 防护建议
}

/**
 * 内置城市花粉季节数据库
 * 覆盖15个主要城市
 */
export const POLLEN_SEASON_DATABASE: PollenSeasonInfo[] = [
  {
    cityCode: '420100',
    cityName: '武汉',
    seasons: [
      {
        name: '春季花粉期',
        startMonth: 3,
        endMonth: 5,
        peakMonth: 4,
        level: 4,
        mainAllergens: ['杨树', '柳树', '法国梧桐', '榆树'],
        tips: [
          '3月初开始关注花粉预报',
          '外出佩戴N95口罩',
          '避免上午10点至下午4点外出',
          '使用空气净化器',
          '如需用药请提前咨询医生'
        ]
      },
      {
        name: '秋季花粉期',
        startMonth: 9,
        endMonth: 10,
        peakMonth: 9,
        level: 3,
        mainAllergens: ['豚草', '蒿草', '葎草'],
        tips: [
          '避免前往草地、公园',
          '回家后及时更换衣物',
          '如有过敏症状请及时就医'
        ]
      }
    ]
  },
  {
    cityCode: '110100',
    cityName: '北京',
    seasons: [
      {
        name: '春季花粉期',
        startMonth: 3,
        endMonth: 5,
        peakMonth: 4,
        level: 5,
        mainAllergens: ['杨树', '柏树', '榆树', '白蜡树'],
        tips: [
          '北京春季花粉浓度全国最高',
          '建议提前2周咨询医生',
          '必要时减少户外活动',
          '车内使用HEPA滤芯',
          '过敏患者建议暂时离京'
        ]
      },
      {
        name: '秋季花粉期',
        startMonth: 8,
        endMonth: 10,
        peakMonth: 9,
        level: 4,
        mainAllergens: ['蒿草', '豚草', '葎草'],
        tips: [
          '秋季草本花粉致敏性强',
          '避免前往郊区和公园',
          '关闭门窗使用空气净化器'
        ]
      }
    ]
  },
  {
    cityCode: '310100',
    cityName: '上海',
    seasons: [
      {
        name: '春季花粉期',
        startMonth: 3,
        endMonth: 5,
        peakMonth: 4,
        level: 3,
        mainAllergens: ['悬铃木（法国梧桐）', '杨树', '柳树'],
        tips: [
          '悬铃木是上海主要过敏原',
          '避开人民广场、淮海路等梧桐密集区',
          '外出佩戴口罩'
        ]
      },
      {
        name: '秋季花粉期',
        startMonth: 9,
        endMonth: 10,
        peakMonth: 9,
        level: 2,
        mainAllergens: ['蒿草', '豚草'],
        tips: [
          '秋季花粉浓度相对较低',
          '轻度过敏患者可正常活动'
        ]
      }
    ]
  },
  {
    cityCode: '440100',
    cityName: '广州',
    seasons: [
      {
        name: '春季花粉期',
        startMonth: 2,
        endMonth: 4,
        peakMonth: 3,
        level: 2,
        mainAllergens: ['木棉', '桉树', '榕树'],
        tips: [
          '广州春季花粉浓度相对较低',
          '木棉飘絮期注意防护',
          '轻度过敏患者可正常活动'
        ]
      }
    ]
  },
  {
    cityCode: '500100',
    cityName: '重庆',
    seasons: [
      {
        name: '春季花粉期',
        startMonth: 3,
        endMonth: 5,
        peakMonth: 4,
        level: 3,
        mainAllergens: ['杨树', '柳树', '柏树'],
        tips: [
          '山区花粉浓度较高',
          '外出注意防护',
          '如有不适及时就医'
        ]
      },
      {
        name: '秋季花粉期',
        startMonth: 9,
        endMonth: 10,
        peakMonth: 9,
        level: 2,
        mainAllergens: ['蒿草', '豚草'],
        tips: [
          '秋季花粉浓度较低',
          '注意个人卫生'
        ]
      }
    ]
  },
  {
    cityCode: '510100',
    cityName: '成都',
    seasons: [
      {
        name: '春季花粉期',
        startMonth: 3,
        endMonth: 5,
        peakMonth: 4,
        level: 3,
        mainAllergens: ['杨树', '柏树', '桑树'],
        tips: [
          '春季湿度较大，花粉浓度中等',
          '外出建议佩戴口罩',
          '保持室内通风干燥'
        ]
      }
    ]
  },
  {
    cityCode: '320100',
    cityName: '南京',
    seasons: [
      {
        name: '春季花粉期',
        startMonth: 3,
        endMonth: 5,
        peakMonth: 4,
        level: 4,
        mainAllergens: ['悬铃木', '杨树', '柳树'],
        tips: [
          '梧桐大道注意防护',
          '春季花粉浓度较高',
          '建议提前准备防护用品'
        ]
      },
      {
        name: '秋季花粉期',
        startMonth: 9,
        endMonth: 10,
        peakMonth: 9,
        level: 3,
        mainAllergens: ['蒿草', '豚草'],
        tips: [
          '秋季花粉以草本为主',
          '避免前往草地'
        ]
      }
    ]
  },
  {
    cityCode: '330100',
    cityName: '杭州',
    seasons: [
      {
        name: '春季花粉期',
        startMonth: 3,
        endMonth: 5,
        peakMonth: 4,
        level: 3,
        mainAllergens: ['杨树', '柳树', '悬铃木'],
        tips: [
          '西湖周边花粉浓度较高',
          '外出注意防护',
          '如有不适及时就医'
        ]
      }
    ]
  },
  {
    cityCode: '610100',
    cityName: '西安',
    seasons: [
      {
        name: '春季花粉期',
        startMonth: 3,
        endMonth: 5,
        peakMonth: 4,
        level: 4,
        mainAllergens: ['杨树', '柳树', '榆树', '柏树'],
        tips: [
          '西北地区春季花粉浓度高',
          '建议提前准备抗过敏药物',
          '减少户外活动时间'
        ]
      },
      {
        name: '秋季花粉期',
        startMonth: 8,
        endMonth: 10,
        peakMonth: 9,
        level: 3,
        mainAllergens: ['蒿草', '豚草'],
        tips: [
          '秋季草本花粉浓度中等',
          '注意个人防护'
        ]
      }
    ]
  },
  {
    cityCode: '210100',
    cityName: '沈阳',
    seasons: [
      {
        name: '春季花粉期',
        startMonth: 4,
        endMonth: 6,
        peakMonth: 5,
        level: 4,
        mainAllergens: ['杨树', '柳树', '榆树', '桦树'],
        tips: [
          '东北地区花粉期较晚',
          '5月为高峰期',
          '外出建议佩戴口罩'
        ]
      },
      {
        name: '秋季花粉期',
        startMonth: 8,
        endMonth: 9,
        peakMonth: 8,
        level: 3,
        mainAllergens: ['蒿草', '豚草'],
        tips: [
          '秋季花粉期较短',
          '注意个人防护'
        ]
      }
    ]
  },
  {
    cityCode: '370100',
    cityName: '济南',
    seasons: [
      {
        name: '春季花粉期',
        startMonth: 3,
        endMonth: 5,
        peakMonth: 4,
        level: 3,
        mainAllergens: ['杨树', '柳树', '榆树'],
        tips: [
          '春季花粉浓度中等',
          '外出注意防护',
          '保持室内清洁'
        ]
      }
    ]
  },
  {
    cityCode: '340100',
    cityName: '合肥',
    seasons: [
      {
        name: '春季花粉期',
        startMonth: 3,
        endMonth: 5,
        peakMonth: 4,
        level: 3,
        mainAllergens: ['杨树', '柳树', '悬铃木'],
        tips: [
          '春季花粉浓度中等',
          '外出建议佩戴口罩',
          '如有不适及时就医'
        ]
      }
    ]
  },
  {
    cityCode: '430100',
    cityName: '长沙',
    seasons: [
      {
        name: '春季花粉期',
        startMonth: 3,
        endMonth: 5,
        peakMonth: 4,
        level: 3,
        mainAllergens: ['杨树', '柳树', '榕树'],
        tips: [
          '湖南春季湿度大',
          '花粉浓度中等',
          '注意个人防护'
        ]
      }
    ]
  },
  {
    cityCode: '350100',
    cityName: '福州',
    seasons: [
      {
        name: '春季花粉期',
        startMonth: 2,
        endMonth: 4,
        peakMonth: 3,
        level: 2,
        mainAllergens: ['榕树', '木棉', '桉树'],
        tips: [
          '南方沿海城市花粉浓度较低',
          '轻度过敏患者可正常活动',
          '注意个人卫生'
        ]
      }
    ]
  },
  {
    cityCode: '650100',
    cityName: '乌鲁木齐',
    seasons: [
      {
        name: '春季花粉期',
        startMonth: 4,
        endMonth: 6,
        peakMonth: 5,
        level: 4,
        mainAllergens: ['杨树', '榆树', '桦树'],
        tips: [
          '西北地区春季花粉浓度高',
          '花粉期较晚且持续时间长',
          '建议提前准备防护用品'
        ]
      },
      {
        name: '秋季花粉期',
        startMonth: 8,
        endMonth: 9,
        peakMonth: 8,
        level: 3,
        mainAllergens: ['蒿草', '藜科植物'],
        tips: [
          '秋季草本花粉为主',
          '避免前往草原地区'
        ]
      }
    ]
  }
]

/**
 * 根据城市名称查找花粉季节信息
 */
export function getPollenSeasonByCity(cityName: string): PollenSeasonInfo | null {
  for (let i = 0; i < POLLEN_SEASON_DATABASE.length; i++) {
    if (POLLEN_SEASON_DATABASE[i].cityName === cityName) {
      return POLLEN_SEASON_DATABASE[i]
    }
  }
  return null
}

/**
 * 获取所有支持的城市列表
 */
export function getSupportedCities(): string[] {
  const result: string[] = []
  for (let i = 0; i < POLLEN_SEASON_DATABASE.length; i++) {
    result.push(POLLEN_SEASON_DATABASE[i].cityName)
  }
  return result
}
