# claude-setup

My global Claude Code config at `~/.claude/`, with an engineering profile and a research profile.

## Features

**Both profiles**

| Feature | What it does |
|---|---|
| Approval protocol | The agent shows a plan and waits for a clear "go". `Auto` runs one plan to the end |
| Code and doc rules | Readable code, few comments, plain words, short commit messages |
| Quality hooks | Format and lint after each edit; type checks and tests before a turn ends |
| Guards | Block unrecoverable git commands and edits to protected test files |
| Plain chat style | Answer first, tables over prose, short sentences |

**Engineering** (`claude`)

| Feature | What it does |
|---|---|
| TDD | Red-green loop at agreed seams |
| Linear | `/plan-feature` drafts issues; `/next-task` picks the next one |
| `ui-check` | Opens changed pages with Playwright: screenshots and console errors |
| ReUI | Finds and installs ReUI registry components through MCP |
| shadcn | Adds and composes shadcn/ui components through MCP and a skill |
| `pr-flow` | Opens a PR with `gh` after an approved push, then watches CI |

**Research** (`claude-research`)

| Feature | What it does |
|---|---|
| Papers | Search Semantic Scholar, arXiv, and Hugging Face; notes with a source for every number |
| Ideas and plans | Ideas checked against prior work; experiment plans ordered cheapest-to-disprove first |
| Runs | Jobs in detached `tmux` with a log, safe over SSH |
| MLflow | Read runs through MCP; each run is linked to an experiment log entry |
| Results | Compare runs with a bootstrap interval; weekly report, summary, and slide deck |
| LLM code | Pinned models, a request-hash cache, prompts as Jinja2 files |

TDD is off in research until you say "TDD on". The status line shows `◆ research`.

## Setup

This repo **is** `~/.claude`. Clone it into place; do not copy files out of it.

1. Install Claude Code and run it once, so `~/.claude/` exists.
2. Move the generated folder aside and clone in its place:
   ```bash
   mv ~/.claude ~/.claude.bak
   git clone git@github.com:NovelioPI/claude-setup.git ~/.claude
   cp -r ~/.claude.bak/projects ~/.claude/ 2>/dev/null
   ```
3. Run the installer. It checks every tool and installs what needs no sudo:
   ```bash
   ~/.claude/scripts/install.sh
   ```
4. Fix anything it reports as a blocker, then run it again.
5. Restart Claude Code.

On a GPU server, repeat these steps on the server, where Claude Code runs.

For research, set these in the shell of each research project:

```bash
export MLFLOW_TRACKING_URI=http://<server>:5000
export S2_API_KEY=<key>   # optional, free from Semantic Scholar
```

## Workflow

**Engineering:** start `claude` in the repo.

1. Describe the task. The agent shows a plan with the seams it will test.
2. Approve with "go", or with `Auto` to run to the end.
3. The agent writes a failing test, then the code, and runs the checks.
4. It reports what changed and what it was unsure about, then proposes a commit.
5. For review, run `pr-flow`: it asks before the push and watches CI.

**Research:** start `claude-research` in the repo.

1. `research:papers`: find and note papers in `notes/`.
2. `research:ideas`: turn the notes into ideas in `notes/ideas.md`.
3. `research:experiment-plan`: turn an idea into runs in `experiments/<exp>/plan.md`.
4. Start each run with `Auto`. It runs in `tmux` and gets a log entry and MLflow tags.
5. `research:compare-runs`: compare results with a significance test.
6. `/research:weekly-report`: write the report, the summary, and the deck.

## More

| Page | Covers |
|---|---|
| [wiki/design.md](wiki/design.md) | Why it looks like this; what to copy; who it is not for |
| [wiki/research-profile.md](wiki/research-profile.md) | How the research profile loads, what it changes, the files it writes |
| [wiki/files.md](wiki/files.md) | Every file, how rules and guides load, tracked skills |
| [wiki/guardrails.md](wiki/guardrails.md) | The git guard, the quality adapter, protected paths, known gaps |
| [wiki/installer.md](wiki/installer.md) | What the installer checks and installs |

MIT licensed.
