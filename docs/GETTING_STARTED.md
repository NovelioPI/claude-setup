# CLAE — Getting Started

This is the operational guide for setting up CLAE in a project and using it correctly.

## 1. Prerequisites

- Python 3
- Claude Code, or another agent that can read the `.claude/` workflow files
- Git for the verification hooks

The Context Gateway itself uses only the Python standard library.

## 2. Install CLAE into a project

From the CLAE template directory:

```bash
cp -R .claude /path/to/project/
cp -R .clae /path/to/project/
cp -R docs /path/to/project/
```

Then run everything from the project root.

Edit:

```text
.clae/project.yaml
```

Example:

```yaml
project: my-dsp
status: ACTIVE
current_task: null
active_tasks: []
blocked_tasks: []
next_tasks: []
```

## 3. Build the initial index

```bash
python3 .clae/scripts/clae.py index
```

Run this after initial setup and after large repository structure changes.

## 4. Start the agent

Open Claude Code from the project root:

```bash
claude
```

The `.claude/CLAUDE.md` file defines the workflow. You normally do not need to invoke every subagent manually.

## 5. Choose the correct starting mode

### New idea

Say:

```text
I have an idea for <project>. Start with brainstorming. Do not implement yet.
```

The workflow should use `docs/workflows/brainstorming.md` and keep the work in idea/project artifacts until the scope is mature.

### Feature

Say:

```text
Implement <feature>. Start by creating the task contract and identifying the minimum context needed.
```

### Bug

Say:

```text
Fix <bug>. Investigate the root cause first. Do not change code until the verification strategy is clear.
```

### Documentation

Say:

```text
Document <topic>. First choose the correct document type, audience, scope, and whether an existing document should be updated.
```

### UI/design

Say:

```text
Implement <UI>. Create or inspect the design contract before changing the frontend.
```

## 6. Create a task workspace

For manual task control:

```bash
python3 .claude/scripts/init_task.py "Fix incorrect pacing multiplier"
```

Use the printed task ID for subsequent commands. The command creates an empty workspace and marks it active in `.claude/work/ACTIVE`. Agents write these artifacts into it from `.claude/templates/`:

```text
contract.md
facts.md
plan.md
test-decision.md
changes.md
verification.md
review.md
```

These are intentionally small artifacts, not a transcript.

## 7. Use durable task state when needed

For a stable project task ID:

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

Use this for durable status. Use `.claude/work/DSP-142/` for execution details.

## 8. Context Gateway

Build a package manually:

```bash
python3 .clae/scripts/clae.py package \
  --task "Fix incorrect pacing multiplier in BidOptimizer" \
  --task-id DSP-142 \
  --budget 10000
```

Inspect:

```text
.clae/runtime/context-packages/DSP-142.json
```

The package records selected and deferred context. The Gateway prefers local, deterministic information before external capabilities.

## 9. Escalate only with evidence

Valid reasons:

```text
missing_symbol
dependency_impact
conflicting_evidence
failed_verification
unverifiable_acceptance
```

Example:

```bash
python3 .clae/scripts/clae.py escalate DSP-142 \
  --task "Fix incorrect pacing multiplier" \
  --reason dependency_impact \
  --level 2 \
  --step 1
```

Do not escalate because you simply want to inspect more files.

## 10. Checkpoint and compact

Checkpoint:

```bash
python3 .clae/scripts/clae.py checkpoint DSP-142
```

Compact:

```bash
python3 .clae/scripts/clae.py compact DSP-142
```

Use a checkpoint after a major phase or before handing work to another agent.

## 11. Testing

The test router decides whether a behavior deserves a test. It does not assume every function needs a test file.

Use:

```text
.claude/routers/test-router.md
.claude/templates/test-decision.md
docs/workflows/testing.md
```

A good test decision explains:

- what behavior matters;
- what risk exists;
- the cheapest useful test level;
- why a test is not needed when it is intentionally skipped.

## 12. Documentation

Use the documentation router before creating a document:

```text
.claude/routers/doc-router.md
```

Choose among README, tutorial, how-to, reference, concept, ADR, or an update to an existing document. Keep each document focused on one audience and purpose.

## 13. Design

Use the design contract before non-trivial UI work:

```text
.claude/schemas/design-contract.schema.json
.claude/templates/design-contract.md
docs/workflows/design.md
```

Optional tools are loaded only when the task needs them.

## 14. Figma

The template uses the community `claude-talk-to-figma-mcp` integration. Its documented setup requires Node.js, Figma Desktop, starting the WebSocket server, importing the Figma development plugin, and connecting the agent with the plugin's channel ID.

Read:

```text
docs/integration/figma-talk-to-figma.md
```

Figma is optional. Backend tasks should not load it.

## 15. Verification hooks

After file edits, CLAE runs a lightweight changed-file check.

When the agent stops and `.claude/work/ACTIVE` contains `VERIFY_ON_STOP=1` (written by `init_task.py`), CLAE runs:

```bash
git diff --check
```

and any focused commands written as:

```text
COMMAND: pytest tests/path/test_x.py
```

inside:

```text
.claude/work/<task-id>/verification.md
```

If a hook blocks the stop, fix the failure before considering the task complete.

## 16. Telemetry

View the summary:

```bash
python3 .clae/scripts/clae.py telemetry summary
```

Telemetry is useful for answering questions such as:

- Are we loading too much context?
- Which tasks need repeated escalation?
- Which external capabilities are rarely useful?
- Is the Gateway actually reducing work?

## 17. Git hygiene

Commit:

```text
.claude/
.clae/gateway/
.clae/schemas/
.clae/scripts/
.clae/project.yaml
docs/
```

Normally do not commit:

```text
.clae/runtime/
```

## 18. The normal loop

```text
1. State the task.
2. Let the router classify it.
3. Create or update the task contract.
4. Build minimum context.
5. Plan.
6. Make a test decision.
7. Implement.
8. Verify.
9. Review and simplify.
10. Checkpoint.
11. Escalate only if evidence requires it.
```
