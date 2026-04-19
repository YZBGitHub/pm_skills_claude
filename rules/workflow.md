# 工作流协议（Workflow Protocol）

> 本文件定义阶段切换、确认机制、触发路由等工作流层面的规则。

## 阶段切换确认机制

**每次进入新阶段或开始新任务时，必须先向用户确认再执行。**

### 确认模板

```
[角色名] 准备开始。
- 输入: [上一阶段的产物]
- 输出: [本阶段产物]
- 预计操作: [简述将要做什么]

确认开始吗？(Y/继续 / N/暂停 / 调整/说明需求变化)
```

### 必须确认的场景

| 场景 | 确认时机 |
|------|---------|
| 进入新角色阶段 | 上一阶段完成后，进入下一角色前 |
| 开始新项目 | 首次接收需求大纲时 |
| 技术栈变更 | 前端使用非默认技术栈（Vite+React）时 |
| 大量文件操作 | 即将创建 >5 个文件时 |
| 部署操作 | 任何部署操作前 |
| 覆盖已有产物 | 要修改或覆盖 workspace 中已有文件时 |

## 触发关键词路由表

| 身份名 · Skill slug | 触发关键词 |
|-------------------|-----------|
| 领航员 · workflow-orchestrator | "继续"、"下一步"、"现在该做什么"、"帮我做个xxx系统"、意图不明确时 |
| 需求架构师 · prd-specialist | "需求分析"、"分析大纲"、"写PRD"、"生成需求文档"、"修订PRD"、"按评审反馈改"、检测到大纲输入 |
| 刁钻评审官 · prd-reviewer | "评审PRD"、"审查PRD"、"PRD评审"、"挑刺"、"找漏洞"、"研发评审"、"刁钻评审" |
| UI/UX 设计师 · design-specialist | "用户故事"、"拆分需求"、"UI规范"、"设计交互"、"交互设计"、"视觉规范" |
| 研发调度官 · project-manager | "排期"、"开发计划"、"模块拆分"、"里程碑" |
| 原型构筑师 · frontend-developer | "生成原型"、"开始开发"、"出页面"、"写前端" |
| 末端审核员 · prototype-auditor | "审一下"、"看看明显问题"、"末端审核"、"快速过一下"、"原型审核" |
| —（部署独立命令） | `/deploy <项目> <平台>` 由用户主动触发，不绑角色 |
| 工作流复盘师 · self-optimizer | "优化流程"、"更新规则" |

## 路由分发策略（分布式）

本工作流采用 **分布式路由** 设计：
- 每个 SKILL.md 自己声明触发条件（`description` 字段）
- 每个 SKILL.md 自己声明"何时不用"，引导到正确角色
- `workflow-orchestrator` 仅作为**兜底路由**，在意图真正不明确时介入
- 任何角色可被直接激活，不需先过总控

## 产物路径规范

| 产物 | 路径 |
|------|------|
| PRD 文档 | `workspace/<项目名>/PRD.md` |
| 开发计划 | `workspace/<项目名>/dev-plan.md` |
| 前端原型 | `workspace/<项目名>/prototype/` |
| 项目状态 | `workspace/<项目名>/.state.json` |
| 末端审核报告 | `workspace/<项目名>/audit-quick.md` |
| PRD 评审报告 | `workspace/<项目名>/prd-review-report.md` |
| 需求分析报告（可选） | `workspace/<项目名>/需求分析报告.md` |
| 跨会话记忆 | `workspace/<项目名>/memory/` |
| 变更日志 | `workspace/<项目名>/change-log.md` |

## 项目状态机 · `.state.json` Schema

每个项目根目录下必须维护 `.state.json`，由**当前角色**在进入 / 完成阶段时更新。

```jsonc
{
  "project": "选课系统",                    // 项目名，与 workspace/<项目名>/ 一致
  "stage": "prd_drafting",                  // 当前阶段，见下表
  "owner_role": "prd-specialist",           // 当前负责角色
  "last_updated": "2026-04-18T10:00:00+08:00",  // ISO 8601 含时区
  "acceptance_criteria": [                  // 下一角色必须逐条勾选
    {"item": "PRD 含第 1-6 章", "done": false},
    {"item": "至少识别 3 类典型用户场景", "done": false}
  ]
}
```

