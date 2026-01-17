# Copilot Instructions - 星晷(SunChaser)

> 本文件定义 GitHub Copilot 在此项目中的行为规范

## 项目信息

- **项目名称**: 星晷 / 逐日 (SunChaser)
- **项目定位**: 太阳/月亮位置预测与AR可视化工具
- **技术栈**: HarmonyOS NEXT + ArkTS + ArkUI (API 6.0.0/20)
- **开发工具**: DevEco Studio
- **目标设备**: Phone (后期可扩展 Tablet)
- **核心功能**: 
  - 太阳/月亮位置计算与实时罗盘显示
  - AR相机叠加太阳轨迹
  - 摄影黄金时段提醒
  - 地图视图与阴影计算

---

## 🔴 AI 强制工作流程

### 开始工作前
1. **必须先读取** `.claude/CLAUDE.md` 确认项目状态
2. **确认理解**: 最近完成的功能、当前待办事项、已知问题
3. **不依赖对话历史** - 每次都要重新读取项目状态

### 遇到困难立即求助 CodeGenie
**原则**: 如果一个问题尝试 2-3 次仍无法解决，**立即停止尝试**，将问题整理到 `C:\HarmonyOS_App_Plans\.claude\当前问题.md`

**必须求助的场景**:
- 编译错误修复超过 3 次仍未解决
- 天文计算算法不确定（SPA、NOAA等）
- 传感器融合（磁力计+陀螺仪+加速度计）逻辑复杂
- AR相机叠加绘制性能问题
- 地图 API 使用不确定（MapKit）
- ArkTS 严格模式语法限制不清楚
- 任何需要查阅官方文档的技术问题

**求助流程**:
1. 停止尝试修复
2. 打开 `C:\HarmonyOS_App_Plans\.claude\当前问题.md`
3. 清空文件并写入新问题（包含：问题描述、代码上下文、尝试过的方法、错误信息）
4. 告知用户："问题已整理到 `当前问题.md`，请粘贴给 CodeGenie"

### 代码修改原则
- ✅ **理解全局再修改** - 先读完整个 build() 函数或相关代码块
- ✅ **一次只改一个问题** - 避免连锁错误
- ✅ 批量操作使用 `multi_replace_string_in_file`
- ❌ **禁止重复修复已解决的问题** - 先确认问题是否真的存在
- ❌ 禁止凭假设修改 - 先用截图/日志确认实际状态

### 🔴 重大代码变动前必须备份
**原则**: 对核心文件进行重构/大幅修改前,**必须先备份**

**需要备份的场景**:
- 重构天文计算引擎
- 修改传感器数据处理逻辑
- 优化 AR 绘制性能涉及算法变更
- 重构罗盘/地图核心组件
- 任何可能导致功能失效的修改

**备份流程**:
1. 使用 PowerShell 命令备份:
   ```powershell
   $backupName = "文件名.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
   Copy-Item "原文件路径" "备份路径/$backupName"
   ```
2. 将备份位置记录到 `.claude/CLAUDE.md` 的"开发日志"
3. 格式: `备份文件: entry/src/main/ets/utils/文件名.backup_时间戳`
4. 确认备份成功后再进行代码修改

### 完成任务后
1. 更新 `.claude/CLAUDE.md` 的"项目进展追踪"
2. 询问用户当前北京时间并更新时间戳

### 交互与文件操作
- ✅ **Todo 列表必须使用中文** - 方便用户直观查看工作安排
- ✅ **修改文件禁止"删除重建"** - 必须使用编辑工具 (`replace_string_in_file` 等) 修改现有文件，保留文件历史
- ❌ **禁止抢跑知识库** - 必须等待用户明确反馈"构建成功"或"运行正常"后，才能将方案写入知识库

---

## 知识管理规则

### 文件结构
```
C:\HarmonyOS_App_Plans\
├── .claude/                    # 全局共享（跨项目）
│   ├── 当前问题.md             # 与 CodeGenie 实时沟通（可清空重写）
│   └── 知识库.md               # 已验证解决方案（只追加，不删除）
└── SunChaser/
    └── .claude/
        └── CLAUDE.md           # 项目指导文档
```

### 核心规则

#### 1. `当前问题.md` - 临时沟通文档
- ✅ **可清空重写** - 每次新问题时完全清空
- ✅ 问题解决后，将有用信息移动到知识库，然后清空
- ❌ **禁止创建其他临时文件** - 如 `传感器问题.md`、`问题_backup.md` 等
- 用途：与 CodeGenie 实时沟通当前问题

