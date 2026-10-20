#!/bin/bash
# PreToolUse(Bash) hook. Saves the working tree to a git ref before a command that can lose files.
# Allows the command when that snapshot can undo it; asks the user when it cannot.

command -v jq >/dev/null 2>&1 || exit 0
INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0
dir=$(printf '%s' "$INPUT" | jq -r '.cwd // empty')
[ -n "$dir" ] || dir=$PWD

KEEP=50
seen=0
asks=()
tops=()

decide() {
  jq -n --arg d "$1" --arg r "$2" --arg c "$3" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: $d,
      permissionDecisionReason: $r, additionalContext: $c}}'
  exit 0
}

add_top() {
  local t
  for t in "${tops[@]}"; do [ "$t" = "$1" ] && return; done
  tops+=("$1")
}

repo_top() { git -C "$1" rev-parse --show-toplevel 2>/dev/null; }

check_target() {
  local path=$1 abs top
  case "$path" in /*) abs=$path ;; *) abs="$dir/$path" ;; esac
  abs=$(realpath -m -- "$abs")
  # Reason: files under the temp dir are disposable, so they need no snapshot and no prompt.
  case "$abs" in /tmp/*|"${TMPDIR:-/tmp}"/*) return ;; esac
  top=$(repo_top "$(dirname "$abs")")
  if [ -z "$top" ] || [ "$abs" = "$top" ] || [[ "$abs" != "$top"/* ]] || [[ "$abs" == "$top"/.git* ]]; then
    asks+=("$path is outside a git repo")
    return
  fi
  # Reason: a snapshot skips ignored files, so rm of .env or a dir holding node_modules is not undoable.
  if [ -n "$(git -C "$top" ls-files --others --ignored --exclude-standard --directory -- "$abs" 2>/dev/null)" ]; then
    asks+=("$path is or holds a git-ignored file")
    return
  fi
  add_top "$top"
}

check_rm() {
  local -a words
  local word match end_opts=0 found
  # Reason: quotes, variables, and expansions hide the real target from this parser.
  if [[ "$1" =~ [\$\`\'\"\\\(\)\{\}~] ]]; then
    asks+=("cannot read the targets of: $1")
    return
  fi
  read -ra words <<< "$1"
  for word in "${words[@]:1}"; do
    if [ "$end_opts" -eq 0 ] && [ "$word" = "--" ]; then end_opts=1; continue; fi
    if [ "$end_opts" -eq 0 ] && [[ "$word" == -* ]]; then continue; fi
    if [[ "$word" == *[*?[]* ]]; then
      found=0
      while IFS= read -r match; do
        [ -n "$match" ] || continue
        found=1
        check_target "$match"
      done < <(cd "$dir" 2>/dev/null && compgen -G "$word")
      [ "$found" -eq 1 ] || continue
    else
      check_target "$word"
    fi
  done
}

check_git() {
  local top
  if [[ "$1" =~ [[:space:]](-C|--git-dir|--work-tree) ]]; then
    asks+=("git runs in another directory: $1")
    return
  fi
  if [[ "$1" =~ ^git[[:space:]]+stash[[:space:]]+(drop|clear) ]]; then
    asks+=("a dropped stash is not in the snapshot")
    return
  fi
  top=$(repo_top "$dir")
  [ -n "$top" ] && add_top "$top"
}

SEGMENTS=$(printf '%s' "$COMMAND" | sed -E 's/(\|\||&&|;|\|)/\n/g')
while IFS= read -r segment; do
  segment="${segment#"${segment%%[![:space:]]*}"}"
  if [[ "$segment" =~ ^cd[[:space:]]+([^[:space:]]+)[[:space:]]*$ ]]; then
    target=${BASH_REMATCH[1]}
    if [[ "$target" =~ [\$\`\'\"~] ]]; then dir=""; continue; fi
    case "$target" in /*) dir=$target ;; *) dir="$dir/$target" ;; esac
    continue
  fi
  risky=""
  if [[ "$segment" =~ ^rm([[:space:]]|$) ]]; then
    risky=rm
  elif [[ "$segment" =~ ^git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-][^[:space:]]*)?)*[[:space:]]+(stash|restore|checkout|clean|reset|rm)([[:space:]]|$) ]]; then
    risky=git
  elif [[ "$segment" =~ ^((sudo|env|command|exec|time|nice|nohup|xargs)([[:space:]]+[^[:space:]]+)*[[:space:]]+)?([^[:space:]]*/)?(rm|unlink|shred)([[:space:]]|$) ]] ||
       [[ "$segment" =~ ^find[[:space:]].*[[:space:]]-delete([[:space:]]|$) ]]; then
    asks+=("cannot check: $segment")
    continue
  fi
  [ -n "$risky" ] || continue
  seen=1
  # Reason: a cd this parser cannot follow leaves the working directory unknown.
  if [ -z "$dir" ]; then
    asks+=("unknown directory after cd: $segment")
    continue
  fi
  if [ "$risky" = rm ]; then check_rm "$segment"; else check_git "$segment"; fi
done <<< "$SEGMENTS"

[ "$seen" -eq 1 ] || [ "${#asks[@]}" -gt 0 ] || exit 0

# Prints a new snapshot ref holding the tracked and untracked files of a repo, ignored files excluded.
snapshot() {
  local top=$1 tmp tree parent commit ref old
  tmp=$(mktemp -d) || return 1
  cp "$(git -C "$top" rev-parse --path-format=absolute --git-path index)" "$tmp/index" 2>/dev/null
  tree=$(
    export GIT_INDEX_FILE="$tmp/index"
    git -C "$top" add -A -- :/ 2>/dev/null && git -C "$top" write-tree 2>/dev/null
  )
  rm -rf "$tmp"
  [ -n "$tree" ] || return 1
  parent=$(git -C "$top" rev-parse -q --verify HEAD)
  commit=$(
    export GIT_AUTHOR_NAME=claude-snapshot GIT_AUTHOR_EMAIL=snapshot@localhost
    export GIT_COMMITTER_NAME=claude-snapshot GIT_COMMITTER_EMAIL=snapshot@localhost
    git -C "$top" commit-tree "$tree" ${parent:+-p "$parent"} -m "Snapshot before: $COMMAND"
  ) || return 1
  ref="refs/claude/snapshots/$(date +%Y%m%d-%H%M%S)-$$"
  git -C "$top" update-ref "$ref" "$commit" || return 1
  git -C "$top" for-each-ref --sort=-refname --format='%(refname)' refs/claude/snapshots/ |
    tail -n +$((KEEP + 1)) | while IFS= read -r old; do git -C "$top" update-ref -d "$old"; done
  echo "$ref"
}

undo=""
for top in "${tops[@]}"; do
  if ref=$(snapshot "$top"); then
    undo+="In $top, undo with: git restore --source=$ref -- <path>. "
  else
    asks+=("the snapshot of $top failed")
  fi
done

if [ "${#asks[@]}" -gt 0 ]; then
  reason=$(printf '%s; ' "${asks[@]}")
  decide ask "Not undoable by snapshot: ${reason%; }" "$undo"
fi
decide allow "Snapshot saved" "$undo"
