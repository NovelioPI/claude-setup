from __future__ import annotations

import json
import time
from collections import Counter
from pathlib import Path


def event(root: Path, event_type: str, payload: dict) -> Path:
    out = root / ".clae" / "runtime" / "telemetry" / "events.jsonl"
    out.parent.mkdir(parents=True, exist_ok=True)
    record = {"ts": time.time(), "event": event_type, **payload}
    with out.open("a", encoding="utf-8") as f:
        f.write(json.dumps(record, separators=(",", ":")) + "\n")
    return out


def summary(root: Path) -> dict:
    path = root / ".clae" / "runtime" / "telemetry" / "events.jsonl"
    if not path.exists():
        return {"events": 0, "types": {}, "tasks": {}}
    types = Counter()
    tasks = Counter()
    tokens = 0
    escalations = 0
    for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        try:
            row = json.loads(line)
        except json.JSONDecodeError:
            continue
        types[row.get("event", "unknown")] += 1
        if row.get("task_id"):
            tasks[row["task_id"]] += 1
        tokens += int(row.get("tokens_used", 0) or 0)
        escalations += int(row.get("escalations", 0) or 0)
    return {
        "events": sum(types.values()),
        "types": dict(types),
        "tasks": dict(tasks),
        "tokens_used": tokens,
        "escalations": escalations,
    }
