from __future__ import annotations

from pathlib import Path

from .models import ContextCandidate, ContextDemand


def overlap(a: set[str], b: set[str]) -> float:
    if not a or not b:
        return 0.0
    return len(a & b) / max(1, len(a))


def score_candidate(candidate: ContextCandidate, demand: ContextDemand) -> float:
    type_bonus = 1.0
    if demand.needs_tests and candidate.kind == "test":
        type_bonus = 1.5
    elif demand.needs_docs and candidate.kind in {"doc", "adr"}:
        type_bonus = 1.4
    elif demand.needs_design and candidate.kind == "design":
        type_bonus = 1.5
    elif demand.needs_project_state and candidate.kind == "project":
        type_bonus = 1.4
    elif candidate.kind == "code":
        type_bonus = 1.3

    value = (
        candidate.relevance
        * candidate.authority
        * candidate.freshness
        * max(candidate.dependency, 0.05)
        * candidate.confidence
        * type_bonus
    )
    return value / (max(candidate.estimated_tokens, 1) ** 0.7)


def marginal_utility(
    candidate: ContextCandidate, selected: list[ContextCandidate], demand: ContextDemand
) -> float:
    selected_paths = {c.source for c in selected}
    redundancy = 0.0
    if candidate.source in selected_paths:
        redundancy = 1.0
    for item in selected:
        if (
            Path(item.source).suffix == Path(candidate.source).suffix
            and item.kind == candidate.kind
            and Path(item.source).stem == Path(candidate.source).stem
        ):
            redundancy = max(redundancy, 0.7)
    return score_candidate(candidate, demand) * (1.0 - min(redundancy, 0.95))
