/**
 * EXIF解析服务
 * 采用渐进式加载策略：Image Kit快速显示 → Native C++后台补充
 */
import { image } from '@kit.ImageKit'
import { fileIo } from '@kit.CoreFileKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { ExifData, createEmptyExifData } from '../models/PhotoRecord'
// Phase 2优化：标准命名导入（CodeGenie推荐）
import { parseExifFromPath, parseExifFromBuffer, NativeExifResult } from 'exifparser'
// B方案拆分：格式化函数独立模块
import {
  formatAperture,
  formatShutterSpeed,
  formatFocalLength,
  formatDateTime,
  parseGpsCoordinate,
  formatExposureMode,
  formatExposureProgram,
  formatMeteringMode,
  formatFlash,
  formatGainControl,
  formatSubjectDistRange,
  formatSceneCaptureType,
  formatOrientation
} from './ExifFieldFormatters'

// RAW解析模式（保留类型定义以兼容旧代码）
export type RawParseMode = 'embedded_jpeg' | 'libraw'

export class ExifParserService {
  /**
   * 检测是否为RAW格式文件
   * 支持主流相机厂商的RAW格式
   */
  isRawFormat(uri: string): boolean {
    const lowerUri = uri.toLowerCase()
    return lowerUri.endsWith('.dng') ||   // Adobe DNG (通用标准)
           lowerUri.endsWith('.cr2') ||   // Canon (旧款)
           lowerUri.endsWith('.cr3') ||   // Canon (新款)
           lowerUri.endsWith('.nef') ||   // Nikon
           lowerUri.endsWith('.arw') ||   // Sony
           lowerUri.endsWith('.raf') ||   // Fujifilm
           lowerUri.endsWith('.orf') ||   // Olympus / OM System
           lowerUri.endsWith('.rw2') ||   // Panasonic
           lowerUri.endsWith('.pef') ||   // Pentax
           lowerUri.endsWith('.srw') ||   // Samsung
           lowerUri.endsWith('.3fr') ||   // Hasselblad
           lowerUri.endsWith('.iiq') ||   // Phase One
           lowerUri.endsWith('.rwl') ||   // Leica
           lowerUri.endsWith('.dcs') ||   // Kodak
           lowerUri.endsWith('.kdc') ||   // Kodak
           lowerUri.endsWith('.erf') ||   // Epson
           lowerUri.endsWith('.mef') ||   // Mamiya
           lowerUri.endsWith('.mos') ||   // Leaf
           lowerUri.endsWith('.nrw')      // Nikon (Coolpix)
  }

  /**
   * 渐进式加载 - Phase 1: 快速解析基础字段（~100ms）
   * 使用Image Kit PropertyKey获取14个核心参数
   * 注意：必须使用fd方式，createImageSource(uri)不支持file://media/格式
   * @param photoUri FilePicker返回的照片URI
   * @returns 基础ExifData（适合立即显示）
   */
  async parseExifQuick(photoUri: string): Promise<ExifData> {
    let file: fileIo.File | null = null
    let imageSource: image.ImageSource | null = null
    
    try {
      // 必须用fd方式：createImageSource(uri)不支持FilePicker返回的file://media/格式
      file = fileIo.openSync(photoUri, fileIo.OpenMode.READ_ONLY)
      imageSource = image.createImageSource(file.fd)
      
      // 仅提取核心字段（速度优先）
      return await this.extractExifData(imageSource)
    } catch (e) {
      hilog.error(0x0021, 'EXIF', '[EXIF-Quick] 快速解析失败:' + e)
      return this.createEmptyWithCurrentTime()
    } finally {
      if (imageSource) {
        try { imageSource.release() } catch (e) { /* ignore */ }
      }
      if (file) {
        try { fileIo.closeSync(file) } catch (e) { /* ignore */ }
      }
    }
  }

  /**
   * 渐进式加载 - Phase 2: 后台解析高级字段（~2.5s）
   * RAW格式使用双通道合并策略：Native + Image Kit
   * @param photoUri FilePicker返回的照片URI
   * @param sandboxPath 沙箱路径（Native C++需要）
   * @returns 完整ExifData（包含RAW专属字段 + 通用字段）
   */
  async parseExifAdvanced(photoUri: string, sandboxPath?: string): Promise<ExifData> {
    // RAW格式：双通道合并策略（修复35→70+字段问题）
    if (this.isRawFormat(photoUri)) {
      hilog.info(0x0021, 'EXIF', '[EXIF-Advanced] 检测到RAW格式，启用双通道解析...')
      
      // 通道1: Native C++解析RAW专属字段（35+字段）
      const nativeData = await this.parseRawByNative(photoUri, sandboxPath)
      
      // 通道2: Image Kit解析通用字段（14+字段）
      let imageKitData: ExifData
      try {
        imageKitData = await this.parseExifQuick(photoUri)
        hilog.info(0x0021, 'EXIF', '[EXIF-Advanced] Image Kit通道成功')
      } catch (e) {
        hilog.warn(0x0021, 'EXIF', '[EXIF-Advanced] Image Kit通道失败，仅使用Native数据')
        return nativeData
      }
      
      // 双通道数据合并（Native优先，Image Kit补充）
      const merged = this.mergeExifData(imageKitData, nativeData)
      hilog.info(0x0021, 'EXIF', '[EXIF-Advanced] 双通道合并完成')
      return merged
    }
    
    // 普通格式：仍使用快速解析（无需高级字段）
    return await this.parseExifQuick(photoUri)
  }

  /**
   * 【已废弃】混合解析策略（保留向后兼容）
   * 新代码请使用 parseExifQuick + parseExifAdvanced
   */
  async parseExif(photoUri: string, sandboxPath?: string): Promise<ExifData> {
    // 检测RAW格式，使用Native解析
    if (this.isRawFormat(photoUri)) {
      hilog.info(0x0021, 'EXIF', '[EXIF] 检测到RAW格式文件，使用Native解析...')
      return await this.parseRawByNative(photoUri, sandboxPath)
    }

    // 普通格式：策略1 - fd方式（速度快）
    try {
      hilog.info(0x0021, 'EXIF', '[EXIF] 尝试fd方式解析...')
      const result = await this.parseExifByFd(photoUri)
      // 检查是否成功获取到核心字段
      if (result.iso > 0 || result.aperture !== '' || result.cameraModel !== '') {
        hilog.info(0x0021, 'EXIF', '[EXIF] fd方式解析成功')
        return result
      }
      hilog.info(0x0021, 'EXIF', '[EXIF] fd方式未获取到有效数据，尝试沙箱方式...')
    } catch (e) {
      hilog.warn(0x0021, 'EXIF', '[EXIF] fd方式解析失败:' + e)
    }

    // 策略2：降级到沙箱路径方式
    if (sandboxPath) {
      try {
        hilog.info(0x0021, 'EXIF', '[EXIF] 尝试沙箱路径解析...')
        const result = await this.parseExifBySandbox(sandboxPath)
        hilog.info(0x0021, 'EXIF', '[EXIF] 沙箱方式解析成功')
        return result
      } catch (e) {
        hilog.error(0x0021, 'EXIF', '[EXIF] 沙箱方式解析失败:' + e)
      }
    }

    // 都失败则返回空数据
    hilog.warn(0x0021, 'EXIF', '[EXIF] 所有解析方式均失败，返回空数据')
    return this.createEmptyWithCurrentTime()
  }

