## Verification

### Proof

- Check the real artifact, not a proxy. "It compiles" and "the tests pass" do not prove what a user sees.
- Script each check so anyone can run it again. Keep its output.
- When a result surprises you, suspect how you observed it before you suspect the system.

### Order

- Split work into small units. Each unit ends in a passing check before the next one starts.
- For a bug, write the failing test first. Show that it fails for the intended reason, and commit it. Then fix the code without editing that test.

### Tests

A test must fail when the behavior breaks, and pass when only the internals change. Take the expected value from the requirement, not from the code.

### Repeated failure

After two failed fixes that share one premise, write the premise down. Test it before a third fix.

### Independent check

Run the `verifier` agent only when a proof needs a person or a running system, or when a feature is done.

| Run it | Skip it |
|---|---|
| A claim needs a screenshot, a UI or TUI flow, a CPU or memory profile, or service logs | A test, a type check, or a command output proves the claim |
| A Large-tier feature is done: write `Run: feature` in the prompt | A format, refactor, docs, or config change |

When you skip it, run the proving command yourself and show its output before you report done.

Give it the claims only: the Behavior claims in `spec.md`, or one stated claim when there is no spec. Do not give it your account of the work. Report its verdicts and evidence paths. A verdict counts only while `HEAD` matches its `Commit:` line. `NOT VERIFIED` or `INCONCLUSIVE` on any claim means the task is not done.
