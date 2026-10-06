# Claude Code Context Management: Step-by-Step Implementation Guide

Oct 5, 2026 · @Novel

## Overview

The goal is a main session that stays under \~50% context with mostly high-signal tokens, and that can recover its full working state from disk in under 5K tokens after any `/clear` or compaction.

The steps follow the priority order from highest to lowest leverage: isolate noisy work in subagents, write durable state to files, load knowledge only when needed, and compress only as a last resort. Steps 1–9 apply to any Claude Code repo; Step 10 helps large or dynamic-language repos; Step 11 is only for harnesses you build on the Agent SDK or API.

End state of the repo:

```
repo/
├── CLAUDE.md                     # lean root: <150 lines
├── src/<module>/CLAUDE.md        # subsystem notes, loaded when working there
├── .claude/
│   ├── settings.json             # hooks
│   ├── agents/explorer.md        # read-only exploration subagent
│   ├── skills/<name>/SKILL.md    # on-demand procedures
│   ├── commands/handoff.md       # /handoff
│   ├── commands/reflect.md       # /reflect
│   └── hooks/                    # pre-compact + session-start scripts
└── .agent/
    ├── progress.md               # current state, rewritten each handoff
    │   (no task file)            # tasks: built-in Tasks, ~/.claude/tasks
    └── lessons.md                # append-only playbook from /reflect
```

Exact file formats and hook fields can change between Claude Code releases, so check the current docs if a config is rejected.

Companion docs: Planning and Task Workflow for Claude Code (planning, tasks, specs) and Code Quality and Cognitive Debt Playbook for Claude Code (quality gates, cognitive debt). Hooks and CLAUDE.md blocks from all three are designed to be combined.

## Step 1: Measure the baseline

Record where your tokens go before changing anything, so you can tell which later steps actually helped.

1. Start a fresh session in your main repo and run `/context` before typing anything. Note the fixed overhead: system prompt, tool definitions, MCP tools, memory files.
2. Do one typical task (a bug fix or small feature) and run `/context` again at the end.
3. Write the numbers down in a scratch table like the one below.

| Measure | Baseline | After rollout |
| --- | --- | --- |
| Fixed overhead at session start (tokens) |  |  |
| MCP tool definitions (tokens) |  |  |
| Memory files / CLAUDE.md (tokens) |  |  |
| Context used at end of a typical task (%) |  |  |
| Auto-compactions per long session |  |  |
| Times the agent re-read the same file |  |  |

Rule of thumb: if fixed overhead is above \~15% before you type, Steps 2, 3 and 9 matter most. If tasks routinely end above 70%, Steps 4–7 matter most.

## Step 2: Restructure CLAUDE.md

CLAUDE.md loads on every request and survives every compaction, so every line in it costs tokens on every turn. Keep only what applies to almost every task.

1. Cut the root file to under \~150 lines. Keep build/test commands, repo map, hard conventions, and the state-file protocol. Move anything else out.
2. Put subsystem details in nested files such as `src/<module>/CLAUDE.md`. Claude Code loads these when it works in that directory.
3. Use `@path` imports for reference docs that are needed often but not always, e.g. `@docs/architecture.md`. Prefer Skills (Step 3) for anything procedural.
4. Add a compaction section so auto-compact keeps what matters.

Template for the root file:

```markdown
# Project: <name>

## Commands
- Build: <e.g. `make build`, `npm run build`, `go build ./...`, `cargo build`>
- Test (fast): `.claude/quality.sh test-fast` or <e.g. `npm test`, `go test -short ./...`>
- Test (single): <e.g. `pytest path::name`, `npx vitest run -t name`, `go test -run Name ./pkg`>
- Lint + types: `.claude/quality.sh typecheck` or <e.g. `npm run lint`, `golangci-lint run`>

## Repo map
- src/<module_a>/  — <one line>
- src/<module_b>/  — <one line>
- scripts/         — <one line>

## Conventions (non-negotiable)
- <rule 1>
- <rule 2>

## Working state protocol
- At session start, read .agent/progress.md and check the open Tasks.
- Use the `explorer` subagent for any search touching more than 3 files.
- Commit after each completed task with a descriptive message.
- Before stopping or when asked, run /handoff.

## Compact instructions
When compacting, always preserve:
- Exact file paths created or modified, and why
- Failing test names and the exact error lines
- The current hypothesis and what has been ruled out
- Decisions made and the reason for each
Discard: full file contents, raw grep/ls output, passing test logs.
```

