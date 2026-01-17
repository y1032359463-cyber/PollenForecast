/**
 * 主页面 - 光影备忘录
 * 
 * 2025-12-25 重构：简洁卡片式首页
 * - 笔记标题 + 核心参数一行
 * - 左滑删除（swipeAction）
 * - 点击进入详情页编辑
 */
import { common } from '@kit.AbilityKit'
import { UIStyle, PhotoRecord, ExifData } from '../models/PhotoRecord'
import { PhotoRecordDataSource } from '../models/LazyDataSource'
import { PreferenceService } from '../services/PreferenceService'
import { PhotoPickerService } from '../services/PhotoPickerService'
import { ExifParserService } from '../services/ExifParserService'
import { DataStorageService } from '../services/DataStorageService'
import { promptAction } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'

@Entry
@Component
struct Index {
  @State isLoading: boolean = true
  @State currentStyle: UIStyle = UIStyle.CARD
  @State records: PhotoRecord[] = []
  
  private dataSource: PhotoRecordDataSource = new PhotoRecordDataSource()
  private context: common.UIAbilityContext | null = null
  private preferenceService: PreferenceService | null = null
  private photoPickerService: PhotoPickerService | null = null
  private exifParserService: ExifParserService | null = null
  private storageService: DataStorageService | null = null
  
  private backgroundTasks: Map<string, boolean> = new Map()
  private isComponentAlive: boolean = true

  async aboutToAppear(): Promise<void> {
    this.context = this.getUIContext().getHostContext() as common.UIAbilityContext
    this.preferenceService = new PreferenceService(this.context)
    this.photoPickerService = new PhotoPickerService(this.context)
    this.exifParserService = new ExifParserService()
    this.storageService = new DataStorageService(this.context)
    
    const initSuccess = await this.storageService.initialize()
    if (!initSuccess) {
      promptAction.showToast({
        message: '存储服务异常，数据将保存在内存中',
        duration: 3000
      })
    }
    
    await this.storageService.migrateFromPreferences()
    this.isComponentAlive = true
    await this.reloadSettings()
    await this.checkFirstLaunch()
  }

  aboutToDisappear(): void {
    this.isComponentAlive = false
    this.backgroundTasks.clear()
  }

  async onPageShow(): Promise<void> {
    // 从详情页返回时刷新数据（笔记可能已更新）
    if (this.storageService && !this.isLoading) {
      const updatedRecords = await this.storageService.getAllRecords()
      this.records = updatedRecords
      this.dataSource.setData(updatedRecords)
      hilog.info(0x0021, 'UI', '[Index] onPageShow 刷新数据，共' + this.records.length + '条')
    }
    if (this.preferenceService) {
      await this.reloadSettings()
    }
  }

  async reloadSettings(): Promise<void> {
    if (this.preferenceService) {
      const newStyle = await this.preferenceService.getUIStyle()
      if (newStyle !== this.currentStyle) {
        this.currentStyle = newStyle
      }
    }
  }

  async checkFirstLaunch(): Promise<void> {
    try {
      if (this.preferenceService) {
        await this.preferenceService.init()
        const isFirst = await this.preferenceService.isFirstLaunch()
        
        if (isFirst) {
          this.getUIContext().getRouter().replaceUrl({ url: 'pages/WelcomePage' })
          return
        }
        
        this.currentStyle = await this.preferenceService.getUIStyle()
        
        if (this.storageService) {
          this.records = await this.storageService.getAllRecords()
          this.dataSource.setData(this.records)
        }
        
        this.isLoading = false
      }
    } catch (error) {
      hilog.error(0x0021, 'UI', '检查首次启动失败:' + error)
      this.isLoading = false
    }
  }

  goToSettings(): void {
    try {
      this.getUIContext().getRouter().pushUrl({ url: 'pages/SettingsPage' })
    } catch (error) {
      hilog.error(0x0021, 'UI', '跳转设置页失败:' + error)
    }
  }

