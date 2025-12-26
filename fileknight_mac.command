#!/usr/bin/env bash
# ⌘
#
#  /fileknight/fileknight_mac.command
#
#  Created by @jonathaxs on 2025-12-26.
#
# ⌘
set -e

# FileKnight macOS Launcher
# Runs the GUI entrypoint.

cd "$(dirname "$0")"

if command -v python3 >/dev/null 2>&1; then
  PY=python3
elif command -v python >/dev/null 2>&1; then
  PY=python
else
  echo "[ERROR] Python not found."
  echo "Install Python (recommended: python.org) and try again."
  read -r -p "Press Enter to exit..."
  exit 1
fi

$PY "src/fileknight_app_gui.py"