# 到时间了吗 (DaotimeleM) - AI Coding Agent Instructions

> 本文件定义 GitHub Copilot 在此项目中的行为规范

计时计费工具，适用于小生意经营者（地摊/桌球室/棋牌室）+ 消费者双端模式

## 项目架构

**技术栈**: HarmonyOS NEXT (API 20, SDK 6.0.0) + ArkTS + ArkUI  
**构建工具**: hvigorw (用户在 DevEco Studio 执行)  
**入口**: `entry/src/main/ets/entryability/EntryAbility.ets` → 加载 `pages/Index.ets`

```
entry/src/main/ets/
├── pages/
│   ├── Index.ets                    # 身份选择页（老板/消费者）
│   ├── merchant/                    # 老板端
│   │   ├── MerchantHome.ets        # 主页（固定左栏+业务卡片）
│   │   ├── BusinessManage.ets      # 业务管理（资源列表+倒计时）
│   │   ├── QRCodePage.ets          # 收款码展示（纯双码）
│   │   └── QRCodeSettings.ets      # 收款码管理（上传/更换）
│   └── consumer/                    # 消费者端
│       ├── ConsumerHome.ets        # 主页（我的租赁）
│       ├── BusinessTypeSelect.ets  # 业务类型选择
│       ├── ResourceList.ets        # 资源列表
│       └── RentalDetail.ets        # 租赁详情
├── models/                          # 数据模型（待创建）
├── utils/                           # 工具函数（待创建）
└── services/                        # 业务逻辑（待创建）
```

**核心设计理念**:
- **极简主义**: "越简单越好" - 用户明确要求
- **固定左栏**: 80px 永久显示，非侧边栏（用户强调"一直在的"）
- **纯收款码**: 只显示两个二维码，无其他元素
- **双端模式**: 老板端（现场计时）+ 消费者端（自助租赁）

---

## 🔴 关键规则

### 代码修改前必读
**必须先读取设计文档** 避免理解偏差：
```bash
# 总是先检查：
- figma/页面设计.md       # 完整的 9 个页面规格说明
- figma/日志.md            # CodeGenie 的技术方案
- .claude/CLAUDE.md        # 项目状态和进展
```

### 常见错误陷阱
| ❌ 错误 | ✅ 正确 | 原因 |
|---------|---------|------|
| 左侧使用侧边栏组件 | 使用固定 80px Column | 用户要求"永久显示" |
| 收款码页面加倒计时 | 只显示两个二维码 | 用户明确"纯收款码" |
| 业务类型超过4个 | 最多4个 | 用户限制 |
| 动态生成收款码 | 固定图片 | 不需要金额生成 |
| 使用 router.back() | 使用具体路由跳转 | API 20 最佳实践 |

### 代码修改原则
- ✅ **理解全局再修改** - 先读完整个相关代码块
- ✅ **一次只改一个问题** - 避免连锁错误
- ✅ 批量操作使用 `multi_replace_string_in_file`
- ❌ **禁止重复修复已解决的问题** - 先确认问题是否真的存在
- ❌ 禁止凭假设修改 - 先用截图/日志确认实际状态
- ❌ **禁止删除重建文件** - 必须使用编辑工具保留文件历史

### 🔴 重大代码变动前必须备份
**需要备份的场景**:
- 重构倒计时逻辑（TaskPool/Emitter）
- 修改核心业务流程（业务添加、资源管理）
- 优化性能涉及算法变更
- 任何可能导致功能失效的修改

**备份流程**:
```powershell
$backupName = "文件名.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item "原文件路径" "备份路径/$backupName"
```

### 完成任务后
1. 更新 `.claude/CLAUDE.md` → "最近更新"
2. 询问用户当前北京时间并更新时间戳
3. 使用中文 Todo 列表（方便用户查看）

---

## 编码规范

### ArkTS 语法规范

ArkTS **不是 TypeScript** - 有严格限制：

```typescript
// ❌ 静态方法不能用 this
static calculate(): Result { return this.helper(); }

// ✅ 使用类名
static calculate(): Result { return ClassName.helper(); }

// ❌ 禁止使用 TypeScript 的 is 类型守卫
function isUser(obj: Object): obj is User { ... }

// ✅ 使用简单的字段检查
if (obj !== null && obj.name !== undefined && typeof obj.name === 'string')

// ❌ 禁止对象字面量类型
comfortDistribution: {
  veryComfortable: number;
  comfortable: number;
}

// ✅ 定义独立 interface
export interface ComfortDistribution {
  veryComfortable: number;
  comfortable: number;
}
```

