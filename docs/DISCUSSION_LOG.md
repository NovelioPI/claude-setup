# CLAE Discussion Log

## Goal

Build an agentic workflow that minimizes token cost while improving readability, maintainability, and scalability.

## v0.1

- artifact bus instead of long agent hand-offs;
- scout, planner, builder, verifier, reviewer;
- deterministic hooks;
- risk × complexity routing;
- compact structured artifacts.

## v0.2

- concise output style;
- brainstorming as a first-class workflow;
- sparse project state instead of a giant `todo.md`;
- path-scoped language rules;
- framework guidance as on-demand Skills;
- progressive disclosure as the context strategy.

## v0.3

### Project management

An external PM system may be a control plane, but CLAE itself must not depend on a paid PM platform. Local `.clae/` state remains the execution cache.

### Testing

Avoid one-test-file-per-function. Make an explicit test-value decision and prefer the cheapest adequate verification.

### Documentation

Use a documentation router, scope contract, typed documentation categories, and ADRs for durable architecture decisions.

### Design

Frontend work needs a stable design contract, a component vocabulary, and visual verification. Design tools are capabilities, not always-on context.

### Tooling cost

Prefer local/open-source tools. For Figma, use the community local server requested for CLAE. For browser work, prefer Playwright CLI + Skills when they reduce context overhead.

## Final model

```text
Context Gateway
    │
    ├── task router
    ├── test router
    ├── doc router
    └── design router
    │
    ▼
minimum context + capability
    │
    ▼
execution
    │
    ▼
artifact
    │
    ▼
verification / review
```
