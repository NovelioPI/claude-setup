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

DEFAULT_CONFIG = {
    "default_budget_tokens": 10000,
    "max_escalation_steps": 3,
    "max_budget_multiplier": 2.0,
    "min_candidate_utility": 0.000001,
}


def load_config(root: Path) -> dict:
    path = root / ".clae" / "gateway" / "config.json"
    if not path.exists():
        return dict(DEFAULT_CONFIG)
    return {**DEFAULT_CONFIG, **json.loads(path.read_text(encoding="utf-8"))}


class ContextGateway:
    def __init__(self, root: Path):
        self.root = root.resolve()
        self.runtime = self.root / ".clae" / "runtime"
        self.runtime.mkdir(parents=True, exist_ok=True)
        self.config = load_config(self.root)

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

    def package_path(self, task_id: str | None) -> Path:
        return self.runtime / "context-packages" / f"{task_id or 'adhoc'}.json"

    def _select(self, task: str, task_id: str | None, budget: int, level: int):
        demand = infer_demand(task, task_id, budget)
        artifacts = []
        if task_id:
            base = self.root / ".claude" / "work" / task_id
            artifacts = [base / name for name in ("contract.md", "facts.md", "plan.md")]
        candidates = discover_candidates(self.root, demand, artifacts)
        package = select_context(
            candidates,
            demand,
            forbidden=demand.forbidden_patterns,
            escalation_level=level,
            min_utility=self.config["min_candidate_utility"],
        )
        package.metadata["capabilities"] = preferred_capabilities(
            needs_project_state=demand.needs_project_state,
            needs_design=demand.needs_design,
        )
        return package, materialize(self.root, package)

    def _write(self, task_id: str | None, payload: dict) -> Path:
        path = self.package_path(task_id)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(payload, indent=2), encoding="utf-8")
        return path

    def build_package(
        self, task: str, task_id: str | None = None, budget: int | None = None
    ):
        budget = budget or self.config["default_budget_tokens"]
        package, materialized = self._select(task, task_id, budget, level=1)
        package.metadata["base_budget"] = budget
        path = self._write(
            task_id, {"package": package.to_dict(), "materialized": materialized}
        )
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

    def _previous_state(self, task_id: str) -> dict:
        """Level, step, and budgets from the task's last package, if any."""
        path = self.package_path(task_id)
        if not path.exists():
            return {}
        data = json.loads(path.read_text(encoding="utf-8"))
        package = data.get("package", {})
        return {
            "level": package.get("escalation_level", 1),
            "step": data.get("escalation", {}).get("step", 0),
            "budget": package.get("budget_tokens"),
            "base_budget": package.get("metadata", {}).get("base_budget"),
        }

    def escalate(
        self,
        task: str,
        task_id: str,
        reason: str,
        current_level: int | None = None,
        step: int | None = None,
        budget: int | None = None,
    ):
        """Escalate one level. Omitted arguments resume from the saved package."""
        previous = self._previous_state(task_id)
        level = current_level if current_level is not None else previous.get("level", 1)
        step = step if step is not None else previous.get("step", 0)
        budget = (
            budget or previous.get("budget") or self.config["default_budget_tokens"]
        )
        base_budget = previous.get("base_budget") or budget

        decision = decide(level, reason, step, self.config["max_escalation_steps"])
        if not decision.allowed:
            event(
                self.root,
                "escalation_blocked",
                {"task_id": task_id, "reason": reason, "level": level, "step": step},
            )
            return decision, None
        new_budget = min(
            int(budget * decision.budget_multiplier),
            int(base_budget * self.config["max_budget_multiplier"]),
        )
        package, materialized = self._select(
            task, task_id, new_budget, level=decision.to_level
        )
        package.metadata["base_budget"] = base_budget
        path = self._write(
            task_id,
            {
                "package": package.to_dict(),
                "materialized": materialized,
                "escalation": {
                    "reason": reason,
                    "message": decision.message,
                    "step": step + 1,
                },
            },
        )
        event(
            self.root,
            "escalation",
            {
                "task_id": task_id,
                "reason": reason,
                "from_level": level,
                "to_level": decision.to_level,
                "step": step + 1,
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
