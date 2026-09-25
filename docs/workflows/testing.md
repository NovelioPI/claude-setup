# Test Strategy Workflow

## Problem

A coding agent can easily turn “good engineering” into “one test file per tiny function.” That adds noise and maintenance without proportional confidence.

## Principle

> Protect behavior, not function count.

## Test decision

Before creating a dedicated test, ask:

1. Does this behavior have domain meaning?
2. Does it branch or contain edge cases?
3. Does it transform data in a non-obvious way?
4. Does it change state or cross a boundary?
5. Is it externally observable or a public contract?
6. Did it fix a regression?
7. Can an existing test or deterministic checker already protect it?

A trivial pure helper such as `add(a, b)` may reasonably have no dedicated test.

## Test levels

```text
cheap deterministic check
        ↓
existing unit/integration coverage
        ↓
new focused test
        ↓
end-to-end / visual test
```

Select the cheapest level that provides enough confidence.

## Test budget

Planning can record:

```yaml
test_budget:
  strategy: minimal
  max_new_test_files: 2
  prefer_existing_test_modules: true
```

The budget is not a hard quality ceiling for high-risk work. Security, billing, migrations, and critical business logic can override it.

## Anti-patterns

Avoid:

- one test file per trivial helper;
- testing implementation details when public behavior is enough;
- duplicating the same assertion at many levels;
- adding tests only to increase coverage percentage.
