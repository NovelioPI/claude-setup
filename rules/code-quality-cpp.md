## Code Quality, C and C++

The C and C++ form of the rules in `rules/code-quality.md`. Each section
names its base section. The base rule and its risk stay there.

Prefer the standard library to hand-written code.
Prefer a suitable abstraction to a raw language feature.

### Comments and docstrings

Base: Comments and docstrings.

State intent in a comment. Do not state mechanism.
Name a non-obvious call-site argument in a short comment.

### Resources

Base: Resources.

Tie every resource to an object whose destructor releases it.
Treat a raw pointer and a raw reference as non-owning. Mark an owner
with a smart pointer.
Never transfer ownership through a raw pointer or a raw reference.
Give a class one fixed owner for each resource it holds.
Prefer a scoped object. Put an object on the heap only for a reason you
can name.
Prefer `unique_ptr` to `shared_ptr` unless two owners really exist.
Break a cycle of `shared_ptr` with a `weak_ptr`.
Take a smart pointer parameter only to state a lifetime effect. Take
`T*` or `T&` when the function only reads or writes the object.
Do one explicit allocation in one statement, and hand it to a manager
object in that same statement.
Do not pass a pointer or a reference taken from an aliased smart
pointer.
Do not let an iterator, a pointer, or a reference outlive its container
element.
Write `std::move` only when you move an object into another scope.
Avoid a large stack allocation.

### Errors

Base: Errors.

Pick one error strategy for the whole project before you write code.
Pick the termination strategy before you write the first error path.
Build that strategy around the invariant each type keeps.
Throw when a function cannot do its assigned task. Let a constructor
throw when it cannot establish the invariant.
Use an exception for an error only, never for ordinary control flow.
Define a purpose-built exception type. Do not throw a built-in type.
Do not catch an exception in a function that cannot act on it.
Keep explicit `try` and `catch` rare. Let a destructor do the cleanup.
Never let an exception leave a destructor.
Do not report an error through global state such as `errno`.
Do not use an in-band error indicator such as a sentinel return value.
Read the value a library call returns, or say why you ignore it.
Let library code detect an error without deciding how to handle it.

When the project forbids exceptions, put cleanup in a scope-exit object
and return an error code from every function, not from some.

### Functions

Base: Functions.

Return a value instead of writing through an output parameter.
Return a named struct when a function produces two or more values.
Pass a cheap-to-copy input by value. Pass anything else by reference to
const.
Pass an in-out parameter by reference to non-const.
Use `T*` rather than `T&` when "no argument" is a valid call.
Mark a pointer parameter that must never be null.
Pass a range as one span object, not as a pointer and a length pair.
State the precondition and the postcondition of a function.
Give related functions the same shape and the same error report.
Use an overload only when the call site says which one runs.
Give a default argument only when its value never changes.
Avoid a complicated expression. Split it into named steps.
Do not depend on the order in which function arguments evaluate.
Turn a loop that computes a predicate into a named predicate function.
Prefer a `switch` to an `if` chain when you test one value.
Write a `default` case for the common case only, not to silence a
warning.
Keep `break` and `continue` rare inside a loop.
Write a loop termination condition that holds for every input.

### Types

Base: Types.

Make an interface explicit. Do not hide a dependency in a global.
Prefer a concrete type to a class hierarchy.
Make a concrete value type regular: copy, compare, and assign like an
`int`.
Prefer a named struct to a pair or a tuple when the fields have
meanings.
Use `size_t` for a value that holds the size of an object.
Use `auto` only when the type name already appears on the same line.
Write `auto&` when you mean a reference.
Risk: if you write `auto` for a container element, then it copies the
element without a visible call.
Prefer a stack array type to a raw C array.
Avoid an implicit conversion operator.

### Data objects

Base: Data objects.

Declare an object `const` or `constexpr` by default.

Do not make a data member `const` or a reference in a copyable type.
Reason: a `const` member leaves the type copy-constructible but not
copy-assignable, so every standard container rejects it.
Write the immutable form as a private member plus a const accessor, or
as a `const` object at the point of use.

