# PM Skills - 产品经理需求设计与原型开发工作流

## 项目概述

这是一套面向 **ToS（高职院校客户）** 的产品需求设计与原型开发 Skills 工作流。通过 **6个主角色 + 1个总控** 的串联协作，将产品需求从大纲阶段推进到高保真原型并部署上线。

## 行业背景

- **目标客户**: 高职院校（ToS - To School）
- **典型场景**: 教务管理、学生服务、实训平台、校企合作、招生就业等高职院校信息化系统
- **设计原则**: 界面简洁易用，符合教育行业用户习惯，兼顾管理端和学生端体验

## 工作流总览

```
需求大纲 (输入)
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
    ══════ PRD.md 定稿 ══════
    │
    ▼
[3] project-manager        研发项目经理      → 开发计划（模块拆分/优先级/里程碑）← 用户确认节点
    │  (确认计划后)
    ▼
[4] frontend-developer     高级前端开发      → 高保真原型（Vite+React，含Three.js 3D支援）
    │
    ▼
[5] release-engineer       发布工程师        代码审查 + 部署上线
    │
    ▼
[6] self-optimizer         自我优化专家      持续采集反馈，优化工作流（后台运行）
```

### 合并说明

| 新角色 | 合并自 | 合并理由 |
|--------|--------|---------|
| prd-specialist | requirements-analyst + prd-writer + requirements-reviewer | 都是PM视角的同一文档工作，中间无需用户干预 |
| design-specialist | user-story-writer + ui-ux-designer | 都是往PRD补充规范章节，性质相近 |
| release-engineer | code-reviewer + devops-engineer | 审查通过即部署，通常连续执行 |
| frontend-developer | frontend-developer + threejs-developer | threejs-developer 作为内置3D支援，无独立入口 |

## 阶段切换确认规则

**每次进入新阶段或开始新任务时，必须先向用户确认再执行。**

### 确认模板
```
[角色名] 准备开始。
- 输入: [上一阶段的产物]
- 输出: [本阶段产物]
- 预计操作: [简述将要做什么]

确认开始吗？(Y/继续 / N/暂停 / 调整/说明需求变化)
```

### 哪些情况必须确认

| 场景 | 确认时机 |
|------|---------|
| 进入新角色阶段 | 上一阶段完成后，进入下一角色前 |
| 开始新项目 | 首次接收需求大纲时 |
| 技术栈变更 | 前端使用非默认技术栈（Vite+React）时 |
| 大量文件操作 | 即将创建 >5 个文件时 |
| 部署操作 | 任何部署操作前 |
| 覆盖已有产物 | 要修改或覆盖 workspace 中已有文件时 |

### 触发关键词（用户主动触发）

| Skill | 触发关键词 |
|-------|-----------|
| workflow-orchestrator | "继续"、"下一步"、"现在该做什么"、"帮我做个xxx系统"、意图不明确时 |
| prd-specialist | "需求分析"、"分析大纲"、"写PRD"、"生成需求文档"、"评审需求"、"审查PRD"、检测到大纲输入 |
| design-specialist | "用户故事"、"拆分需求"、"UI规范"、"设计交互"、"交互设计"、"视觉规范" |
| project-manager | "排期"、"开发计划"、"模块拆分"、"里程碑" |
| frontend-developer | "生成原型"、"开始开发"、"出页面"、"写前端" |
| release-engineer | "审查代码"、"review"、"代码审核"、"发布"、"部署"、"上线" |
| self-optimizer | "优化流程"、"更新规则" |

## 产物规范

### 文件命名
- PRD 文档: `workspace/<项目名>/PRD.md`
- 开发计划: `workspace/<项目名>/dev-plan.md`
- HTML 原型: `workspace/<项目名>/prototype/`

### PRD.md 完整结构
PRD.md 是核心产物，由多个角色协作完成：

```markdown
# [项目名称] 产品需求文档

## 1. 需求背景与目标           ← prd-specialist
## 2. 用户画像与场景分析        ← prd-specialist
## 3. 功能需求                 ← prd-specialist
## 4. 非功能需求               ← prd-specialist
## 5. 数据埋点方案             ← prd-specialist
## 6. 边界Case与异常处理       ← prd-specialist（含自评审）
## 7. 用户故事与验收标准        ← design-specialist
## 8. 交互规范与视觉规范        ← design-specialist
## 9. 变更记录                 ← 全流程
```

## 全局提示词设定

### 角色通用原则
1. **用户视角优先** — 始终从高职院校终端用户（学生、教师、教务人员）的角度思考
2. **简洁专业** — 输出内容结构清晰，避免冗余，使用中文
3. **可追溯** — 每个决策都要有依据，每次修改都记录到变更记录
4. **协作意识** — 每个角色完成后，明确告知下一步应该做什么
5. **行业适配** — 充分考虑高职院校的管理特点、学生特征、政策要求

### 技术栈规范
- **默认技术栈**: Vite + React + Tailwind CSS（高保真原型）
- **3D 需求**: 使用 Three.js（由 frontend-developer 内置支援，无需独立触发）
- **技术栈变更**: 如需使用其他框架，必须向用户确认后再执行

## Skills 目录

所有 skill 位于 `skills/` 目录下，每个 skill 包含：
- `SKILL.md` — 角色定义、职责、工作流程
- `references/` — 参考模板、检查清单等（可选）
- `assets/` — 静态资源（可选）
