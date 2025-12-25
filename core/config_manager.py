# ⌘
#
#  /fileknight/core/config_manager.py
#
#  Created by @jonathaxs on 2025-12-25.
#
# ⌘

from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Any

from core.models import Entry


def expand_user_and_vars(raw_path: str) -> Path:
    """
    Expand ~ and environment vars ($HOME / %USERPROFILE%) cross-platform.
    """
    expanded = os.path.expandvars(raw_path)
    expanded = os.path.expanduser(expanded)
    return Path(expanded)


def load_config(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as f:
        cfg: dict[str, Any] = json.load(f)
    cfg.pop("_meta", None)
    return cfg


def validate_entries(cfg: dict[str, Any]) -> list[Entry]:
    entries_raw = cfg.get("entries", [])
    if not isinstance(entries_raw, list):
        raise ValueError("config.entries must be a list")

    parsed: list[Entry] = []

    for item in entries_raw:
        if not isinstance(item, dict):
            continue

        name = str(item.get("name", "")).strip()
        source_raw = str(item.get("source", "")).strip()
        mode = str(item.get("mode", "mirror")).strip().lower()

        if not name or not source_raw:
            continue
        if mode not in ("mirror", "copy"):
            mode = "mirror"

        parsed.append(Entry(name=name, source=expand_user_and_vars(source_raw), mode=mode))

    if not parsed:
        raise ValueError("No valid entries found in config.json")

    return parsed