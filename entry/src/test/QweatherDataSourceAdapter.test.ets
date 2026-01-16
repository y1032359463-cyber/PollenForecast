import { describe, beforeAll, afterAll, it, expect } from '@ohos/hypium'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { QweatherDataSourceAdapter } from '../main/ets/service/QweatherDataSourceAdapter'
import { DailyInfo } from '../main/ets/model/PollenModels'

/**
 * QweatherDailyIndex 测试接口（与源文件中的接口相同）
 */
interface QweatherDailyIndex {
  date: string
  type: string
  name: string
  level: string
  category: string
  text: string
}

/**
 * 测试用例接口
 */
interface CategoryTestCase {
  input: string
  expected: string
}

interface LevelTestCase {
  input: string
  expected: number
}

interface DailyInfoTestCase {
  input: QweatherDailyIndex
  expectedLevel: number
  expectedCategory: string
}

/**
 * QweatherDataSourceAdapter 测试包装类
 * 通过继承暴露私有方法进行测试
 */
class TestableQweatherAdapter extends QweatherDataSourceAdapter {
  name: string = '和风天气（测试）'
  
  testConvertCategoryToEnglish(category: string): string {
    return this.convertCategoryToEnglish(category)
  }
  
  testConvertLevelToValue(level: string): number {
    return this.convertLevelToValue(level)
  }
  
  testConvertDailyInfo(qweatherDaily: QweatherDailyIndex): DailyInfo {
    // 强制转换为受保护方法需要的内部接口
    // 由于结构相同，在 ArkTS 中需要确保定义一致
    const internalDaily = qweatherDaily as Object as QweatherDailyIndex
    return this.convertDailyInfo(internalDaily)
  }
  
  testExtractRecommendations(text: string): string[] {
    return this.extractRecommendations(text)
  }
}

