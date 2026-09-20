# Loop Engineering: How Production Coding-Agent Harnesses Structure Execution

This file records primary-source findings on loop mechanics, for the loop
engineering design project. It covers the Claude Agent SDK, Claude Code,
OpenAI Codex, Google Jules, GitHub Copilot coding agent, AGENTS.md, and MCP.

## 1. Loop shape, per system

| System | Stages the source names | Transition trigger |
|---|---|---|
| Claude Agent SDK | Receive prompt → Evaluate and respond → Execute tools → Repeat → Return result | Claude produces a response with no tool calls, or a limit (`maxTurns`, `maxBudgetUsd`) is hit. [Agent loop](https://code.claude.com/docs/en/agent-sdk/agent-loop) |
| Claude Code CLI (`-p`) | Same loop as the SDK, wrapped by a process that exits on completion | Process exit code 0 on success, non-zero on failure; SIGTERM leaves the turn unfinished and resumable. [Headless mode](https://code.claude.com/docs/en/headless) |
| OpenAI Codex (CLI/IDE) | Prompt → sandboxed command execution → approval check when a boundary is crossed → result | An approval policy decision (`on-request`, `never`) or a sandbox boundary (filesystem, network) gates each shell action. [Agent approvals & security](https://learn.chatgpt.com/docs/agent-approvals-security) |
| OpenAI Codex cloud | Task creation → isolated container execution (two-phase: setup, then agent) → summary and diff → human requests follow-up or opens a PR | The agent phase ends when Codex finishes and commits changes in its environment; PR creation is a separate, user-triggered step. [Codex cloud](https://learn.chatgpt.com/docs/cloud), [Sandboxing](https://learn.chatgpt.com/docs/sandboxing) |
| Google Jules | Prompt and source → plan generation → (optional) plan approval → VM execution → completion or retry-then-fail | `requirePlanApproval: true` gates progress on an explicit `approvePlan` call; otherwise the API auto-approves the plan. [Jules API](https://developers.google.com/jules/api) |
| GitHub Copilot coding agent | Assignment (issue or `@copilot` mention) → ephemeral GitHub Actions environment → research, plan, edit, test → PR opened → human review and iteration | A human review request is sent when Copilot finishes; `@copilot` comments on the PR restart the loop. [About coding agent](https://docs.github.com/en/copilot/concepts/coding-agent/about-copilot-coding-agent) |

### 1.1 Claude Agent SDK loop, in full

The documented cycle, quoted from the source:

1. **Receive prompt.** The SDK yields a `SystemMessage` with subtype `"init"`.
2. **Evaluate and respond.** Claude responds with text, tool calls, or both. The SDK yields one `AssistantMessage` per content block.
3. **Execute tools.** The SDK runs each tool and feeds results back to Claude. Hooks can intercept here.
4. **Repeat.** "Each full cycle is one turn. Claude continues calling tools and processing results until it produces a response with no tool calls."
5. **Return result.** The SDK yields a final `AssistantMessage` with no tool calls, then a `ResultMessage` with the final text, usage, cost, and session ID.

Source: [How the agent loop works](https://code.claude.com/docs/en/agent-sdk/agent-loop).

A **turn** is one round trip: Claude's output with tool calls, execution, and the fed-back result, all without returning control to the caller's code. The loop ends only when Claude emits a turn with zero tool calls, or a limit fires.

## 2. Where each system puts the human, and the stated reason

| System | Human checkpoint | Source's own stated reason |
|---|---|---|
| Claude Agent SDK | `canUseTool` callback, consulted only when hooks, deny/allow/ask rules, and permission mode do not resolve the call | Not resolved by "any of the above" means no automatic answer exists; the callback is the fallback decision point. [Permissions](https://code.claude.com/docs/en/agent-sdk/permissions) |
| Claude Code `plan` mode | File edits and shell writes always route to `canUseTool`, even with allow rules | "So write operations can't be auto-approved while planning." [Permissions](https://code.claude.com/docs/en/agent-sdk/permissions) |
| Claude Code `bypassPermissions` | No human checkpoint except critical-path `rm`/`rmdir`, tools needing user interaction, and connector tools an org marked `ask` | "Use with extreme caution. Claude has full system access in this mode. Only use in controlled environments where you trust all possible operations." [Permissions](https://code.claude.com/docs/en/agent-sdk/permissions) |
| Codex | Approval prompt before "leaving the sandbox, using the network, or running commands outside a trusted set" | Named escalation triggers: network access, sandbox boundary violation, tool calls with advertised side effects, destructive app/MCP operations. Safety monitoring can independently pause a task "if it detects potentially unsafe model behavior." [Agent approvals & security](https://learn.chatgpt.com/docs/agent-approvals-security) |
| Jules | Plan approval gate, opt-in via `requirePlanApproval` | The API defaults to auto-approving the plan; approval is explicit only when the caller asks for it. [Jules API](https://developers.google.com/jules/api) |
| GitHub Copilot coding agent | Pull request review, always, after Copilot finishes | "Copilot will request a review from you." Reserved for review, not for mid-task approval. [About coding agent](https://docs.github.com/en/copilot/concepts/coding-agent/about-copilot-coding-agent) |
| GitHub Actions (`claude-code-action`) | PR review, or the `--comment` review is posted for a human to read | "Grant the workflow only the permissions it needs, and review Claude's changes before merging." [GitHub Actions](https://code.claude.com/docs/en/github-actions) |

Inference: none of the five systems places a human inside a single tool call by
default when running unattended (`dontAsk`, `never`, `bypassPermissions`,
auto-merge cloud tasks). Each instead narrows the checkpoint to specific
categories: destructive filesystem paths (Claude Code), sandbox/network
boundary crossings (Codex), the plan (Jules), or the finished diff (Copilot,
GitHub Action).

## 3. The pass/fail oracle, per system

| System | What decides "done" | Source |
|---|---|---|
| Claude Agent SDK | Claude's own turn with zero tool calls; no external test oracle is built in | [Agent loop](https://code.claude.com/docs/en/agent-sdk/agent-loop) |
| Claude Agent SDK, structured output | JSON Schema validation against `--json-schema`; failure retries up to a configured limit, else `error_max_structured_output_retries` | [Headless mode](https://code.claude.com/docs/en/headless), [Agent loop](https://code.claude.com/docs/en/agent-sdk/agent-loop) |
| Codex | No formal oracle documented beyond the model's own judgment; safety monitoring can pause on "potentially unsafe model behavior" | [Agent approvals & security](https://learn.chatgpt.com/docs/agent-approvals-security) |
| Codex cloud | The agent commits changes in its environment; the human inspects "citations of terminal logs and test outputs" before merging | Secondary source only (not reached in the primary cloud page fetched): [Codex cloud](https://learn.chatgpt.com/docs/cloud) |
| Jules | Automatic retry on failure; "if it continues to fail, it will mark the task as failed and notify you" | [Jules FAQ](https://jules.google/docs/faq/) |
| GitHub Copilot coding agent | Copilot's own build/test/lint run inside its ephemeral environment, using commands from `.github/copilot-instructions.md`; a human review is the final gate | "If Copilot is able to build, test and validate its changes in its own development environment, it is more likely to produce good pull requests which can be merged quickly." [Best practices](https://docs.github.com/copilot/how-tos/agents/copilot-coding-agent/best-practices-for-using-copilot-to-work-on-tasks) |

Gap: none of the five primary sources defines a single, named "pass/fail
oracle" object comparable to a test suite exit code that the harness itself
enforces before ending the loop. Each treats the model's own stopping
decision, or a downstream human, as the actual gate. GitHub Copilot and
Codex both lean on the target repository's own CI/test commands, which are
external to the loop mechanics.

## 4. Failure modes the docs name for a gate or restriction

| System | Gate or restriction | Named failure it guards against |
|---|---|---|
| Claude Code `PreToolUse` hook / critical-path rule | `rm`/`rmdir` on a critical path is never approved by an allow rule or `bypassPermissions` | Prevents a destructive removal from being silently pre-approved. [Permissions](https://code.claude.com/docs/en/agent-sdk/permissions) |
| Claude Code `--permission-prompts none` | Denies anything needing a human when no one is available | Used "when nobody is available to answer permission prompts, for example in a scheduled job." [Headless mode](https://code.claude.com/docs/en/headless) |
| Claude Code background-task timeout | `CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS`, default 10 minutes idle | "So a stuck subagent or workflow can't hold the process open indefinitely." [Headless mode](https://code.claude.com/docs/en/headless) |
| Claude Code `maxBudgetUsd` | Spend cap across the session, including subagents | Spawning a subagent past the cap fails with `Budget limit reached`, and running background subagents are stopped. [Agent loop](https://code.claude.com/docs/en/agent-sdk/agent-loop) |
| Claude Code subagent spawn depth | `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`, default 3 | Bounds runaway recursive delegation (inference: no explicit reason quoted). |
| Claude Code concurrent subagents | `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`, default 20 | Errors with `Concurrent subagent limit reached` when exceeded. |
| Codex sandbox modes | `read-only`, `workspace-write`, `danger-full-access` | `danger-full-access` "removes the filesystem and network boundaries" and is "not recommended." [Sandboxing](https://learn.chatgpt.com/docs/sandboxing) |
| Codex `bypassPermissions`-equivalent | `--dangerously-bypass-approvals-and-sandbox` (`--yolo`) | "Only use inside an externally hardened environment." [CLI reference](https://learn.chatgpt.com/docs/developer-commands?surface=cli) |
| Codex cloud | Network access disabled during the agent phase by default | Limits "the agent's interaction solely to the code explicitly provided via GitHub repositories and pre-installed dependencies." (secondary paraphrase; primary text not directly quoted) |
| GitHub Copilot coding agent | 59-minute hard execution limit per session | Not explained in the fetched page; treat the reason as unstated. |
| GitHub Copilot coding agent | Single repository, one branch, one PR per task | Not explained in the fetched page; treat the reason as unstated. |
| Jules | Daily task ceiling per plan tier | "New task" button disabled once the ceiling is hit; existing work stays accessible. [Jules usage limits](https://jules.google/docs/usage-limits/) |

## 5. Mechanism names and flags for running unattended

### 5.1 Claude Code / Agent SDK

| Mechanism | Type | Effect |
|---|---|---|
| `claude -p` / `--print` | CLI flag | Runs non-interactively; exits 0 on success, non-zero on failure. [Headless mode](https://code.claude.com/docs/en/headless) |
| `--bare` | CLI flag | Skips auto-discovery of hooks, skills, custom commands, subagents, plugins, MCP servers, auto memory, CLAUDE.md. Recommended for scripted/SDK calls. |
| `--output-format text\|json\|stream-json` | CLI flag | `json` returns `result`, `session_id`, `total_cost_usd`; `stream-json` is newline-delimited JSON, terminated by a `result` message. |
| `--json-schema '<schema>'` | CLI flag | Forces structured output into `structured_output`; invalid schema exits with an error. |
| `--include-partial-messages` + `--verbose` | CLI flag pair | Streams token-level `stream_event` deltas with `stream-json`. |
| `--allowedTools "Read,Edit,Bash"` | CLI flag | Auto-approves named tools; unlisted tools still exist and fall through to permission mode. |
| `--disallowedTools` | CLI flag | Removes tool definitions entirely; Claude cannot see or attempt them. |
| `--permission-mode default\|acceptEdits\|plan\|dontAsk\|bypassPermissions\|auto` | CLI flag | Sets the session-wide permission baseline. |
| `--permission-prompts none` | CLI flag | Denies (rather than waits on) any call that would need a human; requires v2.1.259+. |
| `--dangerously-skip-permissions` | Historical flag (superseded by `bypassPermissions` mode) | Bypasses permission checks; "Use with extreme caution." |
| `--continue`, `--resume <session_id \| path>` | CLI flags | Resumes the most recent, or a named, session. Claude Code finds a session by ID across any project on the machine (v2.1.223+). |
| `--json-schema`, `--max-turns` | CLI flags | Structured output and turn cap for one-shot runs. |
| `max_turns` / `maxTurns` | SDK option | Caps tool-use turns; `ResultMessage.subtype = "error_max_turns"` on hit. |
| `max_budget_usd` / `maxBudgetUsd` | SDK option | Caps spend, subagents included; `error_max_budget_usd` on hit. |
| `canUseTool` callback | SDK callback | Runtime approval handler, invoked only when nothing earlier resolves the call. |
| `PermissionRequest` hook | Hook event | Can pre-empt `canUseTool` in `--permission-prompts none` mode. |
| `CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS` | Env var | Caps how long `-p` waits on a background subagent/workflow; default 10 minutes; `0` disables the cap. |
| `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` | Env var | Default 3; nested subagent spawn depth. |
| `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` | Env var | Default 20 concurrent subagents. |
| `CLAUDE_CODE_SUBAGENT_MODEL` / `_FORCE` | Env vars | Forces a model for every subagent. |
| `isolation: worktree` | Subagent frontmatter field | Runs the subagent in a temporary git worktree branched from the default branch, auto-cleaned if unchanged. |
| SIGTERM vs SIGINT | Process signal | SIGTERM leaves the in-progress turn unfinished, exit code 143, resumable; SIGINT (or SDK `interrupt()`) ends the turn cleanly first. |

### 5.2 OpenAI Codex

| Mechanism | Type | Values / effect |
|---|---|---|
| `--sandbox, -s` | CLI flag | `read-only \| workspace-write \| danger-full-access` |
| `--ask-for-approval, -a` | CLI flag | `on-request \| never` |
| `--dangerously-bypass-approvals-and-sandbox` (`--yolo`) | CLI flag | Runs every command with no approvals or sandbox; "only use inside an externally hardened environment." |
| `codex exec` (alias `codex e`) | CLI subcommand | Non-interactive mode; streams to stdout or JSONL; can resume prior sessions. |
| `--ephemeral` | `codex exec` flag | Runs without persisting rollout files to disk. |
| `--full-auto` | Deprecated `codex exec` flag | Superseded by `--sandbox workspace-write`; previously resolved to `sandbox_mode = "danger-full-access"` + `approval_policy = "never"`. |
| `sandbox_mode` | `config.toml` key | `read-only \| workspace-write \| danger-full-access` |
| `approval_policy` | `config.toml` key | `on-request \| never \|` a granular object with `sandbox_approval`, `rules`, `mcp_elicitations`, `request_permissions`, `skill_approval` booleans. Deprecated: `untrusted`, `on-failure`. |
| `approvals_reviewer` | `config.toml` key | `user \| auto_review` (a reviewer subagent). Default `user`. |
| `sandbox_workspace_write.network_access` | `config.toml` key | Boolean; network is off by default even in `workspace-write`. |
| `sandbox_workspace_write.writable_roots` | `config.toml` key | Array of extra writable paths. |
| `--add-dir` | CLI flag | Grants additional directories write access alongside the main workspace. |
| `--dangerously-bypass-hook-trust` | CLI flag | Runs enabled hooks without persisted hook trust for one invocation. |
| Platform sandbox enforcement | OS mechanism | Seatbelt (macOS), Windows Sandbox (native Windows), `bubblewrap` (Linux/WSL2). [Sandboxing](https://learn.chatgpt.com/docs/sandboxing) |
| Two-phase cloud runtime | Cloud environment model | Setup phase has network access to install dependencies; agent phase runs offline by default unless internet access is enabled for that environment. |

### 5.3 Google Jules

| Mechanism | Type | Effect |
|---|---|---|
| `requirePlanApproval` | API session field | `true` requires an explicit `approvePlan` call; default is auto-approval. |
| `automationMode: AUTO_CREATE_PR` | API session field | Automates PR creation on completion. |
| Setup script (Configuration → Environment) | Project config | Runs before every task in a fresh VM; a successful run can be snapshotted for reuse. |
| AGENTS.md / README fallback | Automatic behavior | "Will also refer to agents.md or your readme.md file for hints to setup an environment on the fly" when no script is set. |
| Daily task ceiling | Plan-tier limit | 15 (Jules), 100 (Pro), 300 (Ultra) per rolling 24 hours. |
| Concurrent task limit | Plan-tier limit | 3 (Jules), 15 (Pro), 60 (Ultra). |
| Retry-then-fail | Automatic behavior | Jules retries automatically on failure, then marks the task failed and notifies the user. |

### 5.4 GitHub Copilot coding agent

| Mechanism | Type | Effect |
|---|---|---|
| Assign an issue to Copilot | Trigger | Starts a task the same way as assigning to a human developer. |
| `@copilot` mention in a PR/issue comment | Trigger | Starts or continues a task; pushes commits directly to the PR branch. |
| `.github/workflows/copilot-setup-steps.yml` | Config file | One `copilot-setup-steps` job that runs before Copilot starts; a non-zero exit skips remaining steps and Copilot proceeds with the current environment state. |
| `.github/copilot-instructions.md` | Config file | Build/test/validation commands Copilot follows during its own environment run. |
| Firewall allowlist | Network config | Required hosts for self-hosted runners: `uploads.github.com`, `user-images.githubusercontent.com`, `api.{individual,business,enterprise}.githubcopilot.com`, plus npm registry hosts if the Codex-derived agent path is used. |
| 59-minute execution cap | Hard limit | Per-session ceiling; reason not stated in the fetched page. |
| Single repo / one branch / one PR | Scope limit | Documented constraint; reason not stated. |

### 5.5 Claude Code GitHub Action

| Mechanism | Type | Effect |
|---|---|---|
| `@claude` mention (default `trigger_phrase`) | Interactive-mode trigger | Starts when no `prompt` input is given. |
| `prompt` input | Automation-mode trigger | Runs unattended on any GitHub event, including `schedule` (cron). |
| Write-access check | Guard | Triggering user must have repo write access, except on events with no human author (e.g. `schedule`). |
| Human-actor check | Guard | Rejects a bot actor unless listed in `allowed_bots`, to prevent bot-triggered loops. |
| `claude_args: "--max-turns 5 ..."` | Config | Passes any Claude Code CLI flag into the action's run. |
| `--comment` (skill-level flag) | Config | Posts the review to the PR instead of leaving it only in the workflow log. |

## 6. Hook events Claude Code supports

Complete list, from the [hooks reference](https://code.claude.com/docs/en/hooks):

| Event | Trigger | Can block | Decision field |
|---|---|---|---|
| SessionStart | Session begins or resumes | No | — |
| Setup | Claude Code starts with `--init-only`, `--init`, or `--maintenance` | No | — |
| UserPromptSubmit | User submits a prompt, before processing | Yes (exit 2) | — |
| UserPromptExpansion | A typed command expands into a prompt | Yes (exit 2) | — |
| PreToolUse | Before a tool call executes | Yes (exit 2) | `permissionDecision`: `allow\|deny\|block` |
| PermissionRequest | A tool call needs a permission decision | No | `decision` object |
| PermissionDenied | Auto mode denies a tool call | No | `retry` flag |
| PostToolUse | After a tool call succeeds | No | — |
| PostToolUseFailure | After a tool call fails | No | — |
| PostToolBatch | After a batch of parallel tool calls resolves | No | — |
| Stop | Claude finishes responding | No | — |
| StopFailure | Turn ends due to API error | No | — |
| TeammateIdle | An agent-team teammate is about to go idle | No | — |
| SubagentStart | A subagent is spawned | No | — |
| SubagentStop | A subagent finishes | No | — |
| TaskCreated | A task is created via `TaskCreate` | No | — |
| TaskCompleted | A task is marked complete | No | — |
| PreCompact | Before context compaction | No | — |
| PostCompact | After context compaction | No | — |
| PreModelSwitch | Before a model switch | Yes (exit 2) | — |
| PostModelSwitch | After the session's model changes | No | — |
| InstructionsLoaded | A CLAUDE.md or `.claude/rules/*.md` file loads | No | — |
| ConfigChange | A config file changes mid-session | No | — |
| CwdChanged | Working directory changes | No | — |
| DirectoryAdded | A directory is added via `/add-dir` | No | — |
| FileChanged | A watched file changes on disk | No | — |
| WorktreeCreate | A worktree is being created | Yes (any non-zero exit) | — |
| WorktreeRemove | A worktree is being removed | Yes (any non-zero exit) | — |
| Notification | Claude Code sends a notification | No | — |
| MessageDisplay | Assistant message text is displayed | No | — |
| Elicitation | An MCP server requests user input | No | — |
| ElicitationResult | After the user responds to an elicitation | No | — |
| SessionEnd | Session terminates | No | — |

Common JSON fields on stdin for every hook:

```json
{
  "session_id": "...", "prompt_id": "...", "transcript_path": "...",
  "cwd": "...", "scratchpad_dir": "...",
  "permission_mode": "default|plan|acceptEdits|auto|dontAsk|bypassPermissions",
  "effort": { "level": "low|medium|high|xhigh|max" },
  "hook_event_name": "EventName",
  "agent_id": "...", "agent_type": "..."
}
```

Tool events (`PreToolUse`, `PostToolUse`, etc.) add `tool_name`, `tool_input`,
`tool_use_id`.

Standard hook output (stdout JSON):

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|block",
    "permissionDecisionReason": "...",
    "additionalContext": "...",
    "updatedInput": {},
    "retry": true
  },
  "systemMessage": "...",
  "terminalSequence": "..."
}
```

Exit codes: `0` success (stdout JSON parsed for decisions), `2` blocking error
(prevents the action where blocking applies), any other code is non-blocking
(action proceeds unless invalid JSON matches the schema).

## 7. Permission evaluation order (Claude Agent SDK / Claude Code)

Documented six-step order, every tool request passes through in this
sequence:

1. **Hooks.** Can deny outright; an `allow` from a hook does not skip deny/ask rules below. A `PreToolUse` allow cannot approve `rm`/`rmdir` on a critical path.
2. **Deny rules** (`disallowed_tools`, `settings.json`). Block even in `bypassPermissions`.
3. **Ask rules** (`settings.json`). Fall through to `canUseTool`, even in `bypassPermissions`.
4. **Permission mode.** `bypassPermissions` approves everything reaching this step (except critical-path removals); `acceptEdits` approves listed file operations; `plan` still routes edits to `canUseTool`.
5. **Allow rules** (`allowed_tools`, `settings.json`). Approve a match; critical-path removals are never approved here.
6. **`canUseTool` callback.** Final fallback; skipped entirely (denied) in `dontAsk` mode.

Source: [Configure permissions](https://code.claude.com/docs/en/agent-sdk/permissions).

## 8. Permission modes compared

| Mode | Behavior | Documented use case |
|---|---|---|
| `default` | No mode-based auto-approval; unresolved calls hit `canUseTool` | Interactive apps with a custom approval callback |
| `acceptEdits` | Auto-approves file edits and filesystem ops (`mkdir`, `touch`, `mv`, `cp`, `rm`, `rmdir`, `sed`) inside the working directory | Trusted prototyping, isolated directories |
| `plan` | Read-only exploration; edits always prompt | Propose changes without executing them |
| `dontAsk` | Converts every would-be prompt into a denial; `canUseTool` never called | Fixed, explicit tool surface for headless agents |
| `auto` | A model classifier approves or denies prompts | Autonomous agents that still want guardrails |
| `bypassPermissions` | Approves everything except critical-path removals, org-`ask` connector tools, and interaction-required tools | CI, containers, isolated environments only |

Subagent inheritance: a subagent runs in the parent's permission mode unless
its own `AgentDefinition.permissionMode` is set and the parent is in
`default`, `dontAsk`, or `plan`. `bypassPermissions` propagates to a subagent
only when the parent session itself is already in that mode (v2.1.267+).

## 9. Resuming, parallelism, and isolation across systems

| System | Resume mechanism | Parallel tasks | Isolation unit |
|---|---|---|---|
| Claude Code | `--continue` (most recent finished session), `--resume <id\|transcript path>`; session found by ID across the whole machine (v2.1.223+) | Subagents: up to `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` (default 20), depth up to `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` (default 3) | Subagent context (fresh, no parent history); optional `isolation: worktree` for a temporary git worktree |
| Codex CLI/IDE | `codex exec` can "resume previous sessions" (mechanism name not further detailed in fetched pages) | Not documented in fetched pages | OS-level sandbox: Seatbelt, Windows Sandbox, `bubblewrap` |
| Codex cloud | Not detailed in fetched pages | "Work in parallel on multiple tasks, each running in its isolated cloud environment" (secondary paraphrase) | Isolated, OpenAI-managed container per task |
| Jules | Sessions are stateful via the API; VM snapshot reused across tasks in the same repo | Concurrent task limit by plan tier (3/15/60) | Fresh, short-lived VM per task |
| GitHub Copilot coding agent | Continue via `@copilot` PR comments | Not documented as a named limit in fetched pages | Ephemeral GitHub Actions environment per task |

## 10. MCP: the agent-to-tool protocol layer

Source: [MCP architecture overview](https://modelcontextprotocol.io/docs/2026-07-28/learn/architecture).

- **Roles:** MCP Host (the AI application, e.g. Claude Code), MCP Client (one per server connection), MCP Server (provides context).
- **Layers:** data layer (JSON-RPC 2.0: discovery, tools, resources, prompts, notifications) and transport layer (stdio for local, Streamable HTTP for remote).
- **Server primitives:** Tools (executable actions), Resources (contextual data), Prompts (interaction templates).
- **Client primitives:** Elicitation (server asks the user for input); Sampling and Logging are deprecated as of protocol version `2026-07-28`.
- **Statelessness:** every request carries protocol version and capabilities in `_meta`; servers infer nothing from prior requests.
- **Discovery:** `server/discover` (capabilities, versions), `tools/list`, `tools/call`.
- **In Claude Code specifically:** MCP tools can be marked `_meta["anthropic/requiresUserInteraction"]`, which forces the call through `canUseTool` even when an allow rule matches, and even in `bypassPermissions` (except `dontAsk`, which denies it outright).

## 11. AGENTS.md spec

Source: [agents.md](https://agents.md/).

- Plain Markdown, no required fields or schema: "the agent simply parses the text you provide."
- Recommended content: build/test commands, code style, testing, security, commit/PR rules — content that "might clutter a README."
- Precedence: "the closest AGENTS.md to the edited file wins; explicit user chat prompts override everything." Agents read the nearest file in the directory tree.
- Governance: stewarded by the Agentic AI Foundation, a Linux Foundation project, after originating as a cross-vendor convention among OpenAI Codex, Amp, Google Jules, Cursor, and Factory.
- Codex, in particular, documents AGENTS.md as "Codex's equivalent of CLAUDE.md ... loaded before any task" (secondary paraphrase from search synthesis, not independently confirmed against a Codex primary page in this pass — see Gaps).
- Jules falls back to AGENTS.md or README.md "for hints to setup an environment on the fly" when no explicit setup script exists.

## Gaps

- Codex's own primary AGENTS.md page (`developers.openai.com/codex/agent-configuration/agents-md` or equivalent) was not directly fetched; the claim that Codex treats AGENTS.md as "loaded before any task" comes from a WebSearch synthesis, not a quoted primary page.
- The exact pass/fail oracle Codex cloud uses before allowing a PR (test citations, log citations) was reached only through a secondary-source paraphrase; the primary `learn.chatgpt.com/docs/cloud` page's own wording on this point was not captured verbatim.
- No primary source in this pass gave Codex's session-resume flag name or syntax in detail (only that `codex exec` "can resume previous sessions").
- Codex cloud's concurrent-task limit, if any, was not found in the fetched pages.
- GitHub Copilot coding agent's reason for the 59-minute execution cap and the single-repo/one-PR-per-task limit was not stated in the fetched page; recorded as an unexplained restriction.
- GitHub Copilot coding agent's own named pass/fail oracle (beyond "build, test, and validate") was not more precisely defined in the fetched pages; no explicit "the task is done when X" statement was found.
- Jules's precise definition of "done" (versus retry) beyond "retries automatically ... then marks the task as failed" was not detailed further in the fetched FAQ page.
- The MCP Tasks extension (durable handles for long-running requests) was named but not explored in depth; it may be directly relevant to loop mechanics for long-running tool calls and was out of scope for this pass.
- Claude Code's `auto` permission mode classifier's exact decision criteria (what the classifier is instructed to approve or deny) were not found; only that "a model classifier approves or denies permission prompts" is documented.
- GitLab CI/CD integration for Claude Code was referenced in the headless-mode page's "Next steps" but not fetched or explored in this pass.
