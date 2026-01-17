/**
 * 鲁班尺计算核心模块
 * 包含鲁班尺（门公尺）和丁兰尺的计算逻辑
 */

// 吉凶结果接口
export interface LubanResult {
  majorWord: string      // 大字（如：财、病、离...）
  minorWord: string      // 小字细分（如：财德、宝库...）
  isGood: boolean        // 是否吉利
  meaning: string        // 含义解释
  color: string          // 显示颜色 (red=吉, black=凶)
}

// 丁兰尺结果接口
export interface DinglanResult {
  majorWord: string      // 大字
  minorWord: string      // 小字细分
  isGood: boolean        // 是否吉利
  meaning: string        // 含义解释
  color: string          // 显示颜色
}

// 综合测量结果
export interface MeasureResult {
  inputMm: number        // 输入毫米数
  gongchi: number        // 公尺（厘米）
  lubanchi: number       // 鲁班尺（尺）
  dinglanchi: number     // 丁兰尺（尺）
  yingchi: number        // 英尺（英寸）
  lubanResult: LubanResult
  dinglanResult: DinglanResult
}

/**
 * 鲁班尺计算器类
 */
export class LubanCalculator {
  // ==================== 常量定义 ====================

  // 单位换算常量
  static readonly MM_PER_CM: number = 10                    // 1厘米 = 10毫米
  static readonly CM_PER_LUBAN: number = 42.9              // 1鲁班尺 = 42.9厘米
  static readonly CM_PER_DINGLAN: number = 38.78           // 1丁兰尺 = 38.78厘米
  static readonly CM_PER_INCH: number = 2.54               // 1英寸 = 2.54厘米
  static readonly INCH_PER_FOOT: number = 12               // 1英尺 = 12英寸

  // 鲁班尺每大格的厘米数（42.9 / 8 = 5.3625）
  static readonly LUBAN_MAJOR_UNIT: number = 42.9 / 8
  // 鲁班尺每小格的厘米数（每大格分4小格）
  static readonly LUBAN_MINOR_UNIT: number = 42.9 / 32

  // 丁兰尺每大格的厘米数（38.78 / 10 = 3.878）
  static readonly DINGLAN_MAJOR_UNIT: number = 38.78 / 10
  // 丁兰尺每小格的厘米数（每大格分4小格）
  static readonly DINGLAN_MINOR_UNIT: number = 38.78 / 40

  // ==================== 鲁班尺数据 ====================

  // 鲁班尺八字（大格）：吉凶顺序
  static readonly LUBAN_MAJOR_WORDS: string[] = ['财', '病', '离', '义', '官', '劫', '害', '本']

  // 鲁班尺大格吉凶判断（true=吉，false=凶）
  static readonly LUBAN_MAJOR_GOOD: boolean[] = [true, false, false, true, true, false, false, true]

  // 鲁班尺小格细分（每大格4个小格）
  static readonly LUBAN_MINOR_WORDS: string[][] = [
    ['财德', '宝库', '六合', '迎福'],    // 财
    ['退财', '公事', '牢执', '孤寡'],    // 病
    ['长库', '劫财', '官鬼', '失脱'],    // 离
    ['添丁', '益利', '贵子', '大吉'],    // 义
    ['顺科', '横财', '进益', '富贵'],    // 官
    ['死别', '退口', '离乡', '财失'],    // 劫
    ['灾至', '死绝', '病临', '口舌'],    // 害
    ['财至', '登科', '进宝', '兴旺']     // 本
  ]

  // 鲁班尺小格吉凶（对应上面的细分）
  static readonly LUBAN_MINOR_GOOD: boolean[][] = [
    [true, true, true, true],           // 财 - 全吉
    [false, false, false, false],       // 病 - 全凶
    [false, false, false, false],       // 离 - 全凶
    [true, true, true, true],           // 义 - 全吉
    [true, true, true, true],           // 官 - 全吉
    [false, false, false, false],       // 劫 - 全凶
    [false, false, false, false],       // 害 - 全凶
    [true, true, true, true]            // 本 - 全吉
  ]

  // 鲁班尺大格含义
  static readonly LUBAN_MAJOR_MEANINGS: string[] = [
    '财：吉，指钱财、才能。',
    '病：凶，指伤灾病患及不利。',
    '离：凶，指六亲离散分开。',
    '义：吉，指符合正义及道德规范。',
    '官：吉，指有官运。',
    '劫：凶，指遭抢夺、胁迫。',
    '害：凶，指祸患之意。',
    '本：吉，指事物的本位或本体。'
  ]