Check: run `/context` in a fresh session. Memory files should now be a small share of the window.

The other two docs add blocks to this file. Keep the root to what applies everywhere (workflow tiers, execution rules, the ownership levels and Core rules). The Core rules and the debugging protocol stay in the root, because a session that works in `tests/` may never load a nested file (Playbook, Steps 7 and 9). Use a nested CLAUDE.md only for a rule that matters only while Claude edits that folder.

## Step 3: Move on-demand knowledge into Skills

Skills use progressive disclosure: only the name and description sit in context until the skill is invoked, so long procedures cost almost nothing when unused.

1. List the procedures you cut from CLAUDE.md in Step 2: release steps, running experiments or benchmarks, database migrations, adding a new API endpoint, environment quirks.
2. Create one folder per procedure under `.claude/skills/`.
3. Write a precise `description`, since it is the only part Claude sees when deciding whether to load the skill.
4. Put long references in sibling files the skill points to, so even an invoked skill loads only what it needs.

Example `.claude/skills/run-experiment/SKILL.md`:

```markdown
---
name: run-experiment
description: Use when running, comparing or logging an offline experiment
  (training, evaluation, simulation). Covers config layout, seeds,
  result logging and how to compare against the current baseline.
---

# Running an experiment

1. Copy configs/base.yaml to configs/exp/<short-name>.yaml and edit only the changed keys.
2. Run: `make experiment CONFIG=configs/exp/<short-name>.yaml SEEDS="0 1 2"`
3. Results land in results/<short-name>/. Never overwrite another run's folder.
4. Compare: `make compare A=results/baseline B=results/<short-name>`
5. Append one line to results/LOG.md: name, metric delta, verdict (not progress.md, which is rewritten at each handoff).

For metric definitions see metrics.md in this folder (read only if needed).
```

Check: ask Claude a question the skill covers and confirm it loads the skill on its own.

## Step 4: Create exploration subagents

This is the highest-leverage step: a subagent burns its own context on searching and reading, and the main session receives only a short report.

1. Create `.claude/agents/explorer.md` with read-only tools so it cannot make edits.
2. Fix the output format in its prompt. A structured, size-capped report is what keeps the main context clean.
3. Optionally add a second agent for log or test-output analysis, which is the other big source of noise.
4. Reference the agent in CLAUDE.md (done in Step 2) so the main session uses it by default.

Example `.claude/agents/explorer.md`:

```markdown
---
name: explorer
description: Read-only codebase investigator. Use proactively for any search,
  "where is X", "how does Y work", or reading more than 3 files.
tools: Read, Grep, Glob, Bash
---

You investigate the codebase and report back. You never edit files.
Only use Bash for read-only commands (git log, git grep, ls, wc).

Return at most 400 words in exactly this format:

## Answer
<2-4 sentences answering the question>

## Key locations
- path/to/file:L120-L180 — <what is there>

## Facts the caller needs
- <signatures, config keys, invariants, gotchas>

## Not checked
- <anything you skipped or were unsure about>

Never paste whole files. Quote at most 15 lines of code total.
```

Example `.claude/agents/log-analyst.md` follows the same pattern, with a format of: failing tests, first error line per failure, suspected cause, and files involved.

Check: ask the main session "how is X implemented?" and confirm it delegates. The main context should grow by about the size of the report, not the size of the files read.

## Step 5: Set up durable state files

The working state of a task should live on disk, not in the conversation, so that losing the conversation costs nothing.

