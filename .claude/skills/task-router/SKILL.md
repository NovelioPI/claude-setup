---
name: task-router
description: Classify a coding task by complexity and risk, create a task contract, and choose the minimum CLAE agent workflow required.
---

# Task Router — CLAE v0.1

You are the routing layer, not the implementer.

## Objective

Turn an unstructured user request into a compact task contract and a minimal execution route.

## Step 1 — Create task ID

Use a stable identifier such as `TASK-YYYYMMDD-HHMM-<short-slug>`.
Create:

`.claude/work/<TASK_ID>/`

Write the ID to:

`.claude/work/ACTIVE`

## Step 2 — Classify

Assess two dimensions.

### Complexity

- `XS`: trivial local edit; one or very few files; behavior obvious.
- `S`: localized bug/feature; small change surface.
- `M`: multiple modules, non-trivial behavior, or meaningful refactor.
- `L`: cross-cutting architecture, migration, subsystem replacement, or broad refactor.

### Risk

- `LOW`: internal/local, reversible, well-tested.
- `MEDIUM`: user-visible behavior, public API, data behavior, or performance-sensitive code.
- `HIGH`: auth/security, destructive data changes, payments, production migrations, concurrency, or sensitive integrations.

When uncertain, choose the higher risk class and record why.

## Step 3 — Create contract

Write `.claude/work/<TASK_ID>/contract.md` with:

- goal
- scope
- non-goals
- acceptance criteria
- risk
- constraints
- expected output
- routing decision

## Routing matrix

| Complexity | Risk | Route |
|---|---|---|
| XS | LOW | direct implementation + lightweight verification |
| S | LOW/MEDIUM | `repo-scout -> builder -> verifier` |
| S | HIGH | `repo-scout -> builder -> verifier -> reviewer` + security-specific checks when applicable |
| M | LOW/MEDIUM | `repo-scout -> planner -> builder -> verifier -> reviewer` |
| M | HIGH | same as M + specialized verification/review |
| L | any | parallel scouts -> planner -> builder -> verifier -> reviewer -> simplify -> verifier |

Do not spawn agents merely to satisfy the matrix. Skip an agent when deterministic repository evidence already makes its job unnecessary.

## Step 4 — Route context

Pass artifacts, not transcripts.

- Scout receives the task contract.
- Planner receives contract + facts.
- Builder receives contract + facts + plan.
- Verifier receives contract + plan + changes + diff.
- Reviewer receives contract + plan + changes + verification + diff.

## Step 5 — Escalation

Escalate only when:

- actual change surface exceeds the plan,
- verification exposes an architectural issue,
- an unknown blocks correctness,
- risk is higher than initially classified.

If blocked, preserve work and update the artifact rather than starting another broad exploration.

## Required router output

The final routing summary should fit in a compact structure:

```yaml
clae_version: 0.1
complexity: S|M|L|XS
risk: LOW|MEDIUM|HIGH
route:
  - repo-scout
  - planner
  - builder
  - verifier
  - reviewer
reason: <one concise paragraph>
artifacts: .claude/work/<TASK_ID>/
```
