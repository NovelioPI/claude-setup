from __future__ import annotations

import json
from pathlib import Path

from .capability import preferred_capabilities
from .checkpoint import build_checkpoint
from .demand import infer_demand
from .discovery import build_index, discover_candidates
from .escalation import decide
from .materializer import materialize
from .selector import select_context
from .telemetry import event


class ContextGateway:
    def __init__(self, root: Path):
        self.root = root.resolve()
        self.runtime = self.root / ".clae" / "runtime"
        self.runtime.mkdir(parents=True, exist_ok=True)

    def index(self) -> Path:
        data = build_index(self.root)
        path = self.runtime / "indexes" / "repo.json"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(data, indent=2), encoding="utf-8")
        event(
            self.root,
            "index",
            {"files": len(data["files"]), "symbols": len(data["symbols"])},
        )
        return path

    def build_package(self, task: str, task_id: str | None = None, budget: int = 10000):
        demand = infer_demand(task, task_id, budget)
        artifacts = []
        if task_id:
            base = self.root / ".claude" / "work" / task_id
            artifacts = [base / name for name in ("contract.md", "facts.md", "plan.md")]
        candidates = discover_candidates(self.root, demand, artifacts)
        package = select_context(
            candidates, demand, forbidden=demand.forbidden_patterns
        )
        materialized = materialize(self.root, package)
        path = self.runtime / "context-packages" / f"{task_id or 'adhoc'}.json"
        path.parent.mkdir(parents=True, exist_ok=True)
        package.metadata["capabilities"] = preferred_capabilities(
            needs_project_state=demand.needs_project_state,
            needs_design=demand.needs_design,
        )
        payload = {"package": package.to_dict(), "materialized": materialized}
        path.write_text(json.dumps(payload, indent=2), encoding="utf-8")
        event(
            self.root,
            "context_package",
            {
                "task_id": task_id,
                "tokens_used": budget - package.remaining_tokens,
                "selected": len(package.selected),
                "deferred": len(package.deferred),
                "escalations": 0,
            },
        )
        return package, materialized, path

    def escalate(
        self,
        task: str,
        task_id: str,
        reason: str,
        current_level: int = 1,
        step: int = 0,
        budget: int = 10000,
    ):
        decision = decide(current_level, reason, step)
        if not decision.allowed:
            event(
                self.root,
                "escalation_blocked",
                {"task_id": task_id, "reason": reason, "level": current_level},
            )
            return decision, None
        new_budget = min(int(budget * decision.budget_multiplier), int(budget * 2.0))
        package, materialized, path = self.build_package(task, task_id, new_budget)
        package.escalation_level = decision.to_level
        data = {
            "package": package.to_dict(),
            "materialized": materialized,
            "escalation": {"reason": reason, "message": decision.message},
        }
        path.write_text(json.dumps(data, indent=2), encoding="utf-8")
        event(
            self.root,
            "escalation",
            {
                "task_id": task_id,
                "reason": reason,
                "from_level": current_level,
                "to_level": decision.to_level,
                "tokens_used": new_budget - package.remaining_tokens,
                "escalations": 1,
            },
        )
        return decision, path

    def checkpoint(self, task_id: str, objective: str | None = None) -> Path:
        cp = build_checkpoint(self.root, task_id, objective)
        path = self.runtime / "checkpoints" / f"{task_id}.json"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(cp.to_dict(), indent=2), encoding="utf-8")
        event(
            self.root,
            "checkpoint",
            {"task_id": task_id, "artifacts": len(cp.source_artifacts)},
        )
        return path
