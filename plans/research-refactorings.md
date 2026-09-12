# Research: refactoring techniques and design principles

## Rules that `rules/code-quality.md` lacks

| Rule | From | Status | Source |
| --- | --- | --- | --- |
| Return early with a guard clause instead of nesting conditions. | Replace Nested Conditional with Guard Clauses | gap | https://refactoring.com/catalog/replaceNestedConditionalWithGuardClauses.html |
| A function returns a value or changes state, never both. | Separate Query from Modifier | gap | https://martinfowler.com/bliki/CommandQuerySeparation.html |
| Do not pass a boolean that picks behavior. Write two functions. | Remove Flag Argument | gap | https://martinfowler.com/bliki/FlagArgument.html |
| Do not assign to a parameter. Copy it into a local variable. | Remove Assignments to Parameters | gap | https://refactoring.guru/remove-assignments-to-parameters |
| Give each variable one purpose. Do not reuse it. | Split Variable | gap | https://refactoring.com/catalog/splitVariable.html |
| Group parameters that always travel together into one object. | Introduce Parameter Object | gap | https://refactoring.com/catalog/introduceParameterObject.html |
| Pass the whole object when the callee reads several of its fields. | Preserve Whole Object | gap | https://refactoring.com/catalog/preserveWholeObject.html |
| Return a read-only view of a collection. Expose add and remove. | Encapsulate Collection | gap | https://refactoring.com/catalog/encapsulateCollection.html |
| Do not add a setter for a field that never changes after construction. | Remove Setting Method | gap | https://refactoring.guru/remove-setting-method |
| Keep a function private unless a caller outside the module needs it. | Hide Method | gap | https://refactoring.guru/hide-method |
| Report a failure with an exception, not with a returned error code. | Replace Error Code with Exception | gap | https://refactoring.com/catalog/replaceErrorCodeWithException.html |
| Check a cheap precondition before the call instead of catching an exception. | Replace Exception with Precheck | gap | https://refactoring.com/catalog/replaceExceptionWithPrecheck.html |
| Delete unused code. Do not comment it out. | Remove Dead Code | gap | https://refactoring.com/catalog/removeDeadCode.html |
| Do not add a class, parameter, or hook for a future need. | Speculative Generality, YAGNI | gap | https://martinfowler.com/bliki/Yagni.html |
| Put a function in the module that owns the data it uses most. | Feature Envy, Move Function | gap | https://refactoring.com/catalog/moveFunction.html |
| Merge conditions that produce the same result into one condition. | Consolidate Conditional Expression | gap | https://refactoring.com/catalog/consolidateConditionalExpression.html |
| Do not reach through a chain of objects to get a value. | Message Chains | gap | https://refactoring.guru/smells/message-chains |
| Prefer composition and delegation over inheritance. | Favor Composition Over Inheritance | gap | https://refactoring.com/catalog/replaceSuperclassWithDelegate.html |
| Do not inherit when the child ignores part of the parent contract. | Refused Bequest, LSP | gap | https://refactoring.guru/smells/refused-bequest |
| Rename a function as soon as its name stops matching its job. | Change Function Declaration | gap | https://refactoring.com/catalog/changeFunctionDeclaration.html |
| Wrap a primitive in a type when the value carries rules. | Replace Primitive with Object | gap | https://refactoring.com/catalog/replacePrimitiveWithObject.html |
| Delete a class or function that only forwards calls. | Remove Middle Man | gap | https://refactoring.com/catalog/removeMiddleMan.html |
| Do not spread one likely change across many modules. | Shotgun Surgery | gap | https://refactoring.guru/smells/shotgun-surgery |
| Delete a field that holds a value only part of the time. | Temporary Field | gap | https://refactoring.guru/smells/temporary-field |
| Write the plain solution first. Add a pattern only for a real problem. | Criticism of Patterns | gap | https://refactoring.guru/design-patterns/criticism |
| Split a function that first computes data and then formats it. | Split Phase | gap | https://refactoring.com/catalog/splitPhase.html |
| Extract any fragment you must study to understand into a named function. | Extract Function, Function Length | conflicts | https://martinfowler.com/bliki/FunctionLength.html |
| Replace a temporary variable with a function that computes it. | Replace Temp with Query | conflicts | https://refactoring.com/catalog/replaceTempWithQuery.html |
| Extract the condition and each branch into named functions. | Decompose Conditional | conflicts | https://refactoring.guru/decompose-conditional |
| Split a class as soon as it holds two responsibilities. | Extract Class, SRP | conflicts | https://refactoring.com/catalog/extractClass.html |
| Replace a type-based conditional with one subclass per type. | Replace Conditional with Polymorphism | conflicts | https://refactoring.com/catalog/replaceConditionalWithPolymorphism.html |
| Depend on an interface, not on a concrete class. | Program to an Interface, DIP | conflicts | https://blog.cleancoder.com/uncle-bob/2020/10/18/Solid-Relevance.html |
| Add an extension point so new behavior needs no edit to old code. | Open/Closed Principle | conflicts | https://blog.cleancoder.com/uncle-bob/2014/05/12/TheOpenClosedPrinciple.html |
| Read and write a field through an accessor inside its own class. | Encapsulate Variable | conflicts | https://refactoring.com/catalog/encapsulateVariable.html |
| Add forwarding methods so a client calls only its direct neighbour. | Hide Delegate | conflicts | https://refactoring.com/catalog/hideDelegate.html |
| Split one wide interface into narrow ones, one per client. | Interface Segregation Principle | conflicts | https://blog.cleancoder.com/uncle-bob/2020/10/18/Solid-Relevance.html |
| Move the parts you expect to vary into separate modules now. | Encapsulate What Varies | conflicts | https://refactoring.guru/files/design-patterns-en-demo.pdf |

