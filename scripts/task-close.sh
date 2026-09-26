#!/bin/bash
set -euo pipefail

COMMENT_LIMIT=60000
GH="${GH:-gh}"
usage="usage: task-close.sh <issue-number> | --self-test"

usage_error() {
  echo "$usage" >&2
  exit 2
}

compose_comment() {
  local dir="$1" report
  echo "Task reports for #$(basename "$dir"):"
  for report in "$dir"/*; do
    printf '\n### %s\n\n' "$(basename "$report")"
    cat "$report"
  done
}

close_task() {
  local dir="$1" issue comment
  issue=$(basename "$dir")
  [ -d "$dir" ] || { echo "no task folder: $dir" >&2; return 1; }
  compgen -G "$dir/*" >/dev/null || { echo "no reports in $dir" >&2; return 1; }
  comment=$(compose_comment "$dir")
  if [ "${#comment}" -gt "$COMMENT_LIMIT" ]; then
    comment="${comment:0:COMMENT_LIMIT}"$'\n\n'"(cut at $COMMENT_LIMIT characters)"
  fi
  "$GH" issue comment "$issue" --body "$comment" >/dev/null || return 1
  rm -rf -- "$dir"
  echo "closed #$issue"
}

self_test() {
  local root failures=0
  root=$(mktemp -d)
  printf '#!/bin/bash\nprintf "%%s\\n" "$@" > "%s/gh.log"\n' "$root" >"$root/gh-ok"
  printf '#!/bin/bash\nexit 1\n' >"$root/gh-fail"
  chmod +x "$root/gh-ok" "$root/gh-fail"
  local GH="$root/gh-ok" dir="$root/work/42"

  mkdir -p "$dir" && echo "VERDICT pass" >"$dir/implementer.md" && echo "no findings" >"$dir/reviewer.md"
  close_task "$dir" >/dev/null && [ ! -e "$dir" ] && grep -q '^### implementer.md$' "$root/gh.log" && grep -q '^### reviewer.md$' "$root/gh.log" \
    || { echo "self-test failed: normal close"; failures=$((failures + 1)); }

  mkdir -p "$dir" && echo "VERDICT fail" >"$dir/implementer.md"
  GH="$root/gh-fail"
  ! close_task "$dir" >/dev/null 2>&1 && [ -d "$dir" ] \
    || { echo "self-test failed: folder deleted after a failed post"; failures=$((failures + 1)); }

  GH="$root/gh-ok"
  rm -rf -- "$dir" "$root/gh.log" && mkdir -p "$dir"
  ! close_task "$dir" >/dev/null 2>&1 && [ ! -e "$root/gh.log" ] \
    || { echo "self-test failed: empty folder posted"; failures=$((failures + 1)); }

  head -c 70000 /dev/zero | tr '\0' x >"$dir/implementer.md"
  close_task "$dir" >/dev/null && grep -q '(cut at' "$root/gh.log" \
    || { echo "self-test failed: long report not cut"; failures=$((failures + 1)); }

  ! "$0" ../.. >/dev/null 2>&1 \
    || { echo "self-test failed: non-number accepted"; failures=$((failures + 1)); }

  rm -rf -- "$root"
  [ "$failures" -eq 0 ] && echo "self-test ok"
}

case "${1:-}" in
  --self-test) self_test ;;
  "" | -*) usage_error ;;
  *)
    [[ $1 =~ ^[0-9]+$ ]] || usage_error
    close_task "$(git rev-parse --show-toplevel)/.claude/work/$1"
    ;;
esac
