#!/bin/bash
set -euo pipefail

REQUIRED_SECTIONS=(Goal Scope Non-goals Acceptance Unknowns)
LABEL_GROUPS=(value effort risk)
FIXTURES="$(dirname "$0")/../tests/contract"

list_problems() {
  local json body section content group count
  json=$(cat)
  body=$(jq -r '.body' <<<"$json" | tr -d '\r')
  for section in "${REQUIRED_SECTIONS[@]}"; do
    content=$(awk -v name="$section" '
      /^(```|~~~)/        { fenced = !fenced; if (inside) print; next }
      !fenced && /^###? / { inside = ($0 ~ "^###? " name "[[:space:]]*$"); next }
      !fenced && /^---/   { inside = 0 }
      inside' <<<"$body" | grep -v -e '^[[:space:]]*$' -e '^_No response_$' || true)
    [ -n "$content" ] || echo "missing section: $section"
  done
  for group in "${LABEL_GROUPS[@]}"; do
    count=$(jq --arg prefix "$group:" '[.labels[].name | select(startswith($prefix))] | length' <<<"$json")
    [ "$count" -eq 1 ] || echo "need one $group label, found $count"
  done
}

report() {
  local problems
  problems=$(list_problems)
  if [ -n "$problems" ]; then
    echo "$problems"
    return 1
  fi
  echo "contract ok"
}

self_test() {
  local fixture expected actual failures=0
  for fixture in "$FIXTURES"/*.json; do
    expected=0
    [[ $(basename "$fixture") == fail-* ]] && expected=1
    actual=0
    report <"$fixture" >/dev/null || actual=1
    if [ "$actual" -ne "$expected" ]; then
      echo "self-test failed: $(basename "$fixture") exit $actual, expected $expected"
      failures=$((failures + 1))
    fi
  done
  [ "$failures" -eq 0 ] && echo "self-test ok"
}

case "${1:-}" in
  --self-test) self_test ;;
  --json) report <"${2:?usage: contract-check.sh --json <file>}" ;;
  "" | -*) echo "usage: contract-check.sh <issue> | --json <file> | --self-test" >&2; exit 2 ;;
  *) gh issue view "$1" --json body,labels | report ;;
esac
