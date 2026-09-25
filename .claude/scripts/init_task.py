#!/usr/bin/env python3
from __future__ import annotations

import argparse
import datetime as dt
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[2]


def slug(text: str) -> str:
    value = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
    return value[:32] or "task"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("description", nargs="+")
    parser.add_argument("--id", help="Stable task ID, e.g. DSP-142")
    args = parser.parse_args()
    stamp = f"{dt.datetime.now(dt.timezone.utc):%Y%m%d-%H%M}"
    task_id = args.id or f"TASK-{stamp}-{slug(' '.join(args.description))}"
    work = ROOT / ".claude" / "work" / task_id
    work.mkdir(parents=True, exist_ok=False)
    (ROOT / ".claude" / "work" / "ACTIVE").write_text(
        task_id + "|VERIFY_ON_STOP=1\n", encoding="utf-8"
    )
    print(task_id)
    print(work)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
