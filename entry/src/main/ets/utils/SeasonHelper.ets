/**
 * 花粉季节判断工具
 * 用于判断当前是否为花粉季，以及获取季节性内容
 */

/**
 * 季节类型
 */
export enum SeasonType {
  SPRING_POLLEN = 'spring_pollen',    // 春季花粉季 (3-5月)
  SUMMER = 'summer',                   // 夏季 (6-7月)
  AUTUMN_POLLEN = 'autumn_pollen',    // 秋季花粉季 (8-10月)
  WINTER = 'winter'                    // 冬季 (11-2月)
}

/**
 * 非花粉季提示内容
 */
export interface OffSeasonContent {
  title: string           // 标题
  description: string     // 描述
  tips: string[]          // 提示列表
  nextSeasonHint: string  // 下一花粉季提示
}

/**
 * 花粉季节工具类
 */
export class SeasonHelper {
  
  /**
   * 获取当前季节类型
   */
  static getCurrentSeason(): SeasonType {
    const month = new Date().getMonth() + 1  // 1-12
    
    if (month >= 3 && month <= 5) {
      return SeasonType.SPRING_POLLEN
    } else if (month >= 6 && month <= 7) {
      return SeasonType.SUMMER
    } else if (month >= 8 && month <= 10) {
      return SeasonType.AUTUMN_POLLEN
    } else {
      return SeasonType.WINTER
    }
  }
  
  /**
   * 判断当前是否为花粉季
   */
  static isPollenSeason(): boolean {
    const season = SeasonHelper.getCurrentSeason()
    return season === SeasonType.SPRING_POLLEN || season === SeasonType.AUTUMN_POLLEN
  }
  
  /**
   * 获取当前月份
   */
  static getCurrentMonth(): number {
    return new Date().getMonth() + 1
  }
  
  /**
   * 获取非花粉季显示内容
   */
  static getOffSeasonContent(): OffSeasonContent {
    const season = SeasonHelper.getCurrentSeason()
    const month = SeasonHelper.getCurrentMonth()
    
    if (season === SeasonType.WINTER) {
      return {
        title: '冬季花粉休眠期',
        description: '当前为冬季，大部分地区花粉浓度极低，是过敏患者的舒适期。',
        tips: [
          '🌿 可适当进行户外活动，呼吸新鲜空气',
          '🏠 趁此时期进行家庭大扫除，清除积尘',
          '💪 加强锻炼，增强体质，为花粉季做准备',
          '📅 提前关注明年花粉季预报'
        ],
        nextSeasonHint: '下一个花粉季预计在3月开始（春季花粉季）'
      }
    } else if (season === SeasonType.SUMMER) {
      return {
        title: '夏季过渡期',
        description: '夏季花粉浓度相对较低，但部分地区仍有草本植物花粉。',
        tips: [
          '🌾 注意草地花粉，避免在草坪久留',
          '☀️ 高温天气注意防暑，减少正午外出',
          '💨 雷雨天气后花粉浓度可能升高',
          '🔔 8月秋季花粉季即将来临，提前准备'
        ],
        nextSeasonHint: '秋季花粉季预计在8月开始（蒿草、豚草高发）'
      }
    }
    
    // 默认返回（花粉季时不应调用此方法）
    return {
      title: '花粉监测中',
      description: '正在获取花粉数据...',
      tips: ['请稍候...'],
      nextSeasonHint: ''
    }
  }
  
  /**
   * 获取花粉季防护要点
   */
  static getPollenSeasonTips(): string[] {
    const season = SeasonHelper.getCurrentSeason()
    
    if (season === SeasonType.SPRING_POLLEN) {
      return [
        '🌳 春季主要花粉：柏树、杨树、柳树、榆树',
        '😷 外出佩戴防护口罩和护目镜',
        '🚿 回家后及时洗脸、洗手、清洗鼻腔',
        '🪟 花粉高峰期（上午10点-下午4点）关闭门窗',
        '👕 外出衣物回家后及时更换',
        '🌬️ 使用空气净化器净化室内空气'
      ]
    } else if (season === SeasonType.AUTUMN_POLLEN) {
      return [
        '🌿 秋季主要花粉：蒿草、豚草、葎草',
        '😷 秋季花粉致敏性更强，务必做好防护',
        '🚗 开车时关闭车窗，使用内循环',
        '🧺 避免在室外晾晒衣物和床品',
        '🏥 症状严重时及时就医',
        '💊 遵医嘱提前使用预防性药物'
      ]
    }
    
    return []
  }
  
  /**
   * 获取季节描述文字
   */
  static getSeasonDescription(): string {
    const season = SeasonHelper.getCurrentSeason()
    
    switch (season) {
      case SeasonType.SPRING_POLLEN:
        return '春季花粉季（3-5月）'
      case SeasonType.SUMMER:
        return '夏季过渡期（6-7月）'
      case SeasonType.AUTUMN_POLLEN:
        return '秋季花粉季（8-10月）'
      case SeasonType.WINTER:
        return '冬季休眠期（11-2月）'
      default:
        return ''
    }
  }
}
