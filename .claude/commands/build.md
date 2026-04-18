---
description: 进入 frontend-developer 生成高保真原型
argument-hint: [项目名]
---

切换到 **frontend-developer** 角色（依据 skills/frontend-developer/SKILL.md + rules/frontend.md）。

输入参数：$ARGUMENTS

**前置硬性检查**（任一不通过即停止）：

1. `workspace/<项目>/PRD.md` 存在且 1-9 章齐全（若缺章节，提示 `/handoff <项目> design` 或 `/prd` 补齐）
2. `workspace/<项目>/dev-plan.md` 存在
3. `.state.json.stage` 在 `plan` 或 `prototype`（说明用户已确认计划）

**执行流程**：

1. 更新 `.state.json`：`stage=prototype`, `owner_role=frontend-developer`, `last_updated=<now>`
2. 在 `workspace/<项目>/prototype/` 下按 rules/frontend.md 规范生成高保真原型：
   - 默认技术栈：Vite + React + TypeScript
   - 按 rules/prd.md 视觉色板实现主题
   - 若涉及 3D 场景，启用 Three.js 支援
3. 生成后输出运行命令（如 `cd workspace/<项目>/prototype && npm install && npm run dev`）
4. 提示用户使用 `/handoff <项目> review` 进入 release-engineer 审查

**大量文件警告**：若本次将创建 >5 个文件（按 rules/workflow.md），先向用户列出目录树并请求确认。

**不得**：改动 `rules/`、`skills/`、根 `CLAUDE.md`（hooks 层已硬阻止）。
