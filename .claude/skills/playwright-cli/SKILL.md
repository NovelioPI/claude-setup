---
name: playwright-cli
description: Use Playwright CLI plus focused commands for browser verification with low context overhead.
---

# Playwright CLI Workflow

Use for frontend acceptance checks and visual/browser verification.

## Rules

- Prefer concise CLI actions over loading the full MCP tool surface.
- Start only the app/service needed for the check.
- Check accessibility and interaction outcomes before visual polish.
- Save only useful screenshots or traces.
- Summarize failures instead of pasting long logs into the main context.

## Verification order

1. route loads
2. primary interaction works
3. empty/loading/error states
4. accessibility basics
5. responsive layout
6. visual polish
