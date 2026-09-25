# Project Management Workflow

## Problem with a giant `todo.md`

A single task log gradually becomes a mix of:

- current state
- history
- technical notes
- old decisions
- irrelevant completed work

That makes every project-status request more expensive than necessary.

## CLAE model

Use a sparse local state:

```text
.clae/
├── project.yaml
├── tasks/
├── archive/
└── ideas/
```

`project.yaml` is a hot cache. Task files are the active state. Archive is cold storage.

## External PM boundary

An external PM system is optional. If used, it is the control plane for human-facing state; `.clae/` remains the execution cache.

```text
PM system
  backlog / priority / status / dependencies
            ↓
    small local snapshot
            ↓
       agent workflow
            ↓
       Git + artifacts
```

Never mirror every PM field locally.

## Free-first policy

CLAE does not require Jira or another paid PM platform. Git issues/projects or local `.clae/` state are valid alternatives.

## State rules

- Keep the project index under ~60 lines.
- Keep task records short.
- Put technical detail in `.claude/work/<task-id>/`.
- Do not read archive for routine status checks.
- A task is DONE only after verification is recorded.
