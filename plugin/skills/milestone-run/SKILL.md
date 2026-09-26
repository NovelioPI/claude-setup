---
name: milestone-run
description: Run a GitHub milestone to completion as an agent loop, dispatching one implementer per issue, gating on each issue's acceptance command, and stopping when the milestone's exit command returns 0. Use when a milestone is approved and its issues pass the contract check. To change one issue by hand, use `issue-update`.
---

# Run a milestone

You are the orchestrator. You pick issues, dispatch agents, gate on verdicts,
commit, and stop when the milestone's exit command passes.

Router: this skill runs a whole milestone. A single issue change belongs to
`issue-update`. Creating a milestone and its issues belongs to `issue-plan`.

## Context discipline

Read verdict blocks. Leave diffs to the reviewer.

| You read | You never read |
|---|---|
| `gh issue view <n> --json body,labels` and the milestone description | a diff |
| An implementer's verdict block | an implementer's transcript |
| A reviewer's finding lines | a whole source file |
| An exit code | a test log |

Reason: the orchestrator lives for the whole milestone, so every token it spends
on a diff is an issue it cannot reach later.

Risk: if the orchestrator reads diffs, then its context fills after a few issues
and the loop dies mid-milestone.

## 0. Preflight

Stop and report when any check fails. A failed check is a planning gap, not a
run to attempt.

| Check | Fix when it fails |
|---|---|
| The milestone description holds an exit command | Add it to the description |
| The exit command is a command, not prose | Rewrite it |
| Every open issue passes `~/.claude/scripts/contract-check.sh <n>` | Fix the body or the labels |
| `git check-ignore -q .claude/work/` succeeds | Add `.claude/work/` to `.gitignore` |
| The working tree is clean | Commit or stash first |

## 1. Get the token

Show the milestone as the plan: its name, its goal, its exit command, and every
issue number it ships. Then wait for "Go" or "Execute".

One token covers the listed issues. An issue outside that list is new scope: stop
the loop, report it, and get a second token.

## 2. Pick the eligible issues

Follow "Pick the next issue" in `issue-update`. Dispatch in parallel only when
the eligible issues share no path in Scope.

Cap `status:next` at 3 issues, which caps concurrent implementers at 3.

An issue that meets a "When to branch" condition in `issue-update` leaves the
loop: stop and report, because its merge needs its own token.

## 3. Dispatch

For each issue, in this order:

1. When the effort is `M` and Hints is empty, dispatch `claude-setup:scout`, then write
   its block into Hints with `gh issue edit <n> --body-file -`.
2. `gh issue edit <n> --add-label status:next`.
3. Record the fingerprint from `~/.claude/scripts/contract-check.sh <n>`.
4. Send `claude-setup:implementer` these lines and nothing more.

```
ISSUE      <n>
ACCEPTANCE <the acceptance command>
BRIEF      ${CLAUDE_PLUGIN_ROOT}/guides/agent-brief.md
```

Reason: the fingerprint hashes the body and the labels, so an edit after step 3
fails the gate for no reason.

Paste no rule text, no file content, and no repository background. The agent
reads the issue and the brief itself.

Pick the model by effort: `S` runs on haiku, `M` on sonnet, `L` splits into `S`
and `M` issues before it runs at all.

## 4. Gate

First run `~/.claude/scripts/contract-check.sh <n> --since <fingerprint>`. A
failure means the contract changed mid-run: stop and report.

Then read the verdict block. Act on `VERDICT` and `EXIT`, never on the prose.

| Verdict | Action |
|---|---|
| `pass`, exit 0 | Continue to step 5 |
| `pass`, exit non-zero | Treat as `fail`; the agent misreported |
| `fail` | Run `~/.claude/scripts/task-close.sh <n>`, move the issue to `status:blocked` with a comment naming the blocker, take the next issue |
| No verdict block | Treat as `fail`; do not infer success from a summary |

## 5. Review, when a trigger fires

Read the review trigger table in `issue-update`. Skip the review when no row
fires, which is the common case for an `S` issue.

Dispatch `claude-setup:reviewer` with the diff range, nothing else. Write the
block it returns to `.claude/work/<n>/reviewer.md`. Apply its findings yourself, or dispatch the implementer again with the
finding lines.

## 6. Commit

Stage the files the verdict named. Check every other changed file before you
commit, and name it in the message or leave it unstaged.

End the subject with `(#<n>)` and put `Fixes #<n>` in the body, as
`rules/commit-style.md` states.

After the push, run `~/.claude/scripts/task-close.sh <n>`. It posts the reports
from `.claude/work/<n>/` to the issue and deletes the folder.

## 7. Close or repeat

When every issue in the milestone is closed, run the milestone's exit command.

| Result | Action |
|---|---|
| Exit 0, every issue closed | Close the milestone as `issue-update` states, run the milestone-exit review, report and stop |
| Exit non-zero, every issue closed | The milestone is underspecified; draft the missing work as an issue and stop for a token |
| Issues remain | Return to step 2 |

The loop ends on an exit code, never on your own judgment that the goal is met.

## Budget

Each implementer stops itself at `maxTurns: 40`, from its frontmatter, so a
stuck agent cannot run forever. A run started with `claude -p` can also pass
`--max-budget-usd`. An interactive session has no dollar cap.
