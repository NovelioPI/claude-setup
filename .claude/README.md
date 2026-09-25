# CLAE

CLAE is a context-limited agentic workflow for software projects.

## What changed from v0.1

### 1. Concise output

Use `.claude/output-styles/clae-concise.md`.

Recommended personal setup:

```text
cp .claude/output-styles/clae-concise.md ~/.claude/output-styles/
```

Then run:

```text
/output-style CLAE Concise
```

The style keeps Claude Code's coding instructions and changes only communication style. Because output styles affect the main session system prompt, keep the file short.

### 2. Brainstorm before execution

Use `/brainstorm` when the idea is not mature.
Long-running ideation lives under `.clae/ideas/` and does not enter every session automatically.

### 3. Sparse project management

Use the `project` skill for task state.

The old giant `todo.md` is replaced by:

- `.clae/project.yaml` — tiny index
- `.clae/tasks/*.yaml` — active tasks
- `.clae/archive/` — history

Read only the records needed for the current request.

### 4. Lazy language and framework rules

Rules are path-scoped under `.claude/rules/`.
Python rules load for Python files, TypeScript rules for TypeScript files, and so on.
This avoids loading every language guide into every builder context.

Keep language rules small. Put mechanically enforceable style in formatters/linters, not prompts.

## Recommended flow

```text
brainstorm
   ↓
project task
   ↓
contract
   ↓
repo-scout
   ↓
plan
   ↓
builder
   ↓
verify
   ↓
review
   ↓
simplify
   ↓
verify
   ↓
archive + learn
```

## Personal output style setup

For a per-user default, copy the style to `~/.claude/output-styles/` and set:

```json
{ "outputStyle": "CLAE Concise" }
```

A project-local example is available at `.claude/settings.local.json.example`.
