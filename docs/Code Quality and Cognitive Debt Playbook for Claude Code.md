# Code Quality and Cognitive Debt Playbook for Claude Code

Oct 5, 2026 · @Novel

Make quality mechanical and understanding deliberate: hooks, protected tests and fitness checks enforce quality so the agent cannot skip it, while an ownership map, explain-back gates and scheduled repayment keep the theory of the system in your head. Companion to Doc and Doc.

## Part 1: Code quality — the layered stack

The agent optimizes for whatever signal you give it, so quality depends on three things: a strong verification signal, protection against tampering with it, and checks aimed at typical agent failure modes. Cheap checks run on every edit; expensive ones run per turn, per task or per PR.

| Layer | Runs when | Catches | Step |
| --- | --- | --- | --- |
| Format + fast lint | After every edit (PostToolUse) | Style, unused code, obvious bugs | 1 |
| Types + related tests | End of turn (Stop) | Interface breaks, regressions | 2 |
| Signal protection | Before edits (PreToolUse) | Test and baseline tampering | 3 |
| Test strength | Per feature, core modules | Weak tests that pass broken code | 4 |
| Architecture fitness | Pre-commit + CI | Boundary violations, bloat, duplication | 5 |
| Independent review | Per task diff | Logic, error handling, security, I/O waste | 6 |

All three hooks go in `.claude/settings.json`. Merge this into the `hooks` object from the Context Management guide (PreCompact and SessionStart stay as they are):

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Write|Edit|MultiEdit",
        "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/protect-signal.sh" }] }
    ],
    "PostToolUse": [
      { "matcher": "Write|Edit|MultiEdit",
        "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/post-edit.sh" }] }
    ],
    "Stop": [
      { "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/stop-gate.sh" }] }
    ]
  }
}
```

Hook contract used throughout: exit code 2 blocks (or, after the fact, flags) the action and sends stderr back to Claude so it knows what to fix. Any other non-zero code is an error that does not block. The hook scripts themselves need only `jq` and `git`; every language-specific command goes through one adapter script, `.claude/quality.sh` (Step 0). The hooks only see Claude's built-in edit tools, so keep other editing tools (such as Serena's) disabled; see the Context Management guide, Step 10.

## Step 0: Language adapter

Hooks, pre-commit and CI never call a formatter, linter or test runner directly. They call `.claude/quality.sh`, the only file that knows which languages the repo uses, so the same hooks work for Python, TypeScript, Go, Rust or a mix. Keep a branch for each language you use and delete the rest.

Tools per language (pick one per cell):

| Language | Format | Lint | Types / compile | Fast tests |
| --- | --- | --- | --- | --- |
| Python | ruff format | ruff check | mypy or pyright | pytest -q -x |
| JavaScript / TypeScript | Biome (biome format) | Biome (biome lint) | tsc --noEmit | Vitest or Jest |
| Go | gofmt / goimports | go vet, golangci-lint | go build | go test -short |
| Rust | rustfmt | clippy | cargo check | cargo test |
| Java / Kotlin | google-java-format / ktlint | Checkstyle, PMD / detekt | Gradle or Maven compile | Gradle or Maven unit tests |
| C# | dotnet format | Roslyn analyzers | dotnet build | dotnet test |

`.claude/quality.sh` (Python, TypeScript, Go and Rust branches shown; `chmod +x` it):

```bash
#!/usr/bin/env bash
# The only file that knows your languages. Hooks, pre-commit and CI call it.
# usage: quality.sh is-source|is-test|format|lint <file>
#        quality.sh typecheck|test-fast <files...>
#        quality.sh boundaries | suppress-pattern
set -uo pipefail
cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}"
cmd=${1:-}; shift || true
has() { printf '%s\n' "$@" | grep -qE "$PAT"; }   # call as: PAT=<regex> has "$@"
rc=0

