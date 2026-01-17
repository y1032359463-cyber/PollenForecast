# 日期间隔与计算组件快速入门

## 目录

- [简介](#简介)
- [约束与限制](#约束与限制)
- [快速入门](#快速入门)
- [API参考](#API参考)
- [示例代码](#示例代码)

## 简介

本组件提供日期之间计算能力，包括计算2个日期之间的天数，计算选中日期前后的时间等功能。

<img src="./screenshot/DateToolsCalculate.png" width="300">

## 约束与限制
### 环境
* DevEco Studio版本：DevEco Studio 5.0.4 Release及以上
* HarmonyOS SDK版本：HarmonyOS 5.0.4 Release SDK及以上
* 设备类型：华为手机（包括双折叠和阔折叠）
* HarmonyOS版本：HarmonyOS 5.0.4(16)及以上

## 快速入门

1. 安装组件。

   如果是在DevEco Studio使用插件集成组件，则无需安装组件，请忽略此步骤。

   如果是从生态市场下载组件，请参考以下步骤安装组件。

   a. 解压下载的组件包，将包中所有文件夹拷贝至您工程根目录的XXX目录下。

   b. 在项目根目录build-profile.json5添加module_date_calculation和module_base_apis模块。

    ```typescript
    // 在项目根目录build-profile.json5填写module_date_calculation和module_base_apis路径。其中XXX为组件存放的目录名
    "modules": [
        {
        "name": "module_date_calculation",
        "srcPath": "./XXX/module_date_calculation",
        },
        {
        "name": "module_base_apis",
        "srcPath": "./XXX/module_base_apis",
        }
    ]
    ```
   c. 在项目根目录oh-package.json5中添加依赖。
    ```typescript
    // XXX为组件存放的目录名称
    "dependencies": {
      "module_date_calculation": "file:./XXX/module_date_calculation"
    }
   ```

2. 引入组件与日历组件句柄。

   ```typescript
   import { DateToolsCalculate } from 'module_date_calculation';
   ```

3. 调用组件，详细参数配置说明参见[API参考](#API参考)。

      ```typescript
   import { DateToolsCalculate } from 'module_date_calculation';
   
   @Entry
   @Component
   struct Index {
     build() {
       Column() {
         DateToolsCalculate({
           startDate: new Date('2025-5-28'),
           buttonColor: '#317AF7',
           textColor: '#ffffff',
         })
       }
     }
   }
   ```

## API参考

### 子组件

无

### 接口

DateToolsCalculate({startDate: string, buttonColor: string,  textColor: string })

日期计算的相关能力，包括日期间隔、日期计算功能。

**参数：**

| 参数名        | 类型                                                         | 是否必填 | 说明     |
| ----------- | ------------------------------------------------------------ | -------- | -------- |
| buttonColor | [ResourceStr](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-types#resourcestr) | 否       | 按钮颜色 |
| textColor   | [ResourceStr](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-types#resourcestr) | 否       | 文字颜色 |
| startDate   | [ResourceStr](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/ts-types#resourcestr)\| number | 否       | 开始日期 |

### 事件

支持以下事件：

#### onIntervalSearch

onIntervalSearch(callback: betweenDates: number)) => void)

日期间隔查询事件，返回日期间隔

#### onCalculateSearch

onCalculateSearch(callback: calculateInfo: [LuckyDays](#LuckyDays对象说明))) => void)

日期计算查询事件，返回查询日期计算详情

**参数：**

| 参数名        | 类型                            | 是否必填 | 说明                         |
| ------------- | ------------------------------- | ---- | ---------------------------- |
| calculateInfo | [LuckyDays](#LuckyDays对象说明) | 是   | 根据时间条件查询到的日期信息 |


### LuckyDays对象说明

| 名称    | 类型   | 是否必填 | 说明      |
| ------- | ------ |------|---------|
| daysFromNow    | string | 是    | 距离今天的天数 |
| solarDate   | string | 是    | 阳历日期    |
| lunarDate     | string | 是    | 农历日期    |
| ganZhiYear | string | 是    | 天干地支年   |
| ganZhiMonth | string | 是    | 天干地支月   |
| forwardOrBack | string | 是    | 向前向后查询  |
| ganZhiDay | string | 是    | 天干地支日   |
| weekday | string | 是    | 星期      |

## 示例代码
   ```typescript
   import { DateToolsCalculate } from 'module_date_calculation';

   @Entry
   @Component
   struct Index {
      build() {
         Column() {
            DateToolsCalculate({
               startDate: new Date('2025-5-28'),
               buttonColor: '#317AF7',
               textColor: '#ffffff',
            })
         }
      }
   }
   ```