  /**
   * 合并基础数据和高级数据（CodeGenie推荐模式）
   * Native C++数据优先，但需验证有效性
   * ArkTS限制：不支持Object.assign/spread，需手动复制所有字段
   */
  mergeExifData(basic: ExifData, advanced: ExifData): ExifData {
    // 先复制basic的所有非空字段到merged
    const merged = this.copyExifData(basic)
    
    // === Native字段优先覆盖（完整35字段） ===
    
    // 基础拍摄参数（P0核心）
    if (advanced.aperture && advanced.aperture !== '') merged.aperture = advanced.aperture
    if (advanced.shutterSpeed && advanced.shutterSpeed !== '') merged.shutterSpeed = advanced.shutterSpeed
    if (advanced.iso > 0) merged.iso = advanced.iso
    if (advanced.focalLength && advanced.focalLength !== '') merged.focalLength = advanced.focalLength
    if (advanced.focalLengthIn35mm && advanced.focalLengthIn35mm !== '') merged.focalLengthIn35mm = advanced.focalLengthIn35mm
    
    // 相机信息
    if (advanced.cameraMake && advanced.cameraMake !== '') merged.cameraMake = advanced.cameraMake
    if (advanced.cameraModel && advanced.cameraModel !== '') merged.cameraModel = advanced.cameraModel
    if (advanced.software && advanced.software !== '') merged.software = advanced.software
    if (advanced.bodySerialNumber && advanced.bodySerialNumber !== '') merged.bodySerialNumber = advanced.bodySerialNumber
    
    // 镜头信息
    if (advanced.lensModel && advanced.lensModel !== '') merged.lensModel = advanced.lensModel
    if (advanced.lensMake && advanced.lensMake !== '') merged.lensMake = advanced.lensMake
    if (advanced.lensSerialNumber && advanced.lensSerialNumber !== '') merged.lensSerialNumber = advanced.lensSerialNumber
    if (advanced.maxAperture && advanced.maxAperture !== '') merged.maxAperture = advanced.maxAperture
    
    // 时间信息
    if (advanced.dateTime && advanced.dateTime !== '') merged.dateTime = advanced.dateTime
    if (advanced.dateTimeDigitized && advanced.dateTimeDigitized !== '') merged.dateTimeDigitized = advanced.dateTimeDigitized
    if (advanced.subSecTimeOriginal && advanced.subSecTimeOriginal !== '') merged.subSecTimeOriginal = advanced.subSecTimeOriginal
    if (advanced.subSecTimeDigitized && advanced.subSecTimeDigitized !== '') merged.subSecTimeDigitized = advanced.subSecTimeDigitized
    
    // 分辨率参数
    if (advanced.resolutionUnit && advanced.resolutionUnit !== '') merged.resolutionUnit = advanced.resolutionUnit
    if (advanced.focalPlaneXResolution && advanced.focalPlaneXResolution > 0) merged.focalPlaneXResolution = advanced.focalPlaneXResolution
    if (advanced.focalPlaneYResolution && advanced.focalPlaneYResolution > 0) merged.focalPlaneYResolution = advanced.focalPlaneYResolution
    if (advanced.focalPlaneResolutionUnit && advanced.focalPlaneResolutionUnit !== '') merged.focalPlaneResolutionUnit = advanced.focalPlaneResolutionUnit
    
    // 图像属性
    if (advanced.imageWidth && advanced.imageWidth > 0) merged.imageWidth = advanced.imageWidth
    if (advanced.imageHeight && advanced.imageHeight > 0) merged.imageHeight = advanced.imageHeight
    if (advanced.orientation && advanced.orientation !== '') merged.orientation = advanced.orientation
    if (advanced.compression && advanced.compression !== '') merged.compression = advanced.compression
    if (advanced.photometricInterpretation && advanced.photometricInterpretation !== '') merged.photometricInterpretation = advanced.photometricInterpretation
    if (advanced.bitsPerSample && advanced.bitsPerSample !== '') merged.bitsPerSample = advanced.bitsPerSample
    if (advanced.samplesPerPixel && advanced.samplesPerPixel !== '') merged.samplesPerPixel = advanced.samplesPerPixel
    
    // 曝光控制
    if (advanced.exposureProgram && advanced.exposureProgram !== '') merged.exposureProgram = advanced.exposureProgram
    if (advanced.meteringMode && advanced.meteringMode !== '') merged.meteringMode = advanced.meteringMode
    if (advanced.exposureMode && advanced.exposureMode !== '') merged.exposureMode = advanced.exposureMode
    
    // 白平衡与闪光灯
    if (advanced.flash && advanced.flash !== '') merged.flash = advanced.flash
    if (advanced.whiteBalance && advanced.whiteBalance !== '') merged.whiteBalance = advanced.whiteBalance
    
    // 图像调整
    if (advanced.contrast && advanced.contrast !== '') merged.contrast = advanced.contrast
    if (advanced.saturation && advanced.saturation !== '') merged.saturation = advanced.saturation
    if (advanced.sharpness && advanced.sharpness !== '') merged.sharpness = advanced.sharpness
    
    // 元数据
    if (advanced.exifVersion && advanced.exifVersion !== '') merged.exifVersion = advanced.exifVersion
    if (advanced.sensingMethod && advanced.sensingMethod !== '') merged.sensingMethod = advanced.sensingMethod
    
    // GPS扩展字段（Image Kit可能提供）
    if (advanced.gpsLatitude !== undefined) merged.gpsLatitude = advanced.gpsLatitude
    if (advanced.gpsLongitude !== undefined) merged.gpsLongitude = advanced.gpsLongitude
    if (advanced.gpsAltitude !== undefined) merged.gpsAltitude = advanced.gpsAltitude
    if (advanced.gpsLatitudeRef) merged.gpsLatitudeRef = advanced.gpsLatitudeRef
    if (advanced.gpsLongitudeRef) merged.gpsLongitudeRef = advanced.gpsLongitudeRef
    
    // === DNG 1.4/1.6专有字段（P0 - 12个）===
    if (advanced.dngVersion) merged.dngVersion = advanced.dngVersion
    if (advanced.dngBackwardVersion) merged.dngBackwardVersion = advanced.dngBackwardVersion
    if (advanced.uniqueCameraModel) merged.uniqueCameraModel = advanced.uniqueCameraModel
    if (advanced.cameraSerialNumberDNG) merged.cameraSerialNumberDNG = advanced.cameraSerialNumberDNG
    if (advanced.dngLensInfo) merged.dngLensInfo = advanced.dngLensInfo
    if (advanced.originalRawFilename) merged.originalRawFilename = advanced.originalRawFilename
    if (advanced.baselineExposure !== undefined) merged.baselineExposure = advanced.baselineExposure
    if (advanced.baselineNoise !== undefined) merged.baselineNoise = advanced.baselineNoise
    if (advanced.baselineSharpness !== undefined) merged.baselineSharpness = advanced.baselineSharpness
    if (advanced.linearResponseLimit !== undefined) merged.linearResponseLimit = advanced.linearResponseLimit
    if (advanced.shadowScale !== undefined) merged.shadowScale = advanced.shadowScale
    if (advanced.previewColorSpace) merged.previewColorSpace = advanced.previewColorSpace
    
    return merged
  }

  /**
   * 深拷贝ExifData对象（ArkTS兼容方式）
   * 避免使用Object.assign/spread等受限API
   */
  private copyExifData(source: ExifData): ExifData {
    const target = createEmptyExifData()
    
    // 基础参数
    target.aperture = source.aperture
    target.shutterSpeed = source.shutterSpeed
    target.iso = source.iso
    target.focalLength = source.focalLength
    
    // 相机信息
    target.cameraMake = source.cameraMake
    target.cameraModel = source.cameraModel
    target.lensModel = source.lensModel
    if (source.lensMake) target.lensMake = source.lensMake
    if (source.lensSerialNumber) target.lensSerialNumber = source.lensSerialNumber
    if (source.bodySerialNumber) target.bodySerialNumber = source.bodySerialNumber
    
    // 时间信息
    target.dateTime = source.dateTime
    if (source.dateTimeOriginal) target.dateTimeOriginal = source.dateTimeOriginal
    if (source.dateTimeDigitized) target.dateTimeDigitized = source.dateTimeDigitized
    if (source.subSecTime) target.subSecTime = source.subSecTime
    if (source.subSecTimeOriginal) target.subSecTimeOriginal = source.subSecTimeOriginal
    if (source.subSecTimeDigitized) target.subSecTimeDigitized = source.subSecTimeDigitized
    
    // GPS信息
    if (source.gpsLatitude !== undefined) target.gpsLatitude = source.gpsLatitude
    if (source.gpsLongitude !== undefined) target.gpsLongitude = source.gpsLongitude
    if (source.gpsAltitude !== undefined) target.gpsAltitude = source.gpsAltitude
    if (source.gpsLatitudeRef) target.gpsLatitudeRef = source.gpsLatitudeRef
    if (source.gpsLongitudeRef) target.gpsLongitudeRef = source.gpsLongitudeRef
    if (source.gpsAltitudeRef) target.gpsAltitudeRef = source.gpsAltitudeRef
    if (source.gpsTimeStamp) target.gpsTimeStamp = source.gpsTimeStamp
    if (source.gpsDateStamp) target.gpsDateStamp = source.gpsDateStamp
    if (source.gpsProcessingMethod) target.gpsProcessingMethod = source.gpsProcessingMethod
    if (source.gpsSpeed) target.gpsSpeed = source.gpsSpeed
    if (source.gpsImgDirection) target.gpsImgDirection = source.gpsImgDirection
    
    // 曝光控制
    if (source.exposureCompensation) target.exposureCompensation = source.exposureCompensation
    if (source.exposureMode) target.exposureMode = source.exposureMode
    if (source.exposureProgram) target.exposureProgram = source.exposureProgram
    if (source.exposureTime) target.exposureTime = source.exposureTime
    if (source.exposureIndex) target.exposureIndex = source.exposureIndex
    if (source.meteringMode) target.meteringMode = source.meteringMode
    if (source.whiteBalance) target.whiteBalance = source.whiteBalance
    if (source.flash) target.flash = source.flash
    if (source.flashEnergy) target.flashEnergy = source.flashEnergy
    
    // 镜头详情
    if (source.maxAperture) target.maxAperture = source.maxAperture
    if (source.focalLengthIn35mm) target.focalLengthIn35mm = source.focalLengthIn35mm
    if (source.focalPlaneXResolution) target.focalPlaneXResolution = source.focalPlaneXResolution
    if (source.focalPlaneYResolution) target.focalPlaneYResolution = source.focalPlaneYResolution
    if (source.focalPlaneResolutionUnit) target.focalPlaneResolutionUnit = source.focalPlaneResolutionUnit
    if (source.subjectDistance) target.subjectDistance = source.subjectDistance
    
    // 图像属性
    if (source.imageWidth) target.imageWidth = source.imageWidth
    if (source.imageHeight) target.imageHeight = source.imageHeight
    if (source.imageLength) target.imageLength = source.imageLength
    if (source.orientation) target.orientation = source.orientation
    if (source.colorSpace) target.colorSpace = source.colorSpace
    if (source.componentsConfiguration) target.componentsConfiguration = source.componentsConfiguration
    if (source.compression) target.compression = source.compression
    if (source.photometricInterpretation) target.photometricInterpretation = source.photometricInterpretation
    if (source.pixelXDimension) target.pixelXDimension = source.pixelXDimension
    if (source.pixelYDimension) target.pixelYDimension = source.pixelYDimension
    if (source.bitsPerSample) target.bitsPerSample = source.bitsPerSample
    if (source.samplesPerPixel) target.samplesPerPixel = source.samplesPerPixel
    
    // 图像处理
    if (source.contrast) target.contrast = source.contrast
    if (source.saturation) target.saturation = source.saturation
    if (source.sharpness) target.sharpness = source.sharpness
    if (source.brightness) target.brightness = source.brightness
    if (source.lightSource) target.lightSource = source.lightSource
    if (source.gainControl) target.gainControl = source.gainControl
    if (source.digitalZoomRatio) target.digitalZoomRatio = source.digitalZoomRatio
    if (source.sceneCaptureType) target.sceneCaptureType = source.sceneCaptureType
    if (source.sceneType) target.sceneType = source.sceneType
    if (source.subjectDistanceRange) target.subjectDistanceRange = source.subjectDistanceRange
    if (source.customRendered) target.customRendered = source.customRendered
    if (source.sensingMethod) target.sensingMethod = source.sensingMethod
    
    // 元数据
    if (source.software) target.software = source.software
    if (source.exifVersion) target.exifVersion = source.exifVersion
    if (source.flashpixVersion) target.flashpixVersion = source.flashpixVersion
    if (source.imageDescription) target.imageDescription = source.imageDescription
    if (source.artist) target.artist = source.artist
    if (source.copyright) target.copyright = source.copyright
    if (source.userComment) target.userComment = source.userComment
    if (source.relatedSoundFile) target.relatedSoundFile = source.relatedSoundFile
    
    // 缩略图
    if (source.thumbnailImageWidth) target.thumbnailImageWidth = source.thumbnailImageWidth
    if (source.thumbnailImageHeight) target.thumbnailImageHeight = source.thumbnailImageHeight
    
    // 其他
    if (source.yCbCrPositioning) target.yCbCrPositioning = source.yCbCrPositioning
    if (source.xResolution) target.xResolution = source.xResolution
    if (source.yResolution) target.yResolution = source.yResolution
    if (source.resolutionUnit) target.resolutionUnit = source.resolutionUnit
    if (source.subjectArea) target.subjectArea = source.subjectArea
    if (source.spectalSensitivity) target.spectalSensitivity = source.spectalSensitivity
    if (source.fileSource) target.fileSource = source.fileSource
    if (source.cFAPattern) target.cFAPattern = source.cFAPattern
    if (source.whitePoint) target.whitePoint = source.whitePoint
    if (source.primaryChromaticities) target.primaryChromaticities = source.primaryChromaticities
    if (source.yCbCrCoefficients) target.yCbCrCoefficients = source.yCbCrCoefficients
    if (source.referenceBlackWhite) target.referenceBlackWhite = source.referenceBlackWhite
    if (source.transferFunction) target.transferFunction = source.transferFunction
    
    // === DNG专有字段（12个）===
    if (source.dngVersion) target.dngVersion = source.dngVersion
    if (source.dngBackwardVersion) target.dngBackwardVersion = source.dngBackwardVersion
    if (source.uniqueCameraModel) target.uniqueCameraModel = source.uniqueCameraModel
    if (source.cameraSerialNumberDNG) target.cameraSerialNumberDNG = source.cameraSerialNumberDNG
    if (source.dngLensInfo) target.dngLensInfo = source.dngLensInfo
    if (source.originalRawFilename) target.originalRawFilename = source.originalRawFilename
    if (source.baselineExposure !== undefined) target.baselineExposure = source.baselineExposure
    if (source.baselineNoise !== undefined) target.baselineNoise = source.baselineNoise
    if (source.baselineSharpness !== undefined) target.baselineSharpness = source.baselineSharpness
    if (source.linearResponseLimit !== undefined) target.linearResponseLimit = source.linearResponseLimit
    if (source.shadowScale !== undefined) target.shadowScale = source.shadowScale
    if (source.previewColorSpace) target.previewColorSpace = source.previewColorSpace
    
    return target
  }

