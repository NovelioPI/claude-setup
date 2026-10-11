---
name: prompts
description: Where prompts live and how code loads them. Use before writing, moving, or changing a prompt, or code that loads one.
---

# Keep prompts in files

## Place

One prompt per file: `prompts/<task>/<name>.j2`.
Never write a prompt as a string literal in code.

## Load

Load every prompt through one loader function, by `<task>/<name>`.
Render it with Jinja2 and `StrictUndefined`.
Risk: if an undefined variable renders as empty, then the model gets a broken
prompt and no error shows.

## Trace

Log the prompt name and the SHA-256 of the rendered text with each MLflow run.
The rendered text includes the variables, so the hash changes when they do.

## Change

A prompt that a logged run used is fixed. Copy it to a new file, such as
`<name>_v2.j2`, and change the copy.
Reason: an old result keeps a prompt file that matches it.
