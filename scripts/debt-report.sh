#!/bin/bash
# Print the cognitive debt numbers from the playbook, Step 11, for the current repo.
# usage: debt-report.sh [since]    since defaults to "30 days ago"
set -uo pipefail

since=${1:-30 days ago}
log=.agent/understanding-gaps.md

git rev-parse --git-dir >/dev/null 2>&1 || { echo "debt-report: not a git repository" >&2; exit 1; }

fixes=0
diagnosed=0
while IFS= read -r hash; do
  fixes=$((fixes + 1))
  git log -1 --format=%b "$hash" | grep -q 'Root cause:' && diagnosed=$((diagnosed + 1))
done < <(git log --since="$since" --format='%h %s' | awk '$2 ~ /^Fix/ { print $1 }')
echo "Fix commits since $since: $fixes, with a Root cause line: $diagnosed"

if [ ! -f "$log" ]; then
  echo "Walkthroughs: no $log yet"
  exit 0
fi
pass=$(grep -c '| PASS |' "$log")
gaps=$(grep -c '| GAPS |' "$log")
echo "Walkthroughs (all time): $pass PASS, $gaps GAPS"

repeated=$(awk -F'|' '$2 ~ /GAPS/ { print $4 }' "$log" | tr ',' '\n' |
           sed 's/^ *//; s/ *$//' | grep -v '^$' | sort | uniq -c | awk '$1 > 1')
if [ -n "$repeated" ]; then
  echo "Gap topics logged more than once:"
  echo "$repeated"
fi
