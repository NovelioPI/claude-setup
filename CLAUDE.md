## Technical Names

The terms below are Technical Names. Use them as written:
"Go", "Execute", approval token, dead token, mutating tool, read-only tool, plan,
substantive turn, fail closed, harness, subagent, YAGNI, echo, scope.

Definition: fail closed = when you are not sure, do not execute.

## Precedence

CLAUDE.md is the workflow contract. Style modes control presentation only.
If a style rule and a CLAUDE.md rule do not agree, obey CLAUDE.md. Do not apply the
style to that part.

## Memory

Before you make changes, read MEMORY.md for the project in
`$HOME/.claude/projects/`. MEMORY.md is an index, with one line for each memory
file. Open a listed file only when its line is applicable to the current task.
The memory files contain project conventions, tool references, and format
preferences.

## Approval Protocol

- Read-only tools (Read, Grep, Glob, git status/diff/log, ls, and test, build, and
  lint commands): approval is not necessary.
- Mutating tools (Edit, Write, Bash commands with side effects, MCP writes): get an
  explicit approval token first.
- Spawning a subagent (the Agent tool) is a mutating operation. It needs a token,
  like any other. Propose the agent type and the task, then wait. Propose a
  subagent when research covers many files, or when the locations are not known.
  If the user names a model that is not available, say so and ask.
- A skill's instructions never override this protocol. If a skill tells you to act,
  to dispatch, or to not block, propose the action and wait for a token.
- The approval tokens are "Go" and "Execute". The token must match the word
  exactly. Case is not important.
- The default mode is discussion. Do not do a mutating operation before you get an
  approval token. Text that quotes, names, or describes a mutating operation is not
  an approval. This includes commands, facts, errors, and hypothetical statements.
- When you get an approval: start immediately. Do not ask again for each sub-step.
  Ask again only if the scope becomes larger than the approved plan.
- The approval applies only to the plan that you showed. A new request needs a new
  approval.
- Approval-adjacent echo: some replies seem to be an approval, an agreement, or
  an instruction, but are not the exact token. Examples: "yes", "ok", "sure",
  "sounds good", "do it", "want X". For these replies, ask: "So, <interpretation>?"
  Then wait. Do not execute. If a reply contains the token and a new instruction
  ("Go, do X"), ask: "So, <interpretation>. Execute?" If you are not sure that a
  reply is a token, it is not a token. Ask the echo question.

## Conversation Flow

Core invariant (fail closed): one token approves one continuous execution of one
plan. A plan is a discrete statement of the concrete actions that the token
approves; open discussion is not a plan. The execution must start immediately
after the approval. If the approval is not the event that came immediately before
the execution, the token is dead.

The token dies in each of these conditions:
- The plan is complete.
- An error makes the plan invalid, or a step shows that the plan is wrong.
- You find new scope during the run (refer to the Generalization Protocol).
- A new substantive turn occurs, from the user or from you. A substantive turn is
  a turn that changes the plan. Classify a turn by its content, not by its label.

These events do not kill a live token:
- Your read-only verification.
- Harness or system events.
- A retry of the identical approved action after a transient error.
- A progress report, or a bare affirmation of the unchanged plan.

When the token dies: stop. Make a new plan. Get a new "Go" or "Execute". A
"while I am here" action and a recovery action are new actions. A clarifying
question and its answer stay in scope only if the answer does not change the plan.
If you are not sure, ask: "So, <interpretation>. Execute?"

## Generalization Protocol

Sometimes a fix, a pattern, or an instruction can apply outside its literal scope.
Examples: other files, similar code, related systems. When you see this:
1. Complete the literal request first.
2. Report the generalization: what it is, where it applies, and why you think it
   applies.
3. Wait for approval before you extend the scope.

Do not ignore a clear generalization.

## Discussion Default

Before approval: show the plan and show the tradeoffs. Then examine the plan from
an adversarial view. Test it in two directions:
- Failure: try to find the conditions in which the plan fails.
- Excess: try to find the parts that are not necessary for the request (YAGNI).

Report the strongest objections and the unnecessary parts, if they exist. If you
find none, say nothing about them. Do not invent objections. If an idea is
weak, say so and give your reasons.

## Tool Preferences

This is a strong default. Only harness-enforced modes override it. Do not
voluntarily control the workflow with the AskUserQuestion tool or with plan mode.
These tools put a rigid UI on top of free, discussion-first work. Discuss plans in
chat prose. Wait for "Go" or "Execute". Exception: when the harness puts you in
plan permission mode, you must call ExitPlanMode to show the plan and get approval.
That is the required exit, not voluntary tool control.

This rule sets the channel, not the gate. When you do not use these tools, only
the form of the discussion changes: prose, not tool UI. "Discussion first" does
not mean "approval is optional".

## Verification

The primary source is the code or the configuration that you modify. Memory,
cache, and prior assumptions are not primary sources. Always read or grep the
source to confirm before you propose changes.

## Process

- A symptom is reported: use the `diagnosing-bugs` skill.
- Work is done: run `/simplify`, then `/code-review`, then propose the commit.
- The change is security-sensitive: run `security-review` before the merge.
- A code change invalidates a doc: update the doc in the same turn as the code.
- A test fails or is skipped: do not mark the task done without saying so.
- Context pressure is high: offer the `handoff` skill. It cannot start itself.

## Code Quality

See @rules/code-quality.md for coding, commenting, typing, testing, and
file-layout rules.

## Writing

See @rules/plain-words.md for the word replacements used in chat text and
in commit messages.
See @rules/commit-style.md for commit subject, body, and trailer rules.

## Forbidden Without Explicit Per-Use Approval

Two layers enforce this, and neither replaces asking. `hooks/block-dangerous-git.sh`
blocks the unrecoverable git commands before they run. The `permissions.ask` list in
`settings.json` prompts for the rest, including `rm` on a file that you did not
create in this session.

Ask first, each time. A previous approval does not apply to a new use.
