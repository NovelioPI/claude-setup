---
name: mlflow
description: Read MLflow experiments, runs, metrics, and traces. Use when the user asks about runs, results, or comparisons between runs.
---

# Read MLflow

Use the `mlflow` MCP tools first.

When no MCP tool covers the task, use the Python client through `uv`:

    uv run --with mlflow python -c "import mlflow; print(mlflow.search_runs(...))"

Or use the CLI: `uv run --with mlflow mlflow runs list --experiment-id <id>`.
Both read `MLFLOW_TRACKING_URI` from the shell, so set it from the project.

Find the runs of a log entry with `filter_string="tags.log_entry = '<ID>'"`.

Never delete a run, an experiment, or a trace.
Risk: if a run is deleted, then a reported number loses its source.

Write tags and notes from the run code, not through MCP. See the
`experiment-log` skill.
