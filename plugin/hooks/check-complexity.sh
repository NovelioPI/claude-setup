#!/bin/bash
# PostToolUse hook. Reports cognitive complexity and nesting depth on a changed
# Python file. Exit 2 sends the message back to Claude; every other path exits 0.

command -v jq >/dev/null 2>&1 || exit 0
command -v uvx >/dev/null 2>&1 || exit 0

file=$(cat | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$file" ] && exit 0
[ -f "$file" ] || exit 0
case "$file" in
  *.py) ;;
  *) exit 0 ;;
esac

MAX_COGNITIVE=15
out=""

cog=$(uvx complexipy --plain --failed --max-complexity-allowed "$MAX_COGNITIVE" \
      "$file" 2>&1) || out="$cog"

nest=$(uvx ruff check --isolated --preview --select PLR1702 "$file" 2>&1) \
      || out="$out"$'\n'"$nest"

[ -z "$out" ] && exit 0

printf 'Complexity limit exceeded in %s.\n%s\n' "$file" "$out" >&2
printf 'See the Complexity section of rules/code-quality.md.\n' >&2
exit 2