#### 2. `知识库.md` - 永久知识库
- ✅ **只追加，不删除** - 除非内容被证明是错误的
- ✅ 方案验证成功后才追加
- ✅ 标注验证日期和适用 API 版本
- ❌ **禁止将未验证的 AI 建议直接写入**
- 用途：存储已验证的技术解决方案

#### 3. 禁止随意创建文件
- ❌ 禁止为每个问题创建单独的 `.md` 文件
- ❌ 禁止创建 `问题_v1.md`、`问题_v2.md` 等版本文件
- ✅ 所有临时问题都写入 `当前问题.md`
- ✅ 所有已验证方案追加到 `知识库.md`

### 与 CodeGenie 协作流程

1. 遇到不确定问题 → **清空** `当前问题.md` 并写入新问题
2. 用户粘贴 CodeGenie 回复 → 分析并执行
3. 方案验证成功 → **立即追加到** `知识库.md`
4. 清空 `当前问题.md` 准备下一个问题

---

## 编码规范

### ArkTS 语法规范

```typescript
// ❌ 静态方法不能用 this
static calculate(): Result { return this.helper(); }

// ✅ 使用类名
static calculate(): Result { return SunCalculator.helper(); }

// ❌ 禁止使用 TypeScript 的 is 类型守卫
function isSunData(obj: Object): obj is SunData { ... }

// ✅ 使用简单的字段检查
if (obj !== null && obj.azimuth !== undefined && typeof obj.azimuth === 'number')
```

**ArkTS 严格限制**:
- ❌ **禁止类型守卫 `is`**: ArkTS 不支持 `obj is Type` 语法
- ❌ **禁止 `any` 和 `unknown`**: 必须使用明确类型
- ❌ **限制 `ESObject` 使用**: 避免使用 ESObject，改用泛型或明确接口
- ❌ **禁止对象字面量类型**: 嵌套对象需定义独立 interface
- ✅ **使用泛型**: `function calculate<T>(): T`
- ✅ **可选字段防御**: `interface SunPosition { azimuth?: number; altitude?: number }`

**基础规范**:
- **导出**: `export { ClassName }` (禁止 export default)
- **布局**: `Column/Row/Stack` (禁止 div/flex)
- **滚动**: `onDidScroll` (onScroll 已废弃)
- **组件命名**: PascalCase (如 `CompassView.ets`)
- **文件命名**: PascalCase.ets

### 常见陷阱

| 问题 | 正确做法 |
|-----|---------|
| ForEach 加样式 | 包裹在 Row/Column 中 |
| layoutWeight 异常 | 确保父容器有明确高度 |
| @Builder 不响应 | 使用参数传递而非直接引用 @StorageLink |
| 预览器差异 | 给状态变量设置合理默认值 |
| Canvas 性能问题 | 避免每帧重绘，使用离屏渲染缓存 |

---

## 项目架构设计

### 目录结构（规划）
```
entry/src/main/ets/
├── entryability/
│   └── EntryAbility.ets          # 应用入口
├── pages/
│   ├── Index.ets                 # 主页（罗盘视图）
│   ├── MapView.ets               # 地图视图
│   ├── ARView.ets                # AR相机视图
│   └── SettingsPage.ets          # 设置页
├── components/                    # UI组件
│   ├── Compass.ets               # 3D罗盘组件
│   ├── SunPath.ets               # 太阳轨迹绘制
│   ├── TimeSlider.ets            # 时间轴滑块
│   └── GoldenHourCard.ets        # 黄金时段卡片
├── utils/                         # 工具类
│   ├── SunCalculator.ets         # 太阳位置计算（SPA算法）
│   ├── MoonCalculator.ets        # 月亮位置计算
│   ├── SensorFusion.ets          # 传感器融合（罗盘校准）
│   └── TimeUtils.ets             # 时间处理工具
├── models/                        # 数据模型
│   ├── SunPosition.ets           # 太阳位置数据
│   ├── Location.ets              # 地理位置
│   └── GoldenHour.ets            # 黄金时段数据
└── services/                      # 服务层
    ├── LocationService.ets       # 定位服务
    ├── SensorService.ets         # 传感器服务
    └── PreferenceService.ets     # 偏好设置
```

### 核心技术点

