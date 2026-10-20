# Guardrails

The hooks and permission rules that block destructive actions, and their known gaps.

## Destructive git

Two layers guard the destructive commands, and the overlap is on purpose.

`hooks/block-dangerous-git.sh` runs as a `PreToolUse` hook on every Bash call and exits 2 to block. It guards `git reset --hard`, `git clean` with a force flag, `git branch -D`, a whole-tree `git checkout` or `git restore`, and `git push` with `--force`, `-f`, or a `+` refspec. It matches each chained segment at its own start, so a guarded string quoted inside another command does not trip it. A prefix such as `sudo`, `env`, `rtk`, or a full git path does not skip it. Without `jq` it blocks every Bash call, by design.

A plain `git push` is **not** guarded, on purpose. A guardrail that blocks a command you use every day teaches you to route around the guardrail. `--force-with-lease` also passes, because it refuses to overwrite unseen commits.

The `permissions.deny` list in `settings.json` is the second layer. It repeats `git reset --hard` and `git clean -f`, so they stay blocked if the hook file goes missing.

## Recoverable deletes

`hooks/snapshot-guard.sh` runs before `rm`, `git stash`, `git restore`, `git checkout`, `git clean`, `git reset`, and `git rm`. It saves the working tree, untracked files included, to `refs/claude/snapshots/<time>`, then allows the command with no prompt. Undo with `git restore --source=<ref> -- <path>`, which leaves the index alone. It keeps the last 50 snapshots in each repo. An `rm` under `/tmp` runs with no snapshot.

It asks instead when a snapshot cannot undo the command: a target outside a repo, a git-ignored file or a folder holding one, `git stash drop` or `clear`, `git -C`, `sudo rm`, `xargs rm`, `find -delete`, or a target hidden by quotes, `$`, or a `cd` it cannot follow. `scripts/test-snapshot-guard.sh` covers each case, and `scripts/install.sh` runs it.

`scripts/install.sh` tests both directions of the guard on every run.

## Quality adapter

An executable `.claude/quality.sh` in a project replaces `scripts/quality.sh` for that project. The hooks use it only when git tracks it and it is unchanged from HEAD. It must give all three subcommands: `format <file>`, `lint <file>`, and `check <files...>`. Both guards always protect it, so Claude cannot edit or commit it. A committed adapter in a cloned repo runs on every edit with no prompt.

## Protected paths

`.claude/protected-paths` in a project holds one glob per line, relative to the project, where `*` also matches `/`. A line with no wildcard, such as `tests/conftest.py`, also blocks creating that file. A project with no list protects only the adapter, so Claude can edit test files. The commit gate also checks unstaged changes, so a changed protected file, including one you edited, blocks every commit made through Claude until you restore or commit it yourself. To change a listed file, edit it yourself. A gate that runs past its 300-second timeout lets the action go through.

## Known gaps

- `commit-gate.sh` matches commit commands by pattern. Forms such as `{ git commit; }`, `timeout 60 git commit`, a git alias, `merge`, and `rebase` get past it.
- Both guards check the project in `CLAUDE_PROJECT_DIR`, not a repo named by `git -C` or `cd`.
- `snapshot-guard.sh` does not see an `rm` inside `bash -c`, a script, or a Makefile. Those calls go through the normal permission mode.
- A large untracked file is copied into `.git` on each snapshot.
- On a case-insensitive drive such as `/mnt/c`, a path with different letter case gets past `protect-signal.sh`.
- `stop-gate.sh` keeps its last result in `claude-stop-gate` in the git dir. A change to a git-ignored file, a tool, `.venv`, or `node_modules` does not rerun it.
- `scripts/quality.sh` runs `ruff check --fix` and `ktlint -F` even with no project config.
