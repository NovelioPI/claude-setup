import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / ".clae"))
from gateway.core.demand import infer_demand
from gateway.core.discovery import discover_candidates
from gateway.core.selector import select_context


def test_code_task_forbids_design_context(tmp_path):
    (tmp_path / ".claude" / "rules" / "languages").mkdir(parents=True)
    (tmp_path / ".claude" / "rules" / "languages" / "python.md").write_text("python")
    (tmp_path / ".claude" / "rules" / "clean-code.md").write_text("clean")
    (tmp_path / "ui").mkdir()
    (tmp_path / "ui" / "design.md").write_text("design optimizer")
    (tmp_path / "optimizer.py").write_text(
        "def calculate_bid(value):\n    return value * 2\n"
    )
    demand = infer_demand("fix optimizer bug", "T-1")
    candidates = discover_candidates(tmp_path, demand, [])
    assert "design" in demand.forbidden_patterns
    package = select_context(candidates, demand, forbidden=demand.forbidden_patterns)
    assert not any("design.md" in c.source for c in package.selected)
    assert any(c.symbol == "calculate_bid" for c in package.selected)


def test_repo_under_excluded_dir_name_is_still_scanned(tmp_path):
    repo = tmp_path / "build" / "repo"
    repo.mkdir(parents=True)
    (repo / "optimizer.py").write_text("def optimize():\n    return 1\n")
    demand = infer_demand("fix optimizer bug", "T-1")
    candidates = discover_candidates(repo, demand, [])
    assert any(c.source == "optimizer.py" for c in candidates)


def test_test_detection_uses_file_name_patterns(tmp_path):
    (tmp_path / "latest.py").write_text("def optimizer():\n    return 1\n")
    (tmp_path / "test_optimizer.py").write_text("def test_optimizer():\n    pass\n")
    demand = infer_demand("fix optimizer bug", "T-1")
    kinds = {c.source: c.kind for c in discover_candidates(tmp_path, demand, [])}
    assert kinds["latest.py"] == "code"
    assert kinds["test_optimizer.py"] == "test"
