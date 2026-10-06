#!/bin/bash
# PostToolUse hook. Formats and lints the edited file through the language adapter.
# Exit 2 sends the problems back to Claude; every other path exits 0.

source "$(dirname "$0")/protected-paths.sh"

command -v jq >/dev/null 2>&1 || exit 0

file=$(cat | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$file" ] && exit 0
[ -f "$file" ] || exit 0

# Reason: a lost execute bit on the global adapter would block every edit.
adapter=(bash "$(dirname "$0")/../scripts/quality.sh")
project=$(project_adapter "${CLAUDE_PROJECT_DIR:-$PWD}") && adapter=("$project")

"${adapter[@]}" format "$file" >/dev/null 2>&1
out=$("${adapter[@]}" lint "$file" 2>&1) && exit 0

printf 'Format or lint problems in %s. Fix them before continuing.\n%s\n' "$file" "$out" >&2
printf 'See rules/code-quality.md and the guide for this language.\n' >&2
exit 2
