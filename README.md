# claude-setup

My global Claude Code config, living at `~/.claude/`. I am publishing it
because most of it is decisions, not settings.

## Why it looks like this

An agent writes code faster than I can read it. That is the whole problem.
Speed was never my bottleneck. My review was.

So the work went into three things. A contract that says when the agent may
act. Rules that make what it writes readable on the first pass. A loop that
proves a change works before I look at it.

Everything here follows from that. If you disagree with the premise, most of
these files will look like too much process.

## What is different here

**The agent waits for a word.** Not "yes", not "sounds good", but the literal
token `Go` or `Execute`. One token approves one plan, and the token dies when
the plan changes. `CLAUDE.md` calls this failing closed.

**Comments are off by default.** A comment earns its place by naming a hidden
constraint or a risk, in 20 words or fewer. Everything else is the code
restating itself.

**Short words are enforced.** `rules/plain-words.md` is a replacement table for
chat text and commit messages. Write "use", not "leverage". Write "start", not
"spin up".

**Two guards on destructive git, and one deliberate gap.** A hook blocks the
unrecoverable commands. `git push` is not blocked, on purpose. A guardrail you
hit every day teaches you to route around it.

## Take what you want

Most of this works in pieces. Copy one file and ignore the rest. MIT licensed,
so take it without asking.

| Piece | Standalone | Needs |
|---|---|---|
| `rules/plain-words.md` | yes | nothing |
| `rules/code-quality.md` and its language files | yes | nothing |
| `output-styles/plain-style.md` | yes | one key in `settings.json` |
| `hooks/block-dangerous-git.sh` | yes | `jq` |
| The approval protocol in `CLAUDE.md` | yes | your patience |

## Not for you if

- You dislike typing a literal word before every write.
- You want a short config. About 3,500 words load on every turn, and the
  language guides add 5,500 more when you touch that language.

## What is in here

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
| `guides/code-quality-cpp.md` | C and C++ form |
| `guides/code-quality-kotlin.md` | Kotlin form, with coroutine and flow rules |
| `guides/code-quality-dart.md` | Dart form, with Flutter rules |
| `output-styles/plain-style.md` | Active chat output style: two fixed shapes, simple English |
| `hooks/block-dangerous-git.sh` | `PreToolUse` guard: blocks unrecoverable git commands |
| `hooks/post-edit.sh` | `PostToolUse` check: formats and lints the edited file through the language adapter |
| `hooks/protect-signal.sh` | `PreToolUse` guard: blocks edits to files in a project's `.claude/protected-paths`, or to test files by name when no list exists |
| `hooks/commit-gate.sh` | `PreToolUse` guard: blocks a commit that changes, deletes, or renames protected files, then runs the stop gate |
| `hooks/protected-paths.sh` | Shared path check for the two guards above |
| `hooks/explorer-readonly.sh` | `PreToolUse` guard for the `explorer` and `reviewer` agents: allows read-only Bash commands |
| `hooks/stop-gate.sh` | `Stop` check: runs the adapter's `check` on changed files; also blocks a new suppression comment without `Reason:` on its line; blocks a turn once, and a commit every time; skips when nothing changed since its last run, but a commit only after a pass |
| `hooks/notify.sh` | Notification hook: Linux notification, Windows toast, or a bell |
| `hooks/session-start.sh` | `SessionStart` hook: prints `.agent/progress.md` after start, compact, or clear |
| `commands/handoff.md` | `/handoff`: rewrites `.agent/progress.md` before a clear |
| `commands/reflect.md` | `/reflect`: proposes lessons for `.agent/lessons.md` |
| `commands/check-task.md` | `/check-task`: reviews the diff, fixes Critical and Major findings, reports the rest |
| `commands/walkthrough.md` | `/walkthrough`: checks that I understand a change before the commit; logs PASS or GAPS |
| `commands/plan-feature.md` | `/plan-feature`: drafts a spec and a task graph, writes after a token |
| `commands/next-task.md` | `/next-task`: picks the next task for the session mode; asks for a token before the work and before the commit |
| `skills/project-init/SKILL.md` | `/project-init`: drafts a short project CLAUDE.md, then runs `/handoff` |
| `agents/explorer.md` | Read-only subagent that searches the code and returns a report of 400 words or less |
| `agents/reviewer.md` | Read-only subagent that reviews a diff and returns ranked findings |
| `statusline-command.sh` | Status line: model, effort, cache, usage bars |
| `scripts/quality.sh` | Language adapter: lint by language, format only with a project formatter config, Python silent errors, and limits of cognitive complexity 15, nesting 5, and 4 parameters (complexipy and ruff for Python, lizard for TS, JS, Kotlin, and C/C++); type-checks (mypy, or pyright with a pyright config), runs `tests/unit`, and runs `vitest --changed` |
| `scripts/install.sh` | Set up a new device; safe to re-run |
| `scripts/debt-report.sh` | Print the Step 11 cognitive debt numbers: fix commits without a root cause, walkthrough results |
| `scripts/shell.zsh` | Shell launchers: `cct` starts a `TASK_MODE=tests` session; `ccf <feature> [mode]` adds a shared task list |
| `scripts/test-explorer-readonly.sh` | Regression test for `hooks/explorer-readonly.sh`: pipes inside quotes, and commands it must block |
| `scripts/probe-context-floor.sh` | Check that `rules/` stayed small and the guide pointer fires |
| `LICENSE` | MIT |

