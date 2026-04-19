#!/usr/bin/env bash
# PreToolUse hook for Write/Edit: enforce write-path conventions.
# - BLOCK writes to rules/, skills/*/SKILL.md, root CLAUDE.md (must be manual)
# - WARN (non-blocking) writes outside workspace/ and .claude/
#
# Exit codes:
#   0  → allow; stderr shown as transcript warning
#   2  → block; stderr fed back to Claude as tool error
set -e

input=$(cat)

file_path=$(printf '%s' "$input" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    ti = d.get('tool_input', {})
    # Write uses 'file_path'; Edit uses 'file_path' too
    print(ti.get('file_path', ''))
except Exception:
    print('')
" 2>/dev/null)

[ -z "$file_path" ] && exit 0

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"

# Normalize: strip project root prefix → relative path
case "$file_path" in
  /*) rel="${file_path#$PROJECT_ROOT/}" ;;
  *)  rel="$file_path" ;;
esac

# ---- BLOCK zone: protected files that must be hand-edited ----
case "$rel" in
  rules/*)
    echo "[hook/BLOCK] 拒绝写入 rules/ —— 全局规则必须人工修改。若确需改动，请让用户确认或直接编辑。" >&2
    exit 2
    ;;
  skills/*/SKILL.md)
    echo "[hook/BLOCK] 拒绝写入 $rel —— SKILL 定义必须人工修改。" >&2
    exit 2
    ;;
  CLAUDE.md)
    echo "[hook/BLOCK] 拒绝写入根 CLAUDE.md —— 项目主规则必须人工修改。" >&2
    exit 2
    ;;
esac

# ---- WARN zone: non-canonical write locations ----
case "$rel" in
  workspace/*) : ;;                 # canonical产物目录
  .claude/*)   : ;;                 # harness 自身配置
  README.md)   : ;;                 # 允许
  skills-lock.json) : ;;
  *)
    echo "[hook/WARN] 写入 $rel 不在 workspace/ 下。若为项目产物，应放在 workspace/<项目名>/；继续执行但请核实。" >&2
    ;;
esac

exit 0
