---
name: issue-plan
description: >-
  Turn settled decisions into a GitHub milestone and contract issues, drafted
  first in plans/build-<name>.md, and keep PROJECT.md for the project facts
  and invariants. Use after `grilling`, or when a project needs its first
  milestone. To move an issue that already exists, use `issue-update`.
---

# Plan a milestone as issues

Router: this skill drafts and creates. A status move belongs to `issue-update`.
An idea that is not yet settled decisions starts at `brainstorming`, then `grilling`.

## 1. PROJECT.md

Create it at the repo root when missing. It holds what issues cannot.

| Section | Required | Trigger to include |
|---|---|---|
| What this project is, with a role table | yes | — |
| Target layout | yes | — |
| Import boundary | no | Two or more layers |
| Entry points | no | Ships a command or a service |
| Operating cycle | no | Clock-driven or event-driven work |
| Invariants | yes | — |

An invariant holds for the life of the project. Write it with the concrete
failure it prevents. An issue that touches one gets `risk:ask`.

## 2. Draft in plans/build-<name>.md

Creating an issue on a public repo publishes it, so draft first.

| Part | Content |
|---|---|
| Milestone | Name, goal, exit command, draft IDs |
| Order | Stages, with the reason for each |
| One section per draft | `### W<n> — <title>`, then a field table |

| Field | Rule |
|---|---|
| Title | Imperative, 70 characters or fewer, no trailing period |
| Labels | One each: `value:1-3`, `effort:S/M/L`, `risk:auto/ask/human` |
| Goal | One sentence: what is true when done |
| Scope | Paths the agent may edit |
| Non-goals | What a reader might expect but is excluded |
| Acceptance | One shell command; exit 0 means done |
| Hints | Path and symbol, no line numbers |
| Unknowns | Named, or `none` |
| Depends on | Draft IDs, or `—` |

Split an `effort:L` draft before filing. The exit command is the milestone's
oracle: a command, never a sentence.

## 3. Create, after a token

1. `bash scripts/labels.sh <owner/repo>` when the labels are missing.
2. Create the milestone with `gh api repos/<owner>/<repo>/milestones`, the goal
   and exit command in its description.
3. Create issues in dependency order with `gh issue create --milestone`, replacing
   each `W<n>` in Depends on with the issue number it got.
4. Run `scripts/contract-check.sh <n>` on each. Fix a failure before the next.
