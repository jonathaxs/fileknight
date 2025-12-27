# ⌘
#
#  /fileknight/fileknight_run.py
#
#  Created by @jonathaxs on 2025-12-23.
#
# ⌘

from __future__ import annotations

import sys
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent
SRC_DIR = ROOT_DIR / "src"
sys.path.insert(0, str(SRC_DIR))

CONFIG_PATH = ROOT_DIR / "config.json"

import platform
from datetime import datetime

from core.cli import parse_args
from core.config_io import export_config, import_config, write_default_config
from core.config_manager import load_config, expand_user_and_vars, validate_entries
from core.copier import copy_item
from core.i18n import detect_language_code, load_locale, t


def main(argv: list[str]) -> int:
    options = parse_args(argv)

    # If config doesn't exist, create a default one and exit (friendly first-run behavior)
    if not CONFIG_PATH.exists():
        write_default_config(CONFIG_PATH)
        print(f"[INFO] config.json was created at: {CONFIG_PATH}")
        print("[INFO] Edit it with your paths and run FileKnight again.")
        return 0

    # Import config (replace current)
    if options.import_path is not None:
        import_config(options.import_path, CONFIG_PATH)
        print(f"[OK] Config imported: {options.import_path} -> {CONFIG_PATH}")
        return 0

    # Export config (copy to directory)
    if options.export_dir is not None:
        exported = export_config(CONFIG_PATH, options.export_dir)
        print(f"[OK] Config exported to: {exported}")
        return 0

    cfg = load_config(CONFIG_PATH)

    language_setting = str(cfg.get("language", "auto")).strip()
    lang = detect_language_code() if language_setting == "auto" else language_setting
    strings = load_locale(lang)

    # config.dry_run can be overridden by CLI flags
    dry_run_cfg = bool(cfg.get("dry_run", False))
    dry_run = dry_run_cfg if options.dry_run_override is None else options.dry_run_override

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
    raise SystemExit(main(sys.argv[1:]))