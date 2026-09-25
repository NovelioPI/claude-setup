# CLAE

Context-Limited Agentic Engineering.

## Core principles

1. Treat context as a finite resource.
2. Give agents the smallest context and cheapest capability that can reliably complete the next step.
3. Prefer deterministic routing and tooling over LLM reasoning for mechanical decisions.
4. Separate facts, decisions, plans, changes, verification, and review.
5. Keep unknowns explicit. Never guess when evidence can be obtained.
6. Load knowledge only when the current task needs it.
7. Never preload every Skill, MCP, rule, document, or project history.
8. Use path-scoped language rules and framework Skills only when confirmed.
9. Protect behavior with tests based on risk and value, not function count.
10. Documentation needs audience, purpose, type, scope, and exclusions.
11. UI work needs a design contract and reusable component vocabulary.
12. Use `.claude/work/<task-id>/` as the task memory bus.
13. Use `.clae/` as sparse runtime state, indexes, checkpoints, and telemetry.
14. Never silently expand scope.
15. Prefer local/open tooling; external MCPs are opt-in capabilities.

## Context Gateway

For non-trivial work, route through:

```text
request
 ↓
Demand
 ↓
Candidate discovery
 ↓
Hard + soft context selection
 ↓
Context Package
 ↓
Materialize only selected detail
 ↓
Execute
 ↓
Evidence / verification
 ↓
Checkpoint
 ↓
Escalate only when evidence requires it
```

Use:

```bash
python3 .clae/scripts/clae.py package --task "<task>" --task-id <id>
```

Do not escalate from L1 to broader context just because the agent is curious. Valid escalation evidence includes missing symbols, dependency impact, conflicting evidence, failed verification, or unverifiable acceptance criteria.

## Task lifecycle

`contract → gateway → facts → plan → test decision → changes → verify → review → simplify → verify → checkpoint → integrate → learn`

## Context ladder

```text
L0 metadata
L1 symbol
L2 local implementation
L3 dependencies
L4 subsystem
L5 repository
```

Start low. Escalate with evidence.

## Capability ladder

Use the cheapest capability that can answer the question.

```text
local artifact → local index → git → MCP → human decision
```

## Output

Prefer simple English and compact status-first responses. Do not restate earlier turns unless they change the decision. Use `.claude/output-styles/clae-concise.md` when working interactively.

## Git commits

Do not add a `Co-Authored-By` trailer to commit messages.
