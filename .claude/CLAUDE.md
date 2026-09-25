# CLAE v0.1

Context-Limited Agentic Engineering for this repository.

## Operating principles

1. Prefer deterministic tools over LLM reasoning.
2. Prefer symbol-level navigation over reading entire files.
3. Delegate broad exploration to `repo-scout`.
4. Separate facts, decisions, plans, changes, verification, and review.
5. Keep unknowns explicit. Never guess when evidence can be obtained.
6. Keep the main session focused on routing, decisions, integration, and user communication.
7. Use the minimum number of agents required.
8. Do not expand scope without recording why.
9. Verify behavior with executable checks.
10. Treat artifacts in `.claude/work/<task-id>/` as the task memory bus.
11. Prefer small, reversible changes.
12. Promote durable lessons into rules/skills/ADRs; do not dump transcripts into memory.

## Task lifecycle

`contract -> facts -> plan -> changes -> verify -> review -> simplify -> verify -> integrate -> learn`

## Artifact rule

Agents must write compact, structured artifacts instead of returning long explanations.
Every factual claim about the repository should have file/symbol/line evidence when practical.

## Stop conditions

An agent should stop when its artifact contract is satisfied. If blocked, write `status: BLOCKED` and record the smallest actionable reason.

## Commands

Use the repository's real commands when known. Otherwise inspect `pyproject.toml`, `package.json`, `Makefile`, CI configuration, or equivalent before inventing commands.
