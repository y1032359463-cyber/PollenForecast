/**
 * 照片详情页 - 显示完整EXIF参数
 */
import { PhotoRecord } from '../models/PhotoRecord'
import { Router, promptAction } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { DataStorageService } from '../services/DataStorageService'
import { common } from '@kit.AbilityKit'

interface RouteParams {
  record: PhotoRecord
  isNew?: boolean  // 是否新建笔记
}

// 参数项接口
interface ParamItem {
  label: string
  value: string
}

@Entry
@Component
struct PhotoDetailPage {
  @State record: PhotoRecord | null = null
  @State noteTitle: string = ''  // 笔记标题
  @State noteText: string = ''   // 笔记内容
  @State isSaving: boolean = false  // 保存状态
  @State isNewNote: boolean = false  // 是否新建模式
  @State showHint: boolean = false  // 显示提示
  private storageService: DataStorageService | null = null

  async aboutToAppear(): Promise<void> {
    const routerInstance: Router = this.getUIContext().getRouter()
    const params = routerInstance.getParams() as RouteParams
    if (params && params.record) {
      this.record = params.record
      this.noteTitle = this.record.noteTitle || ''
      this.noteText = this.record.note || ''
      this.isNewNote = params.isNew || false
      
      // 新建模式：显示提示引导用户写笔记
      if (this.isNewNote) {
        this.showHint = true
        hilog.info(0x0021, 'UI', '[Detail] 新建笔记模式')
      }
      
      hilog.info(0x0021, 'UI', '[Detail] 加载记录:' + this.record.id)
    }
    
    // 初始化存储服务
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    this.storageService = new DataStorageService(context)
    await this.storageService.initialize()
  }

  // 跳转到完整EXIF数据页
  private goToAllExifData(): void {
    if (!this.record) return
    this.getUIContext().getRouter().pushUrl({
      url: 'pages/AllExifDataPage',
      params: { record: this.record }
    }).catch((err: Error) => {
      hilog.error(0x0021, 'UI', '[Detail] 跳转失败:' + err)
    })
  }

  // 处理返回按钮
  private handleBack(): void {
    if (this.isNewNote && !this.noteTitle && !this.noteText) {
      // 新建且未填写任何内容，询问是否放弃
      promptAction.showDialog({
        title: '放弃笔记',
        message: '还没写笔记内容，确定放弃吗？',
        buttons: [
          { text: '继续编辑', color: '#007AFF' },
          { text: '放弃', color: '#FF3B30' }
        ]
      }).then((result: promptAction.ShowDialogSuccessResponse) => {
        if (result.index === 1) {
          // 放弃，删除空记录
          this.deleteEmptyRecord()
        }
      })
    } else {
      this.getUIContext().getRouter().back()
    }
  }
  
