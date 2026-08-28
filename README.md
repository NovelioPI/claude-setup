# claude-code-setup

Personal global config for Claude Code (`~/.claude/`). Private repo — the setup
is personal, not a public dotfiles project.

## What is in here

| File | Target path | Purpose |
|---|---|---|
| `settings.json` | `~/.claude/settings.json` | Status line, output style, permission rules, attribution, hooks |
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | Workflow contract: approval protocol, process rules |
| `rules/code-quality.md` | `~/.claude/rules/code-quality.md` | Coding, comment, typing, test, file-layout rules — imported by CLAUDE.md |
| `output-styles/technical-style.md` | `~/.claude/output-styles/technical-style.md` | ASD-STE100 chat output style |
| `hooks/notify.sh` | `~/.claude/hooks/notify.sh` | Notification hook: macOS alert + sound |
| `statusline-command.sh` | `~/.claude/statusline-command.sh` | Status line script |
| `plans/coding-style-improvements.md` | `~/.claude/plans/coding-style-improvements.md` | Working notes on the coding-style rollout |

## Setup on a new device

1. Install Claude Code and run it once, so `~/.claude/` exists.
2. Clone this repo, then copy the files to their target paths:
   ```
   cp settings.json ~/.claude/settings.json
   cp CLAUDE.md ~/.claude/CLAUDE.md
   mkdir -p ~/.claude/rules ~/.claude/hooks ~/.claude/output-styles ~/.claude/plans
   cp rules/code-quality.md ~/.claude/rules/code-quality.md
   cp hooks/notify.sh ~/.claude/hooks/notify.sh
   cp output-styles/technical-style.md ~/.claude/output-styles/technical-style.md
   cp statusline-command.sh ~/.claude/statusline-command.sh
   cp plans/coding-style-improvements.md ~/.claude/plans/coding-style-improvements.md
   ```
3. Make the scripts executable:
   ```
   chmod +x ~/.claude/hooks/notify.sh ~/.claude/statusline-command.sh
   ```
4. Restart Claude Code so it loads the new settings, CLAUDE.md, and rules.

## Notes

- `settings.json` has no secrets or tokens — verified before this repo was created.
- The `notify.sh` hook uses `osascript` and `afplay`, both macOS-only.
- This repo excludes `~/.claude/projects/*/memory/`: those memory files are tied
  to session-specific paths on the machine that wrote them, and are not portable.
