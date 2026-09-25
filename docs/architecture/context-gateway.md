# Context Gateway

## Problem

A conventional multi-agent workflow can reduce work in one area while increasing context cost everywhere else. Every new agent, rule, MCP server, or document becomes another possible source of irrelevant context.

CLAE therefore treats **context as a first-class resource**.

## Core question

For every task, determine:

```text
What must the model know?
What capability is needed?
What must survive the turn?
What proves the result is correct?
```

## Context layers

```text
L0  current request
L1  task artifacts
L2  project rules and Skills
L3  durable project knowledge
L4  external tools / services
```

Load the lowest layer that can answer the question. Escalate only when needed.

## Four routers

### Task router
Chooses the smallest execution workflow.

### Test router
Decides whether dedicated tests add enough protection to justify maintenance cost.

### Documentation router
Decides whether to update, create, split, merge, or delete a document.

### Design router
Decides when a design contract, component system, Figma artifact, or visual verification is required.

## Artifact bus

Agents communicate through compact files rather than long hand-offs:

```text
contract.md
facts.md
plan.md
changes.md
verification.md
review.md
```

## Capability routing

MCPs, CLIs, and external services are capabilities. They are not permanent context.

```text
task
 ↓
capability needed?
 ├── no  → continue
 └── yes → discover/load only that capability
```

## Anti-patterns

Avoid:

- reading every task history file;
- loading every language guide into a builder;
- loading every MCP tool schema at session start;
- creating a test for every function by default;
- generating documentation without first deciding its audience and type;
- letting a frontend builder invent a new visual language per screen.
