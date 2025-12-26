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

def load_config_raw(path: Path) -> dict[str, Any]:
    """
    Load config.json keeping _meta (useful for GUI and saving without losing metadata).
    """
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def save_config(path: Path, cfg: dict[str, Any]) -> None:
    """
    Save config.json preserving existing _meta when possible.
    """
    meta: dict[str, Any] | None = None

    # Try to preserve meta from existing file
    if path.exists():
        try:
            existing = load_config_raw(path)
            meta = existing.get("_meta")
        except Exception:
            meta = None

    # If caller provided _meta, it wins
    if "_meta" in cfg and isinstance(cfg["_meta"], dict):
        meta = cfg["_meta"]

    to_write = dict(cfg)
    if meta is not None:
        to_write["_meta"] = meta

    path.write_text(
        json.dumps(to_write, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8"
    )


def set_destination_root(cfg: dict[str, Any], destination_root: str) -> None:
    cfg["destination_root"] = destination_root


def set_language(cfg: dict[str, Any], language: str) -> None:
    cfg["language"] = language


def set_dry_run(cfg: dict[str, Any], dry_run: bool) -> None:
    cfg["dry_run"] = bool(dry_run)


def add_or_update_entry(cfg: dict[str, Any], name: str, source: str, mode: str) -> None:
    entries = cfg.get("entries", [])
    if not isinstance(entries, list):
        entries = []
        cfg["entries"] = entries

    name = str(name).strip()
    source = str(source).strip()
    mode = str(mode).strip().lower()
    if mode not in ("mirror", "copy"):
        mode = "mirror"

    for e in entries:
        if isinstance(e, dict) and str(e.get("name", "")).strip() == name:
            e["source"] = source
            e["mode"] = mode
            return

    entries.append({"name": name, "source": source, "mode": mode})


def remove_entry(cfg: dict[str, Any], name: str) -> bool:
    entries = cfg.get("entries", [])
    if not isinstance(entries, list):
        return False

    name = str(name).strip()
    before = len(entries)
    cfg["entries"] = [e for e in entries if not (isinstance(e, dict) and str(e.get("name", "")).strip() == name)]
    return len(cfg["entries"]) != before