#!/bin/bash
# Sourced by protect-signal.sh and commit-gate.sh. Matches a path against the
# globs in <project>/.claude/protected-paths.

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
