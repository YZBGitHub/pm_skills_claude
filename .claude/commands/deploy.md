---
description: 部署原型到指定平台（独立流程，不耦合任何评审/审核角色）
argument-hint: <项目名> <平台名>
---

部署 `workspace/<项目名>/prototype/` 到用户指定的平台。

输入参数：$ARGUMENTS

---

## 设计意图

部署独立成命令，**不归任何 skill 角色管**。理由：
- 之前 release-engineer 把"代码审查 + 部署"绑在一起，实际跑下来代码审查环节用处不大，但部署仍然有用
- 拆开后：末端审核走 `prototype-auditor`（极轻），部署走 `/deploy`（用户主动触发）
- 部署平台高度因团队 / 项目而异（自建服务器 / 对象存储 / Vercel / Netlify / 校园内网），写死在 skill 里反而限制

## 第一步：参数校验

- 若未提供项目名，要求用户补充
- 若未提供平台名，列出常见选项（Vercel / Netlify / 静态服务器 / 校园内网 / 对象存储 / 其他）让用户指定
- 若 `workspace/<项目名>/prototype/package.json` 不存在，停止并提示先跑 `/build <项目名>`

## 第二步：前置确认

```
[部署] 准备部署 <项目名> 到 <平台名>。
- 项目路径: workspace/<项目名>/prototype/
- 构建命令: npm run build
- 输出: dist/
- 平台: <平台名>
- 是否需要域名 / SSL / 校内 DNS 配置？

确认部署吗？(Y / N / 调整)
```

**强制规则**：未得到用户明确 Y 之前，**不执行任何 npm run build / 上传 / 推送**。

## 第三步：构建

```bash
cd workspace/<项目名>/prototype
npm install
npm run build
```

构建产物在 `dist/`。如果构建失败，停止并把完整错误返回给用户，**不尝试自动修复代码**（修代码是 frontend-developer 的事）。

## 第四步：按平台执行部署

| 平台 | 命令模板（请按用户实际配置调整） |
|------|--------|
| Vercel | `vercel --prod` 或 GitHub 集成自动触发 |
| Netlify | `netlify deploy --prod --dir=dist` |
| 静态服务器（rsync） | `rsync -avz dist/ user@host:/var/www/<项目>/` |
| 对象存储（OSS/COS/S3） | 按各家 CLI，如 `ossutil cp -r dist/ oss://bucket/path/` |
| 校园内网 | 通常走运维交付流程，输出 dist 包给运维即可 |
| GitHub Pages | `gh-pages -d dist` |

未列出的平台，询问用户提供命令模板，**不要凭空猜测**。

## 第五步：部署后回执

```markdown
## 部署回执 · <项目名>

- 平台: <平台名>
- 构建时间: YYYY-MM-DD HH:MM
- 部署 URL: https://...
- 构建产物大小: XXX KB
- 状态: 成功 / 失败

### 用户验证清单（部署后请人工抽查）
- [ ] 首页可访问
- [ ] 主导航跳转正常
- [ ] 静态资源加载正常（图片 / 字体 / 图标）
- [ ] 移动端打开无明显错位
```

## 第六步：更新 .state.json

```json
{
  "project": "<项目名>",
  "stage": "deployed",
  "owner_role": null,
  "last_updated": "<ISO8601>",
  "deploy_target": "<平台名>",
  "deploy_url": "https://..."
}
```

## 红线

- **未确认平台不动手**：默认询问而非默认 Vercel
- **构建失败不擅自改代码**：返回错误给用户，由 frontend-developer 修
- **不做 `git push --force`**：任何分支都不
- **不写敏感信息**：API token / SSH key 不写入 repo，靠环境变量或本机配置
- **`rm -rf` 范围严格限定**：只能在 `dist/` 内部，绝不触碰 `workspace/`
- **校园内网部署优先走运维流程**：直接交付 dist 包，不擅自登录服务器
