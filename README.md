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

## Skills setup

`~/.claude/skills/` is excluded from this repo (see `.gitignore`) — every entry
in it is a symlink into `~/.agents/skills/`, which lives outside `~/.claude/`.
On a new device, reinstall the skills with the Skills CLI (`npx skills`, see
https://skills.sh/) — this recreates `~/.agents/skills/<name>/` and the
matching symlink under `~/.claude/skills/`:

```bash
npx skills add mattpocock/skills@ask-matt -g -y
npx skills add mattpocock/skills@claude-handoff -g -y
npx skills add mattpocock/skills@code-review -g -y
npx skills add mattpocock/skills@codebase-design -g -y
npx skills add mattpocock/skills@diagnosing-bugs -g -y
npx skills add mattpocock/skills@domain-modeling -g -y
npx skills add mattpocock/skills@git-guardrails-claude-code -g -y
npx skills add mattpocock/skills@grill-me -g -y
npx skills add mattpocock/skills@grill-with-docs -g -y
npx skills add mattpocock/skills@grilling -g -y
npx skills add mattpocock/skills@handoff -g -y
npx skills add mattpocock/skills@implement -g -y
npx skills add mattpocock/skills@implement-spec -g -y
npx skills add mattpocock/skills@improve-codebase-architecture -g -y
npx skills add mattpocock/skills@loop-me -g -y
npx skills add mattpocock/skills@migrate-to-shoehorn -g -y
npx skills add mattpocock/skills@prototype -g -y
npx skills add mattpocock/skills@research -g -y
npx skills add mattpocock/skills@resolving-merge-conflicts -g -y
npx skills add mattpocock/skills@retro -g -y
npx skills add mattpocock/skills@scaffold-exercises -g -y
npx skills add mattpocock/skills@setup-matt-pocock-skills -g -y
npx skills add mattpocock/skills@setup-pre-commit -g -y
npx skills add mattpocock/skills@setup-ts-deep-modules -g -y
npx skills add mattpocock/skills@tdd -g -y
npx skills add mattpocock/skills@teach -g -y
npx skills add mattpocock/skills@to-questionnaire -g -y
npx skills add mattpocock/skills@to-spec -g -y
npx skills add mattpocock/skills@to-tickets -g -y
npx skills add mattpocock/skills@triage -g -y
npx skills add mattpocock/skills@wait-what -g -y
npx skills add mattpocock/skills@wayfinder -g -y
npx skills add mattpocock/skills@wizard -g -y
npx skills add mattpocock/skills@writing-beats -g -y
npx skills add mattpocock/skills@writing-for-agents -g -y
npx skills add mattpocock/skills@writing-fragments -g -y
npx skills add mattpocock/skills@writing-shape -g -y
npx skills add vercel-labs/skills@find-skills -g -y
```

`skills/tabbit` is not managed by the Skills CLI (it has no entry in
`~/.agents/.skill-lock.json`). It's a real directory, installed and kept in
sync automatically by the Tabbit Browser app (marked `.tabbit-dance-managed`).
Install/run that app on the new device to regenerate it.
