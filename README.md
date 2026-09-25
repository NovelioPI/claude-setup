# CLAE

**Context-Limited Agentic Engineering**

CLAE is a project workflow for AI coding agents. Its main goal is simple:

> Give the agent the smallest context and cheapest capability that can reliably complete the next step.

CLAE adds a local **Context Gateway** on top of the earlier agent, testing, documentation, project-management, and design workflows.

---

## 1. What CLAE gives you

A new project using CLAE gets:

- **Task routing** — decide whether a request is brainstorming, planning, coding, testing, documentation, design, or review.
- **Five core coding agents** — repo scout, planner, builder, verifier, and reviewer.
- **Context Gateway** — select only the context needed for the current step.
- **Context ladders** — start shallow and escalate only when evidence requires more information.
- **Language-scoped rules** — load only the rules for languages/frameworks actually used by the task.
- **Testing policy** — decide whether a test is worth creating instead of creating one test file per trivial function.
- **Documentation workflow** — choose document type, audience, scope, grouping, and update boundaries before writing.
- **Design workflow** — create a design contract before frontend implementation; optionally connect Figma, Storybook, and browser verification.
- **Brainstorming workflow** — explore an idea, research it, record decisions, and turn it into an executable project before coding.
- **Sparse project state** — keep task state in small artifacts instead of one growing `todo.md`.
- **Checkpoints and compaction** — replace long agent history with a small durable state summary.
- **Verification hooks** — check changed files and run recorded focused verification commands.
- **Telemetry** — measure context cost, selection, and escalation so the workflow can improve from real usage.

CLAE is local-first. The Gateway uses Python's standard library and does not require a database, vector store, or paid service.

---

# 2. Start a new project

There are two common setups.

## Option A — Start a brand-new project from the CLAE template

Copy the contents of this repository into your new project:

```bash
cp -R /path/to/clae/.claude ./.claude
cp -R /path/to/clae/.clae ./.clae
cp -R /path/to/clae/docs ./docs
```

Then edit:

```text
.clae/project.yaml
```

At minimum:

```yaml
project: my-project
status: ACTIVE
current_task: null
active_tasks: []
blocked_tasks: []
next_tasks: []
```

You normally **do not copy the example runtime data**. Keep these directories empty:

```text
.clae/runtime/
.clae/archive/
.clae/tasks/
.clae/ideas/
.clae/design/
.claude/work/
```

The included `.gitignore` files already keep runtime/cache data out of git.

## Option B — Add CLAE to an existing project

From the root of the existing project:

```bash
cp -R /path/to/clae/.claude ./
cp -R /path/to/clae/.clae ./
```

Then:

1. Change `.clae/project.yaml` to your project name.
2. Review `.claude/rules/clean-code.md`.
3. Add only the language/framework rules that the project uses.
4. Review `.claude/settings.json` if you already have Claude Code hooks.
5. Review `.claude/integrations/` and enable only integrations you actually use.
6. Build the repository index.

```bash
python3 .clae/scripts/clae.py index
```

No package installation is required for the Gateway.

---

# 3. How to use CLAE day to day

The important rule is:

> **You normally talk to the coding agent. You do not manually manage every Gateway step.**

`CLAUDE.md`, the routers, agents, and hooks tell the agent when to use the Gateway.

The CLI is available when you want to inspect or control the workflow yourself.

A normal coding task looks like this:

```text
request
  ↓
task router
  ↓
create task contract
  ↓
Context Gateway
  ↓
repo scout / planner
  ↓
test decision
  ↓
builder
  ↓
verifier
  ↓
reviewer
  ↓
checkpoint
```

---

# 4. First task in a new project

Create a task workspace:

```bash
python3 .claude/scripts/init_task.py "Fix incorrect pacing multiplier"
```

The command prints a task ID such as:

```text
TASK-20260925-0915-fix-incorrect-pacing-multiplier
```

It creates an empty `.claude/work/TASK-.../` folder and marks it active in `.claude/work/ACTIVE`. Agents write these artifacts into it from `.claude/templates/`:

```text
contract.md
facts.md
plan.md
test-decision.md
changes.md
verification.md
review.md
```

The agent fills these artifacts as the task progresses. They are the **task memory bus**. Do not put the whole conversation into them.

If you prefer stable human-readable task IDs, create a task record as well:

```bash
python3 .claude/scripts/create_task.py DSP-142 "Fix incorrect pacing multiplier"
```

