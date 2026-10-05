#!/bin/bash
# PreCompact hook: save git state and the full transcript before auto-compact.
# Runs only in a project that has run /handoff once, so .agent/ exists.

INPUT=$(cat)
cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 0
[ -d .agent ] || exit 0

mkdir -p .agent/snapshots
STAMP=$(date +%Y%m%d-%H%M%S)

if command -v jq >/dev/null 2>&1; then
  TRANSCRIPT=$(printf '%s' "$INPUT" | jq -r '.transcript_path // empty')
  [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ] && cp "$TRANSCRIPT" ".agent/snapshots/$STAMP.jsonl"
fi

git rev-parse --git-dir >/dev/null 2>&1 || exit 0
{
  echo "# Pre-compact snapshot $STAMP"
  echo "## Uncommitted changes"; git status --short
  echo "## Diff stat"; git diff --stat
  echo "## Recent commits"; git log --oneline -10
} > .agent/snapshot.md
exit 0
