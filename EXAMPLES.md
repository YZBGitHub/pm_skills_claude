# 端到端使用示例

> 通过一个**脱敏的真实项目**（"高等职业教育院校选课系统"）走一遍完整工作流，
> 展示 7 角色如何串联、`.state.json` 如何流转、`acceptance_criteria` 如何交接。

---

## 输入：用户初始需求大纲

```
我想做一个面向高等职业教育院校的选课系统：
- 学生端：浏览本学期开放课程、选课、退课、查看课表
- 教师端：开课申请、查看选课名单、导出班级名单
- 教务端：审核开课、设置选课时间窗、调剂处理
- 关键约束：选课期间并发高（>2000 学生同时操作）、必修课不可退
```

---

## Phase 1 · prd-specialist（需求架构师）

### 用户输入
> "帮我把这个大纲做成 PRD"

### 角色行为
1. **应用 principles.md §1 Think Before Coding** — 先列假设回问：
   > 我假设：① 选课时间窗按学期开放 1 周；② 退课在开课前 2 周内允许；③ 调剂仅针对人数不足课程。如不一致请指正。

2. 用户确认后，撰写 PRD 第 1-6 章：背景 / 用户画像 / 功能 / 非功能 / 埋点 / 边界 Case

3. **完成草稿后写入 `.state.json`**（交给 prd-reviewer，而非直接进入 design）：
```json
{
  "project": "选课系统",
  "stage": "prd_reviewing",
  "owner_role": "prd-reviewer",
  "last_updated": "2026-04-18T11:30:00+08:00",
  "acceptance_criteria": [
    {"item": "Blocker = 0", "done": false},
    {"item": "Major ≤ 2 或全部 Major 已说明", "done": false}
  ]
}
```

### 产物
- `workspace/选课系统/PRD.md` 第 1-6 章（状态：待评审）
- `workspace/选课系统/.state.json`

---

## Phase 1.5 · prd-reviewer（刁钻评审官）

### 触发
prd-specialist 草稿完成 → 用户跑 `/review-prd 选课系统`，或 SessionStart hook 提示 `选课系统 / prd_reviewing / prd-reviewer`

### 角色行为
1. **应用 principles.md §3 Surgical Changes** — 只评审，不替写 PRD
2. 以"被坑过 10 年的高职院校研发负责人"心态六维交叉扫描：完整性 / 精确性 / 一致性 / 可行性 / 边界 / 高职适配
3. 输出 `workspace/选课系统/prd-review-report.md`，问题分级 Blocker / Major / Minor
4. 写入 `.state.json`：`review_result = blocker_found | major_found | passed`，`review_round = N`
5. 若发现 Blocker / Major → 提示用户 `/handoff 选课系统 prd` 回到 prd-specialist 修订
6. 若连续 2 轮无 Blocker / Major → 提示 `/handoff 选课系统 design`

### 典型评审发现示例
- [BLOCKER-01] §3.2 选课流程未定义"选课时间窗结束瞬间正在提交的请求按通过还是驳回"
- [MAJOR-03] §4.1 性能指标"首屏 ≤2 秒"未说明在多大并发下、什么网络条件
- [MINOR-02] §6 边界 Case 缺少"已毕业学生历史数据可见性"说明

### 产物
- `workspace/选课系统/prd-review-report.md`（每轮覆盖或追加章节）
- `.state.json` 更新

---

## Phase 2 · design-specialist（UI/UX 设计师）

### 触发
SessionStart hook 显示 `选课系统 / design_drafting / design-specialist` → 用户说"继续"

### 角色行为
1. **应用 principles.md §4** — 先读 `.state.json` 的 `acceptance_criteria`，作为本阶段验收契约
2. 三阶段执行：用户故事 → 设计风格定调 → UI/UX 规范
3. 写入 PRD 第 7-8 章
4. **交付前逐条勾选** acceptance_criteria，未达成则继续补
5. 完成时写入下一阶段 acceptance_criteria for project-manager

### 产物
- `workspace/选课系统/PRD.md` 第 7-9 章（PRD 定稿）
- `.state.json` → `prd_finalized`

---

## Phase 3 · project-manager（研发调度官）

### 角色行为
1. 拆模块：M1 基础架构 / M2 学生端核心流程 / M3 教师端 / M4 教务端 / M5 高并发优化
2. 评估依赖、风险、里程碑
3. **应用 principles.md §2 Simplicity First** — 不做"理论最优"WBS，颗粒度到能交付即可
4. 输出 `dev-plan.md`，**等待用户确认**（必须的人工节点）

### 用户确认节点
> 用户：调整一下，M5 不做了，先出 MVP

→ 角色更新 dev-plan.md，重新提交确认。

---

## Phase 4 · frontend-developer（原型构筑师）

### 触发
用户说"开始开发 M1"

### 角色行为
1. 读 `.state.json` 的 acceptance_criteria，确认本里程碑要交付什么
2. **应用 principles.md §1** — 技术栈如有偏离默认（Vite+React+Tailwind）必须先确认；本例用默认 → 直接开干
3. 按里程碑 1 交付 Layout + Dashboard + 路由
4. **每里程碑结束** → 更新 `.state.json`，请用户确认是否继续 M2
5. 发现未要求的 smell（如 mockData 命名不一致）→ 写入 `review-notes.md`，**不顺手改**

