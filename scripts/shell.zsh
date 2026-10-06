# Shell launchers that start Claude Code in a TASK_MODE. Source from ~/.zshrc.
# Reason: hooks read TASK_MODE from the claude process, so it must be set at launch.

# usage: ccf <feature> [mode]   modes: impl (default), tests, baseline
ccf() {
  local id="$1" mode="${2:-impl}"
  if [ -n "$id" ]; then
    TASK_MODE="$mode" CLAUDE_CODE_TASK_LIST_ID="$id" claude
  else
    TASK_MODE="$mode" claude
  fi
}

# usage: cct [claude arguments]   starts a tests session
cct() {
  TASK_MODE=tests claude "$@"
}
