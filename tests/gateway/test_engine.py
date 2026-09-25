import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / ".clae"))
from gateway.core.engine import ContextGateway


def make_repo(tmp_path):
    (tmp_path / "optimizer.py").write_text("def optimize():\n    return 1\n")
    return ContextGateway(tmp_path)


def test_escalation_persists_level_in_package_and_materialized(tmp_path):
    gw = make_repo(tmp_path)
    gw.build_package("fix optimizer bug", "T-1")
    decision, path = gw.escalate("fix optimizer bug", "T-1", "missing_symbol")
    data = json.loads(path.read_text())
    assert decision.to_level == 2
    assert data["package"]["escalation_level"] == 2
    assert data["materialized"]["escalation_level"] == 2
    assert data["escalation"]["step"] == 1


def test_escalation_resumes_from_saved_state_until_limit(tmp_path):
    gw = make_repo(tmp_path)
    gw.build_package("fix optimizer bug", "T-1")
    levels = []
    for _ in range(3):
        decision, _ = gw.escalate("fix optimizer bug", "T-1", "missing_symbol")
        levels.append(decision.to_level)
    blocked, path = gw.escalate("fix optimizer bug", "T-1", "missing_symbol")
    assert levels == [2, 3, 4]
    assert not blocked.allowed
    assert path is None


def test_escalated_budget_is_capped_relative_to_base(tmp_path):
    gw = make_repo(tmp_path)
    gw.build_package("fix optimizer bug", "T-1", budget=1000)
    for _ in range(3):
        _, path = gw.escalate("fix optimizer bug", "T-1", "missing_symbol")
    budget = json.loads(path.read_text())["package"]["budget_tokens"]
    assert budget <= 2000