### 产物
- `workspace/选课系统/prototype/`（完整 Vite 项目）
- `workspace/选课系统/review-notes.md`（持续累积）

---

## Phase 5 · prototype-auditor（末端审核员）

### 角色行为
1. **3 项硬伤检查** — 视觉硬伤 / 关键交互断裂 / 内容荒谬，每类最多 1 条，全加 ≤ 3 条
2. 不做 6 维度代码评审、Bundle 分析、a11y 全量审计 —— 这些原 release-engineer 时段实测价值低
3. `passed` → 提示用户验收；`needs_fix` → `/handoff <项目> prototype` 回交 frontend-developer

### 产物
- `workspace/<项目名>/audit-quick.md`（简明审核报告）
- `.state.json` → `audit_quick`

---

## Phase 5.5 · `/deploy`（独立命令，不绑角色）

### 触发
用户主动执行 `/deploy <项目名> <平台>`。**默认不自动部署**，必须用户主动调起。

### 行为
1. 参数校验 + 平台询问
2. 用户 Y 后 `npm run build`
3. 按用户指定平台执行部署命令（Vercel / Netlify / rsync / OSS / 校园内网交付）
4. 写部署回执，更新 `.state.json` → `deployed`

### 产物
- `dist/` 构建产物
- 部署 URL（如适用）
- `.state.json` → `deployed`

---

## Phase 6 · self-optimizer（工作流复盘师，后台运行）

### 角色行为
1. 整理本项目过程中**用户的修正 / 偏好 / 重复指令**
2. 例如本项目中用户多次说"配色再克制一点" → 沉淀为高等职业教育院校项目的默认偏好
3. **任何规则修改前必须用户确认**，再写入 `rules/` 或对应 SKILL

---

## 关键交接点速查

| 交接点 | 谁交给谁 | 触发命令 / 标志 |
|--------|---------|---------------|
| 大纲 → PRD 1-6 草稿 | 用户 → prd-specialist | "写PRD" / 大纲输入 |
| PRD 草稿 → 评审 | prd-specialist → prd-reviewer | `/review-prd <项目名>` |
| 评审有 Blocker/Major → 修订 | prd-reviewer → prd-specialist | `/handoff <项目名> prd` |
| 评审通过 → PRD 7-8 | prd-reviewer → design-specialist | `/handoff <项目名> design` |
| PRD 定稿 → 排期 | design-specialist → project-manager | "排期" / "开发计划" |
| 排期 → 开发 | project-manager → frontend-developer | **用户确认** + "开始开发" |
| 开发 → 末端审核 | frontend-developer → prototype-auditor | `/handoff <项目> audit` / "审一下" |
| 末端审核 → 验收/部署 | prototype-auditor → 用户验收 / `/deploy` | passed 后用户主动 `/deploy <项目> <平台>` |
| 全流程 → 复盘 | 任意角色 → self-optimizer | "优化流程" / 后台触发 |

---

## 失败模式与补救

| 症状 | 可能原因 | 补救 |
|------|---------|------|
| 角色越权（PRD 角色直接写代码） | 触发关键词重叠 | 检查 SKILL.md 的 "Do NOT use for" 是否清晰 |
| `.state.json` 与实际产物不一致 | 角色完成时漏写 | self-optimizer 复盘时校准 |
| acceptance_criteria 没勾选就交接 | 未读 [principles.md](rules/principles.md) §4 | 阻断交接，回退到当前角色补全 |
| 末端审核扩成全面 QA | 未读 [skills/prototype-auditor/SKILL.md] | 强制限 ≤3 条，多余的写到 backlog |
| 用户说"继续"但意图不明 | 多项目并存或跨阶段 | workflow-orchestrator 兜底，列出可选路径让用户选 |

---

## 极简快速上手

```
你（用户）             我（任意角色）
  │                       │
  │── 给一段需求大纲 ──────▶│
  │                       │── prd-specialist 自动激活
  │                       │── 列假设 → 回问
  │◀── 假设清单 ───────────│
  │── 确认 ───────────────▶│
  │                       │── 写 PRD 1-6 → 写 .state.json
  │◀── 完成提示 ──────────│
  │── 继续 ───────────────▶│
  │                       │── design-specialist 接手 → 写 PRD 7-8
  │◀── PRD 定稿 ──────────│
  │── 排期 ───────────────▶│── project-manager → dev-plan.md
  │◀── 计划提交 ──────────│
  │── 确认 + 开始开发 ────▶│── frontend-developer → 原型
  │◀── 里程碑 1 完成 ─────│
  │── 审一下 ─────────────▶│── prototype-auditor → 末端审核（≤3 条）
  │◀── audit-quick.md ─────│
  │── /deploy 项目 平台 ──▶│── /deploy 命令独立执行 → 部署
  │◀── 上线 URL ──────────│
```