1. Create `.agent/progress.md`. It is rewritten (not appended) at each handoff and stays under \~60 lines.
2. Track tasks with Claude Code's built-in Tasks instead of a file. They support dependencies, persist across compaction and `/clear`, and can be shared across sessions with `CLAUDE_CODE_TASK_LIST_ID`. Setup is in the companion workflow doc linked below.
3. Commit after every completed task. `git log --oneline -20` then becomes a free, exact history.
4. Add a `/handoff` command that writes all of the above in one step.

Template `.agent/progress.md`:

```markdown
# Progress — updated <date>

## Current goal
<one sentence>

## Done this session
- <change> (commit abc123)

## In progress
- <task id>: <exact state, next concrete action>

## Current hypothesis / ruled out
- Hypothesis: <...>
- Ruled out: <...> because <evidence>

## Key files
- path/to/file — <why it matters>

## Open questions
- <...>
```

**Planning and task workflow.** When to plan, when to write a spec, and how to run multi-session features on a shared task list are covered in a separate doc: Planning and Task Workflow for Claude Code

In short: small tasks get no plan and no task list, multi-session features get a \~2-page spec plus shared Tasks, and big projects are decomposed one milestone at a time.

Command `.claude/commands/handoff.md`:

```markdown
---
description: Write current working state to disk before clearing or stopping
---

0. Run: touch .agent/.skip-gate  (lets the Stop gate pass while state is written;
   session-start.sh removes it)
1. Rewrite .agent/progress.md using its existing section headings. Be exact:
   file paths, test names, error lines, commit hashes. Max 60 lines.
2. Update the status of the current Tasks. Do not delete or rename tasks.
3. Commit any finished work with a descriptive message.
4. Reply with one line: "Handoff written — safe to /clear."
```

Check: run `/handoff`, then `/clear`, then say "continue". The new session should resume correctly from the files alone.

## Step 6: Wire hooks as a safety net

Hooks catch the cases where you forgot to `/handoff`: a PreCompact hook snapshots mechanical state before compaction, and a SessionStart hook re-injects state after compaction or `/clear`.

A hook runs a shell script, not the model, so it cannot write a thoughtful progress.md. It can save git state and a transcript copy, and it can print files back into context. That is why `/handoff` stays the primary path.

1. Create the two scripts below and `chmod +x` them. They need `jq` installed.
2. Register them in `.claude/settings.json`.
3. Add `.agent/snapshots/` to `.gitignore`.

`.claude/settings.json`:

```json
{
  "hooks": {
    "PreCompact": [
      { "matcher": "auto",
        "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/pre-compact.sh" }] }
    ],
    "SessionStart": [
      { "matcher": "startup",
        "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/session-start.sh" }] },
      { "matcher": "compact",
        "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/session-start.sh" }] },
      { "matcher": "clear",
        "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/session-start.sh" }] }
    ]
  }
}
```

`.claude/hooks/pre-compact.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
input=$(cat)
cd "$CLAUDE_PROJECT_DIR"
mkdir -p .agent/snapshots
ts=$(date +%Y%m%d-%H%M%S)

# Keep the full uncompacted transcript in case you need to dig into it later
transcript=$(echo "$input" | jq -r '.transcript_path // empty')
[ -n "$transcript" ] && cp "$transcript" ".agent/snapshots/$ts.jsonl"

# Mechanical state that compaction summaries often blur
{
  echo "# Pre-compact snapshot $ts"
  echo "## Uncommitted changes"; git status --short
  echo "## Diff stat"; git diff --stat
  echo "## Recent commits"; git log --oneline -10
} > .agent/snapshot.md
```

