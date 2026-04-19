# YZB PM Skills

面向高等职业教育院校用户（学生 / 教师 / 辅导员 / 教务·学工·督导·就业等管理人员 / 院系·学校管理者 / 产教融合企业导师）的产品需求设计与原型开发 AI 工作流。

## 工作流概览

```
需求大纲
    │
    ▼
[0] 领航员 · workflow-orchestrator           识别意图、感知项目状态、路由到正确角色
    │
    ▼
[1] 需求架构师 · prd-specialist              需求分析 + PRD 撰写 → PRD.md 1-6 章草稿
    │
    ▼
[1.5] 刁钻评审官 · prd-reviewer              独立刁钻评审 → 分级问题清单
    │  ↺ 有 Blocker/Major 回 [1] 修订；连续 2 轮无 Blocker/Major 才放行
    ▼
[2] UI/UX 设计师 · design-specialist           用户故事 + UI/UX 规范 → PRD.md 7-8 章 定稿
    │
    ▼
[3] 研发调度官 · project-manager             → 开发计划（模块拆分/优先级/里程碑）← 用户确认节点
    │
    ▼
[4] 原型构筑师 · frontend-developer          → 高保真原型（Vite+React，含 Three.js 3D 支援）
    │
    ▼
[5] 末端审核员 · prototype-auditor            末端简易审核（≤3 项硬伤）→ audit-quick.md
    │
    ▼
（可选）/deploy <项目> <平台>                 独立命令，用户主动触发，不绑任何角色
    │
    ▼
[6] 工作流复盘师 · self-optimizer            持续采集反馈，优化工作流（后台运行）
```

## Skills 角色

| # | 身份名 | Skill slug | 触发 |
|---|-------|-----------|------|
| 0 | 领航员 | workflow-orchestrator | "继续"、"下一步"、"现在该做什么"、意图不明确时 |
| 1 | 需求架构师 | prd-specialist | "需求分析"、"写PRD"、"修订PRD"、上传大纲 |
| 1.5 | 刁钻评审官 | prd-reviewer | "评审PRD"、"审查PRD"、"挑刺"、"找漏洞"、"研发评审" |
| 2 | UI/UX 设计师 | design-specialist | "用户故事"、"UI规范"、"交互设计"、"视觉规范" |
| 3 | 研发调度官 | project-manager | "排期"、"开发计划"、"模块拆分"、"里程碑" |
| 4 | 原型构筑师 | frontend-developer | "生成原型"、"开始开发"、"出页面"、"写前端" |
| 5 | 末端审核员 | prototype-auditor | "审一下"、"看看明显问题"、"末端审核"、"快速过一下" |
| —（部署命令） | `/deploy` | — | 用户主动触发部署，不绑角色 |
| 6 | 工作流复盘师 | self-optimizer | "优化流程"、"更新规则" |

## 目录结构

```
pm_skills_claude/
├── CLAUDE.md                    # 全局工作流编排
├── README.md                    # 本文件
├── skills-lock.json             # skills 版本锁定
├── workspace/                   # 项目产物输出目录
└── skills/
    ├── workflow-orchestrator/   # [0] 工作流总控
    ├── prd-specialist/          # [1] 需求与 PRD 专家
    ├── prd-reviewer/            # [1.5] 独立 PRD 刁钻评审官
    ├── design-specialist/       # [2] 设计规范专家
    ├── project-manager/         # [3] 研发项目经理
    ├── frontend-developer/      # [4] 高级前端开发
    ├── prototype-auditor/       # [5] 末端审核员（仅 3 项硬伤检查）
    └── self-optimizer/          # [6] 自我优化专家
```

## 产物规范

| 产物 | 路径 |
|------|------|
| PRD 文档 | `workspace/<项目名>/PRD.md` |
| PRD 评审报告 | `workspace/<项目名>/prd-review-report.md` |
| 开发计划 | `workspace/<项目名>/dev-plan.md` |
| 前端原型 | `workspace/<项目名>/prototype/` |
| 末端审核报告 | `workspace/<项目名>/audit-quick.md` |
| 变更日志 | `workspace/<项目名>/change-log.md` |

## 快速开始

1. 将需求大纲发给 Claude
2. 说"需求分析"或"帮我做个 xxx 系统"开始第一个角色
3. PRD 草稿完成后用 `/review-prd <项目名>` 触发独立评审；有 Blocker/Major 则回到 prd-specialist 修订，循环直到通过
4. 每个阶段切换前 Claude 会确认，确认后才执行
5. 前端默认使用 Vite + React + Tailwind CSS，如需调整可在确认环节说明
6. 含 3D 展示需求时自动协同 Three.js

## 适用场景

- 高等职业教育院校信息化系统原型设计
- 教务管理、学生服务、实训平台、顶岗实习、校企合作、招生就业、督导评估、辅导员工作台等场景
- 产品经理快速产出 PRD + 原型演示