## SOLID

| Principle | Plain meaning | Status | Cognitive debt |
| --- | --- | --- | --- |
| Single Responsibility | Keep code that changes for one reason in one module. | conflicts | Raises: more files and more hops. |
| Open/Closed | Allow new behavior by adding code, not by editing old code. | conflicts | Raises: extension points exist before any caller needs them. |
| Liskov Substitution | Any implementation must work wherever the interface is expected. | gap | Lowers: the reader trusts one contract. |
| Interface Segregation | Keep an interface small so a client depends on nothing extra. | conflicts | Raises: more types to track. |
| Dependency Inversion | Point dependencies at abstractions, not at concrete details. | conflicts | Raises: the reader cannot see the real callee. |

## Notes on sources

`https://refactoring.guru/design-principles` returns HTTP 404. Refactoring Guru keeps
the design principles and SOLID chapters in its paid book. The free demo PDF at
`https://refactoring.guru/files/design-patterns-en-demo.pdf` carries Features of Good
Design and Encapsulate What Varies, and stops before the SOLID chapter.

SOLID rows cite Robert Martin, who wrote the principles. Martin Fowler has no
bliki entry that states SOLID.

Fowler supports the existing priority on cognitive debt in two places. Kent Beck's
fourth rule tells you to remove elements that serve no other rule
(`https://martinfowler.com/bliki/BeckDesignRules.html`). YAGNI names four costs of
building for a future need (`https://martinfowler.com/bliki/Yagni.html`).

Fowler treats a smell as a signal to inspect, not a rule to obey
(`https://martinfowler.com/bliki/CodeSmell.html`). He says some long methods are fine.

The Extract Function conflict is the sharpest one. Fowler extracts a fragment
whenever he must work out what it does, and accepts one-line functions. The current
rule forbids that when the function has one caller.

Hide Delegate and Remove Middle Man contradict each other. Refactoring Guru says so
on the Message Chains page. Pick one per case, not one as a standing rule.
