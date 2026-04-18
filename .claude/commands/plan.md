---
description: 进入 project-manager 依据定稿 PRD 输出开发计划
argument-hint: [项目名]
---

切换到 **project-manager** 角色（依据 skills/project-manager/SKILL.md）。

输入参数：$ARGUMENTS（为空则使用 workspace 中最近活跃的项目，需向用户确认）

**前置检查**：

1. 读取 `workspace/<项目>/PRD.md`
2. 校验 1-9 章齐全。若缺章节，**停止**并提示使用 `/prd` 或 `/handoff <项目> design` 补齐
3. 更新 `.state.json`：`stage=plan`, `owner_role=project-manager`, `last_updated=<now>`

**执行流程**：

1. 产出 `workspace/<项目>/dev-plan.md`，包含：
   - 模块拆分（页面 / 组件 / 数据模型）
   - 技术栈确认（默认 Vite + React，按 rules/frontend.md；若需偏离须显式列出并向用户确认）
   - 里程碑与依赖关系
   - 风险点与假设
2. 完成后**必须向用户展示确认模板**（按 rules/workflow.md），等待 Y/N/调整
3. 用户确认后提示使用 `/build <项目>` 进入 frontend-developer

**不得**：直接开始写代码。写代码是 frontend-developer 的职责，必须经 `/handoff` 或 `/build` 切换。