Use `class` when an invariant exists. Use `struct` when the fields vary
freely.
Avoid a trivial getter and setter on a type with no invariant. Make the
member public instead.
Define a constructor when the class holds an invariant, and make it
produce a fully initialized object.
Do not use two-phase initialization with a separate `Init()` call.
Avoid work in a constructor that can fail with no way to report it.
A copy operation must not change the source object.

### State

Base: State.

Keep a scope small. Declare a name where you first have a value.
Avoid a global object with a complex constructor.
Forbid a static object whose destructor does work.

### Inheritance

Base: Inheritance.

Make a base class that acts as an interface a pure abstract class.
Do not make a function virtual without a reason you can name.
Access a polymorphic object through a pointer or a reference.
Prefer a virtual function to a cast down the class hierarchy.
Prefer a virtual `clone` to public copying for a polymorphic class.
Use multiple inheritance only to combine distinct interfaces.
Make a function a member only when it needs the class representation.
Define a non-member function for a symmetric operator.
Overload an operator only for its conventional meaning.

### Module boundaries

Base: Module boundaries.

Keep an internal header private to its library.
Let libraries form a layered order with no cycle.
Use a namespace to express logical structure, not to shorten a name.
Include the header you need. Do not write a forward declaration instead.
Separate stable code from code that still changes.
Prefer an inline or a static function to a function-like macro.
Do not use a macro to define part of a public interface.

### Concurrency

These rules have no base rule.

Write a program as if it already runs in many threads.
Share as little writable data between threads as the design allows.
Define a mutex next to the data it guards.
Take and release a lock with an RAII guard, never by hand.
Take and release a lock in the same module, at the same level of
abstraction.
Never call unknown code, such as a callback, while you hold a lock.
Do not block while you hold a lock.
Take several mutexes in one scoped lock, never one after another.
Think in tasks, not in threads.
Do not use `volatile` to synchronize threads.
Do not detach a thread. Join it in a scope.
Do not write lock-free code unless you can name why a lock fails.
Do not write your own double-checked locking.

### Templates

These rules have no base rule. They apply to C++ alone.

Use a template to raise the level of abstraction, not to save typing.
Constrain every template parameter with a concept.
Ask a template for only the properties it really uses.
Avoid template metaprogramming unless you can name the problem it
solves.
Avoid type erasure where a concrete type works.
Do not turn a class hierarchy into a template without a reason.
Keep a template's context dependencies few.
Do not specialize a function template. Write an overload instead.
Do not write code inside a template that only one type can use.

### C only

C has no destructor, so several rules above change form.

Use a `goto` chain to release resources on an error exit.
Reason: C has no scope-exit object, so the chain is the only form that
does not repeat the cleanup on every error path.
Risk: if you write this chain in C++, then it replaces a destructor that
already does the job.
Allocate and free memory in one module, at one level of abstraction.
Store a new value in a pointer right after you free it.
Write one pointer validation function and call it everywhere.
Pass the buffer size next to every array parameter.
Hide a struct's representation behind an opaque type.
Declare a pointer parameter const when the function does not write
through it.
Point at a string literal with a pointer to const.
Adopt one plan for managing strings across the whole program.
Return an empty array rather than a null pointer.
Detect and handle an error that a standard library function reports.
Do not call a deprecated or an obsolescent library function.

### Linting

Run these three commands. They enforce the mechanics this file does not
repeat, and `readability-function-cognitive-complexity` enforces the
whole Complexity section of the base file.

    clang-format -i --style=file <files>
    clang-tidy --checks='-*,bugprone-*,cppcoreguidelines-*,misc-*,
      modernize-*,performance-*,readability-*,cert-*' <files>
    cc -std=c2x -Wall -Wextra -Wshadow -Wconversion \
      -fsanitize=address,undefined <files>

Risk: if a rule repeats what a linter already blocks, then it costs a
line and changes nothing.
