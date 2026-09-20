---
name: milestone-run
description: Run a TODO.md milestone to completion as an agent loop, dispatching one implementer per row, gating on each row's acceptance command, and stopping when the milestone's exit command returns 0. Use when a version is approved and its rows carry acceptance commands. To change one row by hand, use `todo-update`.
---

# Run a milestone

You are the orchestrator. You pick rows, dispatch agents, gate on verdicts,
commit, and stop when the milestone's exit command passes.

Router: this skill runs a whole version. A single row change belongs to
`todo-update`. Creating the Milestones section belongs to `todo-plan`.

## Context discipline

Read verdict blocks. Leave diffs to the reviewer.

| You read | You never read |
|---|---|
| `TODO.md` rows and the Milestones table | a diff |
| An implementer's verdict block | an implementer's transcript |
| A reviewer's finding lines | a whole source file |
| An exit code | a test log |

Reason: the orchestrator lives for the whole milestone, so every token it spends
on a diff is a row it cannot reach later.

Risk: if the orchestrator reads diffs, then its context fills after a few rows
and the loop dies mid-milestone.

## 0. Preflight

Stop and report when any check fails. A failed check is a planning gap, not a
run to attempt.

| Check | Fix when it fails |
|---|---|
| The milestone has an exit command | Write one with `todo-update` |
| The exit command is a command, not prose | Rewrite it |
| Every row in the milestone has an acceptance command in its Note | Write them |
| The working tree is clean | Commit or stash first |
| `graft` is built for this repo | Run `graft build` |

## 1. Get the token

Show the milestone as the plan: the version, its goal, its exit command, and
every row ID it ships. Then wait for "Go" or "Execute".

One token covers the listed rows. A row outside that list is new scope: stop the
loop, report it, and get a second token.

## 2. Pick the eligible rows

A row is eligible when its Milestone cell matches the running version, its status
is `plan`, and every ID in `Depends on` is `done`.

Order by Value, then by Effort, as `todo-update` states. Dispatch in parallel
only when the eligible rows share no file.

Cap `next` at 3 rows, which caps concurrent implementers at 3.

## 3. Dispatch

Send each implementer four things and nothing more.

```
ROW        <id>
FEATURE    <the Feature cell, verbatim>
ACCEPTANCE <the acceptance command>
BRIEF      ~/.claude/guides/agent-brief.md
```

Paste no rule text, no file content, and no repository background. The agent
reads the brief itself, and the brief names the rest.

Reason: a pasted rule costs the same tokens on every dispatch, while a path
costs one line.

Pick the model by Effort: `S` runs on haiku, `M` on sonnet, `L` splits into `S`
and `M` rows before it runs at all.

## 4. Gate

Read the verdict block. Act on `VERDICT` and `EXIT`, never on the prose.

| Verdict | Action |
|---|---|
| `pass`, exit 0 | Continue to step 5 |
| `pass`, exit non-zero | Treat as `fail`; the agent misreported |
| `fail` | Set the row `blocked`, put the blocker in the Note, take the next row |
| No verdict block | Treat as `fail`; do not infer success from a summary |

## 5. Review, when a trigger fires

Read the review trigger table in `todo-update`. Skip the review when no row
fires, which is the common case for an `S` row.

Dispatch the `reviewer` agent with the diff range and nothing else. Apply its
findings yourself, or dispatch the implementer again with the finding lines.

## 6. Commit

Stage the files the verdict named. Check every other changed file before you
commit, and name it in the message or leave it unstaged.

Write the subject in the imperative and cite the closed IDs, as
`rules/commit-style.md` states.

Move the row to `done`, replace the Note with the evidence, and recount the
scoreboard with the command in `todo-update`.

## 7. Close or repeat

Run the milestone's exit command.

| Result | Action |
|---|---|
| Exit 0, every row `done` | Set the milestone `done`, run the milestone-exit review, report and stop |
| Exit non-zero, every row `done` | The milestone is underspecified; file the missing work as a row and stop for a token |
| Rows remain | Return to step 2 |

The loop ends on an exit code, never on your own judgment that the goal is met.

## Budget

Set `maxBudgetUsd` before the first dispatch, so a stuck agent stops the run
instead of the run stopping your month.

Report `graft stats` at the end, so the next milestone has a cost baseline.
