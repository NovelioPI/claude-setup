---
description: Pick up and finish the next unblocked task for this session's mode
---

1. Read .agent/progress.md. Check the mode with `echo $TASK_MODE` and the
   feature with `echo $FEATURE`. An empty mode means impl. An empty feature:
   ask me for it.
2. List the open issues in the Linear project named $FEATURE with the label
   `mode:<mode>`. Pick the first one with no open "blocked by" issue. Check
   blockers with `get_issue` and `includeRelations`, because `list_issues`
   omits relations. If none matches, tell me which mode to restart in, and stop.
3. Read only that issue and the Decisions section of the project description.
4. Show the plan for the task and wait for a token. Then assign the issue to
   me and set its status to In Progress.
5. Do the task. Use the explorer subagent for exploration and log analysis.
   `mode:tests`: write the acceptance tests. `level:core` impl: follow the
   approach under Decisions. If it does not fit, stop and ask me.
6. Run its check. `mode:tests`: the new tests run and fail for the expected reason.
   Other modes: the check passes. If it fails, fix the code or stop and report.
   Never edit a test to make it pass.
7. If the approach had to change, propose a dated line for the project's
   Decisions section. Do not rewrite the description. Propose the commit and
   wait for a token. Then commit, append the Decisions line, set the issue to
   Done, add a comment with the commit hash, and run /handoff.
