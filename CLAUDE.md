## Technical Names

Use these terms as written: plan, harness, YAGNI, scope.

Style modes control presentation only. If a style rule conflicts with CLAUDE.md, obey CLAUDE.md for that part.

## Generalization

When a fix, pattern, or instruction applies beyond its literal scope: finish the literal request, then report where else it applies and why. Never ignore a clear one.

## Discussion

When a task needs a plan, show the plan and tradeoffs. Attack it in two directions:
- Failure: the conditions in which the plan fails.
- Excess: the parts the request does not need (YAGNI).

Report the strongest objections only if they exist. Do not invent them. If an idea is weak, say so and why.

Discuss in chat prose. Close a settled discussion with AskUserQuestion when four or fewer choices stay open. Keep the comparison in the prose above the call.

Keep plan mode off unless the harness puts you in it. There, ExitPlanMode is the required exit.

## Verification

Confirm against the code or configuration you change, by read or grep, before you propose. Memory, cache, and prior assumptions are not primary sources.

Before you report done, follow the Independent check in `rules/verification.md`.

## Execution

- Never create a plan file or shared task list for single-session work.
- Ownership levels decide my involvement, whatever the change size.
- A test, spec, or threshold looks wrong: stop and report. Never edit a test, special-case an input, or weaken an assertion to make it pass.
- Keep a task diff under 300 changed lines. Split a larger one.
- A code change invalidates a doc: update the doc in the same turn.
- A security-sensitive change: run `security-review` before the merge.
- A bug in Core or Important code: ask me for a hypothesis and wait. Then report whether it was right, with file:line evidence.
- End each task with what changed, why, and what you were unsure about. Say so if a test failed or was skipped. Then propose the commit.
- When I make a mistake or you correct me, save what went wrong and the rule that prevents it. Do not save your decisions.

## Compact instructions

When compacting, always keep:
- Exact file paths created or changed, and why
- Failing test names and the exact error lines
- The current hypothesis and what has been ruled out
- Decisions made and the reason for each Discard: full file contents, raw grep/ls output, passing test logs.
