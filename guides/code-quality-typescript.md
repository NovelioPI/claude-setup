## Code Quality, TypeScript and JavaScript

The TypeScript and JavaScript form of the rules in `rules/code-quality.md`.
Each section names its base section. The base rule and its risk stay there.

### Comments and docstrings

Base: Comments and docstrings.

Write JSDoc for a reader of the API. Write `//` for a note about the
implementation.
Do not give every top-level export a JSDoc comment. The base default
holds: write one line only when the signature does not say what it does.
Reason: the Google guide targets a shared repository with generated API
docs, not a reader of the source.
Name a non-obvious call-site argument in a short comment, or take a
named parameter instead.

### Types

Base: Types.

Take an untyped external value as `unknown`, then narrow it before use.
Do not write a type assertion or a `!` without a stated reason. Write a
runtime check instead.
Let inference type a local value. Annotate a value that states a
contract.
Declare an object shape with an `interface`, not with a type alias.
Reason: an `interface` here is a named shape, not an injected
abstraction, so the base two-implementation rule does not apply.
Keep `| null` and `| undefined` out of a type alias. Add them where the
alias is used.
Declare an optional field or parameter instead of a `| undefined` union.
Choose the simplest type construct. Repetition costs less than a
conditional type.
Turn a set of shapes into a discriminated union, not one interface with
optional fields.
Write a type predicate to name a narrowing test you repeat.
Use `satisfies` to check an object literal and keep its literal types.
Build a fixed set of values with `as const`, not with an enum.
Combine interfaces with `extends`.
Risk: if you intersect two interfaces, then a clashing property becomes
`never` with no error at the declaration.
Pass an object literal straight into the parameter.
Risk: if the literal goes through a variable first, then the excess
property check does not run.
Do not expect `implements` to type a method parameter. Annotate the
parameter yourself.
Give a callback whose result you ignore the return type `void`, not
`any`.

### Functions

Base: Functions.

Sort overloads from the most specific signature to the most general.
Replace overloads that differ only in trailing parameters with optional
parameters.
Replace overloads that differ in one argument type with a union
parameter.
Do not pass a named function as a callback unless you control both
signatures.
Keep a parameter initializer free of an observable side effect.

### State

Base: State.

Do not rebind `this`. Pass an explicit parameter or use an arrow
function.
Do not read `this` in a static member.
Do not initialize a class property to an arrow function, unless a
detached handler needs `this`.
Use an arrow property for an event handler you must uninstall, not
`bind` inside the listener call.
Risk: if you bind at the call site, then `removeEventListener` receives
a different function and the handler stays.

### Errors

Base: Errors.

Keep the `try` block to the smallest code that can throw.
Throw an `Error` subclass. Do not throw a string or a plain object.
Narrow a caught value before you use it. Do not assume it is an `Error`.
Write a comment that says why an empty catch block does nothing.

### Data objects

Base: Data objects.

Do not treat `readonly` as a runtime guarantee.
Risk: if another alias holds the same object, then it can still change
the value.
Give an index signature key a meaningful label, such as
`[userId: string]`.
Mark an index signature `readonly` when callers only read the value.
Copy an array before you sort or reverse it, or call `toSorted` and
`toReversed`.
Pass a comparison function to `sort`, because the default compares
UTF-16 strings.
Do not define a non-numeric property on an array. Use a `Map` or an
object.
Set a field from a constructor parameter with a parameter property.
Initialize a field where you declare it, and drop the constructor when
it becomes empty.

### Module boundaries

Base: Module boundaries.

Prefer a module-level function to a private static method.
Do not create a class of static members for namespacing. Export
functions and constants.
Use `#name` when you need privacy at run time.
Risk: if you mark a field `private`, then the mark erases and bracket
access still reads the field.
Use a named import for a frequent symbol, and a namespace import for a
large API.
Use a relative import inside one logical project.

### Inheritance

Base: Inheritance.

Model variants with a discriminated union and one exhaustive switch, not
with one subclass for each variant.
Call a static method on the class that defines it, never on a subclass.
Do not change a prototype at run time, and do not build a mixin.

### Promises

These rules have no base rule.

Keep a promise chain flat. Do not nest a chain inside a `then` callback.
Do not wrap an API that already returns a promise in `new Promise`.
Start independent async work together with `Promise.all`, not one
`await` after another.
End a promise chain with `catch`, or wrap the `await` calls in `try`.

### JavaScript only

These rules apply when no type checker runs.

Test for `null` with an explicit comparison.
Risk: if you use a truthiness test, then it also rejects `0` and `""`.
Add a null check beside a `typeof` object test, because `typeof null`
returns `"object"`.
Default with `??`, not with `||`, when `0` or `""` is a valid value.
Do not create a function inside a function when no closure is needed.
Declare a loop variable with `let`, so each closure captures its own
value.
Bind a method or wrap it in an arrow function before you pass it as a
callback.

### Linting

Run `npx tsc --noEmit`, `npx eslint .`, and `npx prettier --check .`.
Set `"strict": true` in `tsconfig.json`.
Set `parserOptions.projectService: true`, then extend
`tseslint.configs.recommendedTypeChecked`.
Risk: if a rule repeats what a linter already blocks, then it costs a
line and changes nothing.
