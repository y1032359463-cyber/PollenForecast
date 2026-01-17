/**
 * 照片记录数据模型
 * 存储EXIF参数和用户笔记
 */

// UI风格枚举
export enum UIStyle {
  CARD = 'card',    // 卡片列表式（类Metapho）
  PARAM = 'param'   // 参数突出式（专业风）
}

// EXIF参数接口（分组结构 - 96字段）
export interface ExifData {
  // === P0 核心拍摄参数（必需字段）===
  aperture: string        // 光圈 f/2.8
  shutterSpeed: string    // 快门 1/125s
  iso: number             // ISO 400
  focalLength: string     // 焦距 50mm
  cameraMake: string      // 相机品牌
  cameraModel: string     // 相机型号
  lensModel: string       // 镜头型号
  dateTime: string        // 拍摄时间
  
  // === P1 常用进阶参数（可选字段）===
  exposureCompensation?: string  // 曝光补偿
  exposureMode?: string          // 曝光模式
  exposureProgram?: string       // 曝光程序
  meteringMode?: string          // 测光模式
  whiteBalance?: string          // 白平衡
  flash?: string                 // 闪光灯
  focalLengthIn35mm?: string     // 35mm等效焦距
  maxAperture?: string           // 最大光圈
  imageWidth?: number            // 图片宽度
  imageHeight?: number           // 图片高度
  orientation?: string           // 方向
  colorSpace?: string            // 色彩空间
  gpsLatitude?: number           // GPS纬度
  gpsLongitude?: number          // GPS经度
  gpsAltitude?: number           // GPS海拔
  
  // === P2 完整技术参数（扩展字段）===
  // 时间信息扩展
  dateTimeOriginal?: string      // 原始拍摄时间
  dateTimeDigitized?: string     // 数字化时间
  subSecTime?: string            // 秒的小数部分
  subSecTimeOriginal?: string    // 原始亚秒时间
  subSecTimeDigitized?: string   // 数字化亚秒时间
  
  // GPS扩展
  gpsLatitudeRef?: string        // GPS纬度参考
  gpsLongitudeRef?: string       // GPS经度参考
  gpsAltitudeRef?: string        // GPS海拔参考
  gpsTimeStamp?: string          // GPS时间戳
  gpsDateStamp?: string          // GPS日期戳
  gpsProcessingMethod?: string   // GPS处理方法
  gpsSpeed?: string              // GPS速度
  gpsImgDirection?: string       // GPS图像方向
  
  // 曝光控制扩展
  exposureTime?: string          // 曝光时间
  exposureIndex?: string         // 曝光指数
  flashEnergy?: string           // 闪光灯能量
  
  // 设备信息扩展
  lensMake?: string              // 镜头品牌
  lensSerialNumber?: string      // 镜头序列号
  bodySerialNumber?: string      // 机身序列号
  software?: string              // 处理软件
  exifVersion?: string           // EXIF版本
  flashpixVersion?: string       // FlashPix版本
  
  // 镜头参数扩展
  focalPlaneXResolution?: number // 焦平面X分辨率
  focalPlaneYResolution?: number // 焦平面Y分辨率
  focalPlaneResolutionUnit?: string  // 焦平面分辨率单位
  subjectDistance?: string       // 主体距离
  
  // 图像属性扩展
  imageLength?: number           // 图片长度
  componentsConfiguration?: string  // 分量配置
  compression?: string           // 压缩方式
  photometricInterpretation?: string  // 光度解释
  pixelXDimension?: number       // 像素X维度
  pixelYDimension?: number       // 像素Y维度
  bitsPerSample?: string         // 每样本位数
  samplesPerPixel?: string       // 每像素样本数
  
  // 图像处理扩展
  contrast?: string              // 对比度
  saturation?: string            // 饱和度
  sharpness?: string             // 锐度
  brightness?: string            // 亮度
  lightSource?: string           // 光源
  gainControl?: string           // 增益控制
  digitalZoomRatio?: string      // 数字变焦比
  sceneCaptureType?: string      // 场景捕获类型
  sceneType?: string             // 场景类型
  subjectDistanceRange?: string  // 主体距离范围
  customRendered?: string        // 自定义渲染
  sensingMethod?: string         // 感光方式
  
