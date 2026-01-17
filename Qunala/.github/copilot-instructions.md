# Qunala (去哪拉) - AI Coding Agent Instructions

> 本文件定义 GitHub Copilot 在此项目中的行为规范

Public toilet locator app built with **HarmonyOS NEXT** (API 12) using ArkTS and ArkUI.

## Project Architecture

**Tech Stack**: HarmonyOS + ArkTS + ArkUI (API 12, SDK 6.0.0)  
**Build Tool**: Hvigor (via `ohpm install`)  
**Entry Point**: `entry/src/main/ets/entryability/EntryAbility.ets` → loads `pages/Index.ets`

```
entry/src/main/ets/
├── entryability/      # App lifecycle (UIAbility)
├── pages/             # UI components (@Entry/@Component)
├── views/             # Reusable custom components (TBD)
├── models/            # Data interfaces (TBD)
└── utils/             # Helper functions (TBD)
```

**Core Features** (planned):
- Full-screen map interface with toilet markers
- Real-time location tracking (LocationKit)
- Navigation and routing (Map Kit)
- User reviews and toilet records

---

## 🔴 Critical Rules

### Before Writing Model-Related Code
**MUST read model files first** to avoid property name errors:
```bash
# Always check actual property names in:
- models/Toilet.ets       # hasDisabledAccess (not isAccessible)
- models/User.ets         # favoriteToilets (not favoriteCount)
- models/ToiletRecord.ets # recordTime (not timestamp)
- constants/Colors.ets    # Check if color constant exists
```

### Common Pitfalls to Avoid
| ❌ Wrong | ✅ Correct | Reason |
|---------|-----------|--------|
| `toilet.isFree` | `toilet.type === ToiletType.PUBLIC` | Property doesn't exist |
| `ComfortLevel.NEUTRAL` | `ComfortLevel.NORMAL` | Wrong enum name |
| `record.timestamp` | `record.recordTime` | Wrong property name |
| `Colors.DIVIDER` (if undefined) | Add to Colors.ets first | Missing constant |
| Nested object literal | Define separate `interface` | ArkTS requirement |

### Object Literal Type Safety
```typescript
// ❌ Wrong: Inline object type
comfortDistribution: {
  veryComfortable: number;
  comfortable: number;
}

// ✅ Correct: Separate interface
export interface ComfortDistribution {
  veryComfortable: number;
  comfortable: number;
}
comfortDistribution: ComfortDistribution;
```
4. 告知用户："问题已整理到 `当前问题.md`，请粘贴给 CodeGenie"

### 代码修改原则
- ✅ **理解全局再修改** - 先读完整个 `build()` 函数或相关代码块
- ✅ **一次只改一个问题** - 避免连锁错误
- ✅ 批量操作使用 `multi_replace_string_in_file`
- ❌ **禁止重复修复已解决的问题** - 先确认问题是否真的存在
- ❌ 禁止凭假设修改 - 先用截图/日志确认实际状态
- ❌ **禁止删除重建文件** - 必须使用编辑工具保留文件历史

### 🔴 重大代码变动前必须备份
**原则**: 对核心文件进行重构/大幅修改前，**必须先备份**

**需要备份的场景**:
- 重构地图/定位逻辑
- 修改核心业务流程（厕所搜索、导航功能）
- 优化性能涉及算法变更
- 任何可能导致功能失效的修改

**备份流程**:
```powershell
$backupName = "文件名.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item "原文件路径" "备份路径/$backupName"
```
记录备份位置到 `.claude/CLAUDE.md` 的"开发日志"

### 完成任务后
1. 更新 `.claude/CLAUDE.md` → "项目进展追踪"
2. 询问用户当前北京时间并更新时间戳

### 交互与文件操作
- ✅ **Todo 列表必须使用中文** - 方便用户直观查看工作安排
- ❌ **禁止抢跑知识库** - 必须等待用户明确反馈"构建成功"或"运行正常"后，才能将方案写入知识库

---

## 编码规范

### ArkTS 语法规范

