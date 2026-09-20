## Code Quality, Kotlin

The Kotlin form of the rules in `rules/code-quality.md`. Each section names
its base section. The base rule and its risk stay there.

### Comments and docstrings

Base: Comments and docstrings.

Write KDoc for a reader of the API. Write `//` for a note about the
implementation.
Write one line only when the signature does not say what it does.
The Android style guide demands KDoc on every public type and member. The
base default holds instead.
Reason: that guide targets a shared repository with generated API docs, not
a reader of the source.

Write a comment with a label:

    // Reason: the API returns 200 with an error body.
    // Risk: if the lock is held, then this call blocks the loop.

### Types

Base: Types.

Name the real type: a concrete class, a data class, a sealed interface, or
a union of them.
Turn a platform type from Java into a declared Kotlin type at the call
boundary.
Risk: if a platform type spreads, then no null check runs and the failure
lands far from the call.
Declare the return type and the property type of every public declaration.
Use an enum class or a sealed interface for a fixed set of values, not a
bare `String`.
Wrap a primitive in a `value class` when two or more functions validate it
the same way.
Read a nullable value with `?.`, `?:`, or a smart cast. Write `!!` only
where you can name the invariant that holds.
Use `Any?` only at a true boundary with untyped external input. Validate
into a concrete type there.
Declare a collection parameter as `List`, `Set`, or `Map`, not as the
mutable interface.

### Functions

Base: Functions.

Write an expression body for a single-expression function.
Give a parameter a default value instead of writing an overload.
Write an extension function when the function works mainly on one
receiver. Keep it `private` or `internal`.
Declare an extension outside a class.
Risk: if an extension is a member, then it binds two receivers and the
call site cannot say which one applies.
Name an argument at the call site when the literal does not say what it
means.
Write one function at one level of abstraction.
Build a collection with `filter`, `map`, and `first`. Write a `for` loop
for a side effect.
Reserve `infix` for two operands of the same role, such as `to` and `and`.

### State

Base: State.

Declare a `val`. Declare a `var` only where the code reassigns the name.
Keep one mutation point for one piece of state. Back a public read-only
`List` with a private `MutableList`.
Name the backing property with one leading underscore.
Give `lateinit` only to a field that a framework sets before first use.
Risk: if `lateinit` covers ordinary flow, then the failure is an exception
at read time, not a compile error.

### Errors

Base: Errors.

Check an argument with `require`. Check state with `check`. Report an
impossible branch with `error`.
Reserve `assert` for an internal invariant, because the JVM runs it only
with `-ea`.
Throw a standard exception, such as `IllegalArgumentException`. Define a
new type only when a caller catches it to act.
Return `T?` or `Result<T>` when a missing result is an ordinary outcome.
Catch the named exception in a function that can act on it.
Rethrow `CancellationException`.
Risk: if a `catch` swallows `CancellationException`, then a cancelled
coroutine keeps running.

### Logging

Base: Logging.

Use a logger outside a CLI entry point. Do not use `println`.
Pass the message as a lambda when the logger takes one.
Risk: if you build the message early, then logging formats a string it may
discard.

### Data objects

Base: Data objects.

Declare a value object as a `data class` with `val` properties.
Change a value object with `copy`.
Put a field that is not part of the value outside the primary constructor.
Reason: `data class` builds `equals` and `hashCode` from the primary
constructor only.
Define `equals` and `hashCode` together, or let `data class` write both.
Return `List` from a property that exposes a collection. Give an add
method and a remove method instead.
Copy a read-only collection with `toMutableList()` when you need to change
it. Do not cast it to `MutableList`.

### Module boundaries

Base: Module boundaries.

Mark a declaration `internal` when only the module reads it. Mark it
`private` when only the file reads it.
Turn on explicit API mode in a library module with
`-Xexplicit-api=strict`.
Import each name. Do not write a star import.

### Resources

Base: Resources.

Open a `Closeable` with `use`.
Do not pair a manual open call with a manual close call.

### Inheritance

Base: Inheritance.

Model a restricted hierarchy with a `sealed class` or a `sealed interface`
and an exhaustive `when`.
Reason: the compiler reports a missing branch, so a new variant fails the
build instead of failing at run time.
Keep a class `final`, the Kotlin default. Write `open` only where a
subclass exists now.
Hold a reference and delegate with `by` instead of inheriting.
Declare an `interface` when the types share no code.

### Coroutines and flows

These rules have no base rule.

Take a `CoroutineDispatcher` as a constructor parameter with a default
value.
Reason: an injected dispatcher lets a test pass a `TestDispatcher`.
Make a `suspend` function safe to call from the main thread. Move blocking
work with `withContext`.
Launch from a scope that an owner cancels, such as `viewModelScope`. Take
an injected `CoroutineScope` for work that outlives the caller.
Do not launch from `GlobalScope`.
Expose `StateFlow` and `Flow`. Keep `MutableStateFlow` private.
Expose a `suspend` function for a one-shot result, and a `Flow` for a
value that changes over time.
Call `ensureActive()` inside a long loop that never suspends.

### Kotlin only

These rules have no base rule. They apply to Kotlin alone.

Pick a scope function by its job: `let` for a nullable value, `apply` for
configuration, `run` for a block that returns a value, `also` for a side
effect, `with` for repeated access to one receiver.
Chain a `Sequence` when a large collection passes through two or more
steps.
Mark a function `inline` when it takes a lambda parameter and runs in a
hot path.
Declare a stateless helper holder as an `object`.
Define a `typealias` for a function type that appears in three or more
signatures.
Write `0..<n`, not `0..n - 1`.
Build a string with a template, not with `+`.

### Linting

Run `ktlint` and `detekt`. They enforce the formatting and the complexity
limits this file does not repeat.
Risk: if a rule repeats what a linter already blocks, then it costs a line
and changes nothing.