case "$cmd" in
  is-source) [[ "$1" =~ \.(py|ts|tsx|js|jsx|go|rs)$ ]] ;;
  is-test)   case "$1" in
               tests/*|test/*|*/tests/*|*/test/*|*/__tests__/*|*.test.*|*.spec.*|\
               *_test.go|*_test.py|test_*.py|*/test_*.py) exit 0 ;;
               *) exit 1 ;;
             esac ;;
  format)    case "$1" in
               *.py) ruff format --quiet "$1" ;;
               *.ts|*.tsx|*.js|*.jsx) npx biome format --write "$1" ;;
               *.go) gofmt -w "$1" ;;
               *.rs) rustfmt "$1" ;;
             esac ;;
  lint)      case "$1" in
               *.py) ruff check --fix --quiet "$1" ;;
               *.ts|*.tsx|*.js|*.jsx) npx biome lint --write "$1" ;;
               *.go) go vet "./$(dirname "$1")" ;;
               *.rs) : ;;   # clippy is crate-wide, so it runs in typecheck
             esac ;;
  typecheck) PAT='\.py$'       has "$@" && { mypy $(printf '%s\n' "$@" | grep '\.py$') || rc=1; }
             PAT='\.(ts|tsx)$' has "$@" && { npx tsc --noEmit || rc=1; }
             PAT='\.go$'       has "$@" && { go build ./... || rc=1; }
             PAT='\.rs$'       has "$@" && { cargo clippy --quiet -- -D warnings || rc=1; }
             exit $rc ;;
  test-fast) PAT='\.py$'               has "$@" && { pytest -q -x tests/unit || rc=1; }
             PAT='\.(ts|tsx|js|jsx)$'  has "$@" && { npx vitest run --changed || rc=1; }
             PAT='\.go$'               has "$@" && { go test -short ./... || rc=1; }
             PAT='\.rs$'               has "$@" && { cargo test --quiet || rc=1; }
             exit $rc ;;
  boundaries) # enable the checker for each language you use (Step 5)
             # lint-imports || rc=1                                         # Python
             # npx depcruise src --config .dependency-cruiser.cjs || rc=1   # JS/TS
             exit $rc ;;
  suppress-pattern)
             echo 'noqa|type: ignore|biome-ignore|@ts-ignore|@ts-expect-error|nolint|#\[allow\(|@SuppressWarnings' ;;
  *)         echo "unknown command: $cmd" >&2; exit 64 ;;
