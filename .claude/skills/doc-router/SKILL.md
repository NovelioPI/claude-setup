---
name: doc-router
description: Decide where documentation belongs, whether an existing document should be updated, and what scope the document should have.
---

# Documentation Router

## Classify

```text
Tutorial    = learn
How-to      = accomplish
Reference   = look up
Explanation = understand why
ADR         = record a durable architecture decision
```

## Before writing

Create a scope contract:

```yaml
type: how-to
audience: ai-engineer
purpose: <one sentence>
covers:
  - ...
excludes:
  - ...
```

## Search first

Prefer updating a clear existing home over creating a new document.

## Split only when

Audience, goal, lifecycle, conceptual boundary, or source of truth differs enough to hurt scanning.

## Compression

Delete repetition before adding structure. Prefer links to repeated explanations. Prefer generated reference when source code or schemas are authoritative.
