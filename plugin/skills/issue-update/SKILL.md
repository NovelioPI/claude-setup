---
name: issue-update
description: >-
  Move a GitHub issue between plan, next, blocked, parked, and done with gh,
  file new scope as an issue, pick the next issue, and close a milestone on
  its exit command. Also carries the effort rules: when to branch, when to
  brainstorm, what to test, and when to review. Use when work starts or lands
  on an issue, or when asked what is built and what is next. To plan a new
  milestone, use `issue-plan`.
---

# Update issues

Router: this skill changes issues that exist. A new milestone or a first set of
issues belongs to `issue-plan`.

## Status

| Status | On GitHub |
|---|---|
| plan | Open, no status label |
| next | Open, `status:next` |
| blocked | Open, `status:blocked` |
| parked | Closed as not planned |
| done | Closed as completed |

## Triggers

| Event | Command |
|---|---|
| Work starts | Count with `gh issue list --state open --label status:next --json number --jq length`; below 3, `gh issue edit <n> --add-label status:next` |
| The code lands | Commit with `Fixes #<n>` in the body; on the default branch the push closes it, on a branch the merge does |
| New scope appears mid-run | Draft a new issue with the `issue-plan` fields; do not widen the running one |
| An external input is missing | `gh issue edit <n> --remove-label status:next --add-label status:blocked`, then a comment names the input |
| The input arrives | `gh issue edit <n> --remove-label status:blocked --add-label status:next` |
| The issue is refused | `gh issue close <n> --reason "not planned" --comment "<reason>"` |
| A done issue regresses | File a new issue that links the old one; never reopen |
| Every issue in a milestone is closed | Run the exit command from the milestone description |
| The exit command returns 0 | `gh api -X PATCH repos/<owner>/<repo>/milestones/<m> -f state=closed` |
| The exit command fails with every issue closed | The milestone is underspecified; file the missing work |

Cap `status:next` at 3 open issues. Without the cap, the label cannot show work
in flight.

## Pick the next issue

List the open issues with `gh issue list --milestone "<name>" --state open --json number,title,labels,body`.

1. Skip issues labeled `status:blocked` or `status:next`.
2. Every issue in `Depends on` is closed as completed: `gh issue view <d> --json stateReason` gives `COMPLETED`.
3. Lowest `value` first.
4. Within one value, lowest `effort` first.

Risk: if effort outranks value, then a cheap value-3 issue ships before a
value-1 safety issue.

## Effort drives the process

| Effort | Before code | Test | Before commit | Shape |
|---|---|---|---|---|
| `S` | Write the acceptance command | Only for a bug fix | Run the suite | 1 commit |
| `M` | Plan in chat, wait for approval | One at the behaviour boundary | Suite, then the review triggers below | 1-2 commits |
| `L` | Brainstorm, then split into `S` and `M` issues | One for each part | Same as `M` for each part | Never ships as one issue |

Never change the effort label after close: a corrected estimate hides the miss,
so the scale never calibrates.

Follow the project's own review rule. CLAUDE.md may require a review before a
commit, and a project memory may make it ask-first; the memory wins.

## Review triggers

Skip `/code-review` and `/simplify` by default. Run them when a row below fires.

| Condition | `/code-review` | `/simplify` |
|---|---|---|
| Effort `S`, one file, suite green | skip | skip |
| Bug fix shipped with its regression test | skip | skip |
| Effort `M` or `L` | run | run |
| `risk:ask`, or touches an invariant in `PROJECT.md` | run, then `security-review` | run |
| Adds or changes an exported symbol | run | run |
| Touches 5 or more files, or 200 or more changed lines | run | run |
| A milestone's exit command passes | run once over the whole milestone diff | run once |

Count the changed lines with `git diff --stat`.

Reason: a review on every issue costs a full context read each time, and the
same bugs show once over the milestone diff.

## When to branch

| Condition | Branch |
|---|---|
| One commit, suite green | no |
| The change needs 2+ commits to read coherently | yes |
| It touches an invariant | yes |
| It mixes a move or rename with a behaviour change | yes, and split the commits |
| Another machine pulls the same branch meanwhile | yes |

Delete the branch at merge.

## When to brainstorm

| Signal | Action |
|---|---|
| The acceptance command does not fit one line | The issue is not ready; brainstorm |
| Effort reads `L` | Brainstorm, then split |
| `Depends on` crosses two or more milestones | Plan the order first |
| The issue changes an invariant | Brainstorm, then run a security review |
| New scope appears mid-run | Stop, draft it as an issue, finish the running one |