  // 元数据扩展
  imageDescription?: string      // 图片描述
  artist?: string                // 作者
  copyright?: string             // 版权
  userComment?: string           // 用户评论
  relatedSoundFile?: string      // 相关音频文件
  
  // 缩略图扩展
  thumbnailImageWidth?: number   // 缩略图宽度
  thumbnailImageHeight?: number  // 缩略图高度
  
  // 色彩科学扩展
  yCbCrPositioning?: string      // YCbCr定位
  xResolution?: number           // X分辨率
  yResolution?: number           // Y分辨率
  resolutionUnit?: string        // 分辨率单位
  transferFunction?: string      // 传输函数
  whitePoint?: string            // 白点
  primaryChromaticities?: string // 原色度
  yCbCrCoefficients?: string     // YCbCr系数
  referenceBlackWhite?: string   // 参考黑白值
  
  // 技术参数扩展
  spectalSensitivity?: string    // 光谱灵敏度
  isoSpeedRatings?: string       // ISO速率（备用）
  oecf?: string                  // 光电转换函数
  fileSource?: string            // 文件源
  cFAPattern?: string            // CFA图案
  deviceSettingDescription?: string  // 设备设置描述
  subjectLocation?: string       // 主体位置
  subjectArea?: string           // 主体区域
  makerNote?: string             // 制造商注释
  
  // === Phase 2扩展：DNG 1.4/1.6专有字段（P0 - 12个）===
  dngVersion?: string             // DNG版本 (e.g., "1.4.0.0")
  dngBackwardVersion?: string     // DNG向后兼容版本 (e.g., "1.1.0.0")
  uniqueCameraModel?: string      // 相机唯一标识 (e.g., "Nikon D800E")
  cameraSerialNumberDNG?: string  // 相机序列号-DNG专用 (区别于EXIF的bodySerialNumber)
  dngLensInfo?: string            // DNG镜头信息 (e.g., "35-35mm f/1.4-1.4")
  originalRawFilename?: string    // 原始RAW文件名 (e.g., "DSC_3070.NEF")
  baselineExposure?: number       // 基线曝光 (e.g., 0.35)
  baselineNoise?: number          // 基线噪点 (e.g., 0.6)
  baselineSharpness?: number      // 基线锐度 (e.g., 1.0)
  linearResponseLimit?: number    // 线性响应限制
  shadowScale?: number            // 阴影比例 (e.g., 1.0)
  previewColorSpace?: string      // 预览色彩空间 ("Gray Gamma 2.2" / "sRGB")
}

// 照片记录接口
export interface PhotoRecord {
  id: string              // 唯一ID (UUID)
  createTime: number      // 创建时间戳
  updateTime: number      // 更新时间戳
  exifData: ExifData      // EXIF数据
  
  // === 笔记相关（2025-12-25 首页重构扩展）===
  noteTitle: string       // 笔记标题（如"逆光人像心得"）
  note: string            // 笔记正文（扩展到500字）
  
  thumbnailPath?: string  // 缩略图文件路径（沙箱路径，专家推荐方案）
  thumbnail?: string      // 【已废弃】旧版Base64缩略图，保留向后兼容
  
  // === UI状态（不持久化）===
  isDeleting?: boolean    // 删除动画状态
}

// 用户偏好设置
export interface UserPreferences {
  uiStyle: UIStyle        // UI风格
  isFirstLaunch: boolean  // 是否首次启动
  lastBackupTime?: number // 上次备份时间
}

// 默认偏好设置
export const DEFAULT_PREFERENCES: UserPreferences = {
  uiStyle: UIStyle.CARD,
  isFirstLaunch: true
}

// 创建空的EXIF数据
export function createEmptyExifData(): ExifData {
  return {
    aperture: '',
    shutterSpeed: '',
    iso: 0,
    focalLength: '',
    cameraMake: '',
    cameraModel: '',
    lensModel: '',
    dateTime: ''
  }
}

// 生成UUID
export function generateUUID(): string {
  const timestamp = Date.now().toString(36)
  const randomPart = Math.random().toString(36).substring(2, 10)
  return `${timestamp}-${randomPart}`
}
