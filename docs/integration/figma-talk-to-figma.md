# Figma — `claude-talk-to-figma-mcp`

CLAE intentionally does **not** depend on Figma's official MCP server.

Use:

`https://github.com/arinspunk/claude-talk-to-figma-mcp`

## Why

The repository provides an MCP server that connects Claude Code and other agentic tools to Figma Desktop through a local WebSocket server and a Figma plugin.

## Installation from the repository's documented flow

Prerequisites:

- Node.js
- Figma Desktop
- Claude Code or another MCP client

Start the server:

```bash
npx claude-talk-to-figma-mcp
```

The documented Claude Code configuration is:

```bash
claude mcp add ClaudeTalkToFigma -- npx -p claude-talk-to-figma-mcp@latest claude-talk-to-figma-mcp-server
```

The repository also documents a project-local `.mcp.json` configuration.

## Local-server model

```text
Claude Code
    │
    ▼
local MCP server
    │
    ▼
Figma plugin in Figma Desktop
    │
    ▼
Figma document
```

## CLAE usage rule

Do not expose Figma to every task. The design router should activate it only when:

- a UI/design artifact is required;
- an existing Figma design is the source of truth;
- visual design needs inspection or modification.

## Important boundary

Using a local/community MCP avoids relying on Figma's official MCP server, but Figma Desktop and the user's Figma access are still prerequisites for this workflow. Do not treat the local MCP as a replacement for Figma itself.
