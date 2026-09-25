---
name: project
description: Track project state without loading a giant todo file. Use for status, task creation, planning, blockers, parking, completion, and project summaries.
---

# Project State

The project manager is a sparse index, not a transcript.
Never load the full history when a small subset is enough.

## Storage

```text
.clae/
├── project.yaml          # tiny project index
├── tasks/                # active task records only
├── archive/              # completed / parked historical records
└── ideas/                # brainstorming artifacts
```

## Task lifecycle

```text
PLANNED → ACTIVE → DONE
             ├── BLOCKED
             └── PARKED
```

A task can return from BLOCKED/PARKED to ACTIVE.

## Commands / intents

Interpret requests such as:

- "project status" → show active tasks, blockers, next 1-3 actions.
- "what should I do next?" → choose from ACTIVE/PLANNED tasks using dependency, priority, and readiness.
- "add task ..." → create one task file.
- "start TASK-..." → mark ACTIVE.
- "block TASK-..." → record blocker and mark BLOCKED.
- "park TASK-..." → mark PARKED with a reason.
- "done TASK-..." → record verification and move to archive.
- "project summary" → synthesize from project index + active task files only.

## Context rules

- Never print or read all archived tasks for a normal status request.
- Read only task files needed to answer the question.
- Keep `project.yaml` under ~60 lines.
- Keep task records short; put deep technical context in task artifacts under `.claude/work/<task-id>/`.
- Do not use a giant `todo.md` as the source of truth.

## Task record

Use `.claude/schemas/task.schema.json` as the canonical shape.

Example:

```yaml
id: TASK-2026-0924-001
title: Add bid strategy abstraction
status: ACTIVE
priority: high
depends_on: []
scope:
  - src/bidding/**
acceptance:
  - Existing bid tests pass
  - No public API change
artifacts:
  contract: .claude/work/TASK-2026-0924-001/contract.md
  plan: .claude/work/TASK-2026-0924-001/plan.md
created: 2026-09-24
updated: 2026-09-24
```

## Completion rule

A task is not DONE because the agent says it is done.
It is DONE only when the task has a verification artifact with a passing result.