  // 鲁班尺小格含义
  static readonly LUBAN_MINOR_MEANINGS: string[][] = [
    ['财德：指在财、德善、功德方面有表现。', '宝库：比喻可得或储藏珍贵物品。', '六合：合和美满，六合为天地四方。', '迎福：迎接福气，福禄之意。'],
    ['退财：损财、破财之意。', '公事：多指因公家的事如贪污、受贿等。', '牢执：指牢狱之灾。', '孤寡：指有乏嗣、丧偶之患。'],
    ['长库：古有监狱之说。', '劫财：破耗、耗损财物之意。', '官鬼：指有官煞引起之事。', '失脱：物品失落、人离散之意。'],
    ['添丁：古时生男曰添丁。', '益利：增加了财资利禄。', '贵子：日后能显贵的子嗣。', '大吉：吉祥吉利。'],
    ['顺科：顺利通过考试而获中。', '横财：意外之财。', '进益：收益进益、有钱财之意。', '富贵：有财有势，既富且贵。'],
    ['死别：即永别。', '退口：指有孝服之事。', '离乡：背井离乡之意。', '财失：财物损失或丢失。'],
    ['灾至：灾殃祸患到来。', '死绝：死得干干净净。', '病临：疾病来临。', '口舌：争执争吵。'],
    ['财至：即财到。', '登科：考试被录取。', '进宝：招财进宝。', '兴旺：兴盛旺盛。']
  ]

  // ==================== 丁兰尺数据 ====================

  // 丁兰尺十字（大格）
  static readonly DINGLAN_MAJOR_WORDS: string[] = ['丁', '害', '旺', '苦', '义', '官', '死', '兴', '失', '财']

  // 丁兰尺大格吉凶
  static readonly DINGLAN_MAJOR_GOOD: boolean[] = [true, false, true, false, true, false, false, true, false, true]

  // 丁兰尺小格细分
  static readonly DINGLAN_MINOR_WORDS: string[][] = [
    ['福星', '及第', '财旺', '登科'],     // 丁
    ['口舌', '病临', '死绝', '灾至'],     // 害
    ['天德', '喜事', '进宝', '纳福'],     // 旺
    ['失脱', '官鬼', '劫财', '无嗣'],     // 苦
    ['大吉', '财旺', '益利', '天库'],     // 义
    ['富贵', '进宝', '横财', '顺科'],     // 官 (部分吉，但整体归凶)
    ['离乡', '死别', '退丁', '失财'],     // 死
    ['登科', '贵子', '添丁', '兴旺'],     // 兴
    ['孤寡', '牢执', '公事', '退财'],     // 失
    ['迎福', '六合', '进宝', '财德']      // 财
  ]

  // 丁兰尺小格吉凶
  static readonly DINGLAN_MINOR_GOOD: boolean[][] = [
    [true, true, true, true],           // 丁 - 全吉
    [false, false, false, false],       // 害 - 全凶
    [true, true, true, true],           // 旺 - 全吉
    [false, false, false, false],       // 苦 - 全凶
    [true, true, true, true],           // 义 - 全吉
    [true, true, true, true],           // 官 - 细分吉，但大格凶
    [false, false, false, false],       // 死 - 全凶
    [true, true, true, true],           // 兴 - 全吉
    [false, false, false, false],       // 失 - 全凶
    [true, true, true, true]            // 财 - 全吉
  ]

  // 丁兰尺大格含义
  static readonly DINGLAN_MAJOR_MEANINGS: string[] = [
    '丁：吉，旺丁，添人进口之意。',
    '害：凶，主灾害、祸患。',
    '旺：吉，兴旺发达之意。',
    '苦：凶，主辛苦劳累。',
    '义：吉，主仁义道德。',
    '官：凶，主官非诉讼（丁兰尺中官属凶）。',
    '死：凶，主死亡、绝后。',
    '兴：吉，主兴隆昌盛。',
    '失：凶，主失落、散失。',
    '财：吉，主财运亨通。'
  ]

  // 丁兰尺小格含义
  static readonly DINGLAN_MINOR_MEANINGS: string[][] = [
    ['福星：福星高照。', '及第：考中功名。', '财旺：财运旺盛。', '登科：科举中榜。'],
    ['口舌：招惹是非。', '病临：疾病缠身。', '死绝：绝嗣之意。', '灾至：灾祸降临。'],
    ['天德：上天庇佑。', '喜事：喜事临门。', '进宝：招财进宝。', '纳福：承受福气。'],
    ['失脱：失去脱落。', '官鬼：官司缠身。', '劫财：财被劫去。', '无嗣：没有后代。'],
    ['大吉：吉祥如意。', '财旺：财运兴旺。', '益利：利益增加。', '天库：天赐财库。'],
    ['富贵：富裕显贵。', '进宝：财宝进门。', '横财：意外之财。', '顺科：考试顺利。'],
    ['离乡：远离家乡。', '死别：生死离别。', '退丁：人丁减少。', '失财：钱财丢失。'],
    ['登科：考取功名。', '贵子：生贵子。', '添丁：添加人口。', '兴旺：家业兴旺。'],
    ['孤寡：孤独寡居。', '牢执：牢狱之灾。', '公事：官府之事。', '退财：破财损财。'],
    ['迎福：迎接福气。', '六合：六合和顺。', '进宝：财宝进门。', '财德：财富与德行。']
  ]

