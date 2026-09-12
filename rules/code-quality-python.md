## Code Quality, Python

The Python form of the rules in `rules/code-quality.md`. Each section names
its base section. The base rule and its risk stay there.

### Comments and docstrings

Base: Comments and docstrings.

Write a comment with `#` and a label:

    # Reason: the API returns 200 with an error body.
    # Risk: if the lock is held, then this call blocks the loop.

Write a docstring with `"""`, on one line, for a public function only.

### Types

Base: Types.

Name the real type: a concrete class, `TypedDict`, `Protocol`, or a union
of concrete types.
Use `Any` only at a true boundary with untyped external input.
At the boundary, validate into a `TypedDict`, a `pydantic` model, or a
`cast()` right after the call.
Use `X | None`, not `Optional[X]`.
Use a builtin generic (`list[int]`), not the `typing` alias (`List[int]`).
Use `Literal` or a string enum for a fixed set of strings, not a bare `str`.

### Errors

Base: Errors.

Raise an exception for an input check or a precondition check.
Do not use `assert` for that job, because `python -O` strips every
`assert`.
Reserve `assert` for an internal invariant.

### Logging

Base: Logging.

Use the `logging` module outside a CLI or a script entry point.
Do not use `print` there.

### Data objects

Base: Data objects.

Make a value object a frozen dataclass or a `NamedTuple`.
Make it mutable only when the code must mutate it in place.

### Imports

Base: Imports.

Do not write `from x import *`.

### Resources

Base: Resources.

Open a file, a lock, or a connection with `with`.
Do not pair a manual open call with a manual close call.
