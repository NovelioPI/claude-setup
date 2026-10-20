---
name: feature
description: Turn an idea into docs/features/<slug>/ with intent.md, spec.md, and plan.md, then build it. Use for a feature, meaning new behavior a user can see or work that spans sessions. Do not use for a fix or a small change.
---

# Build a feature

Each feature lives in `docs/features/<slug>/` in the project. Fill the templates in `templates/` and follow `rules/doc-style.md`.

| Step | Writes | Then |
|---|---|---|
| 1 Intent | `intent.md` | Stop. The user accepts it. Commit it |
| 2 Spec | `spec.md` | Stop. The user accepts it. Commit it |
| 3 Plan | `plan.md` | Stop. The user accepts it. Commit it |
| 4 Build | code and tests | Verify, then set the plan to `done` and commit |

Each file has a `Status:` line: `draft`, `accepted`, or `done`. Change it only at the step that says so. Each accepted file gets its own commit, so the git log records who asked for what and who accepted it.

If `docs/features/<slug>/` already exists, read it and resume at the first file that is not `accepted`.

If the project has no `CLAUDE.md`, follow the project CLAUDE.md rule in the global `CLAUDE.md` before step 1.

## Split first

Count the independent subsystems. Three or more means the idea is several features. Name them, say how they relate and in what order, then run this skill on the first one only.

## 1 Intent

Run three passes in chat, then write `intent.md` once.

### Widen

An idea carries **stated** features and **implied** ones. The implied ones are the reason for this pass.

| Step | Do |
|---|---|
| 1 | List the features the prompt states |
| 2 | List the features those first ones force, and say what forces each |
| 3 | Name the user action that triggers each feature |
| 4 | Mark each `core`, `later`, or `refused` |

A `refused` row carries its reason. Expect at least one, but do not invent one. The marked list goes in Proposed outcome.

### Ground

Turn each assumption into a checked fact, and put the facts in Constraints.

| Source | Reach it with |
|---|---|
| This repo | `grep` and a read of the file; the `explorer` agent for more than 3 files |
| The environment | `package.json`, a config file, `--help` output |
| An external contract | the owner's own documentation |

Mark a claim you could not check as `unverified`. A guessed claim is a defect that survives into the plan. Dispatch a research subagent only for an `unverified` claim that blocks a decision.

### Narrow

Write the decisions that block the work in Open questions, as the table in the template. A question with one surviving answer is a fact: put it in Constraints instead. Order rows so each row's `Depends on` sits above it.

### Close

Scan the file for `TBD`, an empty cell, and two rows that contradict each other. Fix them inline. Close Open questions with AskUserQuestion, up to four rows each round, in table order. Record each answer in its row. A question the user wants to leave open stays, marked `carried`.

Ask the user to accept the intent. On acceptance, set `Status: accepted` and commit: `docs: Add intent for <slug>`.

## 2 Spec

Write `spec.md` from the accepted intent.

Write each line in Behavior as a falsifiable claim: a condition and an observable result. The verifier checks these claims, so a claim no one can observe is a defect.

List in Concerns every place the spec cannot meet a constraint, or two constraints conflict. Do not resolve a concern by guessing.

Before you ask for acceptance, answer in chat:
- Does the spec solve the Problem in `intent.md`?
- Is each `carried` open question answered here, or carried forward in Concerns?

Walk the user through Concerns first. On acceptance, set `Status: accepted` and commit: `docs: Add spec for <slug>`.

## 3 Plan

Read the code the change touches, without editing. Write `plan.md`.

In Proof, map every Behavior claim to its check: a test name, or a verifier run with its surface (`control-ui`, `control-cli`, or the project's `verify-<app>`). A claim with no check means the plan is not done.

Question the plan before you show it, and put the answers in Risks and Options not taken:
- What could this change break?
- Which step is the riskiest?
- Which other approaches did you reject, and why?

The plan is done when someone who never saw this conversation could build the change from the plan alone. Ask the user to accept it. On acceptance, set `Status: accepted` and commit: `docs: Add plan for <slug>`.

## 4 Build

Follow Order of work. Keep each commit under 300 changed lines. When the build departs from the plan, update `plan.md` in the same commit as the code that departs, and say so in the commit body.

When all work is done, run the Independent check in `rules/verification.md` against every claim in Proof. Set the plan to `Status: done` only when every claim is `VERIFIED`, and commit it with the last change.