  /**
   * Native C++方式解析RAW（专业版）
   * 使用自研的EXIF解析器，直接解析TIFF/DNG二进制结构
   * 支持读取ExifIFD中的核心拍摄参数
   */
  private async parseRawByNative(photoUri: string, sandboxPath?: string): Promise<ExifData> {
    const exifData = createEmptyExifData()
    
    try {
      // === CodeGenie验证步骤1：模块加载状态检测 ===
      hilog.error(0x0021, 'EXIF', `[EXIF-Native-Check] parseExifFromPath类型: ${typeof parseExifFromPath}`)
      
      // 模块预检查（CodeGenie建议）
      if (!parseExifFromPath) {
        hilog.error(0x0021, 'EXIF', '[EXIF-Native] Native模块方法未注册，降级到ArkTS方式')
        return await this.parseRawByThumbnail(photoUri, sandboxPath)
      }
      
      // 确定解析路径（优先使用沙箱路径）
      const targetPath = sandboxPath || photoUri
      hilog.info(0x0021, 'EXIF', `[EXIF-Native] 开始解析: ${targetPath}`)
      
      // 调用Native解析（类型自动推断，避免ArkTS结构化类型错误）
      const nativeResult = parseExifFromPath(targetPath)
      
      if (!nativeResult.success) {
        hilog.error(0x0021, 'EXIF', `[EXIF-Native] 解析失败: ${nativeResult.errorMessage}`)
        // 降级到ArkTS方式
        return await this.parseRawByThumbnail(photoUri, sandboxPath)
      }
      
      // 转换Native结果到ExifData
      exifData.aperture = nativeResult.aperture || ''
      exifData.shutterSpeed = nativeResult.shutterSpeed || ''
      exifData.iso = nativeResult.iso || 0
      exifData.focalLength = nativeResult.focalLength || ''
      exifData.focalLengthIn35mm = nativeResult.focalLength35mm > 0 ? `${nativeResult.focalLength35mm}mm` : ''
      
      exifData.cameraMake = nativeResult.cameraMake || ''
      exifData.cameraModel = nativeResult.cameraModel || ''
      exifData.lensModel = nativeResult.lensModel || ''
      exifData.lensMake = nativeResult.lensMake || ''
      exifData.lensSerialNumber = nativeResult.lensSerialNumber || ''
      
      exifData.dateTime = nativeResult.dateTimeOriginal || nativeResult.dateTime || ''
      exifData.software = nativeResult.software || ''
      
      exifData.imageWidth = nativeResult.imageWidth || nativeResult.pixelXDimension || 0
      exifData.imageHeight = nativeResult.imageHeight || nativeResult.pixelYDimension || 0
      exifData.orientation = formatOrientation(String(nativeResult.orientation || 1))
      
      exifData.exposureProgram = formatExposureProgram(String(nativeResult.exposureProgram || 0))
      exifData.meteringMode = formatMeteringMode(String(nativeResult.meteringMode || 0))
      exifData.flash = formatFlash(String(nativeResult.flash || 0))
      exifData.whiteBalance = nativeResult.whiteBalance === 0 ? '自动' : '手动'
      exifData.exposureMode = formatExposureMode(String(nativeResult.exposureMode || 0))
      
      if (nativeResult.exposureBias !== 0) {
        const bias = nativeResult.exposureBias
        exifData.exposureCompensation = `${bias >= 0 ? '+' : ''}${bias.toFixed(1)} EV`
      }
      
      if (nativeResult.maxAperture > 0) {
        exifData.maxAperture = `f/${nativeResult.maxAperture.toFixed(1)}`
      }
      
      exifData.colorSpace = nativeResult.colorSpace === 1 ? 'sRGB' : (nativeResult.colorSpace === 65535 ? 'Uncalibrated' : String(nativeResult.colorSpace))
      exifData.contrast = nativeResult.contrast === 0 ? '标准' : (nativeResult.contrast === 1 ? '低' : '高')
      exifData.saturation = nativeResult.saturation === 0 ? '标准' : (nativeResult.saturation === 1 ? '低' : '高')
      exifData.sharpness = nativeResult.sharpness === 0 ? '标准' : (nativeResult.sharpness === 1 ? '柔和' : '锐利')
      
      // GPS信息
      if (nativeResult.hasGPS) {
        let lat: number = nativeResult.gpsLatitude
        if (nativeResult.gpsLatitudeRef === 'S') lat = -lat
        exifData.gpsLatitude = lat
        exifData.gpsLatitudeRef = nativeResult.gpsLatitudeRef
        
        let lon: number = nativeResult.gpsLongitude
        if (nativeResult.gpsLongitudeRef === 'W') lon = -lon
        exifData.gpsLongitude = lon
        exifData.gpsLongitudeRef = nativeResult.gpsLongitudeRef
        
        exifData.gpsAltitude = nativeResult.gpsAltitude
        
        // GPS扩展字段
        if (nativeResult.gpsTimeStamp) exifData.gpsTimeStamp = nativeResult.gpsTimeStamp
        if (nativeResult.gpsDateStamp) exifData.gpsDateStamp = nativeResult.gpsDateStamp
        if (nativeResult.gpsSpeed > 0) exifData.gpsSpeed = `${nativeResult.gpsSpeed.toFixed(1)} km/h`
        if (nativeResult.gpsImgDirection > 0) exifData.gpsImgDirection = `${nativeResult.gpsImgDirection.toFixed(1)}°`
      }
      
      // 时间扩展字段
      if (nativeResult.dateTimeDigitized) exifData.dateTimeDigitized = formatDateTime(nativeResult.dateTimeDigitized)
      if (nativeResult.subSecTime) exifData.subSecTime = nativeResult.subSecTime
      if (nativeResult.subSecTimeOriginal) exifData.subSecTimeOriginal = nativeResult.subSecTimeOriginal
      if (nativeResult.subSecTimeDigitized) exifData.subSecTimeDigitized = nativeResult.subSecTimeDigitized
      
      // 镜头扩展字段
      if (nativeResult.subjectDistance > 0) exifData.subjectDistance = `${nativeResult.subjectDistance.toFixed(2)}m`
      
      // 分辨率参数
      if (nativeResult.xResolution > 0) exifData.xResolution = nativeResult.xResolution
      if (nativeResult.yResolution > 0) exifData.yResolution = nativeResult.yResolution
      if (nativeResult.resolutionUnit > 0) {
        exifData.resolutionUnit = nativeResult.resolutionUnit === 2 ? '英寸' : (nativeResult.resolutionUnit === 3 ? '厘米' : String(nativeResult.resolutionUnit))
      }
      if (nativeResult.focalPlaneXResolution > 0) exifData.focalPlaneXResolution = nativeResult.focalPlaneXResolution
      if (nativeResult.focalPlaneYResolution > 0) exifData.focalPlaneYResolution = nativeResult.focalPlaneYResolution
      if (nativeResult.focalPlaneResolutionUnit > 0) exifData.focalPlaneResolutionUnit = String(nativeResult.focalPlaneResolutionUnit)
      
      // 图像属性扩展
      if (nativeResult.compression > 0) exifData.compression = String(nativeResult.compression)
      if (nativeResult.photometricInterpretation > 0) exifData.photometricInterpretation = String(nativeResult.photometricInterpretation)
      if (nativeResult.imageDescription) exifData.imageDescription = nativeResult.imageDescription
      if (nativeResult.userComment) exifData.userComment = nativeResult.userComment
      if (nativeResult.bitsPerSample > 0) exifData.bitsPerSample = String(nativeResult.bitsPerSample)
      if (nativeResult.samplesPerPixel > 0) exifData.samplesPerPixel = String(nativeResult.samplesPerPixel)
      if (nativeResult.componentsConfiguration) exifData.componentsConfiguration = nativeResult.componentsConfiguration
      if (nativeResult.yCbCrPositioning > 0) exifData.yCbCrPositioning = String(nativeResult.yCbCrPositioning)
      
      // 其他元数据
      if (nativeResult.exifVersion) exifData.exifVersion = nativeResult.exifVersion
      if (nativeResult.flashpixVersion) exifData.flashpixVersion = nativeResult.flashpixVersion
      if (nativeResult.lightSource > 0) exifData.lightSource = String(nativeResult.lightSource)
      if (nativeResult.brightness !== 0) exifData.brightness = `${nativeResult.brightness.toFixed(2)} EV`
      if (nativeResult.sensingMethod > 0) exifData.sensingMethod = String(nativeResult.sensingMethod)
      if (nativeResult.relatedSoundFile) exifData.relatedSoundFile = nativeResult.relatedSoundFile
      
      // === 新增字段映射（扩展至96字段）===
      // 机身序列号
      if (nativeResult.bodySerialNumber) exifData.bodySerialNumber = nativeResult.bodySerialNumber
      
      // 图像处理扩展
      if (nativeResult.gainControl > 0) exifData.gainControl = formatGainControl(nativeResult.gainControl)
      if (nativeResult.digitalZoomRatio > 0) exifData.digitalZoomRatio = `${nativeResult.digitalZoomRatio.toFixed(2)}x`
      if (nativeResult.sceneType > 0) exifData.sceneType = nativeResult.sceneType === 1 ? '直接拍摄' : String(nativeResult.sceneType)
      if (nativeResult.subjectDistanceRange > 0) exifData.subjectDistanceRange = formatSubjectDistRange(nativeResult.subjectDistanceRange)
      if (nativeResult.customRendered > 0) exifData.customRendered = nativeResult.customRendered === 0 ? '正常' : '自定义'
      if (nativeResult.sceneCaptureType > 0) exifData.sceneCaptureType = formatSceneCaptureType(nativeResult.sceneCaptureType)
      if (nativeResult.exposureIndex > 0) exifData.exposureIndex = `${nativeResult.exposureIndex.toFixed(2)}`
      if (nativeResult.cFAPattern) exifData.cFAPattern = nativeResult.cFAPattern
      
      // 闪光灯扩展
      if (nativeResult.flashEnergy > 0) exifData.flashEnergy = `${nativeResult.flashEnergy.toFixed(1)} BCPS`
      
      // 文件/设备扩展
      if (nativeResult.fileSource > 0) exifData.fileSource = nativeResult.fileSource === 3 ? 'DSC' : String(nativeResult.fileSource)
      
      // 主体信息
      if (nativeResult.subjectLocation) exifData.subjectLocation = nativeResult.subjectLocation
      if (nativeResult.subjectArea) exifData.subjectArea = nativeResult.subjectArea
      
      // 色彩科学扩展
      if (nativeResult.whitePoint) exifData.whitePoint = nativeResult.whitePoint
      if (nativeResult.primaryChromaticities) exifData.primaryChromaticities = nativeResult.primaryChromaticities
      if (nativeResult.yCbCrCoefficients) exifData.yCbCrCoefficients = nativeResult.yCbCrCoefficients
      if (nativeResult.referenceBlackWhite) exifData.referenceBlackWhite = nativeResult.referenceBlackWhite
      if (nativeResult.transferFunction) exifData.transferFunction = nativeResult.transferFunction
      
      // 光谱扩展
      if (nativeResult.spectralSensitivity) exifData.spectalSensitivity = nativeResult.spectralSensitivity
      if (nativeResult.oecf) exifData.oecf = nativeResult.oecf
      
      // 制造商私有
      if (nativeResult.makerNote) exifData.makerNote = nativeResult.makerNote
      
      // 作者版权
      if (nativeResult.artist) exifData.artist = nativeResult.artist
      if (nativeResult.copyright) exifData.copyright = nativeResult.copyright
      
      // === Phase 2扩展：DNG 1.4/1.6专有字段（P0 - 12个）===
      if (nativeResult.dngVersion) exifData.dngVersion = nativeResult.dngVersion
      if (nativeResult.dngBackwardVersion) exifData.dngBackwardVersion = nativeResult.dngBackwardVersion
      if (nativeResult.uniqueCameraModel) exifData.uniqueCameraModel = nativeResult.uniqueCameraModel
      if (nativeResult.cameraSerialNumberDNG) exifData.cameraSerialNumberDNG = nativeResult.cameraSerialNumberDNG
      if (nativeResult.dngLensInfo) exifData.dngLensInfo = nativeResult.dngLensInfo
      if (nativeResult.originalRawFilename) exifData.originalRawFilename = nativeResult.originalRawFilename
      if (nativeResult.baselineExposure !== 0) exifData.baselineExposure = nativeResult.baselineExposure
      if (nativeResult.baselineNoise !== 0) exifData.baselineNoise = nativeResult.baselineNoise
      if (nativeResult.baselineSharpness !== 0) exifData.baselineSharpness = nativeResult.baselineSharpness
      if (nativeResult.linearResponseLimit !== 0) exifData.linearResponseLimit = nativeResult.linearResponseLimit
      if (nativeResult.shadowScale !== 0) exifData.shadowScale = nativeResult.shadowScale
      if (nativeResult.previewColorSpace) exifData.previewColorSpace = nativeResult.previewColorSpace
      
      // === 详细字段统计日志 ===
      let fieldCount = 0
      let populatedFields: string[] = []
      
      // 基础拍摄参数
      if (nativeResult.aperture) { fieldCount++; populatedFields.push('aperture') }
      if (nativeResult.shutterSpeed) { fieldCount++; populatedFields.push('shutterSpeed') }
      if (nativeResult.iso > 0) { fieldCount++; populatedFields.push('iso') }
      if (nativeResult.focalLength) { fieldCount++; populatedFields.push('focalLength') }
      if (nativeResult.focalLength35mm > 0) { fieldCount++; populatedFields.push('focalLength35mm') }
      
      // 相机信息
      if (nativeResult.cameraMake) { fieldCount++; populatedFields.push('cameraMake') }
      if (nativeResult.cameraModel) { fieldCount++; populatedFields.push('cameraModel') }
      if (nativeResult.software) { fieldCount++; populatedFields.push('software') }
      
      // 镜头信息
      if (nativeResult.lensModel) { fieldCount++; populatedFields.push('lensModel') }
      if (nativeResult.lensMake) { fieldCount++; populatedFields.push('lensMake') }
      if (nativeResult.lensSerialNumber) { fieldCount++; populatedFields.push('lensSerialNumber') }
      if (nativeResult.subjectDistance > 0) { fieldCount++; populatedFields.push('subjectDistance') }
      
      // 时间信息
      if (nativeResult.dateTime || nativeResult.dateTimeOriginal) { fieldCount++; populatedFields.push('dateTime') }
      if (nativeResult.dateTimeDigitized) { fieldCount++; populatedFields.push('dateTimeDigitized') }
      if (nativeResult.subSecTime) { fieldCount++; populatedFields.push('subSecTime') }
      if (nativeResult.subSecTimeOriginal) { fieldCount++; populatedFields.push('subSecTimeOriginal') }
      if (nativeResult.subSecTimeDigitized) { fieldCount++; populatedFields.push('subSecTimeDigitized') }
      
      // GPS信息
      if (nativeResult.hasGPS) {
        fieldCount += 3
        populatedFields.push('gpsLatitude', 'gpsLongitude', 'gpsAltitude')
        if (nativeResult.gpsTimeStamp) { fieldCount++; populatedFields.push('gpsTimeStamp') }
        if (nativeResult.gpsDateStamp) { fieldCount++; populatedFields.push('gpsDateStamp') }
        if (nativeResult.gpsSpeed > 0) { fieldCount++; populatedFields.push('gpsSpeed') }
        if (nativeResult.gpsImgDirection > 0) { fieldCount++; populatedFields.push('gpsImgDirection') }
      }
      
      // 分辨率参数
      if (nativeResult.xResolution > 0) { fieldCount++; populatedFields.push('xResolution') }
      if (nativeResult.yResolution > 0) { fieldCount++; populatedFields.push('yResolution') }
      if (nativeResult.resolutionUnit > 0) { fieldCount++; populatedFields.push('resolutionUnit') }
      if (nativeResult.focalPlaneXResolution > 0) { fieldCount++; populatedFields.push('focalPlaneXResolution') }
      if (nativeResult.focalPlaneYResolution > 0) { fieldCount++; populatedFields.push('focalPlaneYResolution') }
      if (nativeResult.focalPlaneResolutionUnit > 0) { fieldCount++; populatedFields.push('focalPlaneResolutionUnit') }
      
      // 图像属性
      if (nativeResult.imageWidth > 0) { fieldCount++; populatedFields.push('imageWidth') }
      if (nativeResult.imageHeight > 0) { fieldCount++; populatedFields.push('imageHeight') }
      if (nativeResult.orientation > 0) { fieldCount++; populatedFields.push('orientation') }
      if (nativeResult.compression > 0) { fieldCount++; populatedFields.push('compression') }
      if (nativeResult.photometricInterpretation > 0) { fieldCount++; populatedFields.push('photometricInterpretation') }
      if (nativeResult.imageDescription) { fieldCount++; populatedFields.push('imageDescription') }
      if (nativeResult.bitsPerSample > 0) { fieldCount++; populatedFields.push('bitsPerSample') }
      if (nativeResult.samplesPerPixel > 0) { fieldCount++; populatedFields.push('samplesPerPixel') }
      if (nativeResult.componentsConfiguration) { fieldCount++; populatedFields.push('componentsConfiguration') }
      if (nativeResult.yCbCrPositioning > 0) { fieldCount++; populatedFields.push('yCbCrPositioning') }
      
      // 曝光控制
      if (nativeResult.exposureProgram > 0) { fieldCount++; populatedFields.push('exposureProgram') }
      if (nativeResult.meteringMode > 0) { fieldCount++; populatedFields.push('meteringMode') }
      if (nativeResult.exposureMode > 0) { fieldCount++; populatedFields.push('exposureMode') }
      if (nativeResult.exposureBias !== 0) { fieldCount++; populatedFields.push('exposureBias') }
      if (nativeResult.maxAperture > 0) { fieldCount++; populatedFields.push('maxAperture') }
      
      // 其他参数
      if (nativeResult.flash >= 0) { fieldCount++; populatedFields.push('flash') }
      if (nativeResult.whiteBalance >= 0) { fieldCount++; populatedFields.push('whiteBalance') }
      if (nativeResult.colorSpace > 0) { fieldCount++; populatedFields.push('colorSpace') }
      if (nativeResult.contrast >= 0) { fieldCount++; populatedFields.push('contrast') }
      if (nativeResult.saturation >= 0) { fieldCount++; populatedFields.push('saturation') }
      if (nativeResult.sharpness >= 0) { fieldCount++; populatedFields.push('sharpness') }
      
      // 元数据
      if (nativeResult.exifVersion) { fieldCount++; populatedFields.push('exifVersion') }
      if (nativeResult.flashpixVersion) { fieldCount++; populatedFields.push('flashpixVersion') }
      if (nativeResult.lightSource > 0) { fieldCount++; populatedFields.push('lightSource') }
      if (nativeResult.brightness !== 0) { fieldCount++; populatedFields.push('brightness') }
      if (nativeResult.sensingMethod > 0) { fieldCount++; populatedFields.push('sensingMethod') }
      if (nativeResult.userComment) { fieldCount++; populatedFields.push('userComment') }
      if (nativeResult.relatedSoundFile) { fieldCount++; populatedFields.push('relatedSoundFile') }
      
      // === 新增字段统计（21个扩展字段）===
      if (nativeResult.bodySerialNumber) { fieldCount++; populatedFields.push('bodySerialNumber') }
      if (nativeResult.gainControl > 0) { fieldCount++; populatedFields.push('gainControl') }
      if (nativeResult.digitalZoomRatio > 0) { fieldCount++; populatedFields.push('digitalZoomRatio') }
      if (nativeResult.sceneType > 0) { fieldCount++; populatedFields.push('sceneType') }
      if (nativeResult.subjectDistanceRange > 0) { fieldCount++; populatedFields.push('subjectDistanceRange') }
      if (nativeResult.customRendered > 0) { fieldCount++; populatedFields.push('customRendered') }
      if (nativeResult.sceneCaptureType > 0) { fieldCount++; populatedFields.push('sceneCaptureType') }
      if (nativeResult.flashEnergy > 0) { fieldCount++; populatedFields.push('flashEnergy') }
      if (nativeResult.fileSource > 0) { fieldCount++; populatedFields.push('fileSource') }
      if (nativeResult.subjectLocation) { fieldCount++; populatedFields.push('subjectLocation') }
      if (nativeResult.subjectArea) { fieldCount++; populatedFields.push('subjectArea') }
      if (nativeResult.whitePoint) { fieldCount++; populatedFields.push('whitePoint') }
      if (nativeResult.primaryChromaticities) { fieldCount++; populatedFields.push('primaryChromaticities') }
      if (nativeResult.yCbCrCoefficients) { fieldCount++; populatedFields.push('yCbCrCoefficients') }
      if (nativeResult.referenceBlackWhite) { fieldCount++; populatedFields.push('referenceBlackWhite') }
      if (nativeResult.transferFunction) { fieldCount++; populatedFields.push('transferFunction') }
      if (nativeResult.spectralSensitivity) { fieldCount++; populatedFields.push('spectralSensitivity') }
      if (nativeResult.oecf) { fieldCount++; populatedFields.push('oecf') }
      if (nativeResult.makerNote) { fieldCount++; populatedFields.push('makerNote') }
      if (nativeResult.artist) { fieldCount++; populatedFields.push('artist') }
      if (nativeResult.copyright) { fieldCount++; populatedFields.push('copyright') }
      
      // === Phase 2扩展：P0 DNG字段统计（12个）===
      if (nativeResult.dngVersion) { fieldCount++; populatedFields.push('dngVersion') }
      if (nativeResult.dngBackwardVersion) { fieldCount++; populatedFields.push('dngBackwardVersion') }
      if (nativeResult.uniqueCameraModel) { fieldCount++; populatedFields.push('uniqueCameraModel') }
      if (nativeResult.cameraSerialNumberDNG) { fieldCount++; populatedFields.push('cameraSerialNumberDNG') }
      if (nativeResult.dngLensInfo) { fieldCount++; populatedFields.push('dngLensInfo') }
      if (nativeResult.originalRawFilename) { fieldCount++; populatedFields.push('originalRawFilename') }
      if (nativeResult.baselineExposure !== 0) { fieldCount++; populatedFields.push('baselineExposure') }
      if (nativeResult.baselineNoise !== 0) { fieldCount++; populatedFields.push('baselineNoise') }
      if (nativeResult.baselineSharpness !== 0) { fieldCount++; populatedFields.push('baselineSharpness') }
      if (nativeResult.linearResponseLimit !== 0) { fieldCount++; populatedFields.push('linearResponseLimit') }
      if (nativeResult.shadowScale !== 0) { fieldCount++; populatedFields.push('shadowScale') }
      if (nativeResult.previewColorSpace) { fieldCount++; populatedFields.push('previewColorSpace') }
      
      hilog.error(0x0021, 'EXIF', `[EXIF-Native] ✅ 解析完成：${fieldCount}个字段有效`)
      hilog.error(0x0021, 'EXIF', `[EXIF-Native] 📋 有效字段清单: ${populatedFields.join(', ')}`)
      hilog.error(0x0021, 'EXIF', `[EXIF-Native] 核心参数: ISO=${exifData.iso}, 光圈=${exifData.aperture}, 焦距=${exifData.focalLength}`)
      
      return exifData
      
    } catch (e) {
      // 增强错误捕获（CodeGenie建议）
      hilog.error(0x0021, 'EXIF', `[EXIF-Native] 错误详情: ${JSON.stringify(e)}`)
      // 降级到ArkTS方式
      return await this.parseRawByThumbnail(photoUri, sandboxPath)
    }
  }

