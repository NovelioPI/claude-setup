# CLAE Runtime Implementation

## Runtime

The Gateway runtime is under `.clae/gateway/` and uses Python's standard library only.

### Core modules

- `demand.py` — task classification and context demand.
- `discovery.py` — filesystem discovery, lightweight repository index, and symbol discovery.
- `models.py` — typed internal data structures.
- `scoring.py` — candidate utility and marginal utility.
- `selector.py` — budgeted greedy selection.
- `materializer.py` — line-window materialization.
- `checkpoint.py` — task checkpoint extraction.
- `compact.py` — compact runtime package state.
- `telemetry.py` — JSONL event logging and summary.
- `engine.py` — public orchestration API.

## CLI

`.clae/scripts/clae.py` is the portable entry point.

All generated runtime files are under `.clae/runtime/`. The root `.gitignore` excludes them.

## Why standard library only?

The Gateway is infrastructure for context management. Adding a dependency just to retrieve files or compute heuristics would increase installation cost and operational surface. More sophisticated retrieval can be added later behind the same interfaces.

## Current retrieval strategy

1. explicit task artifacts
2. path and keyword matching
3. language rules
4. lightweight symbols for code
5. deterministic utility scoring
6. line-window materialization

Semantic retrieval is intentionally absent.

## Known limitations

- generic symbol extraction for non-Python languages is heuristic
- dependency graph is lightweight in v0.4
- semantic similarity is not implemented
- token estimates use character/4 approximation
- candidate authority and freshness are policy heuristics

These are measurable extension points for later versions.


## Escalation command

When evidence shows the current context package is insufficient:

```bash
python3 .clae/scripts/clae.py escalate TASK-142 --task "<task>" --reason missing_symbol --level 1 --step 0
```

Allowed reasons:
`missing_symbol`, `dependency_impact`, `conflicting_evidence`, `failed_verification`, `unverifiable_acceptance`.
