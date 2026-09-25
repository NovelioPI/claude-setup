from __future__ import annotations

import re

from .models import ContextDemand

# Whole-word keywords. Substring matching misroutes tasks ("build" contains "ui",
# "author" contains "auth", "latest" contains "test").
TASK_TYPE_KEYWORDS = (
    ("brainstorm", {"brainstorm", "idea", "ideas", "explore", "research"}),
    ("docs", {"document", "documentation", "docs", "readme"}),
    ("design", {"design", "ui", "ux", "frontend", "screen", "screens"}),
    ("test", {"test", "tests", "testing", "coverage", "flaky"}),
    ("bug_fix", {"fix", "bug", "bugs", "error", "errors", "broken", "issue"}),
)
HIGH_RISK_KEYWORDS = {
    "security",
    "auth",
    "authentication",
    "authorization",
    "payment",
    "payments",
    "migration",
    "migrations",
    "production",
}
LOW_RISK_KEYWORDS = {"rename", "typo", "typos", "format", "simple", "trivial"}
PROJECT_KEYWORDS = {"project", "jira", "backlog"}
STOPWORDS = {
    "the",
    "and",
    "for",
    "with",
    "that",
    "this",
    "from",
    "into",
    "not",
    "are",
    "was",
    "were",
    "has",
    "have",
    "but",
    "all",
    "any",
    "can",
    "should",
    "when",
    "then",
    "than",
    "our",
    "you",
    "its",
    "also",
    "add",
    "use",
    "make",
    "new",
}


def infer_demand(
    task: str, task_id: str | None, budget_tokens: int = 10000
) -> ContextDemand:
    low = task.lower()
    words = set(re.findall(r"[a-z0-9_]+", low))
    terms = set(re.findall(r"[a-z_][a-z0-9_]{2,}", low)) - STOPWORDS

    task_type = next(
        (name for name, keys in TASK_TYPE_KEYWORDS if words & keys), "code"
    )

    risk = "high" if words & HIGH_RISK_KEYWORDS else "medium"
    if words & LOW_RISK_KEYWORDS:
        risk = "low"

    needs_tests = task_type in {"code", "bug_fix", "test"}
    needs_docs = task_type == "docs"
    needs_design = task_type == "design"
    needs_project_state = bool(words & PROJECT_KEYWORDS) or "next task" in low
    forbidden_patterns = []
    if task_type in {"code", "bug_fix", "test"} and not needs_design:
        forbidden_patterns.append("design")
    if task_type != "brainstorm" and not needs_project_state:
        forbidden_patterns.append("project")

    depth = 2 if task_type in {"design", "docs"} else 1
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
        required_terms=sorted(terms),
        forbidden_patterns=forbidden_patterns,
        needs_design=needs_design,
        needs_project_state=needs_project_state,
        needs_docs=needs_docs,
        needs_tests=needs_tests,
    )
