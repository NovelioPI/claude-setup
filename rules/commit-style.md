## Commit Messages

### Subject

Start the subject with one prefix from the table, then a colon and a space. Do not add a scope. After the prefix, write in the imperative mood: "Add", "Fix", "Ignore". Start with a capital letter. Do not end with a period. Cap the subject at 60 characters, prefix included.

| Prefix | Use for |
|---|---|
| `feat` | A new behavior or feature |
| `fix` | A bug fix |
| `refactor` | A code change with no behavior change |
| `docs` | Docs, wiki, README, or comments only |
| `test` | Tests only |
| `chore` | Config, dependencies, build, CI, and anything else |

Example: `fix: Stop the status line from wrapping`

### Body

Write a body only when the subject cannot explain the reason. Skip the body when the subject says everything. Write the body as bullets, not as paragraphs. Cap each bullet at 20 words. State why the change happened, not what the diff shows.

Risk: if the body restates the diff, then a reader gets no new fact.

### Words

Do not use a figure of speech. See @rules/plain-words.md for the full table. Common cases: ship it, under the hood, magic, footgun, wire up, land a change.

Keep the exact technical word. The long-word table does not apply here.

### Bug fixes

A bug-fix commit always has a body, even when the subject says enough. Its first bullet is `- Root cause: <one sentence>`.

### Trailers

Put a trailer last, after one blank line.
