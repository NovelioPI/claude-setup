---
description: Review the current task diff, fix serious findings, report the rest
---

1. Run the `reviewer` subagent on the current diff. Pass it the task statement.
2. Fix every Critical and Major finding. Do not touch a path in `.claude/protected-paths`,
   or a default test pattern when the project has no list.
3. Run the `reviewer` subagent once more on the updated diff.
4. Report: the remaining Minor findings, any finding you disagreed with and
   why, and the change summary (what changed, why, what you were unsure about).
5. Do not commit.
