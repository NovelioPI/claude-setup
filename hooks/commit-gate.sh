#!/bin/bash
# PreToolUse hook on Bash. Before a `git commit`, blocks changes to protected
# files, then runs the Stop gate. Exit 2 blocks the commit.

source "$(dirname "$0")/protected-paths.sh"

block() {
  echo "BLOCKED: $1" >&2
  exit 2
}

input=$(cat)
if ! command -v jq >/dev/null 2>&1; then
  case "$input" in *commit*) block "jq is missing, so commit-gate.sh cannot check this commit." ;; esac
  exit 0
fi
if ! command=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null); then
  case "$input" in *commit*) block "the hook input is not valid JSON, so commit-gate.sh cannot check this commit." ;; esac
  exit 0
fi

# Reason: a prefix, a path, or a git option before `commit` must not skip the gate.
GIT_COMMIT='^[[:space:]]*((sudo|env|rtk|command|exec|time)[[:space:]]+|[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*([^[:space:]]*/)?git([[:space:]]+(-[cC][[:space:]]*[^[:space:]]+|--[^[:space:]]+))*[[:space:]]+commit([[:space:]]|$)'
printf '%s\n' "$command" | tr ';&|()`"'"'" '\n' | grep -Eq "$GIT_COMMIT" || exit 0

root=$(normalize "${CLAUDE_PROJECT_DIR:-$PWD}")
prefix=$(git -C "$root" rev-parse --show-prefix 2>/dev/null) || exit 0

# Blocks when repo path $2 is inside the project and matcher $1 accepts it.
check() {
  case "$2" in "$prefix"*) ;; *) return 0 ;; esac
  local rel=${2#"$prefix"}
  "$1" "$root" "$rel" &&
    block "$rel is part of the verification signal; this commit adds, deletes, renames, or changes it. Start the session with TASK_MODE=tests to change it."
  return 0
}

# Reads `git diff --name-status -z` from stdin. Old paths must exist in HEAD; new paths must not be named.
check_diff() {
  local status path
  while IFS= read -r -d '' status && IFS= read -r -d '' path; do
    case "$status" in
      A)        check is_protected_new "$path" ;;
      R* | C*)  check is_protected "$path"
                IFS= read -r -d '' path && check is_protected_new "$path" ;;
      *)        check is_protected "$path" ;;
    esac
  done
}

# Reason: a shell edit such as `sed -i` or `git rm` skips protect-signal.sh, so the diff is checked here.
# The index is what a commit records; the working tree covers `commit -a`.
if [ "${TASK_MODE:-impl}" != "tests" ]; then
  base=HEAD
  git -C "$root" rev-parse --verify -q HEAD >/dev/null || base=$(git -C "$root" hash-object -t tree /dev/null)
  check_diff < <(git -C "$root" diff --cached --name-status -z --diff-filter=ACDMRT "$base" 2>/dev/null)
  check_diff < <(git -C "$root" diff --name-status -z --diff-filter=DMRT "$base" 2>/dev/null)
fi

printf '{}' | GATE_CONTEXT=commit bash "$(dirname "$0")/stop-gate.sh"
