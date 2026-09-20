# Autonomy Policy and Measurement in Coding Agents

This file gives primary-source evidence for loop engineering decisions about
agent autonomy: when an agent may act without asking, how blast radius is
contained, and how anyone measures the agent's share of the work.

## 1. Systems compared, at a glance

| System | Gate type | Levels or modes | Primary doc |
|---|---|---|---|
| Claude Code | Permission mode + optional model classifier | `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` | [Choose a permission mode](https://code.claude.com/docs/en/permission-modes) |
| Claude Code | OS-level sandbox (Bash only) | auto-allow, regular permissions | [Configure the sandboxed Bash tool](https://code.claude.com/docs/en/sandboxing) |
| Claude Agent SDK | Same modes as Claude Code, plus a `canUseTool` callback | `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` | [Configure permissions](https://code.claude.com/docs/en/agent-sdk/permissions) |
| OpenAI Codex | Sandbox mode + approval policy, two independent dials | Sandbox: `read-only`, `workspace-write`, `danger-full-access`. Approval: `on-request`, `never` (`untrusted` retired) | [Agent approvals & security](https://developers.openai.com/codex/agent-approvals-security) |
| Google Jules | VM isolation + human publish step | No named levels; a plan-review checkpoint and a manual publish/PR action | [Jules docs](https://jules.google/docs/) |
| GitHub Copilot coding agent | Branch naming rule + firewall | No named levels; agent can only push to a `copilot/` branch or the PR branch that triggered it | [Responsible use of Copilot cloud agent](https://docs.github.com/en/copilot/responsible-use/copilot-cloud-agent) |

## 2. Claude Code: permission modes

### 2.1 Loop shape and decision procedure

Claude Code evaluates every tool call in a fixed order: hooks, then deny
rules, then ask rules, then the permission mode, then allow rules, then a
prompt to the human (or, in `auto` mode, to a classifier model). Source:
[Configure permissions, "Manage permissions"](https://code.claude.com/docs/en/permissions#manage-permissions).

"Rules are evaluated in order: deny, then ask, then allow. The first match in
that order determines the outcome, and rule specificity doesn't change the
order." Source: [Configure permissions](https://code.claude.com/docs/en/permissions#manage-permissions).

| Mode | What runs without asking | Stated best use |
|---|---|---|
| `default` (labeled Manual) | Reads only | Reviewing every action yourself, sensitive work |
| `acceptEdits` | Reads, file edits, and common filesystem commands (`mkdir`, `touch`, `mv`, `cp`, etc.) | Iterating on code you are reviewing |
| `plan` | Reads, plus classifier-approved commands when auto mode is available | Exploring a codebase before changing it |
| `auto` | Everything, with background safety checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Reads and pre-approved tools; anything that would prompt is denied | Locked-down CI and scripts |
| `bypassPermissions` | Everything except a fixed exception list | Isolated containers and VMs only |

Source: [Choose a permission mode, "Available modes"](https://code.claude.com/docs/en/permission-modes#available-modes).

### 2.2 Where the human sits, and the stated reason

In Manual mode, the human sits before every file edit, shell command, and
network call. The doc states: "Claude Code starts with read-only permissions.
When Claude Code needs to edit files, run tests, or execute commands, it asks
you first, and you choose whether to approve the action once or allow it from
then on." Source: [Security, "Permission-based architecture"](https://code.claude.com/docs/en/security#permission-based-architecture).

In `auto` mode, a second model (the classifier) takes the human's seat for
routine actions. The human still sits in front of anything the classifier
cannot verify: "Auto mode reduces permission prompts but does not guarantee
safety. Use it for tasks where you trust the general direction, not as a
replacement for review on sensitive operations." Source: [Choose a permission mode](https://code.claude.com/docs/en/permission-modes#eliminate-prompts-with-auto-mode).

### 2.3 Pass/fail oracle

Three different oracles apply, depending on mode:

| Oracle | Used in | What it checks |
|---|---|---|
| Static rule match | All modes | Command or path text against `permissions.allow` / `ask` / `deny` |
| Human judgment | `default`, `acceptEdits`, `plan` (without auto) | The human reads the proposed action and decides |
| Classifier model | `auto`, and `plan` when auto is available | A separate Claude Sonnet 5 model call judges the action against a fixed rule list, using user messages, tool calls, and CLAUDE.md, with tool results stripped from what it sees |

Source: [Choose a permission mode, "How the classifier evaluates actions"](https://code.claude.com/docs/en/permission-modes#how-the-classifier-evaluates-actions).

The classifier's rule list is long and versioned. Examples of what it blocks
by default: `curl | bash`, force push, `git reset --hard`, `terraform
destroy`, merging a PR no human approved, and "launching an autonomous agent
loop that runs without human approval or a sandbox, such as one started with
`--dangerously-skip-permissions` or `--no-sandbox`." Source: [Choose a permission mode, "What the classifier blocks by default"](https://code.claude.com/docs/en/permission-modes#what-the-classifier-blocks-by-default).

### 2.4 Named failure the gate defends against

The doc names two distinct failures:

1. **Model error.** The `rm`/`rmdir` critical-path check exists as "a circuit
   breaker [that] guards against model error," independent of any rule the
   user wrote. Source: [Choose a permission mode, "Critical paths"](https://code.claude.com/docs/en/permission-modes#critical-paths).
2. **Prompt injection and hostile content.** The classifier blocks actions
   that "appear driven by hostile content Claude read," and Claude Code
   strips tool results from what the classifier itself sees, "so hostile
   content in a file or web page can't manipulate the classifier directly."
   Source: [Choose a permission mode](https://code.claude.com/docs/en/permission-modes#how-the-classifier-evaluates-actions).

`bypassPermissions` mode states its own failure mode directly: "`bypassPermissions`
offers no protection against prompt injection or unintended actions."
Source: [Choose a permission mode, "Skip all checks with bypassPermissions mode"](https://code.claude.com/docs/en/permission-modes#skip-all-checks-with-bypasspermissions-mode).

### 2.5 Exact settings.json syntax

```json
{
  "permissions": {
    "defaultMode": "default",
    "allow": ["Bash(npm run *)", "Bash(git commit *)"],
    "ask": ["Bash(git push *)"],
    "deny": ["Bash(git push *)"]
  }
}
```

Rule shape is `Tool` or `Tool(specifier)`. A bare `Bash` deny rule removes the
tool from the model's context entirely; a scoped rule such as `Bash(rm *)`
leaves the tool available and blocks only matching calls. Source: [Configure permissions, "Permission rule syntax"](https://code.claude.com/docs/en/permissions#permission-rule-syntax).

File and web rules use their own specifier forms: `Read(./.env)`,
`Edit(src/**)`, `WebFetch(domain:example.com)`. A `*` wildcard can sit
anywhere in a Bash rule and stands in for any text, including spaces.
Source: [Configure permissions, "Wildcard patterns"](https://code.claude.com/docs/en/permissions#wildcard-patterns).

The docs warn that a Bash text rule is not a security boundary: `Bash(curl
*)` in `deny` stops `curl https://example.com` but not `/usr/bin/curl
https://example.com` or `sh -c 'curl https://example.com'`. For a boundary
that does not depend on command text, the docs point to the sandbox instead.
Source: [Configure permissions, "What a Bash rule doesn't match"](https://code.claude.com/docs/en/permissions#bash-rule-limits).

## 3. Claude Code: the sandboxed Bash tool

### 3.1 Loop shape

The sandbox is a second, independent layer from permission rules. Permission
rules "control which tools Claude Code can use and are evaluated before any
tool runs." The sandbox instead "provides OS-level enforcement that restricts
what shell commands can access at the filesystem and network level," and
"the operating system enforces the sandbox boundary on the running process,
so it holds regardless of what the model chose to run." Source: [Configure the sandboxed Bash tool, "Permission rules"](https://code.claude.com/docs/en/sandboxing#permission-rules).

Enforcement mechanism by platform:

| Platform | Mechanism |
|---|---|
| macOS | Seatbelt (built in) |
| Linux | `bubblewrap` |
| WSL2 | `bubblewrap`, same as Linux |
| Native Windows | Not supported; run inside WSL2 |

Source: [Configure the sandboxed Bash tool, "OS-level enforcement"](https://code.claude.com/docs/en/sandboxing#os-level-enforcement).

### 3.2 Default filesystem and network scope

| Scope | Default |
|---|---|
| Write | Working directory, added directories, session temp directory |
| Read | Whole computer, except denied directories (still includes `~/.aws/credentials`, `~/.ssh/` unless you add a `sandbox.credentials` or `denyRead` rule) |
| Network | No domain pre-allowed; first use of a new domain prompts, or, in auto mode, the classifier reviews hosts named on the command |

Source: [Configure the sandboxed Bash tool, "How sandboxing works"](https://code.claude.com/docs/en/sandboxing#how-sandboxing-works).

### 3.3 Exact settings.json syntax

```json
{
  "sandbox": {
    "enabled": true,
    "filesystem": {
      "allowWrite": ["~/.kube", "/tmp/build"],
      "denyRead": ["~/"],
      "allowRead": ["."]
    },
    "network": {
      "allowedDomains": ["github.com", "*.npmjs.org"],
      "strictAllowlist": true
    },
    "credentials": {
      "files": [{ "path": "~/.aws/credentials", "mode": "deny" }],
      "envVars": [{ "name": "GITHUB_TOKEN", "mode": "deny" }]
    }
  }
}
```

Source: [Configure the sandboxed Bash tool, "Configure sandboxing"](https://code.claude.com/docs/en/sandboxing#configure-sandboxing) and ["Protect credentials"](https://code.claude.com/docs/en/sandboxing#protect-credentials).

### 3.4 Named failure the gate defends against

The docs name a self-escalation failure directly, tied to turning filesystem
isolation off: "a sandboxed command can write files that later commands run
or read, such as shell startup files, executables on `$PATH`, or
`~/.claude/settings.json`, and use them to widen its own access on the next
run." Source: [Configure the sandboxed Bash tool, "Disable filesystem isolation"](https://code.claude.com/docs/en/sandboxing#disable-filesystem-isolation).

The docs also state the network proxy's own limit: "The built-in proxy
enforces the allowlist based on the requested hostname and, by default, does
not terminate or inspect TLS traffic," which matters for a threat model that
needs to inspect encrypted traffic. Source: [Configure the sandboxed Bash tool, "Network isolation"](https://code.claude.com/docs/en/sandboxing#network-isolation).

## 4. Claude Code and Claude Agent SDK: protected and critical paths

These two path lists are the fixed floor beneath every permission mode,
including `bypassPermissions`.

| Concept | What it blocks | Overridable by an allow rule? |
|---|---|---|
| Protected paths | Writes to config and repo-state directories: `.git`, `.claude`, `.vscode`, `.idea`, `.husky`, `.cargo`, `.devcontainer`, `.yarn`, `.mvn`, plus files such as `.gitconfig`, `.bashrc`, `.npmrc`, `.mcp.json` | No. The check runs before allow rules are evaluated |
| Critical paths | `rm`/`rmdir` targeting the filesystem root, a top-level directory, the home directory, a drive root, or the working directory and its parents | No. A matching allow rule or a hook's `"allow"` cannot approve it; only a deny rule can block it outright |

Source: [Choose a permission mode, "Protected paths"](https://code.claude.com/docs/en/permission-modes#protected-paths) and ["Critical paths"](https://code.claude.com/docs/en/permission-modes#critical-paths).

The stated reason for protected paths: "This prevents accidental corruption
of repository state and Claude's own configuration." The stated reason for
critical paths: "This circuit breaker guards against model error." Same
sources as the table above.

## 5. Anthropic Agent SDK: the six-step evaluation and `canUseTool`

The SDK docs give the fullest published decision procedure of any source in
this file:

1. Hooks (`PreToolUse`) run first and can deny outright.
2. Deny rules match; a match blocks even in `bypassPermissions`.
3. Ask rules match; a match falls through to `canUseTool`, even in
   `bypassPermissions`.
4. Permission mode applies (auto-approve in `bypassPermissions`/`acceptEdits`,
   force a prompt in `plan`).
5. Allow rules match; a match auto-approves.
6. `canUseTool` callback decides anything still unresolved.

Source: [Configure permissions, "How permissions are evaluated"](https://code.claude.com/docs/en/agent-sdk/permissions#how-permissions-are-evaluated).

The SDK docs give a direct warning about a common integration mistake:
"Auto-approved tools never reach `canUseTool`. A tool call approved at any
earlier step... skips your `canUseTool` callback, so permission checks you
put there are silently bypassed for that tool." Source: [Configure permissions](https://code.claude.com/docs/en/agent-sdk/permissions#allow-and-deny-rules).

And on `bypassPermissions`: "`allowed_tools` does not constrain
`bypassPermissions`... Setting `allowed_tools=["Read"]` alongside
`permission_mode="bypassPermissions"` still approves every tool, including
`Bash`, `Write`, and `Edit`." Source: [Configure permissions](https://code.claude.com/docs/en/agent-sdk/permissions#allow-and-deny-rules).

## 6. OpenAI Codex

### 6.1 Loop shape: two independent dials

Codex separates "what the agent can technically do" from "when it must
stop and ask." Source: [Agent approvals & security](https://developers.openai.com/codex/agent-approvals-security).

| Dial | Values | Effect |
|---|---|---|
| `sandbox_mode` | `read-only`, `workspace-write` (default), `danger-full-access` | Sets filesystem and network reach |
| `approval_policy` | `on-request`, `never` (`untrusted` retired, `on-failure` deprecated) | Sets when Codex must pause for a human |

Source: [Config reference](https://developers.openai.com/codex/config-reference) and [Agent approvals & security](https://developers.openai.com/codex/agent-approvals-security).

`workspace-write` keeps `.git`, `.codex`, and `.agents` read-only even though
the rest of the workspace is writable, and keeps network access off by
default: `[sandbox_workspace_write] network_access = true` turns it on.
Source: [Agent approvals & security](https://developers.openai.com/codex/agent-approvals-security).

### 6.2 Exact config.toml syntax

```toml
sandbox_mode = "workspace-write"
approval_policy = "on-request"

[sandbox_workspace_write]
network_access = true
```

Full-bypass form: `sandbox_mode = "danger-full-access"`, or the CLI flags
`--dangerously-bypass-approvals-and-sandbox` / `--yolo`. Source: [Agent approvals & security](https://developers.openai.com/codex/agent-approvals-security).

Codex has also begun exposing a newer, more granular permission-profile
system (`default_permissions`, `[permissions.<name>.filesystem]`,
`[permissions.<name>.network]`), which the docs state does not compose with
`sandbox_mode`/`approval_policy`: "Configure either `default_permissions` and
`[permissions]`, or `sandbox_mode` / `sandbox_workspace_write`, but not
both." Source: [Permissions](https://developers.openai.com/codex/permissions).

### 6.3 Where the human sits, and stated reason

Codex asks before an action "that leaves the sandbox, uses the network, or
runs commands outside a trusted set," under `on-request`. Source: [Agent approvals & security](https://developers.openai.com/codex/agent-approvals-security).

The stated reason for gating network access specifically: "Use caution when
enabling network access or web search in Codex. Prompt injection can cause
the agent to fetch and follow untrusted instructions." Source: [Agent approvals & security](https://developers.openai.com/codex/agent-approvals-security).

Codex's default web search behavior is a direct prompt-injection mitigation:
it defaults to cached, pre-indexed results "to reduce prompt injection from
arbitrary live content," with live search as an opt-in. Source: [Agent approvals & security](https://developers.openai.com/codex/agent-approvals-security).

### 6.4 Pass/fail oracle and named failure

The oracle is the sandbox mode plus the approval policy, evaluated together
at the point Codex tries an action; there is no described classifier model
step comparable to Claude Code's auto mode. The named failure is prompt
injection from network content, stated above, plus data loss from full
access: `danger-full-access` is documented as "not recommended." Source: [Agent approvals & security](https://developers.openai.com/codex/agent-approvals-security).

Codex's Work-tier network controls, separate from the CLI, let an
administrator "disable public internet access entirely, restricting
commands to only required hostnames from a managed allowlist." Source: [Sandboxing](https://developers.openai.com/codex/concepts/sandboxing).

## 7. Google Jules

Jules runs in a per-task virtual machine: "Jules runs in a virtual machine
where it clones your code, installs dependencies, and modifies files."
Source: [Getting started](https://jules.google/docs/).

The human checkpoint is a plan-approval step before code changes run, and a
separate, explicit publish step: "At any point during a task, you can click
the GitHub icon in the top right to publish the current work-in-progress as
a new branch or open a pull request." Source: [Running Tasks with Jules](https://jules.google/docs/running-tasks/).

Jules does not merge on its own; it opens a pull request "targeting the main
branch, which you can then review and merge." Source: [Getting started](https://jules.google/docs/).

The public docs do not state a network allowlist policy, a pass/fail oracle
for the plan-approval step, or a named threat model (such as prompt
injection). This is recorded as a gap in section 12.

## 8. GitHub Copilot coding agent

### 8.1 Loop shape: branch-name containment plus a firewall

The agent is confined to one branch per task, by construction, not by a
reviewable rule: "The cloud agent only has access to the repository where it
is creating a pull request and cannot access other repositories. It can
only push to a single branch: the existing pull request branch when
triggered via `@copilot`, or otherwise to a new `copilot/` branch."
Copilot "cannot push directly to your default branch (for example, `main`)."
Source: [Responsible use of Copilot cloud agent](https://docs.github.com/en/copilot/responsible-use/copilot-cloud-agent).

### 8.2 Where the human sits

Two checkpoints are named:

1. Trigger: "The cloud agent only responds to interactions from users with
   repository write access."
2. Merge: "You are responsible for reviewing and validating responses
   generated by Copilot cloud agent... review all outputs generated by the
   agent thoroughly prior to merging."

Source: [Responsible use of Copilot cloud agent](https://docs.github.com/en/copilot/responsible-use/copilot-cloud-agent).

A CI checkpoint is also named: "Actions workflows triggered by pull requests
raised by the agent require approval from a user with write access before
they will run." Same source.

### 8.3 Pass/fail oracle: an outbound firewall, allowlist-based

"By default, Copilot's access to the internet is limited by a firewall,"
which "always allows access to a number of hosts that Copilot uses to
interact with GitHub." Organizations can extend a "recommended allowlist"
covering OS package repositories, container registries, and language package
registries. Source: [Customizing or disabling the firewall for GitHub Copilot](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/customize-the-agent-firewall).

### 8.4 Named failure

"Limiting internet access helps manage data exfiltration risks. Unexpected
behavior from Copilot, or malicious instructions, could lead to code or
other sensitive information being leaked to remote locations." Source: [Customizing or disabling the firewall for GitHub Copilot](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/customize-the-agent-firewall).

The docs also name prompt injection from repository content directly: the
agent "filters hidden characters that might allow users to hide harmful
instructions in comments or issue contents." Source: [Responsible use of Copilot cloud agent](https://docs.github.com/en/copilot/responsible-use/copilot-cloud-agent).

The firewall doc states its own limits: it "only applies to processes
started by the agent" and "only applies within the GitHub Actions
appliance," and "sophisticated attacks may bypass the firewall." Source: [Customizing or disabling the firewall for GitHub Copilot](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/customize-the-agent-firewall).

## 9. Cross-system table: prompt injection as a named reason for a gate

| System | Named mitigation | Stated limit of the mitigation |
|---|---|---|
| Claude Code (auto mode) | Classifier sees no tool results, only messages and tool calls, so hostile file/page content cannot steer it directly | The classifier can still be blocked or fail to reach a verdict; repeated blocks fall back to prompting |
| Claude Code (bypassPermissions) | None claimed | "Offers no protection against prompt injection or unintended actions" |
| OpenAI Codex | Cached web search results by default; sandbox plus approval gate on network reach | Documented caution: live network access "can cause the agent to fetch and follow untrusted instructions" |
| GitHub Copilot coding agent | Outbound firewall; strips hidden characters from issue/comment text | Firewall covers agent-started processes only, inside the GitHub Actions appliance; "sophisticated attacks may bypass" it |
| Claude Agent SDK | Same classifier/rule stack as Claude Code, when the caller enables `auto` mode | Not enabled by default; caller must opt in |

Sources as cited in sections 2–8 above.

## 10. DORA metrics: official definitions

DORA (DevOps Research and Assessment, now part of Google Cloud) publishes
four metrics at [dora.dev](https://dora.dev/guides/dora-metrics/).

| Metric | Official definition |
|---|---|
| Deployment frequency | "The number of deployments over a given period or the time between deployments" |
| Lead time for changes | "The amount of time it takes for a change to go from committed to version control to deployed in production" |
| Change failure rate | "The ratio of deployments that require immediate intervention following a deployment. Likely resulting in a rollback of the changes or a 'hotfix' to quickly remediate any issues" |
| Failed deployment recovery time | "The time it takes to recover from a deployment that fails and requires immediate intervention" |

Source: [DORA's software delivery performance metrics](https://dora.dev/guides/dora-metrics/).

DORA's own guidance advises against building precise-measurement
infrastructure as a first step: "Building integrations to multiple systems
to get precise data about your software delivery performance might not be
worth the initial investment." It recommends starting with team conversation
and DORA's own Quick Check tool instead. Source: [DORA's software delivery performance metrics](https://dora.dev/guides/dora-metrics/).

The 2025 DORA report ("State of AI-assisted Software Development") measured
AI's effect on these metrics, finding a stability cost alongside a
throughput gain: "AI improves throughput, but often at the cost of
stability if your foundation isn't solid." Source: [DORA 2025: Year in review](https://dora.dev/insights/dora-2025-year-in-review/).

Note: the exact quantitative figures reported around that finding (PR review
time, PR size, incident rate) came from secondary summaries of the report
(Faros AI, Honeycomb), not from a page this research reached directly on
dora.dev. Treat the direction of the finding as primary-sourced and the
specific percentages as secondary until verified against the report PDF
itself.

## 11. SAE J3016: an analogy source, not a software standard

SAE J3016 is included only as a structural analogy for a leveled autonomy
taxonomy. It is a vehicle automation standard, not a software or agent
standard, and no part of it is adopted by any coding-agent vendor in this
file.

| Level | Name | Who performs the driving task |
|---|---|---|
| 0 | No Driving Automation | The human driver does all the driving |
| 1 | Driver Assistance | The system assists with steering or with speed, not both at once |
| 2 | Partial Driving Automation | The system combines steering and speed control; the human must monitor at all times |
| 3 | Conditional Driving Automation | The system performs the whole driving task under set conditions; a human must be ready to retake control |
| 4 | High Driving Automation | The system performs the whole driving task within its design conditions, with no human fallback required inside them |
| 5 | Full Driving Automation | The system performs the whole driving task under all conditions a human driver could |

Source: [DOT HS 812 555, Human Factors Design Guidance for Level 2 and Level
3 Automated Driving Concepts](https://www.nhtsa.gov/sites/nhtsa.gov/files/documents/13494_812555_l2l3automationhfguidance.pdf)
(NHTSA), and [SAE updates J3016 automated-driving graphic](https://www.sae.org/news/2019/01/sae-updates-j3016-automated-driving-graphic).
The full standard text sits behind an SAE paywall at
[J3016_202104](https://saemobilus.sae.org/content/J3016_202104); this research
did not reach the full text, only NHTSA's and SAE's public summaries.

The one structural idea worth carrying into agent autonomy design: SAE marks
level 2 to level 3 as the line where the human stops monitoring continuously
and the system takes on the whole task. Source: same NHTSA document above.
An agent autonomy policy could name an equivalent line: below it, a human
reviews every action; above it, a human is on call for exceptions only.

## 12. Reversibility: what git and GitHub can and cannot undo

| Operation | Recoverable? | How | Source |
|---|---|---|---|
| Local commit, not yet pushed | Yes | `git reflog`, then `git reset` or `git checkout` to the recovered commit | [git-reflog](https://git-scm.com/docs/git-reflog) |
| `git reset --hard` locally | Yes, within the reflog window | `git reflog` finds the prior HEAD position | [git-reflog](https://git-scm.com/docs/git-reflog) |
| Commit made unreachable by reflog expiry | No | None; `git gc` prunes unreachable objects older than `gc.reflogExpireUnreachable` (default 30 days) | [git-reflog](https://git-scm.com/docs/git-reflog) |
| Force-pushed-over commits on a remote | Recoverable only briefly, and only if someone already has them | The commits become unreachable on the remote and `git gc` there removes them; "It can cause the remote repository to lose commits; use it with care" | [git-push](https://git-scm.com/docs/git-push) |
| Deleted GitHub repository | Yes, within 90 days | GitHub's own restore feature; team permissions are not restored | [Restoring a deleted repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/restoring-a-deleted-repository) |
| Deleted branch that was a pull request head | Yes, no documented time limit | "Restore branch" button on the closed pull request | [Deleting and restoring branches in a pull request](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-branches-in-your-repository/deleting-and-restoring-branches-in-a-pull-request) |
| Deleted GitHub release | Not documented either way | GitHub's docs give no statement on tag survival or recovery | [Managing releases in a repository](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository) (gap, see section 13) |
| Published npm package version | No | "Once you have unpublished a package, you will not be able to undo the unpublish"; the exact name-and-version can never be reused, even after removal | [npm unpublish policy](https://docs.npmjs.com/policies/unpublish) |

GitHub's branch protection rules are the documented way to contain blast
radius before an irreversible action happens, rather than after: by default,
GitHub "blocks force pushes on all protected branches" and "you cannot
delete a protected branch." An administrator can also restrict push access
to named users, teams, or apps. Source: [About protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches).

## 13. Measuring "percent of work done by the agent"

No primary source in this research defines a standard, audited metric for
the share of work an agent did. This is recorded as a real gap, not an
oversight in the search.

What is measured instead, by source:

| Source | What is actually measured | Status |
|---|---|---|
| DORA | Deployment frequency, lead time, change failure rate, recovery time — outcomes of the whole delivery pipeline, not agent attribution | Primary, [dora.dev](https://dora.dev/guides/dora-metrics/) |
| DORA 2025 report | PR review time, PR size, bug rate, incident rate, alongside self-reported AI adoption (such as "90% of developers use AI daily") | Primary claim of direction; specific figures reached only through secondary summaries in this research |
| Anthropic (informal) | An internal claim that "80%" or more of lines merged to production are attributable to Claude, by an internal attribution pipeline the company describes as having "gaps" | Secondary only; reported through Redwood Research's blog post citing Anthropic statements, not an Anthropic-published methodology page |
| GitHub (informal, per secondary reporting) | A mix of tool-usage signals, code-pattern heuristics, and self-reported AI-tool declarations, used to estimate AI-authored code across public GitHub | Secondary only; no GitHub methodology page was found |
| Academic (Science journal, per secondary reporting) | About 29% of GitHub Python functions in the U.S. are AI-written, using a statistical detection method | Secondary only; this research did not reach the paper itself |

None of these is a standard anyone can apply consistently across
organizations. Each depends on private instrumentation (Claude Code's own
attribution, GitHub's own heuristics) or a research method not published as
a reusable spec.

## 14. Gaps

- SAE J3016's full standard text (behind SAE's paywall). Only NHTSA's and
  SAE's public summaries were reached.
- OpenAI Codex's `docs/config.md` and `docs/sandbox.md` files in the
  `openai/codex` GitHub repository did not return usable content through
  automated fetch in this research; the `developers.openai.com` /
  `learn.chatgpt.com` docs were used instead, and Codex's docs describe a
  transition in progress from `sandbox_mode`/`approval_policy` to a newer
  `default_permissions`/`[permissions.<name>]` profile system. The exact
  current default and the full field list for the new system were not
  confirmed.
- Google Jules: no primary statement was found on network egress policy,
  on a pass/fail oracle for its plan-review step, or on a named threat
  model such as prompt injection. Jules's changelog and full docs tree were
  not fully read.
- GitHub's documentation on deleting a release states no policy on whether
  the underlying git tag survives, and no recoverability statement.
- GitHub's documentation on restoring a deleted branch that was never a
  pull request head (a plain `git push --delete`) was not found; only the
  pull-request-branch restore flow is documented.
- The 2025 DORA report's specific figures on PR review time, PR size, and
  incident rate were reached only through secondary summaries (Faros AI,
  Honeycomb), not by reading the report PDF directly.
- No primary source defines "percent of work done by an agent" as an
  audited, reproducible metric. Section 13 records this as a real gap.
- Anthropic's own attribution-pipeline methodology for "share of code
  written by Claude" has not been published as a citable methodology page;
  only informal statements, reported second-hand, were found.
- This research did not check the Anthropic Agent SDK's Python-specific
  package documentation separately from the general Agent SDK permissions
  page; behavior may differ in ways not captured here.
