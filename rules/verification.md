## Verification

### Proof

- Check the real artifact, not a proxy. "It compiles" and "the tests pass" do not prove what a user sees.
- Script each check so anyone can run it again. Keep its output.
- When a result surprises you, suspect how you observed it before you suspect the system.

### Order

- Split work into small units. Each unit ends in a passing check before the next one starts.
- For a bug, write the failing test first. Show that it fails for the intended reason, then fix.

### Tests

A test must fail when the behavior breaks, and pass when only the internals change. Take the expected value from the requirement, not from the code.

### Repeated failure

After two failed fixes that share one premise, write the premise down. Test it before a third fix.

### Independent check

Before you report a change with visible behavior as done, a fresh subagent that did not write it runs `verify-this`. It uses the project's `verify-<app>` skill when one exists, else `control-ui` or `control-cli`. When the feature has a `spec.md`, it checks each Behavior claim. Report its verdict and the evidence paths. `NOT VERIFIED` or `INCONCLUSIVE` means the task is not done.
