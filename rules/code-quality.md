## Code Quality

Definition: cognitive debt = the mental effort a reader needs to hold code in mind.
Priority: minimize cognitive debt over completeness, cleverness, or flexibility.
Read code as if the reader sees it for the first time, with no other context.

### Comments and docstrings

Do not write a docstring for a private or internal function.
Write one line only for a public function docstring, only when the
signature does not already say what it does.
Do not write a comment that restates the code. Write a comment only for
a non-obvious reason behind a choice.
Push long explanation into a doc file. Write a doc file only when asked.

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
