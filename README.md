# claude-setup

My global Claude Code config at `~/.claude/`.

## Features

| Feature | What it does |
|---|---|
| Code and doc rules | Readable code, few comments, plain words, short commit messages |
| Quality hooks | Format after each edit; lint and limits before a commit; type checks and tests before a turn ends |
| Guards | Block unrecoverable git commands and edits to protected test files |
| Plain chat style | Answer first, tables over prose, short sentences |
| `cc` alias | `cc` starts `claude --dangerously-skip-permissions`; deny rules and blocking hooks still apply |
| `feature` | Turns an idea into intent, spec, and plan files; you approve and it commits each one, then it builds and verifies |
| Project tiers | A `Tier: small` or `Tier: large` line in the project `CLAUDE.md`; `rules/project-tiers.md` says what each uses. `small` writes intent and plan out of git; `large` runs the full `feature` skill with Linear |
| Linear | Off by default; on in each `large` project. The `feature` skill sets each issue's status through the Linear MCP |
| `attribution` | `/attribution on` or `off` turns the Claude co-author trailer on or off |
| Verification | `verify-this` gives VERIFIED, NOT VERIFIED, or INCONCLUSIVE from a fresh subagent; `control-ui` and `control-cli` drive the app |
| Project verifier | `/create-verification-skill` writes a `verify-<app>` skill for each project |
| `deslop` | Removes AI code slop from the branch diff |
| TDD | `/tdd` runs a red-green loop, only when you call it |

## Setup

This repo **is** `~/.claude`. Clone it into place; do not copy files out of it.

1. Install Claude Code and run it once, so `~/.claude/` exists.
2. Move the generated folder aside and clone in its place:
   ```bash
   mv ~/.claude ~/.claude.bak
   git clone git@github.com:NovelioPI/claude-setup.git ~/.claude
   cp -r ~/.claude.bak/projects ~/.claude/ 2>/dev/null
   ```
3. Run the installer. It checks every tool, installs what needs no sudo, and adds the `cc` alias to your shell rc file:
   ```bash
   ~/.claude/scripts/install.sh
   ```
4. Fix anything it reports as a blocker, then run it again.
5. Restart Claude Code.
6. In Linear, give your team the statuses Backlog, Planning, Ready, Building, Verifying, Done, and Canceled, and make one project per repo. Add a saved view of issues in Verifying, your review queue. In Settings → Team → Workflows & automations, set auto-archive to the shortest period, to help keep the Free plan under its 250-issue cap.

## Workflow

Start `claude`, or `cc` to skip permission prompts, in the repo. Set its tier once: `Tier: small` or `Tier: large` in the project `CLAUDE.md`.

1. Describe the task. For a feature, the `feature` skill writes intent, spec, and plan, and you approve each one.
2. The agent writes the code and runs the checks.
3. The `verifier` agent checks the change in a fresh context and gives a verdict with evidence.
4. It reports what changed and what it was unsure about, then proposes a commit.

## More

| Page | Covers |
|---|---|
| [wiki/design.md](wiki/design.md) | Why it looks like this; what to copy; who it is not for |
| [wiki/files.md](wiki/files.md) | Every file, how rules and guides load, tracked skills |
| [wiki/guardrails.md](wiki/guardrails.md) | The git guard, the quality adapter, protected paths, known gaps |
| [wiki/installer.md](wiki/installer.md) | What the installer checks and installs |

MIT licensed.
