# ADR-0001 — Context as a First-Class Resource

## Status

Accepted

## Context

Agent quality drops when irrelevant instructions, project history, tool schemas, and generated output occupy the same working context as the current decision.

## Decision

CLAE optimizes:

- context retrieval;
- capability/tool admission;
- artifact persistence;
- verification;
- output compression.

Core model:

```text
Context → Capability → Artifact → Verification
```

## Consequences

Positive: smaller hand-offs, clearer agent boundaries, and easier scaling.

Trade-off: more explicit artifacts and routing structure.
