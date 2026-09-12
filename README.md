# claude-code-setup

Personal global config for Claude Code (`~/.claude/`). Private repo — the setup
is personal, not a public dotfiles project.

Target platform is WSL2 on Windows. The notification hook uses Windows interop.

## What is in here

| File | Target path | Purpose |
|---|---|---|
| `settings.json` | `~/.claude/settings.json` | Model, effort, output style, permission rules, hooks, status line, attribution |
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | Workflow contract: approval protocol, conversation flow, process gates |
| `rules/code-quality.md` | `~/.claude/rules/code-quality.md` | Coding, comment, typing, test, file-layout rules — imported by CLAUDE.md |
| `rules/plain-words.md` | `~/.claude/rules/plain-words.md` | Word replacements for chat text and commit messages — imported by CLAUDE.md |
| `rules/commit-style.md` | `~/.claude/rules/commit-style.md` | Commit subject, body, word, and trailer rules — imported by CLAUDE.md |
| `rules/doc-style.md` | `~/.claude/rules/doc-style.md` | Style for a document a human reads — imported by CLAUDE.md |
| `output-styles/plain-style.md` | `~/.claude/output-styles/plain-style.md` | Active chat output style: two fixed shapes, simple English |
| `output-styles/technical-style.md` | `~/.claude/output-styles/technical-style.md` | Older ASD-STE100 chat output style, kept as a fallback |
| `hooks/block-dangerous-git.sh` | `~/.claude/hooks/block-dangerous-git.sh` | `PreToolUse` guard: blocks unrecoverable git commands |
| `hooks/notify.sh` | `~/.claude/hooks/notify.sh` | Notification hook: Windows toast through WSL interop |
| `statusline-command.sh` | `~/.claude/statusline-command.sh` | Status line script |
| `plans/archive/` | `~/.claude/plans/archive/` | Finished planning notes, kept for history |

An output style file is inert on its own. `settings.json` activates one with
`"outputStyle": "plain-style"`.

## Setup on a new device

1. Install Claude Code and run it once, so `~/.claude/` exists.
2. Clone this repo, then copy the files to their target paths:
   ```
   cp settings.json ~/.claude/settings.json
   cp CLAUDE.md ~/.claude/CLAUDE.md
   mkdir -p ~/.claude/rules ~/.claude/hooks ~/.claude/output-styles ~/.claude/plans
   cp rules/code-quality.md ~/.claude/rules/code-quality.md
   cp hooks/block-dangerous-git.sh ~/.claude/hooks/block-dangerous-git.sh
   cp hooks/notify.sh ~/.claude/hooks/notify.sh
   cp output-styles/technical-style.md ~/.claude/output-styles/technical-style.md
   cp statusline-command.sh ~/.claude/statusline-command.sh
   cp -r plans ~/.claude/plans
   ```
3. Make the scripts executable:
   ```
   chmod +x ~/.claude/hooks/block-dangerous-git.sh \
            ~/.claude/hooks/notify.sh \
            ~/.claude/statusline-command.sh
   ```
4. Install `jq`. Both hooks need it.
5. Restart Claude Code so it loads the new settings, CLAUDE.md, rules, and style.

## Guardrails

Two layers guard the destructive commands, and the overlap is on purpose.

`hooks/block-dangerous-git.sh` runs as a `PreToolUse` hook on every Bash call and
exits 2 to block. It guards `git reset --hard`, `git clean` with a force flag,
`git branch -D`, and a whole-tree `git checkout` or `git restore`. It matches each
chained segment at its own start, so a guarded string quoted inside another
command does not trip it. Without `jq` it blocks every Bash call, by design.

`git push` is **not** guarded, on purpose. A guardrail that blocks a command you
use every day teaches you to route around the guardrail.

The `permissions.ask` list in `settings.json` is the second layer. It prompts for
`git stash`, a path-scoped `git checkout` or `git restore`, and `rm`. It still
lists the commands the hook already blocks: if the hook loses its execute bit,
that list is the only guard left.

Test the hook after any edit:
```
printf '%s' '{"tool_input":{"command":"ls"}}' | ~/.claude/hooks/block-dangerous-git.sh
```

## Notes

- `settings.json` has no secrets or tokens — verified before this repo was created.
- `hooks/notify.sh` sends a WinRT toast under the registered Windows PowerShell
  AppId. A `NotifyIcon` balloon does not work: Windows 11 accepts the call, returns
  success, and shows nothing.
- This repo excludes `~/.claude/projects/*/memory/`: those memory files are tied
  to session-specific paths on the machine that wrote them, and are not portable.

## Skills

`~/.claude/skills/` is mostly excluded from this repo (see `.gitignore`), with a
negation for each skill that is tracked. Every entry is a **real directory**, not
a symlink.

Two skills are written here and tracked in full:

| Skill | Purpose |
|---|---|
| `todo-plan` | Create `TODO.md`, a single-file project plan |
| `todo-update` | Maintain `TODO.md`: move rows, file new scope, recount |

The rest come from the Skills CLI (`npx skills`, see https://skills.sh/).
Reinstall them on a new device:

```bash
npx skills add mattpocock/skills@diagnosing-bugs -g -y
npx skills add mattpocock/skills@grilling -g -y
npx skills add mattpocock/skills@handoff -g -y
npx skills add mattpocock/skills@research -g -y
npx skills add mattpocock/skills@resolving-merge-conflicts -g -y
npx skills add mattpocock/skills@writing-for-agents -g -y
```

A skill's own instructions never override the approval protocol in `CLAUDE.md`.
Several of these skills tell the agent to dispatch a sub-agent or to not block;
`CLAUDE.md` has an explicit clause that overrules them.
