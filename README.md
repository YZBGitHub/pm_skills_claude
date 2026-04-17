# YZB PM Skills

面向高职院校（ToS）的产品需求设计与原型开发 AI 工作流。

## 工作流概览

```
需求大纲
    │
    ▼
[0] workflow-orchestrator  工作流总控        识别意图、感知项目状态、路由到正确角色
    │
    ▼
[1] prd-specialist         需求与PRD专家     需求分析 + PRD撰写 + 需求评审 → PRD.md 1-6章
    │
    ▼
[2] design-specialist      设计规范专家      用户故事 + UI/UX规范 → PRD.md 7-8章 定稿
    │
    ▼
[3] project-manager        研发项目经理      → 开发计划（模块拆分/优先级/里程碑）← 用户确认节点
    │
    ▼
[4] frontend-developer     高级前端开发      → 高保真原型（Vite+React，含Three.js 3D支援）
    │
    ▼
[5] release-engineer       发布工程师        代码审查 + 部署上线
    │
    ▼
[6] self-optimizer         自我优化专家      持续采集反馈，优化工作流（后台运行）
```

## Skills 角色

| # | 角色 | Skill | 触发 |
|---|------|-------|------|
| 0 | 工作流总控 | workflow-orchestrator | "继续"、"下一步"、"现在该做什么"、意图不明确时 |
| 1 | 需求与PRD专家 | prd-specialist | "需求分析"、"写PRD"、"评审需求"、上传大纲 |
| 2 | 设计规范专家 | design-specialist | "用户故事"、"UI规范"、"交互设计"、"视觉规范" |
| 3 | 研发项目经理 | project-manager | "排期"、"开发计划"、"模块拆分"、"里程碑" |
| 4 | 高级前端开发 | frontend-developer | "生成原型"、"开始开发"、"出页面"、"写前端" |
| 5 | 发布工程师 | release-engineer | "审查代码"、"review"、"发布"、"部署"、"上线" |
| 6 | 自我优化专家 | self-optimizer | "优化流程"、"更新规则" |

## 目录结构

```
pm_skills_claude/
├── CLAUDE.md                    # 全局工作流编排
├── README.md                    # 本文件
├── skills-lock.json             # skills 版本锁定
├── workspace/                   # 项目产物输出目录
└── skills/
    ├── workflow-orchestrator/   # [0] 工作流总控
    ├── prd-specialist/          # [1] 需求与PRD专家
    ├── design-specialist/       # [2] 设计规范专家
    ├── project-manager/         # [3] 研发项目经理
    ├── frontend-developer/      # [4] 高级前端开发
    ├── release-engineer/        # [5] 发布工程师
    └── self-optimizer/          # [6] 自我优化专家
```

## 产物规范

| 产物 | 路径 |
|------|------|
| PRD 文档 | `workspace/<项目名>/PRD.md` |
| 开发计划 | `workspace/<项目名>/dev-plan.md` |
| 前端原型 | `workspace/<项目名>/prototype/` |

## 快速开始

1. 将需求大纲发给 Claude
2. 说"需求分析"或"帮我做个xxx系统"开始第一个角色
3. 每个阶段切换前 Claude 会确认，确认后才执行
4. 前端默认使用 Vite + React + Tailwind CSS，如需调整可在确认环节说明
5. 含 3D 展示需求时自动协同 Three.js

## 适用场景

- 高职院校信息化系统原型设计
- 教务管理、学生服务、实训平台、校企合作、招生就业等场景
- 产品经理快速产出 PRD + 原型演示
