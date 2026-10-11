# Notebooks

## Shape

Keep logic in importable modules. A notebook only calls them, loads data, and
shows results.
Reason: code inside a cell cannot be imported, tested, or reused by a run script.

Never import from a notebook. Measurement code never depends on a notebook.

Edit `.ipynb` files with the NotebookEdit tool, not with a text edit.

## Repeatable

Set every seed in the first code cell.
Before a commit, run the notebook top to bottom in a fresh kernel:

    uv run --with nbconvert jupyter nbconvert --to notebook --execute --inplace <file>.ipynb

A notebook that fails this run is not done.

## Results

Log every reported number to MLflow, following
`~/.claude/research/guides/mlflow.md`. A number shown only in a cell output is not
a result.

## Outputs in git

Commit notebooks without outputs. Use `nbstripout` when the repo has it set up.
Setting it up adds a dependency and a git filter, so ask first.
