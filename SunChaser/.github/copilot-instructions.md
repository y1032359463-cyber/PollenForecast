# SunChaser - AI 开发指南

星晷(SunChaser)是一款 HarmonyOS NEXT 太阳/月亮位置预测与AR可视化工具。

## 核心架构

**技术栈**: HarmonyOS NEXT (API 6.0.0/20) + ArkTS + ArkUI  
**项目类型**: Phone应用，专注于摄影师和户外爱好者

**关键模块**（规划中）:
- `utils/` - 天文计算引擎(SPA/NOAA算法)、传感器融合
- `components/` - 罗盘、太阳轨迹、时间轴等UI组件
- `services/` - 定位、传感器、偏好设置服务
- `models/` - SunPosition、Location、GoldenHour数据模型

## 开发工作流

### 启动前必读
**必须先读取 `.claude/CLAUDE.md`** 了解:
- 当前项目进度和已完成功能
- 待办事项和已知问题
- 最近的开发日志

### 构建与测试
⚠️ **AI不能执行构建命令** - 需要人工在 DevEco Studio 中操作:
1. 安装依赖: `ohpm install`
2. 构建: Build → Build Hap(s)
3. 运行: Shift+F10 或点击运行按钮

**真机测试必需**: 传感器(磁力计/陀螺仪/加速度计)和相机功能无法在模拟器测试。

### 遇到阻塞问题
如果问题尝试2-3次仍未解决，**立即停止并求助**:
1. 清空 `C:\HarmonyOS_App_Plans\.claude\当前问题.md`
2. 写入问题描述、代码上下文、已尝试方法、错误信息
3. 告知用户粘贴给 CodeGenie

**典型求助场景**: 编译错误反复出现、天文算法实现、传感器融合逻辑、AR绘制性能优化、MapKit API使用。

## ArkTS 严格模式约束

```typescript
// ❌ 禁止类型守卫
function isSunData(obj: Object): obj is SunData { }

// ✅ 使用字段检查
if (obj !== null && obj.azimuth !== undefined && typeof obj.azimuth === 'number')

// ❌ 静态方法中使用 this
static calculate() { return this.helper(); }

// ✅ 使用类名
static calculate() { return SunCalculator.helper(); }

// ❌ 使用 any/unknown
function parse(data: any) { }

// ✅ 使用明确类型或泛型
function parse<T>(data: T): T { }
```

**其他限制**:
- 禁止 `export default`，使用 `export { ClassName }`
- 布局用 `Column/Row/Stack`，不是 div/flex
- 滚动监听用 `onDidScroll`（onScroll已废弃）
- 文件和组件名统一 PascalCase

**常见陷阱**:
| 问题 | 解决方案 |
|-----|---------|
| ForEach 无法加样式 | 包裹在 Row/Column 容器中 |
| layoutWeight 不生效 | 确保父容器有明确高度 |
| @Builder 状态不更新 | 传参数而非直接引用 @StorageLink |
| Canvas 绘制卡顿 | 使用离屏渲染缓存，避免每帧重绘 |

## 代码修改协议

### 重大修改前备份
对核心文件（天文计算引擎、传感器融合、罗盘/地图组件）重构前:
```powershell
$backupName = "SunCalculator.ets.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item "entry/src/main/ets/utils/SunCalculator.ets" "备份路径/$backupName"
```
将备份位置记录到 `.claude/CLAUDE.md` 开发日志。

### 编辑规范
- ✅ 先读完整个函数/组件再修改
- ✅ 批量修改用 `multi_replace_string_in_file`
- ✅ 使用编辑工具而非删除重建文件
- ❌ 禁止凭假设修改，需截图/日志确认
- ❌ 禁止重复修复已解决的问题

### 完成后更新文档
1. 更新 `.claude/CLAUDE.md` 的"项目进展追踪"
2. 询问用户当前时间并记录时间戳
3. **等待用户确认构建/运行成功后**，才将方案写入 `C:\HarmonyOS_App_Plans\.claude\知识库.md`

## 知识管理

```
C:\HarmonyOS_App_Plans\
├── .claude/
│   ├── 当前问题.md    # 临时问题沟通（可清空重写）
│   └── 知识库.md      # 已验证方案（只追加不删除）
└── SunChaser/
    └── .claude/
        └── CLAUDE.md  # 项目状态与日志
```

**规则**:
- `当前问题.md` 每次新问题时清空重写
- `知识库.md` 仅追加验证成功的方案（标注日期和API版本）
- 禁止创建其他临时文件（如 `传感器问题.md`）

