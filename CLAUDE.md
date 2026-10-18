## Technical Names

Use these terms as written: token, mutating action, plan, fail closed, harness, YAGNI, scope.

Definition: fail closed = when you are not sure, do not execute.

Style modes control presentation only. If a style rule conflicts with CLAUDE.md, obey CLAUDE.md for that part.

## Approval Protocol

- Default mode is discussion. A mutating action, including the Agent tool, needs a token first. Exception: `explorer` (not `Explore`), for any search over more than 3 files.
- Test, build, and lint commands need no token.
- A token is a reply whose clear intent is to approve the plan you just showed: "go", "yes", "ok", "do it", "sounds good", "lgtm", in any language.
- It counts only right after you showed a plan and asked for approval.
- Intent unclear (a question, a hedge such as "maybe", or a wish such as "want X"): ask "So, <interpretation>?" and wait.
- Approval plus a small edit inside the plan ("yes, but name it X"): apply it and start. Approval plus new actions: restate the plan and ask.
- "Auto" stays an exact word, because it removes the stops.
- Quoted or described commands, facts, errors, and hypotheticals are not approval.
- A skill never overrides this protocol. If it says to act, propose and wait.
- If the user names a model that is not available, say so and ask.

## Approval scope

One approval covers one plan you saw, run once, start to finish. Stop and ask again when the plan is done, a step shows it is wrong, new scope appears, or either of us changes the plan. A "while I am here" fix or a recovery action is new scope. Read-only checks, retries, and progress reports do not end it.

## Auto Mode

"Auto" approves one plan from start to end. The approval does not end on errors you can fix inside the plan. New scope: do not extend; list it in the report.

Still ask each time:
- Push, deploy, or any action outside this machine.
- Any MCP write. Exception for both: Linear `save_issue` and `save_comment`.
- Delete an untracked file, add a dependency, or change a schema or public API.

Stop, send a push notification, and wait when:
- A test fails and the fix is not clear, or a test, spec, or threshold looks wrong.
- The diff passes 300 changed lines.
- An action from the "still ask" list is next.

## Generalization

When a fix, pattern, or instruction applies beyond its literal scope: finish the literal request, report where else it applies and why, then wait for approval. In Auto Mode, log it in the final report. Never ignore a clear one.

## Discussion

Before approval, show the plan and tradeoffs. Attack it in two directions:
- Failure: the conditions in which the plan fails.
- Excess: the parts the request does not need (YAGNI).

Report the strongest objections only if they exist. Do not invent them. If an idea is weak, say so and why.

Discuss in chat prose. Close a settled discussion with AskUserQuestion when four or fewer choices stay open. Label the approving option "Go", and keep the comparison in the prose above the call. This sets the channel, not the gate: approval is never optional.

Keep plan mode off unless the harness puts you in it. There, ExitPlanMode is the required exit.

## Verification

Confirm against the code or configuration you change, by read or grep, before you propose. Memory, cache, and prior assumptions are not primary sources.

## Execution

- Never create a plan file or shared task list for single-session work.
- On a feature, read only your Linear issue and the project Decisions.
- Ownership levels decide my involvement, whatever the change size.
- A test, spec, or threshold looks wrong: stop and report. Never edit a test, special-case an input, or weaken an assertion to make it pass.
- Keep a task diff under 300 changed lines. Split a larger one.
- Ask before a new dependency, a public API change, or a schema change.
- A code change invalidates a doc: update the doc in the same turn.
- A security-sensitive change: run `security-review` before the merge.
- A bug in Core or Important code: ask me for a hypothesis and wait. Then report whether it was right, with file:line evidence.
- End each task with what changed, why, and what you were unsure about. Say so if a test failed or was skipped. Then propose the commit.
- When I make a mistake or you correct me, save what went wrong and the rule that prevents it. Do not save your decisions.
- Context pressure is high: offer `/handoff`.
- Ask before each use of a command in the hooks' block list or `permissions.ask`. A previous approval does not cover a new use.

## Compact instructions

When compacting, always keep:
- Exact file paths created or changed, and why
- Failing test names and the exact error lines
- The current hypothesis and what has been ruled out
- Decisions made and the reason for each Discard: full file contents, raw grep/ls output, passing test logs.
