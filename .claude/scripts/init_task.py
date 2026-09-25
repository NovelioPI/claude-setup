#!/usr/bin/env python3
from __future__ import annotations

import datetime as dt
import pathlib
import re
import sys


def slug(text: str) -> str:
    value = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
    return value[:32] or "task"


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: init_task.py <task description>", file=sys.stderr)
        return 2
    root = pathlib.Path.cwd().resolve()
    task_id = (
        f"TASK-{dt.datetime.now(dt.UTC):%Y%m%d-%H%M}-{slug(' '.join(sys.argv[1:]))}"
    )
    work = root / ".claude" / "work" / task_id
    work.mkdir(parents=True, exist_ok=False)
    (root / ".claude" / "work" / "ACTIVE").write_text(
        task_id + "|VERIFY_ON_STOP=1\n", encoding="utf-8"
    )
    print(task_id)
    print(work)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
