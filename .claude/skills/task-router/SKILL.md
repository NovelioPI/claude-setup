---
name: task-router
description: Route requests to the smallest CLAE workflow. Use before non-trivial work.
---

# Task Router — CLAE

Route first. Load context second. Execute third.

## Intent classes

- BRAINSTORM → `/brainstorm`
- PROJECT → `/project`
- CODE → coding pipeline
- TEST → `test-strategy` + relevant verification
- DOCS → `doc-router` + doc agents
- DESIGN → `design-router` + design agents/tools
- MIXED → split into explicit sub-tasks with independent artifacts

## Code routing

| Complexity | Risk | Workflow |
|---|---|---|
| XS | low | main → verify |
| S | low | scout → builder → verify |
| M | low/medium | scout → planner → test-strategy → builder → verify → review |
| L | medium/high | parallel focused scouts → planner → test-strategy → builder → specialized review |
| XL | high | explicit plan → isolated execution → specialized verification |

## Risk signals

Increase risk for:
- auth/security
- public APIs
- migrations
- billing/payments
- concurrency/distributed state
- destructive operations
- infrastructure/deployment
- performance-critical code

## Routing rules

- Do not load all language rules. They are path-scoped.
- Load framework Skills only after the framework is confirmed.
- Do not load design tools for backend-only work.
- Do not load browser tooling unless a browser check is useful.
- Do not load project history for a coding task unless the task depends on it.
- Use the lowest-cost capability that can answer the question.
