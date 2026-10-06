#!/bin/bash
# Stop hook. Type-checks changed files and runs unit tests before a turn ends.
# Blocks once with exit 2; the second attempt always passes.

source "$(dirname "$0")/protected-paths.sh"

command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
[ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false')" = "true" ] && exit 0

# Reason: $0 can be relative, so the adapter path is resolved before the cd.
adapter=(bash "$(cd "$(dirname "$0")/.." && pwd)/scripts/quality.sh")
cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
# Reason: /handoff runs with red tests, so its skip file lets one turn end, never a commit.
if [ "${GATE_CONTEXT:-stop}" != commit ] && [ -f .agent/.skip-gate ]; then
  rm -f .agent/.skip-gate
  exit 0
fi

mapfile -t changed < <(
  git diff --relative --name-only --diff-filter=d HEAD 2>/dev/null
  git ls-files --others --exclude-standard
)
[ "${#changed[@]}" -eq 0 ] && exit 0

project=$(project_adapter "$PWD") && adapter=("$project")

# Prints the tree hash of the working tree with untracked files, through a copy of the index.
# Reason: `git diff` and `hash-object` skip some untracked paths and hide the error.
# Reason: new objects go to the temp dir, so large untracked files do not fill .git/objects.
worktree_tree() {
  local dir tree status
  dir=$(mktemp -d) || return 1
  mkdir "$dir/objects"
  # Reason: `cp -p` keeps the mtime, so git still rehashes a file changed after the index write.
  cp -p "$(git rev-parse --git-path index)" "$dir/index" 2>/dev/null
  tree=$(
    export GIT_INDEX_FILE="$dir/index" GIT_OBJECT_DIRECTORY="$dir/objects"
    export GIT_ALTERNATE_OBJECT_DIRECTORIES="$(realpath "$(git rev-parse --git-path objects)")"
    git add -A -- :/ 2>/dev/null && git write-tree 2>/dev/null
  )
  status=$?
  rm -rf "$dir"
  [ "$status" -eq 0 ] && echo "$tree"
}

# Reason: with no new change, a discussion turn would repeat the same block every turn.
# Reason: two projects in one repo share the state file, so the project path is in the fingerprint.
state="$(git rev-parse --git-dir)/claude-stop-gate"
fingerprint=""
tree=$(worktree_tree) &&
  fingerprint=$(printf '%s\n' "$PWD" "$tree" "$(git hash-object -- "${adapter[-1]}")" |
                git hash-object --stdin)
saved_fingerprint=""
saved_status=""
{ read -r saved_fingerprint saved_status < "$state"; } 2>/dev/null
# Risk: if a commit skipped after a failed run, then it would record failing code.
if [ -n "$fingerprint" ] && [ "$fingerprint" = "$saved_fingerprint" ] &&
   { [ "${GATE_CONTEXT:-stop}" != commit ] || [ "$saved_status" = 0 ]; }; then
  exit 0
fi

out=$("${adapter[@]}" check "${changed[@]}" 2>&1)
status=$?
echo "$fingerprint $status" 2>/dev/null > "$state"
[ "$status" -eq 0 ] && exit 0

printf 'Quality gate failed. Report this failure; fix it only inside an approved plan. Do not edit tests to pass.\n%s\n' "$out" >&2
exit 2
