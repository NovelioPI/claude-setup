---
name: task-router
description: Route each request to the smallest CLAE workflow. Use before execution when task type, risk, or scope is unclear.
---

# Task Router — CLAE

Route the request before spawning agents or loading large context.

## Intent classes

### BRAINSTORM

Use when the user is:
- starting a new idea or project;
- unsure what to build;
- asking for alternatives, research, architecture exploration, or product discovery;
- trying to mature a concept before implementation.

Route to `/brainstorm`.
Do not start coding.

### PROJECT

Use when the user is:
- asking for status, next task, blockers, parking, completion, or roadmap;
- maintaining task state without changing code.

Route to `/project`.
Do not load the full task history.

### CODE

Use when the user wants a repository change, bug fix, refactor, test, migration, or implementation.
Proceed through the normal CLAE pipeline.

## CODE routing matrix

| Complexity | Risk | Workflow |
|---|---|---|
| XS | low | main agent → verify |
| S | low | repo-scout → builder → verify |
| M | low/medium | repo-scout → planner → builder → verify → reviewer |
| L | medium/high | parallel scouts → planner → builder → verify → reviewer |
| XL | high | explicit plan + isolated work + specialized reviewers |

## Risk signals

Increase risk when the task touches:
- auth / security;
- public APIs;
- data migrations;
- billing / payments;
- concurrency / distributed state;
- destructive operations;
- performance-critical paths;
- infrastructure / deployment.

## Context rules

1. Use deterministic inspection before spawning an agent.
2. Give each agent only the artifacts it needs.
3. Do not load every coding standard into `builder`.
4. Language rules are path-scoped and activate when matching files are read.
5. Framework guidance is a skill and should be loaded only when the framework is confirmed.
6. Prefer a small number of high-value research passes over broad parallel exploration.
7. Stop routing once the task has a clear execution path.

## Output

Write router decisions to:

`.claude/work/<task-id>/router.md`

Use this structure:

```markdown
# Route

Intent: CODE | BRAINSTORM | PROJECT
Complexity: XS | S | M | L | XL
Risk: LOW | MEDIUM | HIGH
Workflow: <one line>
Reason: <1-3 short bullets>
Required context: <artifacts / paths>
```