**ArkTS 严格限制**:
- ❌ **禁止类型守卫 `is`**: ArkTS 不支持 `obj is Type` 语法
- ❌ **禁止 `any` 和 `unknown`**: 必须使用明确类型
- ❌ **禁止对象字面量类型**: 嵌套对象需定义独立 interface
- ✅ **使用泛型**: `function request<T>(): Promise<T>`
- ✅ **可选字段防御**: `interface Data { code?: string; value?: number }`

---

## UI 组件规范

### 组件结构
```typescript
@Entry
@Component
struct MerchantHome {
  @State businessList: BusinessCard[] = [];
  @State todayIncome: number = 0;

  build() {
    Row() {
      // 左侧固定栏 - 80px 永久显示
      Column() { /* 业务类型 */ }
        .width(80)
        .backgroundColor('#FAFAFA')
      
      // 右侧主内容区
      Column() { /* 业务卡片 */ }
        .layoutWeight(1)
    }
  }
}
```

**关键规则**:
- 使用 `Column/Row/Stack/Flex`（禁止 div）
- `ForEach` 输出包裹在容器中应用样式
- `@State` 用于本地状态，`@StorageLink` 用于全局状态
- 文件命名：PascalCase.ets
- 导出：`export { ClassName }`（禁止 default export）

### HarmonyOS 开发规范
- **导出**: `export { ClassName }` (禁止 export default)
- **布局**: `Column/Row/Stack/Flex` (禁止 div)
- **滚动**: `onDidScroll` (onScroll 已废弃)
- **导航**: `router.pushUrl()` / `router.replaceNamedRoute()`
- **组件命名**: PascalCase
- **图标配置**: `"icon": "$media:layered_image"` (AppGallery 要求)
- **依赖管理**: `@ohos.*` 和 `@kit.*` 是 SDK 内置模块，无需在 oh-package.json5 声明

### 权限配置
**SQLite 数据库权限**（在 `module.json5` 中配置）:
```json
"requestPermissions": [
  {
    "name": "ohos.permission.DISTRIBUTED_DATASYNC",
    "reason": "$string:permission_datasync_reason",
    "usedScene": {
      "abilities": ["EntryAbility"],
      "when": "inuse"
    }
  }
]
```

---

## 项目特有模式

### 1. 呼吸动效按钮（身份选择）
```typescript
@Entry
@Component
struct Index {
  @State scaleValue1: number = 1;
  @State opacityValue1: number = 1;

  aboutToAppear() {
    setInterval(() => {
      animateTo({
        duration: 2000,
        curve: Curve.EaseInOut,
        iterations: 1,
        playMode: PlayMode.Alternate
      }, () => {
        this.scaleValue1 = this.scaleValue1 === 1 ? 1.05 : 1;
        this.opacityValue1 = this.opacityValue1 === 1 ? 0.85 : 1;
      });
    }, 2000);
  }
}
```

### 2. 固定左侧分类栏布局
```typescript
Row() {
  // 左侧固定栏 - 永久显示，80px 宽度
  Column() {
    ForEach(businessTypes, (item) => {
      Column() {
        Text(item.icon).fontSize(32)
        Text(item.name).fontSize(12)
        if (isAdded(item)) Text('✓').fontColor('#4CAF50')
      }
      .onClick(() => onBusinessTypeClick(item))
    })
  }
  .width(80)
  .backgroundColor('#FAFAFA')
  
  // 右侧主内容区 - 自适应宽度
  Column() { /* 业务卡片或管理页面 */ }
    .layoutWeight(1)
}
```

### 3. 纯收款码页面（关键设计）
```typescript
// 用户明确要求：NO 倒计时，NO 按钮，ONLY 二维码
Column() {
  // 微信 - 绿色背景，上半屏
  Stack() {
    Column().backgroundColor('#09BB07').layoutWeight(1)
    Column() {
      Text('微信支付').fontSize(18).fontColor('#FFF')
      Image($rawfile('qrcode/wechat.png'))
        .width('80%')
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)
    }.justifyContent(FlexAlign.Center)
  }.layoutWeight(1)
  
  // 支付宝 - 蓝色背景，下半屏
  Stack() {
    Column().backgroundColor('#1677FF').layoutWeight(1)
    Column() {
      Text('支付宝').fontSize(18).fontColor('#FFF')
      Image($rawfile('qrcode/alipay.png'))
        .width('80%')
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)
    }.justifyContent(FlexAlign.Center)
  }.layoutWeight(1)
}
```

### 4. 倒计时实现（TaskPool + Emitter）
```typescript
import { taskpool, emitter } from '@kit.ArkTS';

@Concurrent
async function countdownTask(seconds: number, eventId: number) {
  let remaining = seconds;
  while (remaining > 0) {
    await new Promise(resolve => setTimeout(resolve, 1000));
    remaining--;
    emitter.emit({ eventId }, { remaining });
  }
}

// 启动倒计时
const task = new taskpool.Task(countdownTask, 3600, 1001);
taskpool.execute(task);

// 监听更新
emitter.on({ eventId: 1001 }, (data) => {
  this.countdown = data.remaining;
});
```

