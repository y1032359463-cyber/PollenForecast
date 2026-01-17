5肉tttttttttttttttttttttttttttt4# DaotimeleM (到时间了吗) 项目文档

> **作用范围**: DaotimeleM 项目  
> **最后更新**: 2025-12-11  
> **AI 维护者**: GitHub Copilot

---

## 🎯 项目概述

**项目名称**: 到时间了吗 (DaotimeleM)  
**应用ID**: 待定  
**SDK版本**: HarmonyOS 6.0.0 (API 20)  
**开发状态**: 初始实现 - 页面框架已完成，核心逻辑待开发  
**优先级**: P1 - 新项目规划中

**目标用户**: 小生意经营者（地摊/桌球室/棋牌室）+ 消费者  
**核心价值**: 纯计时工具 + 固定收款码展示（极简主义设计）

### 设计理念
- **极简主义**: "越简单越好" - 用户明确要求
- **纯计时工具**: 主要功能是倒计时，计费仅供参考
- **固定收款码**: 不需要动态生成金额，用户上传固定图片
- **双端模式**: 老板端（现场计时）+ 消费者端（自助租赁）

---

## 📂 项目结构速查

```
DaotimeleM/
├── .github/
│   └── copilot-instructions.md    # AI 编码指令
├── .claude/
│   └── CLAUDE.md                  # 本文件
├── figma/
│   ├── 页面设计.md                 # 完整的 9 个页面规格说明
│   └── 日志.md                     # CodeGenie 技术方案汇总
├── entry/src/main/
│   ├── ets/
│   │   ├── entryability/
│   │   │   └── EntryAbility.ets
│   │   └── pages/
│   │       ├── Index.ets                     # 身份选择页 ✅
│   │       ├── merchant/
│   │       │   ├── MerchantHome.ets         # 老板端主页 ✅
│   │       │   ├── BusinessManage.ets       # 业务管理页 ✅
│   │       │   ├── QRCodePage.ets           # 收款码展示 ✅
│   │       │   ├── QRCodeSettings.ets       # 收款码设置 ✅
│   │       │   └── HistoryPage.ets          # 历史记录（占位）
│   │       └── consumer/
│   │           ├── ConsumerHome.ets         # 消费者主页（占位）
│   │           ├── BusinessTypeSelect.ets   # 业务类型选择（占位）
│   │           ├── ResourceList.ets         # 资源列表（占位）
│   │           └── RentalDetail.ets         # 租赁详情（占位）
│   └── resources/
│       └── base/
│           ├── profile/
│           │   └── main_pages.json          # 路由配置 ✅
│           └── rawfile/
│               └── qrcode/                   # 收款码图片（待上传）
├── build-profile.json5
└── oh-package.json5
```

---

## 🎨 核心功能与页面

### 1. 身份选择页 (`pages/Index.ets`) ✅
**状态**: 已完成  
**功能**: 
- 两个圆形按钮：老板 / 消费者
- 呼吸动效（scale 1→1.05 + opacity 1→0.85，2秒循环）
- 点击跳转到对应端

**关键代码**:
```typescript
setInterval(() => {
  animateTo({ duration: 2000, curve: Curve.EaseInOut }, () => {
    this.scaleValue1 = this.scaleValue1 === 1 ? 1.05 : 1;
  });
}, 2000);
```

### 2. 老板端主页 (`merchant/MerchantHome.ets`) ✅
**状态**: 已完成框架  
**布局**: 
- 左侧固定栏：80px 宽，永久显示 4 个业务类型（🎱桌球/🏪地摊/🎴棋牌/📦通用）
- 右侧主内容区：业务卡片（Grid 2列布局）
- 顶部显示今日收入

**交互逻辑**:
- 点击左侧图标 → 跳转业务管理页
- 已添加的业务显示 ✓ 标记
- 最多添加 4 个业务类型

**待实现**:
- [ ] 从 Preferences 加载已添加业务
- [ ] 实时同步倒计时显示
- [ ] 今日收入统计逻辑