  /**
   * 内嵌JPEG缩略图方式解析RAW（免费版）
   * 通过多IFD层级查询获取DNG的EXIF数据
   */
  private async parseRawByThumbnail(photoUri: string, sandboxPath?: string): Promise<ExifData> {
    let file: fileIo.File | null = null
    let imageSource: image.ImageSource | null = null
    
    try {
      const targetPath = sandboxPath || photoUri
      file = fileIo.openSync(targetPath, fileIo.OpenMode.READ_ONLY)
      
      // 创建ImageSource（使用文件描述符直接创建）
      imageSource = image.createImageSource(file.fd)
      
      hilog.error(0x0021, 'EXIF', `[DNG-初始化] fd=${file.fd}`)
      
      // 尝试从RAW文件多层级提取EXIF
      hilog.info(0x0021, 'EXIF', '[EXIF] 尝试从RAW文件提取EXIF（多IFD模式）...')
      
      let result: ExifData
      try {
        result = await this.extractRawExifData(imageSource)
        hilog.error(0x0021, 'EXIF', '[EXIF] extractRawExifData执行完成')
      } catch (e) {
        hilog.error(0x0021, 'EXIF', '[EXIF] extractRawExifData异常:' + e)
        result = createEmptyExifData()
      }
      
      // 如果直接获取失败，尝试获取图片信息补充
      if (result.iso === 0 && result.aperture === '') {
        hilog.info(0x0021, 'EXIF', '[EXIF] 直接获取失败，尝试从图像信息提取...')
        try {
          const imageInfo = await imageSource.getImageInfo()
          hilog.info(0x0021, 'EXIF', `[EXIF] RAW图像信息: ${JSON.stringify(imageInfo)}`)
          // 补充图像尺寸
          if (imageInfo && imageInfo.size) {
            result.imageWidth = imageInfo.size.width
            result.imageHeight = imageInfo.size.height
          }
        } catch (e) {
          hilog.warn(0x0021, 'EXIF', '[EXIF] 获取图像信息失败:' + e)
        }
      }
      
      return result
    } catch (e) {
      hilog.error(0x0021, 'EXIF', '[EXIF] RAW解析失败:' + e)
      return this.createEmptyWithCurrentTime()
    } finally {
      if (imageSource) {
        try { imageSource.release() } catch (e) { /* ignore */ }
      }
      if (file) {
        try { fileIo.closeSync(file) } catch (e) { /* ignore */ }
      }
    }
  }