### 5. 数据持久化模式

**Preferences（轻量配置）**:
```typescript
import preferences from '@ohos.data.preferences';

// 保存业务配置
const config = { businesses: ['pool', 'chess'], qrUploaded: true };
await preferences.put('user_config', JSON.stringify(config));

// 读取配置
const data = await preferences.get('user_config', '{}');
const config = JSON.parse(data as string);
```

**SQLite（历史记录）**:
```typescript
const SQL_CREATE_TABLE = `
  CREATE TABLE IF NOT EXISTS history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    business_type TEXT NOT NULL,
    resource_name TEXT,
    start_time INTEGER,
    end_time INTEGER,
    duration INTEGER,
    fee REAL
  )`;
```

**收款码图片（沙箱存储）**:
```typescript
// 保存到沙箱
const context = getContext(this);
const path = context.filesDir + "/qrcode/wechat.png";

// 加载显示
Image(`file://${context.filesDir}/qrcode/wechat.png`)
  .width('80%')
  .aspectRatio(1)
  .objectFit(ImageFit.Contain)
  .interpolation(ImageInterpolation.High)
```

### 6. 相册选择器（PhotoViewPicker）

**正确导入方式**（API 20 推荐）:
```typescript
import { PhotoViewPicker, PhotoSelectOptions, PhotoViewMIMETypes } from '@kit.ArkUI';

async onSelectImage() {
  try {
    const photoSelectOptions = new PhotoSelectOptions();
    photoSelectOptions.MIMEType = PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = 1;
    
    const photoPicker = new PhotoViewPicker();
    const result = await photoPicker.select(photoSelectOptions);
    
    // result.photoUris[0] 是选中的图片 URI
    const selectedUri = result.photoUris[0];
    
    // TODO: 复制到沙箱目录
    const context = getContext(this);
    const destPath = context.filesDir + '/qrcode/wechat.png';
  } catch (err) {
    console.error('选择图片失败:', err);
  }
}
```

**⚠️ 注意**: 旧版 `import picker from '@ohos.file.picker'` 已不推荐使用。

---

## 构建与测试流程

**AI 代理禁止执行构建** - 用户必须在 DevEco Studio 操作：

1. **安装依赖**: `ohpm install`
2. **构建**: Build → Build Hap(s)/APP(s)
3. **运行**: 点击运行按钮或 Shift+F10
4. **清理**: Build → Clean Project

**代理职责**:
- ✅ 修改代码并提醒用户重新构建
- ✅ 等待用户反馈（截图/日志）
- ❌ 禁止尝试 `hvigorw` 或类似命令

---

## 项目状态 (截至 2025-12-11)

**当前阶段**: 初始实现 - 页面框架已完成，核心逻辑待开发

**已完成**:
- ✅ 身份选择页（呼吸动效按钮）
- ✅ 老板端主页（固定左栏+业务卡片）
- ✅ 业务管理页（资源列表+倒计时选择）
- ✅ 收款码页面（绿微信+蓝支付宝）
- ✅ 收款码设置页（上传管理+使用提示）
- ✅ 消费者端占位页面

**待实现（优先级）**:
1. TaskPool 倒计时逻辑 + Emitter 事件通知
2. Preferences 业务配置存储
3. 相册选择器集成（收款码上传）
4. SQLite 历史记录数据库
5. 消费者端完整功能

**外部依赖**:
- 无（纯本地应用，无网络请求）

---

## 代码库示例

**入口能力模式** (`EntryAbility.ets`):
```typescript
// onCreate 设置颜色模式
this.context.getApplicationContext()
  .setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);

// onWindowStageCreate 加载页面
windowStage.loadContent('pages/Index', callback);
```

**组件模式** (`Index.ets`):
```typescript
@Entry
@Component
struct Index {
  @State message: string = 'Hello World'; // 必须有默认值

  build() {
    Column() {
      Text(this.message)
        .onClick(() => { this.message = 'Welcome'; })
    }
  }
}
```

**路由导航**:
```typescript
// 页面跳转
router.pushUrl({
  url: 'pages/merchant/MerchantHome',
  params: { businessType: 'pool' }
});

// 获取参数
const params = router.getParams() as Record<string, string>;
this.businessType = params.businessType || '';
```

---

## 关键参考文件

- `figma/页面设计.md` - 完整的 9 个页面设计规格
- `figma/日志.md` - CodeGenie 技术方案汇总
- `.claude/CLAUDE.md` - 项目进展和状态追踪

---

**注意**: 这是 HarmonyOS NEXT 原生项目（非 OpenHarmony），不使用跨平台框架。
