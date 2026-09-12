# Research: TypeScript and JavaScript code quality

This file lists the judgment rules a linter cannot decide, for a future `rules/code-quality-typescript.md`.

| Column | Meaning |
|---|---|
| Rule | One imperative sentence, in the voice of `rules/code-quality.md` |
| From | The base section in `rules/code-quality.md`, or `standalone` |
| Status | `covered`, `gap`, or `conflicts`, measured against the base file |
| JS only | `yes` when the rule applies to plain JavaScript alone |
| Source | The URL that states the rule |

## Rules

| Rule | From | Status | JS only | Source |
|---|---|---|---|---|
| Take an untyped external value as `unknown`, then narrow it before you use it. | Types | covered | no | https://google.github.io/styleguide/tsguide.html |
| Do not write a type assertion or a `!` without a stated reason. Write a runtime check. | Types | gap | no | https://google.github.io/styleguide/tsguide.html |
| Keep `\|null` and `\|undefined` out of a type alias. Add them where the alias is used. | Types | gap | no | https://google.github.io/styleguide/tsguide.html |
| Declare an optional field or parameter instead of a `\|undefined` union. | Types | gap | no | https://google.github.io/styleguide/tsguide.html |
| Choose the simplest type construct. Repetition costs less than a complex conditional type. | Types | gap | no | https://google.github.io/styleguide/tsguide.html |
| Annotate a symbol at its declaration when its shape must match an interface. | Types | gap | no | https://google.github.io/styleguide/tsguide.html |
| Let inference type a local value. Annotate a value that states a contract. | standalone | gap | no | https://www.typescriptlang.org/docs/handbook/2/everyday-types.html |
| Turn a set of shapes into a discriminated union instead of one interface with optional fields. | Types | gap | no | https://www.typescriptlang.org/docs/handbook/2/narrowing.html |
| Write a type predicate to name a narrowing test you repeat. | Types | gap | no | https://www.typescriptlang.org/docs/handbook/2/narrowing.html |
| Use `satisfies` to check an object literal against a type and keep its literal types. | Types | gap | no | https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-9.html |
| Build a fixed set of values as an object with `as const` instead of an enum. | Types | gap | no | https://www.typescriptlang.org/docs/handbook/enums.html |
| Sort overloads from the most specific signature to the most general. | Functions | gap | no | https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html |
| Replace overloads that differ only in trailing parameters with optional parameters. | Functions | gap | no | https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html |
| Replace overloads that differ in one argument type with a union parameter. | Functions | gap | no | https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html |
| Declare a callback parameter as non-optional, because a caller may accept fewer arguments. | Types | gap | no | https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html |
| Give a callback whose result you ignore the return type `void`, not `any`. | Types | gap | no | https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html |
| Do not treat `readonly` as a runtime guarantee. Another alias can still change the value. | Data objects | gap | no | https://www.typescriptlang.org/docs/handbook/2/objects.html |
| Expect a mutable tuple parameter to reject an `as const` array, because it infers a readonly tuple. | Types | gap | no | https://www.typescriptlang.org/docs/handbook/2/objects.html |
| Give an index signature key a meaningful label. | standalone | gap | no | https://google.github.io/styleguide/tsguide.html |
| Mark an index signature `readonly` when callers only read the value. | Data objects | gap | no | https://www.typescriptlang.org/docs/handbook/2/objects.html |
| Combine interfaces with `extends`, because an intersection turns a clashing property into `never`. | Types | gap | no | https://www.typescriptlang.org/docs/handbook/2/objects.html |
| Pass an object literal straight into the parameter, so the excess property check runs. | Types | gap | no | https://www.typescriptlang.org/docs/handbook/2/objects.html |
| Do not expect `implements` to type a method parameter. Annotate the parameter yourself. | Types | gap | no | https://www.typescriptlang.org/docs/handbook/2/classes.html |
| Prefer a module-level function to a private static method. | Module boundaries | gap | no | https://google.github.io/styleguide/tsguide.html |
| Do not read `this` in a static member. | State | gap | no | https://google.github.io/styleguide/tsguide.html |
| Call a static method on the class that defines it, never on a subclass. | Inheritance | gap | no | https://google.github.io/styleguide/tsguide.html |
| Keep a getter pure. It must not change observable state. | Functions | covered | no | https://google.github.io/styleguide/tsguide.html |
| Set a field from a constructor parameter with a parameter property. | standalone | gap | no | https://google.github.io/styleguide/tsguide.html |
| Initialize a field where you declare it, and drop the constructor when it becomes empty. | standalone | gap | no | https://google.github.io/styleguide/tsguide.html |
| Do not initialize a class property to an arrow function unless a detached handler needs `this`. | standalone | gap | no | https://google.github.io/styleguide/tsguide.html |
| Use `#name` when you need privacy at runtime, because `private` erases and bracket access works. | Module boundaries | gap | no | https://www.typescriptlang.org/docs/handbook/2/classes.html |
| Do not change a prototype at runtime, and do not build a mixin. | Inheritance | gap | no | https://google.github.io/styleguide/tsguide.html |
| Do not pass a named function as a callback unless you control both signatures. | Functions | gap | no | https://google.github.io/styleguide/tsguide.html |
| Keep a parameter initializer free of an observable side effect. | Functions | gap | no | https://google.github.io/styleguide/tsguide.html |
| Do not rebind `this`. Pass an explicit parameter or use an arrow function. | State | gap | no | https://google.github.io/styleguide/tsguide.html |
| Use an arrow property for an event handler you must uninstall, not `bind` in the listener. | standalone | gap | no | https://google.github.io/styleguide/tsguide.html |
| Keep the `try` block to the smallest code that can throw. | Errors | gap | no | https://google.github.io/styleguide/tsguide.html |
| Write a comment that says why an empty catch block does nothing. | Errors | gap | no | https://google.github.io/styleguide/tsguide.html |
| Narrow a caught value before you use it, and assume it is an `Error`. | Errors | gap | no | https://google.github.io/styleguide/tsguide.html |
| Throw an `Error` subclass, never a string or a plain object. | Errors | gap | no | https://google.github.io/styleguide/tsguide.html |
| Keep a promise chain flat. Do not nest a chain inside a `then` callback. | State | conflicts | no | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises |
| Do not wrap an API that already returns a promise in `new Promise`. | Unused code | gap | no | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises |
| Start independent async work together with `Promise.all`, not one `await` after another. | standalone | gap | no | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises |
| End a promise chain with `catch`, or wrap the `await` calls in `try`. | Errors | gap | no | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises |
| Test for `null` with an explicit comparison, because a truthiness test also rejects `0` and `""`. | standalone | gap | yes | https://www.typescriptlang.org/docs/handbook/2/narrowing.html |
| Add a null check beside a `typeof` object test, because `typeof null` returns `"object"`. | standalone | gap | yes | https://www.typescriptlang.org/docs/handbook/2/narrowing.html |
| Default with `??`, not `\|\|`, when `0` or `""` is a valid value. | standalone | gap | yes | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Nullish_coalescing |
| Do not create a function inside a function when no closure is needed. Use the prototype. | standalone | gap | yes | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Closures |
| Declare a loop variable with `let`, so each closure captures its own value. | State | gap | yes | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Closures |
| Bind a method or wrap it in an arrow function before you pass it as a callback. | State | gap | yes | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/this |
| Copy an array before you sort or reverse it, or call `toSorted` and `toReversed`. | Data objects | gap | no | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort |
| Pass a comparison function to `sort`, because the default compares UTF-16 strings. | standalone | gap | no | https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort |
| Do not define a non-numeric property on an array. Use a `Map` or an object. | Data objects | gap | no | https://google.github.io/styleguide/tsguide.html |
| Export only the symbols another module uses. | Module boundaries | covered | no | https://google.github.io/styleguide/tsguide.html |
| Do not create a class of static members for namespacing. Export functions and constants. | Module boundaries | gap | no | https://google.github.io/styleguide/tsguide.html |
| Use named imports for frequent symbols, and a namespace import for a large API. | standalone | gap | no | https://google.github.io/styleguide/tsguide.html |
| Use a relative import inside one logical project. | standalone | gap | no | https://google.github.io/styleguide/tsguide.html |
| Write JSDoc for a reader of the API, and `//` for a note about the implementation. | Comments and docstrings | gap | no | https://google.github.io/styleguide/tsguide.html |
| Give every top-level export a JSDoc comment that summarizes the symbol. | Comments and docstrings | conflicts | no | https://google.github.io/styleguide/tsguide.html |
| Omit a comment that repeats type information the signature already carries. | Comments and docstrings | covered | no | https://google.github.io/styleguide/tsguide.html |
| Name a non-obvious argument at the call site with a comment, or take a named parameter. | Comments and docstrings | gap | no | https://google.github.io/styleguide/tsguide.html |
| Do not abbreviate by deleting letters. Use a short name only in a scope of ten lines. | standalone | gap | no | https://google.github.io/styleguide/tsguide.html |
| Declare an object shape with an `interface`, not with a type alias for an object literal. | Types | conflicts | no | https://google.github.io/styleguide/tsguide.html |
| Model variants with a discriminated union and a switch, not one subclass for each variant. | Inheritance | conflicts | no | https://www.typescriptlang.org/docs/handbook/2/narrowing.html |

