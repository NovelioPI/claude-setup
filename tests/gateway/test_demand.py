import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / ".clae"))
from gateway.core.demand import infer_demand


def test_bug_task_becomes_bug_fix():
    d = infer_demand("Fix the authentication bug", "T-1")
    assert d.task_type == "bug_fix"
    assert d.risk == "high"
    assert d.needs_tests