  async addPhoto(): Promise<void> {
    let sandboxPath: string | undefined = undefined
    
    try {
      if (!this.photoPickerService) return
      const photoUri = await this.photoPickerService.selectPhoto()
      if (!photoUri) return

      try {
        sandboxPath = await this.photoPickerService.getSandboxPath(photoUri)
      } catch (e) {
        hilog.warn(0x0021, 'Picker', '[Index] 获取沙箱路径失败:' + e)
      }

      if (!this.exifParserService) return
      const isRawFile = this.exifParserService.isRawFormat(photoUri)
      
      let basicData: ExifData
      if (isRawFile) {
        basicData = await this.exifParserService.parseExifAdvanced(photoUri, sandboxPath)
      } else {
        basicData = await this.exifParserService.parseExifQuick(photoUri)
      }

      let thumbnailPath = ''
      try {
        const pathForThumbnail = sandboxPath || photoUri
        thumbnailPath = await this.photoPickerService.generateThumbnail(pathForThumbnail)
      } catch (e) {
        hilog.warn(0x0021, 'Picker', '[Index] 生成缩略图失败:' + e)
      }

      const hasExifData = basicData.cameraModel !== '' || basicData.iso > 0
      
      if (!hasExifData) {
        const uiContext = this.getUIContext()
        uiContext.getPromptAction().showDialog({
          title: '提示',
          message: '该照片无EXIF参数数据，是否继续添加？',
          buttons: [
            { text: '取消', color: '#999999' },
            { text: '继续添加', color: '#007DFF' }
          ]
        }).then((result: promptAction.ShowDialogSuccessResponse) => {
          if (result.index === 1) {
            this.createRecordWithNote(basicData, thumbnailPath, photoUri, sandboxPath)
          }
          if (sandboxPath && this.photoPickerService) {
            this.photoPickerService.cleanupTempFile(sandboxPath)
          }
        })
        return
      }

      this.createRecordWithNote(basicData, thumbnailPath, photoUri, sandboxPath)
      
    } catch (error) {
      hilog.error(0x0021, 'UI', '添加照片失败:' + error)
      if (sandboxPath && this.photoPickerService) {
        this.photoPickerService.cleanupTempFile(sandboxPath)
      }
      this.getUIContext().getPromptAction().showToast({
        message: '添加失败，请重试',
        duration: 2000
      })
    }
  }

  // 三专家共识方案B：创建记录后立即跳转详情页编辑笔记
  private async createRecordWithNote(
    exifData: ExifData, 
    thumbnailPath: string,
    photoUri?: string,
    sandboxPath?: string
  ): Promise<void> {
    const newRecord = await this.createRecordAndReturn(exifData, thumbnailPath, '', '')
    
    // 后台继续解析RAW格式（如果需要）
    if (photoUri && this.exifParserService?.isRawFormat(photoUri)) {
      this.loadAdvancedDataInBackground(photoUri, sandboxPath, newRecord.id)
    } else if (sandboxPath && this.photoPickerService) {
      this.photoPickerService.cleanupTempFile(sandboxPath)
    }
    
    // 【方案B核心】立即跳转到详情页，让用户编辑笔记
    hilog.info(0x0021, 'UI', '[Index] 跳转详情页编辑笔记')
    this.getUIContext().getRouter().pushUrl({
      url: 'pages/PhotoDetailPage',
      params: { 
        record: newRecord, 
        isNew: true  // 标记为新建，详情页自动进入编辑模式
      }
    })
  }
  
  // 创建记录并返回完整对象（用于跳转详情页）
  private async createRecordAndReturn(
    exifData: ExifData, 
    thumbnailPath?: string,
    noteTitle?: string,
    note?: string
  ): Promise<PhotoRecord> {
    const now = Date.now()
    const recordId = this.generateUUID()
    const newRecord: PhotoRecord = {
      id: recordId,
      createTime: now,
      updateTime: now,
      exifData: exifData,
      noteTitle: noteTitle || '',
      note: note || '',
      thumbnailPath: thumbnailPath || ''
    }

    this.records.unshift(newRecord)
    this.dataSource.insertData(0, newRecord)

    if (this.storageService) {
      await this.storageService.saveRecord(newRecord)
    }

    return newRecord
  }