`.claude/hooks/session-start.sh` (its stdout is added to the new session's context):

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$CLAUDE_PROJECT_DIR"
rm -f .agent/.skip-gate   # re-enable the Playbook's Stop gate after a handoff
echo "=== Restored working state ==="
[ -f .agent/progress.md ] && head -c 6000 .agent/progress.md
echo; echo "=== Tasks ==="
echo "Built-in Tasks persist across compaction; list the open ones before continuing."
echo; echo "=== Git ==="
[ -f .agent/snapshot.md ] && head -c 3000 .agent/snapshot.md || git log --oneline -5
```

The `head -c` limits keep re-injection to roughly 2–3K tokens. Without a cap, recovery can refill the context you just freed.

Check: run `/compact` manually, then ask "what are we working on?". The answer should match progress.md exactly.

## Step 7: Adopt the proactive clear workflow

Clear at natural breakpoints around 50% context instead of letting auto-compact fire near the limit. A clean restart from good files beats a lossy summary of a noisy session.

1. Make the context meter visible. `/context` works on demand; a custom status line that shows context % is better for long sessions.
2. At each breakpoint, run `/handoff` then `/clear`. Breakpoints are: a task marked done, a hypothesis confirmed or ruled out, or switching subsystems.
3. Start the next task with one short prompt such as "Continue with T3." The SessionStart hook supplies the state.
4. When you must compact instead of clear (mid-task, state not yet written), steer it: `/compact keep the failing test output for test_parse_dates and the list of files edited`.
5. Use one session per task. Do not reuse a session that holds a finished task's debugging history for unrelated work.

The decision at each breakpoint:

| Situation | Action |
| --- | --- |
| Task done, state written | `/handoff` → `/clear` |
| Mid-task, above \~50%, much stale tool output | `/handoff` → `/clear` → "continue" |
| Mid-task, the exact recent details matter | `/compact <what to keep>` |
| Different subsystem or unrelated task | New session |
| Context below \~40% and on track | Keep going |

## Step 8: Add an ACE-style reflection loop

After a task, especially a failed or slow one, distill reusable lessons as small delta bullets into an append-only playbook. This follows the ACE pattern (generator, reflector, curator) and avoids the "context collapse" that comes from repeatedly rewriting one summary.

1. Create `.agent/lessons.md` with sections such as Traps, Commands, Patterns that work.
2. Import it from the root CLAUDE.md with `@.agent/lessons.md` once it proves useful. Until then, keep it out of context.
3. Add the `/reflect` command below and run it after each task.
4. Review proposed bullets before accepting. You are the curator, which keeps wrong lessons out.
5. Prune when `/reflect` reports more than 30 bullets: merge duplicates, delete bullets that never helped, move mature ones into CLAUDE.md or a Skill.

Command `.claude/commands/reflect.md`:

```markdown
---
description: Distill reusable lessons from the task just finished
---

Review this session. Propose at most 5 new bullets for .agent/lessons.md.
If the file does not exist, create it with three headings: Traps, Commands,
Patterns that work.

Rules:
- Each bullet is one line, specific and actionable:
  "When <situation>, do <action> because <reason>."
- Only lessons likely to recur in future tasks. No task-specific status.
- Project technical lessons only. My working preferences go to auto memory.
- If the file has more than 30 bullets, first propose merges and deletions,
  then new bullets.
- Check existing bullets first. If a lesson refines one, propose an edit
  to that bullet instead of a new one.
- Never rewrite or reorder the file.

Show the proposed bullets and wait for my approval before writing.
```

Example of a good bullet: "When a test that uses randomness is flaky, check that the seed is passed in explicitly, because the default is time-based."

Keep lessons.md to reusable "when X, do Y" bullets. Feature summaries and design intent go to `docs/decisions/` (see the workflow doc), because lessons.md may be imported into every session.

## Step 9: Control tool and MCP bloat

Tool definitions and noisy tool outputs are fixed costs you pay on every turn, so trim them at the source.

1. Disable MCP servers you are not using in this repo. Use `/mcp` to see them, and keep project-specific servers in the project's `.mcp.json` rather than your global config.
2. Leave tool search on. Claude Code auto-enables it when MCP tools would use more than \~10% of context. The `ENABLE_TOOL_SEARCH` environment variable controls it; check the docs for current values.
3. Make commands quiet by default. Add to CLAUDE.md, for example: run tests in quiet mode with short failure output (`pytest -q --tb=short`, `vitest --reporter=dot`, `go test ./...` without `-v`, `cargo test -q`), pipe long output through `tail -50`, never `cat` files over 300 lines (use Read with a line range).
4. Send large outputs to files. For long-running jobs such as builds, full test suites or training runs, write to `logs/` and have the log-analyst subagent read them.
5. Re-run `/context` and compare against your Step 1 baseline.

**Optional: automate quiet output with RTK.** RTK (Rust Token Killer) is a CLI proxy that hooks Claude Code's Bash tool and returns filtered output for 100+ common commands: git, test runners, builds, linters, `ls`/`find`. Its 60–90% savings figure is the project's own estimate, so measure on your repo first.

```bash
brew install rtk                 # or: cargo install --git https://github.com/rtk-ai/rtk
rtk --version && rtk gain        # must show token stats, else you installed the wrong "rtk"
rtk discover                     # estimate savings from your past Claude Code sessions
rtk init -g                      # install the Bash hook, then restart Claude Code
```

Things to know before relying on it:

- Do not run `cargo install rtk` from crates.io. That name belongs to a different project (Rust Type Kit).
- Built-in Read, Grep and Glob do not pass through the Bash hook, so their output is not compressed.
- Filtering is lossy by design. If a test failure or build error looks truncated, rerun that command unfiltered for the debugging pass (see RTK's README for how to bypass the rewrite).
- Your own scripts and custom tools have no RTK filter. Keep writing their logs to `logs/` and reading them with the log-analyst subagent.

Subagents that must see exact output, such as the Playbook's reviewer reading a diff, should write it to a file and read it with the Read tool, which RTK does not filter.

## Step 10: Add structural code navigation

Give the agent exact symbol queries (definitions, references, call sites) as on-demand tools, built mechanically from the code. Do not build an LLM-extracted knowledge graph of the codebase.

Do this step if any apply: a large repo or monorepo, a dynamic language where names are ambiguous (Python, JS), frequent signature changes or refactors. Otherwise grep plus the explorer subagent is enough, and you can skip it.

1. Add an LSP-backed MCP server. Serena is the most widely used option. Install it from PyPI with uv, not from an MCP or plugin marketplace, whose commands are often outdated. Check its README for current flags:

```bash
# Install (recommended path: PyPI via uv)
uv tool install -p 3.13 serena-agent@latest --prerelease=allow
serena init

# Register with Claude Code, run from the repo root
claude mcp add serena -- serena start-mcp-server --project "$(pwd)"
```

If your Claude Code version offers built-in LSP support for your language, prefer that and skip the extra server.

For TypeScript/JavaScript repos, exclude `node_modules` from indexing in Serena's project config. With default settings the language server indexes it, and the cache can grow to gigabytes. Measure task success and `/context` before and after; keep Serena only if structural queries were a real pain point.

Use Serena for navigation only, and disable its editing tools in Serena's configuration (check its docs for the option). Edits made through them bypass the Write/Edit hooks that format, lint and protect tests in the Playbook, and those hook scripts could not read their inputs anyway.

2. Give the symbol tools to the explorer subagent from Step 4, so graph queries happen in its context, not the main one. Extend its `tools` line, using the exact tool names `/mcp` shows:

```markdown
tools: Read, Grep, Glob, Bash, mcp__serena__find_symbol,
  mcp__serena__find_referencing_symbols, mcp__serena__get_symbols_overview
```

3. Add routing rules to the root CLAUDE.md:

```markdown
## Code navigation
- Definitions, references, call sites, "what breaks if I change X": use symbol tools.
- Strings, config keys, log messages, comments, non-code files: use grep.
- Before changing a public function's signature, list its references first.
```

4. Optionally, generate a compact repo map that the explorer reads first. Cap it at \~300 lines and regenerate it rather than editing it by hand. Keep it out of CLAUDE.md. This version works for any language universal-ctags supports:

```bash
#!/usr/bin/env bash
# scripts/repo_map.sh — writes .agent/repo-map.md (needs universal-ctags)
{
  echo "# Repo map (generated, do not edit)"
  ctags -R -x --sort=no --exclude=node_modules --exclude=vendor --exclude=target \
        --exclude=dist --exclude=.venv src \
    | awk '$2 ~ /^(function|func|method|class|struct|interface|trait|type)$/ \
           { print $4 ": " $2 " " $1 }' \
    | sort -u
} | head -300 > .agent/repo-map.md
```

Run it from a git `post-commit` hook so it never goes stale. Symbol kind names differ slightly per language; if a language's symbols are missing, check `ctags --list-kinds=<Language>` and extend the `awk` filter.

5. Keep "why" knowledge (design intent, trade-offs, rejected approaches, experiment results) in `lessons.md` and decision records, not in a graph. That knowledge is not in the code, so a code graph cannot hold it, and an LLM-extracted one will go stale.

Check: ask "what calls `<some function>`?". The explorer should answer with symbol tools, the list should match a careful grep, and the main context should grow only by the report.

## Step 11 (optional): Context editing and memory tool in your own harness

If you build agents on the Claude Agent SDK or the Messages API, you can get the same benefits server-side. Combine automatic clearing of old tool results (observation masking) with the file-based memory tool.

1. Enable context editing so old tool results are cleared once input passes a threshold, keeping the most recent few.
2. Enable the memory tool and implement its file operations (view, create, str\_replace, insert, delete, rename) against a sandboxed directory.
3. Tell the model in the system prompt to check memory at the start and write progress there before context runs out.
4. Keep a subagent pattern for exploration, the same as Step 4.

Sketch with the Python SDK; the TypeScript SDK accepts the same fields (identifiers were current as of mid-2026; verify against the docs before use):

```python
import anthropic

client = anthropic.Anthropic()

resp = client.beta.messages.create(
    model="claude-sonnet-5-5",
    max_tokens=4096,
    betas=["context-management-2025-06-27"],
    tools=[
        {"type": "memory_20250818", "name": "memory"},
        # ... your code tools (read_file, grep, run_tests)
    ],
    context_management={
        "edits": [{
            "type": "clear_tool_uses_20250919",
            "trigger": {"type": "input_tokens", "value": 60_000},
            "keep": {"type": "tool_uses", "value": 4},
            "exclude_tools": ["memory"],
        }]
    },
    system=(
        "At the start of each task, view /memories. Before your context "
        "fills, write progress, decisions and next steps to /memories/progress.md."
    ),
    messages=messages,
)
```

Excluding the memory tool from clearing keeps the agent's own notes visible while bulky file reads and test logs are dropped.

## Rollout order and verification

Roll out in three short phases so you can see which change moved which number in your Step 1 table.

| Phase | Steps | Effort | What should improve |
| --- | --- | --- | --- |
| 1. Foundations | 1, 2, 4, 5 | \~1 hour | Lower fixed overhead; main context grows slower |
| 2. Recovery | 6, 7 | \~1 hour | Fewer auto-compactions; clean resumes after `/clear` |
| 3. Refinement | 3, 8, 9, 10 | Ongoing | Less re-learning across sessions; less tool noise |
| Optional | 11 | Per harness | Same gains in your own SDK/API agents |

Verification checklist:

- [ ] Fresh-session overhead re-measured with `/context` and lower than baseline
- [ ] Root CLAUDE.md under \~150 lines, with compact instructions
- [ ] Main session delegates a codebase question to `explorer` without being told
- [ ] `/handoff` → `/clear` → "continue" resumes the task correctly from files alone
- [ ] Manual `/compact` followed by "what are we working on?" matches progress.md
- [ ] Re-injected state after compact or clear is under \~3K tokens
- [ ] At least one Skill loads on its own when relevant
- [ ] `/reflect` produced bullets you approved, and lessons.md has no duplicates
- [ ] A full long task completes with zero auto-compactions
