# Tooling and MCP Policy

## Goal

Use external tools as capabilities without turning every session into a large tool-and-context load.

## Free/local preference

CLAE does not require paid MCP services.

### Figma

Use the community/local server:

`https://github.com/arinspunk/claude-talk-to-figma-mcp`

The repository describes a local WebSocket server plus a Figma Desktop plugin, and provides Claude Code configuration using `npx`. It is MIT-licensed. See `integration/figma-talk-to-figma.md`.

### Browser automation

Prefer Playwright CLI + Skills for coding agents. The Playwright MCP project itself documents that CLI + Skills can be more token-efficient because large MCP schemas and verbose accessibility trees do not need to be loaded into context. Use MCP only when a workflow benefits from persistent browser state or richer introspection.

### Storybook

Storybook's MCP project moved into the main Storybook repository. In v0.3, treat Storybook's Skills/plugin direction as optional, version-matched project tooling rather than an always-on MCP dependency.

### shadcn

The shadcn MCP server can browse/search/install components from configured registries. Use it only in projects that already use the shadcn registry model.

## Tool admission rules

A tool enters the workflow only when:

1. the current task needs it;
2. the tool reduces work or uncertainty;
3. its setup cost is lower than manual work;
4. the tool is allowed by the user's cost/security policy.

## Never assume paid services

If an integration is cloud-hosted, licensed, or usage-metered, keep it optional and document the local fallback.
