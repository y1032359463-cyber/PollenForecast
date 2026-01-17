/**
 * LazyForEach 数据源实现
 * 用于 List 懒加载优化，解决 Swiper 嵌套性能问题
 * 
 * @since 2025-12-25 首页重构
 * @see 三专家共识：必须用 LazyForEach 替代 ForEach
 */

import { PhotoRecord } from './PhotoRecord'

/**
 * 通用懒加载数据源
 * 实现 IDataSource 接口，支持 LazyForEach 按需渲染
 */
export class LazyDataSource<T> implements IDataSource {
  private data: T[] = []
  private listeners: DataChangeListener[] = []

  constructor(data: T[] = []) {
    this.data = data
  }

  /**
   * 获取数据总数
   */
  totalCount(): number {
    return this.data.length
  }

  /**
   * 获取指定索引的数据
   */
  getData(index: number): T {
    return this.data[index]
  }

  /**
   * 注册数据变化监听器
   */
  registerDataChangeListener(listener: DataChangeListener): void {
    if (!this.listeners.includes(listener)) {
      this.listeners.push(listener)
    }
  }

  /**
   * 注销数据变化监听器
   */
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener)
    if (index > -1) {
      this.listeners.splice(index, 1)
    }
  }

  /**
   * 通知数据重新加载
   */
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded()
    })
  }

  /**
   * 通知数据添加
   */
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index)
    })
  }

  /**
   * 通知数据删除
   */
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index)
    })
  }

  /**
   * 通知数据变化
   */
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index)
    })
  }

  // ============ 数据操作方法 ============

  /**
   * 设置新数据（替换全部）
   */
  setData(data: T[]): void {
    this.data = data
    this.notifyDataReload()
  }

  /**
   * 添加单条数据
   */
  addData(item: T): void {
    this.data.push(item)
    this.notifyDataAdd(this.data.length - 1)
  }

  /**
   * 在指定位置插入数据
   */
  insertData(index: number, item: T): void {
    this.data.splice(index, 0, item)
    this.notifyDataAdd(index)
  }

  /**
   * 删除指定索引的数据
   */
  deleteData(index: number): void {
    if (index >= 0 && index < this.data.length) {
      this.data.splice(index, 1)
      this.notifyDataDelete(index)
    }
  }

  /**
   * 根据条件删除数据
   */
  deleteByCondition(predicate: (item: T) => boolean): void {
    const index = this.data.findIndex(predicate)
    if (index >= 0) {
      this.deleteData(index)
    }
  }

  /**
   * 更新指定索引的数据
   */
  updateData(index: number, item: T): void {
    if (index >= 0 && index < this.data.length) {
      this.data[index] = item
      this.notifyDataChange(index)
    }
  }

  /**
   * 获取原始数据数组
   */
  getRawData(): T[] {
    return this.data
  }

  /**
   * 查找数据索引
   */
  findIndex(predicate: (item: T) => boolean): number {
    return this.data.findIndex(predicate)
  }
}

/**
 * PhotoRecord 专用数据源
 * 提供类型安全的操作方法
 */
export class PhotoRecordDataSource extends LazyDataSource<PhotoRecord> {
  
  /**
   * 根据ID删除记录
   */
  deleteById(id: string): boolean {
    const index = this.findIndex(record => record.id === id)
    if (index >= 0) {
      this.deleteData(index)
      return true
    }
    return false
  }

  /**
   * 根据ID查找记录
   */
  findById(id: string): PhotoRecord | undefined {
    return this.getRawData().find(record => record.id === id)
  }

  /**
   * 根据ID更新记录
   */
  updateById(id: string, updater: (record: PhotoRecord) => PhotoRecord): boolean {
    const index = this.findIndex(record => record.id === id)
    if (index >= 0) {
      const updated = updater(this.getData(index))
      this.updateData(index, updated)
      return true
    }
    return false
  }
}


