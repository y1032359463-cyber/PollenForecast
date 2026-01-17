/**
 * 首页 ViewModel
 * 管理首页的数据和业务逻辑
 */

import {
  PollenData,
  PollenLevel,
  PollenForecast,
  ProtectionAdvice,
  LocationInfo,
  getLevelColor,
  getLevelBgColor,
  getLevelText,
  getLevelEmoji
} from '../model/PollenModel';

/**
 * 首页状态
 */
export interface HomePageState {
  isLoading: boolean;              // 加载状态
  currentPollen: PollenData | null; // 当前花粉数据
  forecast: PollenForecast[];       // 7天预报
  advice: ProtectionAdvice | null;  // 防护建议
  errorMessage: string;             // 错误信息
  lastUpdateTime: string;           // 最后更新时间
}

/**
 * 首页 ViewModel
 */
export class HomeViewModel {
  private state: HomePageState;

  constructor() {
    this.state = {
      isLoading: false,
      currentPollen: null,
      forecast: [],
      advice: null,
      errorMessage: '',
      lastUpdateTime: ''
    };
  }

  /**
   * 获取当前状态
   */
  getState(): HomePageState {
    return this.state;
  }

  /**
   * 获取模拟的花粉数据（开发阶段使用）
   */
  getMockPollenData(): PollenData {
    return {
      level: PollenLevel.MODERATE,
      value: 65,
      pollenTypes: [
        {
          type: 'tree' as any,
          name: '树木花粉',
          level: PollenLevel.HIGH,
          value: 78,
          species: ['柏树', '杨树', '柳树']
        },
        {
          type: 'grass' as any,
          name: '草类花粉',
          level: PollenLevel.LOW,
          value: 35,
          species: ['禾本科', '牧草']
        },
        {
          type: 'weed' as any,
          name: '杂草花粉',
          level: PollenLevel.VERY_LOW,
          value: 20,
          species: ['蒿属', '藜科']
        }
      ],
      updateTime: this.getCurrentTimeString(),
      location: {
        city: '北京市',
        district: '海淀区',
        latitude: 39.9042,
        longitude: 116.4074
      }
    };
  }

  /**
   * 获取模拟的7天预报数据
   */
  getMockForecast(): PollenForecast[] {
    const forecast: PollenForecast[] = [];
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const today = new Date();

    for (let i = 0; i < 7; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);

      forecast.push({
        date: this.formatDate(date),
        dayOfWeek: i === 0 ? '今天' : (i === 1 ? '明天' : weekDays[date.getDay()]),
        level: this.getRandomLevel(),
        value: Math.floor(Math.random() * 100) + 20,
        highTemp: Math.floor(Math.random() * 10) + 15,
        lowTemp: Math.floor(Math.random() * 5) + 5,
        weather: this.getRandomWeather()
      });
    }

    return forecast;
  }

  /**
   * 根据等级获取防护建议
   */
  getProtectionAdvice(level: PollenLevel): ProtectionAdvice {
    const adviceMap: Record<PollenLevel, ProtectionAdvice> = {
      [PollenLevel.VERY_LOW]: {
        level: PollenLevel.VERY_LOW,
        title: '适宜外出',
        description: '花粉浓度很低，过敏风险极小，可以放心进行户外活动。',
        actions: [
          '可以正常进行户外运动',
          '开窗通风换气',
          '享受户外时光'
        ]
      },
      [PollenLevel.LOW]: {
        level: PollenLevel.LOW,
        title: '基本适宜',
        description: '花粉浓度较低，轻度过敏者稍加注意即可。',
        actions: [
          '轻度过敏者可随身携带口罩',
          '外出后注意洗手洗脸',
          '保持室内清洁'
        ]
      },
      [PollenLevel.MODERATE]: {
        level: PollenLevel.MODERATE,
        title: '注意防护',
        description: '花粉浓度中等，过敏者应做好防护措施。',
        actions: [
          '外出建议佩戴口罩',
          '减少上午10点至下午4点外出',
          '回家后及时更换衣物',
          '使用空气净化器'
        ]
      },
      [PollenLevel.HIGH]: {
        level: PollenLevel.HIGH,
        title: '减少外出',
        description: '花粉浓度较高，建议减少户外活动时间。',
        actions: [
          '尽量避免户外活动',
          '必须外出时佩戴N95口罩',
          '关闭门窗',
          '备好抗过敏药物',
          '使用鼻腔冲洗'
        ]
      },
      [PollenLevel.VERY_HIGH]: {
        level: PollenLevel.VERY_HIGH,
        title: '避免外出',
        description: '花粉浓度很高，强烈建议留在室内。',
        actions: [
          '尽量留在室内',
          '关闭所有门窗',
          '开启空气净化器',
          '按时服用抗过敏药物',
          '如有严重症状及时就医'
        ]
      }
    };

    return adviceMap[level];
  }

  // ========== 工具方法 ==========

  private getCurrentTimeString(): string {
    const now = new Date();
    return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
  }

  private formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  private getRandomLevel(): PollenLevel {
    const levels = [
      PollenLevel.VERY_LOW,
      PollenLevel.LOW,
      PollenLevel.MODERATE,
      PollenLevel.HIGH,
      PollenLevel.VERY_HIGH
    ];
    return levels[Math.floor(Math.random() * levels.length)];
  }

  private getRandomWeather(): string {
    const weathers = ['晴', '多云', '阴', '小雨', '晴转多云'];
    return weathers[Math.floor(Math.random() * weathers.length)];
  }
}

// 导出工具函数供页面使用
export { getLevelColor, getLevelBgColor, getLevelText, getLevelEmoji };
