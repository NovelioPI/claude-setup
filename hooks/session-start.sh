#!/bin/bash
# SessionStart hook: print the saved working state into the new context.
# Runs only in a project that has run /handoff once, so .agent/ exists.

INPUT=$(cat)
cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 0
[ -d .agent ] || exit 0
rm -f .agent/.skip-gate

# Reason: an uncapped print refills the context that /clear just freed.
echo "=== Restored working state ==="
[ -f .agent/progress.md ] && head -c 6000 .agent/progress.md
echo; echo "=== Tasks ==="
echo "Built-in Tasks persist across compaction; list the open ones before continuing."
echo; echo "=== Git ==="
SOURCE=""
command -v jq >/dev/null 2>&1 && SOURCE=$(printf '%s' "$INPUT" | jq -r '.source // empty')
# Reason: snapshot.md is written only before an auto-compact, so after any other start it is old.
if [ "$SOURCE" = "compact" ] && [ -f .agent/snapshot.md ]; then
  head -c 3000 .agent/snapshot.md
elif git rev-parse --git-dir >/dev/null 2>&1; then
  { git status --short; git log --oneline -5; } | head -c 3000
fi
exit 0
