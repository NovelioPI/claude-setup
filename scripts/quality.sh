#!/bin/bash
# Language adapter for the quality hooks. A project replaces it with an executable
# .claude/quality.sh that gives the same three subcommands.
# usage: quality.sh format <file> | lint <file> | check <changed files...>
# lint and check print problems and exit 1. A missing tool is not a problem.

MAX_COGNITIVE=15

cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 0

# Reason: a missing tool is a machine problem, so it must never block Claude.
have() { command -v "$1" >/dev/null 2>&1; }

has_config() {
  local name
  for name in "$@"; do [ -f "$name" ] && return 0; done
  return 1
}

has_biome() { has_config biome.json biome.jsonc && [ -x node_modules/.bin/biome ]; }

# Reason: uvx has no project libraries, so only the project's own tools run.
project_tool() {
  if [ -x ".venv/bin/$1" ]; then
    echo ".venv/bin/$1"
  else
    command -v "$1"
  fi
}

# Reason: a formatter with no project config rewrites the whole file in its own style.
format_file() {
  case "$1" in
    *.py)
      have uvx || return 0
      if has_config ruff.toml .ruff.toml || grep -q '^\[tool\.ruff' pyproject.toml 2>/dev/null; then
        uvx ruff format --quiet "$1"
      fi
      ;;
    *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs)
      # Reason: with Biome, lint runs `biome check --write`, which also formats.
      has_biome && return 0
      [ -x node_modules/.bin/prettier ] && node_modules/.bin/prettier --write --log-level warn "$1"
      ;;
    *.c|*.h|*.cc|*.cpp|*.hpp)
      have clang-format && has_config .clang-format _clang-format && clang-format -i "$1"
      ;;
    *.dart)
      have dart && dart format "$1"
      ;;
  esac
}

lint_file() {
  local result
  case "$1" in
    *.py)
      have uvx || return 0
      result=$(uvx ruff check --fix --quiet "$1" 2>&1) || printf '%s\n' "$result"
      result=$(uvx complexipy --plain --failed --max-complexity-allowed "$MAX_COGNITIVE" \
               "$1" 2>&1) || printf '%s\n' "$result"
      result=$(uvx ruff check --isolated --preview --select PLR1702,PLR0913,BLE001,S110 \
               --config 'lint.pylint.max-args = 4' "$1" 2>&1) || printf '%s\n' "$result"
      ;;
    *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs)
      if has_biome; then
        result=$(node_modules/.bin/biome check --write --no-errors-on-unmatched "$1" 2>&1) ||
          printf '%s\n' "$result"
      elif [ -x node_modules/.bin/eslint ]; then
        result=$(node_modules/.bin/eslint --fix "$1" 2>&1) || printf '%s\n' "$result"
      fi
      ;;
    *.kt|*.kts)
      have ktlint || return 0
      result=$(ktlint -F "$1" 2>&1) || printf '%s\n' "$result"
      ;;
    *.dart)
      have dart || return 0
      result=$(dart analyze "$1" 2>&1) || printf '%s\n' "$result"
      ;;
  esac
}

run() {
  local result
  result=$("$@" 2>&1) || printf '\n$ %s\n%s\n' "$*" "$(printf '%s' "$result" | tail -40)"
}

check_python_types() {
  local mypy pyright
  local -a interpreter=()
  mypy=$(project_tool mypy)
  if [ -n "$mypy" ]; then
    run "$mypy" "$@"
    return
  fi
  # Reason: pyright with no config reports every project import as missing.
  has_config pyrightconfig.json || grep -q '^\[tool\.pyright' pyproject.toml 2>/dev/null || return 0
  pyright=$(project_tool pyright)
  [ -n "$pyright" ] || return 0
  [ -x .venv/bin/python ] && interpreter=(--pythonpath .venv/bin/python)
  run "$pyright" "${interpreter[@]}" "$@"
}

check_files() {
  local -a py=() ts=() dart=()
  local file pytest
  for file in "$@"; do
    case "$file" in
      *.py) py+=("$file") ;;
      *.ts|*.tsx|*.js|*.jsx) ts+=("$file") ;;
      *.dart) dart+=("$file") ;;
    esac
  done

  if [ "${#py[@]}" -gt 0 ]; then
    check_python_types "${py[@]}"
    pytest=$(project_tool pytest)
    # Reason: pytest exits 5 when no test file exists, which is not a failure.
    if [ -n "$pytest" ] && [ -n "$(find tests/unit -name 'test_*.py' 2>/dev/null | head -1)" ]; then
      run "$pytest" -q -x tests/unit
    fi
  fi

  if [ "${#ts[@]}" -gt 0 ] && [ -f tsconfig.json ] && [ -x node_modules/.bin/tsc ]; then
    run node_modules/.bin/tsc --noEmit
  fi
  if [ "${#ts[@]}" -gt 0 ] && [ -x node_modules/.bin/vitest ]; then
    # Reason: held-out tests must stay unseen, like the Python path that runs only tests/unit.
    run node_modules/.bin/vitest run --changed --passWithNoTests --exclude 'tests/holdout/**'
  fi

  if [ "${#dart[@]}" -gt 0 ] && have dart; then
    run dart analyze "${dart[@]}"
  fi
}

case "${1:-}" in
  format) format_file "$2"; exit 0 ;;
  lint)   problems=$(lint_file "$2") ;;
  check)  shift; problems=$(check_files "$@") ;;
  *)      echo "usage: quality.sh format <file> | lint <file> | check <files...>" >&2; exit 64 ;;
esac

[ -z "$(printf '%s' "$problems" | tr -d '[:space:]')" ] && exit 0
printf '%s\n' "$problems"
exit 1
