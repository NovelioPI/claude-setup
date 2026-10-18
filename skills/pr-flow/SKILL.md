---
name: pr-flow
description: Open a pull request with gh and watch its CI until every check ends. Use when a branch is ready for review, or the user asks to open a PR.
---

# Open a PR and watch CI

1. Check the branch. Stop if it is the default branch or has uncommitted changes.
2. Run the project's tests, lint, and build. Stop on a failure.
3. Show the branch, the commits, and the PR title and body. Ask before the push: a push leaves this machine, so it always needs approval, even under Auto.
4. Push with `git push -u origin <branch>`.
5. Create the PR with `gh pr create --title <title> --body <body>`. The body has:
   - Why: the reason, in two lines at most.
   - What: the changes a reviewer must look at.
   - Tests: what ran, and the result.
   - The Linear issue link, when there is one.
6. Watch CI with the Monitor tool. Emit each check when it ends, and exit when none is pending:

       prev="" while true; do s=$(gh pr checks <n> --json name,bucket || echo '[]') cur=$(jq -r '.[] | select(.bucket!="pending") | "\(.name): \(.bucket)"' <<<"$s" | sort) comm -13 <(echo "$prev") <(echo "$cur") prev=$cur jq -e 'length > 0 and all(.bucket!="pending")' <<<"$s" >/dev/null && break sleep 30 done

7. For each failed check, read `gh run view <run-id> --log-failed` and report the failing lines.
8. Report the PR URL and one row per check.

Never merge the PR. Never push again without asking.
