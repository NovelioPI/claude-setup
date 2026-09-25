# CLAE

**Context-Limited Agentic Engineering**

CLAE is an agentic workflow for software projects designed around one question:

> **What is the minimum context, capability, and verification needed for this task?**

The system grew from a simple coding pipeline into a broader workflow for:

- brainstorming and research
- project state
- code changes
- test decisions
- documentation
- UI/UX design
- visual verification
- long-term engineering memory

## Why this updates exist

Earlier versions solved agent isolation and task artifacts, but four problems remained:

1. builders created too many low-value tests;
2. documentation became large and poorly scoped;
3. frontend agents lacked a stable design source of truth;
4. more external tools threatened to increase context instead of reducing work.

v0.3 introduces a **Context Gateway** and four routers:

```text
                 Context Gateway
                       │
       ┌───────────────┼───────────────┐
       │               │               │
   task-router     test-router      doc-router      design-router
       │               │               │               │
       ▼               ▼               ▼               ▼
    agents         test plan       docs scope      design contract
```

## Repository layout

```text
.claude/
├── CLAUDE.md
├── agents/
├── integrations/
├── routers/
├── rules/
├── schemas/
├── skills/
├── templates/
├── hooks/
└── work/

.clae/
├── project.yaml
├── tasks/
├── ideas/
└── archive/

docs/
├── architecture/
├── workflows/
├── integration/
└── adr/
```

## Typical flows

### New project

```text
idea
 ↓
/brainstorm
 ↓
research + challenge + converge
 ↓
project brief
 ↓
project task
```

### Code change

```text
task
 ↓
task-router
 ↓
repo-scout
 ↓
planner
 ↓
test-router
 ↓
builder
 ↓
verify
 ↓
review
```

### Documentation change

```text
request
 ↓
doc-router
 ↓
scope contract
 ↓
existing-doc search
 ↓
write/update
 ↓
doc review
```

### Frontend change

```text
requirement
 ↓
design-router
 ↓
design contract
 ↓
Figma reference / component system
 ↓
builder
 ↓
Storybook / Playwright verification
```

## Free/local tooling policy

CLAE does not require paid MCP services.

The bundled integration guidance prefers:

- local/community Figma MCP: `arinspunk/claude-talk-to-figma-mcp`
- Playwright CLI + Skills for browser work
- Storybook Skills/plugin when Storybook is present
- shadcn registry tooling when a React/shadcn project uses it
- Git/local artifacts for project state when no external PM system is available

External SaaS can be added by a user, but is not a CLAE requirement.

## Start here

1. Read `.claude/CLAUDE.md`.
2. Copy `.claude/output-styles/clae-concise.md` to your user output styles if desired.
3. Use `/brainstorm` before coding when the idea is still unclear.
4. Use `/project` only when project state is actually needed.
5. Let the routers decide which rules, Skills, agents, and tools to load.
6. Keep `.clae/project.yaml` small.
7. Put deep work in `.claude/work/<task-id>/`.

## Design philosophy

CLAE is not a collection of prompts. It is a **context management system**.

```text
Context → Capability → Artifact → Verification
```
