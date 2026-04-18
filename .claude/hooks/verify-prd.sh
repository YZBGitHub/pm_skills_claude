#!/usr/bin/env bash
# PostToolUse hook for Write/Edit: validate PRD.md structure (sections 1-9).
# Only acts on workspace/*/PRD.md. Warns (exit 0 + stderr); does not block.
set -e

input=$(cat)

file_path=$(printf '%s' "$input" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    ti = d.get('tool_input', {})
    print(ti.get('file_path', ''))
except Exception:
    print('')
" 2>/dev/null)

# Only scope: PRD.md inside workspace/
case "$file_path" in
  */workspace/*/PRD.md) : ;;
  *) exit 0 ;;
esac

[ ! -f "$file_path" ] && exit 0

declare -a titles=(
  "1. 需求背景与目标"
  "2. 用户画像与场景分析"
  "3. 功能需求"
  "4. 非功能需求"
  "5. 数据埋点方案"
  "6. 边界Case与异常处理"
  "7. 用户故事与验收标准"
  "8. 交互规范与视觉规范"
  "9. 变更记录"
)

missing=()
for i in 1 2 3 4 5 6 7 8 9; do
  # Match "## N." at line start (tolerate Chinese/English variants around it)
  if ! grep -qE "^##[[:space:]]+${i}\." "$file_path"; then
    missing+=("${titles[$((i-1))]}")
  fi
done

if [ ${#missing[@]} -gt 0 ]; then
  echo "[hook/PRD-LINT] $file_path 缺少章节：" >&2
  for t in "${missing[@]}"; do
    echo "  - $t" >&2
  done
  echo "按 rules/workflow.md 规范，完整 PRD 需包含 1-9 章。阶段未完成属正常；完稿前请补齐。" >&2
fi

exit 0
