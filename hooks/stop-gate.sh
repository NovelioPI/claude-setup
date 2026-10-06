#!/bin/bash
# Stop hook. Type-checks changed files and runs unit tests before a turn ends.
# Blocks once with exit 2; the second attempt always passes.

source "$(dirname "$0")/protected-paths.sh"

command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
[ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false')" = "true" ] && exit 0

# Reason: $0 can be relative, so the adapter path is resolved before the cd.
adapter=(bash "$(cd "$(dirname "$0")/.." && pwd)/scripts/quality.sh")
cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
# Reason: /handoff runs with red tests, so its skip file lets one turn end, never a commit.
if [ "${GATE_CONTEXT:-stop}" != commit ] && [ -f .agent/.skip-gate ]; then
  rm -f .agent/.skip-gate
  exit 0
fi

mapfile -t changed < <(
  git diff --relative --name-only --diff-filter=d HEAD 2>/dev/null
  git ls-files --others --exclude-standard
)
[ "${#changed[@]}" -eq 0 ] && exit 0

project=$(project_adapter "$PWD") && adapter=("$project")

out=$("${adapter[@]}" check "${changed[@]}" 2>&1) && exit 0

printf 'Quality gate failed. Report this failure; fix it only inside an approved plan. Do not edit tests to pass.\n%s\n' "$out" >&2
exit 2