  // 删除空记录（用于取消新建）
  private async deleteEmptyRecord(): Promise<void> {
    if (!this.record || !this.storageService) {
      this.getUIContext().getRouter().back()
      return
    }
    
    try {
      await this.storageService.deleteRecord(this.record.id)
      hilog.info(0x0021, 'UI', '[Detail] 已删除空记录')
    } catch (error) {
      hilog.error(0x0021, 'UI', '[Detail] 删除记录失败:' + error)
    }
    
    this.getUIContext().getRouter().back()
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#333333')
          .onClick(() => this.handleBack())
        
        Text(this.isNewNote ? '新建笔记' : '参数详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 16 })
        
        Blank()
        
        // 新建模式显示保存按钮
        if (this.isNewNote) {
          Text(this.isSaving ? '保存中...' : '完成')
            .fontSize(16)
            .fontColor(this.isSaving ? '#999999' : '#007AFF')
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              if (!this.isSaving) {
                this.saveNote()
              }
            })
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      // 新建模式引导提示
      if (this.showHint && this.isNewNote) {
        Row() {
          Text('💡')
            .fontSize(18)
          Text('写下这张照片的拍摄心得吧～')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 8 })
          Blank()
          Text('×')
            .fontSize(18)
            .fontColor('#999999')
            .onClick(() => { this.showHint = false })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 10, bottom: 10 })
        .backgroundColor('#FFF4E5')
      }

      if (this.record) {
        // 参数列表
        Scroll() {
          Column() {
            // 笔记编辑卡片始终在顶部（统一体验）
            this.NoteEditCard()
            
            // 核心参数卡片
            this.ParamCard('📸 拍摄参数', this.getShootingParams())

            // 相机信息卡片
            this.ParamCard('📷 设备信息', this.getDeviceParams())

            // 曝光控制卡片
            this.ParamCard('🔆 曝光控制', this.getExposureParams())

            // 图像属性卡片
            this.ParamCard('🖼️ 图像属性', this.getImageParams())

            // 时间位置卡片
            this.ParamCard('📅 时间位置', this.getLocationParams())

            // 查看完整EXIF按钮
            Button('查看完整EXIF数据 →')
              .width('100%')
              .height(48)
              .fontSize(15)
              .fontColor('#007AFF')
              .backgroundColor('#F0F7FF')
              .borderRadius(12)
              .margin({ top: 16, bottom: 16 })
              .onClick(() => {
                this.goToAllExifData()
              })
          }
          .padding(16)
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        // 空状态
        Column() {
          Text('❌')
            .fontSize(48)
          Text('无法加载照片详情')
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

  // 获取拍摄参数
  private getShootingParams(): ParamItem[] {
    if (!this.record) return []
    const params: ParamItem[] = []
    if (this.record.exifData.aperture) {
      params.push({ label: '光圈', value: this.record.exifData.aperture } as ParamItem)
    }
    if (this.record.exifData.shutterSpeed) {
      params.push({ label: '快门', value: this.record.exifData.shutterSpeed } as ParamItem)
    }
    if (this.record.exifData.iso > 0) {
      params.push({ label: 'ISO', value: `ISO ${this.record.exifData.iso}` } as ParamItem)
    }
    if (this.record.exifData.focalLength) {
      params.push({ label: '焦距', value: this.record.exifData.focalLength } as ParamItem)
    }
    if (this.record.exifData.focalLengthIn35mm) {
      params.push({ label: '等效焦距', value: this.record.exifData.focalLengthIn35mm } as ParamItem)
    }
    if (this.record.exifData.maxAperture) {
      params.push({ label: '最大光圈', value: this.record.exifData.maxAperture } as ParamItem)
    }
    return params
  }

  // 获取设备参数
  private getDeviceParams(): ParamItem[] {
    if (!this.record) return []
    const params: ParamItem[] = []
    if (this.record.exifData.cameraMake) {
      params.push({ label: '相机品牌', value: this.record.exifData.cameraMake } as ParamItem)
    }
    if (this.record.exifData.cameraModel) {
      params.push({ label: '相机型号', value: this.record.exifData.cameraModel } as ParamItem)
    }
    if (this.record.exifData.lensModel) {
      params.push({ label: '镜头型号', value: this.record.exifData.lensModel } as ParamItem)
    }
    if (this.record.exifData.lensMake) {
      params.push({ label: '镜头品牌', value: this.record.exifData.lensMake } as ParamItem)
    }
    if (this.record.exifData.software) {
      params.push({ label: '软件', value: this.record.exifData.software } as ParamItem)
    }
    return params
  }

  // 获取位置参数
  private getLocationParams(): ParamItem[] {
    if (!this.record) return []
    const params: ParamItem[] = []
    if (this.record.exifData.dateTime) {
      params.push({ label: '拍摄时间', value: this.record.exifData.dateTime } as ParamItem)
    }
    if (this.record.exifData.gpsLatitude) {
      params.push({ label: 'GPS纬度', value: `${this.record.exifData.gpsLatitude.toFixed(6)}` } as ParamItem)
    }
    if (this.record.exifData.gpsLongitude) {
      params.push({ label: 'GPS经度', value: `${this.record.exifData.gpsLongitude.toFixed(6)}` } as ParamItem)
    }
    if (this.record.exifData.gpsAltitude) {
      params.push({ label: 'GPS海拔', value: `${this.record.exifData.gpsAltitude.toFixed(1)}m` } as ParamItem)
    }
    return params
  }

  // 获取曝光参数
  private getExposureParams(): ParamItem[] {
    if (!this.record) return []
    const params: ParamItem[] = []
    if (this.record.exifData.exposureMode) {
      params.push({ label: '曝光模式', value: this.record.exifData.exposureMode } as ParamItem)
    }
    if (this.record.exifData.exposureProgram) {
      params.push({ label: '曝光程序', value: this.record.exifData.exposureProgram } as ParamItem)
    }
    if (this.record.exifData.exposureCompensation) {
      params.push({ label: '曝光补偿', value: this.record.exifData.exposureCompensation } as ParamItem)
    }
    if (this.record.exifData.meteringMode) {
      params.push({ label: '测光模式', value: this.record.exifData.meteringMode } as ParamItem)
    }
    if (this.record.exifData.whiteBalance) {
      params.push({ label: '白平衡', value: this.record.exifData.whiteBalance } as ParamItem)
    }
    if (this.record.exifData.flash) {
      params.push({ label: '闪光灯', value: this.record.exifData.flash } as ParamItem)
    }
    if (this.record.exifData.brightness) {
      params.push({ label: '亮度', value: this.record.exifData.brightness } as ParamItem)
    }
    return params
  }

  // 获取图像属性
  private getImageParams(): ParamItem[] {
    if (!this.record) return []
    const params: ParamItem[] = []
    if (this.record.exifData.imageWidth && this.record.exifData.imageHeight) {
      params.push({ label: '尺寸', value: `${this.record.exifData.imageWidth} × ${this.record.exifData.imageHeight}` } as ParamItem)
    }
    if (this.record.exifData.orientation) {
      params.push({ label: '方向', value: this.record.exifData.orientation } as ParamItem)
    }
    if (this.record.exifData.colorSpace) {
      params.push({ label: '色彩空间', value: this.record.exifData.colorSpace } as ParamItem)
    }
    if (this.record.exifData.contrast) {
      params.push({ label: '对比度', value: this.record.exifData.contrast } as ParamItem)
    }
    if (this.record.exifData.saturation) {
      params.push({ label: '饱和度', value: this.record.exifData.saturation } as ParamItem)
    }
    if (this.record.exifData.sharpness) {
      params.push({ label: '锐度', value: this.record.exifData.sharpness } as ParamItem)
    }
    if (this.record.exifData.sceneType) {
      params.push({ label: '场景类型', value: this.record.exifData.sceneType } as ParamItem)
    }
    if (this.record.exifData.exifVersion) {
      params.push({ label: 'EXIF版本', value: this.record.exifData.exifVersion } as ParamItem)
    }
    return params
  }

  @Builder
  ParamCard(title: string, params: ParamItem[]) {
    Column() {
      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .margin({ bottom: 12 })

      if (params.length > 0) {
        ForEach(params, (item: ParamItem) => {
          Row() {
            Text(item.label)
              .fontSize(14)
              .fontColor('#666666')
              .width(100)
            
            Text(item.value)
              .fontSize(14)
              .fontColor('#333333')
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
              .textAlign(TextAlign.End)
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
        })
      } else {
        Text('暂无数据')
          .fontSize(13)
          .fontColor('#999999')
          .fontStyle(FontStyle.Italic)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ top: 12 })
    .alignItems(HorizontalAlign.Start)
  }

  // 笔记编辑卡片
  @Builder
  NoteEditCard() {
    Column() {
      Row() {
        Text('📝 拍摄笔记')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
        
        Blank()
        
        Text(`${this.noteText.length}/500`)
          .fontSize(12)
          .fontColor(this.noteText.length > 500 ? '#FF3B30' : '#999999')
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 笔记标题
      TextInput({ placeholder: '笔记标题（如：逆光人像心得）', text: this.noteTitle })
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .maxLength(50)
        .onChange((value: string) => {
          this.noteTitle = value
        })
      
      // 笔记正文
      TextArea({ placeholder: '详细记录拍摄参数、光线条件、后期思路...', text: this.noteText })
        .width('100%')
        .height(this.isNewNote ? 180 : 120)
        .fontSize(14)
        .fontColor('#333333')
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .margin({ top: 12 })
        .maxLength(500)
        .onChange((value: string) => {
          this.noteText = value
        })

      // 非新建模式才显示保存按钮
      if (!this.isNewNote) {
        Button(this.isSaving ? '保存中...' : '保存笔记')
          .width('100%')
          .height(44)
          .fontSize(15)
          .fontColor(Color.White)
          .backgroundColor(this.isSaving ? '#CCCCCC' : '#007AFF')
          .borderRadius(8)
          .margin({ top: 12 })
          .enabled(!this.isSaving)
          .onClick(() => {
            this.saveNote()
          })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ top: this.isNewNote ? 0 : 12 })
    .alignItems(HorizontalAlign.Start)
  }

  // 保存笔记
  private async saveNote(): Promise<void> {
    if (!this.record) return
    
    // 字数限制检查
    if (this.noteText.length > 500) {
      promptAction.showToast({
        message: '笔记不能超过500字',
        duration: 2000
      })
      return
    }
    
    try {
      this.isSaving = true
      
      // 更新记录（标题+正文）
      this.record.noteTitle = this.noteTitle
      this.record.note = this.noteText
      this.record.updateTime = Date.now()
      
      // 保存到存储
      if (this.storageService) {
        await this.storageService.saveRecord(this.record)
        hilog.info(0x0021, 'UI', '[Detail] 笔记已保存: ' + this.noteTitle)
        
        promptAction.showToast({
          message: this.isNewNote ? '笔记已创建' : '笔记保存成功',
          duration: 1500
        })
        
        // 新建模式保存后返回首页
        if (this.isNewNote) {
          this.isNewNote = false  // 标记为已保存
          this.getUIContext().getRouter().back()
        }
      } else {
        throw new Error('存储服务未初始化')
      }
    } catch (error) {
      hilog.error(0x0021, 'UI', '[Detail] 保存笔记失败: ' + error)
      promptAction.showToast({
        message: '保存失败，请重试',
        duration: 2000
      })
    } finally {
      this.isSaving = false
    }
  }
}
