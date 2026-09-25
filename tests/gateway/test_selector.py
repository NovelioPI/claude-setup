import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / ".clae"))

from gateway.core.models import ContextCandidate, ContextDemand
from gateway.core.selector import select_context


def demand(budget=1000):
    return ContextDemand(
        task_id="T-1",
        task_type="code",
        objective="fix optimizer",
        budget_tokens=budget,
        risk="medium",
        required_terms=["optimizer"],
        needs_tests=True,
    )


def test_hard_context_is_always_selected():
    hard = ContextCandidate(
        "h",
        "task",
        "contract.md",
        "contract",
        300,
        hard=True,
        authority=1,
        freshness=1,
        relevance=1,
        dependency=1,
        confidence=1,
    )
    soft = ContextCandidate(
        "s",
        "code",
        "a.py",
        "a",
        600,
        authority=1,
        freshness=1,
        relevance=1,
        dependency=1,
        confidence=1,
    )
    pkg = select_context([hard, soft], demand(700))
    assert [x.id for x in pkg.selected] == ["h"]
    assert pkg.remaining_tokens == 400


def test_soft_candidates_compete_for_budget():
    a = ContextCandidate(
        "a",
        "code",
        "a.py",
        "a",
        200,
        authority=1,
        freshness=1,
        relevance=1,
        dependency=1,
        confidence=1,
    )
    b = ContextCandidate(
        "b",
        "code",
        "b.py",
        "b",
        700,
        authority=1,
        freshness=1,
        relevance=0.9,
        dependency=1,
        confidence=1,
    )
    pkg = select_context([a, b], demand(800))
    assert [x.id for x in pkg.selected] == ["a"]
    assert pkg.remaining_tokens == 600
