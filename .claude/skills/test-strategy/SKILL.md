---
name: test-strategy
description: Decide what testing is worth adding for a change. Use during planning, implementation, or review when tests may be added.
---

# Test Strategy

## Goal

Protect meaningful behavior while keeping test maintenance proportional to risk.

## Decision order

1. Is the behavior trivial and obvious?
2. Is there domain logic?
3. Are there important branches or edge cases?
4. Is there state, IO, parsing, or a public contract?
5. Is this a regression fix?
6. Can an existing test already protect it?
7. What is the cheapest adequate verification?

## Default outcomes

- Trivial pure helper: dedicated test may be unnecessary.
- Business rule: focused test expected.
- Regression bug: regression test expected unless existing coverage is already protective.
- Public API: verify externally observable behavior.
- Security/financial/migration logic: favor stronger protection and explicit review.

## File policy

Prefer extending an existing relevant test module before creating a new test file.
Do not create a test file for a single trivial helper unless the repository has a strong local convention that requires it.

## Output

Record:
- decision
- reason
- test level
- files to extend/create
- deterministic checks