### stage 枚举

| stage 值 | 含义 | owner_role |
|----------|------|-----------|
| `outline_received` | 大纲已收到，待分析 | prd-specialist |
| `prd_drafting` | PRD 1-6 章撰写中 / 按评审报告修订中 | prd-specialist |
| `prd_reviewing` | PRD 草稿待独立评审 / 评审进行中 | prd-reviewer |
| `design_drafting` | PRD 7-8 章撰写中 | design-specialist |
| `prd_finalized` | PRD 定稿，待排期 | project-manager |
| `plan_drafting` | 开发计划撰写中 | project-manager |
| `plan_confirmed` | 开发计划已确认，待开发 | frontend-developer |
| `prototype_building` | 原型开发中 | frontend-developer |
| `audit_quick` | 原型完成，末端审核中 / 已出报告 | prototype-auditor |
| `prototype_done` | 末端审核通过，待用户验收 / 可选部署 | —（用户验收）|
| `deployed` | 已部署（通过 `/deploy` 命令） | — → self-optimizer |

### prd_drafting ↔ prd_reviewing 闭环

```
prd_drafting (prd-specialist 写草稿 / 修订)
    │
    │ 草稿/修订完成 → 写入 .state.json: stage = prd_reviewing
    ▼
prd_reviewing (prd-reviewer 独立刁钻评审)
    │
    ├─ review_result = blocker_found / major_found
    │   → 写入 .state.json: stage = prd_drafting，回到撰写角色修订
    │   → （循环）
    │
    └─ review_result = passed (连续 2 轮无 Blocker / Major)
        → 写入 .state.json: stage = design_drafting
        → 进入 design-specialist
```

### 评审上下文独立性（强制）

prd-reviewer **必须在独立上下文中运行**，不允许与 prd-specialist 在同一会话内顺序切换角色完成评审。原因：
- 主会话已经接收了用户的口头描述、撰写思路、未写明的隐式假设
- 即使切换到"评审者"人格，这些上下文会让评审标准悄悄放宽，遮蔽本应识别为 Blocker 的问题
- "评审者"的核心价值是"看不到撰写过程，只看 PRD 文本"

**实现方式（按 IDE 能力分级）**：

| 环境 | 强制做法 |
|------|---------|
| Claude Code | `/review-prd` 命令必须通过 Agent 工具调用 `.claude/agents/prd-reviewer.md` subagent；主会话不得直接 Read PRD + Write 评审报告 |
| Codex / Cursor / OpenCode / Aider | 开新会话或新 git worktree，会话开头只 `@skills/prd-reviewer/SKILL.md @rules/prd.md @rules/workflow.md`，不要载入主会话历史 |

**反模式**（明令禁止）：
- 主会话扮演 prd-reviewer 角色，直接评审本会话刚写完的 PRD
- 在 subagent prompt 中夹带 PRD 内容摘要 / 撰写者自辩 / 用户偏好说明（让 subagent 自己 Read 原文）
- 把上一轮评审的辩护理由作为本轮"已沟通"的免检依据

### acceptance_criteria 机制（Goal-Driven Execution）

**写入时机**: 每个角色完成本阶段时，**必须**写入下一角色的 acceptance_criteria（作为交接契约）。
**勾选时机**: 下一角色**交付前**必须逐条勾选 `done: true`，任何一条未达成不允许 `/handoff`。
**校验**: 详细原则见 [principles.md](principles.md) §4。

**示例交接流**:

```
prd-specialist 完成 PRD 1-6 章
  └─ 写入 acceptance_criteria for design-specialist:
      - "用户故事覆盖第 3 章所有功能点"
      - "视觉规范包含主色 / 辅色 / 字体 token"
  └─ stage → "design_drafting", owner_role → "design-specialist"

design-specialist 在交付前：
  ├─ 逐条勾选 acceptance_criteria.done = true
  ├─ 写入下一段 acceptance_criteria for project-manager
  └─ stage → "prd_finalized"
```

## PRD.md 完整结构