  private async loadAdvancedDataInBackground(
    uri: string, 
    sandboxPath: string | undefined, 
    recordId: string
  ): Promise<void> {
    this.backgroundTasks.set(recordId, true)
    
    try {
      if (!this.exifParserService) return
      
      if (this.exifParserService.isRawFormat(uri)) {
        this.backgroundTasks.delete(recordId)
        return
      }
      
      if (!this.isComponentAlive) return

      const advancedData = await this.exifParserService.parseExifAdvanced(uri, sandboxPath)
      
      if (!this.isComponentAlive || !this.backgroundTasks.has(recordId)) return

      const index = this.records.findIndex(r => r.id === recordId)
      if (index === -1) return

      const basicData = this.records[index].exifData
      const mergedData = this.exifParserService.mergeExifData(basicData, advancedData)
      
      const originalRecord = this.records[index]
      const updatedRecord: PhotoRecord = {
        id: originalRecord.id,
        createTime: originalRecord.createTime,
        updateTime: Date.now(),
        exifData: mergedData,
        noteTitle: originalRecord.noteTitle,
        note: originalRecord.note,
        thumbnailPath: originalRecord.thumbnailPath,
        thumbnail: originalRecord.thumbnail,
        isDeleting: originalRecord.isDeleting
      }
      
      const temp = [...this.records]
      temp[index] = updatedRecord
      this.records = temp
      this.dataSource.updateData(index, updatedRecord)

      if (this.storageService) {
        await this.storageService.saveRecord(updatedRecord)
      }

    } catch (error) {
      hilog.error(0x0021, 'EXIF', '[Index-Phase2] 后台解析失败:' + error)
    } finally {
      this.backgroundTasks.delete(recordId)
      if (sandboxPath && this.photoPickerService) {
        this.photoPickerService.cleanupTempFile(sandboxPath)
      }
    }
  }

  private async createRecord(
    exifData: ExifData, 
    thumbnailPath?: string,
    noteTitle?: string,
    note?: string
  ): Promise<string> {
    try {
      const now = Date.now()
      const recordId = this.generateUUID()
      const newRecord: PhotoRecord = {
        id: recordId,
        createTime: now,
        updateTime: now,
        exifData: exifData,
        noteTitle: noteTitle || '',
        note: note || '',
        thumbnailPath: thumbnailPath || ''
      }

      this.records.unshift(newRecord)
      this.dataSource.insertData(0, newRecord)

      if (this.storageService) {
        await this.storageService.saveRecord(newRecord)
      }

      this.getUIContext().getPromptAction().showToast({
        message: `已添加`,
        duration: 1500
      })

      return recordId
    } catch (error) {
      hilog.error(0x0021, 'UI', '创建记录失败:' + error)
      throw new Error('创建记录失败: ' + String(error))
    }
  }

