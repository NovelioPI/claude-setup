---
name: compare-runs
description: Compare MLflow runs as a table, a plot, and a significance test. Use when the user asks which run or config is better, or for numbers to show in a report.
---

# Compare runs

Follow `~/.claude/research/guides/mlflow.md` for every MLflow read.

## Steps

1. Pick the runs: by `tags.log_entry`, by experiment, or by the IDs the user gives.
2. For each run, get the metrics, the changed params, the seed, and
   `tags.mlflow.source.git.commit`.
3. Group runs into arms: the same config with different seeds.
4. Write a table: one row per arm, with the mean, the spread, and the seed count.
5. Plot the main metric per arm to `reports/figures/<name>.png`:

       uv run --with mlflow --with matplotlib python <script>

6. Test the difference against the baseline arm:
   - 3 or more seeds per arm: a bootstrap 95% interval of the difference.
   - Fewer seeds: write "too few seeds for a test". Do not claim a winner.
7. Print the table, the figure path, and one line per arm with its entry ID and
   git commit.

Two runs from different git commits are not the same config. Say so when it
happens.
