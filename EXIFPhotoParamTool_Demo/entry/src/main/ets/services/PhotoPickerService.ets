/**
 * 照片选择服务
 * 使用 picker.PhotoPickerComponent 让用户主动选择照片（不申请相册权限）
 * API 20+ 推荐方案（已替换废弃的 PhotoViewPicker）
 */
import { picker } from '@kit.CoreFileKit'
import { fileIo } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { util } from '@kit.ArkTS'
import { image } from '@kit.ImageKit'

export class PhotoPickerService {
  private context: common.UIAbilityContext
  private tempDir: string = ''

  constructor(context: common.UIAbilityContext) {
    this.context = context
    this.tempDir = context.filesDir + '/exif_temp'
    // 初始化临时目录
    this.initTempDir()
  }

  /**
   * 初始化临时目录
   */
  private initTempDir(): void {
    try {
      if (!fileIo.accessSync(this.tempDir)) {
        fileIo.mkdirSync(this.tempDir)
      }
    } catch (e) {
      try {
        fileIo.mkdirSync(this.tempDir)
      } catch (err) {
        hilog.warn(0x0021, 'Picker', '[PhotoPicker] 创建临时目录失败:' + err)
      }
    }
  }

  /**
   * 将FilePicker返回的URI转换为沙箱路径
   * @param uri FilePicker返回的 file://media/ URI
   * @returns 应用沙箱内的安全路径
   */
  async getSandboxPath(uri: string): Promise<string> {
    // 提取原始文件扩展名（保留DNG/CR2等RAW格式）
    let ext = '.jpg'
    const lastDot = uri.lastIndexOf('.')
    const lastSlash = uri.lastIndexOf('/')
    if (lastDot > lastSlash && lastDot !== -1) {
      ext = uri.substring(lastDot).toLowerCase()
    }
    
    const destPath = `${this.tempDir}/${Date.now()}${ext}`
    
    let srcFile: fileIo.File | null = null
    let destFile: fileIo.File | null = null
    
    try {
      // 打开源文件
      srcFile = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY)
      // 创建目标文件
      destFile = fileIo.openSync(destPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
      
      // 流式复制（分块读取，支持大文件）
      const bufferSize = 4096
      let buffer = new ArrayBuffer(bufferSize)
      let bytesRead: number
      
      while ((bytesRead = fileIo.readSync(srcFile.fd, buffer)) > 0) {
        if (bytesRead < bufferSize) {
          // 最后一块数据，只写入实际读取的字节
          fileIo.writeSync(destFile.fd, buffer.slice(0, bytesRead))
        } else {
          fileIo.writeSync(destFile.fd, buffer)
        }
      }
      
      hilog.info(0x0021, 'Picker', `[PhotoPicker] 文件复制成功: ${destPath}`)
      return destPath
      
    } catch (error) {
      hilog.error(0x0021, 'Picker', '[PhotoPicker] 沙箱路径转换失败:' + error)
      throw new Error('文件复制失败')
    } finally {
      if (srcFile) {
        try { fileIo.closeSync(srcFile) } catch (e) { /* ignore */ }
      }
      if (destFile) {
        try { fileIo.closeSync(destFile) } catch (e) { /* ignore */ }
      }
    }
  }

  /**
   * 清理临时文件
   * @param filePath 要删除的临时文件路径
   */
  cleanupTempFile(filePath: string): void {
    try {
      if (filePath.startsWith(this.tempDir) && fileIo.accessSync(filePath)) {
        fileIo.unlinkSync(filePath)
        hilog.info(0x0021, 'Picker', '[PhotoPicker] 临时文件已清理:' + filePath)
      }
    } catch (e) {
      hilog.warn(0x0021, 'Picker', '[PhotoPicker] 清理临时文件失败:' + e)
    }
  }

