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

Before you report a change with visible behavior as done, run the `verifier` agent. Give it the claims: the Behavior claims in `spec.md`, or one stated claim when there is no spec. Report its verdicts and evidence paths. `NOT VERIFIED` or `INCONCLUSIVE` on any claim means the task is not done.
