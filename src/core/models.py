# ⌘
#
#  /fileknight/core/models.py
#
#  Created by @jonathaxs on 2025-12-25.
#
# ⌘

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass
class Entry:
    name: str
    source: Path
    mode: str  # "mirror" or "copy"