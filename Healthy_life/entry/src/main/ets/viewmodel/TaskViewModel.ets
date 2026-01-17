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

import { CommonConstants as Const } from '../common/constants/CommonConstants';
import Logger from '../common/utils/Logger';
import TaskInfoApi from '../common/database/tables/TaskInfoApi';
import { padTo2Digits } from '../common/utils/Utils';
import TaskInfo, { oneWeek } from './TaskInfo';
import { TaskMapById, RemindContentMap, ITaskItem } from '../model/TaskInitList';
import PublishReminderInfo from './PublishReminderInfo';

export const taskOriginData: ITaskItem[] = TaskMapById;

/**
 * @description Get all task status
 * @return object[] Database query results
 */
export const getAllTask = () => {
  return new Promise<TaskInfo[]>((resolve) => {
    TaskInfoApi.query(Const.GLOBAL_KEY, true, (res: TaskInfo[]) => {
      if (res?.length === 0) {
        Logger.warn('queryTaskList', 'has no data!!');
        resolve(res ?? []);
      }
      resolve(res);
    })
  });
}

/**
 * @param params:TaskInfo
 */
export const addTask = (params: TaskInfo, context: Context) => {
  if (!params) {
    Logger.error('addTask', 'params is null!');
    return new Promise<number>((resolve) => {
      resolve(-1);
    });
  }
  return new Promise<number>(async (resolve, reject) => {
    Logger.info('TaskViewModel', 'addTask');

    TaskInfoApi.updateDataByDate(params, (flag: number) => {
      if (!flag) {
        Logger.error('insertTaskSetting', 'updateTaskSetting Error!');
        reject(flag);
      }
      resolve(flag);
    });
    let taskInfoStr = JSON.stringify(params);
    let taskInfo: TaskInfo = JSON.parse(taskInfoStr);
    taskInfo.date = new Date().toDateString();
    taskInfo.isDone = true;
    TaskInfoApi.updateDataByDate(taskInfo, (flag: number) => {
      if (!flag) {
        Logger.error('insertTaskSetting', 'updateTaskSetting Error!');
        reject(flag);
      }
      resolve(flag);
    });
  });
}

/**
 * @description Used to initialize task list data from database data
 * @param taskInitList Task list initial data
 * @param taskInfoData Database query data
 */
export const taskIndexDataInit = (taskInitList: ITaskItem[], taskInfoData: TaskInfo[]) => {
  const afterInitData = taskInitList.map((content) => {
    taskInfoData.forEach((item) => {
      if (item?.taskID === content?.taskID) {
        content.isOpen = item?.isOpen;
        content.targetValue = item?.targetValue;
        content.isAlarm = item?.isAlarm;
        content.startTime = item?.startTime;
        content.endTime = item?.endTime;
        content.frequency = item?.frequency;
      }
    });
    return content;
  });
  return afterInitData;
}

/**
 * @description format data as json string
 * @param params = {}
 */
export const formatParams = (params: ITaskItem) => {
  return JSON.stringify(params);
}

/**
 * @description Initialization frequency string
 * @param frequencyIdCollection
 * @return string Frequency string
 */
export const initFrequencyString = (frequencyIdCollection: string) => {
  if (frequencyIdCollection === '') {
    return Const.EVERYDAY;
  }
  const frequencyIdArray: Array<number> = frequencyIdCollection.split(',').map(item => Number(item) - 1);
  const length = frequencyIdArray.length;
  if (length === 7) {
    return Const.EVERYDAY;
  }
  const frequencyString = frequencyIdArray.reduce((pre, current) => {
    return pre + ' ' + oneWeek[current];
  }, '')
  return frequencyString;
}

/**
 * @description Returns the timestamp of today's selected time
 * @param currentTime
 * @return timestamp
 */
export function returnTimeStamp(currentTime: string) {
  const timeString = `${new Date().toDateString()} ${currentTime}`;
  return new Date(timeString).getTime();
}

/**
 * @description It is used for formatting time and displayed in the form of HH: mm
 * @param value
 */
export const formatTime = (value: TimePickerResult) => {
  let hour = value?.hour ? value?.hour : 8;
  let minute = value?.minute ? value?.minute : 0;
  return `${padTo2Digits(hour)}:${padTo2Digits(minute)}`;
}

/**
 * @description Range of generated drinking water 0.25 - 5 L
 * @return Array<string>
 */
export const createDrinkRange = () => {
  const drinkRangeArr: Array<string> = []
  for (let i = Const.DRINK_STEP; i <= Const.DRINK_MAX_RANGE; i += Const.DRINK_STEP) {
    drinkRangeArr.push(`${i / Const.TIMES_100} L`);
  }
  return drinkRangeArr;
}

/**
 * @description Generate the range of eating apples 1 - 100
 * @return Array<string>
 */
export const createAppleRange = () => {
  const appleRangeArr: Array<string> = [];
  for (let i = 1; i <= Const.EAT_APPLE_RANGE; i++) {
    appleRangeArr.push(`${i} 个`);
  }
  return appleRangeArr;
}