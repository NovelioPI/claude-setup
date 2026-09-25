from __future__ import annotations

from pathlib import Path

from .models import Checkpoint


def _headings(path: Path) -> list[str]:
    if not path.exists():
        return []
    result = []
    for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        if line.startswith("#"):
            result.append(line.strip("# ").strip())
    return result[:12]


def build_checkpoint(
    root: Path, task_id: str, objective: str | None = None
) -> Checkpoint:
    base = root / ".claude" / "work" / task_id
    files = [
        "contract.md",
        "facts.md",
        "plan.md",
        "changes.md",
        "verification.md",
        "review.md",
        "test-decision.md",
    ]
    completed = []
    unresolved = []
    evidence = []
    retained = []
    used = []
    for name in files:
        path = base / name
        if not path.exists():
            continue
        used.append(str(path.relative_to(root)).replace("\\", "/"))
        headings = _headings(path)
        if name in {"changes.md", "verification.md", "review.md"}:
            completed.extend(headings[:4])
        if "FAIL" in path.read_text(encoding="utf-8", errors="ignore"):
            unresolved.append(f"Review {name} for FAIL status")
        evidence.extend(f"{name}: {h}" for h in headings[:3])
        retained.append(str(path.relative_to(root)).replace("\\", "/"))
    if not completed:
        completed.append("No completed phase detected yet")
    return Checkpoint(
        task_id=task_id,
        objective=objective or "See contract.md",
        completed=completed[:12],
        evidence=evidence[:12],
        unresolved=unresolved[:8],
        retained=retained,
        discarded=["raw transcript", "redundant tool output", "superseded exploration"],
        source_artifacts=used,
    )
