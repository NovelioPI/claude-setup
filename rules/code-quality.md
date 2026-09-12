## Code Quality

Definition: cognitive debt = the mental effort a reader needs to hold code in mind.
Priority: minimize cognitive debt over completeness, cleverness, or flexibility.
Read code as if the reader sees it for the first time, with no other context.

Read the language file before you write or edit code in that language.
It gives the language form of the rules below.
Python: `rules/code-quality-python.md`.
TypeScript and JavaScript: `rules/code-quality-typescript.md`.
C and C++: `rules/code-quality-cpp.md`.

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

Cap a comment at 20 words and at 2 lines.
Write a comment with one of two labels, because this section allows only
two cases:

    Reason: <cause> causes <effect>.
    Risk: if <condition>, then <consequence>.

Use simple English. See @rules/plain-words.md for the word tables.
Do not use a figure of speech.
Write a TODO with a plan ID: `TODO(H5): ...`. A bare TODO competes with
TODO.md.

### Functions

Do not extract a function that is called once, unless it removes real
duplication or names a non-obvious step.
Inline a single-use helper into its caller.
A function does one job. Split a function only when it does two or more
unrelated jobs, not to shorten line count.
Return early with a guard clause instead of nesting conditions.
A function returns a value or changes state, never both.
Do not pass a boolean that picks behavior. Write two functions instead.
Cap a function at four parameters. Group values that always travel
together into one type.
Rename a function as soon as its name stops matching its job.
Put a function in the module that owns the data it reads most.
Extract a single-use fragment when you had to read it twice to name it.
Merge conditions that produce the same result into one condition.
Pass the whole object when the callee reads three or more of its fields.

### Types

Do not use a catch-all type to pass a contract through. Name the real
type: a concrete class, a record type, or a union of concrete types.
Use a catch-all type only at a true boundary with untyped external input.
At the boundary, validate into a concrete type. Do not let the catch-all
type pass the boundary line.
Use an enum or a literal union for a fixed set of specific strings,
instead of a bare string type.
Depend on an injected abstraction only when two implementations exist.
A named type that only describes a data shape is not an abstraction.
Name the shape of every object you pass across a function boundary.
Split a wide interface only when a client must implement a method it
never calls.
Wrap a primitive in a type when two or more functions validate it the
same way.
Risk: if a parameter takes a bare string, then a typo passes the type
check and fails at run time.

### State

Thread state through a parameter or a constructor. Do not read or write
module-level mutable state (a global RNG, a global client, a global
cache).
Risk: if two callers share hidden global state, then a test run leaks
state between tests and results depend on run order.
Do not assign to a parameter. Copy it into a local variable first.
Give each variable one purpose. Do not reuse one variable for two jobs.
Do not reach through an object graph to get a value. Ask the first
object.
This limit covers a walk across objects. It does not cover a chain that
keeps returning the same kind of value, such as a promise chain, a
builder, or a query.

### Errors

Raise an exception for an input or a precondition check. Do not use an
assertion for that job.
Risk: if a check is an assertion, then an optimized build strips it and
the check disappears without a message.
Reserve an assertion for an internal invariant, never for external input.
Report a failure with an exception, not with a returned error code.

### Logging

Use a logger for output outside a CLI or a script entry point. Do not
write to standard output there.
Risk: if a library writes to standard output, then a caller cannot
filter, level, or redirect it.

### Data objects

Make a value object immutable by default. Make it mutable only when the
code needs to mutate it in place, not for convenience.
Return a read-only view of a collection. Expose an add method and a
remove method instead.

### Module boundaries

Do not use a wildcard import. It hides where a name came from and breaks
static analysis.
Keep a function private unless a caller outside the module needs it.
Do not read another module's private names. Ask that module for the value.

### Resources

Open a file, a lock, or a connection in a scope that closes it
automatically. Do not pair a manual open call with a manual close call.
Risk: if an exception happens between the two calls, then the close never
runs.

### Unused code

Delete code that no caller reaches. Do not comment it out, because
version control keeps the old copy.
Do not add a class, a parameter, or a hook for a future need.
Write the plain solution first. Add a pattern only for a real problem you
can name.
Add an extension point only when a second caller needs it now.
Move a part into its own module when it has already changed twice. Do not
move it on a guess.
Delete a class or a function that only forwards calls.
Delete a field that only one operation uses. Pass the value as a
parameter.

### Inheritance

Prefer composition and delegation over inheritance.
Replace a type conditional with one subclass for each type. Do this only
when the same switch appears in three or more places.
Prefer a tagged union with an exhaustive switch when the language can
prove that every case is handled. Use one subclass for each type only
when the language cannot prove it.
Reason: the compiler reports a missing case, so a new variant fails the
build instead of failing at run time.
Give two types that do the same job the same method names, or delete one.
Do not add a subclass here that forces a subclass there. Hold a reference
instead.
Do not inherit when the child ignores part of the parent contract.
Risk: if a child breaks the parent contract, then a caller that holds the
parent type fails on the child.

### Complexity

Cap cognitive complexity at 15 for one function.
Cap nesting depth at 5.
Reason: cognitive complexity is the only measure with evidence, because it
tracks how long a reader needs to understand a snippet.

Do not use cyclomatic complexity as a limit.
Risk: if you cap cyclomatic complexity, then it scores five nested
conditions better than six flat ones, against the guard clause rule.

### Names

Make the length of a name match the length of its scope. A name inside a
ten-line scope can be short. A name the whole module reads cannot.
Do not encode type information in a name.
Do not abbreviate by deleting letters.
Risk: if a reader cannot say a name out loud, then they cannot discuss
the code.

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

A house style guide that demands a doc comment on every public name does
not override the Comments and docstrings section. PEP 257 and the Google
TypeScript guide both demand one.
Reason: they target a shared repository with generated API docs, not a
reader of the source.