This creates only:

```text
.clae/tasks/DSP-142.yaml
```

To use the same ID for execution state, create the workspace with it:

```bash
python3 .claude/scripts/init_task.py --id DSP-142 "Fix incorrect pacing multiplier"
```

Use the task record for durable project state. Use `.claude/work/DSP-142/` for execution state.

---

# 5. Context Gateway

The Gateway is the main v0.4 feature.

## Build or refresh the index

Run after cloning the project and whenever the repository structure changes significantly:

```bash
python3 .clae/scripts/clae.py index
```

It creates a lightweight index under:

```text
.clae/runtime/indexes/repo.json
```

The index contains file and symbol metadata. It is runtime state and should not be committed.

## Build a context package

```bash
python3 .clae/scripts/clae.py package \
  --task "Fix incorrect pacing multiplier in BidOptimizer" \
  --task-id DSP-142 \
  --budget 10000
```

The Gateway will:

1. infer task demand;
2. find candidate files/symbols/artifacts;
3. separate hard and soft context;
4. score candidates by relevance, authority, freshness, dependency value, cost, and redundancy;
5. stay inside the token budget;
6. materialize only the selected context;
7. record the result as a JSON context package.

Output:

```text
.clae/runtime/context-packages/DSP-142.json
```

The generated package is primarily for the agent/runtime. You normally do not edit it manually.

## Understand the Context Ladder

CLAE starts shallow:

```text
L0  metadata
L1  symbol/signature
L2  local implementation
L3  dependencies/callers/callees
L4  subsystem
L5  repository
```

Do not jump to L5 because the agent is curious.

Escalate only when there is evidence such as:

- a missing symbol;
- dependency impact;
- conflicting evidence;
- failed verification;
- acceptance criteria that cannot be verified.

Example:

```bash
python3 .clae/scripts/clae.py escalate DSP-142 \
  --task "Fix incorrect pacing multiplier" \
  --reason missing_symbol \
  --level 1 \
  --step 0
```

The Gateway has a bounded escalation policy. It will not expand context forever.

---

# 6. Task lifecycle

CLAE uses artifacts instead of a large `todo.md` log.

```text
contract
  ↓
facts
  ↓
plan
  ↓
test decision
  ↓
changes
  ↓
verification
  ↓
review
  ↓
checkpoint
  ↓
integrate
```

## What goes where?

| Information | Location |
|---|---|
| Durable task status | `.clae/tasks/<id>.yaml` |
| Current execution state | `.claude/work/<id>/` |
| Project-level ideas | `.clae/ideas/` |
| Design decisions | `docs/adr/` or design contract |
| Context Gateway runtime | `.clae/runtime/` |
| Long-lived project rules | `.claude/rules/` |
| Architecture documentation | `docs/architecture/` |

This keeps old task history out of every future agent context.

---

# 7. Brainstorming a new project

Do **not** start with the builder when the idea is still vague.

Start with the brainstorming workflow:

```text
idea
 ↓
problem definition
 ↓
questions / unknowns
 ↓
research
 ↓
alternatives
 ↓
constraints
 ↓
decision
 ↓
project brief
 ↓
execution plan
```

Use:

```text
.claude/routers/task-router.md
.claude/agents/planner.md
docs/workflows/brainstorming.md
.clae/ideas/
```

A good brainstorm artifact should answer:

```text
What problem are we solving?
Who has the problem?
What evidence do we have?
What are the important unknowns?
What alternatives did we consider?
What are the constraints?
What is explicitly out of scope?
What is the smallest useful version?
What should we build first?
```

Only after these are sufficiently clear should the workflow create implementation tasks.

---

# 8. Testing: do not create a test file for every function

CLAE deliberately does **not** use:

```text
one function → one test file
```

The test router asks whether the behavior is worth protecting.

A trivial function such as:

```python
def add(a: int, b: int) -> int:
    return a + b
```

normally does not justify a dedicated test file if the behavior is obvious and covered by higher-level tests.

Tests become more valuable when there is:

- business logic;
- edge-case behavior;
- external I/O;
- state transitions;
- security or permission behavior;
- parsing/serialization;
- regression risk;
- integration boundaries;
- expensive failure.

Use:

```text
.claude/routers/test-router.md
.claude/templates/test-decision.md
docs/workflows/testing.md
```

The expected output is a **test decision**, not automatically a new test file.

---

# 9. Documentation workflow

Documentation is treated as an engineering task, not as “write a README”.