export default function qweatherDataSourceAdapterTest() {
  describe('QweatherDataSourceAdapterTestSuite', () => {
    const adapter = new TestableQweatherAdapter()
    
    beforeAll(() => {
      hilog.info(0x0000, 'QweatherAdapterTest', '测试套件开始')
    })
    
    afterAll(() => {
      hilog.info(0x0000, 'QweatherAdapterTest', '测试套件结束')
    })
    
    describe('isAvailable_test', () => {
      it('isAvailable() 应该返回 true', 0, () => {
        hilog.info(0x0000, 'QweatherAdapterTest', '测试: isAvailable()')
        const result = adapter.isAvailable()
        expect(result).assertTrue()
      })
    })
    
    describe('convertCategoryToEnglish_test', () => {
      it('convertCategoryToEnglish("极不易发") 应该返回 "None"', 0, () => {
        const result = adapter.testConvertCategoryToEnglish('极不易发')
        hilog.info(0x0000, 'QweatherAdapterTest', 'convertCategoryToEnglish("极不易发") = %{public}s', result)
        expect(result).assertEqual('None')
      })
      
      it('convertCategoryToEnglish("不易发") 应该返回 "Low"', 0, () => {
        const result = adapter.testConvertCategoryToEnglish('不易发')
        hilog.info(0x0000, 'QweatherAdapterTest', 'convertCategoryToEnglish("不易发") = %{public}s', result)
        expect(result).assertEqual('Low')
      })
      
      it('convertCategoryToEnglish("较易发") 应该返回 "Moderate"', 0, () => {
        const result = adapter.testConvertCategoryToEnglish('较易发')
        hilog.info(0x0000, 'QweatherAdapterTest', 'convertCategoryToEnglish("较易发") = %{public}s', result)
        expect(result).assertEqual('Moderate')
      })
      
      it('convertCategoryToEnglish("易发") 应该返回 "High"', 0, () => {
        const result = adapter.testConvertCategoryToEnglish('易发')
        hilog.info(0x0000, 'QweatherAdapterTest', 'convertCategoryToEnglish("易发") = %{public}s', result)
        expect(result).assertEqual('High')
      })
      
      it('convertCategoryToEnglish("极易发") 应该返回 "Very High"', 0, () => {
        const result = adapter.testConvertCategoryToEnglish('极易发')
        hilog.info(0x0000, 'QweatherAdapterTest', 'convertCategoryToEnglish("极易发") = %{public}s', result)
        expect(result).assertEqual('Very High')
      })
      
      it('convertCategoryToEnglish("未知") 应该返回 "None"（默认值）', 0, () => {
        const result = adapter.testConvertCategoryToEnglish('未知')
        hilog.info(0x0000, 'QweatherAdapterTest', 'convertCategoryToEnglish("未知") = %{public}s', result)
        expect(result).assertEqual('None')
      })
    })
    
    describe('convertLevelToValue_test', () => {
      it('convertLevelToValue("1") 应该返回 0（极不易发）', 0, () => {
        const result = adapter.testConvertLevelToValue('1')
        hilog.info(0x0000, 'QweatherAdapterTest', 'convertLevelToValue("1") = %{public}d', result)
        expect(result).assertEqual(0)
      })
      
      it('convertLevelToValue("2") 应该返回 25（不易发）', 0, () => {
        const result = adapter.testConvertLevelToValue('2')
        hilog.info(0x0000, 'QweatherAdapterTest', 'convertLevelToValue("2") = %{public}d', result)
        expect(result).assertEqual(25)
      })
      
      it('convertLevelToValue("3") 应该返回 50（较易发）', 0, () => {
        const result = adapter.testConvertLevelToValue('3')
        hilog.info(0x0000, 'QweatherAdapterTest', 'convertLevelToValue("3") = %{public}d', result)
        expect(result).assertEqual(50)
      })
      
      it('convertLevelToValue("4") 应该返回 75（易发）', 0, () => {
        const result = adapter.testConvertLevelToValue('4')
        hilog.info(0x0000, 'QweatherAdapterTest', 'convertLevelToValue("4") = %{public}d', result)
        expect(result).assertEqual(75)
      })
      
      it('convertLevelToValue("5") 应该返回 100（极易发）', 0, () => {
        const result = adapter.testConvertLevelToValue('5')
        hilog.info(0x0000, 'QweatherAdapterTest', 'convertLevelToValue("5") = %{public}d', result)
        expect(result).assertEqual(100)
      })
      
      it('convertLevelToValue("0") 应该返回 0（默认值）', 0, () => {
        const result = adapter.testConvertLevelToValue('0')
        hilog.info(0x0000, 'QweatherAdapterTest', 'convertLevelToValue("0") = %{public}d', result)
        expect(result).assertEqual(0)
      })
    })
    
    describe('extractRecommendations_test', () => {
      it('extractRecommendations("今日花粉浓度极不易发") 应该返回 ["今日花粉浓度较低，可放心外出"]', 0, () => {
        const result = adapter.testExtractRecommendations('今日花粉浓度极不易发')
        hilog.info(0x0000, 'QweatherAdapterTest', 'extractRecommendations 结果数量: %{public}d', result.length)
        expect(result.length).assertLarger(0)
        expect(result[0]).assertEqual('今日花粉浓度较低，可放心外出')
      })
      
      it('extractRecommendations("花粉较易发") 应该返回建议减少外出的建议', 0, () => {
        const result = adapter.testExtractRecommendations('今日花粉较易发')
        hilog.info(0x0000, 'QweatherAdapterTest', 'extractRecommendations 结果数量: %{public}d', result.length)
        expect(result.length).assertLarger(0)
        expect(result[0]).assertEqual('建议易敏人群减少外出时间')
      })
      
      it('extractRecommendations("花粉极易发") 应该返回避免外出的建议', 0, () => {
        const result = adapter.testExtractRecommendations('今日花粉极易发')
        hilog.info(0x0000, 'QweatherAdapterTest', 'extractRecommendations 结果数量: %{public}d', result.length)
        expect(result.length).assertLarger(0)
        expect(result[0]).assertEqual('花粉浓度较高，易敏人群应避免外出')
      })
    })
    
    describe('convertDailyInfo_test', () => {
      it('convertDailyInfo(极不易发) 应该正确转换所有字段', 0, () => {
        const input: QweatherDailyIndex = {
          date: '2026-01-16',
          type: '1',
          name: '花粉过敏指数',
          level: '1',
          category: '极不易发',
          text: '今日花粉浓度极不易发'
        }
        
        const result = adapter.testConvertDailyInfo(input)
        
        hilog.info(0x0000, 'QweatherAdapterTest', 'convertDailyInfo - date: %{public}d-%{public}d-%{public}d', result.date.year, result.date.month, result.date.day)
        hilog.info(0x0000, 'QweatherAdapterTest', 'convertDailyInfo - value: %{public}d, category: %{public}s', result.pollenTypeInfo[0].indexInfo.value, result.pollenTypeInfo[0].indexInfo.category)
        
        expect(result.date.year).assertEqual(2026)
        expect(result.date.month).assertEqual(1)
        expect(result.date.day).assertEqual(16)
        expect(result.pollenTypeInfo[0].code).assertEqual('TOTAL')
        expect(result.pollenTypeInfo[0].displayName).assertEqual('综合花粉')
        expect(result.pollenTypeInfo[0].inSeason).assertFalse()
        expect(result.pollenTypeInfo[0].indexInfo.value).assertEqual(0)
        expect(result.pollenTypeInfo[0].indexInfo.category).assertEqual('None')
        expect(result.pollenTypeInfo[0].healthRecommendations.length).assertLarger(0)
      })
      
      it('convertDailyInfo(较易发) 应该正确转换并标记为 inSeason=true', 0, () => {
        const input: QweatherDailyIndex = {
          date: '2026-01-17',
          type: '1',
          name: '花粉过敏指数',
          level: '3',
          category: '较易发',
          text: '今日花粉较易发'
        }
        
        const result = adapter.testConvertDailyInfo(input)
        
        hilog.info(0x0000, 'QweatherAdapterTest', 'convertDailyInfo - value: %{public}d, inSeason: %{public}s', result.pollenTypeInfo[0].indexInfo.value, result.pollenTypeInfo[0].inSeason)
        
        expect(result.pollenTypeInfo[0].indexInfo.value).assertEqual(50)
        expect(result.pollenTypeInfo[0].indexInfo.category).assertEqual('Moderate')
        expect(result.pollenTypeInfo[0].inSeason).assertTrue()
      })
      
      it('convertDailyInfo(极易发) 应该正确转换高等级数据', 0, () => {
        const input: QweatherDailyIndex = {
          date: '2026-01-18',
          type: '1',
          name: '花粉过敏指数',
          level: '5',
          category: '极易发',
          text: '今日花粉极易发'
        }
        
        const result = adapter.testConvertDailyInfo(input)
        
        hilog.info(0x0000, 'QweatherAdapterTest', 'convertDailyInfo - value: %{public}d, category: %{public}s', result.pollenTypeInfo[0].indexInfo.value, result.pollenTypeInfo[0].indexInfo.category)
        
        expect(result.pollenTypeInfo[0].indexInfo.value).assertEqual(100)
        expect(result.pollenTypeInfo[0].indexInfo.category).assertEqual('Very High')
        expect(result.pollenTypeInfo[0].inSeason).assertTrue()
      })
      
      it('convertDailyInfo 应该生成空的 plantInfo 数组', 0, () => {
        const input: QweatherDailyIndex = {
          date: '2026-01-19',
          type: '1',
          name: '花粉过敏指数',
          level: '2',
          category: '不易发',
          text: '今日花粉浓度较低'
        }
        
        const result = adapter.testConvertDailyInfo(input)
        
        hilog.info(0x0000, 'QweatherAdapterTest', 'convertDailyInfo - plantInfo 长度: %{public}d', result.plantInfo.length)
        
        expect(result.plantInfo.length).assertEqual(0)
      })
    })
    
    describe('comprehensive_test', () => {
      it('完整流程测试：转换所有5个等级的数据', 0, () => {
        const levels: string[] = ['1', '2', '3', '4', '5']
        const categories: string[] = ['极不易发', '不易发', '较易发', '易发', '极易发']
        const expectedValues: number[] = [0, 25, 50, 75, 100]
        const expectedEnglishCategories: string[] = ['None', 'Low', 'Moderate', 'High', 'Very High']
        
        for (let i = 0; i < levels.length; i++) {
          const input: QweatherDailyIndex = {
            date: '2026-01-16',
            type: '1',
            name: '花粉过敏指数',
            level: levels[i],
            category: categories[i],
            text: `今日花粉${categories[i]}`
          }
          
          const result = adapter.testConvertDailyInfo(input)
          
          hilog.info(0x0000, 'QweatherAdapterTest', '等级 %{public}s: value=%{public}d, category=%{public}s', 
            levels[i], result.pollenTypeInfo[0].indexInfo.value, result.pollenTypeInfo[0].indexInfo.category)
          
          expect(result.pollenTypeInfo[0].indexInfo.value).assertEqual(expectedValues[i])
          expect(result.pollenTypeInfo[0].indexInfo.category).assertEqual(expectedEnglishCategories[i])
        }
      })
    })
  })
}
