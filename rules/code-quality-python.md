## Code Quality, Python

The Python form of the rules in `rules/code-quality.md`. Each section names
its base section. The base rule and its risk stay there.

### Comments and docstrings

Base: Comments and docstrings.

Write a comment with `#` and a label:

    # Reason: the API returns 200 with an error body.
    # Risk: if the lock is held, then this call blocks the loop.

Write a docstring with `"""`, on one line, for a public function only.
Cap a docstring at 12 words, on one physical line.

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
Use `TypedDict` only for a dict that crosses an external boundary.
`TypedDict` checks nothing at run time.
Use a `Protocol` with `__call__` for a keyword or variadic callback.
Use `Callable[..., T]` only when the argument list is truly free.
Write `def f[T](x: T) -> T` instead of a module-level `TypeVar`.

### Errors

Base: Errors.

Raise an exception for an input check or a precondition check.
Do not use `assert` for that job, because `python -O` strips every
`assert`.
Reserve `assert` for an internal invariant.
Keep the `try` block to the smallest code that can raise.
Put the follow-on code in an `else` clause, not in `try`.
Try the operation and catch the error instead of pre-checking it.
Use `suppress()` only for one named error you can ignore safely.

### Logging

Base: Logging.

Use the `logging` module outside a CLI or a script entry point.
Do not use `print` there.
Do not use an f-string in a logging call. Pass `%s` arguments instead.
Risk: if you format the message early, then logging builds a string it
may discard.

### Data objects

Base: Data objects.

Make a value object a frozen dataclass or a `NamedTuple`.
Make it mutable only when the code must mutate it in place.
Use `NamedTuple` only when a caller indexes or unpacks the value.
Do not use `NamedTuple` when a plain tuple must not compare equal.
Use a dataclass, not a `NamedTuple`, when a subclass adds fields.
Define `__eq__` and `__hash__` together, or use a frozen dataclass.
Do not define `__hash__` on a class you mutate.

### Module boundaries

Base: Module boundaries.

Do not write `from x import *`.
Mark a non-public name with one leading underscore.
Use two leading underscores only to avoid a subclass name clash.

### Resources

Base: Resources.

Open a file, a lock, or a connection with `with`.
Do not pair a manual open call with a manual close call.
Write a setup and teardown pair with `@contextmanager`, not a class.
Use `ExitStack` when the input decides how many resources open.

### Functions

Base: Functions.

Use a comprehension only to build a collection. Do not run a side effect
inside one.
Write a `for` loop when a comprehension needs two or more `for` clauses.
Bind a function with `def`. Do not assign a lambda to a name.
Prefer an assignment statement to `:=` when both work.
Use `match` to destructure a nested value, not to replace a short `if`.

### State

Base: State.

Do not put `lru_cache` on a function with a side effect.

### Inheritance

Base: Inheritance.

Use a `Protocol` instead of an ABC when the interface shares no code.
Use `__init_subclass__` instead of writing a custom metaclass.

### Python only

These rules have no base rule. They apply to Python alone.

Return a generator when the data is large or unbounded.
Return a list when the caller needs `len()` or a second pass.
Do not add `__slots__` unless the program creates very many instances.
Use `@dataclass(slots=True)` instead of a hand-written `__slots__`.
Apply `functools.wraps` in every decorator you write.

### Linting

Run `ruff`. It enforces the PEP 8 mechanics this file does not repeat.
Risk: if a rule repeats what a linter already blocks, then it costs a
line and changes nothing.
