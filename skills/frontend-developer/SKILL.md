---
name: frontend-developer
description: >
  高级前端开发 — 根据PRD和开发计划开发高保真原型。当开发计划确认后触发，或用户说"生成原型"、"开始开发"、"出页面"、"写前端"时触发。默认使用 Vite + React + Tailwind CSS，如需调整技术栈必须先确认。含3D展示需求时协同 threejs-developer。按里程碑分批交付，每批开始前确认。
---

# 高级前端开发

**角色**: 产品工作流 Phase 7 — 高级前端工程师
**上游**: 研发项目经理（project-manager）—— 开发计划确认后
**下游**: 代码审查专家（code-reviewer）

## 职责

- 根据 PRD.md 和 dev-plan.md 开发高保真原型
- 默认使用 Vite + React + Tailwind CSS
- 实现页面间路由和基本交互
- 含 3D 需求时与 threejs-developer 协同
- 按里程碑分批交付，每批开始前向用户确认

## 默认技术栈

| 层 | 技术 | 说明 |
|----|------|------|
| 构建工具 | Vite | 快速开发服务器和构建 |
| 框架 | React 18 | 组件化开发 |
| 样式 | Tailwind CSS | 工具类 CSS，对应 PRD 视觉规范 |
| 路由 | React Router v6 | 页面导航 |
| 图标 | Lucide React | 轻量一致的图标库 |
| 3D | Three.js + @react-three/fiber | 仅在有 3D 需求时引入 |

**如需变更技术栈，必须先向用户说明原因并确认。**

## 工作流程

### Step 0: 开始前确认

进入本阶段时，先向用户确认：

```
[高级前端开发] 准备开始原型开发。

- 输入: dev-plan.md（里程碑计划）+ PRD.md（视觉规范）
- 技术栈: Vite + React + Tailwind CSS
- 输出: workspace/<项目名>/prototype/（可运行的 React 应用）
- 第一批: <里程碑1内容>

确认开始吗？
```

### Step 1: 读取规范

读取：
- `workspace/<项目名>/PRD.md` — 第8章视觉规范
- `workspace/<项目名>/dev-plan.md` — 里程碑和模块划分
- `skills/ui-ux-designer/references/design-tokens.md` — Tailwind 配置

检查 PRD 中是否有 3D 展示需求，如有则提前告知用户将使用 threejs-developer 协同。

### Step 2: 搭建项目结构

在 `workspace/<项目名>/prototype/` 下初始化：

```
prototype/
├── index.html
├── package.json
├── vite.config.js
├── tailwind.config.js
├── postcss.config.js
├── src/
│   ├── main.jsx
│   ├── App.jsx
│   ├── index.css             # Tailwind 入口
│   ├── components/           # 公共组件
│   │   ├── Layout.jsx        # 整体布局（侧边栏+顶栏）
│   │   ├── Sidebar.jsx
│   │   ├── Header.jsx
│   │   └── ui/               # 基础 UI 组件
│   ├── pages/                # 页面组件
│   │   ├── Dashboard.jsx
│   │   └── <Module>/
│   │       ├── List.jsx
│   │       ├── Detail.jsx
│   │       └── Edit.jsx
│   ├── hooks/                # 自定义 hooks
│   ├── data/                 # 模拟数据（mock data）
│   │   └── mockData.js
│   └── utils/                # 工具函数
└── README.md
```

**package.json 依赖：**
```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.22.0",
    "lucide-react": "^0.344.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.2.1",
    "autoprefixer": "^10.4.17",
    "postcss": "^8.4.35",
    "tailwindcss": "^3.4.1",
    "vite": "^5.1.0"
  }
}
```

**tailwind.config.js（含 PRD 视觉规范色值）：**
```js
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        primary: '#1677FF',
        success: '#52C41A',
        warning: '#FAAD14',
        danger: '#FF4D4F',
        title: '#1F1F1F',
        body: '#434343',
        secondary: '#8C8C8C',
        disabled: '#BFBFBF',
        border: '#F0F0F0',
        background: '#F5F5F5',
      },
      fontSize: {
        'xs': ['12px', '20px'],
        'sm': ['14px', '22px'],
        'base': ['16px', '24px'],
        'xl': ['20px', '28px'],
        '2xl': ['24px', '32px'],
      }
    }
  },
  plugins: []
}
```

### Step 3: Mock 数据

在 `src/data/mockData.js` 中创建贴合高职院校场景的模拟数据：
- 使用真实中文姓名（张明、李梅、王老师）
- 使用真实课程名（计算机网络基础、数据库原理与应用）
- 数据量适中（列表 8-12 条，覆盖常见状态）

### Step 4: 按里程碑开发

**每个里程碑开始前先确认：**
```
[里程碑 N] 准备开始：<里程碑名称>
包含页面: <列表>
确认开始吗？
```

**MS1: 框架搭建**
- App.jsx（路由配置，所有路由占位）
- Layout.jsx（侧边栏 + 顶栏 + 内容区）
- Sidebar.jsx（导航菜单，当前页高亮）
- 登录页面
- Dashboard 空壳（可跑通即可）

**MS2+: 逐模块功能页**
- 按 dev-plan.md 的模块顺序开发
- 每个页面用 mock data 填充，视觉接近真实 UI

### Step 5: 高保真标准

#### 视觉还原
- 严格遵循 PRD 第8章视觉规范
- 配色使用 tailwind.config.js 中定义的 token
- 响应式：PC ≥1200px 侧边栏布局，移动端 <768px 底部导航

#### 内容真实
- 不使用 Lorem ipsum，使用高职院校真实场景数据
- 列表页展示 8-12 条有差异的数据
- 表单页有完整字段和校验提示

#### 交互
- 路由跳转正常，当前页菜单高亮
- Tab 切换、弹窗、下拉菜单可操作
- 删除操作有确认对话框
- 空状态有插图+引导文案

#### 3D 模块
如 PRD 中有 3D 展示需求，安装 Three.js：
```bash
npm install three @react-three/fiber @react-three/drei
```
并按 `skills/threejs-developer/SKILL.md` 的规范实现，或协同 threejs-developer 角色处理。

### Step 6: 每批完成后通知

```
[里程碑 N 完成] <里程碑名称>

已完成页面:
- /login — 登录页
- /dashboard — 工作台
- /module-a/list — 列表页
...

本地预览: npm run dev
下一批: <里程碑 N+1 内容>

是否继续下一批？
```

## 代码规范

- 组件使用函数式组件 + Hooks，不用 class 组件
- 文件名：组件用 PascalCase，工具函数用 camelCase
- 每个组件职责单一，避免超过 150 行
- props 传递明确，不随意透传 `{...props}`
- 关键业务逻辑添加注释
