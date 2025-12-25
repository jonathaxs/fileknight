# ⌘
#
#  /fileknight/core/config_io.py
#
#  Created by @jonathaxs on 2025-12-25.
#
# ⌘

from __future__ import annotations

import json
import shutil
from datetime import datetime
from pathlib import Path
from typing import Any


DEFAULT_CONFIG: dict[str, Any] = {
    "_meta": {
        "file": "config.json",
        "path": "/fileknight/config.json",
        "created_by": "@jonathaxs",
        "created_at": "auto"
    },
    "language": "auto",
    "dry_run": False,
    "destination_root": "~/Desktop/FileKnight",
    "entries": [
        {
            "name": "Example Entry",
            "source": "~/Desktop/ExampleSource",
            "mode": "mirror"
        }
    ]
}


def write_default_config(config_path: Path) -> None:
    cfg = dict(DEFAULT_CONFIG)
    cfg["_meta"] = dict(cfg["_meta"])
    cfg["_meta"]["created_at"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    config_path.write_text(json.dumps(cfg, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def export_config(config_path: Path, export_dir: Path) -> Path:
    export_dir.mkdir(parents=True, exist_ok=True)
    target = export_dir / f"fileknight_config_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    shutil.copy2(config_path, target)
    return target


def import_config(source_json_path: Path, config_path: Path) -> None:
    if not source_json_path.exists():
        raise FileNotFoundError(f"Import source does not exist: {source_json_path}")
    if source_json_path.suffix.lower() != ".json":
        raise ValueError("Import file must be a .json")

    shutil.copy2(source_json_path, config_path)