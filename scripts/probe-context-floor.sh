#!/bin/bash
# Check the always-loaded context floor. Exit 0 pass, 1 fail, 2 skipped.
#
# Claude Code auto-loads every file under ~/.claude/rules/, with no pointer
# needed, into every session and every subagent. A file added there is paid for
# on every turn. Files read on demand belong in ~/.claude/guides/ instead.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
REPO=$(pwd)
FAILS=0
EXPECTED="code-quality.md commit-style.md doc-style.md plain-words.md"
MARKER="ZZFLOOR-$$-CANARY"

say()  { printf '  %-12s %s\n' "$1" "$2"; }
fail() { say "$1" "FAILED  $2"; FAILS=$((FAILS + 1)); }

# Reason: macOS ships no `timeout`; coreutils installs it as `gtimeout`.
if   command -v timeout  >/dev/null 2>&1; then LIMIT="timeout"
elif command -v gtimeout >/dev/null 2>&1; then LIMIT="gtimeout"
else LIMIT=""
fi
run() { if [ -n "$LIMIT" ]; then "$LIMIT" "$@"; else shift; "$@"; fi; }

echo "Context floor"

actual=$(ls -1 "$REPO/rules" | LC_ALL=C sort | tr '\n' ' ' | sed 's/ $//')
if [ "$actual" = "$EXPECTED" ]; then
  say "rules/" "4 files, as expected"
else
  fail "rules/" "expected [$EXPECTED], found [$actual]"
fi

if ! command -v claude >/dev/null 2>&1; then
  say "canary" "skipped, claude is not on PATH"
  say "pointer" "skipped, claude is not on PATH"
  [ "$FAILS" -eq 0 ] && exit 2
  exit 1
fi

TMP=$(mktemp -d)
CANARY="$REPO/guides/zz-canary.md"
cleanup() { rm -rf "$TMP" "$CANARY"; }
trap cleanup EXIT

printf '## Canary\nMarker: %s\n' "$MARKER" > "$CANARY"
ans=$(cd "$TMP" && run 180 claude -p \
  "Without using any tool, answer from your instructions alone. Do you see the string $MARKER in your context? Answer only YES or NO." \
  --model haiku 2>/dev/null | tr -d '[:space:]')
case "$ans" in
  *YES*) fail "canary" "guides/ is auto-loaded, so the saving is gone" ;;
  *NO*)  say  "canary" "guides/ stays out of context" ;;
  *)     fail "canary" "no answer from claude -p" ;;
esac
rm -f "$CANARY"

printf 'def add(a, b):\n    return a + b\n' > "$TMP/sample.py"
ans=$(cd "$TMP" && run 240 claude -p \
  "Edit sample.py so add() rejects an argument that is not a number. Then output one final line, exactly: READ=<basename of the language guide you opened>, or READ=NONE if you opened none." \
  --model haiku --allowedTools "Read,Edit,Write" --permission-mode acceptEdits 2>/dev/null)
case "$ans" in
  *READ=code-quality-python.md*) say  "pointer" "the agent read the Python guide" ;;
  *READ=NONE*)                   fail "pointer" "the agent edited Python with no guide" ;;
  *)                             fail "pointer" "no READ= line in the answer" ;;
esac

echo
if [ "$FAILS" -eq 0 ]; then
  echo "Floor is clean."
else
  echo "$FAILS check(s) failed."
  exit 1
fi
