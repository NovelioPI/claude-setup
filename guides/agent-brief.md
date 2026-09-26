## Agent Brief

The working core for a subagent dispatched on one GitHub issue. The orchestrator
names this file; the agent reads it once and keeps it.

You act under the milestone token the orchestrator holds. It covers your one
issue and nothing else. Do not wait for "Go".

### Scope

Read your contract with `gh issue view <n> --json body`. Edit only the paths in
its Scope. Its acceptance command is your completion criterion, and nothing
else closes the issue.

Leave `git` and every `gh` write to the orchestrator.

New scope you find belongs to the orchestrator. Report it in one line and leave
the running issue at its original edge.

### Search order

| Need | Command |
|---|---|
| Find the code | Start at the paths and symbols in Hints |
| Find more by name | `git grep -n '<name>'` |
| Read a known span | `sed -n '<a>,<b>p' <file>` |

Use `graft ask "<task>" --source` instead of `git grep` only when the repo has a
graft index. Read a whole file only after these miss.

### Code

Minimize cognitive debt: the mental effort a reader needs to hold code in mind.

Read `rules/code-quality.md` once, plus the one language file for the language
you touch. Leave the other language files closed.

Write no comment and no docstring by default. Add one for a hidden constraint or
a subtle invariant, labelled `Reason:` or `Risk:`.

### Verdict

End with a verdict block and nothing after it. Write the same block to
`.claude/work/<n>/<your agent name>.md`, so the close step posts it on the issue.

```
ISSUE    <n>
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
