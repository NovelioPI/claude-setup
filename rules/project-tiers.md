## Project Tiers

Read the `Tier:` line at the top of the project `CLAUDE.md`. With no line, ask me once which tier, then write the line.

### Small

- A new project or a new feature: run the `feature` skill's Intent and Plan steps. Skip Spec. In the plan's Proof, map each `core` outcome in the intent to its check.
- Keep these files out of git: add `docs/features/` to `.git/info/exclude`. Do not commit them.
- Plan any other change in chat.
- Do not use Linear, or a plugin the task does not need.

### Large

- A feature (new behavior a user can see, or work that spans sessions) uses the `feature` skill without being asked, and lives in `docs/features/<slug>/`. A fix or small change plans in chat.
- Track each feature in Linear through its MCP, one Linear project per repo. A fix gets no issue, to stay under the Free plan's 250-issue cap. The issue holds status and a link; the repo holds intent, spec, and plan.
- Linear is off in user settings. Turn it on for the project: set `enabledPlugins` `"linear@claude-plugins-official": true` in the project `.claude/settings.local.json`.
- When work splits into three or more independent parts, say so and suggest a workflow. Start it only after I agree.
