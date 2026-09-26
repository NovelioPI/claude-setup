# Brainstorm: agent workflow v2

This file widens the ideas in `IDEA.md` into features, checked facts, and open decisions.

| Term | Plain meaning |
|---|---|
| bus | A folder where agents leave results for each other, instead of passing them in chat |
| contract | A short file that states one task's goal, scope, and pass condition |
| acceptance command | A shell command whose exit code 0 means the task passed |
| hint | A path and a symbol name that tells a subagent where to start reading |
| orchestrator | The main session: it picks work, dispatches agents, and decides |

## Subsystems

The idea holds four independent subsystems. This file widens A only. B, C, and D become later milestones.

| # | Subsystem | IDEA items | Depends on |
|---|---|---|---|
| A | Task contract and state bus | 2, 5, 6, 14, 15, 17, 18 | — |
| B | Code navigation for subagents | 7, 8, 12 | A: hints live in the contract |
| C | Routing and orchestration | 4, 13, 20, 21, 22 | A: routing reads contract fields |
| D | Memory and learning loop | 1, 3, 24 | A: lessons come from failed verdicts |

The rest of the items are principles, not features. They belong in `CLAUDE.md` as rules.

## Pass 1 — Widen

### Review of the 24 items

The user asked for criticism. Each item gets one verdict.

| # | Item | Verdict | Reason |
|---|---|---|---|
| 1 | Self-improving loop | narrow | A model does not learn between sessions. Only a written rule, hook, or test persists |
| 2 | Filesystem as bus | keep | Core of A |
| 3 | Memory layer for cost | narrow | Memory adds tokens to every session. It saves cost only when it replaces a search |
| 4 | Route by risk and complexity | narrow | Route on contract fields a script reads, not on a model's guess |
| 5 | Task contract | keep | It saves cost only if it holds an acceptance command |
| 6 | Replace `TODO.md` | narrow | The cost is loading the whole file. A query script may fix that alone |
| 7 | Graft is hard to use | keep | Pass 2 checks the alternatives |
| 8 | File and line hints | narrow | A line number goes stale after one edit. Give a path and a symbol |
| 9 | Minimize overengineering | keep | This is the test for every other row |
| 10 | Best-practice lifecycle | narrow | This is a document, not a feature. The loop research already names six stages |
| 11 | Deterministic tools first | keep | Belongs in `CLAUDE.md` |
| 12 | Symbol-level navigation | keep | Part of B |
| 13 | Delegate broad exploration | keep | Conflicts with one token per spawn. Part of C |
| 14 | Compact artifacts | keep | A defines the formats |
| 15 | Separate facts, plans, changes | keep | A decides files or sections |
| 16 | Never guess | done | `CLAUDE.md` Verification section |
| 17 | Keep unknowns explicit | partly done | Brainstorming has `unverified`. The contract needs a field |
| 18 | Document scope growth | done | Generalization Protocol and the `todo-update` new-scope row |
| 19 | Executable checks | done | Acceptance command per row, exit command per milestone |
| 20 | Minimum number of agents | keep | Part of C |
| 21 | Teams only for peer work | keep | Part of C. Pass 2 checks the cost of teams |
| 22 | Main session orchestrates | keep | Part of C. It conflicts with a token per plan in unattended runs |
| 23 | Small reversible changes | done | Branch rules and one commit per row |
| 24 | Durable lessons only | keep | This is the filter for items 1 and 3 |

Five items already exist in `main`. The redesign should not rebuild them.

### The two branches

The user prefers the cost of `clae` and the output of `main`. The two differ in what they add.

| Part | `main` | `clae` |
|---|---|---|
| Output style and code rules | `plain-style`, `rules/`, language guides | `clae-concise`, path-scoped rules |
| Task state | One `TODO.md` per project | `.claude/work/<id>/` with 7 artifact files |
| Code context | graft | Python gateway, about 1,170 lines |
| Agents | implementer, reviewer | 9 agents and 4 routers |
| Schemas | none | 13 JSON schemas |

Hypothesis: the output quality comes from `main`'s rules and style. The low cost comes from `clae`'s small per-task files. Pass 2 checks this.

### Features of subsystem A

Stated features come from the prompt. Implied features are forced by a stated one.

