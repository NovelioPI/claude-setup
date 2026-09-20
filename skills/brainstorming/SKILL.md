---
name: brainstorming
description: Widen a raw idea into a feature space, grounded tech facts, and a numbered list of open decisions, written to plans/. Use before a project starts, when a request is one sentence and the work is not, or when a TODO.md row reads `L`. To close the decisions this produces, use `grilling`. To turn closed decisions into rows, use `todo-plan`.
---

# Brainstorm an idea

Router: this skill widens. `grilling` closes the decisions it finds. `todo-plan`
turns the closed set into rows and milestones.

`todo-update` owns the triggers that send you here. Read its "When to
brainstorm" table for those; this file owns the procedure.

## Classify first

Say the path out loud before the first question, so the user can override it.

| Path | Trigger | Output | Passes |
|---|---|---|---|
| `probe` | a feasibility question, where the answer is the deliverable | an answer in chat | none |
| `bounded` | a change to a flow that already exists in this repo | a decision list in chat | Narrow |
| `project` | a new project, a new subsystem, or a changed interface others depend on | a file in `plans/` | all three |

`bounded` measures the repo, not your familiarity. A flow you cannot open and
read is not bounded.

Take the heavier path when two fit. Hidden complexity found mid-run upgrades the
path: say so and step up. The ratchet turns one way.

## Output

The `project` path writes one file: `plans/brainstorm-<slug>.md`, following
`rules/doc-style.md`.

Write each pass into the file as you finish it. A brainstorm held only in the
transcript dies at the next compaction, and the next skill in the chain reads
the file, not your memory.

Show the slug and the three passes, then wait for "Go" or "Execute" before the
first write.

`probe` and `bounded` stay in chat and write no file.

## Pass 1 — Widen

Count the independent subsystems first. Three or more means the idea is several
projects. Name them, say how they relate and in what order, then widen only the
first. The rest become later milestones.

An idea carries **stated** features and **implied** ones. The implied ones are
why this pass exists.

| Step | Do |
|---|---|
| 1 | List the features the prompt states |
| 2 | List the features those first ones force, and say what forces each |
| 3 | Name the user action that triggers each feature |
| 4 | Mark each `core`, `later`, or `refused` |

A `refused` row carries its reason. The refusals are the pass's real output: a
list that only grows has told you nothing.

Done when every feature is marked, and at least one is `refused`.

## Pass 2 — Ground

Turn each assumption the idea rests on into a checked fact.

| Source | Reach it with |
|---|---|
| This repo | `graft ask "<assumption>" --source` |
| The environment | `package.json`, a config file, `--help` output |
| An external contract | the owner's own documentation |

Mark a claim you could not check as `unverified`. An unverified claim is an
honest row; a guessed one is a defect that survives into `TODO.md`.

Propose a research subagent for one case only: an `unverified` claim that blocks
a decision in pass 3. Name the claim, the decision it blocks, and the source you
would send the agent to, then wait for a token.

Done when every assumption carries a source link or the label `unverified`.

## Pass 3 — Narrow

Write the decisions that block `todo-plan`.

| Column | Content |
|---|---|
| ID | `D1`, `D2`, counting up |
| Decision | The choice, as a question |
| Options | Two or more, each with what it costs |
| Recommendation | Your pick, with the reason |
| Depends on | The IDs that must settle first, or `—` |

A question with one surviving answer is a fact. Record it in pass 2 and leave it
out of this table.

Order the rows so a row's `Depends on` sits above it. `grilling` asks in rounds,
and that order is the first round.

Done when every open decision has an ID, two or more options, and a
recommendation.

## Hand off

Scan the file for `TBD`, an empty cell, and two rows that contradict each other.
Fix them inline.

End with the file path, the count of open decisions, and this offer:

    Grill these <n> decisions? Go or Execute.

On a token, run `grilling` against the pass 3 table. When `grilling` returns,
offer `todo-plan` the same way:

    Write TODO.md from these decisions? Go or Execute.

Each stage takes its own token. One token never covers two stages.

Risk: if a brainstorm ends without a decision table, then `grilling` has no
frontier and the chain stops here.
