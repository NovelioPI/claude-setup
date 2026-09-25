from __future__ import annotations

from dataclasses import dataclass

LEVELS = {
    0: "metadata",
    1: "symbol",
    2: "local_implementation",
    3: "dependencies",
    4: "subsystem",
    5: "repository",
}

VALID_REASONS = {
    "missing_symbol",
    "dependency_impact",
    "conflicting_evidence",
    "failed_verification",
    "unverifiable_acceptance",
}


@dataclass(frozen=True, slots=True)
class EscalationDecision:
    allowed: bool
    from_level: int
    to_level: int
    reason: str
    budget_multiplier: float
    message: str


def decide(
    current_level: int, reason: str, step: int, max_steps: int = 3
) -> EscalationDecision:
    if reason not in VALID_REASONS:
        return EscalationDecision(
            False,
            current_level,
            current_level,
            reason,
            1.0,
            "Unknown escalation reason.",
        )
    if step >= max_steps or current_level >= 5:
        return EscalationDecision(
            False,
            current_level,
            current_level,
            reason,
            1.0,
            "Escalation limit reached; require human review or narrower scope.",
        )
    next_level = min(5, current_level + 1)
    multiplier = 1.25 if next_level < 4 else 1.5
    return EscalationDecision(
        True,
        current_level,
        next_level,
        reason,
        multiplier,
        f"Escalate {LEVELS[current_level]} → {LEVELS[next_level]} because {reason}.",
    )
