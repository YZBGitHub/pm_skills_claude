---
description: 进入 prd-specialist 启动需求分析与 PRD 1-6 章撰写
argument-hint: <项目名> [需求大纲]
---

切换到 **prd-specialist** 角色（依据 skills/prd-specialist/SKILL.md + rules/prd.md + rules/workflow.md）。

输入参数：$ARGUMENTS

**第一步参数校验**：
- 若未提供项目名，要求用户补充
- 若未提供需求大纲，向用户索取

**执行流程**：

1. 若 `workspace/<项目名>/` 不存在则创建；若已存在，读取并确认是否继续现有项目（按 rules/workflow.md"覆盖已有产物"需确认）
2. 写入/更新 `workspace/<项目名>/.state.json`：
   ```json
   {
     "project": "<项目名>",
     "stage": "prd",
     "owner_role": "prd-specialist",
     "last_updated": "<当前 ISO8601 时间>"
   }
   ```
3. 按 rules/workflow.md 的 PRD.md 结构生成第 1-6 章到 `workspace/<项目名>/PRD.md`：
   1. 需求背景与目标
   2. 用户画像与场景分析
   3. 功能需求
   4. 非功能需求
   5. 数据埋点方案
   6. 边界 Case 与异常处理
4. 按 rules/prd.md 的"撰写自检"基线自检（**仅自检最低基线，不替代评审**）
5. 草稿完成后**不直接进入 design**，而是切到 prd-reviewer：
   - 写入 `.state.json`：`stage = prd_reviewing`，`owner_role = prd-reviewer`
   - 提示用户：`/review-prd <项目名>` 触发独立评审
6. 仅当 prd-reviewer 输出 `review_result = passed` 后，才能 `/handoff <项目名> design`

**禁止**：
- 越权写第 7-8 章（那是 design-specialist 的职责）
- 自评自审（评审由独立的 prd-reviewer 角色完成）
