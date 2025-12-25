# ⌘
#
#  /fileknight/fileknight.py
#
#  Created by @jonathaxs on 2025-12-23.
#
# ⌘

from __future__ import annotations

import json
import locale
import os
import platform
import shutil
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any


# ---------------------------------------------------------------------------
# Paths and constants

APP_DIR = Path(__file__).resolve().parent
CONFIG_PATH = APP_DIR / "config.json"
TRANSLATIONS_DIR = APP_DIR / "core" / "translations"


# ---------------------------------------------------------------------------
# Language and i18n helpers

def detect_language_code() -> str:
    lang = (locale.getlocale()[0] or "")
    if not lang:
        lang = (
            os.environ.get("LANG", "")
            or os.environ.get("LC_ALL", "")
            or os.environ.get("LC_MESSAGES", "")
        )
    lang = lang.lower()
    return "pt-BR" if lang.startswith("pt") else "en"


def load_locale(language_code: str) -> dict[str, str]:
    def read_json(path: Path) -> dict[str, Any]:
        with path.open("r", encoding="utf-8") as f:
            return json.load(f)

    preferred = TRANSLATIONS_DIR / f"{language_code}.json"
    fallback = TRANSLATIONS_DIR / "en.json"

    data: dict[str, Any]
    data = read_json(preferred) if preferred.exists() else read_json(fallback)

    data.pop("_meta", None)
    return {k: str(v) for k, v in data.items()}


def t(strings: dict[str, str], key: str) -> str:
    return strings.get(key, key)


# ---------------------------------------------------------------------------
# Config and path utilities

def expand_user_and_vars(raw_path: str) -> Path:
    expanded = os.path.expandvars(raw_path)
    expanded = os.path.expanduser(expanded)
    return Path(expanded)


def load_config(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as f:
        cfg: dict[str, Any] = json.load(f)
    cfg.pop("_meta", None)
    return cfg


# ---------------------------------------------------------------------------
# Data model

@dataclass
class Entry:
    name: str
    source: Path
    mode: str  # "mirror" or "copy"


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


# ---------------------------------------------------------------------------
# Copy logic

def compute_destination_paths(entry: Entry, destination_root: Path) -> tuple[Path, Path]:
    """
    Returns:
      - dst_dir: destination_root/<entry.name>
      - dst_item: dst_dir/<source_name>
    """
    dst_dir = destination_root / entry.name
    dst_item = dst_dir / entry.source.name
    return dst_dir, dst_item


def copy_item(entry: Entry, destination_root: Path, dry_run: bool) -> Path:
    """
    Copies file/dir into destination_root/<entry.name>/<source_name>.
    Returns the final destination path used for this entry.
    """
    if not entry.source.exists():
        raise FileNotFoundError(f"Source does not exist: {entry.source}")

    dst_dir, dst_item = compute_destination_paths(entry, destination_root)

    if dry_run:
        # No filesystem changes in dry_run
        return dst_item

    dst_dir.mkdir(parents=True, exist_ok=True)

    if entry.source.is_dir():
        if entry.mode == "mirror" and dst_item.exists():
            shutil.rmtree(dst_item)

        if not dst_item.exists():
            shutil.copytree(entry.source, dst_item)
        else:
            for src_path in entry.source.rglob("*"):
                rel = src_path.relative_to(entry.source)
                target = dst_item / rel
                if src_path.is_dir():
                    target.mkdir(parents=True, exist_ok=True)
                else:
                    target.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(src_path, target)
    else:
        shutil.copy2(entry.source, dst_item)

    return dst_item


# ---------------------------------------------------------------------------
# Main

def main() -> int:
    if not CONFIG_PATH.exists():
        print(f"[ERROR] Missing config file: {CONFIG_PATH}")
        print("Create a config.json next to fileknight.py.")
        return 1

    cfg = load_config(CONFIG_PATH)

    language_setting = str(cfg.get("language", "auto")).strip()
    lang = detect_language_code() if language_setting == "auto" else language_setting
    strings = load_locale(lang)

    dry_run = bool(cfg.get("dry_run", False))

    destination_raw = str(cfg.get("destination_root", "")).strip()
    if not destination_raw:
        print("[ERROR] config.destination_root is missing")
        return 1

    destination_root = expand_user_and_vars(destination_raw)
    if not dry_run:
        destination_root.mkdir(parents=True, exist_ok=True)

    entries = validate_entries(cfg)

    stamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    header = f"{t(strings, 'app_title').strip()}  |  {platform.system()}  |  {stamp}"
    print(header)
    print(f"{t(strings, 'select_destination')}: {destination_root}")
    print(f"dry_run: {dry_run}")
    print("-" * 60)

    ok = 0
    fail = 0

    for e in entries:
        try:
            dst_item = copy_item(e, destination_root, dry_run=dry_run)

            status = "SIMULATED" if dry_run else "COPIED"
            print(f"[OK] {e.name} ({e.mode}) [{status}]")
            print(f"     from: {e.source}")
            print(f"       to: {dst_item}")
            ok += 1
        except Exception as ex:
            print(f"[FAIL] {e.name}: {ex}")
            fail += 1

    print("-" * 60)
    print(f"OK: {ok} | FAIL: {fail}")

    return 0 if fail == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())