  /**
   * RAW格式专用EXIF提取（标准字段遍历方案）
   * 注：竞品前缀测试代码（Exif.Photo.xxx, ExifIFD:xxx, EXIF:xxx, 0xXXXX）已删除
   *     华为 Image Kit 仅支持标准 PropertyKey 格式
   */
  private async extractRawExifData(imageSource: image.ImageSource): Promise<ExifData> {
    const exifData = createEmptyExifData()

    // 高频字段优先尝试（CodeGenie推荐）
    const PRIORITY_KEYS = [
      'Model', 'Make', 'DateTime', 'DateTimeOriginal', 
      'ExposureTime', 'FNumber', 'ISOSpeedRatings', 
      'FocalLength', 'LensModel'
    ]

    // DNG私有字段（需要tag:Adobe:前缀）
    const DNG_PRIVATE_KEYS = [
      'tag:Adobe:DNGVersion',
      'tag:Adobe:DNGBackwardVersion',
      'tag:Adobe:UniqueCameraModel'
    ]

    // 完整标准EXIF字段（67个）
    const STANDARD_KEYS = [
      'FNumber', 'ExposureTime', 'ISOSpeedRatings', 'FocalLength', 'ExposureCompensation',
      'ExposureBiasValue', 'ExposureMode', 'ExposureProgram', 'MeteringMode',
      'Make', 'Model', 'BodySerialNumber', 'Software', 'ExifVersion',
      'LensModel', 'LensMake', 'LensSerialNumber', 'MaxApertureValue', 'SubjectDistance',
      'DateTimeOriginal', 'DateTime', 'DateTimeDigitized', 'SubSecTime', 'SubSecTimeOriginal',
      'WhiteBalance', 'Flash', 'FlashEnergy', 'LightSource',
      'ColorSpace', 'Contrast', 'Saturation', 'Sharpness', 'BrightnessValue', 'GainControl',
      'GPSLatitude', 'GPSLongitude', 'GPSAltitude', 'GPSLatitudeRef', 'GPSLongitudeRef',
      'GPSAltitudeRef', 'GPSSpeed', 'GPSImgDirection', 'GPSTimeStamp',
      'ImageWidth', 'ImageHeight', 'ImageLength', 'Orientation', 'Compression',
      'XResolution', 'YResolution', 'ResolutionUnit', 
      'FocalPlaneXResolution', 'FocalPlaneYResolution', 'FocalPlaneResolutionUnit',
      'SubjectDistanceRange', 'SubjectArea', 'SensingMethod', 'FocalLengthIn35mmFilm',
      'SceneType', 'SceneCaptureType', 'DigitalZoomRatio', 'FileSource',
      'Artist', 'Copyright', 'ImageDescription', 'UserComment',
      'PhotometricInterpretation', 'YCbCrCoefficients', 'CFAPattern'
    ]

    let successCount = 0
    let failCount = 0

    // 1. 先尝试高频字段
    for (const key of PRIORITY_KEYS) {
      try {
        const value = await imageSource.getImageProperty(key)
        if (value && value !== '' && value !== 'undefined') {
          this.mapFieldToExifData(key, value, exifData)
          successCount++
          hilog.info(0x0021, 'EXIF', `[EXIF] ✓ ${key}=${value}`)
        } else {
          failCount++
        }
      } catch (e) {
        failCount++
      }
    }

    // 2. 尝试DNG私有字段
    for (const key of DNG_PRIVATE_KEYS) {
      try {
        const value = await imageSource.getImageProperty(key)
        if (value && value !== '') {
          successCount++
          hilog.info(0x0021, 'EXIF', `[EXIF] [RAW-DNG] ${key}=${value}`)
        }
      } catch (e) { /* 忽略 */ }
    }

    // 3. 遍历其余标准字段（跳过已尝试的）
    for (const key of STANDARD_KEYS) {
      if (PRIORITY_KEYS.includes(key)) continue
      
      try {
        const value = await imageSource.getImageProperty(key)
        if (value && value !== '' && value !== 'undefined') {
          this.mapFieldToExifData(key, value, exifData)
          successCount++
          hilog.info(0x0021, 'EXIF', `[EXIF] ✓ ${key}=${value}`)
        } else {
          failCount++
        }
      } catch (e) {
        failCount++
      }
    }

    hilog.error(0x0021, 'EXIF', `[EXIF] 🟢 解析完成：成功${successCount}个，失败${failCount}个 🟢`)
    hilog.error(0x0021, 'EXIF', `[EXIF] 结果：ISO=${exifData.iso}, 光圈=${exifData.aperture}, 机型=${exifData.cameraModel}`)
    
    return exifData
  }

