# 前端技术规范（Frontend Rules）

> 本文件定义前端技术栈、代码规范、开发流程，由 frontend-developer 和 release-engineer 遵循。

## 默认技术栈

| 层 | 技术 | 说明 |
|----|------|------|
| 构建工具 | Vite | 快速开发服务器和构建 |
| 框架 | React 18 | 组件化开发 |
| 样式 | Tailwind CSS | 工具类 CSS，对应 PRD 视觉规范 |
| 路由 | React Router v6 | 页面导航 |
| 图标 | Lucide React | 轻量一致的图标库 |
| 3D | Three.js + @react-three/fiber | 仅在有 3D 需求时引入 |

**技术栈变更规则**: 如需使用其他框架（Vue/Svelte/Next.js 等），必须先向用户说明原因并确认。

## package.json 基准依赖

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

## tailwind.config.js 基准配置

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

## 标准项目结构

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
│   ├── components/
│   │   ├── Layout.jsx        # 整体布局（侧边栏+顶栏）
│   │   ├── Sidebar.jsx
│   │   ├── Header.jsx
│   │   └── ui/               # 基础 UI 组件
│   ├── pages/
│   │   ├── Dashboard.jsx
│   │   └── <Module>/
│   │       ├── List.jsx
│   │       ├── Detail.jsx
│   │       └── Edit.jsx
│   ├── hooks/
│   ├── data/
│   │   └── mockData.js
│   └── utils/
└── README.md
```

## 代码规范

- **组件**: 函数式组件 + Hooks，不用 class 组件
- **文件命名**: 组件用 PascalCase（`Sidebar.jsx`），工具函数用 camelCase（`formatDate.js`）
- **组件体积**: 每个组件不超过 150 行
- **Props 传递**: 明确，不随意透传 `{...props}`
- **注释**: 关键业务逻辑必须添加注释，不做过度注释
- **清理**: 提交前移除 `console.log`、未使用变量

## Mock 数据规范

贴合高职院校场景：
- 使用真实中文姓名（张明、李梅、王老师）
- 使用真实课程名（计算机网络基础、数据库原理与应用）
- 数据量适中（列表 8-12 条，覆盖常见状态）
- 不使用 Lorem ipsum

## 高保真标准

### 视觉还原
- 严格遵循 PRD 第 8 章视觉规范
- 配色使用 tailwind.config.js 中定义的 token
- 响应式：PC ≥1200px 侧边栏布局，移动端 <768px 底部导航

### 交互完整性
- 路由跳转正常，当前页菜单高亮
- Tab 切换、弹窗、下拉菜单可操作
- 删除操作有确认对话框
- 空状态有插图+引导文案

### 响应式
- PC（≥1200px）: 侧边栏布局
- 平板（768-1199px）: 侧边栏折叠
- 手机（<768px）: 底部导航显示
- 触摸目标最小 44×44px
- 移动端避免 hover 依赖

## 3D 模块规范

PRD 中出现 3D 展示需求时，追加依赖：
```bash
npm install three @react-three/fiber @react-three/drei
```

规范：
- 3D 场景封装为独立组件（`src/components/three/`）
- 默认启用 `<Suspense>` + loading 兜底
- 移动端降级或隐藏 3D 展示

## 代码审查维度

| 维度 | 检查项 |
|------|--------|
| 代码质量 | 函数式组件、无 console.log、无重复、命名规范 |
| 视觉还原 | 配色/字体/间距/圆角/阴影与 PRD 一致 |
| 交互完整性 | 路由无死链、危险操作有确认、空状态处理 |
| 响应式适配 | PC/平板/移动三档正常 |
| 性能 | CDN 稳定版、依赖精简、图片合理 |
| 可访问性 | img 有 alt、input 关联 label、按钮有可识别文字 |

## Surgical Changes（外科手术式修复）

> 适用于 **release-engineer** 的审查回归阶段，以及 **frontend-developer** 的迭代阶段。
> 配套上位准则见 [principles.md](principles.md) §3。

**铁则**: 只动被点名的问题；**审查不是二次开发**。

| 情况 | 处理 |
|------|------|
| 6 维度命中的具体问题 | ✅ 在本次改动里修复 |
| 仅本次改动产生的孤立代码（unused import / 空函数） | ✅ 顺手清理 |
| 与本次问题无关的代码 smell（命名差、过度复杂、轻微死代码） | ❌ **不动** —— 写入 `workspace/<项目>/review-notes.md` |
| 全局重构念头（"整个目录都该重组"） | ❌ **不动** —— 起一个独立的 follow-up 任务，由用户决定排期 |
| 第三方依赖升级 | ❌ 必须先与用户确认 |

**review-notes.md 格式**:

```markdown
# Review Notes — <项目名>

## <YYYY-MM-DD> · 第 N 轮审查

### 本轮已修复
- [ ] <问题> @ src/path/file.jsx:42

### 暂不修复（写入 backlog）
- 原因 / 影响 / 建议处理时机
- 例：`Sidebar.jsx` 重复了 3 处菜单 className → 影响小，建议下次迭代统一抽 token
```

**违反 Surgical Changes 的典型反例**:
- 审查时把 PascalCase 的"瑕疵"全局批量改名 → ❌
- 改一个按钮文案时顺手优化整个页面布局 → ❌
- 修一个 a11y 问题时引入新的依赖 → ❌（必须先确认）
