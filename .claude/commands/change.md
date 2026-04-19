---
description: 后期变更分流 — 看到原型后想加/改需求时使用
argument-hint: <项目名> <tweak|small|real> <变更描述>
---

后期变更协议（依据 rules/workflow.md "后期变更协议" 章节）。

输入参数：$ARGUMENTS

**第一步参数校验**：
- 若未提供项目名，要求用户补充
- 若 `<类型>` 不在 `tweak | small | real` 中，停止并列出合法值
- 若未提供变更描述，要求用户补充

**判定校验**（用户给出类型后，AI 必须复核一遍，避免错判）：

```
读取 workspace/<项目名>/PRD.md，对照变更描述判断：

Q1: 此变更会让 PRD 的字段表 / 业务规则 / 状态机发生改动吗？
Q2: 影响范围是否限于 1 个功能模块？
Q3: 是否引入新角色 / 新页面 / 新模块？

判定结果与用户给出的类型不一致时：
- 必须告知用户："你给的是 X，但根据 Q1-Q3 判定建议为 Y，原因：..."
- 等待用户确认是否调整类型，或在 change-log.md 中显式标注"用户坚持降级"
```

**执行流程**：

### tweak（微调）
1. 直接进入 frontend-developer 角色
2. 改动只能在：tailwind.config.js / 文案 / 静态资源 / 排版间距
3. 完成后追加到 `workspace/<项目名>/change-log.md`
4. **不动** PRD.md，不改 .state.json 的 stage

### small（小需求）
1. 进入 prd-specialist：在 PRD.md 对应章节末尾追加 `### [INC-N] <增量标题>` 段（不动已定稿正文）
2. 触发 mini-review：调用 prd-reviewer 但传入限定 scope = `[INC-N] 段`
3. mini-review 通过后，进入 frontend-developer 实现
4. 全程在 `workspace/<项目名>/change-log.md` 中登记
5. .state.json 临时 stage 切换：`prd_drafting (incremental)` → `prd_reviewing (mini)` → `prototype_building`，结束后回到 `prototype_building`

### real（真需求变更）
1. 提示用户："此变更影响范围较大，将走完整 prd → prd-review → design → plan → prototype 流程"
2. 等待用户确认
3. 确认后执行 `/handoff <项目名> prd`，回到 prd-specialist
4. change-log.md 标注 `real`，关联本次完整流程的产物版本

**禁止**：
- tweak 改 PRD
- small 跳过 mini-review
- real 不经用户确认就回退到 prd 阶段

**输出**：每次执行结束都打印一段摘要到 change-log.md 的最新条目，便于回溯。
