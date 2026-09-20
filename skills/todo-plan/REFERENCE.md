# TODO.md reference

Shared by the `todo-plan` and `todo-update` skills.

## Columns

| Column | Content |
|---|---|
| ID | Area letter + number, e.g. `F12` |
| Feature | Imperative phrase, 70 characters or fewer, no trailing period |
| Status | `done`, `next`, `plan`, `blocked`, or `parked` |
| Milestone | The version this row ships in, e.g. `v0.2`, or `—` |
| Value | `1` prevents a loss, `2` finds an edge, `3` saves effort |
| Effort | `S` under an hour, `M` half a day, `L` a day or more |
| Depends on | IDs, comma separated, or `—` |
| Note | Evidence, acceptance check, or reason |

Put Milestone, and the optional `Runs in` column, after Status. Keep Status in
column 3: the recount command reads that position.

An area is one letter and one theme. Assign an ID once. Never renumber an ID and
never reuse a retired one — commit subjects and note cells cite it.

## Wording

| Cell | Rule |
|---|---|
| Feature | Imperative, no trailing period; keep the wording after `done` |
| Feature, bold | Bold means "blocks other rows", nothing else |
| Status | One lowercase token, no decoration |
| Depends on | `F5, R2` or `—` |
| Any empty cell | `—`, never blank |
| Note, `plan` | The acceptance check, one clause; a command when an agent runs the row |
| Note, `done` | The evidence: file, test count, or live proof |
| Note, `blocked` | The awaited input |
| Note, `parked` | The refusal reason |
| Milestone | One version token, or `—` for unscheduled |

Cap a Note at about 200 characters. When a root cause needs more, leave a pointer
in the cell and put the write-up in a `### <ID>` subsection under the table. The
row stays scannable and the detail keeps a linkable anchor.

Attach a `Reason:`, `Risk:`, or `Recommendation:` sentence under the table it
explains. One sentence for each. Never stack two labels.

## Format

| Section | Form |
|---|---|
| Legend, scoreboard, layout tree | Fenced block, aligned columns |
| Task tables, boundaries, invariants | Markdown table |

Reason: a fenced block never re-flows, so a fixed-width read survives a narrow
terminal, while a task Note is prose that only a markdown table renders.

## Milestones section

A milestone is a version with a goal and a command that proves the goal is met.

| Column | Content |
|---|---|
| Version | One token, e.g. `v0.2` |
| Goal | Imperative phrase, what the version delivers |
| Exit command | A shell command; exit 0 means the goal is met |
| Status | `done`, `next`, `plan`, or `parked` |
| Rows | The IDs this version ships, comma separated |

The exit command is the milestone's oracle. Write a command, never a sentence.
A milestone with no exit command cannot close itself, so an agent loop runs on it
forever.

| Exit command | Verdict |
|---|---|
| `pytest tests/auth -q` | usable |
| `make release-check` | usable |
| "auth works end to end" | unusable, it is prose |

Close a milestone when every listed row is `done` and the exit command returns 0.
The command is the authority; the rows are the cheap precheck.

Cap `next` at one milestone. One version is in flight at a time.