#### 1. 天文计算
- 使用 **SPA (Solar Position Algorithm)** 或 **NOAA** 算法
- 输入: 日期时间 + 经纬度
- 输出: 方位角(azimuth) + 高度角(altitude)
- 参考: [NREL SPA](https://midcdmz.nrel.gov/spa/)

#### 2. 传感器融合
```typescript
// 组合使用三种传感器
@ohos.sensor.magnetometer    // 磁力计（获取磁北方向）
@ohos.sensor.accelerometer   // 加速度计（确定设备倾斜）
@ohos.sensor.gyroscope       // 陀螺仪（稳定方向）

// 使用互补滤波或卡尔曼滤波消除抖动
```

#### 3. AR 相机叠加
```typescript
// 技术方案：
1. Camera API 获取预览流
2. XComponent 显示相机画面
3. Canvas API 在上层绘制太阳轨迹曲线
4. 根据传感器数据实时更新绘制坐标
```

---

## 开发阶段规划

### 阶段 1: MVP 核心功能 (4-6周)
- [x] 项目初始化
- [ ] 太阳位置计算引擎（SPA算法实现）
- [ ] 基础罗盘UI（显示太阳方位角）
- [ ] 传感器集成（磁力计+加速度计）
- [ ] 时间选择器（模拟不同时间的太阳位置）
- [ ] 日出/日落/黄金时段计算

### 阶段 2: 地图与可视化 (3-4周)
- [ ] 地图集成（MapKit）
- [ ] 地图上绘制日出/日落方向线
- [ ] 地点搜索与收藏
- [ ] 3D罗盘优化（高度角可视化）

### 阶段 3: AR 功能 (3-4周)
- [ ] 相机权限与预览
- [ ] Canvas绘制太阳轨迹
- [ ] 实时传感器融合校准
- [ ] AR视图性能优化

### 阶段 4: 高级功能 (按需)
- [ ] 月亮位置计算
- [ ] 阴影长度计算器
- [ ] 照片拍摄规划
- [ ] 导出分享功能

---

## 项目进展追踪

### 当前状态
- **版本**: 0.1.0 (项目初始化)
- **最新功能**: 基础 Hello World 模板
- **下一步计划**: 实现太阳位置计算引擎

### 开发日志

#### 2025-12-10 (项目创建 + 技术调研)
**初始化完成**:
- ✅ 创建项目结构 (API 6.0.0/20)
- ✅ 配置基础模板
- ✅ 创建 AI 指导文档
- ✅ 技术方案明确：
  - 天文算法：SPA算法（误差0.0003°）
  - 传感器API：`@kit.SensorService`
  - 性能优化：Worker线程 + Canvas离屏渲染

**待办事项**:
1. 实现 `SunCalculator.ets` 工具类（SPA算法5步骤）
2. 配置权限：LOCATION + CAMERA
3. 设计主页罗盘UI
4. 集成传感器API（含校准提示）

**技术要点记录**:
- SPA算法步骤：儒略日 → 真太阳时 → 赤纬 → 高度角 → 方位角
- 推荐移植：suncalc.js (约300行)
- 传感器校准：不同设备偏移±10°，需提供手动调整

**技术要点记录**:
- SPA算法步骤：儒略日 → 真太阳时 → 赤纬 → 高度角 → 方位角
- 推荐移植：suncalc.js (约300行)
- 传感器校准：不同设备偏移±10°，需提供手动调整

---

## 构建与测试

> ⚠️ **必须人工操作** - AI 不能自动构建或运行应用

### 构建流程（用户在 DevEco Studio 中操作）
1. **安装依赖**: `ohpm install`
2. **构建 HAP**: Build → Build Hap(s)/APP(s) → Build Hap(s)
3. **运行到设备**: 点击运行按钮或 Shift+F10
4. **清理构建**: Build → Clean Project

### 调试要点
- **传感器测试**: 必须在真机上测试，模拟器无法模拟传感器
- **定位测试**: 需要开启设备GPS权限
- **相机测试**: 必须真机，且需授予相机权限

### AI 职责
- ❌ 禁止尝试运行 `hvigorw` 等构建命令
- ✅ 修改代码后提醒用户手动构建测试
- ✅ 等待用户反馈构建结果或运行截图

---

## 常见问题记录

### 问题 1: [占位 - 待补充]
**现象**: 
**原因**: 
**解决方案**: 

---

## 参考资源

### 官方文档
- [HarmonyOS 传感器开发](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/sensor-guidelines-V5)
- [相机开发指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/camera-overview-V5)
- [地图服务 MapKit](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/mapkit-intro-V5)

### 算法参考
- [NREL Solar Position Algorithm](https://midcdmz.nrel.gov/spa/)
- [Suncalc.js (可移植参考)](https://github.com/mourner/suncalc)
- [Astronomy Engine](https://github.com/cosinekitty/astronomy)

### 社区资源
- HarmonyOS 开发者论坛
- GitHub: HarmonyOS NEXT 示例代码

---

**最后更新**: 2025-12-10
**项目状态**: 🟢 进行中