### 3. 业务管理页 (`merchant/BusinessManage.ets`) ✅
**状态**: 已完成框架  
**功能**:
- 资源列表：使用中 / 空闲 分组显示
- 使用中资源显示：⏱ 倒计时 + 参考费用 + [查看收款码]
- 空闲资源：点击弹出时间选择（1h/2h/3h/自定义）

**待实现**:
- [ ] TaskPool 倒计时任务启动
- [ ] Emitter 事件监听实时更新
- [ ] 费用计算逻辑（参考值）
- [ ] 从 Preferences 加载资源列表
- [ ] [+新增] 功能（添加资源）

### 4. 收款码页面 (`merchant/QRCodePage.ets`) ✅
**状态**: 已完成框架  
**设计要求**: **纯收款码** - 只显示两个二维码，无其他元素

**布局**:
```
┌────────────────┐
│ 微信支付 ⚙️   │ 上半屏绿色 #09BB07
│   [QR Code]    │
├────────────────┤
│ 支付宝         │ 下半屏蓝色 #1677FF
│   [QR Code]    │
└────────────────┘
```

**待实现**:
- [ ] 从沙箱加载收款码图片 (`context.filesDir + "/qrcode/wechat.png"`)
- [ ] 首次使用引导（未上传时显示 [+] 提示）
- [ ] 长按更换收款码

### 5. 收款码设置页 (`merchant/QRCodeSettings.ets`) ✅
**状态**: 已完成框架  
**功能**:
- 微信/支付宝收款码分别管理
- [更换图片] → 打开相册选择器
- [删除] → 清除已上传的收款码
- 使用提示卡片（1024x1024推荐、确保二维码完整等）

**待实现**:
- [ ] 集成相册选择器 (`@ohos.file.picker.PhotoViewPicker`)
- [ ] 图片保存到沙箱逻辑
- [ ] 图片裁剪/压缩（确保尺寸合理）
- [ ] 二维码区域检测（防止遮挡）

### 6. 消费者端页面（占位）📋
**状态**: 待实现  
**计划页面**:
- ConsumerHome: 我的租赁列表（显示使用中的资源）
- BusinessTypeSelect: 业务类型选择（图形化界面）
- ResourceList: 可用资源列表（从老板端同步）
- RentalDetail: 租赁详情（实时计时 + 到期提醒 + [归还]按钮）

---

## 🔧 技术方案（来自 CodeGenie）

### 1. 收款码存储与展示
**存储位置**: 应用沙箱目录  
```typescript
const context = getContext(this);
const wechatPath = context.filesDir + "/qrcode/wechat.png";
const alipayPath = context.filesDir + "/qrcode/alipay.png";
```

**展示优化**:
```typescript
Image(`file://${qrcodePath}`)
  .width('80%')
  .aspectRatio(1)  // 强制 1:1 比例
  .objectFit(ImageFit.Contain)
  .interpolation(ImageInterpolation.High)  // 高质量缩放
```

**图片要求**:
- 分辨率: 建议 1024x1024 像素
- 格式: PNG（无损压缩）

### 2. 倒计时实现（TaskPool + Emitter）
**方案**: 多实例并发，支持 10+ 倒计时同时运行

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

// 在组件中监听
emitter.on({ eventId: 1001 }, (data) => {
  this.countdown = data.remaining;
});
```

**性能指标**:
- 10 个并发倒计时 CPU 占用率 < 15%
- 后台运行 8 小时误差 < ±2 秒
- 卡片刷新帧率稳定 60fps

**时间校准**:
```typescript
let baseTime = new Date().getTime();
function getAccurateTime() {
  const offset = new Date().getTime() - baseTime;
  return Math.floor(offset / 1000);
}
```

### 3. 固定左侧分类栏布局
**方案**: 使用 `Row + Column`（非 SideBarContainer）

```typescript
Row() {
  // 左侧固定栏 - 80px 永久显示
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
  Column() { /* 业务卡片 */ }
    .layoutWeight(1)
}
```

**响应式适配**: 暂不需要（仅支持手机竖屏）