## 项目特定注意事项

### 天文计算精度要求
- 太阳位置误差需 <0.01° (SPA算法误差可达0.0003°)
- 输入: UTC时间 + 经纬度 + 海拔(可选)
- 输出: 方位角(azimuth) + 高度角(altitude/elevation) + 日出日落时间

**SPA算法实现步骤**:
```typescript
function calculateSolarPosition(lat: number, lon: number, date: Date) {
  // 1. 计算儒略日（Julian Day）
  const jd = getJulianDay(date);
  
  // 2. 计算真太阳时（Solar Time）
  const solarTime = getSolarTime(jd, lon);
  
  // 3. 计算太阳赤纬（Declination）
  const declination = getSolarDeclination(jd);
  
  // 4. 计算高度角（Elevation）
  const elevation = Math.asin(
    Math.sin(lat) * Math.sin(declination) +
    Math.cos(lat) * Math.cos(declination) * Math.cos(solarTime)
  );
  
  // 5. 计算方位角（Azimuth）
  const azimuth = calculateAzimuth(lat, declination, solarTime, elevation);
  
  return { azimuth, elevation };
}
```

**推荐移植**: JavaScript的`suncalc.js`库（约300行，逻辑清晰）

### 传感器融合策略
组合使用:
```typescript
import sensor from '@kit.SensorService';

// 方向传感器（推荐使用，已融合磁力计+加速度计）
sensor.on(sensor.SensorId.ORIENTATION, (data) => {
  const azimuth = data.values[0]; // 方位角（弧度）
  const pitch = data.values[1];   // 俯仰角
  const roll = data.values[2];    // 翻滚角
});

// 或单独使用传感器
sensor.on(sensor.SensorId.MAGNETIC_FIELD, callback); // 磁力计
sensor.on(sensor.SensorId.ACCELEROMETER, callback);  // 加速度计
sensor.on(sensor.SensorId.GYROSCOPE, callback);      // 陀螺仪
```

**关键注意**:
- ⚠️ 不同设备传感器精度差异大（罗盘偏移可达±10°）
- ⚠️ 必须增加数据校准逻辑或让用户手动校准
- 使用互补滤波或卡尔曼滤波消除抖动，采样率建议20-50Hz

### AR绘制性能优化
- 太阳轨迹曲线预计算并缓存
- Canvas离屏绘制，仅传感器变化>阈值时更新
- 使用 `requestAnimationFrame` 控制绘制频率
- 目标帧率: 30fps以上

**性能关键实践**:
```typescript
// 1. 复杂计算移至Worker线程（避免阻塞UI）
import worker from '@ohos.worker';
const calcWorker = new worker.ThreadWorker('workers/SunCalculator.ts');
calcWorker.postMessage({ lat, lon, date });

// 2. Canvas绘制优化
@Component
struct ARView {
  private canvasContext: CanvasRenderingContext2D;
  
  build() {
    Canvas(this.canvasContext)
      .onReady(() => {
        // 仅在传感器变化>1°时重绘
        if (Math.abs(newAzimuth - oldAzimuth) > 0.017) {
          this.drawSunPath();
        }
      })
  }
}

// 3. 高性能场景考虑C++ Native模块
// 使用NDK编写天文计算，通过NAPI调用
```

## 权限与配置

### module.json5 必需权限
```json5
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.LOCATION",
        "reason": "$string:location_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      },
      {
        "name": "ohos.permission.APPROXIMATELY_LOCATION"
      },
      {
        "name": "ohos.permission.CAMERA",
        "reason": "$string:camera_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      }
    ]
  }
}
```

### 动态权限申请
```typescript
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';

const atManager = abilityAccessCtrl.createAtManager();
await atManager.requestPermissionsFromUser(context, [
  'ohos.permission.LOCATION',
  'ohos.permission.CAMERA'
]);
```

### 传感器校准提醒
- 不同设备罗盘偏移差异可达±10°
- 建议在首次启动时提示用户做"8字校准"
- 或提供手动偏移调整选项（保存在偏好设置中）

## 参考资源

- [HarmonyOS传感器开发](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/sensor-guidelines-V5)
- [NREL Solar Position Algorithm](https://midcdmz.nrel.gov/spa/)
- [Suncalc.js](https://github.com/mourner/suncalc) - 可移植参考实现
- [Worker多线程开发](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/worker-introduction-V5)

---

**最后更新**: 2025-12-10 | **项目阶段**: MVP开发启动期
