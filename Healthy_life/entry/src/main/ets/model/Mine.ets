/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export interface InfoItem {
  id: string;
  title: Resource | string;
  icon?: Resource;
  route?: string;  // 添加路由字段
}

export const MineInfoList: InfoItem[] = [
  {
    id: '0',
    title: '📊 数据统计',
    route: 'pages/StatisticsPage'
  },
  {
    id: '0_1',
    title: '🏆 成就中心',
    route: 'pages/AchievementPage'
  },
  {
    id: '0_2',
    title: '⏰ 提醒设置',
    route: 'pages/ReminderSettingsPage'
  },
  {
    id: '0_3',
    title: '🎨 主题设置',
    route: 'pages/ThemeSettingsPage'
  },
  {
    id: '0_4',
    title: '📤 数据导出',
    route: 'pages/DataExportPage'
  },
  {
    id: '1',
    title: $r('app.string.mine_personal_data')
  },
  {
    id: '2',
    title: $r('app.string.mine_check_updates')
  },
  {
    id: '3',
    title: $r('app.string.mine_about')
  }
];