/**
 * 数据统计服务
 * 负责计算任务完成度、生成图表数据
 */

import TaskInfo from '../../viewmodel/TaskInfo';
import TaskInfoApi from '../../common/database/tables/TaskInfoApi';

/**
 * 图表数据点接口
 */
export interface ChartDataPoint {
  label: string;   // 标签(如: 周一, 1月)
  value: number;   // 数值(0-100表示百分比)
}

/**
 * 统计数据服务类
 */
export class StatisticsService {
  /**
   * 获取最近7天的完成度数据
   * @returns 图表数据点数组
   */
  static async getWeeklyCompletionData(): Promise<ChartDataPoint[]> {
    const weekLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    const result: ChartDataPoint[] = [];

    // 获取当前日期
    const today = new Date();
    const currentDayOfWeek = today.getDay() === 0 ? 7 : today.getDay(); // 周日转换为7

    for (let i = 0; i < 7; i++) {
      const dayOffset = i - currentDayOfWeek + 1;
      const targetDate = new Date(today);
      targetDate.setDate(today.getDate() + dayOffset);

      // 计算该天的完成度
      const completionRate = await StatisticsService.calculateDayCompletionRate(targetDate);

      result.push({
        label: weekLabels[i],
        value: completionRate
      });
    }

    return result;
  }

  /**
   * 获取最近30天的完成度数据(按周汇总)
   * @returns 图表数据点数组
   */
  static async getMonthlyCompletionData(): Promise<ChartDataPoint[]> {
    const result: ChartDataPoint[] = [];
    const today = new Date();

    // 按4周划分
    for (let week = 3; week >= 0; week--) {
      let weekTotalRate = 0;
      let validDays = 0;

      // 计算每周7天的平均完成度
      for (let day = 0; day < 7; day++) {
        const dayOffset = -(week * 7 + day);
        const targetDate = new Date(today);
        targetDate.setDate(today.getDate() + dayOffset);

        const rate = await StatisticsService.calculateDayCompletionRate(targetDate);
        if (rate >= 0) {
          weekTotalRate += rate;
          validDays++;
        }
      }

      const avgRate = validDays > 0 ? weekTotalRate / validDays : 0;
      result.push({
        label: `第${4 - week}周`,
        value: Math.round(avgRate)
      });
    }

    return result;
  }

  /**
   * 计算指定日期的任务完成度
   * @param date 目标日期
   * @returns 完成度百分比(0-100)
   */
  static async calculateDayCompletionRate(date: Date): Promise<number> {
    return new Promise<number>((resolve, reject) => {
      const dateStr = StatisticsService.formatDate(date);

      // 添加超时保护
      const timeout = setTimeout(() => {
        resolve(0); // 超时返回0
      }, 5000);

      try {
        TaskInfoApi.query(dateStr, false, (taskList: TaskInfo[]) => {
          clearTimeout(timeout);

          if (!taskList || taskList.length === 0) {
            resolve(0);
            return;
          }

          // 计算完成的任务数
          let completedTasks = 0;
          taskList.forEach(task => {
            if (task.isDone) {
              completedTasks++;
            }
          });

          // 计算完成率
          const completionRate = (completedTasks / taskList.length) * 100;
          resolve(Math.round(completionRate));
        });
      } catch (error) {
        clearTimeout(timeout);
        console.error('calculateDayCompletionRate error:', JSON.stringify(error));
        resolve(0); // 出错返回0
      }
    });
  }

  /**
   * 获取任务类型统计数据
   * @returns 各任务类型的完成次数
   */
  static async getTaskTypeStatistics(): Promise<Map<number, number>> {
    const stats = new Map<number, number>();
    const today = new Date();

    // 统计最近30天的数据
    for (let i = 0; i < 30; i++) {
      const targetDate = new Date(today);
      targetDate.setDate(today.getDate() - i);
      const dateStr = StatisticsService.formatDate(targetDate);

      await new Promise<void>((resolve) => {
        const timeout = setTimeout(() => resolve(), 2000); // 添加超时

        try {
          TaskInfoApi.query(dateStr, false, (taskList: TaskInfo[]) => {
            clearTimeout(timeout);
            taskList?.forEach(task => {
              if (task.isDone) {
                const count = stats.get(task.taskID) || 0;
                stats.set(task.taskID, count + 1);
              }
            });
            resolve();
          });
        } catch (error) {
          clearTimeout(timeout);
          console.error('getTaskTypeStatistics error:', JSON.stringify(error));
          resolve();
        }
      });
    }

    return stats;
  }

  /**
   * 获取连续打卡天数
   * @returns 连续打卡天数
   */
  static async getStreakDays(): Promise<number> {
    let streakDays = 0;
    const today = new Date();

    // 从今天往前检查
    for (let i = 0; i < 365; i++) {
      const targetDate = new Date(today);
      targetDate.setDate(today.getDate() - i);

      const rate = await StatisticsService.calculateDayCompletionRate(targetDate);

      // 如果当天完成度>=80%,算作打卡成功
      if (rate >= 80) {
        streakDays++;
      } else {
        break; // 连续中断
      }
    }

    return streakDays;
  }

  /**
   * 获取总完成任务数
   * @returns 历史总完成任务数
   */
  static async getTotalCompletedTasks(): Promise<number> {
    let totalCount = 0;
    const today = new Date();

    // 统计最近90天
    for (let i = 0; i < 90; i++) {
      const targetDate = new Date(today);
      targetDate.setDate(today.getDate() - i);
      const dateStr = StatisticsService.formatDate(targetDate);

      await new Promise<void>((resolve) => {
        const timeout = setTimeout(() => resolve(), 2000);

        try {
          TaskInfoApi.query(dateStr, false, (taskList: TaskInfo[]) => {
            clearTimeout(timeout);
            taskList?.forEach(task => {
              if (task.isDone) {
                totalCount++;
              }
            });
            resolve();
          });
        } catch (error) {
          clearTimeout(timeout);
          console.error('getTotalCompletedTasks error:', JSON.stringify(error));
          resolve();
        }
      });
    }

    return totalCount;
  }

  /**
   * 格式化日期为字符串
   * @param date 日期对象
   * @returns 格式化的日期字符串 YYYY-MM-DD
   */
  private static formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  /**
   * 获取本周完成率
   */
  static async getCurrentWeekCompletionRate(): Promise<number> {
    const weekData = await StatisticsService.getWeeklyCompletionData();
    const today = new Date();
    const currentDayOfWeek = today.getDay() === 0 ? 6 : today.getDay() - 1;

    let totalRate = 0;
    let validDays = 0;

    for (let i = 0; i <= currentDayOfWeek; i++) {
      totalRate += weekData[i].value;
      validDays++;
    }

    return validDays > 0 ? Math.round(totalRate / validDays) : 0;
  }

  /**
   * 获取本月完成率
   */
  static async getCurrentMonthCompletionRate(): Promise<number> {
    const today = new Date();
    const daysInMonth = today.getDate();
    let totalRate = 0;

    for (let i = 0; i < daysInMonth; i++) {
      const targetDate = new Date(today);
      targetDate.setDate(today.getDate() - i);
      const rate = await StatisticsService.calculateDayCompletionRate(targetDate);
      totalRate += rate;
    }

    return daysInMonth > 0 ? Math.round(totalRate / daysInMonth) : 0;
  }
}
