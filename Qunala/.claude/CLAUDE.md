# 去哪拉 (Qunala) - AI 开发指导文档

> 本文件定义 GitHub Copilot 在"去哪拉"厕所定位 App 项目中的行为规范

## 项目信息

- **项目名称**: 去哪拉 (Qunala)
- **项目描述**: 基于地图的公共厕所定位与导航应用
- **技术栈**: HarmonyOS + ArkTS + ArkUI (API 12+)
- **开发工具**: DevEco Studio 6.0.x
- **核心功能**: 
  - 地图显示当前位置
  - 显示附近公共厕所位置
  - 导航到选定厕所
  - 厕所信息展示（评分、设施、开放时间等）
  - 用户评价与反馈

---

## 🔴 AI 强制工作流程

### 开始工作前
1. **必须先读取** `.claude/CLAUDE.md` 确认项目状态
2. **确认理解**: 最近完成的功能、当前待办事项、已知问题
3. **不依赖对话历史** - 每次都要重新读取项目状态

### 编写涉及数据模型的代码时
**强制步骤**（违反此规则会导致编译错误）：
1. **先读模型定义** - 使用 `read_file` 读取相关模型文件（Toilet.ets / User.ets / ToiletRecord.ets）
2. **确认属性名** - 对照模型中的实际属性名（不要凭记忆）
3. **确认枚举值** - 检查枚举的实际命名（如 `NORMAL` 而非 `NEUTRAL`）
4. **检查依赖常量** - 确认 Colors.ets 中是否有所需颜色常量
5. **验证对象字面量** - 嵌套对象必须有独立 interface 定义

**示例流程**：
```
用户: "在列表中显示厕所的无障碍标签"
AI 操作:
1. read_file Toilet.ets → 确认属性是 hasDisabledAccess 而非 isAccessible
2. read_file Colors.ets → 确认是否有需要的颜色常量
3. 编写代码: toilet.hasDisabledAccess
```

### 遇到困难立即求助 CodeGenie
**原则**: 如果一个问题尝试 2-3 次仍无法解决，**立即停止尝试**，将问题整理到 `C:\HarmonyOS_App_Plans\.claude\当前问题.md`

**必须求助的场景**:
- 编译错误修复超过 3 次仍未解决
- Map Kit API 使用不确定（如地图组件、标记点、路径规划等）
- LocationKit 定位权限或功能问题
- UI 交互功能失效且找不到原因
- ArkTS 严格模式语法限制不清楚
- 任何需要查阅官方文档的技术问题

**求助流程**:
1. 停止尝试修复
2. 打开 `C:\HarmonyOS_App_Plans\.claude\当前问题.md`
3. 清空文件并写入新问题（包含：问题描述、代码上下文、尝试过的方法、错误信息）
4. 告知用户："问题已整理到 `当前问题.md`，请粘贴给 CodeGenie"

### 代码修改原则
- ✅ **理解全局再修改** - 先读完整个 build() 函数或相关代码块
- ✅ **修改前必读模型定义** - 使用 `read_file` 确认属性名/枚举值/接口结构
- ✅ **一次只改一个问题** - 避免连锁错误
- ✅ 批量操作使用 `multi_replace_string_in_file`
- ❌ **禁止重复修复已解决的问题** - 先确认问题是否真的存在
- ❌ 禁止凭假设修改 - 先用截图/日志确认实际状态
- ❌ **禁止凭记忆写代码** - 永远对照模型文件确认属性名

### 🔴 重大代码变动前必须备份
**原则**: 对核心文件进行重构/大幅修改前,**必须先备份**

**需要备份的场景**:
- 重构地图/定位逻辑
- 修改核心业务流程 (如厕所搜索、导航功能)
- 优化性能涉及算法变更
- 任何可能导致功能失效的修改

**备份流程**:
1. 使用 PowerShell 命令备份:
   ```powershell
   $backupName = "文件名.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
   Copy-Item "原文件路径" "备份路径/$backupName"
   ```
2. 将备份位置记录到 `.claude/CLAUDE.md` 的"开发日志"
3. 格式: `备份文件: entry/src/main/ets/views/文件名.backup_时间戳`
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
└── Qunala/
    └── .claude/
        └── CLAUDE.md           # 项目指导文档
