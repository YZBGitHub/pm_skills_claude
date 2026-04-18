#!/usr/bin/env bash
# SessionStart hook: scan workspace/ and inject project status into context.
# stdout is added to Claude's context for this session.
set -e

cat > /dev/null 2>&1 || true   # drain stdin

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
WS="$PROJECT_ROOT/workspace"

echo "=== PM Skills · Workspace 状态 ==="

if [ ! -d "$WS" ]; then
  echo "（尚未创建 workspace/ 目录）"
  exit 0
fi

found=0
for dir in "$WS"/*/; do
  [ -d "$dir" ] || continue
  found=1
  name=$(basename "$dir")
  state_file="$dir.state.json"

  if [ -f "$state_file" ]; then
    python3 - "$name" "$state_file" <<'PY' 2>/dev/null || echo "  - $name · (.state.json 解析失败)"
import json, sys
name, path = sys.argv[1], sys.argv[2]
with open(path) as f:
    d = json.load(f)
stage = d.get("stage", "?")
role  = d.get("owner_role", "?")
upd   = d.get("last_updated", "?")
print(f"  - {name} · stage={stage} · role={role} · updated={upd}")
PY
  else
    stage="unknown"
    [ -f "$dir/PRD.md" ]       && stage="prd/design"
    [ -f "$dir/dev-plan.md" ]  && stage="plan"
    [ -d "$dir/prototype" ]    && stage="prototype"
    echo "  - $name · stage=$stage （无 .state.json，建议由 workflow-orchestrator 在阶段切换时写入）"
  fi
done

if [ $found -eq 0 ]; then
  echo "（workspace/ 为空，等待第一个项目需求输入）"
fi

echo "==========================================="
echo "提示：阶段切换时应更新 workspace/<项目>/.state.json（schema: project/stage/owner_role/last_updated）"