  // ==================== 计算方法 ====================

  /**
   * 毫米转厘米
   */
  static mmToCm(mm: number): number {
    return mm / LubanCalculator.MM_PER_CM
  }

  /**
   * 厘米转鲁班尺
   */
  static cmToLuban(cm: number): number {
    return cm / LubanCalculator.CM_PER_LUBAN
  }

  /**
   * 厘米转丁兰尺
   */
  static cmToDinglan(cm: number): number {
    return cm / LubanCalculator.CM_PER_DINGLAN
  }

  /**
   * 厘米转英寸
   */
  static cmToInch(cm: number): number {
    return cm / LubanCalculator.CM_PER_INCH
  }

  /**
   * 计算鲁班尺结果
   * @param cm 厘米数
   * @returns 鲁班尺吉凶结果
   */
  static calculateLuban(cm: number): LubanResult {
    // 计算在整个周期中的位置（厘米）
    const posInCycle = cm % LubanCalculator.CM_PER_LUBAN

    // 计算大格索引（0-7）
    const majorIndex = Math.floor(posInCycle / LubanCalculator.LUBAN_MAJOR_UNIT) % 8

    // 计算小格在大格中的位置（0-3）
    const posInMajor = posInCycle % LubanCalculator.LUBAN_MAJOR_UNIT
    const minorIndex = Math.floor(posInMajor / LubanCalculator.LUBAN_MINOR_UNIT) % 4

    const majorWord = LubanCalculator.LUBAN_MAJOR_WORDS[majorIndex]
    const minorWord = LubanCalculator.LUBAN_MINOR_WORDS[majorIndex][minorIndex]
    const isGood = LubanCalculator.LUBAN_MINOR_GOOD[majorIndex][minorIndex]
    const meaning = LubanCalculator.LUBAN_MINOR_MEANINGS[majorIndex][minorIndex]

    return {
      majorWord: majorWord,
      minorWord: minorWord,
      isGood: isGood,
      meaning: meaning,
      color: isGood ? '#D4380D' : '#434343'  // 红色=吉，深灰=凶
    }
  }

  /**
   * 计算丁兰尺结果
   * @param cm 厘米数
   * @returns 丁兰尺吉凶结果
   */
  static calculateDinglan(cm: number): DinglanResult {
    // 计算在整个周期中的位置（厘米）
    const posInCycle = cm % LubanCalculator.CM_PER_DINGLAN

    // 计算大格索引（0-9）
    const majorIndex = Math.floor(posInCycle / LubanCalculator.DINGLAN_MAJOR_UNIT) % 10

    // 计算小格在大格中的位置（0-3）
    const posInMajor = posInCycle % LubanCalculator.DINGLAN_MAJOR_UNIT
    const minorIndex = Math.floor(posInMajor / LubanCalculator.DINGLAN_MINOR_UNIT) % 4

    const majorWord = LubanCalculator.DINGLAN_MAJOR_WORDS[majorIndex]
    const minorWord = LubanCalculator.DINGLAN_MINOR_WORDS[majorIndex][minorIndex]
    const isGood = LubanCalculator.DINGLAN_MINOR_GOOD[majorIndex][minorIndex]
    const meaning = LubanCalculator.DINGLAN_MINOR_MEANINGS[majorIndex][minorIndex]

    return {
      majorWord: majorWord,
      minorWord: minorWord,
      isGood: isGood,
      meaning: meaning,
      color: isGood ? '#D4380D' : '#434343'
    }
  }

  /**
   * 综合测量计算
   * @param mm 毫米数
   * @returns 综合测量结果
   */
  static measure(mm: number): MeasureResult {
    const cm = LubanCalculator.mmToCm(mm)

    return {
      inputMm: mm,
      gongchi: cm,
      lubanchi: LubanCalculator.cmToLuban(cm),
      dinglanchi: LubanCalculator.cmToDinglan(cm),
      yingchi: LubanCalculator.cmToInch(cm),
      lubanResult: LubanCalculator.calculateLuban(cm),
      dinglanResult: LubanCalculator.calculateDinglan(cm)
    }
  }
}
