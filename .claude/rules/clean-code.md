# Clean Code Core

These rules are language-independent and intentionally small.

## MUST

- Prefer clear names over comments that explain unclear code.
- Keep one responsibility per function or class when practical.
- Keep control flow shallow; extract complex branches.
- Make dependencies explicit.
- Keep public interfaces small and stable.
- Remove dead code and duplicated logic when touching nearby code.

## PREFER

- Small pure functions for transformations.
- Early returns for guard conditions.
- Data structures that make invalid states hard to represent.
- Tests at the behavior boundary, not only internal implementation details.

## AVOID

- Clever abstractions without a repeated need.
- Generic helpers used by only one caller.
- Large comments that describe code instead of intent.
