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
| 需求架构师 · prd-specialist | "需求分析"、"分析大纲"、"写PRD"、"生成需求文档"、"评审需求"、"审查PRD"、检测到大纲输入 |
| UI/UX 设计师 · design-specialist | "用户故事"、"拆分需求"、"UI规范"、"设计交互"、"交互设计"、"视觉规范" |
| 研发调度官 · project-manager | "排期"、"开发计划"、"模块拆分"、"里程碑" |
| 原型构筑师 · frontend-developer | "生成原型"、"开始开发"、"出页面"、"写前端" |
| 发布守门人 · release-engineer | "审查代码"、"review"、"代码审核"、"发布"、"部署"、"上线" |
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
| 审查记录 | `workspace/<项目名>/review-notes.md` |
| 需求分析报告（可选） | `workspace/<项目名>/需求分析报告.md` |
| 跨会话记忆 | `workspace/<项目名>/memory/` |

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
| `prd_drafting` | PRD 1-6 章撰写中 | prd-specialist |
| `design_drafting` | PRD 7-8 章撰写中 | design-specialist |
| `prd_finalized` | PRD 定稿，待排期 | project-manager |
| `plan_drafting` | 开发计划撰写中 | project-manager |
| `plan_confirmed` | 开发计划已确认，待开发 | frontend-developer |
| `prototype_building` | 原型开发中 | frontend-developer |
| `review_pending` | 原型完成，待审查 | release-engineer |
| `review_passed` | 审查通过，待部署 | release-engineer |
| `deployed` | 已部署 | release-engineer → self-optimizer |

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
## 6. 边界Case与异常处理       ← prd-specialist（含自评审）
## 7. 用户故事与验收标准        ← design-specialist
## 8. 交互规范与视觉规范        ← design-specialist
## 9. 变更记录                 ← 全流程
```
