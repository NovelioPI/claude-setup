import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / ".clae"))
from gateway.core.checkpoint import build_checkpoint


def test_checkpoint_collects_existing_artifacts(tmp_path):
    task = tmp_path / ".claude" / "work" / "T-1"
    task.mkdir(parents=True)
    (task / "contract.md").write_text("# Goal\nFix it\n")
    (task / "verification.md").write_text("# Status\nPASS\n")
    cp = build_checkpoint(tmp_path, "T-1", "Fix it")
    assert "contract.md" in cp.source_artifacts[0]
    assert cp.objective == "Fix it"
