/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { ModernTaskCard } from './ModernTaskCard';
import TaskInfo from '../../viewmodel/TaskInfo';
import { AppConfig } from '../../common/config/AppConfig';

/**
 * 现代化任务卡片适配器
 * 
 * 将原有TaskCard接口适配到新的ModernTaskCard组件
 * 保持与HomeComponent的兼容性
 */
@Component
export struct ModernTaskCardAdapter {
  @Prop taskInfoStr: string = '';
  clickAction: Function = (isClick: boolean) => {};
  @State taskInfo: TaskInfo = new TaskInfo(-1, '', -1, '', false, '', '', '', false, '', false);

  aboutToAppear() {
    this.taskInfo = JSON.parse(this.taskInfoStr);
  }

  // 获取任务类型的emoji图标
  private getTaskEmoji(): string {
    const emojiMap: Record<number, string> = {
      1: '🛏️',  // 早起
      2: '💧',  // 喝水
      3: '🍎',  // 吃苹果
      4: '😊',  // 微笑
      5: '🪥',  // 刷牙
      6: '🌙'   // 睡眠
    };
    return emojiMap[this.taskInfo.taskID] || '📝';
  }

  // 获取任务类型的颜色
  private getTaskColor(): string {
    // 默认颜色映射 (与Figma设计一致)
    const defaultColors: Record<number, string> = {
      1: '#FF6B6B',  // 早起
      2: '#4ECDC4',  // 喝水
      3: '#FF6B35',  // 吃苹果
      4: '#FFD93D',  // 微笑
      5: '#95E1D3',  // 刷牙
      6: '#6C5CE7'   // 睡眠
    };
    return defaultColors[this.taskInfo.taskID] || '#00C853';
  }
  
  // 获取任务名称
  private getTaskName(): string {
    const taskNames: Record<number, string> = {
      1: '早起',
      2: '喝水',
      3: '吃苹果',
      4: '微笑',
      5: '刷牙',
      6: '早睡'
    };
    return taskNames[this.taskInfo.taskID] || '任务';
  }

  // 获取任务单位
  private getTaskUnit(): string {
    try {
      const appConfig = AppConfig.getInstance();
      const taskType = appConfig.getTaskTypeById(this.taskInfo.taskID);
      if (taskType) {
        return taskType.unit;
      }
    } catch (error) {
      // 配置未加载,使用默认单位
    }
    
    const defaultUnits: Record<number, string> = {
      1: '次',
      2: '杯',
      3: '个',
      4: '次',
      5: '次',
      6: '次'
    };
    return defaultUnits[this.taskInfo.taskID] || '次';
  }

  build() {
    ModernTaskCard({
      icon: this.getTaskEmoji(),
      title: this.getTaskName(),
      current: parseInt(this.taskInfo.finValue) || 0,
      total: parseInt(this.taskInfo.targetValue) || 1,
      unit: this.getTaskUnit(),
      color: this.getTaskColor(),
      onCardClick: () => {
        this.clickAction(true);
      }
    })
  }
}
