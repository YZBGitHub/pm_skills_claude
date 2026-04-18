# 端到端使用示例

> 通过一个**脱敏的真实项目**（"高职院校选课系统"）走一遍完整工作流，
> 展示 6 角色如何串联、`.state.json` 如何流转、`acceptance_criteria` 如何交接。

---

## 输入：用户初始需求大纲

```
我想做一个面向高职院校的选课系统：
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

3. **完成时写入 `.state.json`**：
```json
{
  "project": "选课系统",
  "stage": "design_drafting",
  "owner_role": "design-specialist",
  "last_updated": "2026-04-18T11:30:00+08:00",
  "acceptance_criteria": [
    {"item": "用户故事覆盖第 3 章的 12 个功能点", "done": false},
    {"item": "学生端 / 教师端 / 教务端各至少 4 个用户故事", "done": false},
    {"item": "视觉规范包含主色 / 辅色 / 字体 token 与 tailwind.config.js 字段对齐", "done": false}
  ]
}
```

### 产物
- `workspace/选课系统/PRD.md` 第 1-6 章
- `workspace/选课系统/.state.json`

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

## Phase 5 · release-engineer（发布守门人）

### 角色行为
1. **6 维度审查** — 代码质量 / 视觉还原 / 交互完整性 / 响应式 / 性能 / 可访问性
2. **应用 frontend.md Surgical Changes** — 命中的具体问题修复，**无关 smell 写入 review-notes.md，不顺手优化**
3. 审查通过后 → 询问用户部署平台（Vercel / Netlify / 自建服务器）
4. **应用 principles.md §1** — 部署平台、域名、回滚策略由用户确认，不自选
5. 执行部署

### 产物
- 部署后的访问 URL
- `.state.json` → `deployed`

---

## Phase 6 · self-optimizer（工作流复盘师，后台运行）

### 角色行为
1. 整理本项目过程中**用户的修正 / 偏好 / 重复指令**
2. 例如本项目中用户多次说"配色再克制一点" → 沉淀为高职院校项目的默认偏好
3. **任何规则修改前必须用户确认**，再写入 `rules/` 或对应 SKILL

---

## 关键交接点速查

| 交接点 | 谁交给谁 | 触发命令 / 标志 |
|--------|---------|---------------|
| 大纲 → PRD 1-6 | 用户 → prd-specialist | "写PRD" / 大纲输入 |
| PRD 1-6 → PRD 7-8 | prd-specialist → design-specialist | `/handoff` 或"继续" |
| PRD 定稿 → 排期 | design-specialist → project-manager | "排期" / "开发计划" |
| 排期 → 开发 | project-manager → frontend-developer | **用户确认** + "开始开发" |
| 开发 → 审查 | frontend-developer → release-engineer | "审查代码" / "部署" |
| 全流程 → 复盘 | 任意角色 → self-optimizer | "优化流程" / 后台触发 |

---

## 失败模式与补救

| 症状 | 可能原因 | 补救 |
|------|---------|------|
| 角色越权（PRD 角色直接写代码） | 触发关键词重叠 | 检查 SKILL.md 的 "Do NOT use for" 是否清晰 |
| `.state.json` 与实际产物不一致 | 角色完成时漏写 | self-optimizer 复盘时校准 |
| acceptance_criteria 没勾选就交接 | 未读 [principles.md](rules/principles.md) §4 | 阻断交接，回退到当前角色补全 |
| 审查变成二次开发 | 未读 [frontend.md](rules/frontend.md) Surgical Changes | 把无关改动撤回，写入 review-notes.md |
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
  │── 审查 + 部署 ────────▶│── release-engineer → 部署
  │◀── 上线 URL ──────────│
```
