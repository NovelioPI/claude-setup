from __future__ import annotations

from pathlib import Path

from .models import ContextPackage


def _read_window(
    path: Path, start: int | None, end: int | None, max_lines: int = 120
) -> str:
    lines = path.read_text(encoding="utf-8", errors="ignore").splitlines()
    if not lines:
        return ""
    if start is None:
        start = 1
    if end is None:
        end = min(len(lines), start + max_lines - 1)
    start = max(1, start - 4)
    end = min(len(lines), end + 4)
    return "\n".join(f"{i:04d}: {lines[i - 1]}" for i in range(start, end + 1))


def materialize(root: Path, package: ContextPackage) -> dict:
    items = []
    for candidate in package.selected:
        path = root / candidate.source
        if not path.exists():
            items.append(
                {"id": candidate.id, "source": candidate.source, "missing": True}
            )
            continue
        try:
            content = _read_window(path, candidate.line_start, candidate.line_end)
        except OSError as exc:
            content = f"<read error: {exc}>"
        items.append(
            {
                "id": candidate.id,
                "kind": candidate.kind,
                "source": candidate.source,
                "title": candidate.title,
                "symbol": candidate.symbol,
                "content": content,
            }
        )
    return {
        "version": 1,
        "task_id": package.task_id,
        "objective": package.objective,
        "budget_tokens": package.budget_tokens,
        "remaining_tokens": package.remaining_tokens,
        "escalation_level": package.escalation_level,
        "items": items,
        "deferred": [c.to_dict() for c in package.deferred],
        "forbidden": package.forbidden,
    }
