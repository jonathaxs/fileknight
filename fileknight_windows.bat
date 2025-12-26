@echo off
REM ⌘
REM
REM  /fileknight/fileknight_windows.bat
REM
REM  Created by @jonathaxs on 2025-12-26.
REM
REM ⌘

setlocal

REM FileKnight Windows Launcher
REM Runs the GUI entrypoint.

cd /d "%~dp0"

where python >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Python not found.
  echo Install Python from https://www.python.org/downloads/ and try again.
  echo.
  pause
  exit /b 1
)

python "src\fileknight_app_gui.py"

if errorlevel 1 (
  echo.
  echo [ERROR] FileKnight failed to start.
  echo If you see "No module named _tkinter", reinstall Python with Tkinter support.
  echo.
  pause
)

endlocal