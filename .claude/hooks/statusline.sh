#!/usr/bin/env bash
# Statusline: show current project · stage · role
# Reads workspace/<project>/.state.json; falls back to most-recent subdir.
set -e

# Drain stdin (Claude Code sends session JSON here)
input=$(cat 2>/dev/null || true)

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
# If stdin has cwd, prefer it
if [ -n "$input" ]; then
  maybe_cwd=$(printf '%s' "$input" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('workspace', {}).get('current_dir', '') or d.get('cwd', ''))
except Exception:
    print('')
" 2>/dev/null || true)
  [ -n "$maybe_cwd" ] && PROJECT_ROOT="$maybe_cwd"
fi

WS="$PROJECT_ROOT/workspace"

if [ ! -d "$WS" ]; then
  printf "pm-skills · no workspace"
  exit 0
fi

# Most recently modified .state.json wins
current_state=$(ls -t "$WS"/*/.state.json 2>/dev/null | head -1 || true)

if [ -n "$current_state" ] && [ -f "$current_state" ]; then
  project_dir=$(dirname "$current_state")
  name=$(basename "$project_dir")
  line=$(python3 -c "
import json
try:
    d = json.load(open('$current_state'))
    stage = d.get('stage', '?')
    role = d.get('owner_role', '')
    out = f'{stage}'
    if role:
        out += f' · {role}'
    print(out)
except Exception:
    print('?')
" 2>/dev/null)
  printf "pm-skills · %s · %s" "$name" "$line"
  exit 0
fi

# Fallback: most recent subdir, infer stage from files
recent_dir=$(ls -td "$WS"/*/ 2>/dev/null | head -1 || true)
if [ -z "$recent_dir" ]; then
  printf "pm-skills · idle (no projects)"
  exit 0
fi

name=$(basename "$recent_dir")
stage="unknown"
[ -f "$recent_dir/PRD.md" ]       && stage="prd/design"
[ -f "$recent_dir/dev-plan.md" ]  && stage="plan"
[ -d "$recent_dir/prototype" ]    && stage="prototype"

printf "pm-skills · %s · %s (no .state.json)" "$name" "$stage"
