---
name: experiment-log
description: Keep the experiment log in experiments/<experiment>/log.md. Use before and after each run, and when the user asks why a run happened or what comes next.
---

# Keep the experiment log

Each experiment has one log: `experiments/<experiment>/log.md`.
Create the file on the first run of an experiment. Put the newest entry first.

## Entry

    ## E-<YYYY-MM-DD>-<n> <short title>
    - Why: <the question this run answers>
    - Config: <config file or changed values>, seed <n>
    - Run: <MLflow run ID>; results at <path>
    - Result: <one line>
    - Next: <one line>
    - Blockers: <one line, or None>

`<n>` counts up within the day and the experiment.

## When

1. Before the run: write Why and Config. Leave Run, Result, and Next empty.
2. After the run: fill Run, Result, Next, and Blockers.

An entry with no Blockers line counts as None.

A run that crashed still gets Result: the error line.

## Link to MLflow

The run code sets these tags itself, so no MCP write is needed:

    mlflow.set_tags({
        "log_entry": "E-2026-10-11-01",
        "mlflow.note.content": "<the Why line>",
    })

Reason: under Auto, an MCP write stops to ask, and a tag set in code does not.
