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
  local dir="$1" reports report content share
  reports=("$dir"/*)
  share=$((COMMENT_LIMIT / ${#reports[@]}))
  echo "Task reports for #$(basename "$dir"):"
  for report in "${reports[@]}"; do
    printf '\n### %s\n\n' "$(basename "$report")"
    content=$(cat "$report")
    if [ "${#content}" -gt "$share" ]; then
      content="(cut to the last $share characters)"$'\n'"${content: -share}"
    fi
    printf '%s\n' "$content"
  done
}

close_task() {
  local dir="$1" issue
  issue=$(basename "$dir")
  [ -d "$dir" ] || { echo "no task folder: $dir" >&2; return 1; }
  compgen -G "$dir/*" >/dev/null || { echo "no reports in $dir" >&2; return 1; }
  if [ -n "$(find "$dir" -mindepth 1 \( -type d -o -name '.*' \) -print -quit)" ]; then
    echo "refused: $dir holds a subfolder or a dotfile, which would not be posted" >&2
    return 1
  fi
  compose_comment "$dir" | "$GH" issue comment "$issue" --body-file - >/dev/null || return 1
  rm -rf -- "$dir"
  echo "closed #$issue"
}

self_test() {
  local root failures=0
  root=$(mktemp -d)
  printf '#!/bin/bash\nprintf "%%s\\n" "$@" > "%s/gh.log"\n[[ " $* " == *" --body-file - "* ]] && cat >> "%s/gh.log"\nexit 0\n' "$root" "$root" >"$root/gh-ok"
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
  close_task "$dir" >/dev/null && grep -q '(cut to the last' "$root/gh.log" \
    || { echo "self-test failed: long report not cut"; failures=$((failures + 1)); }

  rm -rf -- "$dir" "$root/gh.log" && mkdir -p "$dir"
  { head -c 70000 /dev/zero | tr '\0' x; printf '\nVERDICT implementer-pass\n'; } >"$dir/implementer.md"
  echo "VERDICT reviewer-pass" >"$dir/reviewer.md"
  close_task "$dir" >/dev/null && grep -q 'VERDICT implementer-pass' "$root/gh.log" && grep -q 'VERDICT reviewer-pass' "$root/gh.log" \
    || { echo "self-test failed: cut lost a verdict"; failures=$((failures + 1)); }

  rm -rf -- "$dir" "$root/gh.log" && mkdir -p "$dir"
  printf '€%.0s' $(seq 50000) >"$dir/implementer.md"
  close_task "$dir" >/dev/null 2>&1 \
    || { echo "self-test failed: multibyte report not posted"; failures=$((failures + 1)); }

  rm -rf -- "$dir" "$root/gh.log" && mkdir -p "$dir/logs" && echo "a" >"$dir/a.md"
  ! close_task "$dir" >/dev/null 2>&1 && [ -d "$dir/logs" ] && [ ! -e "$root/gh.log" ] \
    || { echo "self-test failed: subfolder not refused"; failures=$((failures + 1)); }

  rm -rf -- "$dir" "$root/gh.log" && mkdir -p "$dir" && echo "a" >"$dir/a.md" && echo "x" >"$dir/.secret"
  ! close_task "$dir" >/dev/null 2>&1 && [ -e "$dir/.secret" ] && [ ! -e "$root/gh.log" ] \
    || { echo "self-test failed: dotfile not refused"; failures=$((failures + 1)); }

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
