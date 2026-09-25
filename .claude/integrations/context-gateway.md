# Context Gateway integration

The Gateway is local and free by default.

External tools such as Jira, community Figma MCP, Storybook, or browser tooling are treated as capabilities and should be loaded only when a task requires them.

The Gateway should prefer:

```text
local snapshot → local artifact → git → external capability
```

when the cheaper source is fresh and authoritative enough.
