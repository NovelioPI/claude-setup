---
name: ui-check
description: Check a frontend change in a real browser with Playwright before reporting it done. Use after any change to a page, component, or style.
---

# Check a UI change

1. Find the dev server command in `package.json` or the project CLAUDE.md. If none is clear, ask.
2. Start the server with the Bash tool in background mode. Wait for it with a command that exits when the port answers:

       until curl -sf http://localhost:<port> >/dev/null; do sleep 1; done

3. Open each changed page with the Playwright tools.
4. For each page:
   - Take a snapshot and check that the changed element is there and reads right.
   - Take a screenshot at 1280x800, then at 390x844 after a resize.
   - Read the console messages. Any error fails the check.
   - Click through the changed interaction once, if there is one.
5. Stop the dev server.
6. Report one row per page: the URL, the two screenshot paths, the console errors, and pass or fail.

A failed check is not done. Fix it inside the plan, or report it.