### 4. 数据持久化
**Preferences（业务配置）**:
```typescript
import preferences from '@ohos.data.preferences';

// 保存
const config = { 
  businesses: ['pool', 'chess'], 
  qrUploaded: true 
};
await preferences.put('user_config', JSON.stringify(config));

// 读取
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

**适用场景对比**:
| 存储方式 | 适用场景 | 性能 |
|---------|---------|------|
| Preferences | 轻量配置（业务列表、开关状态） | μs级 |
| SQLite | 历史记录（多字段、需查询） | ms级 |

---

## 📋 项目进展追踪

### 最近更新

**2025-12-11** - 项目初始化与页面框架搭建
- ✅ 创建项目结构和路由配置
- ✅ 实现身份选择页（呼吸动效按钮）
- ✅ 实现老板端主页（固定左栏 + 业务卡片布局）
- ✅ 实现业务管理页（资源列表 + 倒计时选择弹窗）
- ✅ 实现收款码展示页（绿微信上 + 蓝支付宝下）
- ✅ 实现收款码设置页（上传管理 + 使用提示）
- ✅ 创建消费者端占位页面
- ✅ 创建 `.github/copilot-instructions.md` AI 编码指令
- ✅ 创建 `.claude/CLAUDE.md` 项目文档

### 已完成功能 ✅
- [x] 路由配置（10 个页面）
- [x] 身份选择页 UI
- [x] 老板端主页框架
- [x] 业务管理页框架
- [x] 收款码页面框架
- [x] 收款码设置页框架
- [x] 消费者端页面占位

### 进行中 🔄
- 无

### 待办事项 📋

**优先级 P0（核心功能）**:
1. [ ] 实现 TaskPool 倒计时逻辑
2. [ ] 实现 Emitter 事件通知系统
3. [ ] 集成 Preferences 业务配置存储
4. [ ] 集成相册选择器（收款码上传）
5. [ ] 实现收款码图片沙箱存储逻辑

**优先级 P1（完善功能）**:
6. [ ] 构建 SQLite 历史记录数据库
7. [ ] 实现费用计算逻辑（参考值）
8. [ ] 实现今日收入统计
9. [ ] 添加资源管理功能（新增/删除）
10. [ ] 实现时间自定义输入

**优先级 P2（消费者端）**:
11. [ ] 实现消费者端主页
12. [ ] 实现业务类型选择页
13. [ ] 实现资源列表页
14. [ ] 实现租赁详情页
15. [ ] 实现到期提醒功能

---

## 🐛 已知问题

### 当前无已知问题
项目刚初始化，页面框架已搭建完成，待用户在 DevEco Studio 构建测试。

---

## 📚 关键参考文档

1. **设计文档**: `figma/页面设计.md`
   - 完整的 9 个页面设计规格
   - 包含 ASCII 界面示意图
   - 详细的交互流程说明

2. **技术方案**: `figma/日志.md`
   - CodeGenie 提供的技术实现方案
   - 收款码存储、倒计时实现、布局方案、数据持久化

3. **AI 指令**: `.github/copilot-instructions.md`
   - GitHub Copilot 编码规范
   - 项目特有模式和代码示例
   - 常见错误陷阱清单

4. **工厂级文档**: `../../../.claude/CLAUDE.md`
   - HarmonyOS 应用工厂项目总览
   - 全局开发规范和工作流程

---

## 🚀 下一步行动

### 立即执行
1. **用户在 DevEco Studio 构建测试**
   - 验证页面路由是否正常
   - 检查呼吸动效是否流畅
   - 确认固定左栏布局是否符合预期

2. **根据构建反馈修复问题**
   - 等待用户提供截图或错误日志
   - 分析并修复编译错误
   - 优化UI显示效果

### 后续计划
1. **实现核心功能**（按优先级 P0 顺序）
   - TaskPool 倒计时
   - Emitter 事件通知
   - Preferences 配置存储
   - 相册选择器集成

2. **用户验收与迭代**
   - 每完成一个功能模块，请用户测试验收
   - 根据反馈调整和优化
   - 逐步完善消费者端功能

---

**注意**: 
- AI 代理禁止执行 `hvigorw` 构建命令，必须由用户在 IDE 操作
- 代码修改前必须先读取 `figma/页面设计.md` 和本文档
- 重大变动前必须备份文件（使用 PowerShell 脚本）
- 完成任务后必须更新本文档的"最近更新"章节