Before writing documentation, decide:

```text
Audience
Purpose
Document type
Scope
Grouping
Source of truth
Update owner
Exclusions
```

The main document types are:

```text
README       → getting started
Tutorial     → learn by doing
How-to       → solve one task
Reference    → exact facts/API/configuration
Concept      → explain how/why something works
ADR          → record an architectural decision
```

Do not put all of these into one huge document.

Use:

```text
.claude/routers/doc-router.md
.claude/agents/doc-writer.md
.claude/agents/doc-reviewer.md
docs/workflows/documentation.md
```

The documentation agent should update an existing document when its scope already fits instead of creating another overlapping file.

---

# 10. Design workflow

For frontend or visual work, do not immediately ask the builder to invent the UI.

Use:

```text
idea / requirement
 ↓
design contract
 ↓
component vocabulary
 ↓
visual reference
 ↓
implementation
 ↓
visual verification
```

The design contract can define:

- layout;
- spacing;
- typography;
- colors;
- components;
- interaction states;
- responsive behavior;
- accessibility requirements;
- visual references.

Useful integrations are documented in:

```text
.claude/integrations/figma-talk-to-figma.mcp.json
.claude/integrations/storybook.md
.claude/integrations/playwright-cli.md
```

### Figma

CLAE uses the community `claude-talk-to-figma-mcp`, not the official Figma MCP.

The project README documents a Node.js + Figma Desktop setup, including starting its WebSocket server, importing its Figma development plugin, and connecting the agent with a channel ID.

CLAE treats Figma as an **optional capability**. Do not enable it for ordinary backend tasks.

---

# 11. Language and clean-code rules

Do not load every programming-language rule into every task.

The workflow is:

```text
task
 ↓
identify touched files
 ↓
identify language/framework
 ↓
load only matching rules
 ↓
build/review
```

Put shared rules in:

```text
.claude/rules/clean-code.md
```

Put language-specific rules under a language-scoped location when extending the template.

For example:

```text
.claude/rules/languages/python.md
.claude/rules/languages/typescript.md
.claude/rules/languages/go.md
```

The agent should not read all of them. The relevant rule is selected from the task's actual files and stack.

---

# 12. Hooks and verification

CLAE installs two Claude Code hook workflows.

### After file changes

```text
.claude/hooks/verify_changed_file.py
```

This provides lightweight immediate checks.

### When the agent stops

```text
.claude/hooks/verify_on_stop.py
```

The stop hook is conservative. It does nothing unless `.claude/work/ACTIVE` contains `VERIFY_ON_STOP=1` (written by `init_task.py`) or `CLAE_VERIFY_ON_STOP=1` is set. When active, it checks:

```bash
git diff --check
```

If the active task has commands recorded as:

```text
COMMAND: <command>
```

inside:

```text
.claude/work/<task-id>/verification.md
```

those commands are also executed.

A task becomes active through:

```text
.claude/work/ACTIVE
```

Normally `init_task.py` creates this file for you.

---

# 13. Checkpoints and compaction

Use a checkpoint after a meaningful phase:

```bash
python3 .clae/scripts/clae.py checkpoint DSP-142
```

Then compact the context package when the task has accumulated exploration noise:

```bash
python3 .clae/scripts/clae.py compact DSP-142
```

Conceptually:

```text
long conversation
      ↓
extract durable state
      ↓
keep active artifacts
      ↓
discard exploration noise
      ↓
small checkpoint
```

A checkpoint should preserve:

- objective;
- completed work;
- important decisions;
- current evidence;
- unresolved issues;
- relevant artifacts.

It should not become a transcript.

---

# 14. Telemetry

CLAE records lightweight JSONL telemetry under:

```text
.clae/runtime/telemetry/
```

View a summary:

```bash
python3 .clae/scripts/clae.py telemetry summary
```

Useful signals include:

- context selected;
- context deferred;
- estimated tokens used;
- escalation count;
- checkpoint count;
- tool/capability use.

Use these measurements to decide whether a future CLAE change is actually useful.

---

# 15. MCP and external tools

External tools are **capabilities**, not permanent context.

The preferred order is:

```text
local artifact
  ↓
local index
  ↓
git
  ↓
external MCP
  ↓
human decision
```

For example, if a fresh local task snapshot already answers a project-status question, do not call Jira just because Jira is available.

The same principle applies to Figma, browser tooling, databases, and other MCPs.

---

# 16. What should be committed?