```markdown
# [项目名称] 产品需求文档

## 1. 需求背景与目标           ← prd-specialist
## 2. 用户画像与场景分析        ← prd-specialist
## 3. 功能需求                 ← prd-specialist
## 4. 非功能需求               ← prd-specialist
## 5. 数据埋点方案             ← prd-specialist
## 6. 边界Case与异常处理       ← prd-specialist
## 7. 用户故事与验收标准        ← design-specialist
## 8. 交互规范与视觉规范        ← design-specialist
## 9. 变更记录                 ← 全流程（包含 prd-reviewer 评审轮次记录）
```

PRD 评审报告独立成文：`workspace/<项目名>/prd-review-report.md`（由 prd-reviewer 维护，每轮覆盖式更新或追加章节）。

---

## 后期变更协议（看到原型后想加 / 改需求）

**问题**：标准流程是单向的 `PRD → 评审 → design → plan → 原型`。看到原型后才想到的需求，如果没有标准化路径，要么"在原型上直接改导致 PRD 失真"，要么"小改也要走全流程导致疲劳放弃"。

**三类变更通道**：

| 类型 | 判断标准 | 处理路径 | 触发命令 |
|------|---------|---------|---------|
| **tweak**（微调） | 文案、配色微调、按钮位置、间距优化、图标替换；**不涉及业务规则、字段、状态** | frontend-developer 直接改原型 + 写 `change-log.md`，**不回 PRD** | `/change <项目> tweak <描述>` |
| **small**（小需求） | 新增 1 个字段 / 调整状态枚举 / 新增 1 个边界 case；**影响 ≤ 1 个功能模块**，无新角色/新页面 | prd-specialist 写"PRD 增量段"（追加到 PRD §X 子节，标 `[INC-N]` 标记）→ prd-reviewer **mini-review**（只看增量段）→ 通过后 frontend-developer 实现 | `/change <项目> small <描述>` |
| **real**（真需求变更） | 新增功能模块 / 改业务流程 / 改角色权限 / 改非功能指标 | 完整回到 prd-specialist 走 `prd → prd-review → design → plan → prototype` 全流程 | `/change <项目> real <描述>` |

**判定边界**（避免争议）：

```
看到原型后用户说"这个改一下" → 角色判定流程：

Q1: 改后 PRD 字段表 / 业务规则 / 状态机要不要动？
    └ 不动 → tweak
    └ 要动，但只动 1 处且不连带 → small
    └ 要动多处或连带其他模块 → real

Q2: 当前角色不确定 → 默认升一级（tweak→small, small→real），保守优先
Q3: 用户坚持要降级 → 写入 change-log.md 标注"用户确认降级"
```

**`change-log.md` 模板**（位于 `workspace/<项目>/change-log.md`，全流程 append-only）：

```markdown
# 变更日志 — <项目名>

## CHG-2026-04-19-001 · tweak
- **触发**: 用户看到 Dashboard 后说"主色再淡一点"
- **判定理由**: 仅视觉调整，无字段/规则变化
- **执行角色**: frontend-developer
- **改动**: tailwind.config.js → primary: #1677FF → #4096FF
- **是否回 PRD**: 否

## CHG-2026-04-19-002 · small
- **触发**: 用户希望选课列表能按"上课时间"排序
- **判定理由**: 新增 1 个排序选项，影响仅选课列表，无新字段
- **执行角色**: prd-specialist → prd-reviewer (mini) → frontend-developer
- **PRD 增量段**: PRD.md §3.2.1 追加 [INC-1]
- **mini-review 结论**: passed (R1)
- **是否回 PRD**: 是（增量）

## CHG-2026-04-19-003 · real
- **触发**: 用户希望增加"教师评教"模块
- **判定理由**: 新功能模块 + 新角色权限层
- **执行角色**: 走完整流程
- **是否回 PRD**: 是（新增 §3.X 章节，触发完整评审）
```

**红线**：
- **tweak 不许触碰业务逻辑代码**，只能改样式 / 文案 / 静态配置
- **small 必须经过 mini-review**（只评新增的 [INC-N] 段，5 分钟内完成），不许跳过
- **real 不许"假装是 small"** — reviewer 在 mini-review 时识别到牵连面广，必须升级为 real，回到完整流程
