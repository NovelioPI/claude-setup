---
description: Plan a task, then run it to the end under Auto Mode
argument-hint: <task>
---

Task: $ARGUMENTS

1. If the task is empty or unclear, ask one question and stop. Do not guess.
2. Write the plan in chat: the files, the actions, and the tests to run.
3. Start at once. Do not wait for a token. Follow the Auto Mode rules in
   CLAUDE.md: the "still ask" list, the stop conditions, and the scope rule.
4. Run the tests, the build, and the lint that the project has.
5. Report: what changed, why, what you were unsure about, test results, and
   the new scope you logged.
6. Do not commit.