## Conflicts

Four rows contradict a rule the base file already states.

**Keep a promise chain flat.** The base `State` section says: do not chain more than two calls to reach a
value. MDN shows a flat chain of four or more `then` calls as the correct shape. The two rules target
different things. The base rule stops you from reaching through an object graph. The MDN rule stops you
from nesting a chain inside a callback. A TypeScript file needs the base rule to name the object case only.

**Give every top-level export a JSDoc comment.** The base `Comments and docstrings` section sets the
default to no comment and no docstring. Google demands a JSDoc summary on every top-level export. This is
a direct contradiction. Google writes for a shared monorepo with generated API documentation. The base
file writes for a reader of the source. Pick one, and say which in the TypeScript file.

**Declare an object shape with an `interface`.** The base `Types` section says: depend on an interface only
when two implementations exist. In TypeScript an `interface` is a structural shape, not an implementation
contract. Google asks for `interface` over a type alias for every object literal type. The base rule was
written for the nominal sense of the word. The TypeScript file must separate the two senses.

**Model variants with a discriminated union.** The base `Inheritance` section says: replace a type
conditional with one subclass for each type, when the same switch appears in three or more places. The
TypeScript handbook answers the same problem with a discriminated union plus an exhaustive switch. The
compiler then proves that every case is handled. One switch on a `kind` field costs less than a class
hierarchy.

