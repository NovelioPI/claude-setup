---
description: Plan a multi-session feature into a spec and a task graph
argument-hint: <feature-name> <one-line goal>
---

Feature: $ARGUMENTS

1. Use the explorer subagent to map the relevant code. Do not read files yourself.
2. Interview me about edge cases, constraints and acceptance criteria, until
   the approach has one meaning. Ask one question at a time. For Core work,
   give 2 approaches with tradeoffs, and record my choice under Decisions.
3. Draft docs/plans/<feature-name>.md from the template below. Cap it at about
   120 lines. Give each task its own "### T<n>" section with its ownership level.
4. Draft the Tasks with dependencies. Each task is one session and one commit.
   Its title starts with its id and [mode]. Its description names its spec
   section and its check.
   - Core or Important work: two tasks. "T<n>-test [tests]" writes the
     acceptance tests. "T<n>-impl [impl]" depends on it. For Core, T<n>-test
     asks me for the invariants in plain words and writes property tests.
   - Plumbing: one "T<n> [impl]" task, checked by existing tests or a command.
5. Show the spec and the task list. In plan mode, show them with ExitPlanMode.
   Wait for a token, then write the spec and create the Tasks.
6. Stop. Tell me to /clear and start each task with: ccf <feature-name> <mode>

Template:

```markdown
# <Feature name>

## Goal
<1-2 sentences: what changes for the user/system and why>

## Non-goals
- <explicitly out of scope>

## Approach
<5-10 lines: the chosen design and the main alternative rejected>

## Acceptance (feature level)
- <measurable check, e.g. "export of 1M rows finishes in < 30 s; existing integration tests pass">

## Tasks
### T1: <title>  [Core|Important|Plumbing]
Files: <paths>
Do: <what, in 2-5 lines>
Check: <test written in T1-test (Core/Important), or a command (Plumbing)>

### T2: <title>  (depends on T1)
...

## Decisions (append only)
- <date>: <decision> — <reason>
```
