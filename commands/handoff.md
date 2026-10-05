---
description: Write current working state to disk before clearing or stopping
---

1. If `.agent/` does not exist, create it, and create `.agent/.gitignore` with
   two lines: `snapshots/` and `snapshot.md`.
2. Rewrite `.agent/progress.md`. Use the existing section headings, or the
   template below if the file does not exist. Be exact: file paths, test names,
   error lines, commit hashes. Max 60 lines.
3. Update the status of the current Tasks. Do not delete or rename tasks.
4. Do not commit. List uncommitted work under "In progress".
5. Reply with one line: "Handoff written — safe to /clear."

Template:

```markdown
# Progress — updated <date>

## Current goal
<one sentence>

## Done this session
- <change> (commit abc123)

## In progress
- <task id>: <exact state, next concrete action>

## Current hypothesis / ruled out
- Hypothesis: <...>
- Ruled out: <...> because <evidence>

## Key files
- path/to/file.py — <why it matters>

## Open questions
- <...>
```
