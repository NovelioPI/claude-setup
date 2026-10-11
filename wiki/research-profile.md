# Research profile

How `claude-research` adds a second setup on top of the engineering default.

## How it starts

`research/claude-research` runs `claude` with three flags. Each applies to that
session only, so a research session and an engineering session can run at once.

| Flag | Loads |
|---|---|
| `--plugin-dir research` | the research skills and the MLflow and Hugging Face MCP servers |
| `--settings research/profile-settings.json` | the plugin list without typescript-lsp, Playwright, and Linear; MLflow permissions |
| `--append-system-prompt-file research/RESEARCH.md` | the research rules and the pointers to the guides |

The launcher also sets `CLAUDE_PROFILE=research`, so the status line shows
`◆ research`.

## What changes from engineering

| Rule | Engineering | Research |
|---|---|---|
| Approval protocol | same | same; start each experiment with `Auto` |
| TDD | on | off until "TDD on" |
| Linear and ownership rules | on | off |
| Code and doc rules, hooks | on | on |

`CLAUDE.md` lets an appended profile prompt override its TDD and Execution
sections. That line is the only coupling between the two profiles.

## Guides and skills

A guide is a set of rules to obey while doing other work. A skill is a job you
start that runs the same steps each time.

| Guides | Skills |
|---|---|
| `experiment-log`, `mlflow`, `llm-api`, `prompts`, `notebooks`, `long-runs` | `papers`, `ideas`, `experiment-plan`, `compare-runs`, `weekly-report` |

## Files it writes in a research repo

| Path | Written by |
|---|---|
| `notes/reading-list.md`, `notes/papers/<id>.md` | `research:papers` |
| `notes/ideas.md` | `research:ideas` |
| `experiments/<exp>/plan.md` | `research:experiment-plan` |
| `experiments/<exp>/log.md` | the experiment-log guide |
| `runs/<entry-id>.log` | the long-runs guide |
| `reports/figures/`, `reports/weekly/<YYYY>-W<ww>.md` | `compare-runs`, `weekly-report` |

## Environment

| Variable | Needed | Use |
|---|---|---|
| `MLFLOW_TRACKING_URI` | yes, per project | the MLflow server; the default is `http://localhost:5000` |
| `S2_API_KEY` | no | a free Semantic Scholar key; without it, search often gets a 429 |

The URI comes from the shell, not plugin `userConfig`. Reason: `userConfig`
would store it in `settings.json`, which this public repo tracks.

## Moving to a separate config folder

Move `research/` to its own `CLAUDE_CONFIG_DIR` only when research needs its own
memory or history. The plugin folder moves as one unit.
