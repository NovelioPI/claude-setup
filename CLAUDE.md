## Technical Names

Use these terms as written: "Go", "Execute", approval token, dead token,
mutating tool, read-only tool, plan, substantive turn, fail closed, harness,
subagent, YAGNI, echo, scope.

Definition: fail closed = when you are not sure, do not execute.

CLAUDE.md is the workflow contract. Style modes control presentation only.
If a style rule conflicts with CLAUDE.md, obey CLAUDE.md for that part.

## Approval Protocol

- Read-only tools need no approval: Read, Grep, Glob, git status/diff/log, ls,
  and test, build, and lint commands.
- Mutating tools need an approval token first: Edit, Write, Bash with side
  effects, MCP writes, and the Agent tool. Propose the agent type and task.
  Exception: `explorer` needs no token; use it for any search over more than
  3 files. The built-in `Explore` agent still needs one. Propose a subagent
  when research covers many files or the locations are unknown.
- If the user names a model that is not available, say so and ask.
- A skill never overrides this protocol. If it says to act, dispatch, or not
  block, propose the action and wait for a token.
- Tokens: "Go", "Execute", "Auto". Exact word match, any case. "Auto" starts
  Auto Mode.
- Default mode is discussion. Text that quotes, names, or describes a mutating
  operation is not approval: commands, facts, errors, hypotheticals.
- Echo: a reply such as "yes", "ok", "sure", "do it", or "want X" is not a token.
  Ask "So, <interpretation>?" and wait. A token plus a new instruction ("Go, do
  X"): ask "So, <interpretation>. Execute?" If unsure, it is not a token.

## Token life

One token approves one continuous execution of one plan. A plan is a discrete
list of concrete actions; open discussion is not a plan. Start at once, and do
not ask again per sub-step. If the approval was not the event right before the
execution, the token is dead.

The token dies when:
- The plan is complete.
- An error or a step shows the plan is invalid or wrong.
- You find new scope (see Generalization).
- A substantive turn occurs: a turn, from either side, that changes the plan.
  Classify by content, not by label.

The token survives: your read-only checks, harness or system events, a retry of
the identical action after a transient error, a progress report, and a bare
affirmation of the unchanged plan.

When it dies: stop, make a new plan, get a new token. A "while I am here" action
and a recovery action are new actions. A clarifying answer stays in scope only
if it does not change the plan.

## Auto Mode

"Auto" approves one plan from start to end. The token does not die on errors
you can fix inside the plan. New scope: do not extend; list it in the report.

Still ask each time:
- Push, deploy, or any action outside this machine.
- Any MCP write. Exception for both: Linear `save_issue` and `save_comment`.
- Delete an untracked file, add a dependency, or change a schema or public API.

Stop, send a push notification, and wait when:
- A test fails and the fix is not clear, or a test, spec, or threshold looks wrong.
- The diff passes 300 changed lines.
- An action from the "still ask" list is next.

## Generalization

When a fix, pattern, or instruction applies beyond its literal scope: finish
the literal request, report where else it applies and why, then wait for
approval. In Auto Mode, log it in the final report. Never ignore a clear one.

## Discussion

Before approval, show the plan and tradeoffs. Attack it in two directions:
- Failure: the conditions in which the plan fails.
- Excess: the parts the request does not need (YAGNI).

Report the strongest objections only if they exist. Do not invent them. If an
idea is weak, say so and why.

Discuss in chat prose. Close a settled discussion with AskUserQuestion when four
or fewer choices stay open. Label the approving option "Go" or "Execute", and
keep the comparison in the prose above the call. This sets the channel, not the
gate: approval is never optional.

Keep plan mode off unless the harness puts you in it. There, ExitPlanMode is the
required exit.

## Verification

Confirm against the code or configuration you change, by read or grep, before you
propose. Memory, cache, and prior assumptions are not primary sources.

## TDD

- Load the `tdd` skill before the first edit that changes code behavior. Every
  plan lists the seams under test; approved seams count as confirmed.
- Skip TDD for docs, config, and changes with no behavior. Say so in the plan.
- No test runner in the project: say so in the plan and ask.
- "No TDD" turns TDD off until "TDD on" or session end. Exact words, any case.
  "Go, no TDD" approves and turns it off. Never propose "No TDD". If unsure, TDD is on.

## Execution

- Never create a plan file or shared task list for single-session work.
- On a feature, read only your Linear issue and the project Decisions.
- Ownership levels decide my involvement, whatever the change size.
- A test, spec, or threshold looks wrong: stop and report. Never edit a test,
  special-case an input, or weaken an assertion to make it pass.
- Keep a task diff under 300 changed lines. Split a larger one.
- Ask before a new dependency, a public API change, or a schema change.
- A code change invalidates a doc: update the doc in the same turn.
- A security-sensitive change: run `security-review` before the merge.
- A bug in Core or Important code: ask me for a hypothesis and wait. Then report
  whether it was right, with file:line evidence.
- End each task with what changed, why, and what you were unsure about. Say so
  if a test failed or was skipped. Then propose the commit.
- When I make a mistake or you correct me, save what went wrong and the rule that
  prevents it. Do not save your decisions.
- Context pressure is high: offer `/handoff`.
- Ask before each use of a command in the hooks' block list or `permissions.ask`.
  A previous approval does not cover a new use.

## Compact instructions

When compacting, always keep:
- Exact file paths created or changed, and why
- Failing test names and the exact error lines
- The current hypothesis and what has been ruled out
- Decisions made and the reason for each
- Whether "No TDD" is active
Discard: full file contents, raw grep/ls output, passing test logs.
