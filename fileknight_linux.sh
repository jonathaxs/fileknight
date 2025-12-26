#!/usr/bin/env bash
# ⌘
#
#  /fileknight/fileknight_linux.sh
#
#  Created by @jonathaxs on 2025-12-26.
#
# ⌘
set -e

# FileKnight Linux Launcher
# Runs the GUI entrypoint.

cd "$(dirname "$0")"

if command -v python3 >/dev/null 2>&1; then
  PY=python3
elif command -v python >/dev/null 2>&1; then
  PY=python
else
  echo "[ERROR] Python not found."
  echo "Install Python 3 and try again."
  exit 1
fi

$PY "src/fileknight_app_gui.py"