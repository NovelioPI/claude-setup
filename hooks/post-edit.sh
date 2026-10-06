#!/bin/bash
# PostToolUse hook. Formats and lints the edited file by language, then checks
# Python complexity. Exit 2 sends the message back to Claude; every other path exits 0.

command -v jq >/dev/null 2>&1 || exit 0

file=$(cat | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$file" ] && exit 0
[ -f "$file" ] || exit 0

MAX_COGNITIVE=15
out=""

# Reason: a missing tool is a machine problem, so it must never block Claude.
have() { command -v "$1" >/dev/null 2>&1; }

root="${CLAUDE_PROJECT_DIR:-$PWD}"
has_config() {
  local name
  for name in "$@"; do [ -f "$root/$name" ] && return 0; done
  return 1
}

# Reason: a formatter with no project config rewrites the whole file in its own style.
case "$file" in
  *.py)
    have uvx || exit 0
    if has_config ruff.toml .ruff.toml || grep -q '^\[tool\.ruff' "$root/pyproject.toml" 2>/dev/null; then
      uvx ruff format --quiet "$file" >/dev/null 2>&1
    fi
    lint=$(uvx ruff check --fix --quiet "$file" 2>&1) || out="$lint"
    cog=$(uvx complexipy --plain --failed --max-complexity-allowed "$MAX_COGNITIVE" \
          "$file" 2>&1) || out="$out"$'\n'"$cog"
    limits=$(uvx ruff check --isolated --preview --select PLR1702,PLR0913,BLE001,S110 \
             --config 'lint.pylint.max-args = 4' "$file" 2>&1) \
          || out="$out"$'\n'"$limits"
    ;;
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs)
    bin="$root/node_modules/.bin"
    if has_config biome.json biome.jsonc && [ -x "$bin/biome" ]; then
      lint=$("$bin/biome" check --write --no-errors-on-unmatched "$file" 2>&1) || out="$lint"
    else
      [ -x "$bin/prettier" ] && "$bin/prettier" --write --log-level warn "$file" >/dev/null 2>&1
      if [ -x "$bin/eslint" ]; then
        lint=$("$bin/eslint" --fix "$file" 2>&1) || out="$lint"
      fi
    fi
    ;;
  *.c|*.h|*.cc|*.cpp|*.hpp)
    have clang-format && has_config .clang-format _clang-format || exit 0
    clang-format -i "$file" >/dev/null 2>&1
    ;;
  *.kt|*.kts)
    have ktlint || exit 0
    lint=$(ktlint -F "$file" 2>&1) || out="$lint"
    ;;
  *.dart)
    have dart || exit 0
    dart format "$file" >/dev/null 2>&1
    lint=$(dart analyze "$file" 2>&1) || out="$lint"
    ;;
  *) exit 0 ;;
esac

[ -z "$(printf '%s' "$out" | tr -d '[:space:]')" ] && exit 0

printf 'Format or lint problems in %s. Fix them before continuing.\n%s\n' "$file" "$out" >&2
printf 'See rules/code-quality.md and the guide for this language.\n' >&2
exit 2
