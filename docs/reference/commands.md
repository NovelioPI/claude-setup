# CLAE CLI Reference

Run commands from the project root.

## `index`

Build the repository metadata index.

```bash
python3 .clae/scripts/clae.py index
```

Output:

```text
.clae/runtime/indexes/repo.json
```

Use after setup and after major repository changes.

## `package`

Create and materialize a context package.

```bash
python3 .clae/scripts/clae.py package \
  --task "<task>" \
  --task-id <id> \
  --budget 10000
```

Options:

- `--task` required task description.
- `--task-id` optional stable task ID.
- `--budget` token budget estimate; default `10000`.

Output:

```text
.clae/runtime/context-packages/<id>.json
```

## `escalate`

Request a broader context package after evidence shows the current one is insufficient.

```bash
python3 .clae/scripts/clae.py escalate <task-id> \
  --task "<task>" \
  --reason <reason> \
  --level <current-level> \
  --step <escalation-step> \
  --budget <budget>
```

Allowed reasons:

```text
missing_symbol
dependency_impact
conflicting_evidence
failed_verification
unverifiable_acceptance
```

Escalation is bounded by the Gateway configuration.

## `checkpoint`

Create a compact durable checkpoint.

```bash
python3 .clae/scripts/clae.py checkpoint <task-id>
```

Optional:

```bash
--objective "<objective>"
```

Output:

```text
.clae/runtime/checkpoints/<task-id>.json
```

## `compact`

Compact a materialized context package.

```bash
python3 .clae/scripts/clae.py compact <task-id>
```

Use after exploratory work has produced redundant context.

## `event`

Write a custom telemetry event.

```bash
python3 .clae/scripts/clae.py event <event-type> \
  --task-id <id> \
  --tokens-used 1200 \
  --escalations 1
```

This is mainly useful when extending CLAE.

## `telemetry summary`

Show aggregated telemetry.

```bash
python3 .clae/scripts/clae.py telemetry summary
```

## Task scripts

Create an execution workspace:

```bash
python3 .claude/scripts/init_task.py "<task>"
```

Create a durable project task record:

```bash
python3 .claude/scripts/create_task.py <id> "<title>"
```
