---
description: Plan a multi-session feature into a Linear project and issues
argument-hint: <feature-name> <one-line goal>
---

Feature: $ARGUMENTS

1. Use the explorer subagent to map the relevant code. Do not read files yourself.
2. Interview me about edge cases, constraints and acceptance criteria, until
   the approach has one meaning. Ask one question at a time. For Core work,
   give 2 approaches with tradeoffs, and record my choice under Decisions.
3. Draft the Linear project description from the project template below. Name
   the project <feature-name>. Cap the description at about 60 lines.
4. Draft the issues from the issue template below. Each issue is one session
   and one commit. Its title starts with its id. Give it one `level:` label.
   Add a "blocked by" relation for each dependency.
   - Every issue names its seams. The task writes tests at those seams with
     the `tdd` skill. For Core, it asks me for the invariants in plain words
     and writes property tests.
   - Use a command check only when the task has no behavior to test.
5. Show the project and the issue list. In plan mode, show them with ExitPlanMode.
   Wait for a token, then create the project, any missing labels, and the issues.
6. Stop. Tell me to /clear and start each task with: ccf <feature-name>

Project template:

```markdown
## Goal
<1-2 sentences: what changes for the user/system and why>

## Non-goals
- <explicitly out of scope>

## Approach
<5-10 lines: the chosen design and the main alternative rejected>

## Acceptance (feature level)
- <measurable check, e.g. "export of 1M rows finishes in < 30 s; existing integration tests pass">

## Decisions (append only)
- <date>: <decision> — <reason>
```

Issue template (title `T<n>: <title>`, label `level:core|important|plumbing`):

```markdown
Files: <paths>
Do: <what, in 2-5 lines>
Seams: <public interfaces under test>
Check: <tests at those seams, or a command when nothing has behavior>
```
