#!/bin/bash
# PostToolUse hook. Formats the edited file and applies lint autofixes through the language adapter.
# Never blocks: lint problems and limits are checked once, by commit-gate.sh.

source "$(dirname "$0")/protected-paths.sh"

command -v jq >/dev/null 2>&1 || exit 0

file=$(cat | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$file" ] && exit 0
[ -f "$file" ] || exit 0

# Reason: a lost execute bit on the global adapter would block every edit.
adapter=(bash "$(dirname "$0")/../scripts/quality.sh")
project=$(project_adapter "${CLAUDE_PROJECT_DIR:-$PWD}") && adapter=("$project")

"${adapter[@]}" format "$file" >/dev/null 2>&1
# Reason: a block after each edit made Claude refactor mid-task, so lint output waits for the commit.
"${adapter[@]}" lint "$file" >/dev/null 2>&1
exit 0
