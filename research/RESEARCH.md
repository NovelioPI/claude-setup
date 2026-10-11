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

- Before and after each run, update `experiments/<experiment>/log.md`. Before the
  first run in a session, read `~/.claude/research/guides/experiment-log.md`.
- Before the first MLflow read or write in a session, read `~/.claude/research/guides/mlflow.md`.
- Write the weekly report, summary, and deck with the `research:weekly-report`
  skill. Use only the logs and MLflow, never memory.
- Before the first edit to code that calls an LLM, read `~/.claude/research/guides/llm-api.md`.
- Before the first edit to a prompt, or to code that holds or loads one, read
  `~/.claude/research/guides/prompts.md`.
- Explore in this order: `research:papers`, `research:ideas`,
  `research:experiment-plan`. Files live in `notes/` and
  `experiments/<exp>/plan.md`.
- Before the first job start in a session, read
  `~/.claude/research/guides/long-runs.md`.
- Before the first edit to a notebook, read `~/.claude/research/guides/notebooks.md`.
- Compare runs with the `research:compare-runs` skill.
