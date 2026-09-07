## Code Quality

Definition: cognitive debt = the mental effort a reader needs to hold code in mind.
Priority: minimize cognitive debt over completeness, cleverness, or flexibility.
Read code as if the reader sees it for the first time, with no other context.

### Comments and docstrings

Default: write no comment and no docstring.
Add one only when the user asks for it, or when a hidden constraint, a
subtle invariant, or a workaround would make a reader change the code
wrongly without it.
Do not write a docstring for a private or internal function.
Write one line only for a public function docstring, and only when the
signature does not already say what it does.
Do not write a comment that restates the code. Write a comment only for
a non-obvious reason behind a choice.
Push a multi-sentence explanation into a doc file, not a docstring or a
comment block. Write a doc file only when asked.

### Functions

Do not extract a function that is called once, unless it removes real
duplication or names a non-obvious step.
Inline a single-use helper into its caller.
A function does one job. Split a function only when it does two or more
unrelated jobs, not to shorten line count.

### Types (Python)

Do not use `Any` to pass a contract through. Name the real type: a
concrete class, `TypedDict`, `Protocol`, or a union of concrete types.
Use `Any` only at a true boundary with untyped external input. At the
boundary, validate into a concrete type (a `TypedDict`, a `pydantic`
model, or a `cast()` right after the call). Do not let `Any` pass the
boundary line.
Use `X | None`, not `Optional[X]`. Use a builtin generic (`list[int]`),
not the `typing` alias (`List[int]`).
Use `Literal` for a fixed set of specific strings, or a string enum,
instead of a bare `str` parameter. A bare `str` accepts a typo; `Literal`
or an enum fails at check time.

### State

Thread state through a parameter or a constructor. Do not read or write
module-level mutable state (a global RNG, a global client, a global
cache).
Risk: if two callers share hidden global state, then a test run leaks
state between tests and results depend on run order.

### Errors

Raise an exception for an input or a precondition check. Do not use
`assert` for that job: `python -O` strips every `assert`, so a check
written as one disappears silently in an optimized run.
Reserve `assert` for an internal invariant, never for external input.

### Logging

Use the `logging` module for output outside a CLI or a script entry
point. Do not use `print` there: a library caller cannot filter, level,
or redirect a `print` call.

### Data objects

Make a value object immutable by default: a frozen dataclass or a
`NamedTuple`. Make it mutable only when the code needs to mutate it in
place, not for convenience.

### Imports

Do not use a wildcard import (`from x import *`). It hides where a name
came from and breaks static analysis.

### Resources

Open a file, a lock, or a connection with `with`. Do not pair a manual
open call with a manual close call: an exception between the two skips
the close.

### Constants

Name a magic number as a constant. An unexplained literal forces the
reader to reverse-engineer its meaning.

### Tests

Do not write one test file per source file, by default.
Do not write one test per function, by default.
Write a test at a behavior boundary: one test per observable behavior.
Skip a test for a trivial function with no branch and no edge case.
A bug fix ships together with a regression test that reproduces the
bug first.

### File and folder size

A file crossing about 300-400 lines is a signal to check cohesion, not
a command to split it. Split only when the check finds two or more
unrelated concerns in the file.
Group files into folders by domain or feature, not by file type alone.
Risk: if a folder has more test files than code files, then tests need
consolidation, not more files.

### Conflicts and exceptions

A project CLAUDE.md rule overrides this section when the two conflict,
for that project only.
