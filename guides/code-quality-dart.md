## Code Quality, Dart and Flutter

The Dart form of the rules in `rules/code-quality.md`, and the Flutter
rules that sit on top. Each section names its base section. The base rule
and its risk stay there.

### Comments and docstrings

Base: Comments and docstrings.

Write `///` for a reader of the API. Write `//` for a note about the
implementation.
Write one line only when the signature does not say what it does.
Start a doc comment with one sentence on one line.
Name an in-scope identifier in square brackets: `[parseHeader]`.

Write a comment with a label:

    // Reason: the server sends 200 with an error body.
    // Risk: if the widget unmounts first, then this context is dead.

### Types

Base: Types.

Name the real type: a concrete class, an enum, or a sealed class
hierarchy.
Annotate the return type and every parameter type of a function
declaration.
Let inference type a local variable that has an initializer.
Use an enum or a sealed class for a fixed set of values, not a bare
`String`.
Switch on a sealed class and cover every case.
Reason: the analyzer reports a missing case, so a new variant fails the
build instead of failing at run time.
Write `dynamic` only at a true boundary with untyped external input.
Validate into a concrete class there.
Return `Future<void>` from an async member that produces no value.
Return an empty collection, not `null`, from a member that returns a
collection, a `Future`, or a `Stream`.

### Functions

Base: Functions.

Bind a function to a name with a function declaration.
Pass a tear-off, such as `names.forEach(print)`, instead of a lambda that
only forwards.
Write `=>` for a member whose body is one expression.
Take a named parameter instead of a positional boolean.
Mark a named parameter `required` instead of taking a value that means
"no argument".
Write an inclusive start and an exclusive end for a range.

### State

Base: State.

Declare a field and a top-level variable `final`.
Initialize a field where you declare it, or with an initializing formal.
Write `late` only where an initializer list cannot run first.
Keep a public `late final` field with no initializer out of the API.
Compute a derived value in a getter instead of storing it and keeping it
in sync.

### Errors

Base: Errors.

Throw a class that extends `Exception` for a condition a caller handles.
Throw an `Error` only for a bug in the program.
Write `on` with a type on every `catch` clause.
Handle or report every error you catch.
Write `rethrow` to keep the original stack trace.

### Data objects

Base: Data objects.

Declare a value class with `final` fields and a `const` constructor.
Override `hashCode` in the same class that overrides `==`.
Define `==` only on an immutable class.
Risk: if a mutable object changes after a `Map` stores it, then the lookup
misses.
Return an unmodifiable view of a collection. Give an add method and a
remove method instead.

### Module boundaries

Base: Module boundaries.

Mark a non-public name with one leading underscore.
Import a package by its public path. Do not import a path under another
package's `src` directory.
Write a relative import inside one package.

### Resources

Base: Resources.

Cancel a `StreamSubscription`, close a `Sink`, and dispose a controller in
`dispose`.
Cancel pending async work in `dispose`.
Risk: if a request finishes after dispose, then the callback writes to a
dead widget.

### Asynchrony

These rules have no base rule.

Write `async` and `await`. Do not chain `then` calls.
Mark a function `async` only when its body awaits.
Await every `Future`, or mark it `unawaited`.
Start independent calls together with `Future.wait`.
Build a `Future` with an `async` function, not with a `Completer`.

### Flutter only

These rules apply to Flutter alone.

Write `const` on every widget whose arguments are constant.
Write a reusable piece of UI as a `StatelessWidget`, not as a method that
returns a `Widget`.
Reason: a widget class gets its own element, so Flutter can skip the
rebuild.
Call `setState` in the smallest widget that shows the changed value.
Build a long list with `ListView.builder`, not with a `children` list.
Pass the subtree that does not animate to `AnimatedBuilder` as `child`.
Check `mounted` before you use a `BuildContext` after an `await`.
Keep expensive work out of `build`. Do it in `initState` or in the model.
Hold screen state in an immutable class and replace the whole object.
Keep business logic out of a widget. A widget lays out, animates, and
routes.
Read data through a repository that returns a domain model. Keep the
transport type out of the widget.
Set `borderRadius` instead of wrapping a widget in a clip.
Use `AnimatedOpacity` or `FadeInImage` instead of `Opacity` in an
animation.
Leave `operator ==` off a widget class.
Risk: if a widget defines `==`, then the element walk costs O(n squared).
Build a string with a `StringBuffer` inside a loop.

### Linting

Run `dart analyze` and `dart format`. Turn on `flutter_lints` in
`analysis_options.yaml`.
Add these rules, because they enforce the sections above automatically:

    use_build_context_synchronously
    cancel_subscriptions
    close_sinks
    unawaited_futures
    only_throw_errors
    avoid_dynamic_calls
    prefer_const_constructors

Risk: if a rule repeats what a linter already blocks, then it costs a line
and changes nothing.
