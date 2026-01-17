# 提交给华为的Bug报告

## 📧 Bug标题
**Sheet组件多个bindSheet链式调用时首次点击无响应**

---

## 🐛 一句话描述
Sheet组件在多个bindSheet链式调用时，首次点击无响应，需要先触发其他Sheet才能显示，疑似初始化顺序问题。

---

## 📝 详细描述（可选）
ProfilePage中使用3个bindSheet链式绑定不同对话框（时薪设置/考勤周期/主题设置），首次点击"时薪设置"或"考勤周期"无反应，必须先点击"主题设置"后再点击空白区域，其他两个Sheet才能逐个显示。已尝试aboutToAppear预初始化（100ms延迟）和点击事件延迟（50ms），问题依然存在，疑似Sheet组件实例化顺序与ArkUI渲染机制冲突。

---

## 🔄 复现步骤
1. 运行Demo项目，切换到"个人中心"Tab（最右侧图标）
2. 点击"时薪设置" → ❌ 无响应，Sheet不显示
3. 点击"考勤周期" → ❌ 无响应，Sheet不显示  
4. 点击"主题设置" → ✅ Sheet正常显示
5. 关闭主题设置对话框
6. 再次点击"时薪设置" → ✅ 此时Sheet可以正常显示

---

## ✅ 期望行为
首次点击任何设置项时，对应的Sheet对话框应该立即显示，无需先触发其他Sheet。

---

## 💻 环境信息
- **DevEco Studio版本**: 6.0.1 Beta1
- **HarmonyOS SDK版本**: API 21 Beta1 (6.0.0.47)
- **项目类型**: HarmonyOS NEXT (runtimeOS: "HarmonyOS")
- **测试设备**: 真机测试
- **编程语言**: ArkTS

---

## 📎 附件
- **Demo项目**: `TimeTracker1_SheetBug_MinDemo.zip` (2.13 MB)
- **关键代码文件**: `entry/src/main/ets/pages/ProfilePage.ets` (第143-178行)
- **详细说明**: 见Demo项目根目录 `BUG_REPORT.md`

---

## 🔧 已尝试的解决方案（均无效）

### 方案一：aboutToAppear预初始化
```typescript
aboutToAppear() {
  setTimeout(() => {
    this.showHourlyWageDialog = false;
    this.showWorkCycleDialog = false;
    this.showThemeDialog = false;
  }, 100);
}
```

### 方案二：点击事件添加延迟
```typescript
private onHourlyWageClick(): void {
  setTimeout(() => {
    this.showHourlyWageDialog = true;
  }, 50);
}
```

---

## 🎯 关键代码片段

### Sheet绑定（3个链式bindSheet）
```typescript
Column() {
  // ...页面内容
}
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

### 状态变量定义
```typescript
@State showHourlyWageDialog: boolean = false;
@State showWorkCycleDialog: boolean = false;
@State showThemeDialog: boolean = false;
```

---

## 💭 疑似原因分析
- 多个bindSheet链式调用时，Sheet组件实例化顺序可能不确定
- 第三个Sheet（主题设置）被优先初始化，前两个Sheet延迟初始化
- 首次点击时，前两个Sheet尚未完成DOM构建，状态更新无效
- 触发第三个Sheet后，引发全局渲染更新，其他Sheet才完成初始化

---

## 📞 联系方式
如需更多信息或协助复现，请联系：[你的邮箱/用户名]
