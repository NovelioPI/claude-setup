# Changelog

This file records notable changes to CLAE, in reverse-chronological order.

## v0.4 - 2026-09-25

- Added executable Context Gateway runtime under `.clae/gateway/`.
- Added demand modeling, candidate discovery, budgeted context selection, materialization, escalation, capability routing, checkpoints, compaction, and telemetry.
- Added context demand, candidate, package, checkpoint, and capability schemas.
- Added Gateway tests.
- Kept runtime dependency-free using Python standard library.
- Kept the free/local integration policy, including `arinspunk/claude-talk-to-figma-mcp`.

## v0.3 - 2026-09-25

### Added

- Context Gateway skill that builds a minimum-sufficient context package before non-trivial work, plus ADR 0001.
- Free/local integration tooling: Figma (Talk to Figma), shadcn, Storybook, Playwright CLI, plus ADR 0002.
- Test-decision workflow: `test-strategy` skill, test router, schema, and template, plus ADR 0003.
- Design contract workflow: `design-explorer` and `design-reviewer` agents, `design-router` and `design-dna` skills, `playwright-cli` skill, design rule, schema, and template, plus ADR 0004.
- Documentation workflow: `doc-writer` and `doc-reviewer` agents, `doc-router` skill, documentation rule, schema, and template.
- Project docs index and discussion log under `docs/`.
- Root `README.md` and a routing model in `CLAUDE.md`: every non-trivial request now passes through the Context Gateway to a task, test, doc, or design router.
- `task-router` skill reworked with two new intent classes, TEST and DOCS, alongside BRAINSTORM, PROJECT, CODE, DESIGN, and MIXED.

## v0.2 - 2026-09-25

### Added

- Concise output style (`clae-concise`) and a `settings.local.json.example` for personal setup.
- `brainstorm` skill for maturing an idea before execution.
- Sparse project tracking under `.clae/` (`project.yaml`, `tasks/`, `archive/`, `ideas/`), plus the `project` skill and its schemas.
- Path-scoped language rules (Go, Python, SQL, TypeScript) and a clean-code rule.
- `fastapi` framework skill.
- Repository `.gitignore` and `.ignore`, covering caches, local settings, and Windows zone-identifier files.

### Changed

- `task-router` skill reworked around intent classes (BRAINSTORM, PROJECT, CODE) instead of complexity/risk alone.
- `CLAUDE.md` and `README.md` updated to keep project state and language rules out of always-on context, loaded on demand.

## v0.1 - 2026-09-25

### Added

- Initial CLAE agent workflow scaffold.
- Five isolated agent roles: `repo-scout`, `planner`, `builder`, `verifier`, `reviewer`.
- `task-router` skill for complexity x risk routing.
- Machine-readable schemas and human-readable templates for task artifacts.
- Verification hooks: a post-edit Python syntax check and an optional stop gate.
- `init_task.py` script to create the active task workspace.