An executable `.claude/quality.sh` in a project replaces `scripts/quality.sh` for that project.
The hooks use it only when git tracks it and it is unchanged from HEAD.
It must give all three subcommands: `format <file>`, `lint <file>`, and `check <files...>`.
Both guards always protect it, so Claude cannot edit or commit it outside `TASK_MODE=tests`.
A committed adapter in a cloned repo runs on every edit with no prompt.

`.claude/protected-paths` in a project holds one glob per line, relative to the project, where `*` also matches `/`.
A line with no wildcard, such as `tests/conftest.py`, also blocks creating that file.
A project with no list gets the default test patterns in `hooks/protected-paths.sh`, such as `tests/*` and `*.test.*`.
They block edits to existing test files, not new ones, except `conftest.py` at the root or directly in `tests/` or `test/`, which they also block from being created.
A list with no patterns, empty or only comments, turns them off.
The commit gate also checks unstaged changes, so a changed protected file, including one you edited, blocks every commit made through Claude until you restore or commit it yourself.
Start a session with `TASK_MODE=tests` to edit those files. A gate that runs past its 300-second timeout lets the action go through.

Known gaps in the guards:

- `commit-gate.sh` matches commit commands by pattern. Forms such as `{ git commit; }`, `timeout 60 git commit`, a git alias, `merge`, and `rebase` get past it.
- Both guards check the project in `CLAUDE_PROJECT_DIR`, not a repo named by `git -C` or `cd`.
- On a case-insensitive drive such as `/mnt/c`, a path with different letter case gets past `protect-signal.sh`.
- `stop-gate.sh` keeps its last result in `claude-stop-gate` in the git dir. A change to a git-ignored file, a tool, `.venv`, or `node_modules` does not rerun it.
- `scripts/quality.sh` runs `ruff check --fix` and `ktlint -F` even with no project config.

Claude Code auto-loads every file under `rules/` into every session and every
subagent, with no import line needed. `guides/` is the opposite: nothing loads
it, and a pointer in `rules/code-quality.md` sends the agent there on its first
edit in that language. That split is worth about 5,500 words per context.

An output style file does nothing on its own. `settings.json` activates one with
`"outputStyle": "plain-style"`.

## Setup on a new device

This repo **is** `~/.claude`. Clone it into place; do not copy files out of it.

1. Install Claude Code and run it once, so `~/.claude/` exists.
2. Move the generated directory aside and clone in its place:
   ```bash
   mv ~/.claude ~/.claude.bak
   git clone git@github.com:NovelioPI/claude-setup.git ~/.claude
   cp -r ~/.claude.bak/projects ~/.claude/ 2>/dev/null
   ```
3. Run the installer, which checks every tool and installs what needs no sudo:
   ```bash
   ~/.claude/scripts/install.sh
   ```
   Add `--lsp` to install language servers and their plugins, for example
   `--lsp python,go` or `--lsp all`. The names are `python`, `typescript`,
   `go`, `cpp`, `kotlin`, and `dart`.
4. Fix anything it reports as a blocker, then run it again.
5. Restart Claude Code so it loads the settings, `CLAUDE.md`, the rules, and the style.

### What the installer needs

| Tool | Used by | Installed by the script |
|---|---|---|
| `git` | the clone | no, needs sudo |
| `jq` | the hooks and the status line | no, needs sudo |
| `node`, `npm` | `npx skills` | no |
| `uv` | `scripts/quality.sh`, which runs `ruff`, `complexipy`, and `lizard` through `uvx` | yes |
| `rtk` | the `PreToolUse` hook in `settings.json` that shortens Bash output | yes, by brew or a checked GitHub release |
| `pyright`, `typescript-language-server`, `gopls` | the LSP plugins in `enabledPlugins`, which give the `LSP` tool to `explorer` | with `--lsp`; Go itself too, if missing |
| `clangd`, `kotlin-lsp`, `dart` | the C/C++, Kotlin, and Dart LSP plugins; Dart uses `lsp-plugins/`, a local marketplace | with `--lsp`: clangd on Linux and macOS, kotlin-lsp on Linux; `dart` comes with Flutter |
| `gh`, `rg` | optional convenience | no |

## Skills

This repo tracks only the skills written here: `brainstorming` and
`project-init`. Other skills are
other people's work, so they are not redistributed.

| Skill | Source |
|---|---|
| `impeccable`, and the `agents/impeccable-*.md` it dispatches | installed separately, not tracked here |

`~/.claude/skills/` is otherwise excluded, with a negation for each tracked
skill. Every entry is a real directory, never a symlink.

A skill's own instructions never override the approval protocol in `CLAUDE.md`.
Several of them tell the agent to dispatch a subagent or to not block, and
`CLAUDE.md` has a clause that overrules them.

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

`scripts/install.sh` tests both directions of the guard on every run.

## Notes

- `settings.json` carries no secrets and no tokens. Machine-local settings live
  in `settings.local.json`, which is not tracked.
- `hooks/notify.sh` sends a WinRT toast under the registered Windows PowerShell
  AppId. A `NotifyIcon` balloon does not work: Windows 11 accepts the call,
  returns success, and shows nothing.
- This repo excludes `~/.claude/projects/*/memory/`. Those memory files are tied
  to session-specific paths on the machine that wrote them.
