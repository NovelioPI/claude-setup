---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.mts"
  - "**/*.cts"
  - "**/package.json"
  - "**/tsconfig.json"
---

# TypeScript Engineering Rules

## MUST

- Preserve strict type checking when the project enables it.
- Avoid `any` at public boundaries.
- Validate untrusted input before it enters typed domain logic.
- Keep async error handling explicit.

## PREFER

- Narrow literal types and discriminated unions for finite states.
- Small modules with explicit exports.
- Runtime schemas where external data crosses a trust boundary.

## AVOID

- Type assertions used to suppress real type errors.
- Deeply nested promise chains.
- Large barrel files that hide dependency direction.

## VERIFY

Use the repository's formatter, linter, type checker, and tests.
