# Tier C comparison

This file compares the 15 rejected refactoring rules against the rules now in
`rules/code-quality.md`, and gives a verdict for each.

`code-quality.md` states one priority: minimize cognitive debt over
completeness, cleverness, or flexibility. Cognitive debt is the mental effort a
reader needs to hold code in mind. Every verdict below follows from that
priority.

## Verdicts

| # | Proposed rule | Your rule | Section | Real disagreement | Verdict |
|---|---|---|---|---|---|
| 1 | Extract any fragment you must study | Do not extract a single-use function | Functions | Who pays: the writer names the step, or the reader jumps to it | accept narrowed |
| 2 | Replace a temp variable with a function | Inline a single-use helper | Functions | A query recomputes; a temp holds one value | reject |
| 3 | Extract the condition and each branch | Return early with a guard clause | Functions | Both cut nesting; only one adds a hop | already covered |
| 4 | Split a class holding two responsibilities | Split only for two unrelated jobs | Functions | "Responsibility" is vaguer than "unrelated job" | already covered |
| 5 | Replace a type conditional with subclasses | Use an enum or a literal union | Types | A subclass per type spreads one switch across files | reject |
| 6 | Depend on an interface, not a class | Name the real type | Types | An interface hides the real callee from the reader | accept narrowed |
| 7 | Add an extension point for new behavior | Do not add a hook for a future need | Unused code | Open/Closed builds the hook before a caller exists | reject |
| 8 | Read a field through an accessor | Make a value object immutable | Data objects | An immutable field needs no accessor | already covered |
| 9 | Add forwarding methods to hide a delegate | Do not chain more than two calls | State | Hide Delegate and Remove Middle Man cancel out | reject |
| 10 | Split a wide interface per client | Name the real type | Types | More types to track, for one caller's benefit | reject |
| 11 | Move the parts you expect to vary now | Write the plain solution first | Unused code | "Expect to vary" is a guess about the future | reject |
| 12 | Single Responsibility | Split only for two unrelated jobs | Functions | Same target, vaguer test | already covered |
| 13 | Open/Closed | Do not add a hook for a future need | Unused code | Direct opposite | reject |
| 14 | Liskov Substitution | Do not inherit a contract you ignore | Inheritance | None | already covered |
| 15 | Dependency Inversion | Name the real type | Types | Indirection the reader must follow | reject |

## Tally

| Verdict | Count |
|---|---|
| reject | 8 |
| already covered | 5 |
| accept narrowed | 2 |

## Notes on the two narrowed rules

### 1. Extract Function

Fowler extracts a fragment whenever he must work out what it does, and he
accepts one-line functions. Your rule forbids that for a single caller.

The two rules agree more than they look. Your rule already allows an extraction
that "names a non-obvious step". Fowler's test names the same case: you had to
study the fragment.

Proposed narrowing: keep the ban, and add one sentence.

    Extract a single-use fragment when you had to read it twice to name it.

Risk: if this sentence reads as a general licence, then the file fills with
one-line helpers. The words "had to read it twice" are the guard.

Source: https://martinfowler.com/bliki/FunctionLength.html

### 6. Depend on an interface

Your Types section tells the writer to name the real type. An interface is a
real type, so the two rules do not always clash.

The clash is narrow: it appears when a caller has one implementation and the
interface exists only for a future second one. That case is the Unused code
rule, not a typing rule.

Proposed narrowing: no new rule. Add one sentence to Unused code.

    Do not add an interface until a second implementation exists.

Source: https://blog.cleancoder.com/uncle-bob/2020/10/18/Solid-Relevance.html

## Background

Fowler treats a smell as a signal to inspect, not a rule to obey. He states
this on his CodeSmell page, and he says some long methods are fine. That
position is why this file scores each item against your stated priority instead
of adopting the smell wholesale.

Two primary sources support the current file rather than the Tier C items. Kent
Beck's fourth design rule tells you to remove any element that serves no other
rule. Fowler's Yagni page names four separate costs of building for a future
need, including the cost of carrying an unused extension point.

Sources: https://martinfowler.com/bliki/CodeSmell.html,
https://martinfowler.com/bliki/BeckDesignRules.html,
https://martinfowler.com/bliki/Yagni.html

## Decision

The user overruled six `reject` verdicts on 2026-09-12. The table above keeps
the original analysis. This section records what the rules file now holds.

| # | Verdict in the table | Decision | Condition line added |
|---|---|---|---|
| 1 | accept narrowed | accepted | you had to read it twice to name it |
| 5 | reject | accepted | the same switch appears in three or more places |
| 6 | accept narrowed | accepted | two implementations exist |
| 7 | reject | accepted | a second caller needs it now |
| 10 | reject | accepted | a client must implement a method it never calls |
| 11 | reject | accepted | the part has already changed twice |
| 13 | reject | merged into 7 | same rule, stated as a principle |
| 15 | reject | merged into 6 | same rule, stated as a principle |

Rows 2 and 9 stay rejected. Rows 3, 4, 8, 12 and 14 stay covered.

Every accepted rule carries a condition line, so it cannot fire on a guess
about the future.
