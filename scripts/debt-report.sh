#!/bin/bash
# Print the cognitive debt numbers from the playbook, Step 11, for the current repo.
# usage: debt-report.sh [since]    since defaults to "30 days ago"
set -uo pipefail

since=${1:-30 days ago}

git rev-parse --git-dir >/dev/null 2>&1 || { echo "debt-report: not a git repository" >&2; exit 1; }

fixes=0
diagnosed=0
while IFS= read -r hash; do
  fixes=$((fixes + 1))
  git log -1 --format=%b "$hash" | grep -q 'Root cause:' && diagnosed=$((diagnosed + 1))
done < <(git log --since="$since" --format='%h %s' | awk '$2 ~ /^Fix/ { print $1 }')
echo "Fix commits since $since: $fixes, with a Root cause line: $diagnosed"
