# AGENTS.md

> 跨 IDE 标准化的 Agent / Skill 定义入口（兼容 OpenAI Codex、Cursor、Antigravity、OpenCode、Aider 等支持 AGENTS.md 协议的工具）。
> Claude Code 用户请同时参考 `CLAUDE.md`，包含 Claude Code 专属能力（subagents / hooks / slash commands）。

## 项目定位

面向 **高等职业教育院校用户** 的产品需求设计与原型开发工作流。涵盖学生、教师、辅导员、教务/学工/督导/就业等管理人员、院系/学校管理者、产教融合企业导师等用户群体。

## 8 个角色（任意 IDE 均可手动激活）

激活方式：在对话中引用对应 `skills/<slug>/SKILL.md` 文件，或直接复述角色名 + 触发关键词。

| # | 身份名 | Skill slug | 主要触发 | 角色定义文件 |
|---|-------|-----------|---------|------------|
| 0 | 领航员 | workflow-orchestrator | 意图不明确、状态查询 | `skills/workflow-orchestrator/SKILL.md` |
| 1 | 需求架构师 | prd-specialist | "需求分析"/"写PRD"/"修订PRD" | `skills/prd-specialist/SKILL.md` |
| 1.5 | 刁钻评审官 | prd-reviewer | "评审PRD"/"挑刺"/"找漏洞" | `skills/prd-reviewer/SKILL.md` |
| 2 | UI/UX 设计师 | design-specialist | "用户故事"/"UI规范" | `skills/design-specialist/SKILL.md` |
| 3 | 研发调度官 | project-manager | "排期"/"开发计划" | `skills/project-manager/SKILL.md` |
| 4 | 原型构筑师 | frontend-developer | "生成原型"/"写前端" | `skills/frontend-developer/SKILL.md` |
| 5 | 末端审核员 | prototype-auditor | "审一下"/"看看明显问题" | `skills/prototype-auditor/SKILL.md` |
| —（独立命令） | `/deploy` | "部署"/"上线"（用户主动触发） | `.claude/commands/deploy.md` |
| 6 | 工作流复盘师 | self-optimizer | "优化流程"/"更新规则" | `skills/self-optimizer/SKILL.md` |

## 通用规则（任意 IDE 都应读取）

- `rules/principles.md` — 想清楚、简洁、外科手术、目标驱动（强制）
- `rules/general.md` — 通用原则、行业知识
- `rules/workflow.md` — 阶段切换、确认机制、`.state.json` schema、变更通道
- `rules/prd.md` — PRD 撰写规范
- `rules/frontend.md` — 前端技术栈

## 工作流

```
需求大纲
  → prd-specialist (1-6 章草稿)
  → prd-reviewer   (独立刁钻评审)  ↺ 循环直到 passed
  → design-specialist (7-8 章定稿)
  → project-manager (开发计划，含用户确认节点)
  → frontend-developer (高保真原型)
  → prototype-auditor (末端简易审核，3 项硬伤) → audit-quick.md
  → 可选：/deploy <项目> <平台>（独立命令，用户主动触发）
```

## 产物路径

| 产物 | 路径 |
|------|------|
| PRD 文档 | `workspace/<项目名>/PRD.md` |
| PRD 评审报告 | `workspace/<项目名>/prd-review-report.md` |
| 开发计划 | `workspace/<项目名>/dev-plan.md` |
| 前端原型 | `workspace/<项目名>/prototype/` |
| 项目状态 | `workspace/<项目名>/.state.json` |
| 末端审核报告 | `workspace/<项目名>/audit-quick.md` |
| 变更日志 | `workspace/<项目名>/change-log.md` |

## IDE 兼容矩阵

| 能力 | Claude Code | Codex | Antigravity | OpenCode | Cursor | Aider |
|------|------|-------|-------------|----------|--------|-------|
| AGENTS.md 自动加载 | 否（用 CLAUDE.md） | ✅ | ✅ | ✅ | ✅ | ✅ |
| `rules/*.md` @ 引用 | ✅ | 手动 | 手动 | 手动 | 手动 | 手动 |
| `skills/*/SKILL.md` 自动激活 | ✅（plugin） | ❌ | 部分 | ❌ | ❌ | ❌ |
| 角色 subagent 隔离上下文 | ✅ `.claude/agents/` | 部分 | ❌ | ❌ | ❌ | ❌ |
| Slash commands | ✅ `.claude/commands/` | 部分 | ❌ | 部分 | ❌ | ❌ |
| Hooks（PreToolUse/Session 等） | ✅ `.claude/hooks/` | ❌ | ❌ | ❌ | ❌ | ❌ |

## 非 Claude Code IDE 使用建议

由于 hook / subagent / slash command 等机制不通用，其他 IDE 上请按以下降级方式使用：

1. **手动加载规则**：会话开始时 `@rules/principles.md @rules/general.md @rules/workflow.md` 一次性载入
2. **手动激活角色**：需要切换角色时显式说"现在切换到 prd-reviewer，按 `skills/prd-reviewer/SKILL.md` 执行"
3. **手动维护状态**：`.state.json` 由你自己更新或让 AI 在每个阶段结束时更新
4. **评审上下文隔离**：开新 chat / 新 worktree 来跑 prd-reviewer，避免主会话污染
5. **变更通道**：手动判定 tweak / small / real，不依赖 `/change` 命令

详细迁移清单见 `PORTABILITY.md`。