Commit the workflow itself:

```text
.claude/
.clae/gateway/
.clae/schemas/
.clae/scripts/
.clae/project.yaml
.clae/tasks/       # if using durable task records
.clae/ideas/       # if using project ideas
.clae/design/      # if using durable design contracts
docs/
```

Do **not** commit generated runtime state:

```text
.clae/runtime/
```

Check the repository's ignore files before committing.

---

# 17. Recommended first-day setup

For a new project, do this once:

```bash
# 1. Install/copy CLAE

# 2. Edit project metadata
$EDITOR .clae/project.yaml

# 3. Review project rules
$EDITOR .claude/rules/clean-code.md

# 4. Build the repository index
python3 .clae/scripts/clae.py index

# 5. Start Claude Code in the project root
claude
```

Then tell the agent what you want in normal language.

For a new idea:

```text
I have an idea for X. Start with brainstorming.
Do not implement anything yet.
```

For a concrete feature:

```text
Implement X. Start by creating the task contract and building the minimum context package.
```

For a bug:

```text
Fix X. Investigate first. Do not modify code until the root cause and verification strategy are clear.
```

For UI work:

```text
Build X, but create/review the design contract before implementation.
```

For documentation:

```text
Document X. First determine the right document type, audience, scope, and whether an existing document should be updated.
```

---

# 18. Common mistakes

### Mistake: manually reading the whole repository

Use the Gateway and escalate only when evidence requires it.

### Mistake: putting every project task into one `todo.md`

Use `.clae/tasks/` for durable status and `.claude/work/<id>/` for current execution.

### Mistake: loading every language rule

Load rules based on the files touched by the task.

### Mistake: asking the builder to invent a UI

Create a design contract first for non-trivial UI work.

### Mistake: writing a giant document

Choose a document type and explicit scope before writing.

### Mistake: creating tests because a function exists

Use behavior and risk as the test boundary.

### Mistake: calling every MCP because it is available

Treat MCPs as escalation capabilities.

### Mistake: escalating because the agent is curious

Escalate only with evidence.

---

# 19. Troubleshooting

### `clae.py index` fails

Run it from the project root:

```bash
pwd
python3 .clae/scripts/clae.py index
```

Python 3 is required.

### No context is selected

Check the task wording and budget:

```bash
python3 .clae/scripts/clae.py package --task "..." --budget 10000
```

Then inspect:

```text
.clae/runtime/context-packages/
```

### The agent needs more context

Do not manually dump the repository into the prompt. Record the evidence and use the escalation command with the narrowest valid reason.

### Stop verification blocks the agent

Inspect:

```text
.claude/work/ACTIVE
.claude/work/<task-id>/verification.md
```

Run the failing command manually. Fix the issue or update the verification artifact if the command is no longer correct.

### Figma is unavailable

Figma is optional. Check the integration guide and the upstream community MCP setup. The MCP requires Figma Desktop and a running WebSocket connection; its documented workflow also requires importing the plugin into Figma and connecting with the channel ID.

---

# 20. Documentation map

Start here:

```text
README.md
  ↓
docs/README.md
  ↓
choose a workflow
```

| Need | Read |
|---|---|
| Understand the architecture | `docs/architecture/context-gateway.md` |
| Understand why decisions were made | `docs/adr/` |
| Start a new idea | `docs/workflows/brainstorming.md` |
| Manage project state | `docs/workflows/project-management.md` |
| Decide when to test | `docs/workflows/testing.md` |
| Write maintainable docs | `docs/workflows/documentation.md` |
| Build UI systematically | `docs/workflows/design.md` |
| Understand runtime internals | `docs/implementation/runtime.md` |
| Configure Figma | `docs/integration/figma-talk-to-figma.md` |

---

# 21. v0.4 scope

The v0.4 Gateway intentionally uses deterministic heuristics first.

It does **not** require:

- a vector database;
- an embedding service;
- a paid project-management tool;
- a paid design tool integration;
- a learned context router.

The next useful step is to collect telemetry from real tasks. Only then should CLAE consider learned relevance, adaptive escalation, or semantic retrieval.

---

## One-minute mental model

If you remember only this, remember:

```text
ASK
 ↓
ROUTE
 ↓
LOAD THE SMALLEST USEFUL CONTEXT
 ↓
WORK
 ↓
VERIFY
 ↓
CHECKPOINT
 ↓
ESCALATE ONLY WITH EVIDENCE
```
