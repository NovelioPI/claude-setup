---
name: context-gateway
description: Decide which project context, rules, Skills, agents, artifacts, and tools are needed for the current request. Use before non-trivial work.
---

# Context Gateway

Treat context as a budget.

## Steps

1. Classify the request: brainstorm, project, code, test, docs, design, mixed.
2. Identify the smallest required facts.
3. Identify required deterministic checks.
4. Identify optional capabilities (MCP, CLI, external source).
5. Load only the matching language/framework/design rules.
6. Write a compact route artifact when the task is non-trivial.

## Rules

- Never preload every Skill.
- Never preload every MCP tool.
- Never read all project history.
- Prefer current artifacts over old transcript context.
- Prefer local tools when they are sufficient.
- Prefer deterministic tools for deterministic work.
