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
ln -s /tmp/snapshot-guard-link-target "$repo/lnk"
# Reason: branch other tracks .env, so a checkout of it overwrites the ignored local .env.
other_tree=$(
  export GIT_INDEX_FILE="$repo/.git/other-index"
  git -C "$repo" read-tree HEAD && git -C "$repo" add -f .env && git -C "$repo" write-tree
)
rm -f "$repo/.git/other-index"
other=$(git -C "$repo" -c user.name=t -c user.email=t@t commit-tree "$other_tree" -p HEAD -m other)
git -C "$repo" update-ref refs/heads/other "$other"

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
expect ask   'git commit -m "rm the old file"'
expect ask   'echo rm x'
expect ask   'git commit -m "tidy; rm stale files"'
expect ask   'git commit -m "a && rm b"'
expect ask   "echo 'x | rm y'"
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
expect none  'bash -c "npm test"'
expect ask   '(rm tracked.txt)'
expect ask   '{ rm tracked.txt; }'
expect ask   'if true; then rm tracked.txt; fi'
expect ask   'for f in a; do rm tracked.txt; done'
expect ask   '! rm tracked.txt'
expect ask   '\rm tracked.txt'
expect ask   '"rm" tracked.txt'
expect ask   'FOO=1 rm tracked.txt'
expect ask   'timeout 5 rm tracked.txt'
expect ask   'echo $(rm tracked.txt)'
expect ask   'echo `rm tracked.txt`'
expect ask   'find . -name x -exec rm {} \;'
expect ask   'env git clean -fdx'
expect ask   'command git stash'
expect ask   'eval rm tracked.txt'
expect ask   'bash -c rm\ tracked.txt'
expect ask   $'bash -c "echo hi\nrm tracked.txt\n"'
expect ask   "bash -c \$'rm\\x20.env'"
expect none  'docker run --rm image'
expect ask   'cd; rm new.txt'
expect ask   'cd /home && rm new.txt'
expect ask   'pushd /tmp && rm new.txt'
expect ask   'cd -P /tmp && rm new.txt'
expect ask   'cd -- /tmp && rm new.txt'
expect ask   'rm lnk'
expect ask   'git checkout other'
expect ask   'git stash -a'
expect ask   'git stash --all'
expect ask   'git clean -x'
expect ask   'git -c clean.requireForce=false clean -x'
expect ask   'git -c core.worktree=/tmp stash'
expect allow 'git switch -f other2'
expect allow 'git checkout-index -a -f'
expect ask   $'ls # don\'t\ntrue; rm .env'
expect ask   "echo \$'a\\'b'; rm .env"
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

# Reason: git add skips a skip-worktree file, so the snapshot must clear that bit to see the edit.
git -C "$repo" update-index --skip-worktree tracked.txt
echo EDITED > "$repo/tracked.txt"
decision 'rm tracked.txt' >/dev/null
ref=$(git -C "$repo" for-each-ref --sort=-refname --format='%(refname)' refs/claude/snapshots/ | head -1)
if [ "$(git -C "$repo" show "$ref:tracked.txt" 2>/dev/null)" = EDITED ]; then
  echo "ok    snapshot holds the edit of a skip-worktree file"
else
  echo "FAIL  snapshot lost the edit of a skip-worktree file"
  fails=$((fails + 1))
fi
git -C "$repo" update-index --no-skip-worktree tracked.txt

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
