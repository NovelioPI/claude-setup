# Loop Engineering: A Development System at 95% Agent Execution

This file merges three primary-source research passes into one design. It
states what the evidence supports, what it rules out, and what to build first.

Detail files:

| File | Area |
|---|---|
| `research-loop-engineering-mechanics.md` | How five production harnesses shape their loop |
| `research-loop-engineering-verification.md` | Machine-checkable pass and fail oracles |
| `research-loop-engineering-autonomy.md` | Permission policy, blast radius, measurement |

## The finding that decides the design

No production coding-agent harness ships a pass or fail oracle. Every one
stops when the model stops, or when a human reads the diff.

| System | What decides "done" | Source |
|---|---|---|
| Claude Agent SDK | A turn with zero tool calls | [Agent loop](https://code.claude.com/docs/en/agent-sdk/agent-loop) |
| Claude Code, structured output | JSON Schema validation, with bounded retries | [Headless mode](https://code.claude.com/docs/en/headless) |
| OpenAI Codex | The model's own judgment; no documented oracle | [Agent approvals](https://learn.chatgpt.com/docs/agent-approvals-security) |
| Google Jules | Retry, then mark failed and notify | [Jules FAQ](https://jules.google/docs/faq/) |
| GitHub Copilot coding agent | The repository's own build and test commands, then human review | [Best practices](https://docs.github.com/copilot/how-tos/agents/copilot-coding-agent/best-practices-for-using-copilot-to-work-on-tasks) |

Reason: the harness is generic, so the oracle has to come from the repository.

A loop engineering system is therefore not a better agent. It is the oracle,
the gate, and the feedback path that the harness leaves to you.

## 1. The six stages, and who owns each

| Stage | Job | Owner today | Owner at 95% | Moved by |
|---|---|---|---|---|
| Intake | Turn intent into a task row with an acceptance condition | human | human | nothing |
| Plan | Pick the change | agent | agent | already moved |
| Execute | Edit code | agent | agent | already moved |
| Verify | Prove the change works | human eye | machine gate | the oracle |
| Accept | Merge or release | human token | written policy | the gate ladder |
| Learn | Stop the failure repeating | nobody | hook, rule, or test | loop memory |

Only Verify and Accept need to move. Intake stays human, and that is the 5%.

## 2. The oracle is hard, and the evidence says how hard

A test suite is the only oracle any source treats as authoritative. The same
sources measure how often it is wrong.

| Measurement | Value | Source |
|---|---|---|
| SWE-bench samples filtered out as underspecified or unfairly tested | 68.3% of 1,699 | [SWE-bench Verified](https://openai.com/index/introducing-swe-bench-verified/) |
| Developers needed to do that screening | 93 | [SWE-bench Verified](https://openai.com/index/introducing-swe-bench-verified/) |
| Patches marked resolved on Verified that were actually wrong | 7.8% | [arxiv 2503.15223](https://arxiv.org/abs/2503.15223) |
| Reported resolution rate inflated by those wrong patches | 6.2 points | [arxiv 2503.15223](https://arxiv.org/abs/2503.15223) |

Read the first row as the cost of the oracle. Two thirds of naturally
occurring tasks carried no usable pass condition until humans wrote one.

Read the third row as the residual. Even a screened, test-backed oracle
accepts a wrong change about one time in thirteen.

### What each candidate oracle actually checks

| Oracle | Checks | Does not check |
|---|---|---|
| Test suite | The assertions someone wrote | Anything nobody asserted |
| `coverage.py`, JaCoCo | Which lines ran | Whether any assertion looked at them |
| Mutation score | Whether the suite notices its subject changing | Whether the subject is correct |
| Hypothesis property | A stated invariant over generated inputs | Invariants nobody stated |
| Pact, OpenAPI | Interface shape between two parties | Behavior behind the interface |
| Bazel hermeticity | Same inputs give byte-identical output | Whether the output is right |

Sources: [coverage.py](https://coverage.readthedocs.io/),
[JaCoCo](https://www.jacoco.org/jacoco/trunk/doc/),
[Stryker](https://stryker-mutator.io/docs/),
[Hypothesis](https://hypothesis.readthedocs.io/),
[Pact](https://docs.pact.io/),
[Bazel](https://bazel.build/basics/hermeticity).

Mutation score is the only listed measure that grades the oracle itself.
Stryker's shipped default thresholds are `high: 80`, `low: 60`, `break: null`.

Risk: if the gate uses coverage, then the loop accepts code that ran and
proved nothing.

## 3. The gate ladder, grounded in reversibility

Autonomy should follow what can be undone, not what feels safe. The git and
GitHub documentation gives a concrete ordering.

| Operation | Recoverable | How | Gate |
|---|---|---|---|
| Local commit | yes | `git reflog` | auto |
| `git reset --hard`, local | yes, inside the reflog window | `git reflog` | auto |
| Unreachable commit after reflog expiry | no | none; `gc` prunes after 30 days by default | ask |
| Force push over remote commits | briefly, and only if a copy exists | none once the remote runs `gc` | ask |
| Deleted GitHub repository | yes, within 90 days | GitHub restore; permissions are lost | ask |
| Deleted pull request head branch | yes, no stated limit | "Restore branch" on the closed pull request | auto |
| Deleted GitHub release | not documented | unknown | ask |
| Published npm version | no | none; the name and version can never be reused | human |

Sources: [git-reflog](https://git-scm.com/docs/git-reflog),
[git-push](https://git-scm.com/docs/git-push),
[restoring a deleted repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/restoring-a-deleted-repository),
[npm unpublish policy](https://docs.npmjs.com/policies/unpublish).

Three rungs follow from the table.

| Rung | Condition | Who decides |
|---|---|---|
| Auto | Reversible, and the oracle passed | the gate |
| Ask | Reversible only inside a window, or recovery loses data | the human, per use |
| Human | No recovery path exists | the human, always |

## 4. Mechanisms already available, by name

Claude Code supplies the enforcement layer. None of it needs to be built.

| Need | Mechanism | Note |
|---|---|---|
| Deny before the model sees a choice | `permissions.deny` | Evaluated first, before `ask` and `allow` |
| Enforce a project rule | `PreToolUse` hook | 33 hook events documented |
| Run with nobody watching | `--permission-prompts none` | For "a scheduled job", per the docs |
| Cap spend | `maxBudgetUsd` | Stops running background subagents |
| Cap delegation | `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` | Default 3 |
| Cap idle background work | `CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS` | Default 10 minutes |
| Locked-down autonomy | `dontAsk` mode | Pre-approved tools run; anything else is denied, not prompted |
| Structured result | `--json-schema` | Validated, with bounded retries |

Source: [permissions](https://code.claude.com/docs/en/permissions),
[headless mode](https://code.claude.com/docs/en/headless),
[agent loop](https://code.claude.com/docs/en/agent-sdk/agent-loop).

`dontAsk` is the correct mode for an unattended loop. It fails closed: an
action outside the allow list is denied, so the run stops instead of waiting.

Never use `bypassPermissions` outside a disposable container. The docs call
for "extreme caution" and full system access.

### The merge gate belongs to GitHub, not to the agent

| Rule | Machine-checkable |
|---|---|
| Required status checks | yes |
| Signed commits | yes |
| Coverage restriction | yes |
| Merge queue passing against the merge group | yes |
| Pull request review | no |
| Code owner review | no |
| Deployment environment approval | no |

Source: [available rules for rulesets](https://docs.github.com/en/enterprise-cloud@latest/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets).

The merge queue matters for a parallel agent fleet. It runs the required
checks against a temporary merge group, not against each branch alone.

Risk: if many agents merge in parallel without a queue, then two changes that
each pass alone break the branch together.

## 5. The 95% target cannot be measured today

No primary source defines the share of work an agent did. This is a gap in
the field, not a gap in the search.

| Source | What it measures | Status |
|---|---|---|
| DORA | Deployment frequency, lead time, change failure rate, recovery time | primary |
| DORA 2025 report | Throughput rises; stability falls where the foundation is weak | direction primary, figures secondary |
| Anthropic | An internal lines-attribution claim, with stated gaps | secondary only |
| GitHub | Usage signals and code heuristics | secondary only |

Source: [dora.dev](https://dora.dev/guides/dora-metrics/).

DORA's change failure rate is the honest counterweight. Raising agent
throughput while that rate climbs is not progress.

Next: define the denominator before claiming a percentage. A defensible one
is the share of merged pull requests that reached `main` with no human commit
on the branch.

## 6. The conflict with the current workflow contract

`CLAUDE.md` demands an approval token for every mutating tool call. That rule
and a 95% target cannot both hold.

| Element | Current rule | Needed for the loop |
|---|---|---|
| Approval unit | one token, one plan | one token, one task class |
| Scope | the plan shown | the allow list and the oracle |
| Trigger to stop | any new scope | a failed gate |

Two designs resolve it, and only one is safe.

| Design | How | Verdict |
|---|---|---|
| Widen the token to cover a session | One approval, unbounded actions | ❌ removes the gate, keeps no oracle |
| Move the gate from the turn to the task class | Approve an allow list and an oracle once, per class of task | ✅ the gate survives, the human leaves the turn |

The second design keeps `fail closed`. An action outside the approved class
still stops the run.

## 7. Build order

| Step | Build | Reason it comes here |
|---|---|---|
| 1 | An acceptance condition field on every task row | Without it, nothing downstream can decide pass or fail |
| 2 | One repository command that returns the verdict | The gate needs a single exit code, not a report |
| 3 | A mutation-score check on the files the task touched | It grades the oracle from step 2 |
| 4 | The three-rung gate ladder as `permissions` plus a `PreToolUse` hook | Enforcement, not advice |
| 5 | `dontAsk` headless runs behind that ladder | The loop finally runs unattended |
| 6 | A merge queue with required checks | Parallel agents stop breaking each other |
| 7 | A rule that every human correction becomes a hook, rule, or test | The 5% shrinks over time |

Do not build an orchestrator, a queue service, or a dashboard before step 5.
They schedule a loop that cannot yet tell pass from fail.

## Background

The 68.3% filter rate in SWE-bench Verified is the single most useful number
here, because it measures the thing the design depends on. It says that most
real tasks, drawn from real repositories with real test suites, did not carry
a usable machine-checkable pass condition until people wrote one by hand.

The implication is direct. An agent can be given the Execute stage for free,
because the harness already does that. The Verify stage has to be paid for,
once per task class, in human effort spent writing acceptance conditions and
grading the suite that checks them. Loop engineering is the practice of
paying that cost deliberately, up front, instead of paying it forever as diff
review.

## Gaps

| Question | Why it is open |
|---|---|
| Runtime cost of a mutation-testing gate | No first-party figure from Stryker or mutmut |
| Runtime cost of the SWE-bench harness | Not stated in the paper or the evaluation guide |
| Whether a deleted GitHub release keeps its tag | GitHub's docs are silent |
| Exact wording of strict versus loose required checks | The GitHub page returns 404 at every URL tried |
| Codex's newer permission-profile system | A transition is in progress; the full spec was not confirmed |
| Google Jules network policy and threat model | No published document found |
| Reason for Copilot's 59-minute execution cap | Unstated in the source |
| A citable method for "percent of work done by the agent" | None exists, including from Anthropic |

Each detail file carries its own longer gaps list.
