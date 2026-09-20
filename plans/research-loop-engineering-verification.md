# Verification Gates for Agent-Driven Development

This file records primary-source findings on machine-checkable pass/fail
oracles, for the "loop engineering" design project. It answers, per source,
what loop runs, where the human sits, what the oracle is, and what failure
the gate names.

## Summary across all sources

| Source | Loop shape | Human placement | Oracle | Named failure |
|---|---|---|---|---|
| SWE-bench harness | Apply patch, run FAIL_TO_PASS + PASS_TO_PASS tests, compare to cached logs | None in the eval loop; humans built the dataset filter | All FAIL_TO_PASS and all PASS_TO_PASS tests report `PASSED` | A patch that does not fix the issue, or that breaks other tests |
| SWE-bench Verified | Same harness, on a screened 500-task subset | 93 software developers screened 1,699 samples before any model runs | Same test-based oracle, on tasks the screen kept | Underspecified issue text, unfair or unrelated unit tests |
| Hypothesis | Generate example, run test body, shrink on failure, repeat up to `max_examples` | None; the human writes the property once | An uncaught exception or failed assertion in the test body | An edge case the developer did not think to write as an example |
| Stryker / mutmut | Insert one mutant, rerun tests, mark killed or survived, repeat per mutant | None in the run; a human reads the surviving-mutant report | Mutant killed = a test failed; mutant survived = all tests passed | A passing suite that would not notice its subject changing behavior |
| GitHub branch protection / rulesets | Push or open PR, each required rule evaluates, merge blocks until all pass | Only on rule types that require a person (PR review, code owner, deployment approval) | Each rule's own reported state: check `success`/`skipped`/`neutral`, review `approved` | An incompatible or unreviewed change reaching the protected branch |
| GitHub merge queue | PR enters queue, GitHub builds a temporary merge group, required checks run against it, merges on pass | None inside the queue; a human already approved the PR before it entered | Required checks succeed against the merge group, not just the PR branch alone | Two PRs that each pass alone but conflict when combined |
| GitHub environment protection | Deployment job requests the environment, protection rules evaluate, job proceeds or waits | Required reviewers: a named person must approve the job before it runs | Reviewer's explicit approval, or a satisfied wait timer / branch rule | An unreviewed deployment to a sensitive environment |
| GitHub spec-kit | specify → clarify → plan → checklist → tasks → analyze → implement → converge, repeat until Converged | Human reviews the artifact after each `/speckit-*` skill call; checklists are "reviewer-owned" | `/speckit-converge` reports `Converged` when the codebase matches spec, plan, and tasks | A spec that generates code diverging from its own requirements |
| Pact | Consumer test generates a pact file, provider verifies it, `can-i-deploy` checks the matrix | None in the loop; humans write the consumer expectations once | Provider verification result plus `can-i-deploy` exit code (0 or 1) | A provider change that breaks a consumer's assumed contract |
| OpenAPI | Not a loop; a document plus tooling that validates requests/responses against it | None in validation; a human authors the spec document | Request/response conforms to the schema, or it does not | An API response that silently drifts from its documented shape |
| coverage.py | Run tests once under measurement, report executed vs. missed lines | None; a human reads the report | N/A — coverage.py names no pass/fail itself, only a percentage | Code that runs during tests but that no assertion checks |
| JaCoCo | Instrument bytecode, run tests, count instructions/branches/lines/methods executed | None; a human or a separate build rule sets a threshold | N/A — JaCoCo reports counters; a build tool must add the threshold | Same as coverage.py: execution is not correctness |
| Bazel hermeticity | Build/test action runs with a declared, sandboxed input set only | None; hermeticity is a build-system property, not a review step | A rebuild from the same inputs produces byte-identical output | A test that passes only because of host state outside the declared inputs |

## 1. SWE-bench and SWE-bench Verified

