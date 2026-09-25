#!/usr/bin/env python3
"""Stop hook: verify an active CLAE task only when explicitly activated.

The router creates `.claude/work/ACTIVE`. The file may contain either a task ID
or `TASK_ID|VERIFY_ON_STOP=1`.

This hook intentionally stays conservative: when activated it runs
`git diff --check` and discovers a focused test command from the active task's verification.md if
one is recorded. It blocks only when a recorded required check fails.
"""

from __future__ import annotations

import json
import os
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()).resolve()
ACTIVE = ROOT / ".claude" / "work" / "ACTIVE"


def run(cmd: list[str]) -> tuple[int, str]:
    proc = subprocess.run(cmd, cwd=ROOT, text=True, capture_output=True, check=False)
    output = (proc.stdout + "\n" + proc.stderr).strip()
    return proc.returncode, output[-4000:]


def stop_hook_active() -> bool:
    """True when Claude is already continuing because a Stop hook blocked."""
    try:
        return bool(json.load(sys.stdin).get("stop_hook_active"))
    except (json.JSONDecodeError, AttributeError):
        return False


def main() -> int:
    if not ACTIVE.exists():
        return 0
    # Block at most once per stop; a persistent failure must not loop forever.
    if stop_hook_active():
        return 0

    raw = ACTIVE.read_text(encoding="utf-8").strip()
    if not raw:
        return 0

    task_id = raw.split("|", 1)[0].strip()
    verify_enabled = (
        "VERIFY_ON_STOP=1" in raw or os.environ.get("CLAE_VERIFY_ON_STOP") == "1"
    )
    if not verify_enabled:
        return 0

    code, out = run(["git", "diff", "--check"])
    if code != 0:
        sys.stderr.write(
            "CLAE stop verification failed: `git diff --check`.\n" + out + "\n"
        )
        return 2

    verification = ROOT / ".claude" / "work" / task_id / "verification.md"
    if verification.exists():
        text = verification.read_text(encoding="utf-8")
        # Optional focused commands recorded as lines: COMMAND: <shell command>
        commands = re.findall(r"^COMMAND:\s*(.+)$", text, flags=re.MULTILINE)
        for command in commands[:5]:
            proc = subprocess.run(
                command,
                cwd=ROOT,
                shell=True,
                text=True,
                capture_output=True,
                check=False,
            )
            if proc.returncode != 0:
                detail = (proc.stdout + "\n" + proc.stderr).strip()[-4000:]
                sys.stderr.write(
                    f"CLAE stop verification failed: {command}\n{detail}\n"
                )
                return 2

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
