# claude-setup

My Claude Code setup: a plugin, plus the rules and config it works with. I am
publishing it because most of it is decisions, not settings.

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

**A milestone closes on an exit code.** Each GitHub milestone
names a command in its description. The loop stops when that command returns 0. It never
stops because the agent decided it was finished.

**Comments are off by default.** A comment earns its place by naming a hidden
constraint or a risk, in 20 words or fewer. Everything else is the code
restating itself.

**Short words are enforced.** `rules/plain-words.md` is a replacement table for
chat text and commit messages. Write "use", not "leverage". Write "start", not
"spin up".

**Two guards on destructive git, and one deliberate gap.** A hook blocks the
unrecoverable commands. `git push` is not blocked, on purpose. A guardrail you
hit every day teaches you to route around it.

**The rules cite their sources.** `plans/` holds the research behind each
threshold. The cognitive complexity cap of 15 is SonarSource's own default, and
`plans/research-quality-metrics.md` records why cyclomatic complexity is not
used as a limit.

**Reviews are triggered, not routine.** `/code-review` and `/simplify` run when
a change touches an invariant, an exported symbol, or five files. A one-file fix
with a green suite runs neither.

## Take what you want

Most of this works in pieces. Copy one file and ignore the rest. MIT licensed,
so take it without asking.

| Piece | Standalone | Needs |
|---|---|---|
| `rules/plain-words.md` | yes | nothing |
| `rules/code-quality.md` and its language files | yes | nothing |
| `output-styles/plain-style.md` | yes | one key in `settings.json` |
| `plugin/hooks/block-dangerous-git.sh` | yes | `jq` |
| `skills/issue-plan`, `skills/issue-update` | yes | nothing |
| The approval protocol in `CLAUDE.md` | yes | your patience |
| `skills/milestone-run` | no | the full skill chain and an acceptance command per row |

## Not for you if

- You want the agent to run unattended without writing an acceptance command
  for each task.
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
| `guides/agent-brief.md` | The compact working core a dispatched subagent reads |
| `output-styles/plain-style.md` | Active chat output style: two fixed shapes, simple English |
| `output-styles/technical-style.md` | Older ASD-STE100 style, kept as a fallback |
| `agents/implementer.md` | Subagent that builds one GitHub issue and returns a verdict |
| `agents/reviewer.md` | Subagent that reviews a diff and returns ranked findings |
| `plugin/hooks/block-dangerous-git.sh` | `PreToolUse` guard: blocks unrecoverable git commands |
| `plugin/hooks/check-complexity.sh` | `PostToolUse` check: cognitive complexity and nesting depth on Python |
| `plugin/hooks/notify.sh` | Notification hook: Linux notification, Windows toast, or a bell |
| `statusline-command.sh` | Status line: model, effort, graft, cache, usage bars |
| `scripts/install.sh` | Set up a new device; safe to re-run |
| `scripts/probe-context-floor.sh` | Check that `rules/` stayed small and the guide pointer fires |
| `plans/` | Research findings and the decisions taken from them |
| `LICENSE` | MIT |

Claude Code auto-loads every file under `rules/` into every session and every
subagent, with no import line needed. `guides/` is the opposite: nothing loads
it, and a pointer in `rules/code-quality.md` sends the agent there on its first
edit in that language. That split is worth about 5,500 words per context.

An output style file does nothing on its own. `settings.json` activates one with
`"outputStyle": "plain-style"`.

## Setup on a new device

The repo lives anywhere. `~/.claude` stays Claude Code's own folder, and the
skills, agents, and hooks reach it as a plugin from this repo's marketplace.

1. Clone the repo:
   ```bash
   git clone git@github.com:NovelioPI/claude-setup.git ~/claude-setup
   ```
2. Run the installer, which checks every tool and installs what needs no sudo:
   ```bash
   ~/claude-setup/scripts/install.sh
   ```
3. Fix anything it reports as a blocker, then run it again.
4. Run the two plugin commands it prints, then restart Claude Code.

`CLAUDE.md`, `rules/`, and the `permissions.ask` list cannot travel in a plugin.
Until the rule sync lands, they load only in a session opened in this repo.

### What the installer needs

| Tool | Used by | Installed by the script |
|---|---|---|
| `git` | the clone | no, needs sudo |
| `jq` | all three hooks and the status line | no, needs sudo |
| `node`, `npm` | graft and `npx skills` | no |
| `uv` | `check-complexity.sh`, which runs `complexipy` and `ruff` through `uvx` | yes |
| `graft` | the context graph, its hooks, the status line segment | yes |
| `gh`, `rg` | optional convenience | no |

## Graft

Graft builds a context graph of a repo so an agent finds code without reading
whole files. It is wired here through user-level hooks in `settings.json`.

Run `graft init` inside each project. It writes that project's shims, and the
user-level shim at `~/.claude/helpers/graft-hooks.cjs`.

`helpers/` is not tracked. Graft regenerates it with absolute paths, so a
committed copy breaks on the next device.

`GRAFT_NO_STATUSLINE=1` in the `env` block stops `graft init` claiming the status
line. `statusline-command.sh` renders the graft segment itself, beside the model
and the effort level. Keep the same variable exported in your shell profile, so a
`graft init` you type by hand honours it too.

Re-run `scripts/install.sh` after any `graft init`. It rewrites absolute paths in
`settings.json` back to `$HOME`.

## Skills and the development loop

Three skills chain into one workflow.

| Order | Skill | Job |
|---|---|---|
| 1 | `brainstorming` | Widen a raw idea into features, grounded facts, and open decisions |
| 2 | `grilling` | Close those decisions, one round of questions at a time |
| 3 | `issue-plan` | Write `PROJECT.md` and draft, then create, a milestone and its issues |

Then the loop runs.

| Skill | Job |
|---|---|
| `issue-update` | Move an issue between statuses, file new scope, close a milestone, decide when to review |
| `milestone-run` | Run a whole version: dispatch, gate on the acceptance command, commit, repeat |

`milestone-run` dispatches `agents/implementer.md` per row, and
`agents/reviewer.md` only when a review trigger fires. A milestone closes when
its exit command returns 0.

This repo tracks only the four skills written here: `brainstorming`,
`milestone-run`, `issue-plan`, and `issue-update`. The rest are other people's
work, so they are not redistributed. `scripts/install.sh` fetches them.

| Skill | Source |
|---|---|
| `grilling`, `writing-for-agents`, `diagnosing-bugs`, `handoff`, `research`, `resolving-merge-conflicts` | [mattpocock/skills](https://github.com/mattpocock/skills), through the Skills CLI at https://skills.sh/ |
| `impeccable`, and the `agents/impeccable-*.md` it dispatches | installed separately, not tracked here |

`~/.claude/skills/` is otherwise excluded, with a negation for each tracked
skill. Every entry is a real directory, never a symlink.

A skill's own instructions never override the approval protocol in `CLAUDE.md`.
Several of them tell the agent to dispatch a subagent or to not block, and
`CLAUDE.md` has a clause that overrules them.

## Guardrails

Two layers guard the destructive commands, and the overlap is on purpose.

`plugin/hooks/block-dangerous-git.sh` runs as a `PreToolUse` hook on every Bash call and
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
- `plugin/hooks/notify.sh` sends a WinRT toast under the registered Windows PowerShell
  AppId. A `NotifyIcon` balloon does not work: Windows 11 accepts the call,
  returns success, and shows nothing.
- This repo excludes `~/.claude/projects/*/memory/`. Those memory files are tied
  to session-specific paths on the machine that wrote them.
