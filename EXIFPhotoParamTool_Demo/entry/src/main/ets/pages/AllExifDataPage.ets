/**
 * 完整EXIF数据页 - 显示所有70+字段（包括空值）
 */
import { PhotoRecord } from '../models/PhotoRecord'
import { Router } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'

interface RouteParams {
  record: PhotoRecord
}

interface ExifItem {
  label: string
  value: string
}

interface FieldCount {
  total: number
  nonEmpty: number
}

@Entry
@Component
struct AllExifDataPage {
  @State record: PhotoRecord | null = null
  @State expandedGroups: Set<string> = new Set(['📸 拍摄参数'])  // 默认只展开拍摄参数

  aboutToAppear(): void {
    const routerInstance: Router = this.getUIContext().getRouter()
    const params = routerInstance.getParams() as RouteParams
    if (params && params.record) {
      this.record = params.record
      hilog.info(0x0021, 'EXIF', '[AllExif] 加载记录:' + JSON.stringify(this.record))
      
      // === 调试DNG字段数据 ===
      hilog.error(0x0021, 'EXIF', '[AllExif-DNG] 🔴 检查DNG字段值 🔴')
      hilog.error(0x0021, 'EXIF', `[AllExif-DNG] dngVersion: ${this.record.exifData.dngVersion}`)
      hilog.error(0x0021, 'EXIF', `[AllExif-DNG] dngBackwardVersion: ${this.record.exifData.dngBackwardVersion}`)
      hilog.error(0x0021, 'EXIF', `[AllExif-DNG] uniqueCameraModel: ${this.record.exifData.uniqueCameraModel}`)
      hilog.error(0x0021, 'EXIF', `[AllExif-DNG] cameraSerialNumberDNG: ${this.record.exifData.cameraSerialNumberDNG}`)
      hilog.error(0x0021, 'EXIF', `[AllExif-DNG] dngLensInfo: ${this.record.exifData.dngLensInfo}`)
      hilog.error(0x0021, 'EXIF', `[AllExif-DNG] baselineExposure: ${this.record.exifData.baselineExposure}`)
    }
  }

  // 切换分组展开/折叠状态
  private toggleGroup(groupName: string): void {
    if (this.expandedGroups.has(groupName)) {
      this.expandedGroups.delete(groupName)
    } else {
      this.expandedGroups.add(groupName)
    }
    // 触发响应式更新（ArkTS要求重新赋值）
    this.expandedGroups = new Set(this.expandedGroups)
  }

  // 计算总字段数和非空字段数
  private getTotalFieldCount(): FieldCount {
    if (!this.record) {
      const emptyCount: FieldCount = { total: 0, nonEmpty: 0 }
      return emptyCount
    }
    
    const allSections = [
      this.getShootingParams(),
      this.getCameraParams(),
      this.getLensParams(),
      this.getGpsParams(),
      this.getTimeParams(),
      this.getImageParams(),
      this.getExposureParams(),
      this.getFlashParams(),
      this.getFocusParams(),
      this.getColorParams(),
      this.getAdjustmentParams(),
      this.getSceneParams(),
      this.getResolutionParams(),
      this.getMetadataParams(),
      this.getTechnicalParams(),
      this.getDngParams()  // ✅ 新增：包含DNG专有参数分组
    ]
    
    let total = 0
    let nonEmpty = 0
    
    allSections.forEach(section => {
      section.forEach(item => {
        total++
        if (item.value !== '-') {
          nonEmpty++
        }
      })
    })
    
    const result: FieldCount = { total: total, nonEmpty: nonEmpty }
    return result
  }

  // 计算单个分组的字段数
  private getSectionFieldCount(items: ExifItem[]): FieldCount {
    const total = items.length
    const nonEmpty = items.filter(item => item.value !== '-').length
    const result: FieldCount = { total: total, nonEmpty: nonEmpty }
    return result
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => {
            this.getUIContext().getRouter().back()
          })
        