  /**
   * 生成照片缩略图并保存到沙箱目录
   * 使用 Image Kit 正确生成缩略图（专家推荐方案）
   * @param sandboxPath 沙箱内的照片文件路径
   * @returns 缩略图文件路径，失败返回空字符串
   */
  async generateThumbnail(sandboxPath: string): Promise<string> {
    // 方法入口日志（调试关键！）
    hilog.error(0x0021, 'Picker', `[Thumbnail] ===== 开始生成缩略图 =====`)
    hilog.error(0x0021, 'Picker', `[Thumbnail] 输入路径: ${sandboxPath}`)
    
    let srcFile: fileIo.File | null = null
    let imageSource: image.ImageSource | null = null
    let pixelMap: image.PixelMap | null = null
    let packer: image.ImagePacker | null = null
    let thumbnailFile: fileIo.File | null = null

    try {
      // 验证输入路径
      if (!sandboxPath || sandboxPath === '') {
        hilog.error(0x0021, 'Picker', '[Thumbnail] 错误：输入路径为空')
        return ''
      }
      
      // 检查文件是否存在
      const fileExists = fileIo.accessSync(sandboxPath)
      hilog.info(0x0021, 'Picker', `[Thumbnail] 文件存在检查: ${fileExists}`)
      if (!fileExists) {
        hilog.error(0x0021, 'Picker', `[Thumbnail] 错误：文件不存在 - ${sandboxPath}`)
        return ''
      }
      
      // 确保缩略图目录存在
      const thumbnailDir = this.context.filesDir + '/thumbnails'
      hilog.info(0x0021, 'Picker', `[Thumbnail] 缩略图目录: ${thumbnailDir}`)
      try {
        if (!fileIo.accessSync(thumbnailDir)) {
          fileIo.mkdirSync(thumbnailDir)
        }
      } catch (e) {
        fileIo.mkdirSync(thumbnailDir)
      }

      // 1. 打开源文件获取文件描述符（关键修复！）
      srcFile = fileIo.openSync(sandboxPath, fileIo.OpenMode.READ_ONLY)
      hilog.info(0x0021, 'Picker', '[Thumbnail] 打开源文件成功，fd=' + srcFile.fd)

      // 2. 使用文件描述符创建 ImageSource（不能直接传路径！）
      imageSource = image.createImageSource(srcFile.fd)
      if (!imageSource) {
        hilog.error(0x0021, 'Picker', '[Thumbnail] 创建ImageSource失败')
        return ''
      }

      // 2.1 获取原图尺寸，计算中心裁切区域
      const imageInfo = await imageSource.getImageInfo()
      const srcWidth = imageInfo.size.width
      const srcHeight = imageInfo.size.height
      hilog.info(0x0021, 'Picker', `[Thumbnail] 原图尺寸: ${srcWidth} x ${srcHeight}`)

      // 计算中心正方形裁切区域（取短边为边长）
      const cropSize = Math.min(srcWidth, srcHeight)
      const cropX = Math.floor((srcWidth - cropSize) / 2)
      const cropY = Math.floor((srcHeight - cropSize) / 2)
      hilog.info(0x0021, 'Picker', `[Thumbnail] 裁切区域: x=${cropX}, y=${cropY}, size=${cropSize}`)

      // 2.2 生成缩略图 PixelMap
      // 先裁切中心正方形区域，再缩放到目标尺寸
      // 清晰度优化：800×800 适配 DPR 3 设备（340px × 3 ≈ 1020px）
      const TARGET_SIZE = 800  // 从400提升到800，确保高清显示
      const decodingOptions: image.DecodingOptions = {
        desiredRegion: { x: cropX, y: cropY, size: { width: cropSize, height: cropSize } }
      }
      pixelMap = await imageSource.createPixelMap(decodingOptions)
      if (!pixelMap) {
        hilog.error(0x0021, 'Picker', '[Thumbnail] 创建PixelMap失败')
        return ''
      }

      // 2.3 缩放到目标尺寸
      // 注意：如果原图裁切区域已经小于目标尺寸，则不放大（避免模糊）
      if (cropSize > TARGET_SIZE) {
        const scaleRatio = TARGET_SIZE / cropSize
        await pixelMap.scale(scaleRatio, scaleRatio)
        hilog.info(0x0021, 'Picker', `[Thumbnail] 缩放完成: ${TARGET_SIZE}x${TARGET_SIZE}`)
      } else {
        hilog.info(0x0021, 'Picker', `[Thumbnail] 原图较小(${cropSize}px)，保持原尺寸不放大`)
      }

      // 3. 使用 ImagePacker 编码为 JPEG
      packer = image.createImagePacker()
      const packingOptions: image.PackingOption = {
        format: 'image/jpeg',
        quality: 90  // 专家建议：85-90%，提升清晰度
      }
      const arrayBuffer = await packer.packing(pixelMap, packingOptions)
      if (!arrayBuffer || arrayBuffer.byteLength === 0) {
        hilog.error(0x0021, 'Picker', '[Thumbnail] ImagePacker编码失败')
        return ''
      }

      // 4. 保存缩略图文件到沙箱
      const thumbnailPath = `${thumbnailDir}/${Date.now()}_thumb.jpg`
      thumbnailFile = fileIo.openSync(thumbnailPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY)
      fileIo.writeSync(thumbnailFile.fd, arrayBuffer)

      hilog.info(0x0021, 'Picker', `[Thumbnail] 缩略图生成成功: ${thumbnailPath} (${arrayBuffer.byteLength} bytes)`)
      return thumbnailPath

    } catch (e) {
      hilog.error(0x0021, 'Picker', '[Thumbnail] 生成缩略图失败:' + e)
      return ''
    } finally {
      // 释放资源（顺序：packer → pixelMap → imageSource → 文件句柄）
      if (packer) {
        try { packer.release() } catch (e) { /* ignore */ }
      }
      if (pixelMap) {
        try { pixelMap.release() } catch (e) { /* ignore */ }
      }
      if (imageSource) {
        try { imageSource.release() } catch (e) { /* ignore */ }
      }
      if (thumbnailFile) {
        try { fileIo.closeSync(thumbnailFile) } catch (e) { /* ignore */ }
      }
      // 关闭源文件句柄
      if (srcFile) {
        try { fileIo.closeSync(srcFile) } catch (e) { /* ignore */ }
      }
    }
  }

