# Build plan: agent workflow v2

This file drafts the GitHub issues and the milestone that build the decisions in `brainstorm-agent-workflow.md`.

Nothing here exists on GitHub yet. Creating the issues publishes them, because `claude-setup` is public.

## Milestone

| Field | Value |
|---|---|
| Name | v2: issue-based task loop |
| Goal | A task moves from a GitHub issue to a verified commit, locally or in a cloud run |
| Exit command | `bash scripts/v2-exit.sh`, built by W16 |
| Issues | W1 to W16 |

## Conventions

These conventions apply to every draft below.

| Item | Rule |
|---|---|
| Draft ID | `W<n>`. GitHub gives the real number at creation |
| Contract | The issue body holds goal, scope, non-goals, acceptance command, hints, and unknowns (D6) |
| Labels | `value:1-3`, `effort:S/M/L`, `risk:*` |
| Docs | A change that makes `README.md` wrong updates it in the same commit |
| Paths | The plugin lives in `plugin/`. `plugins/` is ignored by git and belongs to Claude Code |

The risk scale reuses the gate ladder from `research-loop-engineering.md` §3 (D16).

| Label | Meaning | Gate |
|---|---|---|
| `risk:auto` | Reversible, and the acceptance command decides | auto |
| `risk:ask` | Touches an invariant, such as the approval protocol | human, per issue |
| `risk:human` | No recovery path, such as publishing | human, always |

## Order

| Stage | Issues | Reason |
|---|---|---|
| 1 Defects | W1–W4 | Small fixes. The loop runs on these files |
| 2 Protocol | W5 | The implementer must act under the milestone token before any loop runs |
| 3 Contract | W6–W9 | The issue format, its gate, and the task folder |
| 4 Agents and skills | W10–W13 | They read the contract from stage 3 |
| 5 Distribution | W14–W15 | Plugin, rule sync, and the cloud workflow |
| 6 Exit | W16 | Runs every acceptance command |

## Draft issues

### W1 — Remove Glob and Grep from the implementer's tools

| Field | Value |
|---|---|
| Labels | `value:3` `effort:S` `risk:auto` |
| Goal | The implementer lists only tools that exist on Linux and WSL (X3) |
| Scope | `agents/implementer.md` |
| Non-goals | Changing the reviewer's tools |
| Acceptance | `! grep -E '^tools:.*\b(Glob\|Grep)\b' agents/implementer.md` |
| Hints | `agents/implementer.md`, frontmatter `tools:` |
| Unknowns | none |
| Depends on | — |

### W2 — Replace `maxBudgetUsd` in `milestone-run`

| Field | Value |
|---|---|
| Labels | `value:2` `effort:S` `risk:auto` |
| Goal | The Budget section names a mechanism the CLI has (X2) |
| Scope | `skills/milestone-run/SKILL.md` |
| Non-goals | Adding a budget hook |
| Acceptance | `! grep -q maxBudgetUsd skills/milestone-run/SKILL.md` |
| Hints | `skills/milestone-run/SKILL.md`, section `## Budget` |
| Unknowns | Whether `--max-budget-usd` in print mode fits an interactive milestone run |
| Depends on | — |

### W3 — Drop the "read MEMORY.md" instruction

| Field | Value |
|---|---|
| Labels | `value:3` `effort:S` `risk:ask` |
| Goal | `CLAUDE.md` stops telling the agent to load what the harness already loads (X4) |
| Scope | `CLAUDE.md` |
| Non-goals | Changing auto memory settings |
| Acceptance | `! grep -q 'read MEMORY.md' CLAUDE.md` |
| Hints | `CLAUDE.md`, section `## Memory` |
| Unknowns | none |
| Depends on | — |

### W4 — Measure whether `@rules/` imports load the rules twice

| Field | Value |
|---|---|
| Labels | `value:2` `effort:S` `risk:auto` |
| Goal | Find out if `rules/` loads twice: once by auto-load, once by `@` import (X5) |
| Scope | `scripts/probe-context-floor.sh`, `CLAUDE.md` |
| Non-goals | Moving rules, which W15 does |
| Acceptance | `bash scripts/probe-context-floor.sh` exits 0 and prints a duplicate-load line |
| Hints | `scripts/probe-context-floor.sh`, the `MARKER` canary |
| Unknowns | Whether a canary can detect a double load |
| Depends on | — |

