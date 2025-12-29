# HarmonyOS 花粉浓度播报项目 - TRAE_CN IDE 设置指南

## 📖 项目概述

**花粉浓度播报** - 基于鸿蒙生态的智能花粉过敏管理平台，遵循严格的代码规范和AI协作指南。

## 🎯 目标

本指南将帮助您在 **TRAE_CN IDE** 中正确配置开发环境，确保：

1. 自动读取项目指令文件（`.claude/CLAUDE.md` 和 `.github/copilot-instructions.md`）
2. 严格遵循 HarmonyOS 开发 AI 协作指南中的代码规范
3. 实现自动化代码检查和规范验证

## 🛠️ TRAE_CN IDE 设置

### 1. 打开项目
- 在 TRAE_CN 中直接打开 `PollenForecast` 项目目录

### 2. 设置项目规则
- 点击左侧菜单栏 → `规则` → 项目规则
- 系统会自动读取 `trae_rules/project_rules.md` 文件中的规则
- TRAE_CN 会自动读取以下文件作为上下文：
  - `.github/copilot-instructions.md`：GitHub Copilot 行为规范
  - `.claude/CLAUDE.md`：项目指导文档和开发进度
  - `trae_rules/project_rules.md`：TRAE_CN 专属项目规则

### 3. 配置编辑器设置
- 点击左侧菜单栏 → `设置中心` → `编辑器设置`
- 启用 "自动格式化" 和 "保存时格式化" 选项
- 调整代码缩进和其他格式化选项以符合项目规范

### 4. 安装必要扩展（可选）
- 点击左侧菜单栏 → `扩展市场`
- 搜索并安装 `ESLint` 扩展（用于代码规范检查）
- 搜索并安装 `ArkTS` 扩展（用于 ArkTS 语法支持）
- 重启 TRAE_CN IDE 以应用扩展

## 📋 代码规范遵循流程

### 1. 自动读取项目指令

TRAE_CN 会自动读取以下文件，确保您的代码符合项目规范：

- `.github/copilot-instructions.md`：GitHub Copilot 行为规范
- `.claude/CLAUDE.md`：项目指导文档和开发进度
- `trae_rules/project_rules.md`：TRAE_CN 专属项目规则

### 2. 代码规范强制规则

请遵循以下代码规范编写代码：

- ✅ 使用 `export { xxx }` 而非 `export default`
- ✅ 确保组件使用 `@Component + @Entry` 装饰器
- ✅ 采用链式样式 `.width(100).height(50)` 而非对象式
- ✅ 使用 `Column/Row/Stack` 等 ArkUI 布局组件
- ✅ 组件命名使用 PascalCase
- ✅ 文件命名使用 PascalCase.ets

## 📁 配置文件说明

### 1. `PollenForecast.code-workspace`

VS Code/TRAE_CN 工作区配置文件，包含：
- 编辑器设置（缩进、格式化等）
- 文件排除规则
- 基本工作区配置

### 2. `code-linter.json5`

HarmonyOS 代码规范检查配置文件，用于项目级别的代码规范验证：
- 定义代码检查规则
- 设置文件匹配模式
- 配置忽略路径

### 3. `build-profile.json5`

项目构建配置文件，包含：
- 构建参数设置
- 模块配置
- 依赖管理

### 4. `oh-package.json5`

项目依赖配置文件，管理项目所需的第三方库和模块

### 5. `trae_rules/project_rules.md`

TRAE_CN 专属项目规则文件，包含：
- 代码规范要求
- 项目结构说明
- API 配置信息
- 开发流程指导

## 🚀 开发流程

1. **启动项目**：在 TRAE_CN 中打开项目
2. **自动读取指令**：TRAE_CN 会自动读取项目指令文件
3. **编写代码**：使用 AI 辅助功能编写符合规范的代码
4. **遵循规范**：参考 `trae_rules/project_rules.md` 中的代码规范
5. **更新文档**：完成开发后更新 `.claude/CLAUDE.md` 中的开发进度

## 🔍 常见问题

### Q1: TRAE_CN 无法读取项目规则文件怎么办？

**解决方法**：
1. 检查 `trae_rules/project_rules.md` 文件是否存在且内容完整
2. 检查 `.github/` 和 `.claude/` 目录是否存在
3. 重启 TRAE_CN IDE

### Q2: 如何查看当前项目的代码规范？

**解决方法**：
1. 点击左侧菜单栏 → `规则` → 项目规则
2. 查看 `trae_rules/project_rules.md` 文件中的内容
3. 或直接阅读 `.github/copilot-instructions.md` 和 `.claude/CLAUDE.md`

### Q3: 如何确保 AI 助手遵循项目规范？

**解决方法**：
1. 确保 `trae_rules/project_rules.md` 文件存在且完整
2. 确保 `.github/copilot-instructions.md` 文件存在且完整
3. TRAE_CN 会自动读取这些文件作为上下文

## 📞 技术支持

如果您在使用 TRAE_CN IDE 时遇到问题：

1. 查看 TRAE_CN 内置帮助文档
2. 参考项目中的 `.claude/CLAUDE.md` 文档
3. 在 `C:\HarmonyOS_App_Plans\.claude\当前问题.md` 中记录问题

## 📝 更新记录

- **2025-12-07**：创建 TRAE_CN IDE 设置指南
- **2025-12-06**：完成代码规范检查脚本
- **2025-12-05**：创建项目配置文件

---

**遵循规范，高效开发！** 🎉

请确保每次开发前都阅读此指南，确保您的代码符合项目要求。