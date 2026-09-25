# ADR-0003 — Behavior Over Function Count for Testing

## Status

Accepted

## Decision

Do not require a dedicated test for every function. Add tests when they protect meaningful behavior, domain rules, public contracts, regressions, or important edge cases.

## Consequences

- fewer low-value test files;
- lower maintenance cost;
- explicit test decisions during planning;
- high-risk work may override minimal-testing defaults.
