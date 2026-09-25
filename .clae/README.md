# CLAE — `.clae` Runtime

`.clae/` contains the Context Gateway, project/task metadata, schemas, and runtime state.

If you are new to CLAE, read the repository root `README.md` first. For a step-by-step setup, read `docs/GETTING_STARTED.md`.

## Directory map

```text
.clae/
├── gateway/        Gateway implementation
├── schemas/        Gateway JSON schemas
├── scripts/        CLI and project helpers
├── tasks/          Durable task records
├── ideas/          Project ideas / discovery work
├── design/         Durable design artifacts
├── archive/        Archived durable artifacts
├── project.yaml    Project metadata
└── runtime/        Generated index, packages, checkpoints, telemetry
```

## Runtime lifecycle

```text
Demand
  ↓
Candidate discovery
  ↓
Hard + soft selection
  ↓
Context Package
  ↓
Materialize
  ↓
Execute
  ↓
Verify
  ↓
Checkpoint
  ↓
Escalate only with evidence
```

## Common commands

```bash
python3 .clae/scripts/clae.py index
python3 .clae/scripts/clae.py package --task "<task>" --task-id <id> --budget 10000
python3 .clae/scripts/clae.py escalate <id> --task "<task>" --reason missing_symbol --level 1 --step 0
python3 .clae/scripts/clae.py checkpoint <id>
python3 .clae/scripts/clae.py compact <id>
python3 .clae/scripts/clae.py telemetry summary
```

See `docs/reference/commands.md` for the complete command reference.

## Generated state

Do not manually edit generated files under `.clae/runtime/` unless you are debugging the runtime.

Runtime data should normally remain uncommitted:

```text
.clae/runtime/
```

Durable task and project artifacts belong outside runtime:

```text
.clae/tasks/
.clae/ideas/
.clae/design/
```
