# claude-setup

My global Claude Code config at `~/.claude/`.

## Features

| Feature | What it does |
|---|---|
| Approval protocol | The agent shows a plan and waits for a clear "go". `Auto` runs one plan to the end |
| Code and doc rules | Readable code, few comments, plain words, short commit messages |
| Quality hooks | Format and lint after each edit; type checks and tests before a turn ends |
| Guards | Block unrecoverable git commands and edits to protected test files |
| Plain chat style | Answer first, tables over prose, short sentences |
| Linear | `/plan-feature` drafts issues; `/next-task` picks the next one |
| `ui-check` | Opens changed pages with Playwright: screenshots and console errors |
| ReUI | Finds and installs ReUI registry components through MCP |
| shadcn | Adds and composes shadcn/ui components through MCP and a skill |
| `pr-flow` | Opens a PR with `gh` after an approved push, then watches CI |
| TDD | `/tdd` runs a red-green loop, only when you call it |
| Ponytail | Plugin that asks for the smallest change that solves the task |

## Setup

This repo **is** `~/.claude`. Clone it into place; do not copy files out of it.

1. Install Claude Code and run it once, so `~/.claude/` exists.
2. Move the generated folder aside and clone in its place:
   ```bash
   mv ~/.claude ~/.claude.bak
   git clone git@github.com:NovelioPI/claude-setup.git ~/.claude
   cp -r ~/.claude.bak/projects ~/.claude/ 2>/dev/null
   ```
3. Run the installer. It checks every tool and installs what needs no sudo:
   ```bash
   ~/.claude/scripts/install.sh
   ```
4. Fix anything it reports as a blocker, then run it again.
5. Restart Claude Code.

## Workflow

Start `claude` in the repo.

1. Describe the task. The agent shows a plan.
2. Approve with "go", or with `Auto` to run to the end.
3. The agent writes the code and runs the checks.
4. It reports what changed and what it was unsure about, then proposes a commit.
5. For review, run `pr-flow`: it asks before the push and watches CI.

## More

| Page | Covers |
|---|---|
| [wiki/design.md](wiki/design.md) | Why it looks like this; what to copy; who it is not for |
| [wiki/files.md](wiki/files.md) | Every file, how rules and guides load, tracked skills |
| [wiki/guardrails.md](wiki/guardrails.md) | The git guard, the quality adapter, protected paths, known gaps |
| [wiki/installer.md](wiki/installer.md) | What the installer checks and installs |

MIT licensed.
