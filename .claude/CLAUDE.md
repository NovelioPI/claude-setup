# CLAE

Context-Limited Agentic Engineering.

## Core principles

1. Keep always-on context tiny.
2. Prefer deterministic tools over LLM reasoning for mechanical work.
3. Load knowledge only when the current task needs it.
4. Separate facts, decisions, plans, changes, verification, and review.
5. Keep unknowns explicit. Never guess when evidence can be obtained.
6. Main-session work is routing, decisions, integration, and user communication.
7. Use the smallest number of agents and tools that can solve the task.
8. Never expand scope silently.
9. Treat `.claude/work/<task-id>/` as the task memory bus.
10. Treat `.clae/` as sparse project state, not conversation history.
11. Use path-scoped language rules; use framework Skills only when the framework is confirmed.
12. Use behavior-based testing decisions; do not create tests only because a function exists.
13. Documentation must have an audience, purpose, type, and scope before it is written.
14. UI work must use an explicit design contract and existing component vocabulary when available.
15. Prefer local/open tooling. Do not assume a paid SaaS or paid MCP is available.
16. Promote durable lessons into rules, Skills, or ADRs instead of transcript memory.

## Routing model

```text
request
  ↓
context gateway
  ├── task router
  ├── test router
  ├── doc router
  └── design router
  ↓
minimum required context + capability
  ↓
execution
  ↓
verification
```

## Task lifecycle

`contract → facts → plan → test decision → changes → verify → review → simplify → verify → integrate → learn`

## Output style

Prefer simple English and compact status-first responses. Do not restate earlier turns unless they change the current decision. Use `.claude/output-styles/clae-concise.md` when this repository is used interactively.

## Stop conditions

An agent stops when its artifact contract is satisfied. If blocked, write `status: BLOCKED` and the smallest actionable blocker.
