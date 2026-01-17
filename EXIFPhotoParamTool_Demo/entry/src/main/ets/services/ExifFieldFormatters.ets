/**
 * EXIF字段格式化工具模块
 * 负责将原始EXIF值转换为用户友好的显示格式
 */

/**
 * 格式化光圈值
 * 输入: "f/2.0" 或 "2.8" 或 "28/10"
 * 输出: "f/2.8"
 */
export function formatAperture(value: string): string {
  try {
    if (value.startsWith('f/')) {
      return value
    }
    if (value.includes('/')) {
      const parts = value.split('/')
      const num = parseFloat(parts[0]) / parseFloat(parts[1])
      return `f/${num.toFixed(1)}`
    }
    return `f/${parseFloat(value).toFixed(1)}`
  } catch {
    return value
  }
}

/**
 * 格式化快门速度
 * 输入: "1/709 sec." 或 "0.008" 或 "1/125"
 * 输出: "1/125s" 或 "2s"
 */
export function formatShutterSpeed(value: string): string {
  try {
    if (value.includes('sec.')) {
      return value.replace(' sec.', 's')
    }
    if (value.includes('/')) {
      return `${value}s`
    }
    const speed = parseFloat(value)
    if (speed >= 1) {
      return `${speed.toFixed(1)}s`
    } else {
      const reciprocal = Math.round(1 / speed)
      return `1/${reciprocal}s`
    }
  } catch {
    return value
  }
}

/**
 * 格式化焦距
 * 输入: "6.3 mm" 或 "50" 或 "50/1"
 * 输出: "50mm"
 */
export function formatFocalLength(value: string): string {
  try {
    if (value.includes('mm')) {
      return value.replace(' mm', 'mm')
    }
    if (value.includes('/')) {
      const parts = value.split('/')
      const focal = parseFloat(parts[0]) / parseFloat(parts[1])
      return `${Math.round(focal)}mm`
    }
    return `${Math.round(parseFloat(value))}mm`
  } catch {
    return value
  }
}

/**
 * 格式化日期时间
 * 输入: "2024:12:14 15:30:45"
 * 输出: "2024/12/14 15:30"
 */
export function formatDateTime(value: string): string {
  try {
    const formatted = value.replace(/:/g, '-').substring(0, 16)
    return formatted.replace('-', '/').replace('-', '/')
  } catch {
    return value
  }
}

/**
 * 解析GPS坐标
 * 输入格式可能是度分秒 "39,54,20.00,N"
 * 输出: 十进制度数 39.905556
 */
export function parseGpsCoordinate(value: string): number {
  try {
    if (!value.includes(',')) {
      return parseFloat(value)
    }
    const parts = value.split(',')
    const degrees = parseFloat(parts[0])
    const minutes = parseFloat(parts[1])
    const seconds = parseFloat(parts[2])
    const direction = parts[3]
    
    let decimal = degrees + (minutes / 60) + (seconds / 3600)
    if (direction === 'S' || direction === 'W') {
      decimal = -decimal
    }
    return decimal
  } catch {
    return 0
  }
}

/** 格式化曝光模式 */
export function formatExposureMode(value: string): string {
  const modes: Record<string, string> = {
    '0': '自动曝光',
    '1': '手动曝光',
    '2': '自动包围曝光'
  }
  return modes[value] || value
}

/** 格式化曝光程序 */
export function formatExposureProgram(value: string): string {
  const programs: Record<string, string> = {
    '0': '未定义',
    '1': '手动',
    '2': '程序自动',
    '3': '光圈优先',
    '4': '快门优先',
    '5': '创意程序',
    '6': '运动模式',
    '7': '人像模式',
    '8': '风景模式'
  }
  return programs[value] || value
}

/** 格式化测光模式 */
export function formatMeteringMode(value: string): string {
  const modes: Record<string, string> = {
    '0': '未知',
    '1': '平均测光',
    '2': '中央重点',
    '3': '点测光',
    '4': '多点测光',
    '5': '评价测光',
    '6': '局部测光'
  }
  return modes[value] || value
}

/** 格式化闪光灯 */
export function formatFlash(value: string): string {
  const num = parseInt(value)
  if (num === 0) return '未闪光'
  if (num === 1) return '闪光'
  if (num & 0x1) return '闪光'
  return '未闪光'
}

/** 格式化增益控制 */
export function formatGainControl(value: number): string {
  const controls: Record<number, string> = {
    0: '无',
    1: '低增益提升',
    2: '高增益提升',
    3: '低增益降低',
    4: '高增益降低'
  }
  return controls[value] || String(value)
}

/** 格式化主体距离范围 */
export function formatSubjectDistRange(value: number): string {
  const ranges: Record<number, string> = {
    0: '未知',
    1: '微距',
    2: '近景',
    3: '远景'
  }
  return ranges[value] || String(value)
}

/** 格式化场景捕获类型 */
export function formatSceneCaptureType(value: number): string {
  const types: Record<number, string> = {
    0: '标准',
    1: '风景',
    2: '人像',
    3: '夜景'
  }
  return types[value] || String(value)
}

/** 格式化方向 */
export function formatOrientation(value: string): string {
  const orientations: Record<string, string> = {
    '1': '正常',
    '2': '水平翻转',
    '3': '旋转180°',
    '4': '垂直翻转',
    '5': '顺时针90°+水平翻转',
    '6': '顺时针90°',
    '7': '逆时针90°+水平翻转',
    '8': '逆时针90°'
  }
  return orientations[value] || value
}
