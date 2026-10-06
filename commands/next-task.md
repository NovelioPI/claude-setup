---
description: Pick up and finish the next unblocked task for this session's mode
---

1. Read .agent/progress.md. List the open Tasks. Check the mode with
   `echo $TASK_MODE`. An empty value means impl.
2. Pick the first unblocked task whose [mode] matches. If none matches, tell me
   which mode to restart in, and stop.
3. Find the spec in docs/plans/. Get its heading lines with `grep -n '^##'`.
   Read only the task's section and the Decisions section.
4. Show the plan for the task and wait for a token. Then mark it in progress.
5. Do the task. Use the explorer subagent for exploration and log analysis.
   [tests]: write the acceptance tests. Core [impl]: follow the approach
   under Decisions. If it does not fit, stop and ask me.
6. Run its check. [tests]: the new tests run and fail for the expected reason.
   Other modes: the check passes. If it fails, fix the code or stop and report.
   Never edit a test to make it pass.
7. Run /check-task and fix the Critical and Major findings.
8. Important or Core code: run /walkthrough and wait for PASS.
9. If the approach had to change, append a dated line to the spec's Decisions
   section. Do not rewrite the spec. Propose the commit, including that line,
   and wait for a token. Then commit, mark the task done, and run /handoff.