### W5 — Let a dispatched agent act under the milestone token

| Field | Value |
|---|---|
| Labels | `value:1` `effort:S` `risk:ask` |
| Goal | The implementer acts on a listed issue without waiting for "Go" (D8, X1) |
| Scope | `CLAUDE.md`, `guides/agent-brief.md` |
| Non-goals | Any change to how the main session gets a token |
| Acceptance | `grep -q 'dispatched' CLAUDE.md && grep -q 'milestone token' guides/agent-brief.md` |
| Hints | `CLAUDE.md`, sections `## Approval Protocol` and `## Conversation Flow` |
| Unknowns | The exact wording. It must cover listed issues only |
| Depends on | — |

### W6 — Add the task issue form and labels

| Field | Value |
|---|---|
| Labels | `value:1` `effort:S` `risk:auto` |
| Goal | A human files a task with every contract field (D6, D7) |
| Scope | `plugin/templates/ISSUE_TEMPLATE/task.yml`, `scripts/labels.sh` |
| Non-goals | Applying labels to any repo in this issue |
| Acceptance | `uvx yamllint -d relaxed plugin/templates/ISSUE_TEMPLATE/task.yml` |
| Hints | [GitHub issue forms](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms) |
| Unknowns | yamllint checks YAML syntax, not GitHub's issue form schema (D17) |
| Depends on | — |

### W7 — Write the contract check script

| Field | Value |
|---|---|
| Labels | `value:1` `effort:M` `risk:auto` |
| Goal | A script exits non-zero when an issue lacks a contract field (D7) |
| Scope | `scripts/contract-check.sh`, `tests/contract/` |
| Non-goals | Validating the text inside a field |
| Acceptance | `bash scripts/contract-check.sh --self-test` |
| Hints | `gh issue view <n> --json body,labels` |
| Unknowns | none |
| Depends on | W6 |

### W8 — Define the task folder and its close step

| Field | Value |
|---|---|
| Labels | `value:1` `effort:M` `risk:auto` |
| Goal | Each task writes reports to `.claude/work/<n>/`. Closing posts the verdict on the issue and deletes the folder (D4, D5) |
| Scope | `scripts/task-close.sh`, `plugin/templates/gitignore-work` |
| Non-goals | Keeping any report after close |
| Acceptance | `bash scripts/task-close.sh --self-test` |
| Hints | `guides/agent-brief.md`, section `### Verdict` |
| Unknowns | none |
| Depends on | W7 |

### W9 — Record the contract fingerprint at dispatch

| Field | Value |
|---|---|
| Labels | `value:2` `effort:S` `risk:auto` |
| Goal | A mid-run edit to the issue body is detected before the verdict (D5) |
| Scope | `scripts/contract-check.sh` |
| Non-goals | Blocking edits on GitHub |
| Acceptance | `bash scripts/contract-check.sh --self-test` covers an edited body and an edited label (D31) |
| Hints | `scripts/contract-check.sh` from W7 |
| Unknowns | none |
| Depends on | W7 |

### W10 — Add the scout agent

| Field | Value |
|---|---|
| Labels | `value:2` `effort:M` `risk:auto` |
| Goal | A cheap read-only agent writes path and symbol hints into the issue body (D9) |
| Scope | `agents/scout.md` |
| Non-goals | Replacing graft, which is milestone M2 |
| Acceptance | `claude plugin validate ./plugin` after W14; before that, the frontmatter check in W16 |
| Hints | `agents/implementer.md` as the format model |
| Unknowns | Whether haiku is strong enough. Measure on three real issues |
| Depends on | W7 |

### W11 — Rewrite `todo-plan` as `issue-plan`

| Field | Value |
|---|---|
| Labels | `value:1` `effort:M` `risk:auto` |
| Goal | The skill creates a milestone and draft issues, not a `TODO.md` (D10) |
| Scope | `skills/issue-plan/`, `skills/todo-plan/` removed, `.gitignore` negation lines, `README.md` |
| Non-goals | Creating issues without a token |
| Acceptance | `test -f skills/issue-plan/SKILL.md && test ! -e skills/todo-plan` |
| Hints | `skills/todo-plan/SKILL.md`, `TEMPLATE.md`, `REFERENCE.md` |
| Unknowns | none |
| Depends on | W6 |

### W12 — Rewrite `todo-update` as `issue-update`

