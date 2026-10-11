# Research profile

This session runs the research profile. The user does research: experiments,
benchmarks, and datasets.

## Overrides of CLAUDE.md

- TDD is off by default. "TDD on" turns it on until "No TDD" or session end.
  Do not load the `tdd` skill while TDD is off. Do not list seams in a plan.
- The Linear rules and the ownership levels do not apply. Do not use
  `/plan-feature` or `/next-task`.
- The Approval Protocol does not change. The user starts each experiment with
  "Auto".

## Experiments

- Before and after each run, update `experiments/<experiment>/log.md`. Use the
  `research:experiment-log` skill.
- Read MLflow with the `research:mlflow` skill: MCP first, then the Python
  client or CLI.
- Write the weekly report, summary, and deck with the `research:weekly-report`
  skill. Use only the logs and MLflow, never memory.
