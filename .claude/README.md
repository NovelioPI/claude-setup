# CLAE

CLAE (Context-Limited Agentic Engineering) is a repository-local operating system for agentic software work.

The goal is broader than coding: manage **context, capability, artifacts, and verification** across ideation, project management, code, tests, documentation, and design.

## Design rules

- Always-on instructions stay small.
- Rules are path-scoped.
- Skills are loaded on demand.
- MCP is optional and routed only when useful.
- Work is persisted as small artifacts rather than long chat transcripts.
- Deterministic checks handle deterministic rules.

## Main layers

```text
Project control
  .clae/

Execution knowledge
  .claude/rules/
  .claude/skills/

Context routing
  .claude/routers/
  .claude/skills/context-gateway/

Workers
  .claude/agents/

Task memory
  .claude/work/<task-id>/

External/local capabilities
  .claude/integrations/
```

See `../docs/README.md` for the design record behind this version.


## Escalation command

When evidence shows the current context package is insufficient:

```bash
python3 .clae/scripts/clae.py escalate TASK-142 --task "<task>" --reason missing_symbol --level 1 --step 0
```

Allowed reasons:
`missing_symbol`, `dependency_impact`, `conflicting_evidence`, `failed_verification`, `unverifiable_acceptance`.
