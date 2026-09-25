---
paths:
  - "**/*.py"
  - "**/*.pyi"
  - "**/pyproject.toml"
---

# Python Engineering Rules

## MUST

- Format with the project's configured formatter.
- Prefer type hints for public functions and important boundaries.
- Use exceptions for exceptional states, not normal branching.
- Avoid mutable default arguments.
- Keep I/O at clear boundaries; keep core logic testable.

## PREFER

- `pathlib` for filesystem paths.
- Small typed data objects over loose dictionaries at stable boundaries.
- `dataclass` or `BaseModel` when the project already uses them consistently.

## AVOID

- Broad `except Exception` without a clear recovery policy.
- Hidden global state.
- `Any` at public boundaries unless justified.

## VERIFY

Prefer the repository's configured formatter, linter, type checker, and test commands. Do not invent a tool if the project already has one.
