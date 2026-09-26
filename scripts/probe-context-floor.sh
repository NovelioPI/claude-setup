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

input_tokens() {
  (cd "$TMP/work" && run 180 env CLAUDE_CONFIG_DIR="$1" claude -p "Answer only OK." \
    --model haiku --output-format json 2>/dev/null) |
    jq '.usage | .input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens' 2>/dev/null
}

make_config() {
  local cfg="$TMP/config-$1"
  mkdir -p "$cfg"
  ln -s "$REPO/.credentials.json" "$cfg/.credentials.json"
  echo "$cfg"
}

mkdir -p "$TMP/work"
baseline=$(make_config baseline)
sed 's#@rules/#rules/#g' "$REPO/CLAUDE.md" > "$baseline/CLAUDE.md"
autoload=$(make_config autoload)
cp "$baseline/CLAUDE.md" "$autoload/CLAUDE.md" && cp -r "$REPO/rules" "$autoload/"
imported=$(make_config imported)
cp "$REPO/CLAUDE.md" "$imported/CLAUDE.md" && cp -r "$REPO/rules" "$imported/"
tokens_c=$(input_tokens "$baseline"); tokens_a=$(input_tokens "$autoload"); tokens_b=$(input_tokens "$imported")
if [[ "$tokens_c$tokens_a$tokens_b" =~ ^[0-9]+$ ]] && [[ -n "$tokens_c" && -n "$tokens_a" && -n "$tokens_b" ]] && [ "$tokens_a" -gt "$tokens_c" ]; then
  rules_size=$((tokens_a - tokens_c))
  extra=$((tokens_b - tokens_a))
  say "tokens" "baseline $tokens_c, auto-load $tokens_a, auto-load plus @ import $tokens_b"
  if [ $((extra * 2)) -ge "$rules_size" ]; then
    say "duplicate-load" "yes, the @ import adds $extra of $rules_size rule tokens again"
  else
    say "duplicate-load" "no, the @ import adds $extra of $rules_size rule tokens"
  fi
else
  fail "duplicate" "no usable token counts: [$tokens_c] [$tokens_a] [$tokens_b]"
fi

printf '## Canary\nMarker: %s\n' "$MARKER" > "$CANARY"
ans=$(cd "$TMP" && run 180 env CLAUDE_CONFIG_DIR="$REPO" claude -p \
  "Without using any tool, answer from your instructions alone. Do you see the string $MARKER in your context? Answer only YES or NO." \
  --model haiku 2>/dev/null | tr -d '[:space:]')
case "$ans" in
  *YES*) fail "canary" "guides/ is auto-loaded, so the saving is gone" ;;
  *NO*)  say  "canary" "guides/ stays out of context" ;;
  *)     fail "canary" "no answer from claude -p" ;;
esac
rm -f "$CANARY"

printf 'def add(a, b):\n    return a + b\n' > "$TMP/sample.py"
ans=$(cd "$TMP" && run 240 env CLAUDE_CONFIG_DIR="$REPO" claude -p \
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
