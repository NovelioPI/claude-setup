# Design

Why this setup looks the way it does, and whether it fits you.

## Why it looks like this

An agent writes code faster than I can read it. So I stopped reading every line, and check evidence instead.

The work went into three things. A method that fixes what to build before any code: intent, spec, and plan. Rules that make what it writes readable on the first pass. A verifier in a fresh context that proves each claim and puts its screenshots on the Linear issue.

Everything here follows from that. If you disagree with the premise, most of these files will look like too much process.

## What is different here

**Comments are off by default.** A comment earns its place by naming a hidden constraint or a risk, in 20 words or fewer. Everything else is the code restating itself.

**Short words are enforced.** `rules/plain-words.md` is a replacement table for chat text and commit messages. Write "use", not "leverage". Write "start", not "spin up".

**Two guards on destructive git, and one deliberate gap.** A hook blocks the unrecoverable commands. `git push` is not blocked, on purpose. A guardrail you hit every day teaches you to route around it.

## Take what you want

Most of this works in pieces. Copy one file and ignore the rest. MIT licensed, so take it without asking.

| Piece | Standalone | Needs |
|---|---|---|
| `rules/plain-words.md` | yes | nothing |
| `rules/code-quality.md` and its language guides | yes | nothing |
| `output-styles/plain-style.md` | yes | one key in `settings.json` |
| `hooks/block-dangerous-git.sh` | yes | `jq` |

## Not for you if

- You want a short config. About 1,600 words load on every turn. The code and doc rules add 1,900 more when Claude touches those files, and a language guide adds 700 to 1,000.
