#!/bin/bash
# Regression test for hooks/explorer-readonly.sh. Exit 0 when every case passes.
set -uo pipefail

hook="$(cd "$(dirname "$0")/.." && pwd)/hooks/explorer-readonly.sh"
fails=0

expect() {
  local want=$1 cmd=$2 got
  printf '%s' "$cmd" | jq -Rs '{tool_input: {command: .}}' | /bin/bash "$hook" >/dev/null 2>&1
  got=$?
  if [ "$got" -eq "$want" ]; then
    echo "ok    exit $got  $cmd"
  else
    echo "FAIL  exit $got, want $want  $cmd"
    fails=$((fails + 1))
  fi
}

ALLOW=0
BLOCK=2

expect $ALLOW 'grep -E "a|b" file'
expect $ALLOW "git log --grep='x|y'"
expect $ALLOW 'grep a\|b file'
expect $ALLOW 'grep "a\"|rm x" f'
expect $ALLOW 'ls | head'
expect $BLOCK 'grep a | rm x'
expect $BLOCK "grep \$'\\'' | rm x"
expect $BLOCK "grep 'a | head"
expect $BLOCK 'grep a || ls'
expect $BLOCK 'grep a |'

[ "$fails" -eq 0 ]
