# ADR-0002 — Free-First Integrations

## Status

Accepted

## Decision

CLAE must work without paid MCP services. Integrations are optional capabilities with local fallbacks.

For Figma, use the community/local `arinspunk/claude-talk-to-figma-mcp` instead of the official Figma MCP server.

For browser work, prefer Playwright CLI + Skills when it is more context-efficient than MCP.

## Consequences

- CLAE remains portable.
- External SaaS is not a hard dependency.
- Tool choice is driven by task value and context cost.