  /**
   * 将字段映射到ExifData（根据华为支持的实际字段名）
   */
  private mapFieldToExifData(key: string, value: string, exifData: ExifData): void {
    switch(key) {
      // 基础拍摄参数
      case 'FNumber':
      case 'ApertureValue':
        exifData.aperture = formatAperture(value)
        break
      case 'ExposureTime':
      case 'ShutterSpeedValue':
        exifData.shutterSpeed = formatShutterSpeed(value)
        break
      case 'ISOSpeedRatings':
      case 'PhotographicSensitivity':
        exifData.iso = parseInt(value) || 0
        break
      case 'FocalLength':
        exifData.focalLength = formatFocalLength(value)
        break
      case 'FocalLengthIn35mmFilm':
        exifData.focalLengthIn35mm = `${value}mm`
        break
        
      // 设备信息
      case 'Make':
        exifData.cameraMake = value
        break
      case 'Model':
        exifData.cameraModel = value
        break
      case 'LensModel':
        exifData.lensModel = value
        break
      case 'LensMake':
        exifData.lensMake = value
        break
        
      // 时间信息
      case 'DateTimeOriginal':
        exifData.dateTime = formatDateTime(value)
        break
      case 'DateTime':
        if (!exifData.dateTime) exifData.dateTime = formatDateTime(value)
        break
        
      // 曝光控制
      case 'ExposureMode':
        exifData.exposureMode = formatExposureMode(value)
        break
      case 'ExposureProgram':
        exifData.exposureProgram = formatExposureProgram(value)
        break
      case 'MeteringMode':
        exifData.meteringMode = formatMeteringMode(value)
        break
      case 'WhiteBalance':
        exifData.whiteBalance = value === '0' ? '自动' : '手动'
        break
      case 'Flash':
        exifData.flash = formatFlash(value)
        break
        
      // GPS信息
      case 'GPSLatitude':
        exifData.gpsLatitude = parseGpsCoordinate(value)
        break
      case 'GPSLongitude':
        exifData.gpsLongitude = parseGpsCoordinate(value)
        break
      case 'GPSAltitude':
        exifData.gpsAltitude = parseFloat(value)
        break
        
      // 图像属性
      case 'ImageWidth':
      case 'PixelXDimension':
        exifData.imageWidth = parseInt(value)
        break
      case 'ImageHeight':
      case 'ImageLength':
      case 'PixelYDimension':
        exifData.imageHeight = parseInt(value)
        break
      case 'Orientation':
        exifData.orientation = formatOrientation(value)
        break
      case 'ColorSpace':
        exifData.colorSpace = value === '1' ? 'sRGB' : value
        break
        
      // 其他常用字段
      case 'Software':
        exifData.software = value
        break
      case 'ExifVersion':
        exifData.exifVersion = value
        break
        
      default:
        // 未知字段，不处理
        break
    }
  }

  /**
   * fd方式解析（稳定版）
   * 必须使用fd方式，createImageSource(uri)不支持file://media/格式
   */
  private async parseExifByFd(photoUri: string): Promise<ExifData> {
    let file: fileIo.File | null = null
    let imageSource: image.ImageSource | null = null
    
    try {
      file = fileIo.openSync(photoUri, fileIo.OpenMode.READ_ONLY)
      imageSource = image.createImageSource(file.fd)
      return await this.extractExifData(imageSource)
    } finally {
      if (imageSource) {
        try { imageSource.release() } catch (e) { /* ignore */ }
      }
      if (file) {
        try { fileIo.closeSync(file) } catch (e) { /* ignore */ }
      }
    }
  }

  /**
   * 沙箱路径方式解析（CodeGenie推荐）
   */
  private async parseExifBySandbox(sandboxPath: string): Promise<ExifData> {
    let file: fileIo.File | null = null
    let imageSource: image.ImageSource | null = null
    
    try {
      // 使用沙箱内的绝对路径创建ImageSource
      file = fileIo.openSync(sandboxPath, fileIo.OpenMode.READ_ONLY)
      imageSource = image.createImageSource(file.fd)
      return await this.extractExifData(imageSource)
    } finally {
      if (imageSource) {
        try { imageSource.release() } catch (e) { /* ignore */ }
      }
      if (file) {
        try { fileIo.closeSync(file) } catch (e) { /* ignore */ }
      }
    }
  }

  /**
   * 创建带当前时间的空ExifData
   */
  private createEmptyWithCurrentTime(): ExifData {
    const exifData = createEmptyExifData()
    exifData.dateTime = new Date().toLocaleString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
    return exifData
  }