```

### 核心规则

#### 1. `当前问题.md` - 临时沟通文档
- ✅ **可清空重写** - 每次新问题时完全清空
- ✅ 问题解决后，将有用信息移动到知识库，然后清空
- ❌ **禁止创建其他临时文件** - 如 `地图按钮问题.md`、`问题_backup.md` 等
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
static calculate(): Result { return ClassName.helper(); }

// ❌ 禁止使用 TypeScript 的 is 类型守卫
function isUser(obj: Object): obj is User { ... }

// ✅ 使用简单的字段检查
if (obj !== null && obj.name !== undefined && typeof obj.name === 'string')
```

**ArkTS 严格限制**:
- ❌ **禁止类型守卫 `is`**: ArkTS 不支持 `obj is Type` 语法
- ❌ **禁止 `any` 和 `unknown`**: 必须使用明确类型
- ❌ **限制 `ESObject` 使用**: 避免使用 ESObject，改用泛型或明确接口
- ❌ **禁止对象字面量类型**: 嵌套对象需定义独立 interface
- ✅ **使用泛型**: `function request<T>(): Promise<T>`
- ✅ **可选字段防御**: `interface Data { code?: string; value?: number }`

### HarmonyOS 开发规范
- **导出**: `export { ClassName }` (禁止 export default)
- **布局**: `Column/Row/Stack/Flex` (禁止 div)
- **滚动**: `onDidScroll` (onScroll 已废弃)
- **组件命名**: PascalCase
- **文件命名**: PascalCase.ets

### 地图与定位相关
- **地图组件**: 使用 HarmonyOS Map Kit
- **定位服务**: 使用 LocationKit，需申请权限
- **权限申请**: `ohos.permission.LOCATION` / `ohos.permission.APPROXIMATELY_LOCATION`
- **地图标记**: 使用 Marker 组件标注厕所位置
- **路径规划**: 使用 Map Kit 导航 API

### 常见陷阱

| 问题 | 正确做法 |
|-----|---------|
| ForEach 加样式 | 包裹在 Row/Column 中 |
| layoutWeight 异常 | 确保父容器有明确高度 |
| @Builder 不响应 | 使用参数传递而非直接引用 @StorageLink |
| 预览器差异 | 给状态变量设置合理默认值 |
| 地图不显示 | 检查权限申请和 API Key 配置 |
| 定位失败 | 确认设备位置服务已开启 |

### ⚠️ AI 高频错误模式（基于实际开发总结）

> **更新**: 2025-12-10 - "去哪拉"项目开发经验

#### 1. 对象字面量类型声明错误
**错误写法**:
```typescript
comfortDistribution: {
  veryComfortable: number;
  comfortable: number;
}
```
**正确做法**:
```typescript
// 必须定义独立 interface
export interface ComfortDistribution {
  veryComfortable: number;
  comfortable: number;
}
comfortDistribution: ComfortDistribution;
```

#### 2. 模型属性名不一致
**常见错误**: 组件中使用 `toilet.isFree`，但模型中只有 `toilet.type`
**解决方案**:
- 修改代码前先用 `read_file` 确认模型定义
- 使用模型中实际存在的属性名
- 示例: `toilet.type === ToiletType.PUBLIC`（而非 `toilet.isFree`）

#### 3. 枚举值命名错误
**错误**: `ComfortLevel.NEUTRAL`  
**正确**: `ComfortLevel.NORMAL`（需对照模型定义）

#### 4. 缺失颜色常量
**错误**: 直接使用 `Colors.DIVIDER` 但未定义  
**预防**: 编译前检查 Colors.ets 是否包含所需常量

#### 5. User/ToiletRecord 对象字面量类型不匹配
**问题**: 直接赋值字符串数组给 `achievements: Achievement[]`
**正确做法**:
```typescript
achievements: [
  {
    type: AchievementType.EXPLORER,
    level: 2,
    progress: 15,
    target: 20
  }
]
```

#### 6. 时间戳属性名混淆
**错误**: `record.timestamp` / `record.recordedAt`  
**正确**: `record.recordTime`（需对照 ToiletRecord 模型）

#### 7. UserStats 属性名错误
**错误**: `favoriteCount` / `uploadCount`  
**正确**: `favoriteToilets` / `contributedToilets`（需对照 User 模型）

### 🛡️ 错误预防检查清单

修改代码前必须确认：
- [ ] 用 `read_file` 读取相关模型定义
- [ ] 确认枚举值的实际命名
- [ ] 检查 Colors.ets 是否有所需常量
- [ ] 对象字面量是否符合 interface 定义
- [ ] 嵌套对象是否定义了独立 interface

---

## 构建与测试

> ⚠️ **必须人工操作** - AI 不能自动构建或运行应用

