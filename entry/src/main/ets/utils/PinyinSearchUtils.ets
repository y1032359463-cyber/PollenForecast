/**
 * 拼音搜索工具类
 * 支持按拼音、首字母缩写搜索城市/区县
 */

import resourceManager from '@ohos.resourceManager'
import util from '@ohos.util'

export interface PinyinArea {
  name: string
  pinyin: string
  initial: string
  adcode: string
  level: string
}

let pinyinMap: PinyinArea[] = []

/**
 * 加载拼音映射表
 */
export async function loadPinyinMap(context: Context): Promise<void> {
  try {
    const resMgr = context.resourceManager
    const rawFile = await resMgr.getRawFileContent('pinyin_map.json')
    
    const uint8Array = new Uint8Array(rawFile.buffer)
    const decoder = new util.TextDecoder('utf-8')
    const jsonString = decoder.decodeWithStream(uint8Array)
    
    pinyinMap = JSON.parse(jsonString)
    console.info(`[PinyinSearchUtils] 加载完成，共 ${pinyinMap.length} 个区域`)
  } catch (error) {
    console.error(`[PinyinSearchUtils] 加载失败: ${JSON.stringify(error)}`)
    pinyinMap = []
  }
}

/**
 * 拼音搜索（支持多种匹配模式）
 * @param keyword 搜索关键词
 * @returns 匹配的区域列表
 */
export function searchByPinyin(keyword: string): PinyinArea[] {
  if (!keyword || !pinyinMap || pinyinMap.length === 0) {
    return []
  }
  
  const lowerKeyword = keyword.toLowerCase().trim()
  const results: PinyinArea[] = []
  
  for (const area of pinyinMap) {
    // 1. 中文名称匹配
    if (area.name.includes(keyword)) {
      results.push(area)
      continue
    }
    
    // 2. 完整拼音匹配
    if (area.pinyin.includes(lowerKeyword)) {
      results.push(area)
      continue
    }
    
    // 3. 首字母缩写匹配（使用 includes）
    if (area.initial.toLowerCase().includes(lowerKeyword)) {
      results.push(area)
      continue
    }
    
    // 4. 首字母缩写前缀匹配（如 "js" 可以匹配 "JSQ"）
    if (area.initial.toLowerCase().startsWith(lowerKeyword)) {
      results.push(area)
      continue
    }
    
    // 5. 拼音片段匹配（如 "luo" 可以匹配 "luoyangshi"）
    const pinyinSegments = area.pinyin.split(/(?=[A-Z])/)
    for (const segment of pinyinSegments) {
      if (segment.toLowerCase().startsWith(lowerKeyword)) {
        results.push(area)
        break
      }
    }
  }
  
  return results
}

/**
 * 按首字母分组搜索结果
 * @param areas 区域列表
 * @returns 按首字母分组的Map
 */
export function groupByInitial(areas: PinyinArea[]): Map<string, PinyinArea[]> {
  const grouped = new Map<string, PinyinArea[]>()
  
  for (const area of areas) {
    const initial = area.initial.charAt(0)
    if (!grouped.has(initial)) {
      grouped.set(initial, [])
    }
    grouped.get(initial)!.push(area)
  }
  
  return grouped
}

/**
 * 获取拼音映射表（供外部直接使用）
 */
export function getPinyinMap(): PinyinArea[] {
  return pinyinMap
}

/**
 * 根据adcode获取拼音信息
 */
export function getPinyinByAdcode(adcode: string): PinyinArea | null {
  for (const area of pinyinMap) {
    if (area.adcode === adcode) {
      return area
    }
  }
  return null
}
