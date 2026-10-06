#!/bin/bash
# PreToolUse hook for read-only agents (explorer, reviewer): allow only read-only Bash commands.
# Exit 2 blocks the call. A command not on the allowlist is blocked.

block() {
  echo "this agent is read-only: $1" >&2
  exit 2
}

command -v jq >/dev/null 2>&1 || block "jq is missing, so the command cannot be checked"
cmd=$(jq -r '.tool_input.command // empty')
[ -n "$cmd" ] || block "empty command"

# Reason: these characters chain, redirect, or substitute commands past the allowlist.
case "$cmd" in
  # Risk: if $'...' were allowed, then its \' would hide a real pipe from the split below.
  *';'* | *'&'* | *'>'* | *'<'* | *'$('* | *'${'* | *'$['* | *"\$'"* | *'`'* | *$'\n'*)
    block "the command uses ; & > < \$( \${ \$[ \$' \` or a newline" ;;
esac

# Reason: a | inside quotes, such as grep -E "a|b", is an argument, not a pipe.
stages=()
stage=""
quote=""
escaped=false
for ((i = 0; i < ${#cmd}; i++)); do
  c=${cmd:i:1}
  if $escaped; then
    escaped=false
  elif [ "$c" = '\' ] && [ "$quote" != "'" ]; then
    escaped=true
  elif [ -n "$quote" ]; then
    [ "$c" = "$quote" ] && quote=""
  elif [ "$c" = "'" ] || [ "$c" = '"' ]; then
    quote=$c
  elif [ "$c" = '|' ]; then
    stages+=("$stage")
    stage=""
    continue
  fi
  stage+=$c
done
[ -z "$quote" ] && ! $escaped || block "the command has an unclosed quote or a trailing backslash"
stages+=("$stage")

for stage in "${stages[@]}"; do
  read -ra words <<< "$stage"
  [ "${#words[@]}" -gt 0 ] || block "empty pipe stage"
  # Reason: a full path to the system git skips the RTK rewrite, which hides detail.
  case "${words[0]}" in /usr/bin/git | /bin/git | /usr/local/bin/git | /opt/homebrew/bin/git) words[0]=git ;; esac
  # Reason: bash removes quotes and backslashes before it runs, so check the text without them.
  plain=" ${stage//[\'\"\\]/} "
  case "${words[0]}" in
    grep | ls | wc | head) continue ;;
    tail)
      [[ "$plain" =~ [[:space:]]-[a-zA-Z0-9]*[fF][a-zA-Z0-9]*[[:space:]] || "$plain" == *--follow* ]] && block "tail -f never returns"
      continue ;;
    rg | find | git) ;;
    *) block "${words[0]} is not on the allowlist" ;;
  esac
  [[ "$stage" == *'$'* ]] && block "\$ is not allowed in rg, find, or git"
  case "${words[0]}" in
    rg)
      [[ "$plain" == *--pre* ]] && block "rg --pre runs a command" ;;
    find)
      case "$plain" in
        *-exec* | *-ok* | *-delete* | *-fprint* | *-fls*) block "find option runs a command or writes a file" ;;
      esac ;;
    git)
      case "${words[1]}" in
        log | show | blame | diff | status | ls-files | grep) ;;
        *) block "git ${words[1]} is not on the allowlist" ;;
      esac
      # Reason: git accepts any unique prefix of a long option, such as --outp for --output.
      [[ "$plain" == *[[:space:]]--o[pu]* || "$plain" == *-O* ]] &&
        block "this git option writes a file or runs a program" ;;
  esac
done
exit 0