### 构建流程（用户在 DevEco Studio 中操作）
1. **安装依赖**: `ohpm install`
2. **构建 HAP**: Build → Build Hap(s)/APP(s) → Build Hap(s)
3. **运行到设备**: 点击运行按钮或 Shift+F10
4. **清理构建**: Build → Clean Project

### AI 职责
- ❌ 禁止尝试运行 `hvigorw` 等构建命令
- ✅ 修改代码后提醒用户手动构建测试
- ✅ 等待用户反馈构建结果或运行截图

---

## 项目进展追踪

### 当前版本: v0.1.0 (初始化阶段)

### 📋 核心功能规划

#### Phase 1: 基础功能 (v0.1.0 - v0.3.0)
- [ ] 地图集成与显示
  - [ ] 集成 HarmonyOS Map Kit
  - [ ] 显示当前位置
  - [ ] 地图交互（缩放、拖动）
- [ ] 定位功能
  - [ ] 申请定位权限
  - [ ] 获取当前位置
  - [ ] 位置更新监听
- [ ] 厕所数据展示
  - [ ] 在地图上标记厕所位置
  - [ ] 厕所列表展示
  - [ ] 厕所详情页面

#### Phase 2: 核心功能 (v0.4.0 - v0.6.0)
- [ ] 搜索功能
  - [ ] 附近厕所搜索
  - [ ] 按距离排序
  - [ ] 筛选功能（设施、评分等）
- [ ] 导航功能
  - [ ] 路径规划
  - [ ] 实时导航
  - [ ] 到达提醒
- [ ] 厕所信息
  - [ ] 基础信息（地址、开放时间）
  - [ ] 设施信息（无障碍、母婴室等）
  - [ ] 图片展示

#### Phase 3: 增强功能 (v0.7.0 - v1.0.0)
- [ ] 用户系统
  - [ ] 用户登录/注册
  - [ ] 个人中心
  - [ ] 收藏功能
- [ ] 评价系统
  - [ ] 评分功能
  - [ ] 评论功能
  - [ ] 图片上传
- [ ] 数据贡献
  - [ ] 添加新厕所
  - [ ] 更新厕所信息
  - [ ] 报告问题
- [ ] 桌面小组件
  - [ ] 一键导航到最近厕所
  - [ ] 实时距离显示
  - [ ] 2x2/2x4 网格尺寸适配

### 🎯 当前待办事项
<!-- 按优先级排序 -->
1. 创建基础项目结构
2. 集成地图组件
3. 实现定位功能
4. 设计 UI 界面

### ✅ 已完成功能
<!-- 按时间倒序 -->

### 2025-12-10 (项目初始化 + 基础架构搭建)
- ✅ 创建项目指导文档
- ✅ 定义开发规范和工作流程
- ✅ 收到 CodeGenie + 豆包专家建议
- ✅ 明确 UI/UX 设计方向和数据获取策略
- ✅ 新增桌面小组件导航功能方案
- ✅ **开始代码开发**：
  - 创建颜色常量（黄色主调配色方案）
  - 创建配置常量（地图、缓存、API等）
  - 创建数据模型（Toilet、ToiletRecord、User）
  - 创建主页面框架（4个Tab）
  - 配置底部导航栏
  - **优化 Tab 切换动画**：
    - 图标缩放动画（1.0 → 1.1）
    - 文字颜色渐变 + 透明度变化
    - 下划线指示器动画
    - 页面内容入场动画（上滑淡入）
    - 动画时长：200-300ms，使用 EaseInOut 曲线

---

