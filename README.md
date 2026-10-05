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
| `output-styles/technical-style.md` | Older ASD-STE100 style, kept as a fallback |
| `hooks/block-dangerous-git.sh` | `PreToolUse` guard: blocks unrecoverable git commands |
| `hooks/explorer-readonly.sh` | `PreToolUse` guard for the `explorer` agent only: allows read-only Bash commands |
| `hooks/check-complexity.sh` | `PostToolUse` check: cognitive complexity and nesting depth on Python |
| `hooks/notify.sh` | Notification hook: Linux notification, Windows toast, or a bell |
| `hooks/pre-compact.sh` | `PreCompact` hook: saves git state and the transcript to `.agent/` |
| `hooks/session-start.sh` | `SessionStart` hook: prints `.agent/progress.md` after start, compact, or clear |
| `commands/handoff.md` | `/handoff`: rewrites `.agent/progress.md` before a clear |
| `commands/reflect.md` | `/reflect`: proposes lessons for `.agent/lessons.md` |
| `skills/project-init/SKILL.md` | `/project-init`: drafts a short project CLAUDE.md, then runs `/handoff` |
| `agents/explorer.md` | Read-only subagent that searches the code and returns a report of 400 words or less |
| `statusline-command.sh` | Status line: model, effort, cache, usage bars |
| `scripts/install.sh` | Set up a new device; safe to re-run |
| `scripts/probe-context-floor.sh` | Check that `rules/` stayed small and the guide pointer fires |
| `LICENSE` | MIT |

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
4. Fix anything it reports as a blocker, then run it again.
5. Restart Claude Code so it loads the settings, `CLAUDE.md`, the rules, and the style.

### What the installer needs

| Tool | Used by | Installed by the script |
|---|---|---|
| `git` | the clone | no, needs sudo |
| `jq` | the hooks and the status line | no, needs sudo |
| `node`, `npm` | `npx skills` | no |
| `uv` | `check-complexity.sh`, which runs `complexipy` and `ruff` through `uvx` | yes |
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
