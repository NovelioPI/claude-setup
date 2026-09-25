import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / ".clae"))
from gateway.core.escalation import decide


def test_escalation_advances_one_level():
    d = decide(1, "missing_symbol", 0)
    assert d.allowed
    assert d.to_level == 2


def test_invalid_reason_is_blocked():
    d = decide(1, "curiosity", 0)
    assert not d.allowed
