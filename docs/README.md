# CLAE Documentation

This folder records the reasoning behind CLAE and the workflow decisions made during its design.

## Documents

- `architecture/context-gateway.md` — why CLAE centers on context routing.
- `workflows/brainstorming.md` — idea development before execution.
- `workflows/project-management.md` — sparse project state and external PM boundaries.
- `workflows/testing.md` — avoiding low-value test files and test sprawl.
- `workflows/documentation.md` — documentation routing, scope, and compression.
- `workflows/design.md` — design contracts, Figma, Storybook, and visual verification.
- `integration/tooling.md` — free/local tooling policy and integration choices.
- `adr/0001-context-as-a-first-class-resource.md` — durable architecture decision.

## Source boundary

These docs summarize the design discussion that produced CLAE. They intentionally distinguish:

- project design decisions;
- current external-tool facts;
- optional integrations;
- open decisions.

Do not treat third-party tool availability as a permanent guarantee. Re-check the referenced project when upgrading CLAE.
