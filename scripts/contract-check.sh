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

fingerprint() {
  jq -r '.body, (.labels | map(.name) | sort | join(","))' | tr -d '\r' | sha256sum | cut -d' ' -f1
}

report() {
  local since="${1:-}" json problems current
  json=$(cat)
  problems=$(list_problems <<<"$json")
  current=$(fingerprint <<<"$json")
  if [ -n "$since" ] && [ "$since" != "$current" ]; then
    problems="${problems:+$problems$'\n'}contract changed since dispatch"
  fi
  if [ -n "$problems" ]; then
    echo "$problems"
    return 1
  fi
  echo "contract ok $current"
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
  local sample="$FIXTURES/pass-script.json" recorded
  recorded=$(report <"$sample" | cut -d' ' -f3)
  report "$recorded" <"$sample" >/dev/null || { echo "self-test failed: same fingerprint rejected"; failures=$((failures + 1)); }
  ! report "stale" <"$sample" >/dev/null || { echo "self-test failed: changed fingerprint accepted"; failures=$((failures + 1)); }
  [ "$failures" -eq 0 ] && echo "self-test ok"
}

usage="usage: contract-check.sh <issue> | --json <file> [--since <fingerprint>] | --self-test"
issue="" json_file="" since=""
while [ $# -gt 0 ]; do
  case "$1" in
    --self-test) self_test; exit ;;
    --json) json_file="${2:?$usage}"; shift 2 ;;
    --since) since="${2:?$usage}"; shift 2 ;;
    -*) echo "$usage" >&2; exit 2 ;;
    *) issue="$1"; shift ;;
  esac
done
if [ -n "$json_file" ]; then
  report "$since" <"$json_file"
elif [ -n "$issue" ]; then
  gh issue view "$issue" --json body,labels | report "$since"
else
  echo "$usage" >&2
  exit 2
fi
