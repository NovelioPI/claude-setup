import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / ".clae"))
from gateway.core.capability import preferred_capabilities


def test_project_state_prefers_local_before_mcp():
    caps = preferred_capabilities(needs_project_state=True)
    assert caps[:2] == ["local_artifact", "local_index"]
    assert caps.index("mcp") > caps.index("git")
