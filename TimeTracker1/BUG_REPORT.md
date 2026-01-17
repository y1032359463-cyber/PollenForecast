# Sheet组件首次点击无响应Bug

## 🐛 问题描述

**ProfilePage中使用3个bindSheet链式绑定不同对话框，首次点击前两个Sheet无反应，必须先点击第三个Sheet后其他才能显示。**

## 📍 复现步骤

1. 运行项目，切换到"个人中心"Tab（最右侧）
2. 点击"时薪设置" → ❌ 无响应
3. 点击"考勤周期" → ❌ 无响应  
4. 点击"主题设置" → ✅ 正常显示Sheet
5. 关闭对话框，再点击"时薪设置" → ✅ 此时可以显示

## 🔑 关键代码位置

**文件**: `entry/src/main/ets/pages/ProfilePage.ets`

### Sheet绑定代码（第143-157行）
```typescript
.bindSheet($$this.showHourlyWageDialog, this.HourlyWageDialog(), {
  height: 300,
  backgroundColor: Color.White
})
.bindSheet($$this.showWorkCycleDialog, this.WorkCycleDialog(), {
  height: 300,
  backgroundColor: Color.White
})
.bindSheet($$this.showThemeDialog, this.ThemeDialog(), {
  height: 300,
  backgroundColor: Color.White
})
```

### 点击事件处理（第160-178行）
```typescript
private onHourlyWageClick(): void {
  console.info('[ProfilePage] 点击时薪设置');
  setTimeout(() => {
    console.info('[ProfilePage] 打开时薪设置对话框');
    this.showHourlyWageDialog = true;
  }, 50);
}
// 其他两个类似...
```

### 已尝试的解决方案

#### 方案一：aboutToAppear预初始化（无效）
```typescript
aboutToAppear() {
  setTimeout(() => {
    this.showHourlyWageDialog = false;
    this.showWorkCycleDialog = false;
    this.showThemeDialog = false;
  }, 100);
}
```

#### 方案三：点击事件延迟（无效）
```typescript
setTimeout(() => {
  this.showHourlyWageDialog = true;
}, 50);
```

## 🔍 疑似原因

Sheet组件实例化顺序与ArkUI渲染机制存在冲突：
- 多个bindSheet链式调用时，后面的Sheet可能优先初始化
- 首次点击时，前面的Sheet尚未完成实例化
- 需要触发一次渲染更新后，所有Sheet才能正常工作

## 💻 环境信息

- **DevEco Studio**: 6.0.1 Beta1
- **HarmonyOS SDK**: API 21 Beta1 (6.0.0.47)
- **项目类型**: HarmonyOS NEXT (runtimeOS: "HarmonyOS")
- **测试设备**: 真机测试

## 📦 Demo说明

本项目为最小可复现Demo，已移除：
- 文档文件（figma/、.claude/等）
- 构建缓存（build/、oh_modules/）
- IDE配置（.vscode/、.idea/）

保留完整功能代码，可直接在DevEco Studio中打开构建测试。

## 🙏 期望结果

首次点击任何设置项时，对应的Sheet对话框应该立即显示，无需先触发其他Sheet。
