---
description: 通过 subagent 隔离上下文，对 PRD 第 1-6 章做独立刁钻评审（强制走子代理，避免主会话上下文污染）
argument-hint: <项目名> [评审轮次]
---

调用 **prd-reviewer subagent**（依据 `.claude/agents/prd-reviewer.md` + `skills/prd-reviewer/SKILL.md`）完成 PRD 评审。

输入参数：$ARGUMENTS

---

## 为什么强制走 subagent

PRD 评审必须**独立于撰写上下文**。如果让主会话直接评审：
- 主会话已经读过用户的口头描述、看过 prd-specialist 的撰写思路、可能读过早期草稿，**评审标准会被悄悄"放宽"以匹配已写内容**
- 撰写时使用的术语 / 假设 / 取舍依据会污染评审视角
- prd-reviewer 的核心价值（"挑剔的研发视角，看不见撰写者的辩护"）被破坏

**Subagent 提供干净上下文窗口** —— 它只看到本次显式传入的参数 + 它自己读取的文件，看不到主会话历史。这正是模拟"换一个研发负责人来 review"的关键。

---

## 第一步：参数校验（主会话执行）

- 若未提供项目名，要求用户补充
- 若 `workspace/<项目名>/PRD.md` 不存在，停止并提示先跑 `/prd <项目名>`
- 若未提供轮次，默认 1；若已存在前一轮报告，自动 +1

---

## 第二步：调用 subagent（强制）

**主会话不要直接读 PRD、不要直接写评审报告。** 通过 Agent 工具调用 `prd-reviewer` subagent，传入以下 prompt 模板：

```
你是 prd-reviewer subagent。完整行为定义见 .claude/agents/prd-reviewer.md 与 skills/prd-reviewer/SKILL.md。

任务输入：
- project_name: <项目名>
- review_round: <N>
- prior_report: workspace/<项目名>/prd-review-report.md（如存在前一轮，对照读取）

执行步骤：
1. 完整读取 workspace/<项目名>/PRD.md（不要跳读）
2. 如有前一轮 prd-review-report.md，对照读取，确认上一轮 Blocker/Major 是否已修订
3. 按六个维度独立扫描：完整性 / 精确性 / 一致性 / 可行性 / 边界与异常 / 高等职业教育院校适配
4. 输出 workspace/<项目名>/prd-review-report.md（覆盖式或追加 "第 N 轮" 章节）
5. 更新 workspace/<项目名>/.state.json：
   {
     "project": "<项目名>",
     "stage": "prd_reviewing",
     "owner_role": "prd-reviewer",
     "last_updated": "<ISO8601>",
     "review_round": <N>,
     "review_result": "blocker_found | major_found | passed"
   }
6. 返回简明摘要给主会话：Blocker 数 / Major 数 / Minor 数 / 评审结论 / 下一步建议

红线：
- 不替 prd-specialist 改写 PRD 正文
- 不放水、不刷存在感、不基于主会话的暗示放过问题
- 每条问题必须 cite §章节号 + 引用 PRD 原文
```

**禁止的反模式**：
- ❌ 主会话自己 Read PRD.md 然后 Write prd-review-report.md（即使懒得调 subagent 也不行）
- ❌ 把 PRD 全文复制粘贴到 subagent prompt 里（subagent 自己读，确保它独立通过 Read 接触原文）
- ❌ 在 subagent prompt 里塞主会话对 PRD 的解释 / 撰写背景 / 用户偏好（污染独立性）

---

## 第三步：处理 subagent 返回（主会话执行）

Subagent 返回摘要后，主会话只做：

1. 把摘要展示给用户
2. 根据 `review_result` 给出下一步建议：
   - `passed`（连续 2 轮无 Blocker / Major）→ 提示 `/handoff <项目名> design`
   - 否则 → 提示 `/handoff <项目名> prd`，回到 prd-specialist 修订
3. 不要帮 subagent 重新解释或软化问题

---

## 跨 IDE 降级方案

非 Claude Code 环境（Codex / Cursor / OpenCode / Aider 等）没有 subagent，等价做法：

- **新开一个独立会话** 跑 prd-reviewer，会话开头只 `@skills/prd-reviewer/SKILL.md @rules/prd.md @rules/workflow.md`，**不要载入主会话历史**
- 或新开一个 git worktree，让 prd-reviewer 在隔离环境中工作

详见 `PORTABILITY.md` 的"评审上下文隔离"段。
