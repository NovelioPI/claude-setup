# Planning and Task Workflow for Claude Code

Oct 5, 2026 · @Novel

Match planning effort to task size: small tasks get no plan, multi-session features get a short spec plus Claude Code's built-in Tasks, and whole projects are decomposed one milestone at a time. Companion to Claude Code Context Management: Step-by-Step Implementation Guide and Code Quality and Cognitive Debt Playbook for Claude Code.

## Workflow tiers

Default to Tier 0. Move up a tier only when a signal below is true, because each tier adds files and context the agent has to manage.

| Tier | Signal | Planning | Task tracking | Files created |
| --- | --- | --- | --- | --- |
| 0: Just do it | Clear ask, ≤3 files, fits one session | None | None | None |
| 1: Think first | Approach unclear or >3 files, but one session | Plan mode; plan stays in chat | Built-in Tasks, this session only | None |
| 2: Feature | Spans several sessions or subagents | Short spec file | Shared Task list with dependencies | `docs/plans/<feature>.md` |
| 3: Project | Weeks of work, several features | Roadmap of milestones | Issue tracker; only the current milestone becomes Tasks | `docs/roadmap.md` |

Decision rule, in order:

1. Will this take more than one session, or need parallel subagents? Yes → Tier 2 (or 3 if it is several features).
2. Is the approach unclear, or will more than 3 files change? Yes → Tier 1.
3. Otherwise → Tier 0.

When unsure, start one tier lower. Promoting a task mid-way ("this is bigger than I thought, let's write a spec") is cheap; unwinding a spec and task list for a two-line fix is pure waste.

## The three artifacts

Keep plan, task graph and progress apart. Each changes at a different rate and is read at a different moment, so merging them (as todo.md does) makes the agent reread the plan every time it checks what is next.

| Artifact | Answers | Changes | Lives in | Read when |
| --- | --- | --- | --- | --- |
| Spec (plan) | Why, what, approach, decisions, acceptance criteria | Rarely; decisions appended | `docs/plans/<feature>.md` (in git) | Executor reads only its task's section, at task start |
| Task graph | What's next, status, what blocks what | Constantly | Built-in Tasks (`~/.claude/tasks`) | Each time the agent picks up work; Ctrl+T to view |
| Progress note | Where exactly I am now, hypothesis, key files | Rewritten at each handoff | `.agent/progress.md` | Once, at session start |

Built-in Tasks (Claude Code v2.1.16 and later) replace todo.md for tracking. They support dependencies, persist across compaction and `/clear`, and can be shared across sessions and subagents. They live outside the repo, so they are not versioned or visible to teammates; the spec and progress note are.

## One-time setup

Four pieces: a tier rule in CLAUDE.md, a way to launch sessions on a shared task list, and two commands.

1. Add the workflow block to the root CLAUDE.md:

```markdown
## Workflow tiers
- Default: just implement. No plan, no task list, for changes touching <=3 files
  that fit in one session.
- Approach unclear or >3 files: use plan mode first; keep the plan in chat.
- Spans multiple sessions: suggest /plan-feature and wait for my OK.
  Never create plan files or shared task lists for single-session work.
- When working on a feature, read only the spec section your task references,
  never the whole spec.
- Tier decides planning artifacts; ownership level (Ownership levels block)
  decides my involvement. A Tier 0 fix in Core still follows the Core rules.
```

2. Add a launcher so every session on a feature shares its task list. In `~/.bashrc` or `~/.zshrc`:

```bash
# usage: ccf <feature> [mode]   modes: impl (default), tests, pair
ccf() {
  local id="$1" mode="${2:-impl}"
  if [ -n "$id" ]; then
    TASK_MODE="$mode" CLAUDE_CODE_TASK_LIST_ID="$id" claude
  else
    TASK_MODE="$mode" claude
  fi
}
```

The mode sets which protected paths the session may edit and how strict the Stop gate is (Playbook, Step 3).

For a long-running feature, you can instead pin it per checkout in `.claude/settings.local.json` (not committed): `{ "env": { "CLAUDE_CODE_TASK_LIST_ID": "<feature>" } }`.

3. Create `.claude/commands/plan-feature.md`:

```markdown
---
description: Plan a multi-session feature into a spec and a task graph
argument-hint: <feature-name> <one-line goal>
---

Feature: $ARGUMENTS

1. Use the explorer subagent to map the relevant code. Do not read files yourself.
2. Interview me: ask about edge cases, constraints and acceptance criteria
   until the approach is unambiguous. One question at a time.
3. Write docs/plans/<feature-name>.md using the template in that folder.
   Max ~2 pages. One "### T<n>" section per task, with its ownership level.
4. Create Tasks with dependencies. Each task: one session, one commit, title
   starts with its id and [mode], description names its spec section and check.
   - Core or Important work: a pair. "T<n>-test [tests]" writes the acceptance
     tests; "T<n>-impl [impl]" (or "[pair]" for Core) depends on it.
   - Plumbing: one "T<n> [impl]" task, checked by existing tests or a command.
5. Stop. Tell me to /clear and start each task with: ccf <feature-name> <mode>
```

4. Create `.claude/commands/next-task.md`:

```markdown
---
description: Pick up and finish the next unblocked task for this session's mode
---

1. Read .agent/progress.md. List the open Tasks. Check the mode: echo $TASK_MODE
   (empty means impl).
2. Pick the first unblocked task whose [mode] matches. If none matches, tell me
   which mode to restart in and stop. Mark it in progress.
3. Read ONLY its section of the spec in docs/plans/ plus the Decisions section.
4. Do the task. Use subagents for exploration and log analysis.
   [tests]: write the acceptance tests. [pair]: follow the Core rules, outline,
   leave TODO(human) stubs and wait for me.
5. Run its check. [tests]: the new tests run and fail for the expected reason.
   Otherwise: the check passes. If not, fix or stop and report; never edit
   tests to make it pass. Do not mark it done.
6. Run /check-task and fix Critical and Major findings.
7. Important or Core code: run /walkthrough and wait for PASS before committing.
8. Commit, mark the task done, then run /handoff.
9. If the approach had to change, append a dated line to the spec's
   Decisions section instead of rewriting the spec.
```

