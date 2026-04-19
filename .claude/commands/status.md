---
description: 展示 workspace/ 下所有项目的阶段状态
---

读取 `workspace/` 下所有项目并输出状态表。

**数据源**：
- 首选 `workspace/<项目>/.state.json`
- 若不存在，按文件推断：
  - 有 `prototype/` → stage=prototype
  - 有 `dev-plan.md` → stage=plan
  - 有 `PRD.md` → stage=prd/design
  - 其他 → stage=unknown

**输出格式**（Markdown 表）：

| 项目 | 阶段 | 当前负责角色 | 最后更新 | 下一步建议 |
|------|------|-------------|---------|----------|

**下一步建议映射**：
- `prd` → `/handoff <项目> design` 进入 design-specialist
- `design` → `/plan <项目>`
- `plan` → `/build <项目>`（需用户确认计划后）
- `prototype` → `/handoff <项目> audit` 进入 prototype-auditor 末端审核
- `audit_quick` (passed) → 可交付验收；如需部署用 `/deploy <项目> <平台>`
- `audit_quick` (needs_fix) → `/handoff <项目> prototype` 回交 frontend-developer 修复
- `deployed` → 可启动下一迭代或 self-optimizer 复盘

若 workspace/ 为空，提示用户：请提供需求大纲，使用 `/prd <项目名> <大纲>` 启动。

**不需要**：写任何文件；纯查询。