**Loop shape.** The harness checks out the base commit, applies the test
patch, applies the candidate patch (with an automatic repair retry if it
does not apply), runs the repository's test suite in a Docker container,
and parses the results.
[arxiv.org/html/2310.06770v3](https://arxiv.org/html/2310.06770v3), Section
A.4. A task counts as resolved only when "all FAIL_TO_PASS and PASS_TO_PASS
tests are found and have a pass status."
[arxiv.org/html/2310.06770v3](https://arxiv.org/html/2310.06770v3).

`FAIL_TO_PASS` is the set of tests that go from failing to passing once the
gold patch is applied; the validation engine checks that at least one such
test exists, "to ensure non-trivial tasks."
[arxiv.org/html/2310.06770v3](https://arxiv.org/html/2310.06770v3).
`PASS_TO_PASS` is the set of tests that keep passing after the gold patch,
"included to ensure that the revision does not break or violate any
existing expected behavior."
[arxiv.org/html/2310.06770v3](https://arxiv.org/html/2310.06770v3). Both
sets are computed by diffing a pre-patch test log against a post-patch test
log.

**Where the human sits.** The paper states: "we do not perform
crowdsourcing or recruit human task workers for any part of SWE-bench,
including its collection and evaluation procedures."
[arxiv.org/html/2310.06770v3](https://arxiv.org/html/2310.06770v3). Task
quality is filtered entirely by execution, not by human review, in the
original benchmark. This is the gap OpenAI's Verified effort later closed.

**Oracle.** Exact test names in `FAIL_TO_PASS` and `PASS_TO_PASS`, matched
against `PASSED` in the post-patch test log. The evaluation guide confirms:
"the evaluation is performed in a containerized Docker environment to
ensure consistent results across different platforms."
[SWE-bench evaluation.md](https://raw.githubusercontent.com/SWE-bench/SWE-bench/main/docs/guides/evaluation.md).

**Named failure.** A patch that does not make the required tests pass, or
that breaks a test that used to pass. Separately, the harness names
infrastructure failure as its own category: "instances with likely
infrastructure failures" and "instances with ambiguous failures," logged
apart from a genuine wrong patch.
[SWE-bench evaluation.md](https://raw.githubusercontent.com/SWE-bench/SWE-bench/main/docs/guides/evaluation.md).

**Filtering scale.** Of about 90,000 candidate pull requests crawled from
12 repositories, only 2,294 instances survived the fully automated
execution-based filter, which removed pull requests with failed patch
application, import errors in pre-solution tests, or no `FAIL_TO_PASS`
test at all.
[arxiv.org/html/2310.06770v3](https://arxiv.org/html/2310.06770v3), Table
10 and Section 2.

**No cost figures.** The paper reports no per-instance runtime, no total
compute, and no engineer-hours for building or running the harness.
Recorded as a gap below.

### SWE-bench Verified: why human validation was added

OpenAI states the problem directly: "The unit tests used to evaluate the
correctness of a solution are often overly specific, and in some cases are
even unrelated to the issue." A second problem: "Many samples have an
issue description that is underspecified, leading to ambiguity on what the
problem is." A third: environment setup sometimes "inadvertently caus[es]
unit tests to fail" for reasons unrelated to the candidate patch.
[OpenAI, Introducing SWE-bench Verified](https://openai.com/index/introducing-swe-bench-verified/).

**Scale of the human validation.** "We worked with 93 software developers
experienced in Python to manually screen SWE-bench samples for quality,"
evaluating 1,699 random samples against criteria that check whether "the
problem statement or the `FAIL_TO_PASS` unit tests filter out valid
solutions."
[OpenAI, Introducing SWE-bench Verified](https://openai.com/index/introducing-swe-bench-verified/).

**Fraction of broken oracles.** "Our annotation process resulted in 68.3%
of SWE-bench samples being filtered out due to underspecification, unfair
unit tests, or other issues."
[OpenAI, Introducing SWE-bench Verified](https://openai.com/index/introducing-swe-bench-verified/).
This is the single clearest primary number for "what fraction of tasks had
broken or underspecified oracles" in the whole research set.

**Effect on measured performance.** GPT-4o's resolve rate went from 16% on
the original SWE-bench to 33.2% on SWE-bench Verified with the
best-performing scaffold, showing that a broken oracle understated true
capability rather than overstated it.
[OpenAI, Introducing SWE-bench Verified](https://openai.com/index/introducing-swe-bench-verified/).

### False-accept evidence

A separate, independent empirical study directly measures how often the
test-based oracle marks a wrong patch as correct. "Are 'Solved Issues' in
SWE-bench Really Solved Correctly? An Empirical Study" found that, on
SWE-bench Verified, 7.8% of patches that the harness counted as resolved
were in fact incorrect, an inflation of the reported resolution rate by
6.2 absolute percentage points.
[arxiv.org/abs/2503.15223](https://arxiv.org/abs/2503.15223). The paper
also found that 29.6% of "plausible" patches behave differently from the
ground-truth patch, even when both pass the same test suite, because the
suite is "rarely exhaustive" and a patch "may pass the tests but
nevertheless fail to match the developers' expectations."
[arxiv.org/abs/2503.15223](https://arxiv.org/abs/2503.15223). This is
primary source evidence for the false-accept rate the brief asks about,
even though it is a follow-up paper rather than the original SWE-bench
paper.

## 2. Property-based testing: Hypothesis

**Loop shape.** For a test decorated with `@given`, Hypothesis generates a
random input from the declared strategy, runs the test body, and, on
failure, shrinks the input to a smaller failing case before reporting it.
By default it "generates 100 random inputs."
[Hypothesis quickstart](https://hypothesis.readthedocs.io/en/latest/quickstart.html).
The stopping rule for the generation phase is explicit: "once this many
satisfying test cases have been considered without finding any failing
test case, Hypothesis will stop looking," where "this many" is
`max_examples`, default 100.
[Hypothesis settings reference](https://hypothesis.readthedocs.io/en/latest/reference/api.html).

**What it verifies beyond an example test.** "You write tests which should
pass for all inputs in whatever range you describe, and let Hypothesis
randomly choose which of those inputs to check — including edge cases you
might not have thought about."
[Hypothesis documentation](https://hypothesis.readthedocs.io/en/latest/index.html).
An example-based test checks one input the author already thought of; a
property test checks the space the author described, and gets pushed
toward inputs the author did not think of.

**Where the human sits.** The human writes the property (the assertion)
and the input strategy once. Hypothesis generates and shrinks
automatically; the tool documentation does not describe any point where a
person reviews individual generated examples.

**Oracle.** An uncaught exception or a failed assertion inside the test
body, exactly as with an ordinary unit test; the difference is only the
input source.

**Named failure.** An edge case in the input space that a hand-written
example test never exercises. On failure, Hypothesis narrows to a minimal
failing input so the developer can read the smallest case that breaks the
property.
[Hypothesis changelog references shrinking](https://hypothesis.readthedocs.io/en/latest/changelog.html).

## 3. Mutation testing: Stryker and mutmut

**Loop shape.** "Bugs, or mutants, are automatically inserted into your
production code. Your tests are run for each mutant. If your tests fail
then the mutant is killed. If your tests passed, the mutant survived."
[Stryker documentation](https://stryker-mutator.io/docs/). mutmut follows
the same loop: generate one mutant (e.g. `<` to `<=`, an integer literal
incremented by one), run the suite, classify as killed or survived.
[mutmut documentation](https://mutmut.readthedocs.io/en/latest/).

**What it verifies beyond coverage.** Stryker's own analogy: coverage
"would tell you the bread is 80% covered with paste. Mutation testing, on
the other hand, would tell you it is actually chocolate paste and not...
well... something else."
[Stryker documentation](https://stryker-mutator.io/docs/). Coverage proves
a line executed; mutation testing proves an assertion would have noticed
if that line's behavior changed.

**Where the human sits.** Neither tool places a human inside the mutant
loop. A human sets the score threshold once, and reads the list of
surviving mutants after the run to add missing assertions.

**Oracle.** "The higher the percentage of mutants killed, the more
effective your tests are."
[Stryker documentation](https://stryker-mutator.io/docs/). Concretely,
Stryker's `thresholds` config sets three bands:

```json
"thresholds": { "high": 80, "low": 60, "break": 50 }
```

`mutation score >= high` reports green; `low <= score < high` reports a
warning; `score < low` reports danger; `score < break` makes Stryker exit
with code 1, failing the build. `break` defaults to `null`, so a fresh
Stryker install "never let[s] your build fail" until a threshold is set
explicitly.
[Stryker JS configuration reference](https://github.com/stryker-mutator/stryker-js/blob/master/docs/configuration.md).

**Named failure.** A test suite that passes with full line or branch
coverage but "tests nothing" — it executes the code without any assertion
capable of detecting a behavior change in it. Stryker frames this as the
gap between "covered" and "actually tested."
[Stryker documentation](https://stryker-mutator.io/docs/).

**Cost.** mutmut documents a per-mutant timeout formula: `(duration_of_
original_tests + timeout_constant) * timeout_multiplier` seconds, and
notes it "remembers work that has been done" to run incrementally rather
than from scratch each time.
[mutmut documentation](https://mutmut.readthedocs.io/en/latest/). Neither
tool's docs give an absolute runtime or compute figure; mutation testing's
cost scales with (number of mutants) × (full test-suite runtime), which is
an inference from the loop shape, not a stated number.

## 4. GitHub: branch protection, rulesets, merge queue, auto-merge, CODEOWNERS, environment protection

**Loop shape.** A push or pull request triggers every configured rule.
Required status checks "must have a `successful`, `skipped`, or `neutral`
status before collaborators can make changes to a protected branch," and
"all required status checks must pass before collaborators can merge
changes into the protected branch."
[About protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches).
A check must have "completed successfully in the chosen repository during
the past seven days," and "must pass on the latest commit SHA; checks from
earlier commits don't satisfy the requirement."
[Troubleshooting required status checks](https://docs.github.com/en/pull-requests/how-tos/merge-and-close-pull-requests/troubleshooting-required-status-checks).

**Which rules are machine-checkable, which need a human.** GitHub's own
ruleset rule catalog draws this line explicitly:

| Machine-checkable rule | What it checks automatically |
|---|---|
| Require status checks to pass before merging | CI/test job result |
| Require signed commits | Commit signature verification |
| Require linear history | Merge-commit shape |
| Block force pushes | Push type |
| Require secret scanning alerts resolved | Scanner state |
| Require code scanning results | Scanner alert severity |
| Restrict code coverage | Line coverage percentage |
| Restrict file paths / extensions / size | Diff contents |

| Human-required rule | Who must act |
|---|---|
| Require a pull request before merging | Author opens a PR; a named reviewer approves |
| Require review from code owners | The code owner named in `CODEOWNERS` |
| Require deployments to succeed before merging | Whoever runs/approves the deployment |

[Available rules for rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets).
This is a direct, primary-source answer to "exactly which gates can be
machine-satisfied and which need a human."

**Merge queue.** A merge queue "help[s] increase velocity by automating
pull request merges into a busy branch and ensuring the branch is never
broken by incompatible changes."
[Managing a merge queue](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue).
Loop: GitHub builds a temporary merge group combining the queued PR with
"the latest version of the base branch as well as changes from pull
requests ahead of it in the queue," dispatches a `merge_group` webhook
event, waits for CI, and "will merge all these changes into the base
branch once the checks required by the branch protections of the base
branch pass."
[Managing a merge queue](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue).
On failure, "the pull request will be removed from the queue," with the
reason shown on its timeline.
[Managing a merge queue](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue).
Named failure: two PRs that each pass CI alone but conflict once combined
— a semantic conflict a single-PR check cannot see.

**Auto-merge.** "Auto-merge merges a pull request automatically after all
required reviews and status checks pass," and disables itself "if someone
without write permissions pushes new changes to the head branch or if the
base branch is switched."
[Automatically merging a pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/automatically-merging-a-pull-request).

**CODEOWNERS.** "Code owners are automatically requested for review when
someone opens a pull request that modifies code that they own," and, once
required in branch protection, "any pull request that affects code with a
code owner must be approved by that code owner before the pull request
can be merged."
[About code owners](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners).
Pattern syntax follows `.gitignore` rules with "the last matching pattern
takes the most precedence," but `!` negation and `[ ]` character ranges
"do not work" in a CODEOWNERS file.
[About code owners](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners).
Why a human here: correctness of a diff is machine-checkable, but whether
the *right person* signed off on a sensitive path is a human judgment
GitHub does not attempt to automate.

**Environment protection rules.** "Required reviewers require a specific
person or team to approve workflow jobs that reference the environment,"
up to six people or teams, and "only one of the required reviewers needs
to approve the job for it to proceed."
[Managing environments for deployment](https://docs.github.com/actions/deployment/targeting-different-environments/using-environments-for-deployment).
A wait timer can additionally delay a job "for a specific amount of time
after the job is initially triggered," from 1 minute up to 30 days, and
"wait time will not count towards your billable time."
[Managing environments for deployment](https://docs.github.com/actions/deployment/targeting-different-environments/using-environments-for-deployment).
This is GitHub's explicit human gate before an irreversible action
(deployment), separate from the reversible-by-revert action of a merge.

**Example required-check config** (branch ruleset, conceptual shape drawn
from the rule catalog above): a ruleset naming `require_status_checks`
with a list of check contexts, `required_approving_review_count: 1`, and
`require_code_owner_review: true` together express "CI must pass and the
named owner must approve" as one machine-enforced rule set.
[Available rules for rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets).

## 5. Spec-driven development: GitHub spec-kit

**Loop shape.** The full path is: `/speckit-constitution` (once),
`/speckit-specify`, `/speckit-clarify`, `/speckit-plan`,
`/speckit-checklist`, `/speckit-tasks`, `/speckit-analyze`,
`/speckit-implement`, `/speckit-converge`.
[Spec Kit quickstart](https://raw.githubusercontent.com/github/spec-kit/main/docs/quickstart.md).
The stopping rule is explicit: "run `/speckit-implement` and converge
again until it reports Converged."
[Spec Kit quickstart](https://raw.githubusercontent.com/github/spec-kit/main/docs/quickstart.md).

**What is the contract.** "Specifications don't serve code — code serves
specifications... The specification becomes the primary artifact. Code
becomes its expression... in a particular language and framework."
[spec-driven.md](https://raw.githubusercontent.com/github/spec-kit/main/spec-driven.md).
"Debugging means fixing specifications and their implementation plans that
generate incorrect code."
[spec-driven.md](https://raw.githubusercontent.com/github/spec-kit/main/spec-driven.md).

**Where the human sits, and why.** The quickstart instructs: "Invoke each
`/speckit-*` skill separately in your agent's chat and review the result
before moving to the next step."
[Spec Kit quickstart](https://raw.githubusercontent.com/github/spec-kit/main/docs/quickstart.md).
The checklist step is explicitly a human-owned gate, not an
implementation-completeness signal: "These custom checklists are
reviewer-owned requirements-quality review artifacts: mark an item `[x]`
only when the reviewer determines that requirement-quality criterion is
satisfied. Checked custom items do not mean implementation work is
complete."
[Spec Kit quickstart](https://raw.githubusercontent.com/github/spec-kit/main/docs/quickstart.md).
`/speckit-implement` itself enforces this: "Before implementation, it
reads checklist checkbox state as a gate and asks before proceeding if any
checklist items are unchecked."
[Spec Kit quickstart](https://raw.githubusercontent.com/github/spec-kit/main/docs/quickstart.md).
Stated reason: checklists are "unit tests for your requirements," to
confirm the spec is "complete, clear, and consistent before you break the
work down"; this checks the requirement text, which a machine cannot judge
for completeness, so a reviewer must.
[Spec Kit quickstart](https://raw.githubusercontent.com/github/spec-kit/main/docs/quickstart.md).

**Oracle.** `/speckit-analyze` is "read-only" and reports "conflicts,
gaps, and ambiguities across spec.md, plan.md, and tasks.md"; it does not
gate by itself, but tells the human or agent to "fix them at the source
and re-run before implementing."
[Spec Kit quickstart](https://raw.githubusercontent.com/github/spec-kit/main/docs/quickstart.md).
`/speckit-converge` is the actual pass/fail oracle: it "checks the
codebase against the spec, plan, and tasks. If it finds gaps, it appends
new tasks to tasks.md," and the loop repeats until it reports Converged.
[Spec Kit quickstart](https://raw.githubusercontent.com/github/spec-kit/main/docs/quickstart.md).

**Named failure.** A specification precise enough to generate code, but
where the generated code has drifted from it; spec-kit calls this "the gap
between specification and implementation" that earlier processes tried
and failed to narrow rather than eliminate.
[spec-driven.md](https://raw.githubusercontent.com/github/spec-kit/main/spec-driven.md).

## 6. Contract testing: Pact and OpenAPI

**Loop shape (Pact).** "Contract testing is a technique for testing an
integration point by checking each application in isolation to ensure the
messages it sends or receives conform to a shared understanding that is
documented in a 'contract.'"
[Pact documentation](https://docs.pact.io/). The consumer's automated
tests generate a pact file; the provider verifies against it; before
deploy, `can-i-deploy` reads the "Matrix" of all consumer/provider
versions that have been verified against each other.
[Can I Deploy](https://docs.pact.io/pact_broker/can_i_deploy).

**Where the human sits.** None inside the verify/deploy loop. A human
writes the consumer's expectations once, as ordinary test code; everything
after that — contract generation, provider verification,
deploy-safety check — runs unattended.

**Oracle.** Exit code from `can-i-deploy`: 0, with "All required
verification results are published and successful," or 1, listing the
failed pairing.
[Can I Deploy](https://docs.pact.io/pact_broker/can_i_deploy). "The
`can-i-deploy` tool should be added to your consumer deployment script,
before you do the actual deployment. If all the pacts for the given
consumer version are not successfully verified the command will exit with
an error code."
[Can I Deploy](https://docs.pact.io/pact_broker/can_i_deploy).

**Named failure.** A provider change that breaks a consumer's actual usage
pattern, without the two services ever running together in a full
end-to-end test. Pact's own framing: it only tests "parts of the
communication that are actually used by the consumer(s)," in contrast to a
full schema that "describe[s] all possible states."
[Pact documentation](https://docs.pact.io/).

**OpenAPI as a static contract.** OpenAPI is not a loop; it is a document.
"The OpenAPI Specification (OAS) defines a standard, programming
language-agnostic interface description for HTTP APIs, which allows both
humans and computers to discover and understand the capabilities of a
service without requiring access to source code, additional
documentation, or inspection of network traffic."
[OpenAPI Specification v3.1.0](https://spec.openapis.org/oas/v3.1.0.html).
Tooling built on top of the document (validators, mock servers, contract
diff tools) supplies the actual pass/fail check; the spec itself only
defines the shape being checked against.

## 7. Coverage as a gate: coverage.py and JaCoCo

**What each tool measures.** "Coverage.py is a tool for measuring code
coverage of Python programs. It monitors your program, noting which parts
of the code have been executed, then analyzes the source to identify code
that could have been executed but was not."
[Coverage.py documentation](https://coverage.readthedocs.io/en/latest/index.html).
JaCoCo counts at several granularities: "the smallest unit JaCoCo counts
are single Java byte code instructions"; it separately counts branches,
lines, methods, and classes, and calculates cyclomatic complexity per
method "as an indication for the number of unit test cases to fully cover
a certain piece of software."
[JaCoCo counters](https://www.jacoco.org/jacoco/trunk/doc/counters.html).

**What each tool says it does not measure.** Coverage.py's own FAQ states
plainly: "It's good, but it isn't perfect," and elsewhere frames its
purpose narrowly: "coverage measurement is typically used to gauge the
effectiveness of tests. It can show which parts of your code are being
exercised by tests, and which are not."
[Coverage.py FAQ](https://coverage.readthedocs.io/en/latest/faq.html).
Neither statement claims coverage says anything about correctness; the
tool reports execution, not verification. JaCoCo's docs note concrete
blind spots: "exception handling is not considered as branches," and
compiler-generated synthetic code "sometimes results in unexpected code
coverage results."
[JaCoCo counters](https://www.jacoco.org/jacoco/trunk/doc/counters.html).

**Oracle.** Neither tool defines pass/fail on its own; each reports a
percentage or a count. GitHub's own ruleset catalog does turn coverage
into a gate directly: "Restrict code coverage" blocks a merge "based on
line coverage percentages."
[Available rules for rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets).
This is an inference bridge, not a coverage.py or JaCoCo claim: the
threshold is set by the build tool wrapping the coverage report, not by
the coverage tool itself.

**Named failure.** Code that runs during a test but that no assertion in
that test actually checks — the same gap mutation testing is built to
close. Neither coverage.py's nor JaCoCo's own docs name this gap in those
words; it is drawn here as the direct implication of "executed" versus
"checked," combining the coverage.py FAQ statement above with the Stryker
statement in Section 3.

## 8. Deterministic verification: Bazel hermeticity

**What hermeticity means.** "Given the same input source code and product
configuration, a hermetic build system always returns the same output by
isolating the build from changes to the host system."
[Bazel: Hermeticity](https://bazel.build/basics/hermeticity).

**Why it matters for a trustworthy oracle.** "Hermetic builds are good for
troubleshooting because you know the exact conditions that produced the
build," which depends on the build being "insensitive to libraries and
other software installed on the local or remote host machine."
[Bazel: Hermeticity](https://bazel.build/basics/hermeticity). A hermetic
build avoids "services external to the build environment," non-
deterministic outputs such as timestamps or build IDs, and "system
binaries that differ across hosts."
[Bazel: Hermeticity](https://bazel.build/basics/hermeticity).

**Named failure.** A test that passes only because of host state outside
its declared inputs — a stale cache, an installed system library, an
absolute path, or the wrong day's timestamp. Bazel's docs frame the
underlying risk as a build that fails "null sequential builds": a rebuild
from the same source should not regenerate a different output, and if it
does, past pass/fail results were never trustworthy signals of the code
alone.
[Bazel: Hermeticity](https://bazel.build/basics/hermeticity).

**Loop shape / where the human sits.** Hermeticity is a property enforced
by declaring every input and running inside a sandbox, not a review step.
No human involvement is described in this document; it is a structural
precondition for trusting any of the other oracles in this file.

## Copyable configurations found

**Stryker mutation-score gate** (fails the build below the break
threshold):

```json
"thresholds": { "high": 80, "low": 60, "break": 50 }
```

[Stryker JS configuration](https://github.com/stryker-mutator/stryker-js/blob/master/docs/configuration.md).

**mutmut per-mutant timeout formula:**

```
timeout = (duration_of_original_tests + timeout_constant) * timeout_multiplier
```

[mutmut documentation](https://mutmut.readthedocs.io/en/latest/).

**Hypothesis example-count setting:**

```python
from hypothesis import settings

@settings(max_examples=100)  # default; stop once this many pass with no failure
def test_property(...):
    ...
```

Default value and stopping rule confirmed at
[Hypothesis settings reference](https://hypothesis.readthedocs.io/en/latest/reference/api.html).

**Pact deploy-safety check:**

```bash
pact-broker can-i-deploy \
  --pacticipant Consumer --version 1.2.3 \
  --to-environment production
# exit 0: "Computer says yes"; exit 1: "Computer says no", blocks the deploy script
```

[Can I Deploy](https://docs.pact.io/pact_broker/can_i_deploy).

**spec-kit convergence loop (shell form of the stated workflow):**

```text
/speckit-implement
/speckit-converge
# repeat both until /speckit-converge reports "Converged"
```

[Spec Kit quickstart](https://raw.githubusercontent.com/github/spec-kit/main/docs/quickstart.md).

## Cost figures found

| Source | Cost figure | Source URL |
|---|---|---|
| SWE-bench Verified screening | 93 developers screened 1,699 samples by hand | [OpenAI announcement](https://openai.com/index/introducing-swe-bench-verified/) |
| Hypothesis | 100 generated examples per property, by default | [Hypothesis settings](https://hypothesis.readthedocs.io/en/latest/reference/api.html) |
| Mutation testing (general) | Cost scales as (mutant count) × (full suite runtime); no absolute figure stated | Inference from [Stryker](https://stryker-mutator.io/docs/) and [mutmut](https://mutmut.readthedocs.io/en/latest/) loop shape |
| GitHub environment wait timer | 1 to 43,200 minutes (30 days) configurable delay; wait time is not billed | [Managing environments for deployment](https://docs.github.com/actions/deployment/targeting-different-environments/using-environments-for-deployment) |
| GitHub environment reviewers | Up to 6 named reviewers; only 1 approval needed | [Managing environments for deployment](https://docs.github.com/actions/deployment/targeting-different-environments/using-environments-for-deployment) |
| GitHub rulesets | Up to 75 rulesets per repository, 75 more organization-wide | [About rulesets](https://docs.github.com/en/enterprise-cloud@latest/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets) |
| SWE-bench harness runtime | Not stated in the paper or the evaluation guide | Recorded as a gap below |

## Gaps

- No primary source gave a per-instance or total runtime/compute figure
  for the SWE-bench evaluation harness. The paper and the harness's own
  evaluation guide describe the procedure but state no timing numbers.
- Could not confirm from Hypothesis's own docs whether shrinking is
  described as a distinct named phase with its own guarantees (e.g. a
  bound on shrink iterations); only changelog fragments were reachable,
  not a dedicated conceptual page.
- Could not reach the Stryker or mutmut pages stating a documented,
  first-party runtime cost (e.g. "N times slower than your test suite").
  Both docs claim to be fast or incremental but give no number.
- Could not open `docs.github.com`'s dedicated "About status checks"
  page (returns 404 at every URL form tried); the strict-vs-loose
  distinction and the exact quote for it come from the "About protected
  branches" page instead, which covers the same ground less precisely.
- Bazel's hermeticity page does not give a concrete engineer-hour or
  compute cost for adopting hermetic builds or tests.
- Could not reach JaCoCo's own page (if one exists) recommending a
  specific coverage threshold; the docs describe counters only, with no
  stated target percentage.
- The OpenAPI Specification's own text does not describe a specific
  validation loop (a request/response validator is third-party tooling,
  not part of the spec document itself); no first-party OpenAPI validator
  reference was checked in this pass.
- Did not verify GitHub's exact wording for the difference between
  "strict" and "loose" required status checks with a direct quotation;
  only a paraphrase was recovered.
