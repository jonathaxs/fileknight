# ⌘
#
#  /fileknight/fileknight.py
#
#  Created by @jonathaxs on 2025-12-23.
#
# ⌘

from __future__ import annotations

import platform
from datetime import datetime
from pathlib import Path

from core.config_manager import load_config, expand_user_and_vars, validate_entries
from core.copier import copy_item
from core.i18n import detect_language_code, load_locale, t


APP_DIR = Path(__file__).resolve().parent
CONFIG_PATH = APP_DIR / "config.json"


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