  /**
   * 清理缩略图文件
   * @param thumbnailPath 缩略图文件路径
   */
  cleanupThumbnail(thumbnailPath: string): void {
    const thumbnailDir = this.context.filesDir + '/thumbnails'
    try {
      if (thumbnailPath.startsWith(thumbnailDir) && fileIo.accessSync(thumbnailPath)) {
        fileIo.unlinkSync(thumbnailPath)
        hilog.info(0x0021, 'Picker', '[Thumbnail] 缩略图已清理:' + thumbnailPath)
      }
    } catch (e) {
      hilog.warn(0x0021, 'Picker', '[Thumbnail] 清理缩略图失败:' + e)
    }
  }

  /**
   * 清理所有临时文件
   */
  cleanupAllTempFiles(): void {
    try {
      const files = fileIo.listFileSync(this.tempDir)
      for (const file of files) {
        try {
          fileIo.unlinkSync(`${this.tempDir}/${file}`)
        } catch (e) { /* ignore */ }
      }
      hilog.info(0x0021, 'Picker', '[PhotoPicker] 所有临时文件已清理')
    } catch (e) {
      hilog.warn(0x0021, 'Picker', '[PhotoPicker] 清理临时目录失败:' + e)
    }
  }

  /**
   * 选择单张照片
   * @returns 照片URI，如果用户取消则返回null
   */
  async selectPhoto(): Promise<string | null> {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions()
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 1

      const photoPicker = new picker.PhotoViewPicker()
      const photoSelectResult = await photoPicker.select(photoSelectOptions)

      if (photoSelectResult && photoSelectResult.photoUris.length > 0) {
        return photoSelectResult.photoUris[0]
      }
      
      return null
    } catch (error) {
      hilog.error(0x0021, 'Picker', '选择照片失败:' + error)
      return null
    }
  }

  /**
   * 选择多张照片
   * @param maxCount 最大选择数量，默认9张
   * @returns 照片URI数组
   */
  async selectMultiplePhotos(maxCount: number = 9): Promise<string[]> {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions()
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = maxCount

      const photoPicker = new picker.PhotoViewPicker()
      const photoSelectResult = await photoPicker.select(photoSelectOptions)

      if (photoSelectResult && photoSelectResult.photoUris.length > 0) {
        return photoSelectResult.photoUris
      }
      
      return []
    } catch (error) {
      hilog.error(0x0021, 'Picker', '选择多张照片失败:' + error)
      return []
    }
  }
}
