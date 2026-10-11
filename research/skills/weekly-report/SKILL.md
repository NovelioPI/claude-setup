---
name: weekly-report
description: Write the weekly research report from the experiment logs and MLflow, then the chat summary and, on approval, a slide deck. Use before the weekly meeting or when the user asks for a summary, report, or presentation of recent results.
---

# Write the weekly report

The report is the single source. The summary and the deck come from it.

## Collect

1. Find this week: the ISO week of today, Monday to today.
2. Read every `experiments/*/log.md` in the current repo.
3. Keep the entries whose ID date `E-<YYYY-MM-DD>-<n>` falls in the week.
4. Get each entry's metrics from MLflow with the `research:mlflow` skill:
   filter on `tags.log_entry = '<ID>'`.

Use only the logs and MLflow. Never fill a gap from memory.
An entry with no Result line shows `no result logged`.

## Write

Write `reports/weekly/<YYYY>-W<ww>.md`. Rewrite it if it exists.

    # Week <ww>, <YYYY>

    ## Summary
    - <what moved this week>
    - <the best result, with its number and entry ID>
    - <the main open question>

    ## <experiment>
    Question: <from the Why lines>

    | Entry | Config | <metric> | Result |
    |---|---|---|---|

    Next: <from the Next lines>

    ## Blockers and asks
    - <each Blockers line that is not None, with its entry ID>
    - None, only when every entry in the week says None

One section per experiment with entries this week. Cite the entry ID for every
number.

## Summary

Print the Summary section in chat, then the report path.

## Deck

Build the deck only when the user asks, and only from the report.
Publishing sends the content to claude.ai, so show the slide list and wait for
approval, even under Auto.

Start from the "Slides" artifact type, through the Artifact tool's quickstart.
Use one slide for the title and week, one for the Summary, one for each
experiment section, and one for blockers and asks.
Put each results table on its experiment slide, unchanged.
