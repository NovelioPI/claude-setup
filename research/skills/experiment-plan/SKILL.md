---
name: experiment-plan
description: Turn an idea from notes/ideas.md into an experiment list in experiments/<exp>/plan.md. Use when the user asks how to test an idea or what to run next.
---

# Plan experiments

Write `experiments/<exp>/plan.md`:

    # <exp>
    Source idea: I-<n>

    | Field | Content |
    |---|---|
    | Hypothesis | <one falsifiable sentence> |
    | Metric | <name, and the split it is measured on> |
    | Baseline | <what the result is compared to> |
    | Disproved if | <the result that would show the hypothesis is wrong> |

    ## Runs
    | # | Change from baseline | Why | Cost | Status |
    |---|---|---|---|---|

Order the runs so the cheapest run that can disprove the hypothesis goes first.
Status is `planned`, `running`, or `done <entry ID>`.

Each run's Why becomes the Why line of its entry in `experiments/<exp>/log.md`.
Follow `~/.claude/research/guides/experiment-log.md` when the run starts.
Then set the idea's status to `planned` in `notes/ideas.md`.
