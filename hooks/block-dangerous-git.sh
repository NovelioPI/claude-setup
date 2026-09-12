#!/bin/bash
# PreToolUse(Bash) guardrail. Exit 2 blocks the command.
# Fails closed: a missing jq blocks every Bash call rather than allowing every one.

INPUT=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  echo "BLOCKED: git guardrail cannot run because jq is not installed." >&2
  exit 2
fi

COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

DANGEROUS_PATTERNS=(
  'git[[:space:]]+reset[[:space:]].*--hard'
  'git[[:space:]]+clean[[:space:]].*(-[^[:space:]]*f|--force)'
  'git[[:space:]]+branch[[:space:]].*-D'
  'git[[:space:]]+checkout[[:space:]]+\.([[:space:]]|$)'
  'git[[:space:]]+restore[[:space:]]+\.([[:space:]]|$)'
)

# Match each chained segment at its own start, so a dangerous string quoted
# inside another command (a commit message, an echo) does not trip the hook.
SEGMENTS=$(printf '%s' "$COMMAND" | sed -E 's/(\|\||&&|;|\|)/\n/g')

while IFS= read -r segment; do
  for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if printf '%s' "$segment" | grep -qE "^[[:space:]]*(sudo[[:space:]]+)?(${pattern})"; then
      echo "BLOCKED: '${COMMAND}' matches the guarded pattern '${pattern}'. The user has not given you authority to run this." >&2
      exit 2
    fi
  done
done <<< "$SEGMENTS"

exit 0
