#!/bin/bash
# Set up this config on a new device. Safe to re-run: every step is idempotent.
# Installs what it can without sudo, and prints the command for anything else.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
REPO=$(pwd)
BLOCKERS=0
SKILLS=(diagnosing-bugs grilling handoff research resolving-merge-conflicts writing-for-agents)

say()   { printf '  %-12s %s\n' "$1" "$2"; }
block() { say "$1" "MISSING  -> $2"; BLOCKERS=$((BLOCKERS + 1)); }
have()  { command -v "$1" >/dev/null 2>&1; }

if [ "$REPO" != "$HOME/.claude" ]; then
  echo "This repo must live at ~/.claude, not $REPO." >&2
  echo "Claude Code reads ~/.claude directly; a copy elsewhere drifts." >&2
  exit 1
fi

echo "Tools"
for t in git jq; do
  have "$t" && say "$t" "present" || block "$t" "sudo apt install -y $t"
done
for t in gh rg; do
  have "$t" && say "$t" "present" || say "$t" "absent (optional)"
done

if have node && have npm; then
  say "node/npm" "present  $(node -v) / npm $(npm -v)"
else
  block "node/npm" "install Node 20 or newer, then re-run"
fi

if have uvx; then
  say "uv" "present"
elif have curl; then
  say "uv" "installing..."
  curl -LsSf https://astral.sh/uv/install.sh | sh >/dev/null 2>&1
  have uvx && say "uv" "installed" || block "uv" "curl -LsSf https://astral.sh/uv/install.sh | sh"
else
  block "uv" "curl -LsSf https://astral.sh/uv/install.sh | sh"
fi

if have graft; then
  say "graft" "present  $(graft -v 2>/dev/null)"
elif have npm; then
  say "graft" "installing..."
  npm install -g @nanonets/graft >/dev/null 2>&1
  have graft && say "graft" "installed" || block "graft" "npm install -g @nanonets/graft"
fi

if have notify-send || have powershell.exe; then
  say "notify" "present"
else
  say "notify" "absent — the hook falls back to a terminal bell"
fi

echo
echo "Skills"
if have npx; then
  for s in "${SKILLS[@]}"; do
    if [ -f "$REPO/skills/$s/SKILL.md" ]; then
      say "$s" "present"
    else
      npx -y skills add "mattpocock/skills@$s" -g -y >/dev/null 2>&1 \
        && say "$s" "installed" || say "$s" "FAILED  -> npx skills add mattpocock/skills@$s -g -y"
    fi
  done
else
  block "npx" "install Node, then re-run"
fi

echo
echo "Permissions"
chmod +x hooks/*.sh statusline-command.sh scripts/*.sh 2>/dev/null
say "chmod +x" "hooks, status line, scripts"

echo
echo "Graft wiring"
if [ -f "$HOME/.claude/helpers/graft-hooks.cjs" ]; then
  say "shim" "present"
else
  say "shim" "absent -> run 'graft init' inside your first project, then re-run this script"
  BLOCKERS=$((BLOCKERS + 1))
fi
grep -q 'GRAFT_NO_STATUSLINE' settings.json \
  && say "statusline" "protected by GRAFT_NO_STATUSLINE" \
  || say "statusline" "GRAFT_NO_STATUSLINE missing from settings.json"

# Risk: if graft init runs at user level, then it rewrites these commands with an
# absolute /home/<user> path, which breaks on the next device.
if grep -q '"command": "node \\"/home/' settings.json; then
  python3 - <<'PY'
import json, collections, os
p = "settings.json"
s = json.load(open(p), object_pairs_hook=collections.OrderedDict)
home = os.path.expanduser("~")
def fix(o):
    if isinstance(o, dict):
        for k, v in o.items():
            if k == "command" and isinstance(v, str) and home in v:
                o[k] = v.replace(home, "$HOME")
            else:
                fix(v)
    elif isinstance(o, list):
        for v in o:
            fix(v)
fix(s)
open(p, "w").write(json.dumps(s, indent=2) + "\n")
PY
  say "paths" "rewrote absolute paths to \$HOME"
else
  say "paths" "no absolute paths in settings.json"
fi

echo
echo "Check"
if have jq; then
  out=$(printf '%s' '{"tool_input":{"command":"ls"}}' | ./hooks/block-dangerous-git.sh 2>&1; echo "rc=$?")
  case "$out" in
    *rc=0*) say "git guard" "allows a safe command" ;;
    *)      say "git guard" "FAILED: $out"; BLOCKERS=$((BLOCKERS + 1)) ;;
  esac
  out=$(printf '%s' '{"tool_input":{"command":"git reset --hard"}}' | ./hooks/block-dangerous-git.sh 2>&1; echo "rc=$?")
  case "$out" in
    *rc=2*) say "git guard" "blocks git reset --hard" ;;
    *)      say "git guard" "FAILED to block: $out"; BLOCKERS=$((BLOCKERS + 1)) ;;
  esac
fi

echo
if [ "$BLOCKERS" -eq 0 ]; then
  echo "Ready. Restart Claude Code so it loads settings, CLAUDE.md, rules, and the style."
else
  echo "$BLOCKERS blocker(s) above. Fix them, then re-run this script."
  exit 1
fi
