#!/bin/bash
# Stop hook. Type-checks changed files and runs unit tests before a turn ends.
# Blocks once with exit 2; the second attempt always passes.

command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
[ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false')" = "true" ] && exit 0

cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
# Reason: /handoff runs with red tests, so its skip file lets one turn end.
if [ -f .agent/.skip-gate ]; then
  rm -f .agent/.skip-gate
  exit 0
fi

changed() {
  git diff --name-only --diff-filter=d HEAD -- "$@" 2>/dev/null
  git ls-files --others --exclude-standard -- "$@"
}

# Reason: uvx has no project libraries, so only the project's own tools run.
project_tool() {
  if [ -x ".venv/bin/$1" ]; then
    echo ".venv/bin/$1"
  else
    command -v "$1"
  fi
}

out=""

run() {
  local result
  result=$("$@" 2>&1) || out="$out"$'\n'"\$ $*"$'\n'"$(printf '%s' "$result" | tail -40)"
}

mapfile -t py < <(changed '*.py')
if [ "${#py[@]}" -gt 0 ]; then
  mypy=$(project_tool mypy)
  pytest=$(project_tool pytest)
  [ -n "$mypy" ] && run "$mypy" "${py[@]}"
  # Reason: pytest exits 5 when no test file exists, which is not a failure.
  if [ -n "$pytest" ] && [ -n "$(find tests/unit -name 'test_*.py' 2>/dev/null | head -1)" ]; then
    run "$pytest" -q -x tests/unit
  fi
fi

mapfile -t ts < <(changed '*.ts' '*.tsx' '*.js' '*.jsx')
if [ "${#ts[@]}" -gt 0 ] && [ -f tsconfig.json ] && [ -x node_modules/.bin/tsc ]; then
  run node_modules/.bin/tsc --noEmit
fi

mapfile -t dart < <(changed '*.dart')
if [ "${#dart[@]}" -gt 0 ] && command -v dart >/dev/null 2>&1; then
  run dart analyze "${dart[@]}"
fi

[ -z "$out" ] && exit 0

printf 'Quality gate failed. Fix before finishing; do not edit tests to pass.\n%s\n' "$out" >&2
exit 2
