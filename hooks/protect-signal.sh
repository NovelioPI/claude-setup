#!/bin/bash
# PreToolUse hook. Blocks edits to existing files that match a protected pattern
# (.claude/protected-paths, or the defaults), and creation of a file a pattern names exactly.
# TASK_MODE=tests lifts the block.

source "$(dirname "$0")/protected-paths.sh"

block() {
  echo "BLOCKED: $1" >&2
  exit 2
}

command -v jq >/dev/null 2>&1 || block "jq is missing, so protect-signal.sh cannot check this edit."
file=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty') ||
  block "the hook input is not valid JSON, so protect-signal.sh cannot check this edit."
[ -z "$file" ] && exit 0
[ "${TASK_MODE:-impl}" = "tests" ] && exit 0

root=$(normalize "${CLAUDE_PROJECT_DIR:-$PWD}")
case "$file" in /*) ;; *) file="$root/$file" ;; esac
path=$(normalize "$file")

# Reason: a write through a broken symlink lands in the protected tree, so it counts as existing.
matcher=is_protected_new
[ -e "$path" ] || [ -L "$path" ] && matcher=is_protected

# Blocks when path $2, inside directory $1, matches a protected pattern.
check() {
  case "$2" in "$1"/*) ;; *) return 0 ;; esac
  local rel=${2#"$1"/}
  "$matcher" "$root" "$rel" &&
    block "$rel is part of the verification signal and is read-only in this session. If it looks wrong, stop and explain why instead of editing it. Start the session with TASK_MODE=tests to change it."
  return 0
}

check "$root" "$path"
# Reason: a symlink can point into the protected tree, so the resolved path is checked too.
real=$(realpath "$path" 2>/dev/null) && real_root=$(realpath "$root" 2>/dev/null) &&
  check "$real_root" "$real"
exit 0