| ID | Feature | Kind | Forced by | Trigger | Mark |
|---|---|---|---|---|---|
| A1 | A folder per task that agents write results into | stated, item 2 | — | Orchestrator dispatches a task | core |
| A2 | A contract file: goal, scope, non-goals, acceptance command | stated, item 5 | — | User approves a task | core |
| A3 | A task list that loads less context than `TODO.md` | stated, item 6 | — | Orchestrator picks the next task | core |
| A4 | Facts, plan, changes, and verdict kept apart | stated, item 15 | — | Agent finishes a stage | core |
| A5 | An unknowns field in the contract | stated, item 17 | — | Agent meets a question it cannot answer | core |
| A6 | A task ID scheme | implied | A1, A3 | Task is created | core |
| A7 | A fixed field format a script can read | implied | A2, A4, item 11 | Script reads a contract or verdict | core |
| A8 | A query command: next task, counts, blocked | implied | A3, item 11 | User or orchestrator asks what is next | core |
| A9 | Contract check before dispatch | implied | A2 | Orchestrator dispatches | core |
| A10 | One writer per file | implied | A1 with parallel agents | Two agents run at once | core |
| A11 | Resume from the folder after a new session | implied | A1 | Session ends or compacts | core |
| A12 | Archive of finished task folders | implied | A1 | Task reaches done | later |
| A13 | A human overview of all tasks | implied | A3 removes the one-page view | User opens the project | later |
| A14 | Migration of the four skills and existing `TODO.md` files | implied | A3 | First use in an old project | later |
| A15 | Per-task budget: model, turns, cost cap | implied | A2, item 5 | Orchestrator dispatches | later |
| A16 | A JSON schema for every artifact type | proposed by `clae` | A7 | — | refused |
| A17 | A task server or database | proposed by `clae` v0.3 | A3 | — | refused |
| A18 | A mailbox for agents to chat through files | reading of item 2 | A1 | — | refused |
| A19 | An external tracker as the source of truth | proposed by `clae` v0.3 | A3 | — | refused |
| A20 | A context gateway that scores and packs files | `clae` v0.4 | A1 | — | refused |

### Refusals

| ID | Reason |
|---|---|
| A16 | Only the contract and the verdict are read by a script. A schema for the other five files is weight with no reader |
| A17 | Files and one script meet the need. A server adds a process to start and a state to repair |
| A18 | The bus carries finished results, not dialogue. Chat through files brings back the long conversation it replaces |
| A19 | A tracker needs a network call to read state. It can mirror the files later, not replace them |
| A20 | This belongs to B. At about 1,170 lines it fails item 9 before B is even widened |

### Later milestones

| Milestone | Subsystem | First question for its own brainstorm |
|---|---|---|
| M2 | B navigation | Does an LSP or a tag index give symbol hints with less setup than graft? |
| M3 | C routing | Which contract fields decide the model, the agent count, and the review? |
| M4 | D memory | How does a failed verdict become a proposed rule, hook, or test? |
| M5 | Principles | Which of items 9–11 and 16–24 are missing from `CLAUDE.md`? |
| M6 | Plugin | Merged into subsystem A by D10 |

## Pass 2 — Ground

Two research agents read the Claude Code docs and the public literature on 2026-09-26. Two claims were checked again by hand.

### Facts that shape subsystem A

