# Installer

What `scripts/install.sh` checks, and what it installs on its own.

The script is safe to re-run. It installs what needs no sudo and prints the command for the rest.

| Tool | Used by | Installed by the script |
|---|---|---|
| `git` | the clone | no, needs sudo |
| `jq` | the hooks and the status line | no, needs sudo |
| `node`, `npm` | `npx skills` and the language servers | no |
| `uv` | `scripts/quality.sh` and the MLflow MCP server | yes |
| `rtk` | the `PreToolUse` hook in `settings.json` that shortens Bash output | yes, by brew or a checked GitHub release |
| `pyright`, `typescript-language-server` | the LSP plugins, which give the `LSP` tool to `explorer` | yes, by npm |
| `claude` | the plugins `pyright-lsp`, `typescript-lsp`, `context7`, and `linear` | yes, by `claude plugin install`; Linear then needs `/mcp` sign-in |
| `claude` | the `reui` MCP server for the `reui` skill | yes, by `claude mcp add`; then `/mcp` sign-in |
| `claude` | the `shadcn` MCP server, run by `npx shadcn@latest mcp`, for frontend components | yes, by `claude mcp add`; no sign-in |
| `gh`, `rg` | `pr-flow` and search | no, optional |

It also tests both directions of the git guard, the `rtk` hook, and the context floor in `scripts/probe-context-floor.sh`.
