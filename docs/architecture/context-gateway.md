# Context Gateway

## Goal

The Context Gateway manages context as a finite resource. It decides what the next agent step needs instead of loading all available project knowledge.

## Model

```text
Task
 → Demand
 → Candidate discovery
 → Utility/cost selection
 → Context Package
 → Materialization
 → Agent
 → Evidence
 → Verification
 → Checkpoint
 → Escalation if required
```

## Context Package

A package is a plan for context, not the context itself. It contains:

- objective
- token budget
- selected candidates
- deferred candidates
- forbidden scope
- escalation level

The materializer turns selected candidates into the small concrete snippets the agent needs.

## Context ladders

Code:

```text
L0 metadata
L1 symbol
L2 local implementation
L3 dependencies
L4 subsystem
L5 repository
```

Other domains use the same idea: project state, docs, design, and verification start with local/cheap sources and escalate only when necessary.

## Candidate scoring

The initial selector uses a deterministic heuristic:

```text
utility ≈
  relevance × authority × freshness × dependency × confidence
  -----------------------------------------------------------
                  cost^0.7
```

A redundancy penalty is applied when a candidate overlaps selected context.

The exact formula is intentionally provisional. Telemetry should guide later tuning.

## Hard vs soft context

Hard context cannot be silently dropped. Soft context competes for remaining budget.

Examples of hard context:

- task contract
- direct implementation
- mandatory language rules
- critical acceptance tests

Examples of soft context:

- old ADRs
- related documentation
- similar implementations
- historical incidents

## Escalation

Escalation requires evidence. Valid triggers:

- missing symbol or definition
- dependency impact
- conflicting sources
- failed verification
- acceptance criteria cannot be proven

Curiosity alone is not a trigger.

## Capability ladder

Use the cheapest available capability:

```text
local task state
 → local index
 → git
 → external MCP
 → human decision
```

For UI work, for example:

```text
design contract
 → component metadata
 → Storybook
 → Figma
 → human decision
```

## Checkpointing

A checkpoint records enough task state to continue without carrying the full transcript. It keeps objective, completed work, evidence, unresolved items, retained artifacts, and discarded context categories.

## Future evolution

v0.5 can add learned selection weights, semantic retrieval, better code graphs, and automatic context ROI analysis. Those are intentionally not required.


## Relationship to CLAE v0.3

v0.3 introduced the Context Gateway as a workflow concept. v0.4 turns that concept into an executable runtime. The five original coding agents remain useful, but they no longer need to decide context policy themselves. They receive or request a package from the Gateway and may escalate only for concrete evidence.