| # | Assumption | Finding | Source | Status |
|---|---|---|---|---|
| G1 | Plain files work as a bus between agents | Manus, Anthropic, and Letta all store results in files and pass paths | [Manus](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus), [Anthropic multi-agent](https://www.anthropic.com/engineering/multi-agent-research-system) | verified |
| G2 | Plain files beat a memory product | Letta filesystem 74.0% vs Mem0 68.5% on LoCoMo, vendor-run | [Letta](https://www.letta.com/blog/benchmarking-ai-agent-memory/) | verified, weak |
| G3 | `TODO.md` is the context cost | Largest local file: 10,609 words, 125 rows, 85 of them `done` | `~/stockbit-trading-agent/TODO.md` | verified |
| G4 | Claude Code has a task list that could replace `TODO.md` | TaskCreate is off by default on Opus 5.x. It lives in `~/.claude/tasks/`, outside the repo | [tools reference](https://code.claude.com/docs/en/tools-reference) | verified |
| G5 | A contract helps | Anthropic used sprint contracts, then removed them on Opus 4.6 with no loss | [harness design](https://www.anthropic.com/engineering/harness-design-long-running-apps) | verified |
| G6 | A heavy spec helps | Agents ignored spec-kit specs. Kiro turned a small bug into 16 criteria | [Fowler](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html) | verified |
| G7 | The handoff matters more than the model | A cheap scout plus a fixer solved 159 vs 158, at about 1/5 cost | [arXiv 2608.04804](https://arxiv.org/abs/2608.04804) | verified by agent |
| G8 | A separate reviewer is worth its cost | Agents praise their own work. A clean-context reviewer finds about 2 bugs per PR | [harness design](https://www.anthropic.com/engineering/harness-design-long-running-apps), [Cognition](https://cognition.com/blog/multi-agents-working) | verified |
| G9 | The parent sees the subagent's work | It sees the final message only | [tools reference](https://code.claude.com/docs/en/tools-reference) | verified |
| G10 | A hook can hand a contract to a subagent | SubagentStart `additionalContext` reaches the subagent before its first prompt. Output caps at 10,000 characters | [hooks](https://code.claude.com/docs/en/hooks) | verified |
| G11 | A PreToolUse hook can tell an implementer spawn from a research spawn | Needs `subagent_type` in the hook input | — | unverified |
| G12 | Loop state files belong in git | 217 working loops in 36,710 repos; almost none commit their state files | [arXiv 2608.21884](https://arxiv.org/abs/2608.21884) | verified by agent |
| G13 | Harness parts are permanent | Anthropic: each part encodes an assumption about the model. Remove it when the model outgrows it | [harness design](https://www.anthropic.com/engineering/harness-design-long-running-apps) | verified |

### Facts that shape the later milestones

| # | Assumption | Finding | Source | Status |
|---|---|---|---|---|
| G14 | LSP saves tokens (M2) | LSP used 6% to 118% more tokens than grep. It failed 3 of 4 multi-file renames | [arXiv 2608.13568](https://arxiv.org/abs/2608.13568) | verified by hand |
| G15 | Bounded views beat whole files (M2) | SWE-agent: full-file viewer 12.7% vs 30-line window 14.3% (Lite, older model) | [SWE-agent](https://arxiv.org/html/2405.15793) | verified |
| G16 | Claude Code has LSP (M2) | Yes, through a code intelligence plugin. Diagnostics arrive after each edit | [code intelligence](https://code.claude.com/docs/en/plugins/code-intelligence) | verified |
| G17 | Multi-agent is cheap (M3) | Agents use about 4x chat tokens, multi-agent about 15x, teams about 7x | [Anthropic multi-agent](https://www.anthropic.com/engineering/multi-agent-research-system), [costs](https://code.claude.com/docs/en/costs) | verified |
| G18 | Multi-agent helps coding (M3) | Sequential tasks lose up to 70%. Coding has few parallel parts | [arXiv 2512.08296](https://arxiv.org/abs/2512.08296) | verified by agent |
| G19 | A learned router pays off (M3) | Savings came from the scout's handoff, not from the routing choice | [arXiv 2608.04804](https://arxiv.org/abs/2608.04804) | verified by agent |
| G20 | Context files raise success (M4) | No success gain, over 20% more cost. Instructions in them are followed | [arXiv 2602.11988](https://arxiv.org/abs/2602.11988) | verified by hand |
| G21 | Context files cut runtime (M4) | AGENTS.md cut median runtime 28.64% and output tokens 16.58% | [arXiv 2601.20404](https://arxiv.org/abs/2601.20404) | verified by agent |
| G22 | A model can rewrite its own memory (M4) | A full rewrite shrank a playbook from 18,282 to 122 tokens and fell below no memory | [ACE](https://arxiv.org/abs/2510.04618) | verified |
| G23 | Lessons transfer (M4) | Abstract lessons help, +3.7%. Raw traces transfer negatively | [arXiv 2604.14004](https://arxiv.org/abs/2604.14004) | verified by agent |
| G24 | "AI engineering OS" is a defined practice | No agreed definition exists. The name appears only in project titles | agent search | unverified |
| G25 | `main` gives better output, `clae` lower cost | No side-by-side run exists | — | unverified |

"Verified by agent" means a research agent read the primary source and I did not read it again.

### Defects found in `main`

These defects sit outside subsystem A. They are reported here, not fixed.

| # | File | Defect | Source |
|---|---|---|---|
| X1 | `agents/implementer.md` | Custom subagents load `~/.claude/CLAUDE.md`. The implementer inherits the wait-for-Go protocol with no user present | [sub-agents](https://code.claude.com/docs/en/sub-agents) |
| X2 | `skills/milestone-run/SKILL.md` | "Set `maxBudgetUsd`" is an SDK option. The CLI has `--max-budget-usd` in print mode only | [CLI reference](https://code.claude.com/docs/en/cli-reference) |
| X3 | `agents/implementer.md` | `tools:` lists Glob and Grep. Both are absent on Linux and WSL by default | [tools reference](https://code.claude.com/docs/en/tools-reference) |
| X4 | `CLAUDE.md` Memory section | It says to read `MEMORY.md`. The harness already loads its first 200 lines | [memory](https://code.claude.com/docs/en/memory) |
| X5 | `CLAUDE.md` | `@rules/...` imports load at launch. `rules/` also auto-loads. A double load is possible | [memory](https://code.claude.com/docs/en/memory), unverified |

## Pass 3 — Narrow

IDs start at D3. D1 and D2 were settled in chat: two research agents, and subsystem A first.

Rescored on 2026-09-26 for future value, after D3, D4, and D8 were settled. "Cost" now means what an option blocks later, not tokens today.

| ID | Decision | Options | Recommendation | Depends on |
|---|---|---|---|---|
| D3 | Where does the task list live? | settled, see Grilling | GitHub Issues | — |
| D4 | What happens to the task bus at done? | settled, see Grilling | Delete the folder, post the verdict on the issue | D3 |
| D8 | How does the implementer escape the approval protocol? | settled, see Grilling | Scoped `CLAUDE.md` clause | — |
| D5 | Where does the contract live, and what files does one task hold? | (a) Issue body is the contract. The folder holds one report per agent. Blocks nothing; cloud agents read the same issue. (b) `contract.md` in the folder plus reports. Blocks cloud agents, which cannot see the folder. (c) `clae`'s 7 files. Blocks cloud agents too | (a). The contract must be where a cloud agent looks: the issue (G26, G29) | D3, D4 |
| D6 | Which fields does the contract hold? | (a) Body: goal, non-goals, acceptance command, hints, unknowns. Labels: value, effort, risk. Adds a risk field before M3 reads it. (b) Same without risk. Later issues need a back-fill when M3 lands. (c) `clae`'s 10 fields with a stored routing choice. Stores what a script can compute | (a). A label costs one line now and saves a back-fill later. Routing stays computed (item 11) | D5 |
| D7 | What checks a contract before dispatch? | (a) Script in the `milestone-run` preflight. Local only. (b) PreToolUse hook on the Agent tool. Local only, and G11 is unverified. (c) GitHub issue form with required fields, plus the preflight script reading the same fields. Works for local and cloud runs | (c). The check must hold where the work runs, and cloud runs skip local hooks | D6 |
| D9 | Who writes the hints before M2 exists? | (a) The orchestrator, from a grep. Hints stay in chat. (b) A cheap scout writes hints into the issue body for `M` rows. (c) The implementer finds its own way. Nothing is kept for the next agent | (b). Hints on the issue serve every later agent, local or cloud (G7) | D6 |
| D10 | How do the skills change? | (a) Rewrite `todo-plan`, `todo-update`, and `milestone-run` in place for Issues, rename them, add a migration script for the 5 old `TODO.md` files. (b) New skills beside the old ones, retire the old after migration. Two chains for a while. (c) Package rules, skills, and agents as a plugin now. Also answers G29, but widens scope | (a). One chain, names that match the job. The plugin becomes its own milestone, M6 | D3, D5, D7 |

Order for grilling: D5, then D6, then D7 and D9, then D10.

## Grilling

Round 1 ran by hand on 2026-09-26, because the `grilling` skill is not installed (D11).

| ID | Settled answer | Note |
|---|---|---|
| D4 | `.claude/work/<id>/` is ignored by git and deleted at `done`. The agent's verdict is posted on the issue as a comment | Rechecked after D3. The issue keeps every verdict, so M4 can learn from failures |
| D8 | (a) One `CLAUDE.md` clause: a subagent dispatched for a row in an approved milestone acts under that token | The clause covers only rows the token listed. A row outside the list still stops the run |
| D3 | GitHub Issues: labels for Value and Effort, milestones for versions, `Fixes #n` in the commit | Chosen for the issue, PR, checks, merge queue path and for cloud agents. Accepted: network reads, no offline use |
| D5 | The issue body is the contract. `.claude/work/<id>/` holds one report per agent | The agent records the body's `updatedAt` value at start, so a mid-run edit is detected |
| D7 | Issue form with required fields, plus a preflight script that reads the same fields | The script is the gate. `gh issue create` skips the form |
| D9 | A cheap scout writes path and symbol hints into the issue body for `M` rows. The orchestrator writes them for `S` rows | Hints name a symbol, not a line number |
| D6 | Hybrid: body holds goal, scope as allowed paths, non-goals, acceptance command, hints, unknowns. Labels hold value, effort, risk | Scope is the one field taken from `clae`. Constraints fold into non-goals. Routing stays computed |
| D10 | Options (a) and (c): rewrite the three skills in place for Issues, rename them, migrate the 5 old `TODO.md` files, and package rules, skills, agents, hooks, and styles as a plugin in this milestone | M6 merges into this milestone. A plugin cannot carry `CLAUDE.md` or `rules/`. D13 settles how they travel |

Criterion change, set by the user in round 2: future value outranks today's token cost. Recommendations in D5 to D10 were scored on cost and need a new score.

| # | Fact added in grilling | Source | Status |
|---|---|---|---|
| G26 | The Claude Code GitHub Action turns an issue into a PR on `@claude`, runs on a schedule, and accepts a subscription token | [GitHub Actions](https://code.claude.com/docs/en/github-actions) | verified |
| G27 | Backlog.md keeps one Markdown file per task in the repo, with a CLI and an MCP server. MIT, 6.9k stars | [Backlog.md](https://github.com/MrLesk/Backlog.md) | verified |
| G28 | GitHub stores "blocked by" links between issues natively | — | unverified |
| G29 | A GitHub Action run loads the repo's config, not `~/.claude`, so `rules/` and the approval protocol do not reach it | inferred from [GitHub Actions](https://code.claude.com/docs/en/github-actions) | unverified |
| G30 | A plugin ships skills, agents, hooks, commands, output styles, MCP and LSP servers. It has no field for `CLAUDE.md` or `rules/`. Its settings apply only `agent` and `subagentStatusLine` | [plugins reference](https://code.claude.com/docs/en/plugins-reference) | verified |
| G31 | The GitHub Action installs plugins through its `plugin_marketplaces` and `plugins` inputs | [GitHub Actions](https://code.claude.com/docs/en/github-actions) | verified |

### Round 3

| ID | Settled answer | Note |
|---|---|---|
| D13 | A sync script copies `CLAUDE.md` rules and `rules/` into each repo's `.claude/`. A plugin hook warns when a copy drifts. `~/.claude/rules/` stops holding them | Reaches local, Action, and cloud runs. A session outside any repo loads no rules |

Options refused for D13:

| Option | Reason |
|---|---|
| SessionStart hook prints the rules | The rules total 19,813 characters. The hook cap is 10,000 |
| Plugin `agent` setting | It replaces Claude Code's whole default system prompt |
| Rules become skills | The approval protocol stops being always-on |

Note for the build plan: a cloud run has no user to type a token. The user's `@claude` comment on an issue with a valid contract acts as the token.

| # | Fact added in round 3 | Source | Status |
|---|---|---|---|
| G32 | An agent run as the main thread replaces the default system prompt, the same way `--system-prompt` does. `CLAUDE.md` still loads | [sub-agents](https://code.claude.com/docs/en/sub-agents) | verified |
| G33 | `CLAUDE.md` plus `rules/` total 19,813 characters | `wc -c` on this repo | verified |
| G34 | `--append-system-prompt-file` appends a file to the default system prompt | [CLI reference](https://code.claude.com/docs/en/cli-reference) | verified |

All decisions D3 to D10 and D13 are settled. The next stage turns them into issues and a milestone in `claude-setup` (D3), not a `TODO.md`.