  private generateUUID(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c: string) => {
      const r = Math.random() * 16 | 0
      const v = c === 'x' ? r : (r & 0x3 | 0x8)
      return v.toString(16)
    })
  }

  build() {
    Column() {
      if (this.isLoading) {
        Column() {
          LoadingProgress().width(50).height(50)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 顶部导航栏
        Row() {
          Text('光影备忘录')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
          
          Blank()
          
          Image($r('app.media.startIcon'))
            .width(28)
            .height(28)
            .onClick(() => this.goToSettings())
        }
        .width('100%')
        .height(56)
        .padding({ left: 20, right: 20 })

        // 内容区域
        if (this.records.length === 0) {
          this.EmptyState()
        } else {
          this.RecordList()
        }

        // 底部添加按钮
        Button() {
          Row() {
            Text('+')
              .fontSize(24)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
            Text(' 新建笔记')
              .fontSize(16)
              .fontColor(Color.White)
          }
        }
        .width('88%')
        .height(52)
        .backgroundColor('#2563EB')
        .borderRadius(26)
        .shadow({ radius: 12, color: '#402563EB', offsetY: 4 })
        .margin({ bottom: 28, top: 12 })
        .onClick(() => this.addPhoto())
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }

  // 空状态
  @Builder
  EmptyState() {
    Column() {
      Text('📷')
        .fontSize(64)
        .margin({ bottom: 16 })
      
      Text('还没有复盘笔记')
        .fontSize(18)
        .fontColor('#64748B')
        .margin({ bottom: 8 })
      
      Text('选择照片，记录拍摄心得')
        .fontSize(14)
        .fontColor('#94A3B8')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  // 记录列表
  @Builder
  RecordList() {
    List() {
      ForEach(this.records, (record: PhotoRecord) => {
        ListItem() {
          this.NoteCard(record)
        }
        .padding({ left: 16, right: 16, top: 6, bottom: 6 })
        .swipeAction({ end: this.DeleteButton(record) })
      }, (record: PhotoRecord) => record.id + '_' + record.updateTime.toString())
    }
    .width('100%')
    .layoutWeight(1)
    .cachedCount(5)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  // 笔记卡片（背景图 + 前景内容）
  @Builder
  NoteCard(record: PhotoRecord) {
    Stack() {
      // 背景层：缩略图
      if (record.thumbnailPath && record.thumbnailPath.length > 0) {
        Image('file://' + record.thumbnailPath)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .interpolation(ImageInterpolation.High)
          .borderRadius(16)
      } else {
        // 无图时的渐变背景
        Column()
          .width('100%')
          .height('100%')
          .borderRadius(16)
          .linearGradient({
            angle: 135,
            colors: [['#667EEA', 0], ['#764BA2', 1]]
          })
      }

      // 遮罩层：底部渐变（更柔和）
      Column()
        .width('100%')
        .height('100%')
        .borderRadius(16)
        .linearGradient({
          angle: 180,
          colors: [
            ['#00000000', 0],
            ['#00000010', 0.4],
            ['#00000060', 0.7],
            ['#000000C0', 1]
          ]
        })

      // 右上角：日期标签
      Text(this.formatDate(record.createTime))
        .fontSize(10)
        .fontColor('#FFFFFFEE')
        .backgroundColor('#00000060')
        .padding({ left: 8, right: 8, top: 3, bottom: 3 })
        .borderRadius(6)
        .position({ right: 12, top: 12 })

      // 底部内容区域
      Column() {
        // 笔记标题（有内容时显示）
        if (record.noteTitle && record.noteTitle.length > 0) {
          Text(record.noteTitle)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .textShadow({ radius: 4, color: '#80000000', offsetY: 1 })

          // 笔记摘要（有内容时显示）
          if (record.note && record.note.length > 0) {
            Text(record.note)
              .fontSize(12)
              .fontColor('#FFFFFFCC')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
              .margin({ top: 4 })
              .lineHeight(16)
          }
        }

        // 底部信息栏：机型
        if (record.exifData.cameraModel) {
          Text(record.exifData.cameraModel)
            .fontSize(10)
            .fontColor('#FFFFFF99')
            .maxLines(1)
            .margin({ top: record.noteTitle ? 8 : 0 })
        }
      }
      .width('100%')
      .padding({ left: 14, right: 14, bottom: 14 })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.End)
      .height('100%')
    }
    .width('100%')
    .height(180)
    .borderRadius(16)
    .clip(true)
    .shadow({ radius: 8, color: '#20000000', offsetY: 4 })
    .onClick(() => this.goToDetail(record))
  }

  // 删除按钮（左滑显示）
  @Builder
  DeleteButton(record: PhotoRecord) {
    Row() {
      Button() {
        Text('删除')
          .fontSize(14)
          .fontColor(Color.White)
      }
      .width(72)
      .height('100%')
      .backgroundColor('#EF4444')
      .onClick(() => this.confirmDeleteRecord(record))
    }
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // 确认删除
  confirmDeleteRecord(record: PhotoRecord): void {
    promptAction.showDialog({
      title: '确认删除',
      message: '删除后无法恢复',
      buttons: [
        { text: '取消', color: '#64748B' },
        { text: '删除', color: '#EF4444' }
      ]
    }).then((result: promptAction.ShowDialogSuccessResponse) => {
      if (result.index === 1) {
        this.deleteRecord(record)
      }
    })
  }

  // 格式化日期
  private formatDate(timestamp: number): string {
    const date = new Date(timestamp)
    const month = (date.getMonth() + 1).toString().padStart(2, '0')
    const day = date.getDate().toString().padStart(2, '0')
    return `${month}-${day}`
  }

  // 删除记录
  async deleteRecord(record: PhotoRecord): Promise<void> {
    try {
      const index = this.records.findIndex(r => r.id === record.id)
      if (index >= 0) {
        const temp = [...this.records]
        temp.splice(index, 1)
        this.records = temp
        this.dataSource.deleteData(index)
      }
      
      if (this.storageService) {
        await this.storageService.deleteRecord(record.id)
      }
      
      promptAction.showToast({ message: '已删除', duration: 1500 })
    } catch (error) {
      hilog.error(0x0021, 'Storage', '[Index] 删除失败: ' + error)
      promptAction.showToast({ message: '删除失败', duration: 1500 })
    }
  }

  // 跳转详情页
  goToDetail(record: PhotoRecord): void {
    try {
      this.getUIContext().getRouter().pushUrl({
        url: 'pages/PhotoDetailPage',
        params: { record: record }
      })
    } catch (error) {
      hilog.error(0x0021, 'UI', '跳转详情页失败:' + error)
    }
  }
}
