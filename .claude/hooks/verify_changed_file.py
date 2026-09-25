#!/usr/bin/env python3
"""Cheap PostToolUse verification for changed files.

Reads Claude Code hook JSON from stdin. Only performs deterministic, low-cost
checks. Exit 2 blocks the operation and feeds stderr back to Claude.
"""

from __future__ import annotations

import json
import os
import pathlib
import subprocess
import sys


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except json.JSONDecodeError:
        return 0

    tool_input = payload.get("tool_input") or {}
    path = tool_input.get("file_path") or tool_input.get("path")
    if not path:
        return 0

    p = pathlib.Path(path)
    if not p.is_absolute():
        p = pathlib.Path(payload.get("cwd") or os.getcwd()) / p
    p = p.resolve()

    if p.suffix != ".py" or not p.exists() or not p.is_file():
        return 0

    proc = subprocess.run(
        [sys.executable, "-m", "py_compile", str(p)],
        cwd=str(p.parent),
        text=True,
        capture_output=True,
        check=False,
    )
    if proc.returncode == 0:
        return 0

    sys.stderr.write(
        f"CLAE verification failed for {p}: Python syntax/compile check failed.\n"
        f"{proc.stderr.strip()}\n"
    )
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
