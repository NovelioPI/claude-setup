# Files

What each file in this repo does, how it loads, and which skills are tracked.

## Every file

| Path | Purpose |
|---|---|
| `settings.json` | Model, effort, output style, permission rules, hooks, status line |
| `CLAUDE.md` | Workflow contract: approval protocol, conversation flow, process gates |
| `rules/code-quality.md` | Coding, comment, typing, test, and file-layout rules |
| `rules/plain-words.md` | Word replacements for chat text and commit messages |
| `rules/commit-style.md` | Commit subject, body, word, and trailer rules |
| `rules/doc-style.md` | Style for a document a human reads |
| `guides/code-quality-python.md` | Python form of those rules |
| `guides/code-quality-typescript.md` | TypeScript and JavaScript form |
| `guides/code-quality-dart.md` | Dart form, with Flutter rules |
| `output-styles/plain-style.md` | Active chat output style: answer first, tables only to compare, simple English |
| `hooks/block-dangerous-git.sh` | `PreToolUse` guard: blocks unrecoverable git commands |
| `hooks/post-edit.sh` | `PostToolUse` check: formats and lints the edited file through the language adapter |
| `hooks/protect-signal.sh` | `PreToolUse` guard: blocks edits to files in a project's `.claude/protected-paths`, or to test files by name when no list exists |
| `hooks/commit-gate.sh` | `PreToolUse` guard: blocks a commit that changes, deletes, or renames protected files, then runs the stop gate |
| `hooks/protected-paths.sh` | Shared path check for the two guards above |
| `hooks/explorer-readonly.sh` | `PreToolUse` guard for the `explorer` agent: allows read-only Bash commands |
| `hooks/stop-gate.sh` | `Stop` check: runs the adapter's `check` on changed files; also blocks a new suppression comment without `Reason:` on its line; blocks a turn once, and a commit every time; skips when nothing changed since its last run, but a commit only after a pass |
| `hooks/notify.sh` | Notification hook: Linux notification, Windows toast, or a bell |
| `hooks/session-start.sh` | `SessionStart` hook: prints `.agent/progress.md` after start, compact, or clear |
| `commands/handoff.md` | `/handoff`: rewrites `.agent/progress.md` before a clear |
| `commands/plan-feature.md` | `/plan-feature`: drafts a Linear project and issues, creates them after a token |
| `commands/next-task.md` | `/next-task`: picks the next unblocked Linear issue of the feature; asks for a token before the work and before the commit |
| `commands/auto.md` | `/auto`: plans a task and runs it to the end under Auto Mode |
| `skills/project-init/SKILL.md` | `/project-init`: drafts a short project CLAUDE.md, then runs `/handoff` |
| `skills/tdd/` | `tdd`: red-green loop at agreed seams, only on `/tdd`; copied from `mattpocock/skills` commit `3f59913` (MIT) |
| `skills/ui-check/SKILL.md` | `ui-check`: open changed pages with Playwright, desktop and mobile screenshots, console errors |
| `skills/pr-flow/SKILL.md` | `pr-flow`: open a PR with `gh` after an approved push, watch CI, show failed logs |
| `skills/reui/` | `reui`: find, install, and use ReUI registry components through the ReUI MCP server |
| `skills/shadcn/` | `shadcn`: add, search, and compose shadcn/ui components; copied from `shadcn/ui` `skills/shadcn` |
| `agents/explorer.md` | Read-only subagent that searches the code and returns a report of 400 words or less |
| `statusline-command.sh` | Status line: model, effort, cache, usage bars |
| `scripts/quality.sh` | Language adapter: lint by language, format only with a project formatter config, Python silent errors, and limits of cognitive complexity 15, nesting 5, and 4 parameters (complexipy and ruff for Python, lizard for TS, JS, Kotlin, and C/C++); type-checks (mypy, or pyright with a pyright config), runs `tests/unit`, and runs `vitest --changed` |
| `scripts/install.sh` | Set up a new device; safe to re-run |
| `scripts/test-explorer-readonly.sh` | Regression test for `hooks/explorer-readonly.sh`: pipes inside quotes, and commands it must block |
| `scripts/probe-context-floor.sh` | Check that `rules/` stayed small and the guide pointer fires |
| `wiki/` | These detail pages; `README.md` links to each one |
| `LICENSE` | MIT |

## How rules and guides load

Claude Code auto-loads every file under `rules/` with no import line needed. `plain-words.md` and `commit-style.md` load in every session. `code-quality.md` and `doc-style.md` have `paths:` frontmatter, so each loads only when Claude reads or edits a matching code or Markdown file. A Bash heredoc write does not trigger them. `guides/` is never auto-loaded: a pointer in `rules/code-quality.md` sends the agent there on its first edit in that language.

An output style file does nothing on its own. `settings.json` activates one with `"outputStyle": "plain-style"`.

## Skills

This repo tracks only the skills written here: `brainstorming`, `project-init`, `ui-check`, and `pr-flow`. Other skills are other people's work, so they are not redistributed.

| Skill | Source |
|---|---|
| `impeccable`, and the `agents/impeccable-*.md` it dispatches | installed separately, not tracked here |

`~/.claude/skills/` is otherwise excluded, with a negation for each tracked skill. Every entry is a real directory, never a symlink.

A skill's own instructions never override the approval protocol in `CLAUDE.md`. Several of them tell the agent to dispatch a subagent or to not block, and `CLAUDE.md` has a clause that overrules them.

## Notes

- `settings.json` carries no secrets and no tokens. Machine-local settings live in `settings.local.json`, which is not tracked.
- `hooks/notify.sh` sends a WinRT toast under the registered Windows PowerShell AppId. A `NotifyIcon` balloon does not work: Windows 11 accepts the call, returns success, and shows nothing.
- This repo excludes `~/.claude/projects/*/memory/`. Those memory files are tied to session-specific paths on the machine that wrote them.
