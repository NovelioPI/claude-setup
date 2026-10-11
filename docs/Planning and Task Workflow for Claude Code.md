# Planning and Task Workflow for Claude Code

Oct 5, 2026 · @Novel

Match planning effort to task size: small tasks get no plan, multi-session features get a Linear project with one issue per task, and whole projects are decomposed one milestone at a time. Companion to Claude Code Context Management: Step-by-Step Implementation Guide and Code Quality and Cognitive Debt Playbook for Claude Code.

## Workflow tiers

Default to Tier 0. Move up a tier only when a signal below is true, because each tier adds files and context the agent has to manage.

| Tier | Signal | Planning | Task tracking | Files created |
| --- | --- | --- | --- | --- |
| 0: Just do it | Clear ask, ≤3 files, fits one session | None | None | None |
| 1: Think first | Approach unclear or >3 files, but one session | Plan mode; plan stays in chat | Built-in Tasks, this session only | None |
| 2: Feature | Spans several sessions or subagents | Linear project description | Linear issues with blocked-by relations | None in the repo |
| 3: Project | Weeks of work, several features | Roadmap of milestones | Linear; only the current milestone becomes issues | `docs/roadmap.md` |

Decision rule, in order:

1. Will this take more than one session, or need parallel subagents? Yes → Tier 2 (or 3 if it is several features).
2. Is the approach unclear, or will more than 3 files change? Yes → Tier 1.
3. Otherwise → Tier 0.

When unsure, start one tier lower. Promoting a task mid-way ("this is bigger than I thought, let's write a spec") is cheap; unwinding a spec and task list for a two-line fix is pure waste.

## The three artifacts

Keep plan, task graph and progress apart. Each changes at a different rate and is read at a different moment, so merging them (as todo.md does) makes the agent reread the plan every time it checks what is next.

| Artifact | Answers | Changes | Lives in | Read when |
| --- | --- | --- | --- | --- |
| Spec (plan) | Why, what, approach, decisions, acceptance criteria | Rarely; decisions appended | Linear project description | Executor reads only Decisions, at task start |
| Task graph | What's next, status, what blocks what | Constantly | Linear issues, labels, and relations | Each time the agent picks up work; Linear board to view |
| Progress note | Where exactly I am now, hypothesis, key files | Rewritten at each handoff | `.agent/progress.md` (gitignored) | Once, at session start |

Linear holds the spec and the task graph, so the repo gets no plan files. The `linear@claude-plugins-official` plugin gives Claude its MCP tools. The board shows live status on a second screen. Issue and comment writes (`save_issue`, `save_comment`) need no prompt; other Linear writes still ask. The whole `.agent/` folder is gitignored, so nothing from this workflow enters git.

## One-time setup

Four pieces: a tier rule in CLAUDE.md, a way to name the feature, the Linear plugin, and two commands.

1. Add the workflow block to CLAUDE.md (global `~/.claude/CLAUDE.md` in this setup):

```markdown
## Workflow tiers

- Tier 0: the change touches 3 files or fewer and fits one session.
  Make no plan file and no task list.
- Tier 1: the approach is unclear, or more than 3 files change. Ask me to
  switch on plan mode. Keep the plan in chat.
- Tier 2: the work spans several sessions or needs parallel subagents.
  Propose /plan-feature and wait for a token.
- Never create a plan file or a shared task list for single-session work.
- On a feature, read only the spec section that your task names, plus Decisions.
- The tier decides the planning files. Ownership levels decide my involvement.
  A Tier 0 fix in Core still follows the Core rules.
- The tier never skips the Approval Protocol. Tier 0 still needs a token.
```

2. Name the feature. `/next-task` asks for the Linear project name when `FEATURE` is empty. For a long-running feature, pin it per checkout in `.claude/settings.local.json` (not committed): `{ "env": { "FEATURE": "<feature>" } }`.

One session writes both the tests and the code of a task. TDD is the default: each task follows the `tdd` skill at the seams its plan names. "No TDD" turns it off until "TDD on" or the end of the session.