        Text('完整EXIF数据')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 16 })
        
        Blank()
        
        // 总字段数统计
        if (this.record) {
          Text(`${this.getTotalFieldCount().nonEmpty}/${this.getTotalFieldCount().total}`)
            .fontSize(14)
            .fontColor('#999999')
            .margin({ right: 8 })
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      if (this.record) {
        Scroll() {
          Column() {
            // === P0 核心参数 ===
            // 拍摄参数
            this.ExifSection('📸 拍摄参数', this.getShootingParams())
            
            // 相机信息
            this.ExifSection('📷 相机信息', this.getCameraParams())
            
            // 镜头参数
            this.ExifSection('🔭 镜头参数', this.getLensParams())
            
            // GPS定位
            this.ExifSection('📍 GPS定位', this.getGpsParams())
            
            // 时间信息
            this.ExifSection('⏰ 时间信息', this.getTimeParams())
            
            // 图像属性
            this.ExifSection('🖼️ 图像属性', this.getImageParams())
            
            // === P1 进阶参数 ===
            // 曝光控制
            this.ExifSection('🔆 曝光控制', this.getExposureParams())
            
            // 闪光灯
            this.ExifSection('⚡ 闪光灯', this.getFlashParams())
            
            // 对焦测距
            this.ExifSection('🎯 对焦测距', this.getFocusParams())
            
            // 白平衡与色彩
            this.ExifSection('🎨 白平衡与色彩', this.getColorParams())
            
            // 图像调整
            this.ExifSection('🔧 图像调整', this.getAdjustmentParams())
            
            // 拍摄模式
            this.ExifSection('📐 拍摄模式', this.getSceneParams())
            
            // === P2 技术参数 ===
            // 分辨率参数
            this.ExifSection('📏 分辨率参数', this.getResolutionParams())
            
            // 文件元数据
            this.ExifSection('📋 文件元数据', this.getMetadataParams())
            
            // 技术参数
            this.ExifSection('⚙️ 技术参数', this.getTechnicalParams())
            
            // === P0 DNG专有参数（Phase 2新增）===
            this.ExifSection('📦 DNG专有参数', this.getDngParams())
          }
          .padding(16)
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        Column() {
          Text('❌')
            .fontSize(48)
          Text('无法加载数据')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // === P0 核心参数 ===
  // 拍摄参数
  private getShootingParams(): ExifItem[] {
    if (!this.record) return []
    return [
      { label: '光圈', value: this.record.exifData.aperture || '-' },
      { label: '快门速度', value: this.record.exifData.shutterSpeed || '-' },
      { label: 'ISO感光度', value: this.record.exifData.iso > 0 ? `ISO ${this.record.exifData.iso}` : '-' },
      { label: '焦距', value: this.record.exifData.focalLength || '-' },
      { label: '等效焦距(35mm)', value: this.record.exifData.focalLengthIn35mm || '-' },
      { label: '曝光时间', value: this.record.exifData.exposureTime || '-' },
    ] as ExifItem[]
  }

  // 相机信息
  private getCameraParams(): ExifItem[] {
    if (!this.record) return []
    return [
      { label: '相机品牌', value: this.record.exifData.cameraMake || '-' },
      { label: '相机型号', value: this.record.exifData.cameraModel || '-' },
      { label: '机身序列号', value: this.record.exifData.bodySerialNumber || '-' },
      { label: '处理软件', value: this.record.exifData.software || '-' },
      { label: 'EXIF版本', value: this.record.exifData.exifVersion || '-' },
    ] as ExifItem[]
  }

  // 镜头参数
  private getLensParams(): ExifItem[] {
    if (!this.record) return []
    return [
      { label: '镜头型号', value: this.record.exifData.lensModel || '-' },
      { label: '镜头品牌', value: this.record.exifData.lensMake || '-' },
      { label: '镜头序列号', value: this.record.exifData.lensSerialNumber || '-' },
      { label: '最大光圈', value: this.record.exifData.maxAperture || '-' },
      { label: '主体距离', value: this.record.exifData.subjectDistance || '-' },
    ] as ExifItem[]
  }

  // GPS定位
  private getGpsParams(): ExifItem[] {
    if (!this.record) return []
    const lat = this.record.exifData.gpsLatitude
    const lon = this.record.exifData.gpsLongitude
    const alt = this.record.exifData.gpsAltitude
    const latRef = this.record.exifData.gpsLatitudeRef
    const lonRef = this.record.exifData.gpsLongitudeRef
    const altRef = this.record.exifData.gpsAltitudeRef
    
    return [
      { label: 'GPS纬度', value: lat ? `${lat.toFixed(6)}° ${latRef || ''}` : '-' },
      { label: 'GPS经度', value: lon ? `${lon.toFixed(6)}° ${lonRef || ''}` : '-' },
      { label: 'GPS海拔', value: alt ? `${alt.toFixed(1)}m ${altRef || ''}` : '-' },
      { label: 'GPS海拔参考', value: this.record.exifData.gpsAltitudeRef || '-' },
      { label: 'GPS速度', value: this.record.exifData.gpsSpeed || '-' },
      { label: 'GPS图像方向', value: this.record.exifData.gpsImgDirection || '-' },
      { label: 'GPS时间戳', value: this.record.exifData.gpsTimeStamp || '-' },
      { label: 'GPS日期戳', value: this.record.exifData.gpsDateStamp || '-' },
      { label: 'GPS处理方法', value: this.record.exifData.gpsProcessingMethod || '-' },
    ] as ExifItem[]
  }

  // 时间信息
  private getTimeParams(): ExifItem[] {
    if (!this.record) return []
    const dt = this.record.exifData.dateTime
    const subSec = this.record.exifData.subSecTime
    const dtWithSubSec = (dt && subSec) ? `${dt}.${subSec}` : (dt || '-')
    
    return [
      { label: '拍摄时间', value: dtWithSubSec },
      { label: '原始拍摄时间', value: this.record.exifData.dateTimeOriginal || '-' },
      { label: '数字化时间', value: this.record.exifData.dateTimeDigitized || '-' },
      { label: '亚秒时间', value: this.record.exifData.subSecTime || '-' },
      { label: '亚秒时间(原始)', value: this.record.exifData.subSecTimeOriginal || '-' },
      { label: '亚秒时间(数字化)', value: this.record.exifData.subSecTimeDigitized || '-' },
    ] as ExifItem[]
  }

  // 图像属性
  private getImageParams(): ExifItem[] {
    if (!this.record) return []
    const width = this.record.exifData.imageWidth
    const height = this.record.exifData.imageHeight
    const sizeStr = (width && height) ? `${width} × ${height}` : '-'
    
    const pixelX = this.record.exifData.pixelXDimension
    const pixelY = this.record.exifData.pixelYDimension
    const pixelStr = (pixelX && pixelY) ? `${pixelX} × ${pixelY}` : '-'
    
    return [
      { label: '图像尺寸', value: sizeStr },
      { label: '有效像素尺寸', value: pixelStr },
      { label: '图像方向', value: this.record.exifData.orientation || '-' },
      { label: '色彩空间', value: this.record.exifData.colorSpace || '-' },
      { label: '每样本位数', value: this.record.exifData.bitsPerSample || '-' },
      { label: '每像素样本数', value: this.record.exifData.samplesPerPixel || '-' },
      { label: '分量配置', value: this.record.exifData.componentsConfiguration || '-' },
    ] as ExifItem[]
  }

  // === P1 进阶参数 ===
  // 曝光控制
  private getExposureParams(): ExifItem[] {
    if (!this.record) return []
    return [
      { label: '曝光补偿', value: this.record.exifData.exposureCompensation || '-' },
      { label: '曝光模式', value: this.record.exifData.exposureMode || '-' },
      { label: '曝光程序', value: this.record.exifData.exposureProgram || '-' },
      { label: '测光模式', value: this.record.exifData.meteringMode || '-' },
      { label: '曝光指数', value: this.record.exifData.exposureIndex || '-' },
    ] as ExifItem[]
  }

  // 闪光灯
  private getFlashParams(): ExifItem[] {
    if (!this.record) return []
    return [
      { label: '闪光灯', value: this.record.exifData.flash || '-' },
      { label: '闪光灯能量', value: this.record.exifData.flashEnergy || '-' },
      { label: '光源类型', value: this.record.exifData.lightSource || '-' },
    ] as ExifItem[]
  }

  // 对焦测距
  private getFocusParams(): ExifItem[] {
    if (!this.record) return []
    return [
      { label: '主体距离', value: this.record.exifData.subjectDistance || '-' },
      { label: '主体距离范围', value: this.record.exifData.subjectDistanceRange || '-' },
      { label: '主体区域', value: this.record.exifData.subjectArea || '-' },
      { label: '主体位置', value: this.record.exifData.subjectLocation || '-' },
      { label: '感光方式', value: this.record.exifData.sensingMethod || '-' },
    ] as ExifItem[]
  }

  // 白平衡与色彩
  private getColorParams(): ExifItem[] {
    if (!this.record) return []
    return [
      { label: '白平衡', value: this.record.exifData.whiteBalance || '-' },
      { label: '色彩空间', value: this.record.exifData.colorSpace || '-' },
      { label: '白点', value: this.record.exifData.whitePoint || '-' },
      { label: '原色度', value: this.record.exifData.primaryChromaticities || '-' },
      { label: 'YCbCr系数', value: this.record.exifData.yCbCrCoefficients || '-' },
    ] as ExifItem[]
  }

  // 图像调整
  private getAdjustmentParams(): ExifItem[] {
    if (!this.record) return []
    return [
      { label: '对比度', value: this.record.exifData.contrast || '-' },
      { label: '饱和度', value: this.record.exifData.saturation || '-' },
      { label: '锐度', value: this.record.exifData.sharpness || '-' },
      { label: '亮度值', value: this.record.exifData.brightness || '-' },
      { label: '增益控制', value: this.record.exifData.gainControl || '-' },
      { label: '自定义渲染', value: this.record.exifData.customRendered || '-' },
    ] as ExifItem[]
  }

  // 拍摄模式
  private getSceneParams(): ExifItem[] {
    if (!this.record) return []
    return [
      { label: '场景捕获类型', value: this.record.exifData.sceneCaptureType || '-' },
      { label: '场景类型', value: this.record.exifData.sceneType || '-' },
      { label: '数字变焦比', value: this.record.exifData.digitalZoomRatio || '-' },
      { label: '光谱灵敏度', value: this.record.exifData.spectalSensitivity || '-' },
    ] as ExifItem[]
  }

  // === P2 技术参数 ===
  // 分辨率参数
  private getResolutionParams(): ExifItem[] {
    if (!this.record) return []
    const xRes = this.record.exifData.xResolution
    const yRes = this.record.exifData.yResolution
    const unit = this.record.exifData.resolutionUnit
    const resStr = (xRes && yRes && unit) ? `${xRes} × ${yRes} ${unit}` : '-'
    
    const fpXRes = this.record.exifData.focalPlaneXResolution
    const fpYRes = this.record.exifData.focalPlaneYResolution
    const fpUnit = this.record.exifData.focalPlaneResolutionUnit
    
    return [
      { label: '图像分辨率', value: resStr },
      { label: '焦平面X分辨率', value: fpXRes !== undefined && fpXRes > 0 ? fpXRes.toString() : '-' },
      { label: '焦平面Y分辨率', value: fpYRes !== undefined && fpYRes > 0 ? fpYRes.toString() : '-' },
      { label: '焦平面分辨率单位', value: fpUnit || '-' },
    ] as ExifItem[]
  }

  // 文件元数据
  private getMetadataParams(): ExifItem[] {
    if (!this.record) return []
    return [
      { label: '图片描述', value: this.record.exifData.imageDescription || '-' },
      { label: '作者', value: this.record.exifData.artist || '-' },
      { label: '版权', value: this.record.exifData.copyright || '-' },
      { label: '用户评论', value: this.record.exifData.userComment || '-' },
      { label: '制造商注释', value: this.record.exifData.makerNote || '-' },
      { label: '相关音频文件', value: this.record.exifData.relatedSoundFile || '-' },
      { label: '设备设置描述', value: this.record.exifData.deviceSettingDescription || '-' },
    ] as ExifItem[]
  }

  // 技术参数
  private getTechnicalParams(): ExifItem[] {
    if (!this.record) return []
    return [
      { label: '压缩方式', value: this.record.exifData.compression || '-' },
      { label: '光度解释', value: this.record.exifData.photometricInterpretation || '-' },
      { label: '传输函数', value: this.record.exifData.transferFunction || '-' },
      { label: '参考黑白值', value: this.record.exifData.referenceBlackWhite || '-' },
      { label: '光电转换函数', value: this.record.exifData.oecf || '-' },
      { label: '文件源', value: this.record.exifData.fileSource || '-' },
      { label: 'CFA图案', value: this.record.exifData.cFAPattern || '-' },
      { label: 'FlashPix版本', value: this.record.exifData.flashpixVersion || '-' },
      { label: 'ISO速率', value: this.record.exifData.isoSpeedRatings || '-' },
      { label: 'YCbCr定位', value: this.record.exifData.yCbCrPositioning || '-' },
      { label: '图片长度', value: this.record.exifData.imageLength?.toString() || '-' },
      { label: '缩略图宽度', value: this.record.exifData.thumbnailImageWidth?.toString() || '-' },
      { label: '缩略图高度', value: this.record.exifData.thumbnailImageHeight?.toString() || '-' },
    ] as ExifItem[]
  }

  // === P0 DNG专有参数（Phase 2新增）===
  private getDngParams(): ExifItem[] {
    if (!this.record) return []
    return [
      { label: 'DNG版本', value: this.record.exifData.dngVersion || '-' },
      { label: 'DNG向后兼容版本', value: this.record.exifData.dngBackwardVersion || '-' },
      { label: '唯一相机型号', value: this.record.exifData.uniqueCameraModel || '-' },
      { label: '相机序列号(DNG)', value: this.record.exifData.cameraSerialNumberDNG || '-' },
      { label: 'DNG镜头信息', value: this.record.exifData.dngLensInfo || '-' },
      { label: '原始RAW文件名', value: this.record.exifData.originalRawFilename || '-' },
      { label: '基准曝光', value: this.record.exifData.baselineExposure ? `${this.record.exifData.baselineExposure.toFixed(2)} EV` : '-' },
      { label: '基准噪点', value: this.record.exifData.baselineNoise ? this.record.exifData.baselineNoise.toFixed(2) : '-' },
      { label: '基准锐度', value: this.record.exifData.baselineSharpness ? this.record.exifData.baselineSharpness.toFixed(2) : '-' },
      { label: '线性响应限制', value: this.record.exifData.linearResponseLimit ? this.record.exifData.linearResponseLimit.toFixed(2) : '-' },
      { label: '阴影缩放', value: this.record.exifData.shadowScale ? this.record.exifData.shadowScale.toFixed(2) : '-' },
      { label: '预览色彩空间', value: this.record.exifData.previewColorSpace || '-' },
    ] as ExifItem[]
  }

  @Builder
  ExifSection(title: string, items: ExifItem[]) {
    Column() {
      // 标题（带字段数统计 + 展开/折叠图标）
      Row() {
        // 展开/折叠图标
        Text(this.expandedGroups.has(title) ? '▼' : '▶')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ right: 8 })
        
        Text(title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        
        Blank()
        
        Text(`${this.getSectionFieldCount(items).nonEmpty}/${this.getSectionFieldCount(items).total}`)
          .fontSize(13)
          .fontColor('#999999')
      }
      .width('100%')
      .margin({ bottom: this.expandedGroups.has(title) ? 12 : 0 })
      .onClick(() => {
        this.toggleGroup(title)
      })
      
      // 字段列表（条件渲染 - 只渲染已展开的分组）
      if (this.expandedGroups.has(title)) {
        Column() {
          ForEach(items, (item: ExifItem, index: number) => {
          Row() {
            Text(item.label)
              .fontSize(13)
              .fontColor('#666666')
              .width(120)
            
            Text(item.value)
              .fontSize(13)
              .fontColor(item.value === '-' ? '#CCCCCC' : '#333333')
              .fontWeight(item.value === '-' ? FontWeight.Normal : FontWeight.Medium)
              .layoutWeight(1)
              .textAlign(TextAlign.End)
          }
          .width('100%')
          .height(36)
          .padding({ left: 12, right: 12 })
          .backgroundColor(index % 2 === 0 ? '#FAFAFA' : Color.White)
        })
      }
      .width('100%')
      .borderRadius(8)
      .clip(true)
    }  // if条件渲染结束
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ top: 12 })
    .alignItems(HorizontalAlign.Start)
  }
}