## Linting

A rule that a tool decides mechanically does not belong in the rule file. These tools replace the rules
listed beside them.

| Tool | Command | Rules it replaces |
|---|---|---|
| `tsc` | `npx tsc --noEmit` | Implicit `any`, null and undefined checks, unchecked index access, missing `override`, switch fallthrough, unused locals, catch variables typed as `unknown` |
| typescript-eslint | `npx eslint .` | `no-explicit-any`, `no-non-null-assertion`, `no-floating-promises`, `no-misused-promises`, `no-unnecessary-condition`, `prefer-readonly`, `strict-boolean-expressions`, `switch-exhaustiveness-check`, `require-await`, `return-await`, `unbound-method`, `no-base-to-string`, `prefer-nullish-coalescing`, `prefer-optional-chain`, `consistent-type-imports`, `consistent-type-definitions`, `no-shadow`, the `no-unsafe-*` family |
| ESLint core | `npx eslint .` | `eqeqeq`, `no-var`, `prefer-const`, `no-eval`, `no-with`, `no-debugger`, `no-extend-native`, `no-new-wrappers`, `no-array-constructor`, `no-object-constructor`, `no-cond-assign`, `no-param-reassign`, `func-style`, `prefer-arrow-callback`, `prefer-rest-params`, `prefer-spread`, `new-parens`, `default-case`, `no-fallthrough`, naming conventions |
| Prettier | `npx prettier --check .` | Quote style, semicolons, indentation, line width, trailing commas, brace placement |