## Running a Tier 2 feature

Plan in one session, execute each task in its own fresh session, and close the feature by archiving the spec. Exploration noise from planning never reaches execution.

**Plan session**

1. Start on the feature's list: `ccf export-csv`.
2. Enter plan mode (Shift+Tab) and run `/plan-feature export-csv <goal>`.
3. Answer the interview questions. Review the spec and task graph (Ctrl+T); edit the spec by hand if needed.
4. `/clear`.

**Execution sessions (repeat per task)**

1. `ccf export-csv <mode>` with the mode in the task title, then `/next-task`.
2. Plumbing tasks can run unattended. Important tasks pause for `/walkthrough`, and Core tasks are pairing sessions where you stay at the keyboard. Each task commits, marks itself done and writes progress.md via `/handoff`.
3. `/clear` (or exit) and repeat. Run independent tasks in parallel only in separate git worktrees on the same list; in a shared checkout the Stop gate would see the other session's changes.

**When reality diverges from the plan**

- Small change of approach: the executor appends a dated line to Decisions and carries on.
- A task turns out bigger: ask Claude to split it into new Tasks with dependencies, and add matching sections to the spec.
- The plan is wrong at its core: stop, run a short planning session that edits the spec, and regenerate only the affected Tasks.

**Finishing the feature**

1. Ask Claude to collapse the spec into a short decision record, `docs/decisions/<feature>.md`: what was built, key decisions and why, known gotchas. Add any reusable "when X, do Y" lessons to `.agent/lessons.md` via `/reflect`.
2. Delete the spec file, or move it to `docs/plans/done/` if your team reviews plans. Git keeps the full version.
3. Clear the feature's task list ("clear all tasks").

## Spec template and lean-plan rules

A spec is a contract for executors, not a design essay: cap it at \~2 pages and give every task its own section so each session reads only what it needs.

Save as `docs/plans/_template.md`:

```markdown
# <Feature name>

## Goal
<1-2 sentences: what changes for the user/system and why>

## Non-goals
- <explicitly out of scope>

## Approach
<5-10 lines: the chosen design and the main alternative rejected>

## Acceptance (feature level)
- <measurable check, e.g. "export of 1M rows finishes in < 30 s; existing integration tests pass">

## Tasks
### T1: <title>  [Core|Important|Plumbing]
Files: <paths>
Do: <what, in 2-5 lines>
Check: <test written in T1-test (Core/Important), or a command (Plumbing)>

### T2: <title>  (depends on T1)
...

## Decisions (append only)
- <date>: <decision> — <reason>
```

Rules that keep it from bloating:

- Never `@import` a spec into CLAUDE.md. It is loaded by path, on demand.
- One `### T<n>` section per task, matching the task title, so `/next-task` reads only that section plus Decisions.
- Append to Decisions; never regenerate the spec. Regeneration is where drift and silent scope changes creep in.
- Code belongs in the repo, not the spec. Name files and functions instead of pasting snippets.
- If a spec passes \~2 pages, the feature is too big. Split it into two features or promote it to Tier 3.

## Big projects: rolling-wave planning

Decompose only the current milestone into Tasks. Tasks for work months away are guesses that go vague and stale, which is what makes a big todo.md feel sparse.

1. Keep a roadmap of 5–10 milestones, one paragraph each, in `docs/roadmap.md`. Claude reads it only when planning, never during execution.
2. Treat the current milestone as one or more Tier 2 features: run `/plan-feature` for each, so its tasks are dense and specific.
3. When a milestone finishes, update the roadmap with what you learned, then plan the next one.

Template `docs/roadmap.md`:

```markdown
# Roadmap — <project>

## Now: M2 <name>
<one paragraph: goal, exit criteria> — features: export-csv, auth-refresh

## Next
- M3 <name>: <one line goal>
- M4 <name>: <one line goal>

## Later
- <one line each; no detail on purpose>

## Done
- M1 <name> (<month>): <one line outcome>
```

If teammates need to see the work, keep milestones and features as GitHub issues and let Claude read them with the `gh` CLI (e.g. `gh issue list --milestone M2`). Built-in Tasks still handle the in-flight execution graph. Beads, a git-backed issue tracker built for coding agents, is an alternative if you want the dependency graph itself versioned in the repo.

## Migrating from todo.md

Sort what is in todo.md by tier, move each part to its new home, then delete the file.

1. Update Claude Code to v2.1.16 or later so built-in Tasks are available.
2. Ask Claude to classify every open item in todo.md as Tier 0, 1 or 2, or as a roadmap-level milestone.
3. Tier 0/1 items: just do them, or leave them as GitHub issues. They need no tracking file.
4. Tier 2 groups: run `/plan-feature` for each, which creates its spec and Tasks.
5. Milestone-level items: move them into `docs/roadmap.md`.
6. Delete todo.md and remove any CLAUDE.md lines that mention it.

Verification checklist:

- [ ] A small fix (Tier 0) is done with no plan, no tasks and no new files
- [ ] A medium change uses plan mode and leaves no plan file behind
- [ ] `/plan-feature` produces a spec under \~2 pages with one section per task
- [ ] Two sessions started with the same `ccf <feature>` see the same task list
- [ ] `/next-task` reads only its spec section, and finishes with a commit and handoff
- [ ] A finished feature leaves a short summary in lessons.md and no stale spec
