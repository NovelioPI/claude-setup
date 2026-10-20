---
name: attribution
description: Turn the Claude co-author trailer in commits and PRs on or off. Use on /attribution on, /attribution off, or /attribution to see the state.
disable-model-invocation: true
argument-hint: on | off
allowed-tools: Bash(jq *), Bash(mv *)
---

# Attribution

Edit `~/.claude/settings.json` with `jq`. Change only the `attribution` key.

| Argument | Change |
|---|---|
| `off` | Set `attribution` to `{"commit": "", "pr": ""}` |
| `on` | Delete the `attribution` key, so Claude Code uses its default trailer |
| none | Change nothing |

Write through a temp file, then `mv` it over `settings.json`.

Reply with one line only: `Attribution: on` or `Attribution: off`. The state is off when both values are empty strings; else it is on.
