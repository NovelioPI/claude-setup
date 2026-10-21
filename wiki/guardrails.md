# Guardrails

The hooks and permission rules that block destructive actions, and their known gaps.

## Destructive git

Two layers guard the destructive commands, and the overlap is on purpose.

`hooks/block-dangerous-git.sh` runs as a `PreToolUse` hook on every Bash call and exits 2 to block. It guards `git reset --hard`, `git clean` with a force flag, `git branch -D`, a whole-tree `git checkout` or `git restore`, and `git push` with `--force`, `-f`, or a `+` refspec. It matches each chained segment at its own start, so a guarded string quoted inside another command does not trip it. A prefix such as `sudo`, `env`, `rtk`, or a full git path does not skip it. Without `jq` it blocks every Bash call, by design.

A plain `git push` is **not** guarded, on purpose. A guardrail that blocks a command you use every day teaches you to route around the guardrail. `--force-with-lease` also passes, because it refuses to overwrite unseen commits.

The `permissions.deny` list in `settings.json` is the second layer. It repeats `git reset --hard` and `git clean` with a dash followed later by an `f`, such as `-dfx`, so they stay blocked if the hook file goes missing. It also blocks a dry run whose path holds an `f`, such as `git clean -n -- fixtures`.

## Quality adapter

An executable `.claude/quality.sh` in a project replaces `scripts/quality.sh` for that project. The hooks use it only when git tracks it and it is unchanged from HEAD. It must give all three subcommands: `format <file>`, `lint <file>`, and `check <files...>`. Both guards always protect it, so Claude cannot edit or commit it. A committed adapter in a cloned repo runs on every edit with no prompt.

## Protected paths

`.claude/protected-paths` in a project holds one glob per line, relative to the project, where `*` also matches `/`. A line with no wildcard, such as `tests/conftest.py`, also blocks creating that file. A project with no list protects only the adapter, so Claude can edit test files. The commit gate also checks unstaged changes, so a changed protected file, including one you edited, blocks every commit made through Claude until you restore or commit it yourself. To change a listed file, edit it yourself. A gate that runs past its 300-second timeout lets the action go through.

## Ignored paths

The lint, check, and suppression gates skip `.claude/skills/` and each glob in `.claude/quality-ignore`, one per line. A skill script often uses another language, so the project's tools fail on it. Python checks also run only with `pyproject.toml`, `setup.py`, `setup.cfg`, or `mypy.ini`, and Dart checks only with `pubspec.yaml`. Both guards protect the ignore list, so only you can edit it.

## Known gaps

- `commit-gate.sh` matches commit commands by pattern. Forms such as `{ git commit; }`, `timeout 60 git commit`, a git alias, `merge`, and `rebase` get past it.
- Both guards check the project in `CLAUDE_PROJECT_DIR`, not a repo named by `git -C` or `cd`.
- No hook guards `rm`, `git stash`, or `git restore`. They go through the normal permission mode, and `/rewind` restores only edits made by the edit tools.
- On a case-insensitive drive such as `/mnt/c`, a path with different letter case gets past `protect-signal.sh`.
- `stop-gate.sh` keeps its last result in `claude-stop-gate` in the git dir. A change to a git-ignored file, a tool, `.venv`, or `node_modules` does not rerun it.
- `scripts/quality.sh` runs `ruff check --fix` and `ktlint -F` even with no project config.
