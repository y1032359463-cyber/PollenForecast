/**
 * 数据导出服务
 * 支持CSV和JSON格式
 */

import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import TaskInfoApi from '../../common/database/tables/TaskInfoApi';
import TaskInfo from '../../viewmodel/TaskInfo';

/**
 * 导出格式枚举
 */
export enum ExportFormat {
  CSV = 'csv',
  JSON = 'json'
}

/**
 * 导出数据接口
 */
interface ExportData {
  exportTime: string;
  totalRecords: number;
  data: TaskExportData[];
}

/**
 * 任务导出数据接口
 */
interface TaskExportData {
  date: string;
  taskID: number;
  targetValue: string;
  finValue: string;
  isDone: boolean;
}

/**
 * 数据导出服务
 */
export class DataExportService {
  private static instance: DataExportService;

  private constructor() {}

  static getInstance(): DataExportService {
    if (!DataExportService.instance) {
      DataExportService.instance = new DataExportService();
    }
    return DataExportService.instance;
  }

  /**
   * 导出所有打卡数据
   */
  async exportAllData(format: ExportFormat): Promise<string> {
    try {
      // 查询所有任务数据
      const taskList: TaskInfo[] = await this.queryAllTasks();

      // 根据格式生成内容
      let content = '';
      if (format === ExportFormat.CSV) {
        content = this.generateCSV(taskList);
      } else {
        content = this.generateJSON(taskList);
      }

      // 生成文件路径
      const fileName = `healthy_life_export_${this.getDateString()}.${format}`;
      const filePath = this.getExportPath(fileName);

      // 写入文件
      await this.writeFile(filePath, content);

      return filePath;
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Export failed: ${err.message}`);
      throw new Error(`Export failed: ${err.message}`);
    }
  }

  /**
   * 查询所有任务
   */
  private queryAllTasks(): Promise<TaskInfo[]> {
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        reject(new Error('Query timeout'));
      }, 10000);

      try {
        TaskInfoApi.query('', false, (taskList: TaskInfo[]) => {
          clearTimeout(timeout);
          resolve(taskList);
        });
      } catch (error) {
        clearTimeout(timeout);
        reject(error);
      }
    });
  }

  /**
   * 生成CSV格式
   */
  private generateCSV(taskList: TaskInfo[]): string {
    const headers = ['日期', '任务ID', '目标次数', '完成次数', '完成状态'];
    const rows: string[] = [headers.join(',')];

    taskList.forEach(task => {
      const row = [
        task.date || '',
        task.taskID?.toString() || '',
        task.targetValue?.toString() || '0',
        task.finValue?.toString() || '0',
        task.isDone ? '已完成' : '未完成'
      ];
      rows.push(row.join(','));
    });

    return rows.join('\n');
  }

  /**
   * 生成JSON格式
   */
  private generateJSON(taskList: TaskInfo[]): string {
    const exportData: ExportData = {
      exportTime: new Date().toISOString(),
      totalRecords: taskList.length,
      data: taskList.map((task): TaskExportData => ({
        date: task.date,
        taskID: task.taskID,
        targetValue: task.targetValue,
        finValue: task.finValue,
        isDone: task.isDone
      }))
    };

    return JSON.stringify(exportData, null, 2);
  }

  /**
   * 获取导出路径
   */
  private getExportPath(fileName: string): string {
    const context = getContext();
    const filesDir = context.filesDir;
    return `${filesDir}/${fileName}`;
  }

  /**
   * 写入文件
   */
  private async writeFile(filePath: string, content: string): Promise<void> {
    try {
      const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
      fileIo.writeSync(file.fd, content);
      fileIo.closeSync(file);
      console.info(`File written successfully: ${filePath}`);
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Write file failed: ${err.message}`);
      throw new Error(`Write file failed: ${err.message}`);
    }
  }

  /**
   * 获取日期字符串
   */
  private getDateString(): string {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const hour = String(now.getHours()).padStart(2, '0');
    const minute = String(now.getMinutes()).padStart(2, '0');
    return `${year}${month}${day}_${hour}${minute}`;
  }
}
