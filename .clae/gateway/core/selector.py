from __future__ import annotations

from .models import ContextCandidate, ContextDemand, ContextPackage
from .scoring import marginal_utility

MIN_UTILITY = 1e-6


def select_context(
    candidates: list[ContextCandidate],
    demand: ContextDemand,
    forbidden: list[str] | None = None,
) -> ContextPackage:
    forbidden = forbidden or []

    def blocked(candidate):
        haystack = f"{candidate.source} {candidate.title}".lower()
        return candidate.kind in forbidden or any(
            token.lower() in haystack for token in forbidden
        )

    candidates = [c for c in candidates if not blocked(c)]
    candidates = [c for c in candidates if c.hard or c.relevance >= 0.18]
    hard = [c for c in candidates if c.hard]
    soft = [c for c in candidates if not c.hard]

    hard_cost = sum(c.estimated_tokens for c in hard)
    if hard_cost > demand.budget_tokens:
        raise ValueError(
            f"Hard context requires {hard_cost} tokens, exceeding budget {demand.budget_tokens}. "
            "Reduce scope or increase the task budget."
        )

    selected = list(hard)
    remaining = demand.budget_tokens - hard_cost
    deferred: list[ContextCandidate] = []
    selected_soft = 0
    max_soft = max(1, demand.breadth)
    max_per_kind = 2
    kind_counts: dict[str, int] = {}

    # Greedy marginal utility with an explicit breadth cap. The result is deterministic.
    while soft and remaining > 0 and selected_soft < max_soft:
        ranked = []
        for c in soft:
            if (
                c.estimated_tokens <= remaining
                and kind_counts.get(c.kind, 0) < max_per_kind
            ):
                ranked.append((marginal_utility(c, selected, demand), c.id, c))
        if not ranked:
            break
        utility, _, candidate = max(ranked, key=lambda item: (item[0], item[1]))
        if utility <= MIN_UTILITY:
            break
        selected.append(candidate)
        remaining -= candidate.estimated_tokens
        soft.remove(candidate)
        selected_soft += 1
        kind_counts[candidate.kind] = kind_counts.get(candidate.kind, 0) + 1

    deferred.extend(soft)
    return ContextPackage(
        task_id=demand.task_id,
        objective=demand.objective,
        budget_tokens=demand.budget_tokens,
        selected=selected,
        deferred=deferred,
        forbidden=forbidden,
        remaining_tokens=remaining,
        escalation_level=1,
        metadata={"selection": "greedy-marginal-utility"},
    )