| Field | Value |
|---|---|
| Labels | `value:1` `effort:M` `risk:auto` |
| Goal | Status moves become label and state changes through `gh` (D10) |
| Scope | `skills/issue-update/`, `skills/todo-update/` removed, `.gitignore`, `README.md` |
| Non-goals | The scoreboard `awk` command, which GitHub's milestone view replaces |
| Acceptance | `test -f skills/issue-update/SKILL.md && test ! -e skills/todo-update` |
| Hints | `skills/todo-update/SKILL.md`, sections `## Triggers` and `## Review triggers` |
| Unknowns | How to show `blocked` and `parked`: labels or closed-as-not-planned |
| Depends on | W11 |

### W13 — Point `milestone-run`, the agents, and the brief at issues

| Field | Value |
|---|---|
| Labels | `value:1` `effort:M` `risk:auto` |
| Goal | The loop reads contracts from issues and runs the check from W7 in preflight |
| Scope | `skills/milestone-run/SKILL.md`, `skills/brainstorming/SKILL.md`, `agents/`, `guides/agent-brief.md` |
| Non-goals | Parallel dispatch changes |
| Acceptance | `! grep -rn 'TODO.md' skills agents guides` |
| Hints | `grep -rln 'TODO.md\|todo-plan\|todo-update' skills agents guides` lists the files |
| Unknowns | none |
| Depends on | W7, W8, W10, W12 |

### W14 — Package the plugin

| Field | Value |
|---|---|
| Labels | `value:1` `effort:L` `risk:ask` |
| Goal | Skills, agents, hooks, and output styles install as one plugin (D10) |
| Scope | `plugin/`, `scripts/install.sh`, `README.md` |
| Non-goals | Publishing to a public marketplace |
| Acceptance | `claude plugin validate ./plugin` |
| Hints | [plugins reference](https://code.claude.com/docs/en/plugins-reference) |
| Unknowns | How the local `~/.claude` loads the plugin without a duplicate copy of each skill |
| Depends on | W13 |

`L` means this issue splits before it runs. The split waits until W13 shows the final file set.

### W15 — Sync rules into each repo and warn on drift

| Field | Value |
|---|---|
| Labels | `value:1` `effort:M` `risk:ask` |
| Goal | Rules reach local, Action, and cloud runs through each repo's `.claude/` (D13) |
| Scope | `scripts/sync-rules.sh`, `plugin/hooks/`, `rules/`, `scripts/probe-context-floor.sh` |
| Non-goals | Syncing a repo that did not opt in |
| Acceptance | `bash scripts/sync-rules.sh --self-test` covers a fresh copy and a drifted copy |
| Hints | `scripts/probe-context-floor.sh`, the `EXPECTED` list, which must change |
| Unknowns | Whether the global `CLAUDE.md` protocol then loads twice in a synced repo |
| Depends on | W4, W14 |

### W16 — Write the milestone exit script

| Field | Value |
|---|---|
| Labels | `value:1` `effort:S` `risk:auto` |
| Goal | One command runs every acceptance command above and exits non-zero on the first failure |
| Scope | `scripts/v2-exit.sh` |
| Non-goals | Running anything on GitHub |
| Acceptance | `bash scripts/v2-exit.sh` |
| Hints | Acceptance rows W1 to W15 |
| Unknowns | none |
| Depends on | W1–W15 |

## Not in this milestone

| Item | Where it goes |
|---|---|
| The GitHub Action workflow template and the `@claude` token rule | v3, checked by actionlint (D17), after W14 and W15 prove the plugin and the sync |
| Migrating the 5 old `TODO.md` files | v3. It needs W12's answer on `blocked` and `parked` |
| Code navigation, routing, memory | Milestones M2, M3, M4 in the brainstorm |

## Decisions taken on this plan

| ID | Answer |
|---|---|
| D16 | Risk labels are `risk:auto`, `risk:ask`, and `risk:human` |
| D17 | yamllint checks W6's issue form. actionlint checks v3's workflow |
| D18 | Migration and the Action workflow move to v3. This overrides the migration part of D10 |
| D26 | The issue form has no value, effort, or risk fields. The human sets the labels after filing, and the contract check fails when one is missing |
| D31 | W9 detects a contract change by a fingerprint of the body and labels, not by `updatedAt`. This overrides the `updatedAt` part of D5 |
