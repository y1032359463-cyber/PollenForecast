/**
 * WorkRecord.ets - 工时记录数据模型
 * 
 * 定义了单条工时记录的详细数据结构，用于在应用内传递和持久化存储。
 * 
 * @property {string} id - 记录的唯一标识符，建议使用时间戳和随机数生成。
 * @property {string} date - 工作日期 (ISO 8601 格式, e.g., "2025-11-15T00:00:00.000Z")。
 * @property {string} startTime - 开始时间 (格式 "HH:mm")。
 * @property {string} endTime - 结束时间 (格式 "HH:mm")。
 * @property {number} duration - 工作时长（以小时为单位，浮点数）。
 * @property {string} projectType - 工作类型ID (e.g., 'dev', 'design')。
 * @property {string} projectName - 项目名称。
 * @property {number} hourlyWage - 时薪。
 * @property {number} allowance - 补贴金额。
 * @property {number} deduction - 扣款金额。
 * @property {string} remarks - 备注信息。
 * @property {string} createdAt - 记录创建时间 (ISO 8601 格式)。
 */
export interface WorkRecord {
  id: string;
  date: string;
  startTime: string;
  endTime: string;
  duration: number;
  projectType: string;
  projectName: string;
  hourlyWage: number;
  allowance: number;
  deduction: number;
  remarks: string;
  createdAt: string;
}

/**
 * WorkType - 工作类型定义
 * 
 * @property {string} id - 类型唯一标识符。
 * @property {string} name - 类型显示名称。
 * @property {string} icon - 图标资源名称。
 * @property {string} color - 代表颜色。
 */
export interface WorkType {
  id: string;
  name: string;
  icon: string;
  color: string;
}
