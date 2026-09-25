# CLAE v0.1

Context-Limited Agentic Engineering scaffold for Claude Code.

## Directory map

```text
.claude/
├── CLAUDE.md                    # Always-on, compact project constitution
├── settings.json                # Verification hooks
├── agents/                      # 5 isolated roles
│   ├── repo-scout.md
│   ├── planner.md
│   ├── builder.md
│   ├── verifier.md
│   └── reviewer.md
├── skills/
│   └── task-router/SKILL.md     # Complexity × risk routing
├── schemas/                     # Machine-readable artifact contracts
├── templates/                   # Human-readable artifact templates
├── hooks/
│   ├── verify_changed_file.py   # Cheap syntax gate after Python edits
│   └── verify_on_stop.py        # Optional task-level stop gate
├── scripts/
│   └── init_task.py             # Create ACTIVE task workspace
└── work/                        # Per-task artifact bus (keep out of commits as desired)
```

## Recommended invocation

Start with the task router:

```text
/task-router <your task>
```

Then follow the route it emits. Pass artifacts between agents instead of copying transcripts.

### Example

```text
.task
  ↓
contract.md
  ↓
repo-scout → facts.md
  ↓
planner    → plan.md
  ↓
builder    → changes.md
  ↓
verifier   → verification.md
  ↓
reviewer   → review.md
```

## Active task

`ACTIVE` contains the current task ID and enables the optional Stop verification hook.
Delete or clear it when the task is fully integrated.

## Hook philosophy

Hooks do deterministic work only. The post-edit hook checks Python syntax. The stop hook is opt-in via `VERIFY_ON_STOP=1` in `ACTIVE` and blocks on `git diff --check` or explicit `COMMAND:` lines found in the task's `verification.md`.

## v0.1 limitations

- The router is intentionally prompt-driven rather than a custom daemon.
- Artifact validation is schema-defined but not automatically enforced by a separate validator yet.
- The builder does not force worktree isolation by default; use worktrees for genuinely parallel implementation streams.
