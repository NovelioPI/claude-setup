# Coding style, comments, docs, tests — improvement plan

Source: brainstorm on 2026-08-27. Updated: 2026-08-27, after
`~/.claude/rules/code-quality.md` and `~/.claude/CLAUDE.md` `## Process`
were finalized.

## Global (in ~/.claude/CLAUDE.md, `## Process` section)

- [x] Standing rule: run `/code-review` before a commit is proposed.
- [x] Standing rule: run `/simplify` after a feature works, before commit.
- [x] Formalize "why, not what" as the comment rule in CLAUDE.md.
- [x] Require a comment on any deliberate non-obvious workaround (narrow exception to "no comments").
- [x] Rule: update docs in the same turn as the code change that invalidates them.
- [x] Rule: never mark a task done with a failing or skipped test without saying so.
- [x] Use `security-review` skill before merging security-sensitive changes.

## Global — code-quality.md (imported from CLAUDE.md)

- [x] No single-use function extraction; inline single-use helpers.
- [x] Python: no `Any` as a contract; narrow to a concrete type at the boundary.
- [x] No one-test-per-function default; test at a behavior boundary.
- [x] A bug fix ships with a regression test that reproduces it first.
- [x] File/folder size: ~300-400 lines is a cohesion signal, not a split command; group by domain.
- [x] Conflict precedence: a project CLAUDE.md overrides this section, for that project only.

All global items are done. Restart the session to load the latest
`@rules/code-quality.md` content and the new `## Process` section.

## Per-project (needs a concrete repo to act on)

- [ ] Run `init` to generate/refresh project `CLAUDE.md` per active repo — captures build/test/lint commands as facts.
- [ ] Add explicit coding style rules (naming, error handling, module layout) — derive from the codebase via `init`, not hand-written.
- [ ] Add a project-local `PostToolUse` hook (matcher `Write|Edit`) in that repo's own `.claude/settings.json`,
      running the test/lint command `init` discovered. Procedure: run `init` in the repo first to name the
      command as a fact, then add the hook there — not in `~/.claude/settings.json`. Needs a repo named first.

## Global — done (this session, 2026-08-28)

- [x] `Notification` hook: `~/.claude/hooks/notify.sh`, registered in `~/.claude/settings.json`. Shows a
      macOS notification and plays a sound whenever Claude Code sends a `Notification` event.

## Already covered, no action needed

- No new `*.md` files unless asked — already enforced by the system output style.

---

**Archived 2026-09-12.** Every global item is done. The three per-project items
stay open, and cannot run until a concrete repo is named: they depend on `init`
discovering that repo's build, test, and lint commands.
