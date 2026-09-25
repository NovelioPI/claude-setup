---
name: context-gateway
description: Build a minimum-sufficient context package before non-trivial work. Use for code, docs, design, testing, and project tasks.
---

# Context Gateway

Treat context as a finite engineering resource.

## Default flow

```text
request
→ infer demand
→ discover candidates
→ select by utility/cost
→ materialize minimal context
→ execute
→ checkpoint
→ escalate only with evidence
```

## Use the runtime

For a non-trivial task, prefer:

```bash
python3 .clae/scripts/clae.py index
python3 .clae/scripts/clae.py package --task "..." --task-id TASK-...
```

Read the generated:

```text
.clae/runtime/context-packages/<task-id>.json
```

before broad repository exploration.

## Rules

- Hard context is never silently dropped to make room for soft context.
- Start at the smallest context level that can answer the question.
- Escalate only with evidence: missing symbol, dependency impact, conflicting evidence, failed verification, or unverifiable acceptance criteria.
- Prefer local state over external MCP calls when local state is fresh enough.
- Never preload all tools, rules, docs, or project history.
- Use AST/symbol/path information before semantic search.
- Keep provenance for important evidence.
- Checkpoint before compaction or major phase changes.
- Do not turn every uncertainty into a larger context fetch.


## Escalation command

When evidence shows the current context package is insufficient:

```bash
python3 .clae/scripts/clae.py escalate TASK-142 --task "<task>" --reason missing_symbol --level 1 --step 0
```

Allowed reasons:
`missing_symbol`, `dependency_impact`, `conflicting_evidence`, `failed_verification`, `unverifiable_acceptance`.
