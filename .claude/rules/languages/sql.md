---
paths:
  - "**/*.sql"
  - "**/migrations/**/*.sql"
  - "**/queries/**/*.sql"
---

# SQL Engineering Rules

## MUST

- Make schema changes explicit and reversible when the migration system supports rollback.
- Name selected columns explicitly in application queries.
- Parameterize values; never build SQL with string concatenation.

## PREFER

- One query responsibility per module/function.
- Indexes based on measured access patterns.
- Explain plans for performance-sensitive queries.

## AVOID

- `SELECT *` across stable application boundaries.
- Hidden destructive migrations.
- N+1 query patterns.
