# Documentation Workflow

## Principle

Documentation should be **discoverable, scoped, and sufficient** — not exhaustive by default.

## Router

Before writing:

```text
Who is the reader?
What do they need to accomplish or understand?
What kind of document is this?
What belongs here?
What explicitly does not belong here?
```

## Four primary types

```text
Tutorial    → teach
How-to      → accomplish
Reference   → look up facts
Explanation → understand why
```

Use ADRs for durable architecture decisions.

## Scope contract

Every generated document should have:

- type
- audience
- purpose
- covers
- excludes

## Grouping and splitting

Keep information together when it shares:

- audience
- goal
- lifecycle
- conceptual boundary
- source of truth

Split when any of those change enough to make scanning harder.

## Compression pass

Before finalizing:

1. Can something be removed?
2. Can it be linked instead?
3. Can it be generated from source?
4. Can several sentences become one?
5. Does the reader need it now?

## README role

README is the front door, not the project encyclopedia.
