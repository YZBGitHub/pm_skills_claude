# PORTABILITY.md — 跨 IDE 移植清单

> 本工作流原生为 Claude Code 设计，但通过分层结构可在多种 AI 编码工具中运行。本文档说明每种工具的最小可用方案。

## 设计原则

1. **核心层 IDE 无关** — `rules/`、`skills/*/SKILL.md`、`workspace/` 是纯 Markdown / JSON，任意 IDE 都能读
2. **驱动层 IDE 专属** — `.claude/agents/`、`.claude/commands/`、`.claude/hooks/` 是 Claude Code 的 harness 配置
3. **入口层双轨** — `CLAUDE.md`（Claude Code）+ `AGENTS.md`（其他 IDE）

## 文件分类

| 分类 | 路径 | IDE 兼容性 |
|------|------|-----------|
| 入口（Claude Code） | `CLAUDE.md` | 仅 Claude Code 自动加载 |
| 入口（通用） | `AGENTS.md` | Codex / Cursor / Antigravity / OpenCode / Aider 等自动加载 |
| 通用规则 | `rules/*.md` | 所有 IDE，手动 `@` 引用 |
| 角色定义 | `skills/*/SKILL.md` | 所有 IDE，手动引用 |
| 角色 harness | `.claude/agents/*.md` | 仅 Claude Code |
| Slash commands | `.claude/commands/*.md` | 仅 Claude Code（少数 IDE 部分支持） |
| Hooks | `.claude/hooks/*.sh` | 仅 Claude Code |
| 插件清单 | `.claude-plugin/plugin.json` | 仅 Claude Code |
| 项目产物 | `workspace/<项目>/...` | 所有 IDE |

## 各 IDE 移植说明

### OpenAI Codex / Codex CLI

**支持情况**：✅ AGENTS.md 自动加载；❌ subagent / hooks / slash 不支持

**使用流程**：
1. 工程根目录已有 `AGENTS.md`，Codex 启动时自动读取
2. 在每个新会话开头补一句：`请同时读取 rules/principles.md, rules/workflow.md, rules/general.md`
3. 触发某个角色时显式说："切换到 `skills/prd-specialist/SKILL.md` 角色，按其定义执行"
4. 评审时**新开 Codex 会话**避免上下文污染（subagent 不可用）

**已知限制**：
- 评审独立性靠开新会话保证，工作流不会自动隔离
- 变更通道（tweak/small/real）需要手动判定，没有 `/change` 命令
- 阶段交接没有 `/handoff` 校验，要靠纪律性

### Antigravity

**支持情况**：✅ AGENTS.md；部分支持 skill 加载

**使用流程**：与 Codex 类似，AGENTS.md + 手动引用 rules

### OpenCode

**支持情况**：✅ AGENTS.md；部分支持 slash command（自定义协议）

**额外建议**：可把 `.claude/commands/*.md` 复制一份到 OpenCode 自己的命令目录（如适用），并改写为 OpenCode 的 frontmatter 格式

### Cursor

**支持情况**：✅ AGENTS.md（Cursor 支持 .cursor/rules 与 AGENTS.md 双轨）

**额外建议**：可把 `rules/*.md` 软链到 `.cursor/rules/` 让 Cursor 自动加载

### Aider

**支持情况**：✅ AGENTS.md；命令式交互

**使用流程**：用 `/read rules/principles.md` 等命令显式加载

## 跨 IDE 缺失能力的等价方案

| Claude Code 能力 | 跨 IDE 等价方案 |
|----|----|
| Subagent 隔离上下文（评审、子任务） | 开新会话 / 新 git worktree |
| Slash command（`/prd` `/review-prd` `/handoff` `/change`） | 把命令文件作为"模板提示词"手动粘贴 |
| PreToolUse hook（guard-write） | 团队约定 + code review |
| SessionStart hook（注入项目状态） | 会话开头手动跑 `cat workspace/*/state.json` |
| PostToolUse hook（PRD 章节校验） | 提交前手动检查 |
| `.claude-plugin/plugin.json` 一键分发 | 用 git submodule / npm package 分发整个 repo |

## 最小可用 checklist（任意 IDE）

要在新 IDE 上跑通一遍工作流，至少做到：

- [ ] AGENTS.md 已被 IDE 识别（看启动日志）
- [ ] 会话开头能 `@` 引用 rules/*.md
- [ ] 能按角色 SKILL.md 切换"人格"
- [ ] 能在 workspace/ 下读写文件
- [ ] 评审阶段使用新会话

## 不可移植的部分（坦诚清单）

| 能力 | 为什么 |
|------|--------|
| `guard-write.sh` 写入保护 | hook 仅 Claude Code 支持，需团队纪律替代 |
| `.state.json` 自动维护 | 无 hook 自动同步，需角色自觉 |
| Plugin 版本锁定 | 仅 Claude Code 插件机制 |
| frontend-design skill 自动协同 | skill 自动激活需 Claude Code，其他 IDE 需手动调用 |
