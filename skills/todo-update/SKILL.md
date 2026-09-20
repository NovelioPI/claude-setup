---
name: todo-update
description: >-
  Maintain a project's TODO.md: move a row between done, next, plan, blocked and
  parked, file new scope as a row, pick the next row to work on, and recount the
  scoreboard. Also carries the effort rules — when to branch, when to brainstorm,
  what to test, and what to run before a commit. Use when a row changes, when work
  starts or lands, or when asked what is built and what is next. To create the
  file, or to add an area, use `todo-plan`.
---

# Update TODO.md

Router: this skill changes rows in an existing `TODO.md`. Creating the file or
adding an area belongs to `todo-plan`.

Read `~/.claude/skills/todo-plan/REFERENCE.md` for columns, wording, and format.

## Triggers

| Event | Edit |
|---|---|
| Work starts on a row | Set `next` |
| The row's code lands | Set `done`, replace the Note with the evidence, recount |
| New scope appears mid-run | Add a row as `plan`; do not widen the running row |
| An external input is missing | Set `blocked`, name the input in the Note |
| The row is refused | Set `parked`, put the reason in the Note |
| A `done` row regresses | Add a new row; never move `done` backwards |
| Every row in a milestone is `done` | Run the milestone's exit command |
| The exit command returns 0 | Set the milestone `done`, set the next one `next` |
| The exit command fails with every row `done` | The milestone is underspecified; file the missing work as a row |

```
plan ──▶ next ──▶ done
  │        │
  ├────────┴──▶ blocked ──▶ next
  └──▶ parked
```

Cap `next` at 3 rows across the whole file. The cap is what makes the token worth
writing: without it, `next` goes unused and the file cannot show work in flight.

Edit the row in the same change as the code, and offer the row edit together with
the diff, before the commit message. Cite the closed IDs in the commit subject:
`Settle the paper book on an off day (H5, H6)`.

## Pick the next row

1. Every ID in `Depends on` is `done`.
2. Lowest Value number first.
3. Within one Value, lowest Effort first.
4. A **bold** Feature is a blocker and goes first in its area.

Risk: if Effort outranks Value, then a cheap value-3 convenience ships before a
value-1 safety row, and the file stops being a risk order.

## Effort drives the process

| Effort | Before code | Test | Before commit | Shape |
|---|---|---|---|---|
| `S` | Write the acceptance clause in one line | Only for a bug fix | Run the suite | 1 row, 1 commit |
| `M` | Plan in chat, wait for approval | One at the behaviour boundary | Suite, then the review triggers below | 1 row, 1-2 commits |
| `L` | Brainstorm, then split into `S`/`M` rows | One for each sub-row | Same as `M` for each part | Never ships as one row |

`L` is a smell, not a size. An `L` row that stays `L` carries its reason in the
Note. Never rewrite Effort after `done`: a corrected estimate hides the miss, so
the scale never calibrates.

Follow the project's own review rule. CLAUDE.md may require a review before a
commit, and a project memory may make it ask-first; the memory wins.

## Review triggers

Skip `/code-review` and `/simplify` by default. Run them when a row below fires.

| Condition | `/code-review` | `/simplify` |
|---|---|---|
| Effort `S`, one file, suite green | skip | skip |
| Bug fix shipped with its regression test | skip | skip |
| Effort `M` or `L` | run | run |
| Touches a row in Invariants | run, then `security-review` | run |
| Adds or changes an exported symbol | run | run |
| Touches 5 or more files, or 200 or more changed lines | run | run |
| A milestone's exit command passes | run once over the whole milestone diff | run once |

Count the changed lines with `git diff --stat`.

Reason: a review on every row costs a full context read per row, and the same
bugs surface once over the milestone diff.

Risk: if every row triggers a review, then the token cost of the loop doubles and
the reviewer reads the same file many times.

## When to branch

| Condition | Branch |
|---|---|
| One commit, suite green | no |
| The change needs 2+ commits to read coherently | yes |
| It touches a row in Invariants | yes |
| It mixes a move or rename with a behaviour change | yes, and split the commits |
| Another machine pulls the same branch meanwhile | yes |

Delete the branch at merge.

## When to brainstorm

| Signal | Action |
|---|---|
| The acceptance clause does not fit one sentence | The row is not ready; brainstorm |
| Effort reads `L` | Brainstorm, then split |
| `Depends on` crosses two or more areas | Plan the order first |
| The row changes an Invariant | Brainstorm, then run a security review |
| New scope appears mid-run | Stop, file it as `plan`, finish the running row |

## Recount the scoreboard

Scoreboard drift is the one failure discipline cannot prevent. Recount on every
status change, and write the counts back into the scoreboard block:

```
awk -F'|' '/^\| *[A-Z]+[0-9]+ *\|/ {id=$2; st=$4; gsub(/ /,"",id); gsub(/ /,"",st);
  sub(/[0-9]+$/,"",id); c[id" "st]++} END {for (k in c) print k, c[k]}' TODO.md | sort
```