Turn on `"strict": true` in `tsconfig.json`. It enables `noImplicitAny`, `strictNullChecks`,
`strictFunctionTypes`, `strictBindCallApply`, `strictPropertyInitialization`, `noImplicitThis`,
`useUnknownInCatchVariables`, and `alwaysStrict`.
Source: https://www.typescriptlang.org/tsconfig/

Use the type-aware ESLint presets. Set `parserOptions.projectService: true`, then extend
`tseslint.configs.recommendedTypeChecked`. `strictTypeChecked` adds stricter type-aware rules, and
`stylisticTypeChecked` adds stylistic ones.
Source: https://typescript-eslint.io/getting-started/typed-linting/

Six rows carry a `JS only` mark. Three of them exist because the matching lint rule needs type
information. In plain JavaScript `strict-boolean-expressions` and `prefer-nullish-coalescing` cannot run,
so a human must apply them.
Source: https://typescript-eslint.io/rules/

## Notes on sources

No fetched URL returned a 404. Every row above traces to a page I fetched in this session.

Sources that disagree with each other:

| Question | Google | TypeScript handbook or MDN |
|---|---|---|
| Private class fields | Do not use `#ident`, because down-level emit grows and slows | `private` is erased and reachable by bracket notation; `#name` gives hard privacy |
| Interface or type alias | Use `interface` for every object literal type | Choose by preference; use `interface` until you need a `type` feature |
| Enums | Do not use `const enum`; a plain `enum` is fine | An object with `as const` may remove the need for an enum |

The `#private` disagreement rests on a build target. Google names emit size and performance when the code
is down-leveled to an older JavaScript version. The research could not confirm whether that cost still
applies to a modern target. Treat the Google ban as conditional.

refactoring.guru holds no TypeScript-specific material. Its TypeScript page is a generic pattern catalog
with TypeScript code samples. The page itself makes no claim about the language.
Source: https://refactoring.guru/design-patterns/typescript

The Airbnb style guide lives in one very large README. The fetch returned a partial list of rules. Those rules
duplicate ESLint core rules or Google rules already cited. No row cites it.
Source: https://github.com/airbnb/javascript

The MDN `Promise` reference page carries no advice about chain shape or floating promises. The `Using
promises` guide carries all of it. Cite the guide, not the reference.
Source: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise

MDN states that strict equality is almost always the correct comparison. `eqeqeq` decides this, so no row
states it.
Source: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Equality_comparisons_and_sameness

## Counts

| Count | Value |
|---|---|
| Total rows | 64 |
| gap | 56 |
| covered | 4 |
| conflicts | 4 |
| JS only | 6 |

## Decision

Written to `rules/code-quality-typescript.md` on 2026-09-12, 168 lines.

Every row above became a rule, except the seven below.

| Row | Outcome | Reason |
|---|---|---|
| Give every top-level export a JSDoc comment | rejected | The base default wins. `rules/code-quality.md` now records the exception. |
| Export only the symbols another module uses | dropped | The base `Module boundaries` section states it, and the statement is language-neutral. |
| Keep a getter pure | dropped | The base `Functions` section states it: a function returns a value or changes state, never both. |
| Omit a comment that repeats type information | dropped | The base `Comments and docstrings` section states it. |
| Annotate a symbol at its declaration when its shape must match an interface | merged | The `satisfies` rule and the inference rule cover the same case. |
| Expect a mutable tuple parameter to reject an `as const` array | dropped | `tsc` reports it, so it fails the judgment bar. |
| Declare a callback parameter as non-optional | dropped | The rule applies to authoring a declaration file, which is outside this rule set. |

The three remaining `conflicts` rows entered the rules file, because the
base file changed first on the same day.

| Row | Base change |
|---|---|
| Keep a promise chain flat | The chain limit now names an object graph only. |
| Declare an object shape with an `interface` | "interface" became "injected abstraction". |
| Model variants with a discriminated union | The base now prefers a tagged union with an exhaustive switch. |
