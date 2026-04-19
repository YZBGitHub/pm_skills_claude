# PM Skills - 产品经理需求设计与原型开发工作流

## 项目概述

一套面向 **高等职业教育院校用户**（覆盖学生、教师、辅导员、教务/学工/督导/就业等管理人员、院系/学校管理者，以及产教融合中的企业导师）的产品需求设计与原型开发 Skills 工作流。通过 **7 个主角色 + 1 个总控** 的串联协作，将产品需求从大纲阶段推进到高保真原型并部署上线。

## 规则文件（Rules）

全局规则按类型拆分至 `rules/` 目录，每次会话自动生效：

| 规则文件 | 作用域 | 谁需要遵守 |
|---------|--------|----------|
| [rules/principles.md](rules/principles.md) | 行为准则：想清楚、简洁、外科手术、目标驱动 | **所有角色（强制）** |
| [rules/general.md](rules/general.md) | 通用原则、行业背景、输出规范 | 所有角色 |
| [rules/workflow.md](rules/workflow.md) | 阶段切换、确认机制、触发路由、产物路径、`.state.json` schema | 所有角色 |
| [rules/prd.md](rules/prd.md) | PRD 撰写标准、视觉规范色板、撰写自检基线 | prd-specialist, design-specialist |
| [rules/frontend.md](rules/frontend.md) | 技术栈、代码规范、高保真标准、Surgical Changes | frontend-developer, prototype-auditor |

## 工作流总览

```
需求大纲 (输入)
    │
    ▼
[0] 领航员 · workflow-orchestrator           意图识别、状态路由（兜底）
    │
    ▼
[1] 需求架构师 · prd-specialist              需求分析 + PRD 撰写 → PRD.md 1-6 章草稿
    │
    ▼
[1.5] 刁钻评审官 · prd-reviewer              独立刁钻评审 → prd-review-report.md
    │  ↺ 有 Blocker/Major 回到 [1] 修订；连续 2 轮无 Blocker/Major 才放行
    ▼
[2] UI/UX 设计师 · design-specialist           用户故事 + UI/UX 规范 → PRD.md 7-8 章 定稿
    │
    ══════ PRD.md 定稿 ══════
    │
    ▼
[3] 研发调度官 · project-manager             → 开发计划 ← 用户确认节点
    │  (确认计划后)
    ▼
[4] 原型构筑师 · frontend-developer          → 高保真原型（Vite+React，含 Three.js 3D 支援）
    │
    ▼
[5] 末端审核员 · prototype-auditor            末端简易审核（≤3 项硬伤）→ audit-quick.md
    │
    ▼
（可选）/deploy <项目> <平台>                 独立命令，按用户指定平台部署
    │
    ▼
[6] 工作流复盘师 · self-optimizer            三层记忆系统，持续采集反馈（后台运行）
```

## 角色路由表

| 身份名 | Skill slug | 主要触发 |
|-------|-----------|---------|
| 领航员 | workflow-orchestrator | 意图不明确、跨阶段跳转、项目状态查询 |
| 需求架构师 | prd-specialist | 需求大纲输入 / "需求分析" / "写PRD" / "修订PRD" |
| 刁钻评审官 | prd-reviewer | "评审PRD" / "审查PRD" / "挑刺" / "找漏洞" / "研发评审" |
| UI/UX 设计师 | design-specialist | PRD 评审通过后 / "用户故事" / "UI规范" |
| 研发调度官 | project-manager | PRD 定稿后 / "排期" / "开发计划" |
| 原型构筑师 | frontend-developer | 计划确认后 / "生成原型" / "写前端" |
| 末端审核员 | prototype-auditor | 原型完成后 / "审一下" / "看看明显问题" |
| —（部署独立命令） | `/deploy` | 用户主动触发；不绑任何角色 |
| 工作流复盘师 | self-optimizer | 后台运行 / "优化流程" |

> 详细触发关键词见 [rules/workflow.md](rules/workflow.md)

## 路由设计理念

采用 **分布式触发路由**：
- 每个 SKILL.md 自己声明触发条件和"何时不用"的重定向
- 任何角色可被直接激活，不需先过总控
- `workflow-orchestrator` 仅作为**兜底路由**，意图不明确时介入

## 角色合并 / 拆分说明

| 角色 | 合并/拆分自 | 理由 |
|--------|--------|---------|
| prd-specialist | requirements-analyst + prd-writer | 同一文档前期工作，中间无需用户干预 |
| **prd-reviewer** | **从 prd-specialist 拆出** | **打破"自己评审自己看不到盲区"的反模式，独立刁钻视角** |
| design-specialist | user-story-writer + ui-ux-designer | 都是往 PRD 补充规范章节 |
| **prototype-auditor** | **取代 release-engineer，瘦身后只剩"末端硬伤检查"** | **原 6 维度代码评审实测价值低；部署逻辑被抽到 `/deploy` 命令** |
| frontend-developer | frontend-developer + threejs-developer | 3D 作为内置支援，无独立入口 |

## Skills 目录

所有 skill 位于 `skills/` 目录下，每个 skill 包含：
- `SKILL.md` — 角色定义、职责、工作流程
- `references/` — 参考模板、检查清单等（可选）
- `assets/` — 静态资源（可选）

### SKILL.md frontmatter 规范

```yaml
---
name: <skill-slug>
version: <semver>
model: opus | sonnet | default    # 可选，声明首选模型
license: MIT                       # 便于分发与开源
description: >
  Use when: <激活场景>。
  Trigger phrases: <触发关键词列表>。
  Do NOT use for: <应重定向的场景>。
---
```

## 插件分发

本项目整体可作为 Claude Code Plugin 分发给团队成员。配置见 `.claude-plugin/plugin.json`。

端到端使用示例见 [EXAMPLES.md](EXAMPLES.md)。
