# 开发规范

## 分支策略

### 主要分支
- **main** - 生产分支,仅用于发布版本,受保护
- **develop** - 开发主分支,所有功能开发完成后合并到此分支

### 功能分支命名规范
```
feature/模块名-功能描述
例如:
- feature/config-system          # 配置系统
- feature/theme-manager           # 主题管理
- feature/data-analytics          # 数据统计
- feature/achievement-system      # 成就系统
```

### 修复分支命名规范
```
fix/问题描述
例如:
- fix/database-migration-error
- fix/theme-switching-crash
```

### 发布分支命名规范
```
release/版本号
例如:
- release/v1.0.0
- release/v1.1.0
```

## 工作流程

### 1. 开发新功能
```powershell
# 从develop创建功能分支
git checkout develop
git pull origin develop
git checkout -b feature/功能名称

# 开发并提交
git add .
git commit -m "feat: 功能描述"

# 推送到远程
git push origin feature/功能名称

# 在GitHub创建Pull Request合并到develop
```

### 2. 修复Bug
```powershell
# 从develop创建修复分支
git checkout develop
git checkout -b fix/问题描述

# 修复并提交
git add .
git commit -m "fix: 问题描述"

# 推送并创建PR
git push origin fix/问题描述
```

### 3. 发布版本
```powershell
# 从develop创建发布分支
git checkout develop
git checkout -b release/v1.0.0

# 测试并修复问题后合并到main
git checkout main
git merge release/v1.0.0
git tag v1.0.0
git push origin main --tags

# 同时合并回develop
git checkout develop
git merge release/v1.0.0
```

## 提交信息规范

使用[约定式提交](https://www.conventionalcommits.org/zh-hans/)格式:

```
<类型>(<范围>): <描述>

[可选的正文]

[可选的脚注]
```

### 提交类型
- **feat**: 新功能
- **fix**: 修复bug
- **docs**: 文档变更
- **style**: 代码格式(不影响代码运行)
- **refactor**: 重构(既不是新功能也不是修复bug)
- **perf**: 性能优化
- **test**: 测试相关
- **chore**: 构建过程或辅助工具变更
- **revert**: 回滚之前的提交

### 示例
```
feat(theme): 添加深色主题支持

实现了深色主题的配置和切换功能,包括:
- ThemeManager深色模式API
- 5种深色主题预设
- 自动跟随系统主题

Closes #12
```

## 自动备份

使用项目根目录的`backup.ps1`脚本快速备份:

```powershell
# 使用默认提交信息
.\backup.ps1

# 使用自定义提交信息
.\backup.ps1 "feat: 完成配置系统开发"
```

## 代码审查清单

提交PR前请确保:
- [ ] 代码符合ArkTS编码规范
- [ ] 所有新功能都有注释说明
- [ ] 配置文件使用JSON格式且有schema验证
- [ ] 组件使用`@Reusable`装饰器优化性能
- [ ] 大列表使用`LazyForEach`而非`ForEach`
- [ ] 颜色/尺寸等常量已提取到配置文件
- [ ] 数据库操作有错误处理
- [ ] 没有硬编码的文本(支持多语言)

## 开发环境要求

- **DevEco Studio**: 5.0 Release及以上
- **HarmonyOS SDK**: 5.0 Release及以上
- **Node.js**: 16.x及以上
- **Git**: 2.30及以上
- **Clash Verge**: 代理端口7897(用于GitHub访问)

## 获取帮助

遇到问题时:
1. 查看`.claude/CLAUDE.md`了解项目整体架构
2. 参考`01_技术改造详细方案.md`了解具体实现
3. 查看Figma设计文件对照UI实现
4. 在GitHub Issues提交问题
