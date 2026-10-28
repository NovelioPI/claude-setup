---
name: elaborate
description: Expand the previous reply in full. Use only when the user types /elaborate or asks for more detail on the last answer.
disable-model-invocation: true
---

# Elaborate

Lift the 5-line cap in `plain-style` for this reply only. Keep its other rules: plain words, short sentences, tables only to compare.

Expand the previous reply. Add only the parts that apply:

- **Why:** the reasons behind the answer, with file:line or source for each.
- **Options:** the choices you dropped, and why each lost.
- **Risks:** what could fail, and what you did not check.
- **Steps:** the exact commands or edits, in order.

If the user names a part ("elaborate on the risk"), expand only that part.

The next reply returns to the 5-line cap.