3. Install the Linear plugin with `claude plugin install linear@claude-plugins-official`, then log in once with `/mcp`.

4. Add the two commands: `commands/plan-feature.md` creates the Linear project and issues, and `commands/next-task.md` picks and finishes one issue. Read the command files for the exact steps.

## Running a Tier 2 feature

Plan in one session, execute each task in its own fresh session, and close the feature by archiving the Linear project. Exploration noise from planning never reaches execution.

**Plan session**

1. Start a session: `claude`.
2. Enter plan mode (Shift+Tab) and run `/plan-feature export-csv <goal>`.
3. Answer the interview questions. Review the project and issues on the Linear board; edit them by hand if needed.
4. `/clear`.

**Execution sessions (repeat per task)**

1. `claude`, then `/next-task`. Give `export-csv` when it asks for the feature.
2. Each task asks for a token before the work and before the commit. Core tasks also pause for your choice of approach. Each task commits, sets its issue to Done, comments the commit hash, and writes progress.md via `/handoff`.
3. `/clear` (or exit) and repeat. Run independent tasks in parallel only in separate git worktrees on the same feature; in a shared checkout the Stop gate would see the other session's changes.

**When reality diverges from the plan**

- Small change of approach: the executor appends a dated line to Decisions and carries on.
- A task turns out bigger: ask Claude to split it into new issues with blocked-by relations.
- The plan is wrong at its core: stop, run a short planning session that edits the project description, and regenerate only the affected issues.

**Finishing the feature**

1. Ask Claude to collapse the project description into a short decision record, `docs/decisions/<feature>.md`: what was built, key decisions and why, known gotchas. Add any reusable "when X, do Y" lessons to `.agent/lessons.md` via `/reflect`.
2. Archive the Linear project. Linear keeps the full history.

## Spec template and lean-plan rules

A spec is a contract for executors, not a design essay: cap it at \~2 pages and give every task its own section so each session reads only what it needs.

`/plan-feature` holds the project and issue templates inline (`commands/plan-feature.md`). The project description uses the sections below; each `### T<n>` section becomes one issue:

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

- Never copy a spec into CLAUDE.md. Claude reads it from Linear, on demand.
- One issue per task, so `/next-task` reads only that issue plus Decisions.
- Append to Decisions; never regenerate the spec. Regeneration is where drift and silent scope changes creep in.
- Code belongs in the repo, not the spec. Name files and functions instead of pasting snippets.
- If a spec passes \~2 pages, the feature is too big. Split it into two features or promote it to Tier 3.

## Big projects: rolling-wave planning

Decompose only the current milestone into issues. Tasks for work months away are guesses that go vague and stale, which is what makes a big todo.md feel sparse.

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

Linear projects can also hold the milestones, so the roadmap file becomes optional.

## Migrating from todo.md

Sort what is in todo.md by tier, move each part to its new home, then delete the file.

1. Install the Linear plugin (One-time setup, step 3).
2. Ask Claude to classify every open item in todo.md as Tier 0, 1 or 2, or as a roadmap-level milestone.
3. Tier 0/1 items: just do them, or leave them as Linear issues. They need no tracking file.
4. Tier 2 groups: run `/plan-feature` for each, which creates its Linear project and issues.
5. Milestone-level items: move them into `docs/roadmap.md`.
6. Delete todo.md and remove any CLAUDE.md lines that mention it.

Verification checklist:

- [ ] A small fix (Tier 0) is done with no plan, no tasks and no new files
- [ ] A medium change uses plan mode and leaves no plan file behind
- [ ] `/plan-feature` produces a Linear project and one issue per task
- [ ] Two sessions given the same feature name see the same Linear project
- [ ] `/next-task` reads only its issue plus Decisions, and finishes with a commit and handoff
- [ ] `git status` after `/handoff` shows nothing under `.agent/`
- [ ] A finished feature leaves a short summary in lessons.md and no stale spec