  /**
   * 从ImageSource提取EXIF数据
   */
  private async extractExifData(imageSource: image.ImageSource): Promise<ExifData> {
    const exifData = createEmptyExifData()

    try {
      // 光圈 (FNumber)
      const aperture = await imageSource.getImageProperty(image.PropertyKey.F_NUMBER)
      hilog.info(0x0021, 'EXIF', `[EXIF] 原始光圈值: ${aperture}`)
      if (aperture) {
        exifData.aperture = formatAperture(aperture)
      }

      // 快门速度 (ExposureTime)
      const shutterSpeed = await imageSource.getImageProperty(image.PropertyKey.EXPOSURE_TIME)
      hilog.info(0x0021, 'EXIF', `[EXIF] 原始快门值: ${shutterSpeed}`)
      if (shutterSpeed) {
        exifData.shutterSpeed = formatShutterSpeed(shutterSpeed)
      }

      // ISO
      const iso = await imageSource.getImageProperty(image.PropertyKey.ISO_SPEED_RATINGS)
      hilog.info(0x0021, 'EXIF', `[EXIF] 原始ISO值: ${iso}`)
      if (iso) {
        exifData.iso = parseInt(iso)
      }

      // 焦距 (FocalLength)
      const focalLength = await imageSource.getImageProperty(image.PropertyKey.FOCAL_LENGTH)
      hilog.info(0x0021, 'EXIF', `[EXIF] 原始焦距值: ${focalLength}`)
      if (focalLength) {
        exifData.focalLength = formatFocalLength(focalLength)
      }

      // 相机品牌
      try {
        const cameraMake = await imageSource.getImageProperty(image.PropertyKey.MAKE)
        hilog.info(0x0021, 'EXIF', `[EXIF] MAKE: ${cameraMake}`)
        if (cameraMake && cameraMake !== '') {
          exifData.cameraMake = cameraMake
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] MAKE 获取失败') }

      // 相机型号
      try {
        const cameraModel = await imageSource.getImageProperty(image.PropertyKey.MODEL)
        hilog.info(0x0021, 'EXIF', `[EXIF] MODEL: ${cameraModel}`)
        if (cameraModel && cameraModel !== '') {
          exifData.cameraModel = cameraModel
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] MODEL 获取失败') }

      // 镜头型号
      try {
        const lensModel = await imageSource.getImageProperty(image.PropertyKey.LENS_MODEL)
        hilog.info(0x0021, 'EXIF', `[EXIF] LENS_MODEL: ${lensModel}`)
        if (lensModel && lensModel !== '') {
          exifData.lensModel = lensModel
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] LENS_MODEL 获取失败') }

      // 拍摄时间（尝试多个字段）
      try {
        let dateTime = await imageSource.getImageProperty(image.PropertyKey.DATE_TIME_ORIGINAL)
        hilog.info(0x0021, 'EXIF', `[EXIF] DATE_TIME_ORIGINAL: ${dateTime}`)
        
        if (!dateTime || dateTime === '') {
          dateTime = await imageSource.getImageProperty(image.PropertyKey.DATE_TIME)
          hilog.info(0x0021, 'EXIF', `[EXIF] DATE_TIME: ${dateTime}`)
        }
        
        if (dateTime && dateTime !== '') {
          exifData.dateTime = formatDateTime(dateTime)
          hilog.info(0x0021, 'EXIF', `[EXIF] 最终日期: ${exifData.dateTime}`)
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] DateTime 获取失败') }

      // GPS信息
      try {
        const gpsLat = await imageSource.getImageProperty(image.PropertyKey.GPS_LATITUDE)
        const gpsLon = await imageSource.getImageProperty(image.PropertyKey.GPS_LONGITUDE)
        hilog.info(0x0021, 'EXIF', `[EXIF] GPS: ${gpsLat}, ${gpsLon}`)
        if (gpsLat && gpsLon && gpsLat !== '' && gpsLon !== '') {
          exifData.gpsLatitude = parseGpsCoordinate(gpsLat)
          exifData.gpsLongitude = parseGpsCoordinate(gpsLon)
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] GPS 获取失败') }

      // === 扩展字段（带详细日志） ===
      hilog.info(0x0021, 'EXIF', '[EXIF] ===== 开始提取扩展字段 =====')
      
      // GPS海拔
      try {
        const gpsAlt = await imageSource.getImageProperty(image.PropertyKey.GPS_ALTITUDE)
        hilog.info(0x0021, 'EXIF', `[EXIF] GPS_ALTITUDE: ${gpsAlt}`)
        if (gpsAlt && gpsAlt !== '') {
          exifData.gpsAltitude = parseFloat(gpsAlt)
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] GPS_ALTITUDE 获取失败') }

      // 曝光补偿
      try {
        const exposureBias = await imageSource.getImageProperty(image.PropertyKey.EXPOSURE_BIAS_VALUE)
        hilog.info(0x0021, 'EXIF', `[EXIF] EXPOSURE_BIAS_VALUE: ${exposureBias}`)
        if (exposureBias && exposureBias !== '') {
          const biasNum = parseFloat(exposureBias)
          exifData.exposureCompensation = `${biasNum >= 0 ? '+' : ''}${biasNum.toFixed(1)} EV`
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] EXPOSURE_BIAS_VALUE 获取失败') }

      // 曝光模式
      try {
        const exposureMode = await imageSource.getImageProperty(image.PropertyKey.EXPOSURE_MODE)
        hilog.info(0x0021, 'EXIF', `[EXIF] EXPOSURE_MODE: ${exposureMode}`)
        if (exposureMode && exposureMode !== '') {
          exifData.exposureMode = formatExposureMode(exposureMode)
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] EXPOSURE_MODE 获取失败') }

      // 曝光程序
      try {
        const exposureProgram = await imageSource.getImageProperty(image.PropertyKey.EXPOSURE_PROGRAM)
        hilog.info(0x0021, 'EXIF', `[EXIF] EXPOSURE_PROGRAM: ${exposureProgram}`)
        if (exposureProgram && exposureProgram !== '') {
          exifData.exposureProgram = formatExposureProgram(exposureProgram)
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] EXPOSURE_PROGRAM 获取失败') }

      // 测光模式
      try {
        const meteringMode = await imageSource.getImageProperty(image.PropertyKey.METERING_MODE)
        hilog.info(0x0021, 'EXIF', `[EXIF] METERING_MODE: ${meteringMode}`)
        if (meteringMode && meteringMode !== '') {
          exifData.meteringMode = formatMeteringMode(meteringMode)
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] METERING_MODE 获取失败') }

      // 白平衡
      try {
        const whiteBalance = await imageSource.getImageProperty(image.PropertyKey.WHITE_BALANCE)
        hilog.info(0x0021, 'EXIF', `[EXIF] WHITE_BALANCE: ${whiteBalance}`)
        if (whiteBalance && whiteBalance !== '') {
          exifData.whiteBalance = whiteBalance === '0' ? '自动' : '手动'
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] WHITE_BALANCE 获取失败') }

      // 闪光灯
      try {
        const flash = await imageSource.getImageProperty(image.PropertyKey.FLASH)
        hilog.info(0x0021, 'EXIF', `[EXIF] FLASH: ${flash}`)
        if (flash && flash !== '') {
          exifData.flash = formatFlash(flash)
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] FLASH 获取失败') }

      // 镜头品牌
      try {
        const lensMake = await imageSource.getImageProperty(image.PropertyKey.LENS_MAKE)
        hilog.info(0x0021, 'EXIF', `[EXIF] LENS_MAKE: ${lensMake}`)
        if (lensMake && lensMake !== '') {
          exifData.lensMake = lensMake
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] LENS_MAKE 获取失败') }

      // 最大光圈
      try {
        const maxAperture = await imageSource.getImageProperty(image.PropertyKey.MAX_APERTURE_VALUE)
        hilog.info(0x0021, 'EXIF', `[EXIF] MAX_APERTURE_VALUE: ${maxAperture}`)
        if (maxAperture && maxAperture !== '') {
          exifData.maxAperture = formatAperture(maxAperture)
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] MAX_APERTURE_VALUE 获取失败') }

      // 35mm等效焦距
      try {
        const focalLength35 = await imageSource.getImageProperty(image.PropertyKey.FOCAL_LENGTH_IN_35_MM_FILM)
        hilog.info(0x0021, 'EXIF', `[EXIF] FOCAL_LENGTH_IN_35_MM_FILM: ${focalLength35}`)
        if (focalLength35 && focalLength35 !== '') {
          exifData.focalLengthIn35mm = `${focalLength35}mm`
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] FOCAL_LENGTH_IN_35_MM_FILM 获取失败') }

      // 图像尺寸
      try {
        const imgInfo = await imageSource.getImageInfo()
        hilog.info(0x0021, 'EXIF', `[EXIF] ImageInfo: ${JSON.stringify(imgInfo)}`)
        if (imgInfo && imgInfo.size) {
          exifData.imageWidth = imgInfo.size.width
          exifData.imageHeight = imgInfo.size.height
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] ImageInfo 获取失败') }

      // 方向
      try {
        const orientation = await imageSource.getImageProperty(image.PropertyKey.ORIENTATION)
        hilog.info(0x0021, 'EXIF', `[EXIF] ORIENTATION: ${orientation}`)
        if (orientation && orientation !== '') {
          exifData.orientation = formatOrientation(orientation)
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] ORIENTATION 获取失败') }

      // 色彩空间
      try {
        const colorSpace = await imageSource.getImageProperty(image.PropertyKey.COLOR_SPACE)
        hilog.info(0x0021, 'EXIF', `[EXIF] COLOR_SPACE: ${colorSpace}`)
        if (colorSpace && colorSpace !== '') {
          exifData.colorSpace = colorSpace === '1' ? 'sRGB' : (colorSpace === '65535' ? 'Uncalibrated' : colorSpace)
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] COLOR_SPACE 获取失败') }

      // 对比度
      try {
        const contrast = await imageSource.getImageProperty(image.PropertyKey.CONTRAST)
        hilog.info(0x0021, 'EXIF', `[EXIF] CONTRAST: ${contrast}`)
        if (contrast && contrast !== '') {
          exifData.contrast = contrast === '0' ? '标准' : (contrast === '1' ? '低' : '高')
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] CONTRAST 获取失败') }

      // 饱和度
      try {
        const saturation = await imageSource.getImageProperty(image.PropertyKey.SATURATION)
        hilog.info(0x0021, 'EXIF', `[EXIF] SATURATION: ${saturation}`)
        if (saturation && saturation !== '') {
          exifData.saturation = saturation === '0' ? '标准' : (saturation === '1' ? '低' : '高')
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] SATURATION 获取失败') }

      // 锐度
      try {
        const sharpness = await imageSource.getImageProperty(image.PropertyKey.SHARPNESS)
        hilog.info(0x0021, 'EXIF', `[EXIF] SHARPNESS: ${sharpness}`)
        if (sharpness && sharpness !== '') {
          exifData.sharpness = sharpness === '0' ? '标准' : (sharpness === '1' ? '柔和' : '锐利')
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] SHARPNESS 获取失败') }

      // 亮度
      try {
        const brightness = await imageSource.getImageProperty(image.PropertyKey.BRIGHTNESS_VALUE)
        hilog.info(0x0021, 'EXIF', `[EXIF] BRIGHTNESS_VALUE: ${brightness}`)
        if (brightness && brightness !== '') {
          exifData.brightness = `${parseFloat(brightness).toFixed(2)} EV`
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] BRIGHTNESS_VALUE 获取失败') }

      // 场景类型
      try {
        const sceneType = await imageSource.getImageProperty(image.PropertyKey.SCENE_TYPE)
        hilog.info(0x0021, 'EXIF', `[EXIF] SCENE_TYPE: ${sceneType}`)
        if (sceneType && sceneType !== '') {
          exifData.sceneType = sceneType === '1' ? '直接拍摄' : sceneType
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] SCENE_TYPE 获取失败') }

      // 软件
      try {
        const software = await imageSource.getImageProperty(image.PropertyKey.SOFTWARE)
        hilog.info(0x0021, 'EXIF', `[EXIF] SOFTWARE: ${software}`)
        if (software && software !== '') {
          exifData.software = software
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] SOFTWARE 获取失败') }

      // EXIF版本
      try {
        const exifVersion = await imageSource.getImageProperty(image.PropertyKey.EXIF_VERSION)
        hilog.info(0x0021, 'EXIF', `[EXIF] EXIF_VERSION: ${exifVersion}`)
        if (exifVersion && exifVersion !== '') {
          exifData.exifVersion = exifVersion
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] EXIF_VERSION 获取失败') }

      // === 尝试更多华为可能支持的字段 ===
      try {
        const artist = await imageSource.getImageProperty(image.PropertyKey.ARTIST)
        hilog.info(0x0021, 'EXIF', `[EXIF] ARTIST: ${artist}`)
        if (artist && artist !== '') exifData.artist = artist
      } catch (e) { /* ignore */ }
      
      try {
        const copyright = await imageSource.getImageProperty(image.PropertyKey.COPYRIGHT)
        hilog.info(0x0021, 'EXIF', `[EXIF] COPYRIGHT: ${copyright}`)
        if (copyright && copyright !== '') exifData.copyright = copyright
      } catch (e) { /* ignore */ }
      
      try {
        const imageDesc = await imageSource.getImageProperty(image.PropertyKey.IMAGE_DESCRIPTION)
        hilog.info(0x0021, 'EXIF', `[EXIF] IMAGE_DESCRIPTION: ${imageDesc}`)
        if (imageDesc && imageDesc !== '') exifData.imageDescription = imageDesc
      } catch (e) { /* ignore */ }

      // === 补充竞品能读但本项目缺失的字段（39个）===
      hilog.info(0x0021, 'EXIF', '[EXIF] ===== 开始补充缺失字段 =====')
      
      // SubSecTime系列（3个）- 亚秒时间精度
      try {
        const subSecTime = await imageSource.getImageProperty(image.PropertyKey.SUBSEC_TIME)
        hilog.info(0x0021, 'EXIF', `[EXIF] SUBSEC_TIME: ${subSecTime}`)
        if (subSecTime && subSecTime !== '') exifData.subSecTime = subSecTime
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] SUBSEC_TIME 获取失败') }
      
      try {
        const subSecTimeOrig = await imageSource.getImageProperty(image.PropertyKey.SUBSEC_TIME_ORIGINAL)
        hilog.info(0x0021, 'EXIF', `[EXIF] SUBSEC_TIME_ORIGINAL: ${subSecTimeOrig}`)
        if (subSecTimeOrig && subSecTimeOrig !== '') exifData.subSecTimeOriginal = subSecTimeOrig
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] SUBSEC_TIME_ORIGINAL 获取失败') }
      
      try {
        const subSecTimeDigit = await imageSource.getImageProperty(image.PropertyKey.SUBSEC_TIME_DIGITIZED)
        hilog.info(0x0021, 'EXIF', `[EXIF] SUBSEC_TIME_DIGITIZED: ${subSecTimeDigit}`)
        if (subSecTimeDigit && subSecTimeDigit !== '') exifData.subSecTimeDigitized = subSecTimeDigit
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] SUBSEC_TIME_DIGITIZED 获取失败') }
      
      // 图像技术参数
      try {
        const digitalZoom = await imageSource.getImageProperty(image.PropertyKey.DIGITAL_ZOOM_RATIO)
        hilog.info(0x0021, 'EXIF', `[EXIF] DIGITAL_ZOOM_RATIO: ${digitalZoom}`)
        if (digitalZoom && digitalZoom !== '') exifData.digitalZoomRatio = digitalZoom
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] DIGITAL_ZOOM_RATIO 获取失败') }
      
      try {
        const gainControl = await imageSource.getImageProperty(image.PropertyKey.GAIN_CONTROL)
        hilog.info(0x0021, 'EXIF', `[EXIF] GAIN_CONTROL: ${gainControl}`)
        if (gainControl && gainControl !== '') exifData.gainControl = formatGainControl(parseInt(gainControl))
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] GAIN_CONTROL 获取失败') }
      
      try {
        const lightSource = await imageSource.getImageProperty(image.PropertyKey.LIGHT_SOURCE)
        hilog.info(0x0021, 'EXIF', `[EXIF] LIGHT_SOURCE: ${lightSource}`)
        if (lightSource && lightSource !== '') exifData.lightSource = lightSource
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] LIGHT_SOURCE 获取失败') }
      
      try {
        const sceneCaptureType = await imageSource.getImageProperty(image.PropertyKey.SCENE_CAPTURE_TYPE)
        hilog.info(0x0021, 'EXIF', `[EXIF] SCENE_CAPTURE_TYPE: ${sceneCaptureType}`)
        if (sceneCaptureType && sceneCaptureType !== '') exifData.sceneCaptureType = formatSceneCaptureType(parseInt(sceneCaptureType))
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] SCENE_CAPTURE_TYPE 获取失败') }
      
      try {
        const sensingMethod = await imageSource.getImageProperty(image.PropertyKey.SENSING_METHOD)
        hilog.info(0x0021, 'EXIF', `[EXIF] SENSING_METHOD: ${sensingMethod}`)
        if (sensingMethod && sensingMethod !== '') exifData.sensingMethod = sensingMethod
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] SENSING_METHOD 获取失败') }
      
      try {
        const subjectDistanceRange = await imageSource.getImageProperty(image.PropertyKey.SUBJECT_DISTANCE_RANGE)
        hilog.info(0x0021, 'EXIF', `[EXIF] SUBJECT_DISTANCE_RANGE: ${subjectDistanceRange}`)
        if (subjectDistanceRange && subjectDistanceRange !== '') exifData.subjectDistanceRange = formatSubjectDistRange(parseInt(subjectDistanceRange))
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] SUBJECT_DISTANCE_RANGE 获取失败') }
      
      try {
        const customRendered = await imageSource.getImageProperty(image.PropertyKey.CUSTOM_RENDERED)
        hilog.info(0x0021, 'EXIF', `[EXIF] CUSTOM_RENDERED: ${customRendered}`)
        if (customRendered && customRendered !== '') exifData.customRendered = parseInt(customRendered) === 0 ? '正常' : '自定义'
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] CUSTOM_RENDERED 获取失败') }
      
      // GPS扩展字段
      try {
        const gpsAltRef = await imageSource.getImageProperty(image.PropertyKey.GPS_ALTITUDE_REF)
        hilog.info(0x0021, 'EXIF', `[EXIF] GPS_ALTITUDE_REF: ${gpsAltRef}`)
        if (gpsAltRef && gpsAltRef !== '') exifData.gpsAltitudeRef = gpsAltRef
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] GPS_ALTITUDE_REF 获取失败') }
      
      try {
        const gpsLatRef = await imageSource.getImageProperty(image.PropertyKey.GPS_LATITUDE_REF)
        hilog.info(0x0021, 'EXIF', `[EXIF] GPS_LATITUDE_REF: ${gpsLatRef}`)
        if (gpsLatRef && gpsLatRef !== '') exifData.gpsLatitudeRef = gpsLatRef
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] GPS_LATITUDE_REF 获取失败') }
      
      try {
        const gpsLonRef = await imageSource.getImageProperty(image.PropertyKey.GPS_LONGITUDE_REF)
        hilog.info(0x0021, 'EXIF', `[EXIF] GPS_LONGITUDE_REF: ${gpsLonRef}`)
        if (gpsLonRef && gpsLonRef !== '') exifData.gpsLongitudeRef = gpsLonRef
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] GPS_LONGITUDE_REF 获取失败') }
      
      try {
        const gpsTimeStamp = await imageSource.getImageProperty(image.PropertyKey.GPS_TIME_STAMP)
        hilog.info(0x0021, 'EXIF', `[EXIF] GPS_TIME_STAMP: ${gpsTimeStamp}`)
        if (gpsTimeStamp && gpsTimeStamp !== '') exifData.gpsTimeStamp = gpsTimeStamp
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] GPS_TIME_STAMP 获取失败') }
      
      try {
        const gpsDateStamp = await imageSource.getImageProperty(image.PropertyKey.GPS_DATE_STAMP)
        hilog.info(0x0021, 'EXIF', `[EXIF] GPS_DATE_STAMP: ${gpsDateStamp}`)
        if (gpsDateStamp && gpsDateStamp !== '') exifData.gpsDateStamp = gpsDateStamp
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] GPS_DATE_STAMP 获取失败') }
      
      try {
        const gpsProcessingMethod = await imageSource.getImageProperty(image.PropertyKey.GPS_PROCESSING_METHOD)
        hilog.info(0x0021, 'EXIF', `[EXIF] GPS_PROCESSING_METHOD: ${gpsProcessingMethod}`)
        if (gpsProcessingMethod && gpsProcessingMethod !== '') exifData.gpsProcessingMethod = gpsProcessingMethod
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] GPS_PROCESSING_METHOD 获取失败') }
      
      try {
        const gpsSpeed = await imageSource.getImageProperty(image.PropertyKey.GPS_SPEED)
        hilog.info(0x0021, 'EXIF', `[EXIF] GPS_SPEED: ${gpsSpeed}`)
        if (gpsSpeed && gpsSpeed !== '') exifData.gpsSpeed = `${gpsSpeed} km/h`
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] GPS_SPEED 获取失败') }
      
      try {
        const gpsImgDirection = await imageSource.getImageProperty(image.PropertyKey.GPS_IMG_DIRECTION)
        hilog.info(0x0021, 'EXIF', `[EXIF] GPS_IMG_DIRECTION: ${gpsImgDirection}`)
        if (gpsImgDirection && gpsImgDirection !== '') exifData.gpsImgDirection = `${gpsImgDirection}°`
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] GPS_IMG_DIRECTION 获取失败') }
      
      // 其他时间字段
      try {
        const dateTimeDigitized = await imageSource.getImageProperty(image.PropertyKey.DATE_TIME_DIGITIZED)
        hilog.info(0x0021, 'EXIF', `[EXIF] DATE_TIME_DIGITIZED: ${dateTimeDigitized}`)
        if (dateTimeDigitized && dateTimeDigitized !== '') exifData.dateTimeDigitized = formatDateTime(dateTimeDigitized)
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] DATE_TIME_DIGITIZED 获取失败') }
      
      // 分辨率相关
      try {
        const xResolution = await imageSource.getImageProperty(image.PropertyKey.X_RESOLUTION)
        hilog.info(0x0021, 'EXIF', `[EXIF] X_RESOLUTION: ${xResolution}`)
        if (xResolution && xResolution !== '') exifData.xResolution = parseFloat(xResolution)
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] X_RESOLUTION 获取失败') }
      
      try {
        const yResolution = await imageSource.getImageProperty(image.PropertyKey.Y_RESOLUTION)
        hilog.info(0x0021, 'EXIF', `[EXIF] Y_RESOLUTION: ${yResolution}`)
        if (yResolution && yResolution !== '') exifData.yResolution = parseFloat(yResolution)
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] Y_RESOLUTION 获取失败') }
      
      try {
        const resolutionUnit = await imageSource.getImageProperty(image.PropertyKey.RESOLUTION_UNIT)
        hilog.info(0x0021, 'EXIF', `[EXIF] RESOLUTION_UNIT: ${resolutionUnit}`)
        if (resolutionUnit && resolutionUnit !== '') {
          exifData.resolutionUnit = resolutionUnit === '2' ? '英寸' : (resolutionUnit === '3' ? '厘米' : resolutionUnit)
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] RESOLUTION_UNIT 获取失败') }
      
      // 图像长度
      try {
        const imageLength = await imageSource.getImageProperty(image.PropertyKey.IMAGE_LENGTH)
        hilog.info(0x0021, 'EXIF', `[EXIF] IMAGE_LENGTH: ${imageLength}`)
        if (imageLength && imageLength !== '') {
          const length = parseInt(imageLength)
          if (!exifData.imageHeight || exifData.imageHeight === 0) {
            exifData.imageHeight = length
            exifData.imageLength = length
          }
        }
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] IMAGE_LENGTH 获取失败') }
      
      // FlashPix版本
      try {
        const flashpixVersion = await imageSource.getImageProperty(image.PropertyKey.FLASHPIX_VERSION)
        hilog.info(0x0021, 'EXIF', `[EXIF] FLASHPIX_VERSION: ${flashpixVersion}`)
        if (flashpixVersion && flashpixVersion !== '') exifData.flashpixVersion = flashpixVersion
      } catch (e) { hilog.warn(0x0021, 'EXIF', '[EXIF] FLASHPIX_VERSION 获取失败') }

      hilog.info(0x0021, 'EXIF', '[EXIF] ===== 补充字段提取完成 =====')
      hilog.info(0x0021, 'EXIF', '[EXIF] ===== 扩展字段提取完成 =====')

    } catch (error) {
      hilog.error(0x0021, 'EXIF', '提取EXIF字段失败:' + error)
    }

    hilog.info(0x0021, 'EXIF', `[EXIF] 最终解析结果:` + JSON.stringify(exifData))
    return exifData
  }
}
