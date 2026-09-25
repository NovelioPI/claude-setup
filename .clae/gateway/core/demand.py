from __future__ import annotations

import re

from .models import ContextDemand


def infer_demand(
    task: str, task_id: str | None, budget_tokens: int = 10000
) -> ContextDemand:
    low = task.lower()
    tokens = set(re.findall(r"[a-z_][a-z0-9_]{2,}", low))

    if any(k in low for k in ("brainstorm", "idea", "explore", "research")):
        task_type = "brainstorm"
    elif any(k in low for k in ("document", "docs", "readme", "documentation")):
        task_type = "docs"
    elif any(k in low for k in ("design", "ui", "ux", "frontend", "screen")):
        task_type = "design"
    elif any(k in low for k in ("test", "testing", "coverage", "flaky")):
        task_type = "test"
    elif any(k in low for k in ("fix", "bug", "error", "broken", "issue")):
        task_type = "bug_fix"
    else:
        task_type = "code"

    risk = (
        "high"
        if any(
            k in low for k in ("security", "auth", "payment", "migration", "production")
        )
        else "medium"
    )
    if any(k in low for k in ("rename", "typo", "format", "simple", "trivial")):
        risk = "low"

    needs_tests = task_type in {"code", "bug_fix", "test"}
    needs_docs = task_type == "docs"
    needs_design = task_type == "design"
    needs_project_state = any(
        k in low for k in ("project", "jira", "next task", "backlog")
    )
    forbidden_patterns = []
    if task_type in {"code", "bug_fix", "test"} and not needs_design:
        forbidden_patterns.append("design")
    if task_type not in {"project", "brainstorm"} and not needs_project_state:
        forbidden_patterns.append("project")

    depth = (
        1
        if task_type in {"code", "bug_fix"}
        else 2
        if task_type in {"design", "docs"}
        else 1
    )
    breadth = 3 if risk != "high" else 5

    return ContextDemand(
        task_id=task_id,
        task_type=task_type,
        objective=task.strip(),
        budget_tokens=budget_tokens,
        risk=risk,
        code_depth=depth,
        test_depth=1 if needs_tests else 0,
        docs_depth=1 if needs_docs else 0,
        project_depth=1 if needs_project_state else 0,
        breadth=breadth,
        required_terms=sorted(tokens),
        forbidden_patterns=forbidden_patterns,
        needs_design=needs_design,
        needs_project_state=needs_project_state,
        needs_docs=needs_docs,
        needs_tests=needs_tests,
    )
