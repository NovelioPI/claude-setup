# Code Smells vs `rules/code-quality.md`

| Smell | Test | Status | Where | Source |
| --- | --- | --- | --- | --- |
| Long Method | Method runs past ~10 lines, or needs an inner comment. | `conflicts` | Functions | https://refactoring.com/catalog/extractFunction.html |
| Large Class | Class holds many fields and methods and will not fit in your head. | `covered` | File and folder size | https://martinfowler.com/articles/class-too-large.html |
| Primitive Obsession | Code uses a string, number, or magic constant where a named type fits. | `covered` | Types; Constants | https://refactoring.com/catalog/replacePrimitiveWithObject.html |
| Long Parameter List | Function takes more than three or four parameters. | `gap` | | https://refactoring.com/catalog/introduceParameterObject.html |
| Data Clumps | The same few values appear together in many signatures. | `gap` | | https://martinfowler.com/bliki/DataClump.html |
| Alternative Classes with Different Interfaces | Two classes do the same job under different method names. | `gap` | | https://refactoring.com/catalog/changeFunctionDeclaration.html |
| Refused Bequest | Subclass ignores inherited members, or overrides them to fail. | `gap` | | https://refactoring.com/catalog/replaceSuperclassWithDelegate.html |
| Switch Statements | The same switch on one type code repeats in several places. | `gap` | | https://refactoring.com/catalog/replaceConditionalWithPolymorphism.html |
| Temporary Field | A field holds a value during one operation and stays empty otherwise. | `gap` | | https://refactoring.com/catalog/extractClass.html |
| Divergent Change | One module changes for several unrelated reasons. | `covered` | File and folder size | https://refactoring.com/catalog/extractClass.html |
| Parallel Inheritance Hierarchies | Every new subclass here forces a new subclass there. | `gap` | | https://refactoring.guru/smells/parallel-inheritance-hierarchies |
| Shotgun Surgery | One change forces small edits across many files. | `covered` | File and folder size | https://refactoring.com/catalog/moveFunction.html |
| Comments | A comment restates what the code does. | `covered` | Comments and docstrings | https://refactoring.com/catalog/extractFunction.html |
| Duplicate Code | Two fragments read almost the same. | `covered` | Functions | https://refactoring.com/catalog/extractFunction.html |
| Data Class | A class holds fields and accessors and no behavior. | `conflicts` | Data objects | https://refactoring.com/catalog/encapsulateRecord.html |
| Dead Code | No caller reaches the variable, function, or class. | `gap` | | https://refactoring.com/catalog/removeDeadCode.html |
| Lazy Class | A class does too little to pay for its own file. | `covered` | Functions; File and folder size | https://refactoring.com/catalog/inlineClass.html |
| Speculative Generality | An abstraction, hook, or parameter has no current user. | `covered` | Code Quality (priority line) | https://martinfowler.com/bliki/Yagni.html |
| Feature Envy | A function reads another object's data more than its own. | `gap` | | https://refactoring.com/catalog/moveFunction.html |
| Inappropriate Intimacy | Two classes reach into each other's private fields. | `gap` | | https://refactoring.com/catalog/hideDelegate.html |
| Incomplete Library Class | A library class lacks a method you need, and you cannot edit it. | `gap` | | https://refactoring.guru/smells/incomplete-library-class |
| Message Chains | Code walks a chain such as `a.b().c().d()` to reach a value. | `gap` | | https://refactoring.com/catalog/hideDelegate.html |
| Middle Man | Most methods of a class only forward the call. | `covered` | Functions | https://refactoring.com/catalog/removeMiddleMan.html |

## Gaps and proposed rules

- **Long Parameter List** — Cap a function at four parameters. Group values that always travel together into one object.
- **Data Clumps** — When the same three values pass together twice, give them one type.
- **Alternative Classes with Different Interfaces** — Give two types that do the same job the same method names, or delete one.
- **Refused Bequest** — Do not inherit when the child ignores part of the parent. Hold a field instead.
- **Switch Statements** — Do not repeat a branch on the same type code in more than two places.
- **Temporary Field** — Do not add a field that only one operation uses. Pass the value as a parameter.
- **Parallel Inheritance Hierarchies** — Do not add a subclass here that forces a subclass there. Hold a reference instead.
- **Dead Code** — Delete code that no caller reaches. Version control keeps the old copy.
- **Feature Envy** — Put a function next to the data it reads most.
- **Inappropriate Intimacy** — Do not read another module's private names. Ask that module for the value.
- **Incomplete Library Class** — Wrap a missing library method in one named function. Do not patch the library at run time.
- **Message Chains** — Do not chain more than two calls to reach a value. Ask the first object.

## Verification notes

- Fowler's bliki holds only three pages that name a smell: `CodeSmell`, `DataClump`, and `Yagni`. Every other bliki smell page does not exist.
- The `refactoring.com/catalog/` pages carry a name, a diagram, and a code sketch. They confirm the treatment and its name. They carry no prose test for the smell.
- `refactoring.guru` tracks *Refactoring* 1st edition. The 2nd edition list of 24 smells, confirmed in the publisher's excerpt of chapter 3 (https://www.informit.com/articles/article.aspx?p=2952392), renames four rows above and drops three:
  - Long Method → Long Function; Switch Statements → Repeated Switches; Lazy Class → Lazy Element; Inappropriate Intimacy → Insider Trading; Duplicate Code → Duplicated Code.
  - Dropped: Parallel Inheritance Hierarchies, Incomplete Library Class, Dead Code.
- The same source adds four smells that `refactoring.guru` never lists: Mysterious Name, Global Data, Mutable Data, Loops. They are outside the requested table.

### Notes on the two `conflicts` rows

- **Long Method.** The smell uses line count and inner comments as the trigger, and treats a block with Extract Method. `code-quality.md` says line count is not the trigger, bans a function extracted for length, and bans a single-use helper.
- **Data Class.** The smell says a field-only class should absorb behavior. `code-quality.md` says a value object should stay an immutable data holder.
- One partial tension, not scored: the **Comments** smell prescribes Extract Method for a commented block. `code-quality.md` agrees with the rule (prefer a good name) but bans that treatment when the block has one caller.
