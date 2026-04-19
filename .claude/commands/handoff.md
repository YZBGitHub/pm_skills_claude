---
description: 阶段交接 — 更新 .state.json 并切换到下一角色
argument-hint: <项目名> <next-stage>
---

阶段交接协议。输入参数：$ARGUMENTS

**参数**：
- `<项目名>`：workspace 下的项目目录名
- `<next-stage>`：允许值 `prd | prd-review | design | plan | prototype | audit | deployed`

**Stage → 默认角色映射**：

| stage | owner_role |
|-------|-----------|
| prd | prd-specialist |
| prd-review | prd-reviewer |
| design | design-specialist |
| plan | project-manager |
| prototype | frontend-developer |
| audit | prototype-auditor |
| deployed | —（由 `/deploy` 命令负责，不绑角色） |

**标准阶段顺序**：`prd → prd-review ↺ prd → design → plan → prototype → audit → (可选) deployed`

`prd ↔ prd-review` 之间形成循环：评审有 Blocker/Major 时回到 prd 修订，连续 2 轮无 Blocker/Major 才能进入 design。
`audit → deployed` 不通过 `/handoff` 触发，由用户主动执行 `/deploy <项目> <平台>`。

**执行流程**：

1. 读取 `workspace/<项目名>/.state.json`，记录当前 stage
2. 若目标 stage 违反顺序（如 `plan → prototype` 跳过了 plan → review 直达 deployed），**必须向用户确认**是否允许跳过，写明原因
3. 按目标 stage 做前置校验：
   - 进入 `design`：PRD.md 第 1-6 章存在
   - 进入 `plan`：PRD.md 1-9 章齐全
   - 进入 `prototype`：dev-plan.md 存在且用户已确认
   - 进入 `audit`：`prototype/` 下有可运行的前端工程
4. 前置校验通过后，**输出 rules/workflow.md 的确认模板**，等待用户 Y/N/调整
5. 用户确认后，更新 `workspace/<项目名>/.state.json`：
   ```json
   {
     "project": "<项目名>",
     "stage": "<next-stage>",
     "owner_role": "<映射后的角色>",
     "last_updated": "<ISO8601>"
   }
   ```
6. 激活对应角色的 SKILL.md，开始执行该阶段

**异常处理**：
- 任一校验失败 → 停止，说明原因，建议先跑对应前置命令（`/prd`、`/plan`、`/build`）
- 目标 stage 不在允许值中 → 停止，列出合法值
