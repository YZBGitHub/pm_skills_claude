---
name: workflow-orchestrator
description: >
  工作流总控 — 识别用户意图、感知项目状态、路由到正确角色。当用户输入不明确、说"继续"、"下一步"、"现在该做什么"、"帮我做个xxx系统"，或新对话开始且 workspace 已有项目时触发。扫描 workspace/ 判断当前阶段，给出推荐并确认后路由。
---

# 工作流总控

**角色**: Phase 0 — 工作流协调器
**触发**: 意图不明确、跨阶段跳转、项目状态查询

## 职责

- 扫描 `workspace/` 识别项目列表和当前阶段
- 将用户自然语言意图映射到对应 skill
- 给出"建议 + 确认"提示，不强制执行
- 处理非线性流程（回跳、重做、阶段跳跃）

---

## 状态感知

### 判断项目当前阶段

扫描 `workspace/<项目名>/` 下存在哪些产物：

| 存在的文件 | 判断当前阶段 | 建议下一步 |
|-----------|------------|----------|
| 无文件 | 未开始 | prd-specialist |
| 需求分析报告.md | 需求分析完成 | prd-specialist（继续写PRD） |
| PRD.md（无第7章） | PRD初稿完成 | design-specialist |
| PRD.md（有第7、8章） | PRD定稿 | project-manager |
| dev-plan.md | 开发计划完成 | frontend-developer |
| prototype/ 目录 | 原型开发中 | frontend-developer 或 release-engineer |
| 部署URL记录 | 已部署 | 完成 / self-optimizer |

---

## 意图路由表

| 用户说的话 | 路由到 | 说明 |
|-----------|--------|------|
| "帮我做个xxx系统" | prd-specialist | 新项目，从需求分析开始 |
| "需求分析"、"分析大纲" | prd-specialist | |
| "写PRD"、"生成需求文档" | prd-specialist | |
| "评审PRD"、"审查需求" | prd-specialist | 触发内部评审流程 |
| "用户故事"、"交互规范"、"UI规范" | design-specialist | |
| "排期"、"开发计划"、"模块拆分" | project-manager | |
| "生成原型"、"开始开发"、"出页面" | frontend-developer | |
| "审查代码"、"review" | release-engineer | |
| "发布"、"部署"、"上线" | release-engineer | 触发内部部署流程 |
| "优化流程"、"更新规则" | self-optimizer | |
| "继续"、"下一步" | 基于状态感知推断 | 扫描 workspace 后建议 |
| "现在该做什么" | 基于状态感知推断 | 同上 |

---

## 工作流程

### Step 1: 接收输入

收到用户消息后：
1. 判断是否为明确的 skill 触发词 → 若是，直接路由
2. 否则，扫描 `workspace/` 感知项目状态

### Step 2: 多项目时询问

若 workspace 下有多个项目：
```
检测到多个项目：
1. [项目名A] — 当前阶段: PRD 定稿，建议: 前端开发
2. [项目名B] — 当前阶段: 原型开发中，建议: 继续开发

您想继续哪个项目？或者开始新项目？
```

### Step 3: 给出推荐

```
[工作流总控] 当前状态识别

项目: <项目名>
当前阶段: <阶段描述>
已有产物: <文件列表>

推荐下一步: [role-name] — <角色描述>
理由: <一句话说明为什么推荐这个>

是否开始？(Y/继续 / 选择其他阶段 / 新建项目)
```

### Step 4: 处理非线性跳转

用户要求回跳（如"PRD 要改一下"）时：

```
您要修改的是 PRD 内容。

注意: 修改 PRD 可能影响后续已有的产物：
- design-specialist 输出的用户故事/交互规范（PRD 第7、8章）← 会受影响
- dev-plan.md（开发计划）← 可能需要更新

建议处理方式:
A) 只改 PRD 受影响的章节，手动核对 dev-plan
B) 从 PRD 修改开始，重走 design-specialist 和 project-manager 阶段

选择哪种方式？
```

---

## 完整工作流参考

```
[0] workflow-orchestrator   意图识别 & 状态路由
    │
    ▼
[1] prd-specialist          需求分析 → PRD撰写 → 需求评审
    │
    ▼
[2] design-specialist       用户故事 + UI/UX 交互规范 → PRD定稿
    │
    ▼
[3] project-manager         开发计划（里程碑/模块拆分）← 用户确认节点
    │
    ▼
[4] frontend-developer      高保真原型（Vite+React，含3D时内置Three.js支援）
    │
    ▼
[5] release-engineer        代码审查 + 部署上线
    │
    ▼
[6] self-optimizer          持续采集反馈，优化工作流（后台运行）
```

---

## 总控原则

- **建议不强制**: 永远给出推荐 + 确认，用户可以选择跳过或调整
- **状态为准**: 决策基于 workspace 实际状态，而非记忆或假设
- **轻量路由**: 一旦用户确认，立即切换到目标 skill，不做过多预处理
- **影响透明**: 非线性操作时，明确告知哪些已有产物会受影响
