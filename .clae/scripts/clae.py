#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT / ".clae") not in sys.path:
    sys.path.insert(0, str(ROOT / ".clae"))

from gateway.core.compact import compact_package
from gateway.core.engine import ContextGateway
from gateway.core.telemetry import event, summary


def main() -> int:
    parser = argparse.ArgumentParser(prog="clae", description="CLAE Context Gateway")
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_index = sub.add_parser("index", help="Build a lightweight repository index")
    p_index.set_defaults(handler="index")

    p_package = sub.add_parser(
        "package", help="Build and materialize a context package"
    )
    p_package.add_argument("--task", required=True)
    p_package.add_argument("--task-id")
    p_package.add_argument("--budget", type=int, help="Defaults to config.json")
    p_package.set_defaults(handler="package")

    p_escalate = sub.add_parser(
        "escalate",
        help="Escalate context after evidence shows the current package is insufficient",
    )
    p_escalate.add_argument("task_id")
    p_escalate.add_argument("--task", required=True)
    p_escalate.add_argument(
        "--reason",
        required=True,
        choices=[
            "missing_symbol",
            "dependency_impact",
            "conflicting_evidence",
            "failed_verification",
            "unverifiable_acceptance",
        ],
    )
    p_escalate.add_argument(
        "--level", type=int, help="Defaults to the saved package's level"
    )
    p_escalate.add_argument(
        "--step", type=int, help="Defaults to the saved package's escalation step"
    )
    p_escalate.add_argument(
        "--budget", type=int, help="Defaults to the saved package's budget"
    )
    p_escalate.set_defaults(handler="escalate")

    p_checkpoint = sub.add_parser("checkpoint", help="Create a task checkpoint")
    p_checkpoint.add_argument("task_id")
    p_checkpoint.add_argument("--objective")
    p_checkpoint.set_defaults(handler="checkpoint")

    p_compact = sub.add_parser("compact", help="Compact a materialized context package")
    p_compact.add_argument("task_id")
    p_compact.set_defaults(handler="compact")

    p_event = sub.add_parser("event", help="Record a telemetry event")
    p_event.add_argument("event_type")
    p_event.add_argument("--task-id")
    p_event.add_argument("--tokens-used", type=int, default=0)
    p_event.add_argument("--escalations", type=int, default=0)
    p_event.set_defaults(handler="event")

    p_summary = sub.add_parser("telemetry", help="Show telemetry summary")
    p_summary.add_argument("action", choices=["summary"])
    p_summary.set_defaults(handler="telemetry")

    args = parser.parse_args()
    try:
        return run(args)
    except (ValueError, FileNotFoundError) as exc:
        print(f"clae: {exc}", file=sys.stderr)
        return 1


def run(args: argparse.Namespace) -> int:
    gateway = ContextGateway(ROOT)

    if args.handler == "index":
        print(gateway.index())
        return 0
    if args.handler == "package":
        _, materialized, path = gateway.build_package(
            args.task, args.task_id, args.budget
        )
        print(
            json.dumps(
                {
                    "path": str(path),
                    "selected": len(materialized["items"]),
                    "remaining_tokens": materialized["remaining_tokens"],
                },
                indent=2,
            )
        )
        return 0
    if args.handler == "escalate":
        decision, path = gateway.escalate(
            args.task, args.task_id, args.reason, args.level, args.step, args.budget
        )
        print(
            json.dumps(
                {
                    "decision": decision.message,
                    "allowed": decision.allowed,
                    "path": str(path) if path else None,
                },
                indent=2,
            )
        )
        return 0 if decision.allowed else 2
    if args.handler == "checkpoint":
        print(gateway.checkpoint(args.task_id, args.objective))
        return 0
    if args.handler == "compact":
        print(compact_package(ROOT, args.task_id))
        return 0
    if args.handler == "event":
        print(
            event(
                ROOT,
                args.event_type,
                {
                    "task_id": args.task_id,
                    "tokens_used": args.tokens_used,
                    "escalations": args.escalations,
                },
            )
        )
        return 0
    if args.handler == "telemetry":
        print(json.dumps(summary(ROOT), indent=2))
        return 0
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
