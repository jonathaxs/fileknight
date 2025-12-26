# ⌘
#
#  /fileknight/core/copier.py
#
#  Created by @jonathaxs on 2025-12-25.
#
# ⌘

from __future__ import annotations

import shutil
from pathlib import Path

from core.models import Entry


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
    Copy file/dir into destination_root/<entry.name>/<source_name>.
    Returns the final destination path used for this entry.
    """
    if not entry.source.exists():
        raise FileNotFoundError(f"Source does not exist: {entry.source}")

    dst_dir, dst_item = compute_destination_paths(entry, destination_root)

    if dry_run:
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