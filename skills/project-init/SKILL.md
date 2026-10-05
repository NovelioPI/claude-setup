---
name: project-init
description: Set up a project for context management. Drafts a short root CLAUDE.md (commands, repo map, conventions), then runs /handoff to create .agent/. Use when a project has no CLAUDE.md or no .agent/ folder.
disable-model-invocation: true
---

# Initialize a project

The global `~/.claude/CLAUDE.md` already holds the compact instructions and
the approval protocol. Do not copy them into the project file.

## Steps

1. Check each target on its own. If `./CLAUDE.md` exists, do not replace
   it: report which template sections it lacks, and skip steps 2 and 5.
   If `.agent/` exists, skip step 6. If both exist, stop.
2. Read the build files and scripts that exist, such as `package.json`,
   `pyproject.toml`, `requirements*.txt`, `Makefile`, `justfile`, `go.mod`,
   `Cargo.toml`, `CMakeLists.txt`, `pom.xml`, `build.gradle*`,
   `pubspec.yaml`, and `scripts/`. List the top-level folders.
3. Ask the user in one message: the current goal in one sentence, and,
   only if step 5 runs, any hard conventions. Leave Conventions empty if
   none.
4. Show one plan with only what the remaining steps write: the drafted
   `./CLAUDE.md`, and the files `/handoff` writes (`.agent/.gitignore`,
   `.agent/progress.md`, `.agent/.skip-gate`). Wait for "Go". One "Go"
   covers steps 5 and 6.
5. Write `./CLAUDE.md`.
6. Invoke `/handoff`, with the goal from step 3 as "Current goal".
7. Do not commit. End with one line that lists the files created, in place
   of the `/handoff` reply.

Keep the file under 60 lines. Write a command only if a build file or a
script shows it. Omit a command line that no file shows. Never guess a
command.

## Template

```markdown
# Project: <name>

## Commands
- Build: <command>
- Test (fast): <command>
- Test (single): <command>
- Lint + types: <command>

## Repo map
- <folder>/ — <one line>

## Conventions
- <rule>
```
