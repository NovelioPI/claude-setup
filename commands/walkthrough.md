---
description: Check my understanding of the current change before the commit
---

1. Before you show anything, ask me to predict which files changed and how.
   Wait for my answer. Then list the changed files from `git diff HEAD --stat`
   and `git ls-files --others --exclude-standard`, and name what I missed.
2. Summarize the change in 8 lines or fewer: what changed, why, the key
   decision, and how it could fail.
3. Point to the 2 or 3 most important places (file:line), in reading order.
4. Ask me 3 questions, one at a time, that I can answer only if I understand
   the change: edge cases, invariants, failure modes. No yes/no questions.
   Do not show an answer before I try.
5. After each answer, correct me exactly where I am wrong.
6. End with PASS (all answers correct) or GAPS: <list>. Append one line to
   `.agent/understanding-gaps.md`, and create the file if it is missing:
   `<YYYY-MM-DD> | PASS or GAPS | <main file> | <topic of each gap>`
