#!/usr/bin/env python3
from __future__ import annotations

import argparse
from datetime import UTC, datetime
from pathlib import Path

TEMPLATE = """id: {task_id}
title: {title}
status: PLANNED
priority: medium
depends_on: []
scope: []
acceptance:
  - Define acceptance criteria
blocker: null
artifacts: {{}}
created: {today}
updated: {today}
"""


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("task_id")
    parser.add_argument("title")
    args = parser.parse_args()

    root = Path.cwd()
    path = root / ".clae" / "tasks" / f"{args.task_id}.yaml"
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        raise SystemExit(f"Task already exists: {path}")
    path.write_text(
        TEMPLATE.format(
            task_id=args.task_id,
            title=args.title,
            today=datetime.now(UTC).date().isoformat(),
        )
    )
    print(path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
