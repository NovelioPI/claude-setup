#!/bin/bash
# Regression test for hooks/snapshot-guard.sh. Exit 0 when every case passes.
set -uo pipefail

hook="$(cd "$(dirname "$0")/.." && pwd)/hooks/snapshot-guard.sh"
fails=0
repo=$(mktemp -d "$HOME/.snapshot-guard-test.XXXXXX")
trap 'rm -rf "$repo"' EXIT

git -C "$repo" init -q
printf 'node_modules/\n.env\n' > "$repo/.gitignore"
echo tracked > "$repo/tracked.txt"
git -C "$repo" add -A
git -C "$repo" -c user.name=t -c user.email=t@t commit -qm init
echo untracked > "$repo/new.txt"
echo secret > "$repo/.env"
mkdir -p "$repo/app/node_modules" && echo dep > "$repo/app/node_modules/x.js"

decision() {
  jq -n --arg c "$1" --arg d "$repo" '{tool_input: {command: $c}, cwd: $d}' |
    bash "$hook" | jq -r '.hookSpecificOutput.permissionDecision // "none"'
}

expect() {
  local want=$1 cmd=$2 got
  got=$(decision "$cmd")
  got=${got:-none}
  if [ "$got" = "$want" ]; then
    echo "ok    $got  $cmd"
  else
    echo "FAIL  $got, want $want  $cmd"
    fails=$((fails + 1))
  fi
}

expect none  'ls -la'
expect none  'git commit -m "rm the old file"'
expect none  'echo rm x'
expect none  'git commit -m "tidy; rm stale files"'
expect none  'git commit -m "a && rm b"'
expect none  "echo 'x | rm y'"
expect allow 'rm tracked.txt'
expect allow 'rm -f new.txt'
expect allow 'rm *.txt'
expect allow 'git stash'
expect allow 'git restore tracked.txt'
expect allow 'git checkout -- tracked.txt'
expect allow 'git status && git stash -u'
expect allow 'rm /tmp/scratch-file'
expect allow "cd $repo && rm new.txt"
expect ask   'rm .env'
expect ask   'rm -rf app'
expect ask   'rm /etc/hosts'
expect ask   'rm "$FILE"'
expect ask   'sudo rm tracked.txt'
expect ask   'find . -name "*.txt" | xargs rm'
expect ask   'find . -name x -delete'
expect ask   'git stash drop'
expect ask   'git -C /elsewhere restore f'
expect ask   'cd "$DIR" && rm new.txt'
expect ask   "bash -c 'true; rm tracked.txt'"
expect ask   'sh -c "rm tracked.txt"'
expect allow 'sleep 1 & rm new.txt'
expect allow 'true |& rm new.txt'
expect none  'ls 2>&1 && ls &>/dev/null'

# Reason: outside a repo git fails on its own, so the hook must not claim a snapshot.
outside=$(mktemp -d "$HOME/.snapshot-guard-out.XXXXXX")
got=$(jq -n --arg d "$outside" '{tool_input: {command: "git stash"}, cwd: $d}' | bash "$hook" |
  jq -r '.hookSpecificOutput.permissionDecision // "none"')
rm -rf "$outside"
if [ "${got:-none}" = none ]; then
  echo "ok    none  git stash outside a repo"
else
  echo "FAIL  $got, want none  git stash outside a repo"
  fails=$((fails + 1))
fi

# The snapshot must hold an untracked file, so rm of it can be undone.
ref=$(git -C "$repo" for-each-ref --sort=-refname --format='%(refname)' refs/claude/snapshots/ | head -1)
rm "$repo/new.txt"
if git -C "$repo" restore --source="$ref" -- new.txt 2>/dev/null && [ "$(cat "$repo/new.txt")" = untracked ]; then
  echo "ok    restore of an untracked file from $ref"
else
  echo "FAIL  restore of an untracked file from ${ref:-no ref}"
  fails=$((fails + 1))
fi

[ "$fails" -eq 0 ]