esac
```

To add a language, extend `is-source` with its file extension, `is-test` with its test-file naming convention, and add one line to each of `format`, `lint`, `typecheck` and `test-fast`. Only languages present in the changed files are checked, so a mixed repo pays only for what changed.

Check: `.claude/quality.sh is-test src/cart.test.ts && echo protected` prints `protected`, and `.claude/quality.sh typecheck <a changed file>` runs the right checker.

## Step 1: Per-edit gate

Format and lint only the file just edited, so the hook finishes in well under a second. Anything slower belongs in the Stop gate, because this hook runs after every single edit.

`.claude/hooks/post-edit.sh`:

```bash
#!/usr/bin/env bash
# Format + lint the edited file only. Exit 2 sends lint errors back to Claude.
f=$(jq -r '.tool_input.file_path // empty')
cd "$CLAUDE_PROJECT_DIR"
rel=${f#"$CLAUDE_PROJECT_DIR"/}
q=.claude/quality.sh
[ -f "$rel" ] && "$q" is-source "$rel" || exit 0
"$q" format "$rel" >/dev/null 2>&1
if ! out=$("$q" lint "$rel" 2>&1); then
  printf 'Lint errors in %s (fix before continuing):\n%s\n' "$rel" "$out" >&2
  exit 2
fi
```

1. Save the script and run `chmod +x .claude/hooks/post-edit.sh`.
2. Check: ask Claude to add a function with an unused import. The import should be removed automatically, and a real lint error (e.g. an undefined name) should come back to Claude as feedback.

## Step 2: End-of-turn gate

When Claude tries to finish a turn that changed source files, type-check the changed files and run the fast unit suite. Block it once if they fail, so Claude fixes the problem instead of reporting success.

`.claude/hooks/stop-gate.sh`:

```bash
#!/usr/bin/env bash
# Block finishing ONCE if checks fail. stop_hook_active=true means we already blocked.
set -o pipefail
input=$(cat)
[ "$(echo "$input" | jq -r '.stop_hook_active')" = "true" ] && exit 0
cd "$CLAUDE_PROJECT_DIR"
[ -f .agent/.skip-gate ] && exit 0   # /handoff in progress (Context guide, Step 5)
q=.claude/quality.sh
changed=$( { git diff --name-only HEAD; git ls-files --others --exclude-standard; } |
           while read -r f; do [ -f "$f" ] && "$q" is-source "$f" && echo "$f"; done )
[ -z "$changed" ] && exit 0          # conversational turn: nothing to check
out=$( { "$q" typecheck $changed && "$q" test-fast $changed; } 2>&1 | tail -40 )
if [ $? -ne 0 ]; then
  printf 'Quality gate failed. Fix before finishing (do not edit tests):\n%s\n' "$out" >&2
  exit 2
fi
```

Design notes:

- The `stop_hook_active` check prevents an infinite loop. If checks still fail on the second attempt, Claude stops and must report the failure to you.
- Skipping turns with no changed source files keeps question-and-answer turns instant.
- `tail -40` caps the feedback so a long failure does not flood the context.
- The gate only sees uncommitted changes. If Claude commits within the turn, the pre-commit hooks from Step 5 cover it.
- If the fast suite takes more than \~30 seconds, narrow `test-fast` in quality.sh to tests affected by the change (for example `pytest --testmon`, `vitest --changed`, `go test` on changed packages, `cargo test -p <crate>`) and leave the full suite to CI.

One deliberate escape hatch. `/handoff` creates `.agent/.skip-gate` so a mid-task handoff is not blocked by red tests, and `session-start.sh` deletes it.

Run parallel sessions only in separate git worktrees. In a shared checkout, the gate would see and fail on the other session's changes.

Check: introduce a type error through Claude. It should be blocked once, fix the error, then finish.

## Step 3: Protect the verification signal

Tests, golden datasets and eval thresholds are the signal the agent is graded against, so make them read-only while it implements. Benchmarks such as EvilGenie and SpecBench have observed coding agents editing tests and hardcoding expected outputs.

1. Add the guard `.claude/hooks/protect-signal.sh`:

```bash
#!/usr/bin/env bash
# Tests and eval baselines are read-only unless the session's TASK_MODE allows them.
f=$(jq -r '.tool_input.file_path // empty')
cd "$CLAUDE_PROJECT_DIR"
rel=${f#"$CLAUDE_PROJECT_DIR"/}
mode=${TASK_MODE:-impl}
case "$rel" in
  tests/holdout/*) ;;                                              # never editable by the agent
  evals/golden/*|configs/eval_thresholds.yaml) [ "$mode" = "baseline" ] && exit 0 ;;
  *) .claude/quality.sh is-test "$rel" || exit 0                   # not a test file: allow
     [ "$mode" = "tests" ] && exit 0 ;;
esac
echo "BLOCKED: $rel is part of the verification signal and is read-only in TASK_MODE=$mode. If it looks wrong, stop and explain why instead of editing it." >&2
exit 2
```

2. Split roles across sessions. Write or approve tests in a session started with `TASK_MODE=tests claude`, then implement in a normal session. One session should never change both the tests and the code under test. The workflow doc's /plan-feature creates these as paired tasks (T\<n>-test, then T\<n>-impl).
3. Add the execution rules to the root CLAUDE.md. The first rule matters most: in ImpossibleBench, a single "stop if tests are flawed" instruction cut one model's test-gaming rate from 93% to 1%.

```markdown
## Execution rules
- If a test, spec or eval threshold looks wrong, STOP and report. Never edit tests,
  special-case inputs, or weaken assertions to make them pass.
- Prefer restructuring existing code over layering new branches onto it.
  If a function passes ~50 lines, refactor before adding to it.
- Keep each task's diff reviewable: aim for <300 changed lines; split otherwise.
- No new dependencies, public API changes or schema changes without asking.
- No silent error handling: no empty catch/except blocks, swallowed errors, or fallback
  defaults that hide failures.
- Ambiguous requirement: ask one question instead of guessing.
- End each task with: what changed, why, and what you were unsure about.
```

Known gap: the hook covers Claude's edit tools, not shell commands such as `sed -i` or redirects. The reviewer in Step 6 checks `git diff --stat` for any changes under protected paths, which closes most of that gap.

Tests that live inside source files, such as Rust `#[cfg(test)]` modules or doctests, cannot be protected by path. The reviewer's tampering check covers them; for Core code, consider moving acceptance tests into separate test files (for Rust, the `tests/` directory).

Session modes used across all three docs (set by the `ccf` launcher in the workflow doc):

| TASK\_MODE | Used for | Editable protected paths | Stop gate |
| --- | --- | --- | --- |
| impl (default) | Implementation tasks | None | Types + fast tests |
| tests | Writing or approving acceptance tests | Test files (as defined by `quality.sh is-test`), except `tests/holdout/` | Types + fast tests |
| baseline | Updating golden data or eval thresholds (rare, you decide) | `evals/golden/`, thresholds | Types + fast tests |

Check: in a normal session, ask Claude to "make the failing test pass" by editing the test. The edit should be blocked with the message above.

## Step 4: Strengthen the tests

Coverage shows code ran, not that it was checked. Use invariants, mutation testing and held-out checks so passing tests actually mean correct code. Apply them first to core modules (business rules, algorithms, data transformations: whatever defines correctness in your project).

Tools per language:

| Language | Property-based testing | Mutation testing |
| --- | --- | --- |
| Python | Hypothesis | mutmut, cosmic-ray |
| JavaScript / TypeScript | fast-check | Stryker |
| Go | rapid, testing/quick | gremlins, go-mutesting |
| Rust | proptest, quickcheck | cargo-mutants |
| Java / Kotlin | jqwik, Kotest property testing | PIT (pitest) |
| C# | FsCheck, CsCheck | Stryker.NET |

**Property-based tests.** Assert invariants over thousands of generated inputs. No single hardcoded output can satisfy them. Python example with Hypothesis; adapt names to your code:

```python
from hypothesis import given, strategies as st
from myapp.pricing import apply_discount   # replace with your functions
from myapp.codec import encode, decode

prices = st.decimals(min_value=0, max_value=10_000, places=2)
percents = st.decimals(min_value=0, max_value=100, places=2)

@given(price=prices, pct=percents)
def test_discount_stays_in_range(price, pct):
    assert 0 <= apply_discount(price, pct) <= price

@given(price=prices, pct=percents, extra=percents)
def test_bigger_discount_never_costs_more(price, pct, extra):
    bigger = min(pct + extra, 100)
    assert apply_discount(price, bigger) <= apply_discount(price, pct)

@given(st.dictionaries(st.text(), st.integers()))
def test_round_trip_is_lossless(data):
    assert decode(encode(data)) == data
```

The same idea in TypeScript with fast-check:

```ts
import fc from "fast-check";
import { test } from "vitest";
import { applyDiscount } from "../src/pricing"; // replace with your function

test("discount stays in range", () => {
  fc.assert(
    fc.property(fc.integer({ min: 0, max: 1_000_000 }), fc.integer({ min: 0, max: 100 }),
      (cents, pct) => {
        const result = applyDiscount(cents, pct);
        return result >= 0 && result <= cents;
      }),
  );
});
```

Invariants that work in most codebases: outputs stay within valid ranges; round-trips are lossless (serialize then parse, encode then decode); operations that should be idempotent are (a retry or migration applied twice); results are monotonic where the domain says so; totals are conserved (no money, items or records lost in a transformation).

**Mutation testing.** It plants small bugs, such as flipped comparisons or off-by-one changes, and reports which ones your tests miss. Use the tool for your language from the table above. Run it per feature on core modules only, since it is slow; most tools can be scoped to specific paths. Treat each surviving mutant in core code as a missing test, and aim for a mutation score of about 70% or more there.

**Held-out tests.** Keep integration tests the agent never sees in `tests/holdout/`, run them only in CI, and deny the read tool access in `.claude/settings.json`:

```json
{ "permissions": { "deny": ["Read(./tests/holdout/**)"] } }
```

This blocks Claude's Read tool, not shell commands, so it is a speed bump rather than a wall. Held-out tests mainly catch solutions that pass the visible tests without truly working.

**Metric regression gate.** Fail the PR when metrics regress beyond tolerance against a protected baseline (`evals/golden/` is guarded in Step 3). It works for any measurable outcome, such as latency, error rate, model accuracy or benchmark scores:

```python
# evals/gate.py — usage: python -m evals.gate results/<run>/metrics.json
import json, sys

BASE = json.load(open("evals/golden/baseline_metrics.json"))
NEW = json.load(open(sys.argv[1]))
# allowed change per metric: positive = may rise by this much, negative = may fall
# replace with the metrics that matter in your project
TOL = {"p95_latency_ms": +5.0, "error_rate": +0.001, "accuracy": -0.002}

failed = []
for metric, tol in TOL.items():
    delta = NEW[metric] - BASE[metric]
    if (tol > 0 and delta > tol) or (tol < 0 and delta < tol):
        failed.append(f"{metric}: {BASE[metric]:.4f} -> {NEW[metric]:.4f}")
if failed:
    sys.exit("Metric regression:\n" + "\n".join(failed))
print("Metric gate passed")
```

Also fix random seeds and keep benchmarks deterministic, so a metric change always means a code change.

## Step 5: Architecture fitness

Agents tend to bolt new logic onto existing functions instead of restructuring them. Turn structure into checks that block: complexity limits, module boundaries, duplication detection, and a ratchet that lets legacy violations only go down.

1. **Complexity and size limits** in your linter, set to block rather than warn. Rules and boundary checkers per language:

| Language | Complexity and size rules | Module boundary checker |
| --- | --- | --- |
| Python | ruff: C90 (complexity), PLR0912 / PLR0915 (branches, statements) | import-linter |
| JavaScript / TypeScript | Biome: noExcessiveCognitiveComplexity, plus function-length rules if your version has them | dependency-cruiser, or Biome noRestrictedImports with per-folder overrides |
| Go | golangci-lint: gocyclo or gocognit, funlen | depguard, go-arch-lint |
| Rust | clippy: cognitive\_complexity, too\_many\_lines, too\_many\_arguments | Crates in a workspace plus `pub(crate)` visibility |
| Java / Kotlin | Checkstyle or PMD; detekt for Kotlin | ArchUnit |
| C# | Roslyn analyzers (e.g. CA1502) | NetArchTest, ArchUnitNET |

Python example (`pyproject.toml`):

```toml
[tool.ruff.lint]
select = ["E", "F", "B", "SIM", "C90", "PL", "BLE", "S110"]
# C90 = complexity, PL = pylint size rules, BLE = blind except, S110 = try/except/pass

[tool.ruff.lint.mccabe]
max-complexity = 10

[tool.ruff.lint.pylint]
max-branches = 12
max-statements = 50
max-args = 6
```

TypeScript example (`biome.json`; rule names and groups can move between Biome versions, so check the docs if one is rejected):

```json
{
  "formatter": { "enabled": true },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "complexity": {
        "noExcessiveCognitiveComplexity": {
          "level": "error",
          "options": { "maxAllowedComplexity": 10 }
        }
      },
      "suspicious": {
        "noEmptyBlockStatements": "error"
      }
    }
  }
}
```

2. **Module boundaries.** Higher layers may import lower ones, never the reverse. Use the checker for your language from the table. Python example with import-linter:

```toml
[tool.importlinter]
root_package = "myapp"

[[tool.importlinter.contracts]]
name = "Layered architecture"
type = "layers"
layers = ["myapp.api", "myapp.services", "myapp.domain"]
```

Run with `lint-imports`. The same rules for TypeScript with dependency-cruiser (`.dependency-cruiser.cjs`, run with `npx depcruise src --config .dependency-cruiser.cjs`):

```js
module.exports = {
  forbidden: [
    { name: "domain-stays-pure", severity: "error",
      from: { path: "^src/domain" }, to: { path: "^src/(api|services)" } },
    { name: "services-dont-import-api", severity: "error",
      from: { path: "^src/services" }, to: { path: "^src/api" } },
  ],
};
```

Enable the matching line in the `boundaries` branch of quality.sh so pre-commit and CI run it.

3. **Duplication detection** in CI with jscpd, which supports most languages: `npx jscpd --threshold 3 src`.
4. **Ratchet for an existing repo.** Freeze today's violations so only new code must comply, then let the count only go down. Baseline options: Python `ruff check --add-noqa`; Go `golangci-lint run --new-from-rev=origin/main` (reports only new issues); Biome can insert `biome-ignore` comments for existing diagnostics (a suppress option on `biome lint` in recent versions; check the docs); otherwise add inline suppressions once. Then make sure inline suppressions never grow:

```bash
# scripts/ratchet.sh — fail if inline lint suppressions increased (any language)
pattern=$(.claude/quality.sh suppress-pattern)
now=$(git grep -E -c "$pattern" -- . ':!*.md' ':!.claude/quality.sh' | awk -F: '{s+=$NF} END {print s+0}')
max=$(cat .ratchet-suppressions)
[ "$now" -le "$max" ] || { echo "suppressions rose: $max -> $now" >&2; exit 1; }
if [ "$now" -lt "$max" ]; then echo "suppressions fell to $now; lower .ratchet-suppressions to lock it in"; fi
```

Create `.ratchet-suppressions` once with the current count.

5. **Pre-commit config** (`.pre-commit-config.yaml`), so committed code also passes the gates:

```yaml
# pre-commit runs any language; every hook goes through quality.sh
repos:
  - repo: local
    hooks:
      - id: format-lint
        name: format + lint
        entry: bash -c 'for f in "$@"; do .claude/quality.sh is-source "$f" || continue; .claude/quality.sh format "$f" && .claude/quality.sh lint "$f" || exit 1; done' --
        language: system
      - id: types-and-tests      # commits made inside a turn bypass the Stop gate
        name: types + fast tests
        entry: bash -c '.claude/quality.sh typecheck "$@" && .claude/quality.sh test-fast "$@"' --
        language: system
      - id: boundaries
        name: architecture boundaries
        entry: .claude/quality.sh boundaries
        language: system
        pass_filenames: false
      - id: ratchet
        name: suppression ratchet
        entry: bash scripts/ratchet.sh
        language: system
        pass_filenames: false
```

Run the same checks, plus the full test suite, held-out tests and the metric gate, in CI.

## Step 6: Independent review

Review every task diff with a fresh-context subagent, so the code is judged by something that did not write it. Give it a checklist aimed at known agent failure modes; the gates already cover style.

1. Create `.claude/agents/reviewer.md`:

```markdown
---
name: reviewer
description: Reviews the current task's diff for defects. Use after implementing a task,
  before committing. Read-only.
tools: Read, Grep, Glob, Bash
---

You review a diff you did not write. Never edit source files. Bash is for
read-only commands only: git diff, git diff --stat, git log.

Inputs:
- Run `git diff HEAD > .agent/review.diff` and `git diff HEAD --stat`, then read
  .agent/review.diff with the Read tool. Do not rely on diff output printed in
  the shell: it may be compressed by RTK, the file is not.
- The spec section named by the caller.

Check, in this order:
1. Signal tampering: any change under tests/, evals/golden/ or eval thresholds?
   Literals matching test fixtures? Branches that only trigger on test inputs?
   Looser assertions?
2. Logic and edge cases vs the spec: empty, zero, null/None, boundaries, ordering.
3. Error handling: swallowed exceptions, silent fallbacks, missing validation.
4. Performance: repeated I/O or model loads in loops, N+1 patterns,
   unnecessary copies of large arrays or dataframes.
5. Security: secrets, unsafe deserialization, shell or SQL built from input.
6. Structure: layering instead of refactoring, duplicated logic, unclear names.

Output at most 15 findings, most severe first:
[Critical|Major|Minor] path:line — problem — suggested fix
End with: VERDICT: PASS or VERDICT: FIX (if any Critical or Major).
```

2. Create `.claude/commands/check-task.md` (named to avoid clashing with any built-in review command):

```markdown
---
description: Review the current task diff, fix serious findings, report the rest
---

1. Run the reviewer subagent on the current diff, passing the spec section for this task.
2. Fix every Critical and Major finding. Do not touch protected paths.
3. Run the reviewer once more on the updated diff.
4. Report to me: remaining Minor findings, anything you disagreed with and why,
   and the change summary (what, why, what you were unsure about).
```

3. Add `/check-task` before the commit step of `/next-task` in the workflow doc, so every task gets reviewed (the workflow doc's /next-task already includes it).
4. Your human review then focuses on what tools cannot judge: is the design right, does it match intent, and is it the simplest solution?
5. Optionally, add an AI review bot in CI as a second opinion on each PR.

## Part 2: Cognitive debt — Step 7: Ownership map

Cognitive debt is lost understanding, held by people, not code: clean, well-tested code can still be something nobody can explain. The goal is not to understand every line. It is to keep the theory of the system (architecture, invariants, intent and core logic) in your head, and to delegate the rest knowingly.

A practical test for any code: could you reproduce, verify and fix it without the agent? If not, that is debt. Spend your understanding where the risk is highest, by giving each area of the repo an ownership level:

| Level | Typical areas | How you work |
| --- | --- | --- |
| Core | Domain logic and algorithms that define correctness (e.g. pricing rules, scheduling, permissions, core models) | The agent writes all code; you pick the approach, state the invariants and pass `/walkthrough` |
| Important | Data pipelines, integrations with external systems, evaluation or test harnesses | Agent writes; you read every line and pass `/walkthrough` |
| Plumbing | Config, CLI, logging, glue, scripts | Delegate fully; quality gates are enough |

Add the map to the root CLAUDE.md (replace the paths with yours):

```markdown
## Ownership levels
Core (User decide; Claude write all code):
- src/domain/, src/core/
- I choose the approach before any task starts (in /plan-feature, or from
  2 options you give me first). If it does not fit, stop and ask me.
- Tests session: ask me for the invariants in plain words and write
  property tests from them.
- Impl session: write all the code; do not edit tests. End with
  /walkthrough; do not commit on GAPS.
Important (you write; I review every line):
- src/pipelines/, src/integrations/, src/eval/
- Always end the task with /walkthrough.
Plumbing (delegate):
- Everything else. Quality gates are sufficient.
Ownership decides my involvement; the workflow tier decides planning.
They are independent.
```

The Core rules stay in the root, not in a nested file. A tests session often works only in `tests/`, so it would never load a `CLAUDE.md` inside a Core directory.

Revisit the map at each milestone. An area moves up a level when incidents or confusion cluster there.

Ownership is separate from the workflow tiers: the tier decides planning artifacts, ownership decides human involvement. A two-line Tier 0 fix in Core gets no plan, but you still choose the approach and give your hypothesis first. Ownership also decides autonomy: Plumbing tasks can run unattended through `/next-task`, Important tasks pause for `/walkthrough` before committing, and Core tasks pause twice: for your choice of approach and for `/walkthrough`.

## Step 8: Inquiry before delegation

Stay cognitively engaged while using the agent. In Anthropic's skill-formation study, developers who asked follow-up or conceptual questions kept their understanding (65%+ quiz scores), while those who fully delegated code or debugging scored below 40%.

Add to the root CLAUDE.md:

```markdown
## Working with me
- When I ask why or how, explain first. Do not edit until I ask.
- Before a hard change in Important code, give 2 alternatives with
  trade-offs in <=5 lines and let me choose. Core follows Ownership levels.
```

In this setup, the global CLAUDE.md approval protocol already covers this block, so a project needs no copy. The comment rules in `rules/code-quality.md` replace a general WHY-comment rule: a comment marks only a hidden constraint, an invariant or a workaround.

Personal habits that make the difference:

- Ask "why this approach?" after Claude proposes one, even when it looks right.
- When learning an unfamiliar library outside the project, ask conceptual questions and write the first version yourself. Inside the project, Core code stays with Claude.

## Step 9: Hypothesis-first debugging

Debugging showed the largest skill gap in the study, and handing every failure back to the agent is how the false-correction loop starts. In Core and Important code, form your own hypothesis before the agent investigates.

Add to the nested `CLAUDE.md` in each Core and Important directory, not the root, so it loads only where it applies:

```markdown
## Debugging protocol (Core and Important code)
1. Before investigating, ask me for my hypothesis. Wait for my answer.
2. Then investigate. Report whether my hypothesis was right and what the
   actual root cause is, with evidence (file:line, failing input).
3. Every fix commit message must include a line: "Root cause: <one sentence>".
```

The "Root cause" line is also what Step 11 uses to measure fix-without-diagnosis. Plumbing bugs can skip step 1.

## Step 10: Comprehension gate

Before merging Core or Important work, prove to yourself that you understand it. A prediction check shows where your mental model is wrong, and the walkthrough questions confirm the fix.

Create `.claude/commands/walkthrough.md`:

```markdown
---
description: Check my understanding of the change before merging
---

1. Before showing anything, ask me to predict which files changed and how.
   Wait for my answer, then list the actual changed files and point out surprises.
2. Summarize the change in <=8 lines: what changed, why, the key decision,
   and how it could fail.
3. Point to the 2-3 most important code locations (file:line) in reading order.
4. Ask me 3 questions, one at a time, that I can only answer if I understand
   the change: edge cases, invariants, failure modes. No yes/no questions.
   Do not reveal an answer before I try.
5. After each answer, correct me precisely if I am wrong.
6. End with PASS (all correct) or GAPS: <list>. For GAPS, append a line to
   .agent/understanding-gaps.md with the date, file and topic.
```

Rules of use:

- Required for Core and Important code, optional for Plumbing. The ownership block in CLAUDE.md already asks for it.
- Do not merge on GAPS in Core code. Ask follow-up questions or read the code until you can answer, then rerun.
- Example of a good question: "What happens if the external call times out after the database write but before the response is sent?"

## Step 11: Measure cognitive debt

No tool measures understanding directly, so track a few proxies monthly and watch their trend rather than absolute values.

| Indicator | How to get it | Warning sign |
| --- | --- | --- |
| Explain-without-opening | Pick a Core module; describe its flow and invariants from memory, then check | You can't name its invariants |
| Unowned hotspots | `scripts/unowned_hotspots.py` (below) | Core or Important files on the list |
| Fix-without-diagnosis | `fix:` commits lacking a "Root cause:" line | Rising share |
| Walkthrough pass rate | PASS vs GAPS entries in .agent/understanding-gaps.md | Falling, or the same gaps recurring |
| Time to diagnose | Rough hours from a Core bug report to the root cause | Rising over months |

`scripts/unowned_hotspots.py` lists files changed in agent co-authored commits but never in a commit without that trailer. Claude Code adds a Co-Authored-By trailer by default; if you remove it, this script cannot tell the difference.

```python
# usage: python scripts/unowned_hotspots.py ["90 days ago"]
import collections, subprocess, sys

since = sys.argv[1] if len(sys.argv) > 1 else "90 days ago"
log = subprocess.run(
    ["git", "log", f"--since={since}", "--name-only", "--format=\x01%B\x02"],
    capture_output=True, text=True, check=True).stdout

agent, human = collections.Counter(), set()
for entry in log.split("\x01")[1:]:
    msg, _, files = entry.partition("\x02")
    by_agent = "co-authored-by: claude" in msg.lower()
    for f in (line.strip() for line in files.splitlines()):
        if not f:
            continue
        if by_agent:
            agent[f] += 1
        else:
            human.add(f)

for f, n in agent.most_common():
    if f not in human:
        print(f"{n:4d}  {f}")
```

Count fix-without-diagnosis with git:

```bash
fixes=$(git log --since="30 days ago" --oneline --grep='^fix' | wc -l)
diagnosed=$(git log --since="30 days ago" --oneline --grep='^fix' --grep='Root cause:' --all-match | wc -l)
echo "fix commits: $fixes, with root cause: $diagnosed"
```

A file on the hotspot list is not automatically a problem: Plumbing is supposed to be delegated. Act on Core and Important files, through the repayment routine in Step 12.

## Step 12: Scheduled repayment

Cognitive debt is repaid through deliberate practice: rebuilding understanding by hand, testing without help, and reconstructing from first principles. Schedule it, because short-term productivity always makes skipping it look rational.

| Cadence | Practice | Time |
| --- | --- | --- |
| Weekly | Theory session: sketch one Core or Important module from memory (flow, invariants, failure modes), then compare with the code and note the gaps | \~30 min |
| Weekly | Work through .agent/understanding-gaps.md; ask Claude conceptual questions about each, without editing | \~20 min |
| Monthly | One unaided task: fix a small Core bug or add a small feature without the agent | 1–2 h |
| Monthly | Review the hotspot and fix-without-diagnosis numbers from Step 11 | 15 min |
| Per milestone | Refresh the architecture doc and ownership map; collapse finished specs into decision records in docs/decisions/ | \~1 h |

Theory-session prompt, to use after sketching from memory:

```text
I just described <module> from memory: <my description>.
Compare it with the actual code. List what I got wrong or missed, most
important first, with file:line. Do not change any files.
```

On a team, rotate who reviews and who runs theory sessions on each Core area, so understanding never sits with only one person.

## Rollout and verification

Roll out over about three weeks, cheapest and highest-impact first, and check each step before adding the next.

| Week | Steps | Outcome |
| --- | --- | --- |
| 1 | Language adapter (0) and ratchet baseline (Step 5, item 4) first, then 1, 2, 3, ownership map (7) | Gates run automatically; tests are protected; areas are classified |
| 2 | 5, 6, 8, 9, 10 | Structure is enforced; every task is reviewed; walkthroughs are routine |
| 3 | 4 on core modules, 11 | Tests are strong where it matters; first debt baseline is measured |
| Ongoing | 12 | Debt is repaid on a schedule |

Verification checklist:

- [x] quality.sh has a branch for every language in the repo, and an unused import added by Claude is removed automatically after the edit
- [x] A type error blocks the end of the turn once, and Claude fixes it
- [x] Editing a file under tests/ is blocked in a normal session and allowed with TASK\_MODE=tests
- [ ] Hypothesis invariants exist for your Core functions
- [ ] Mutation score on core modules is measured, and surviving mutants have become tests
- [ ] The metric gate fails on a deliberately degraded build or model
- [ ] import-linter fails on a deliberately wrong-direction import
- [x] /check-task finds a planted bug (e.g. a swallowed exception)
- [ ] Ownership levels are in CLAUDE.md, and Claude offers 2 approaches before Core code
- [ ] /walkthrough asks for a prediction first and logs GAPS to .agent/understanding-gaps.md
- [ ] Fix commits include a "Root cause:" line
- [ ] The first monthly debt review (hotspots, fix-without-diagnosis) is done
