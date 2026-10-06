#!/bin/bash
# Sourced by protect-signal.sh, commit-gate.sh, post-edit.sh, and stop-gate.sh.
# Matches a path against <project>/.claude/protected-paths, and finds a trusted project adapter.

# Prints an absolute path with `.`, `..`, and repeated slashes removed.
normalize() {
  local parts part
  local -a out=()
  IFS=/ read -ra parts <<< "$1"
  for part in "${parts[@]}"; do
    case "$part" in
      '' | .) ;;
      ..) [ ${#out[@]} -gt 0 ] && out=("${out[@]:0:${#out[@]}-1}") ;;
      *) out+=("$part") ;;
    esac
  done
  [ ${#out[@]} -eq 0 ] && { echo /; return; }
  printf '/%s' "${out[@]}"
}

# Prints the patterns of project $1, one per line, without comments or blank lines.
protected_patterns() {
  local list="$1/.claude/protected-paths" pattern
  # Reason: the project adapter decides what the gates check, so it is always protected.
  echo .claude/quality.sh
  [ -f "$list" ] || return 0
  while IFS= read -r pattern || [ -n "$pattern" ]; do
    # Reason: a list saved on Windows ends each line with \r, which no path matches.
    pattern=${pattern%$'\r'}
    case "$pattern" in '' | '#'*) continue ;; esac
    printf '%s\n' "$pattern"
  done < "$list"
}

# Succeeds when existing path $2, relative to project root $1, matches any pattern.
is_protected() {
  local pattern
  while IFS= read -r pattern; do
    # shellcheck disable=SC2254
    case "$2" in $pattern) return 0 ;; esac
  done < <(protected_patterns "$1")
  return 1
}

# Prints the adapter of project $1 when it is executable and its content equals HEAD.
# Reason: a shell write skips protect-signal.sh, so an untracked or edited adapter is not trusted.
# Reason: `git diff` skips assume-unchanged files, so the content hashes are compared.
project_adapter() {
  local committed current
  [ -x "$1/.claude/quality.sh" ] || return 1
  committed=$(git -C "$1" rev-parse -q --verify HEAD:./.claude/quality.sh 2>/dev/null) || return 1
  current=$(git -C "$1" hash-object -- .claude/quality.sh 2>/dev/null) || return 1
  [ "$committed" = "$current" ] || return 1
  echo "$1/.claude/quality.sh"
}

# Succeeds when new path $2 equals a pattern with no wildcard.
# Reason: `tests/*` must still allow new tests, but a named file such as
# tests/conftest.py can disable every test if Claude creates it.
is_protected_new() {
  local pattern
  while IFS= read -r pattern; do
    case "$pattern" in *'*'* | *'?'* | *'['*) continue ;; esac
    [ "$2" = "$pattern" ] && return 0
  done < <(protected_patterns "$1")
  return 1
}