ArkTS is **NOT TypeScript** - it has strict limitations:

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

---

## UI Component Conventions

### Component Structure
```typescript
@Entry
@Component
struct ToiletMap {
  @State currentLocation: Location = defaultLocation;
  @StorageLink('toiletList') toiletList: Toilet[] = [];

  build() {
    Column() {
      Map({ /* ... */ })
        .width('100%')
        .height('100%')
    }
  }
}
```

**Key Rules**:
- Use `Column/Row/Stack/Flex` (never div/flexbox)
- Wrap `ForEach` output in a container (Row/Column) when applying styles
- Use `@State` for local state, `@StorageLink` for global state
- File naming: `PascalCase.ets`
- Exports: `export { ClassName }` (no default exports)

### Common Pitfalls

**HarmonyOS 开发规范**:
- **导出**: `export { ClassName }` (禁止 export default)
- **布局**: `Column/Row/Stack/Flex` (禁止 div)
- **滚动**: `onDidScroll` (onScroll 已废弃)
- **组件命名**: PascalCase
- **文件命名**: PascalCase.ets
- Use `@State` for local state, `@StorageLink` for global state
- Wrap `ForEach` output in a container (Row/Column) when applying stylesall @State variables |

---

## Map & Location Integration

**Required Permissions** (`entry/src/main/module.json5`):
```json5
{
  "requestPermissions": [
    {
      "name": "ohos.permission.APPROXIMATELY_LOCATION",
      "reason": "$string:location_reason",
      "usedScene": { "abilities": ["EntryAbility"], "when": "inuse" }
    },
    {
      "name": "ohos.permission.LOCATION"
    }
  ]
}
```

**Map Kit Setup**:
```typescript
import { mapCommon, Map } from '@kit.MapKit';

// Initialize API key
mapCommon.setApiKey('YOUR_API_KEY');

// Use MarkerCluster for performance with 100+ markers
Map() {
  MarkerCluster({
    markers: this.toiletMarkers,
    clusterRadius: 60,
    minClusterSize: 3
  })
}
```

**Location Service**:
```typescript
import { geoLocationManager } from '@kit.LocationKit';

// Request single location
geoLocationManager.getCurrentLocation(callback)
```

---

## Build & Testing Workflow

**AI agents CANNOT run builds** - user must execute in DevEco Studio:

1. **Install dependencies**: `ohpm install`
2. **Build**: Build → Build Hap(s)/APP(s)
3. **Run**: Click run button or Shift+F10
4. **Clean**: Build → Clean Project

**Agent Responsibilities**:
- ✅ Modify code and remind user to rebuild
- ✅ Wait for user feedback (screenshots/logs)
- ❌ Never attempt `hvigorw` or similar commands

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

## Project Status (as of 2025-12-10)

**Phase 1 Priorities** (v0.1.0 - v0.3.0):
- [ ] Integrate HarmonyOS Map Kit
- [ ] Implement location tracking with LocationKit
- [ ] Display toilet markers on map
- [ ] Create bottom drawer with toilet list
- [ ] Add basic filtering (distance, type)

**Current State**: Project initialized, awaiting Map Kit integration

**External Dependencies**:
- Huawei Map API Key (required for map display)
- Toilet POI data source (TBD: scraping vs. self-built vs. partnerships)

---

## Examples from Codebase

**Entry Ability Pattern** (`EntryAbility.ets`):
```typescript
// Set color mode in onCreate
this.context.getApplicationContext()
  .setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);

// Load page in onWindowStageCreate
windowStage.loadContent('pages/Index', callback);
```

**Component Pattern** (`Index.ets`):
```typescript
@Entry
@Component
struct Index {
  @State message: string = 'Hello World'; // Default value required

  build() {
    RelativeContainer() {
      Text(this.message)
        .alignRules({ /* ... */ })
        .onClick(() => { this.message = 'Welcome'; })
    }
  }
}
```

---

**Note**: This is a HarmonyOS NEXT native project (not OpenHarmony). Cross-platform frameworks are not used.
