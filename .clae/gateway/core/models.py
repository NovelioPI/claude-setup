from __future__ import annotations

from dataclasses import asdict, dataclass, field
from typing import Any, Literal

CandidateKind = Literal[
    "task",
    "code",
    "test",
    "rule",
    "doc",
    "adr",
    "project",
    "design",
    "memory",
    "git",
    "tool_result",
    "other",
]

# Soft candidates below this relevance are never selected.
MIN_SOFT_RELEVANCE = 0.18


@dataclass(slots=True)
class ContextDemand:
    task_id: str | None
    task_type: str
    objective: str
    budget_tokens: int = 10000
    risk: str = "medium"
    code_depth: int = 1
    test_depth: int = 1
    docs_depth: int = 0
    project_depth: int = 0
    breadth: int = 3
    required_terms: list[str] = field(default_factory=list)
    forbidden_patterns: list[str] = field(default_factory=list)
    needs_design: bool = False
    needs_project_state: bool = False
    needs_docs: bool = False
    needs_tests: bool = False

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass(slots=True)
class ContextCandidate:
    id: str
    kind: CandidateKind
    source: str
    title: str
    estimated_tokens: int
    authority: float = 0.7
    freshness: float = 1.0
    relevance: float = 0.1
    dependency: float = 0.1
    confidence: float = 0.8
    hard: bool = False
    line_start: int | None = None
    line_end: int | None = None
    symbol: str | None = None
    metadata: dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)

    @property
    def base_utility(self) -> float:
        cost_penalty = max(self.estimated_tokens, 1) ** 0.7
        return (
            self.relevance
            * self.authority
            * self.freshness
            * max(self.dependency, 0.05)
            * self.confidence
        ) / cost_penalty


@dataclass(slots=True)
class ContextPackage:
    task_id: str | None
    objective: str
    budget_tokens: int
    selected: list[ContextCandidate]
    deferred: list[ContextCandidate]
    forbidden: list[str]
    remaining_tokens: int
    escalation_level: int = 1
    metadata: dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict[str, Any]:
        data = asdict(self)
        data["selected"] = [c.to_dict() for c in self.selected]
        data["deferred"] = [c.to_dict() for c in self.deferred]
        return data


@dataclass(slots=True)
class Checkpoint:
    task_id: str
    objective: str
    completed: list[str]
    evidence: list[str]
    unresolved: list[str]
    retained: list[str]
    discarded: list[str]
    source_artifacts: list[str]

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)
