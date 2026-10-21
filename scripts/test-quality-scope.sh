#!/bin/bash
# Regression test for the quality gate's file scope. Exit 0 when every case passes.
set -uo pipefail

home="$(cd "$(dirname "$0")/.." && pwd)"
fails=0

result() {
  if [ "$1" -eq 0 ]; then
    echo "ok    $2"
  else
    echo "FAIL  $2"
    fails=$((fails + 1))
  fi
}

# Prints a new repo whose committed adapter logs each call to calls.log and passes.
adapter_repo() {
  local repo
  repo=$(mktemp -d)
  git -C "$repo" init -q
  mkdir -p "$repo/.claude"
  printf '#!/bin/bash\necho "$*" >> "%s/calls.log"\nexit 0\n' "$repo" > "$repo/.claude/quality.sh"
  chmod +x "$repo/.claude/quality.sh"
  printf 'calls.log\n' > "$repo/.gitignore"
  [ $# -gt 0 ] && printf '%s\n' "$@" > "$repo/.claude/quality-ignore"
  git -C "$repo" add -A && git -C "$repo" -c user.name=t -c user.email=t@t commit -qm init
  mkdir -p "$repo/src" "$repo/.claude/skills/tool" "$repo/tools"
  echo 'x' > "$repo/src/app.ts"
  echo 'x' > "$repo/.claude/skills/tool/run.py"
  echo 'x' > "$repo/tools/gen.py"
  echo "$repo"
}

repo=$(adapter_repo 'tools/*')
printf '{}' | CLAUDE_PROJECT_DIR="$repo" bash "$home/hooks/stop-gate.sh" 2>/dev/null
calls=$(cat "$repo/calls.log" 2>/dev/null)
grep -q 'src/app.ts' <<< "$calls"
result $? "stop gate checks src/app.ts"
! grep -q 'skills/tool/run.py' <<< "$calls"
result $? "stop gate skips .claude/skills by default"
! grep -q 'tools/gen.py' <<< "$calls"
result $? "stop gate skips a path in .claude/quality-ignore"

repo=$(adapter_repo)
printf '{"tool_input":{"command":"git commit -m x"}}' |
  CLAUDE_PROJECT_DIR="$repo" bash "$home/hooks/commit-gate.sh" >/dev/null 2>&1
! grep -q '^lint .*skills/tool/run.py' "$repo/calls.log"
result $? "commit gate does not lint .claude/skills"

source "$home/hooks/protected-paths.sh"
is_protected "$repo" .claude/quality-ignore
result $? "the ignore list is protected"

# Prints a new repo with fake mypy and pytest that log to calls.log and fail.
python_repo() {
  local repo tool
  repo=$(mktemp -d)
  mkdir -p "$repo/.venv/bin" "$repo/tests/unit"
  for tool in mypy pytest; do
    printf '#!/bin/bash\necho %s >> "%s/calls.log"\nexit 1\n' "$tool" "$repo" > "$repo/.venv/bin/$tool"
    chmod +x "$repo/.venv/bin/$tool"
  done
  touch "$repo/tests/unit/test_a.py" "$repo/run.py"
  echo "$repo"
}

repo=$(python_repo)
CLAUDE_PROJECT_DIR="$repo" bash "$home/scripts/quality.sh" check run.py >/dev/null 2>&1
result $? "check passes a .py file in a project with no Python config"
[ ! -s "$repo/calls.log" ]
result $? "check runs no mypy or pytest without Python config"

repo=$(python_repo)
touch "$repo/pyproject.toml"
CLAUDE_PROJECT_DIR="$repo" bash "$home/scripts/quality.sh" check run.py >/dev/null 2>&1
[ $? -ne 0 ] && grep -q mypy "$repo/calls.log"
result $? "check runs mypy in a project with pyproject.toml"

[ "$fails" -eq 0 ]
