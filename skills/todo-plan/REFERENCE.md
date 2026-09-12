# TODO.md reference

Shared by the `todo-plan` and `todo-update` skills.

## Columns

| Column | Content |
|---|---|
| ID | Area letter + number, e.g. `F12` |
| Feature | Imperative phrase, 70 characters or fewer, no trailing period |
| Status | `done`, `next`, `plan`, `blocked`, or `parked` |
| Value | `1` prevents a loss, `2` finds an edge, `3` saves effort |
| Effort | `S` under an hour, `M` half a day, `L` a day or more |
| Depends on | IDs, comma separated, or `—` |
| Note | Evidence, acceptance check, or reason |

Add an optional `Runs in` column after Status when one codebase feeds two or more
runtimes. Keep Status in column 3 either way: the recount command reads that
position.

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
| Note, `plan` | The acceptance check, one clause |
| Note, `done` | The evidence: file, test count, or live proof |
| Note, `blocked` | The awaited input |
| Note, `parked` | The refusal reason |

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
