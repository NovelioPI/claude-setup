from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class Capability:
    name: str
    tier: int
    token_cost: int
    latency: str
    authority: float
    side_effects: str


CAPABILITIES = {
    "local_artifact": Capability("local_artifact", 0, 50, "low", 0.95, "none"),
    "local_index": Capability("local_index", 1, 100, "low", 0.9, "none"),
    "git": Capability("git", 2, 250, "low", 0.95, "low"),
    "mcp": Capability("mcp", 3, 700, "medium", 0.9, "medium"),
    "human": Capability("human", 4, 0, "high", 1.0, "high"),
}


def preferred_capabilities(
    needs_project_state: bool = False, needs_design: bool = False
) -> list[str]:
    if needs_project_state:
        return ["local_artifact", "local_index", "git", "mcp", "human"]
    if needs_design:
        return ["local_artifact", "local_index", "mcp", "human"]
    return ["local_artifact", "local_index", "git", "mcp", "human"]
