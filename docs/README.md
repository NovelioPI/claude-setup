# CLEA Documentation

Use this folder when you want to understand or extend CLAE rather than simply use it.

## Start here

- `../README.md` — complete user-facing setup and usage guide.
- `GETTING_STARTED.md` — shorter operational setup and daily workflow.
- `reference/commands.md` — CLI command reference.

## Architecture

- `architecture/context-gateway.md` — Gateway design, why CLAE treats context as a first-class resource.
- `implementation/runtime.md` — runtime implementation details.

## Workflows

- `workflows/brainstorming.md` — develop an idea before implementation.
- `workflows/project-management.md` — sparse task/project state.
- `workflows/testing.md` — behavior/risk-based test decisions.
- `workflows/documentation.md` — documentation type, scope, grouping, and compression.
- `workflows/design.md` — design contracts and visual verification.

## Integrations

- `integration/tooling.md` — free/local tooling policy.
- `integration/figma-talk-to-figma.md` — community Figma MCP setup.

## Decisions

`adr/` contains durable architecture decisions. Read these when changing the design of CLAE itself.

## Source boundary

These docs distinguish:

- CLAE design decisions;
- current external-tool facts;
- optional integrations;
- open decisions.

External tools can change independently of CLAE. Re-check their upstream documentation before upgrading an integration.