### 2025-12-10 (项目初始化)
**初始化**:
- 创建 `.claude/CLAUDE.md` 项目指导文档
- 定义 AI 工作流程和编码规范
- 规划核心功能路线图
**专家建议**:
- 收到 CodeGenie 和豆包的详细设计建议
- 明确地图界面布局：顶部搜索栏 + 半透明浮动面板
- 确定标记系统：颜色区分类型 + 动态热力图
- 数据获取策略：官方数据 + 高德/华为 Map Kit + 用户众包
- 鸿蒙特色功能：分布式协同 + 场景感知 + 健康管理
- **新增桌面小组件**：一键导航 + 实时距离显示 + 智能推荐算法t + 用户众包
- 鸿蒙特色功能：分布式协同 + 场景感知 + 健康管理de/CLAUDE.md` 项目指导文档
- 定义 AI 工作流程和编码规范
- 规划核心功能路线图

---

## 已知问题

### 待解决问题
<!-- 格式: [严重程度] 问题描述 - 发现日期 -->

### 已解决问题
<!-- 保留历史记录，方便回溯 -->

---

## 技术债务

### 需要优化的项目
<!-- 格式: [优先级] 优化内容 - 原因 -->

---

## 专家建议整合 (CodeGenie + 豆包)

### UI/UX 设计要点
1. **地图界面布局**
   - 顶部：搜索栏 + 定位按钮 + 筛选器
   - 地图缩放：13-16 级（平衡全局与细节）
   - 半透明浮动面板展示详情（不遮挡地图）
   - 鸿蒙"实况胶囊"：导航时显示关键信息

2. **标记系统设计**
   - 不同颜色/形状区分类型（公厕🚽/商场🏬/餐厅等）
   - 动态热力图显示繁忙程度（红=拥挤/绿=空闲）
   - 标记随距离自动缩放（近大远小）
   - 必备属性：位置、类型、状态、评分、特色设施

3. **关键 HarmonyOS API**
   - `LocationButton` 组件（API 10+）：避免频繁授权弹窗
   - `startAbilityByType`：拉起第三方导航（Petal 地图）
   - `@kit.ArkData`：本地存储如厕记录
   - `@kit.FilePicker`：用户上传照片
   - `Navigation` 组件：管理页面路由

### 数据获取策略
1. **官方数据（核心来源）**
   - 全国公厕云平台（住建部）
   - 地方政府开放数据平台
   - 景区/商场/交通枢纽数据合作

2. **地图 API 数据（补充）**
   - 高德地图 SDK（鸿蒙官方认证）：公厕 POI + 室内地图
   - 华为 Map Kit（鸿蒙原生）：性能最优 + 分布式能力

3. **用户贡献（扩展）**
   - 上报新厕所 + 异常状态（经审核后更新）

### 差异化功能（鸿蒙特色）
1. **分布式协同**
   - 手机发现 → 平板查看详情 → 手表导航提醒
   - 车机互联：驾车时自动切换到大屏导航

2. **场景感知**
   - 根据用户活动（跑步/逛街）智能推荐附近厕所

3. **健康管理**
   - 如厕记录：时间、地点、类型、时长、评分
   - 数据可视化：频率日历、时长统计图表
   - 智能提醒：根据习惯提醒规律如厕
   - AI 问答：基于医疗知识库解答健康疑问

4. **桌面小组件（新增）**
   - **一键导航**：点击小组件直接导航到最近厕所
   - **实时距离显示**：通过 `LocalStorage` 更新距离信息
   - **动画效果**：使用 `@AnimatableProp` 添加点击反馈
   - **智能推荐**：结合历史记录加权计算（曼哈顿距离算法）
   - **跨组件通信**：`postCardAction` + `want` 参数传递导航意图
   - **规范要求**：
     - 尺寸适配：2x2 / 2x4 网格
     - 内存占用：≤ 10MB
     - 刷新间隔：≥ 30 分钟

**小组件实现代码示例**:
```typescript
// 小组件入口
@Entry
@Component
struct ToiletWidget {
  @LocalStorageProp('nearestToilet') nearestToilet: string = '计算中...';

  build() {
    Column() {
      Text(this.nearestToilet)
        .fontSize(14)
      Button("一键导航")
        .onClick(() => {
          postCardAction(this, {
            action: 'router',
            abilityName: 'EntryAbility',
            params: { action: 'navigate_nearest' }
          });
        })
    }
    .padding(10)
  }
}

// 拉起第三方导航
let want = {
  action: 'ohos.want.action.navigate',
  parameters: {
    destination: `${toiletLat},${toiletLng}`,
    provider: 'petalmaps' // 高德/百度/Petal
  }
};
context.startAbilityByType(want);
```

### 隐私与安全
- 记录数据本地加密存储，可选云端备份（需授权）
- 权限申请：`ohos.permission.LOCATION` + `APPROXIMATELY_LOCATION` 配对
- 严格遵循 HarmonyOS 隐私保护规范

### 实施路线图
- **Phase 1 (1-2月)**：地图展示 + 标记系统 + 导航 + 如厕记录
- **Phase 2 (1月)**：专业意见 + 社区互动 + 鸿蒙特性优化
- **Phase 3 (2-4周)**：多设备测试 + 数据验证 + 应用市场上架

---

## 备注

- 本项目使用 HarmonyOS 原生开发，不使用跨平台框架
- 地图服务需要申请相应的 API Key（AppGallery Connect）
- 定位功能需要用户授权
- 厕所数据来源：官方数据 + 地图 API + 用户众包
