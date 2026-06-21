@echo off
REM This launcher works no matter where it's run from:
REM   - Double-click in Explorer
REM   - Command Prompt (cmd.exe)
REM   - PowerShell
REM It relaunches the countdown into PowerShell automatically.

set SCRIPT_DIR=%~dp0
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%countdown_color.ps1"
pause