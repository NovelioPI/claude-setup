---
paths:
  - "**/*.go"
  - "**/go.mod"
  - "**/go.sum"
---

# Go Engineering Rules

## MUST

- Handle returned errors deliberately.
- Keep package dependencies simple and directional.
- Prefer small interfaces defined by the consumer.

## PREFER

- `gofmt` and repository-standard linting.
- Context propagation for request-scoped work.
- Explicit constructors when a type has important invariants.

## AVOID

- Ignoring errors with `_` unless the omission is intentional and documented by context.
- Premature interfaces with one implementation.
- Package-level mutable state.
