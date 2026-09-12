---
name: todo-plan
description: >-
  Create TODO.md, a single-file project plan: a role table, a layout tree,
  letter-prefixed task tables carrying status, value, effort and dependencies, a
  scoreboard, and an invariants list. Use at project setup, when task notes are
  scattered across chat, issues and code comments, or when the file needs a new
  area or section. To change a row that already exists, use `todo-update`.
---

# Create TODO.md

Router: this skill writes or extends the file. A row's status change, a new row, or
a status report belongs to `todo-update`.

Read `~/.claude/skills/todo-plan/REFERENCE.md` for columns, wording, and format.
Copy `~/.claude/skills/todo-plan/TEMPLATE.md` to the repo root as `TODO.md`.

One `TODO.md` at the repo root is the single source of truth for what is built,
what is next, and why.

## File shape

| # | Section | Required | Trigger to include |
|---|---|---|---|
| 1 | Title, purpose, update rule | yes | — |
| 2 | What this project is | yes | — |
| 3 | Target layout | yes | — |
| 4 | Import boundary | no | The code has two or more layers |
| 5 | Entry points | no | The project ships a command or a service |
| 6 | Operating cycle | no | Work is clock-driven or event-driven |
| 7 | Legend | yes | — |
| 8 | Scoreboard | yes | — |
| 9 | Area sections | yes | — |
| 10 | Invariants | yes | — |

Delete a conditional section when its trigger does not fire. A one-package project
with one entry point needs sections 1-3 and 7-10 only.

## Choose the areas

An area is one letter and one theme. Derive the letters from section 2's role
table, so a folder maps to an area and a reader finds the rows from the layout.

| Do | Do not |
|---|---|
| One area for each role or subsystem | An area for each file |
| A letter that hints at the theme, e.g. `F` for the wire | Sequential letters with no meaning |
| A separate area for restructuring work | Mixed refactors inside a feature area |
| A separate area for operations | Operations rows hidden in feature areas |

Order the area sections the way the code depends: the lowest layer first, the
clock-driven or model-facing surface last.

## Fill the first rows

1. Write every row that is already built as `done`, with its evidence in the Note.
2. Write the agreed direction as `plan`.
3. Leave `next` empty until work starts.
4. Fill `Depends on` before Value and Effort — the dependency order often shows
   that an Effort estimate is wrong.
5. Recount the scoreboard from the rows, never by hand.

Reason: a plan file that starts empty is abandoned, so the first pass records the
existing code and earns the file its authority.

## Invariants section

An invariant holds for the life of the project. A change to one is a security
review, not a refactor. Write the invariant and the concrete failure it prevents,
never a preference or a style rule.

## Extend an existing file

| Change | How |
|---|---|
| A new area | Add the section in dependency order, add the scoreboard line |
| A new conditional section | Add it only when its trigger now fires |
| An area grows past one theme | Split it; keep the old IDs on the old rows |
