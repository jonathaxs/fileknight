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

# Absolute path to the directory where this script is located
APP_DIR = Path(__file__).resolve().parent

# config.json must live next to fileknight.py
CONFIG_PATH = APP_DIR / "config.json"

# Folder that contains i18n JSON files
LOCALES_DIR = APP_DIR / "core" / "locales"


# ---------------------------------------------------------------------------
# Language and i18n helpers

def detect_language_code() -> str:
    """
    Detect the OS language.

    If the system language starts with 'pt', return 'pt-BR'.
    Otherwise, fallback to 'en'.
    """
    # locale.getlocale() may return something like ('pt_BR', 'UTF-8')
    lang = (locale.getlocale()[0] or "")

    # Extra fallback using environment variables (Linux/macOS safe)
    if not lang:
        lang = (
            os.environ.get("LANG", "")
            or os.environ.get("LC_ALL", "")
            or os.environ.get("LC_MESSAGES", "")
        )

    lang = lang.lower()
    return "pt-BR" if lang.startswith("pt") else "en"


def load_locale(language_code: str) -> dict[str, str]:
    """
    Load a locale file from /locales.

    Tries to load <language_code>.json first.
    Falls back to en.json if not found.
    """
    def read_json(path: Path) -> dict[str, Any]:
        with path.open("r", encoding="utf-8") as f:
            return json.load(f)

    preferred = LOCALES_DIR / f"{language_code}.json"
    fallback = LOCALES_DIR / "en.json"

    data: dict[str, Any]
    data = read_json(preferred) if preferred.exists() else read_json(fallback)

    # Remove metadata if present
    data.pop("_meta", None)

    # Ensure everything is string -> string
    return {k: str(v) for k, v in data.items()}


def t(strings: dict[str, str], key: str) -> str:
    """
    Translation helper.

    If a key is missing, return the key itself.
    """
    return strings.get(key, key)


# ---------------------------------------------------------------------------
# Config and path utilities

def expand_user_and_vars(raw_path: str) -> Path:
    """
    Expand user (~) and environment variables ($HOME, %USERPROFILE%).

    Works across Windows, Linux and macOS.
    """
    expanded = os.path.expandvars(raw_path)
    expanded = os.path.expanduser(expanded)
    return Path(expanded)


def load_config(path: Path) -> dict[str, Any]:
    """
    Load config.json and strip internal metadata.
    """
    with path.open("r", encoding="utf-8") as f:
        cfg: dict[str, Any] = json.load(f)

    cfg.pop("_meta", None)
    return cfg


# ---------------------------------------------------------------------------
# Data model

@dataclass
class Entry:
    """
    Represents one backup entry defined in config.json.
    """
    name: str
    source: Path
    mode: str  # "mirror" or "copy"


def validate_entries(cfg: dict[str, Any]) -> list[Entry]:
    """
    Parse and validate entries from config.json.

    Returns a list of valid Entry objects.
    """
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

        parsed.append(
            Entry(
                name=name,
                source=expand_user_and_vars(source_raw),
                mode=mode
            )
        )

    if not parsed:
        raise ValueError("No valid entries found in config.json")

    return parsed


# ---------------------------------------------------------------------------
# Copy logic

def copy_item(entry: Entry, destination_root: Path) -> None:
    """
    Copy a file or directory defined by an Entry.

    Destination structure:
      destination_root/<entry.name>/<source_name>

    Modes:
    - mirror: delete previous copy and copy again
    - copy: merge files into existing destination
    """
    if not entry.source.exists():
        raise FileNotFoundError(f"Source does not exist: {entry.source}")

    # Folder for this entry
    dst_dir = destination_root / entry.name
    dst_dir.mkdir(parents=True, exist_ok=True)

    # Directory source
    if entry.source.is_dir():
        dst_item = dst_dir / entry.source.name

        # Mirror mode: remove existing destination first
        if entry.mode == "mirror" and dst_item.exists():
            shutil.rmtree(dst_item)

        # Fresh copy
        if not dst_item.exists():
            shutil.copytree(entry.source, dst_item)
        else:
            # Copy mode: merge files recursively
            for src_path in entry.source.rglob("*"):
                rel = src_path.relative_to(entry.source)
                target = dst_item / rel

                if src_path.is_dir():
                    target.mkdir(parents=True, exist_ok=True)
                else:
                    target.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(src_path, target)

    # File source
    else:
        dst_file = dst_dir / entry.source.name
        shutil.copy2(entry.source, dst_file)


# ---------------------------------------------------------------------------
# Main application flow
# ---------------------------------------------------------------------------

def main() -> int:
    """
    Entry point of FileKnight.
    """
    if not CONFIG_PATH.exists():
        print(f"[ERROR] Missing config file: {CONFIG_PATH}")
        print("Create a config.json next to fileknight.py.")
        return 1

    cfg = load_config(CONFIG_PATH)

    # Language resolution
    language_setting = str(cfg.get("language", "auto")).strip()
    lang = detect_language_code() if language_setting == "auto" else language_setting
    strings = load_locale(lang)

    # Destination root
    destination_raw = str(cfg.get("destination_root", "")).strip()
    if not destination_raw:
        print("[ERROR] config.destination_root is missing")
        return 1

    destination_root = expand_user_and_vars(destination_raw)
    destination_root.mkdir(parents=True, exist_ok=True)

    # Parse entries
    entries = validate_entries(cfg)

    # Header
    stamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"{t(strings, 'app_title')}  |  {platform.system()}  |  {stamp}")
    print(f"{t(strings, 'select_destination')}: {destination_root}")
    print("-" * 60)

    ok = 0
    fail = 0

    # Process entries
    for e in entries:
        try:
            copy_item(e, destination_root)
            print(f"[OK] {e.name} ({e.mode})")
            ok += 1
        except Exception as ex:
            print(f"[FAIL] {e.name}: {ex}")
            fail += 1

    # Footer
    print("-" * 60)
    print(f"OK: {ok} | FAIL: {fail}")

    return 0 if fail == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())