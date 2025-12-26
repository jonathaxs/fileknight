# ⌘
#
#  /fileknight/core/i18n.py
#
#  Created by @jonathaxs on 2025-12-25.
#
# ⌘

from __future__ import annotations

import json
import locale
import os
from pathlib import Path
from typing import Any


def project_root() -> Path:
    # .../src/core/i18n.py -> parents[2] == .../fileknight
    return Path(__file__).resolve().parents[2]


def translations_dir() -> Path:
    return project_root() / "src" / "translations"


def detect_language_code() -> str:
    """
    Return 'pt-BR' if OS language starts with Portuguese, otherwise 'en'.
    """
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
    """
    Load translations JSON from core/translations.
    Falls back to en.json.
    """
    def read_json(path: Path) -> dict[str, Any]:
        with path.open("r", encoding="utf-8") as f:
            return json.load(f)

    preferred = translations_dir() / f"{language_code}.json"
    fallback = translations_dir() / "en.json"

    data: dict[str, Any]
    data = read_json(preferred) if preferred.exists() else read_json(fallback)

    data.pop("_meta", None)
    return {k: str(v) for k, v in data.items()}


def t(strings: dict[str, str], key: str) -> str:
    return strings.get(key, key)