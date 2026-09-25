from __future__ import annotations

import json
from pathlib import Path


def compact_package(root: Path, task_id: str) -> Path:
    source = root / ".clae" / "runtime" / "context-packages" / f"{task_id}.json"
    if not source.exists():
        raise FileNotFoundError(f"No context package found for {task_id}")
    data = json.loads(source.read_text(encoding="utf-8"))
    materialized = data.get("materialized", {})
    compacted = {
        "version": 1,
        "task_id": task_id,
        "objective": materialized.get("objective"),
        "retained_items": [
            {
                "kind": x.get("kind"),
                "source": x.get("source"),
                "symbol": x.get("symbol"),
            }
            for x in materialized.get("items", [])
            if not x.get("missing")
        ],
        "deferred_count": len(materialized.get("deferred", [])),
        "forbidden": materialized.get("forbidden", []),
        "note": "Use this checkpoint as the minimum routing state; rematerialize detail on demand.",
    }
    out = root / ".clae" / "runtime" / "cache" / f"{task_id}.compact.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(compacted, indent=2), encoding="utf-8")
    return out
