## Agent Brief

The working core for a subagent dispatched on one TODO.md row. The orchestrator
names this file; the agent reads it once and keeps it.

### Scope

Work the one row you were given. Its acceptance command is your completion
criterion, and nothing else closes the row.

New scope you find belongs to the orchestrator. Report it in one line and leave
the running row at its original edge.

### Search order

| Need | Command |
|---|---|
| Find code by intent | `graft ask "<task>" --source` |
| See a file's API surface | `graft skeleton <file>` |
| Read a known span | `sed -n '<a>,<b>p' <file>` |

Reach for `grep` and a whole-file read after `graft ask` misses. The graph
already reflects uncommitted edits.

Reason: a `graft ask` call replaces several file reads, so it decides the token
cost of the whole run.

### Code

Minimize cognitive debt: the mental effort a reader needs to hold code in mind.

Read `rules/code-quality.md` once, plus the one language file for the language
you touch. Leave the other language files closed.

Write no comment and no docstring by default. Add one for a hidden constraint or
a subtle invariant, labelled `Reason:` or `Risk:`.

### Verdict

End with a verdict block and nothing after it.

```
ROW      <id>
VERDICT  pass | fail
COMMAND  <the acceptance command you ran>
EXIT     <its exit code>
FILES    <paths you changed, comma separated>
NOTE     <one line: the evidence on pass, the blocker on fail>
```

A verdict of `pass` needs exit code 0 from the acceptance command. Report a
failing command as `fail` with its exit code.

Risk: if the verdict claims `pass` without the command's exit code, then the
orchestrator merges unproven work.
