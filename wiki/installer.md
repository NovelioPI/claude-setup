# Installer

What `scripts/install.sh` checks, and what it installs on its own.

The script is safe to re-run. It installs what needs no sudo and prints the command for the rest.

| Tool | Used by | Installed by the script |
|---|---|---|
| `git` | the clone | no, needs sudo |
| `jq` | the hooks and the status line | no, needs sudo |
| `node`, `npm` | `npx skills` and the language servers | no |
| `uv` | `scripts/quality.sh` and the MLflow MCP server | yes |
| `typescript-language-server` | the LSP plugin, which gives the `LSP` tool to `explorer` | yes, by npm |
| `claude` | the plugins `typescript-lsp`, `context7`, and `linear` | yes, by `claude plugin install`; Linear is then turned off for the user and on in each `large` project, which needs `/mcp` sign-in |
| `gh`, `rg` | pull requests and search | no, optional |

It also tests both directions of the git guard and the context floor in `scripts/probe-context-floor.sh`.
