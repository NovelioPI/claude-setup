# Guardrails

The hooks and permission rules that block destructive actions, and their known gaps.

## Destructive git

Two layers guard the destructive commands, and the overlap is on purpose.

`hooks/block-dangerous-git.sh` runs as a `PreToolUse` hook on every Bash call and exits 2 to block. It guards `git reset --hard`, `git clean` with a force flag, `git branch -D`, a whole-tree `git checkout` or `git restore`, and `git push` with `--force`, `-f`, or a `+` refspec. It matches each chained segment at its own start, so a guarded string quoted inside another command does not trip it. A prefix such as `sudo`, `env`, `rtk`, or a full git path does not skip it. Without `jq` it blocks every Bash call, by design.

A plain `git push` is **not** guarded, on purpose. A guardrail that blocks a command you use every day teaches you to route around the guardrail. `--force-with-lease` also passes, because it refuses to overwrite unseen commits.

The `permissions.deny` list in `settings.json` is the second layer. It repeats `git reset --hard` and `git clean` with a dash followed later by an `f`, such as `-dfx`, so they stay blocked if the hook file goes missing. It also blocks a dry run whose path holds an `f`, such as `git clean -n -- fixtures`.

## Recoverable deletes

`hooks/snapshot-guard.sh` runs before `rm`, `git stash`, `git restore`, `git checkout`, `git clean`, `git reset`, and `git rm`. It saves the working tree, untracked files included, to `refs/claude/snapshots/<time>`, then allows the command with no prompt. Undo with `git restore --source=<ref> -- <path>`, which leaves the index alone. It keeps the last 50 snapshots in each repo. An `rm` under `/tmp` runs with no snapshot.

It fails closed. A command with a delete word anywhere (`rm`, `unlink`, `shred`, `eval`, `-delete`, or `git` with a risky subcommand) is allowed only in a form the hook parses: a plain `rm` or `git` command, after plain `cd`, `;`, `|`, `&&`, or `&`. It asks for every other form: `( )`, `{ }`, `$`, a backslash, `!`, a backtick, a heredoc, a quote across lines, `bash -c`, `sudo`, `xargs`, `env`, `find -delete`, or a delete word anywhere else, such as in a commit message. It also asks when a snapshot cannot undo the command: a target outside a repo, a symlink, a git-ignored file or a folder holding one, `git stash drop` or `clear`, `git stash -a`, `git clean -x`, `git -C` or `git -c`, a revision that tracks an ignored local file such as `.env`, or any `cd` other than `cd <one path>`, including `pushd`. The snapshot clears skip-worktree and assume-unchanged bits in its own index copy, so it holds edits to those files too. `scripts/test-snapshot-guard.sh` covers each case, and `scripts/install.sh` runs it.

`scripts/install.sh` tests both directions of the guard on every run.

## Quality adapter

An executable `.claude/quality.sh` in a project replaces `scripts/quality.sh` for that project. The hooks use it only when git tracks it and it is unchanged from HEAD. It must give all three subcommands: `format <file>`, `lint <file>`, and `check <files...>`. Both guards always protect it, so Claude cannot edit or commit it. A committed adapter in a cloned repo runs on every edit with no prompt.

## Protected paths

`.claude/protected-paths` in a project holds one glob per line, relative to the project, where `*` also matches `/`. A line with no wildcard, such as `tests/conftest.py`, also blocks creating that file. A project with no list protects only the adapter, so Claude can edit test files. The commit gate also checks unstaged changes, so a changed protected file, including one you edited, blocks every commit made through Claude until you restore or commit it yourself. To change a listed file, edit it yourself. A gate that runs past its 300-second timeout lets the action go through.

## Known gaps

- `commit-gate.sh` matches commit commands by pattern. Forms such as `{ git commit; }`, `timeout 60 git commit`, a git alias, `merge`, and `rebase` get past it.
- Both guards check the project in `CLAUDE_PROJECT_DIR`, not a repo named by `git -C` or `cd`.
- `snapshot-guard.sh` prompts for any mention of a delete word, such as `git commit -m "fix rm bug"`. Parsers that tried to tell quoted text from code missed real deletes after a comment, `$'...'`, a subshell, or `eval`.
- `snapshot-guard.sh` does not see an `rm` inside a script, a Makefile, or a split word such as `r''m`. Those calls go through the normal permission mode. It guards against mistakes, not against a deliberate bypass.
- A large untracked file is copied into `.git` on each snapshot.
- On a case-insensitive drive such as `/mnt/c`, a path with different letter case gets past `protect-signal.sh`.
- `stop-gate.sh` keeps its last result in `claude-stop-gate` in the git dir. A change to a git-ignored file, a tool, `.venv`, or `node_modules` does not rerun it.
- `scripts/quality.sh` runs `ruff check --fix` and `ktlint -F` even with no project config.
