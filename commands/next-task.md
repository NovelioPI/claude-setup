---
description: Pick up and finish the next unblocked task of this feature
---

1. Read .agent/progress.md. Check the feature with `echo $FEATURE`. If it is
   empty, ask me for it.
2. List the open issues in the Linear project named $FEATURE. Pick the first
   one with no open "blocked by" issue. Check blockers with `get_issue` and
   `includeRelations`, because `list_issues` omits relations. If none is
   unblocked, tell me, and stop.
3. Read only that issue and the Decisions section of the project description.
4. Show the plan for the task and wait for a
   token. Then assign the issue to me and set its status to In Progress.
5. Do the task. Use the explorer subagent for exploration and log analysis.
   `level:core`: ask me for the
   invariants in plain words, write property tests from them, and follow the
   approach under Decisions. If it does not fit, stop and ask me.
6. Run its check. It passes. If it fails, fix the code or stop and report.
   Never edit a test to make it pass.
7. If the approach had to change, propose a dated line for the project's
   Decisions section. Do not rewrite the description. Propose the commit and
   wait for a token. Then commit, append the Decisions line, set the issue to
   Done, add a comment with the commit hash, and run /handoff.
