# ⌘
#
#  /fileknight/core/cli.py
#
#  Created by @jonathaxs on 2025-12-25.
#
# ⌘

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path


@dataclass
class CliOptions:
    dry_run_override: bool | None
    export_dir: Path | None
    import_path: Path | None


def parse_args(argv: list[str]) -> CliOptions:
    parser = argparse.ArgumentParser(prog="fileknight", add_help=True)

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Simulate actions without copying (overrides config.dry_run = true).",
    )
    parser.add_argument(
        "--run",
        action="store_true",
        help="Force real copy (overrides config.dry_run = false).",
    )
    parser.add_argument(
        "--export-config",
        nargs="?",
        const="~/Downloads",
        help="Export config.json to a folder (default: ~/Downloads).",
    )
    parser.add_argument(
        "--import-config",
        help="Import a .json file and replace current config.json.",
    )

    args = parser.parse_args(argv)

    dry_override: bool | None = None
    if args.dry_run and args.run:
        parser.error("Use only one: --dry-run OR --run")

    if args.dry_run:
        dry_override = True
    elif args.run:
        dry_override = False

    export_dir = Path(args.export_config).expanduser() if args.export_config else None
    import_path = Path(args.import_config).expanduser() if args.import_config else None

    return CliOptions(
        dry_run_override=dry_override,
        export_dir=export_dir,
        import_path=import_path,
    )