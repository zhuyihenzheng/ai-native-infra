@echo off
rem aci.cmd - policy-safe wrapper for tools/aci.ps1 (works from cmd.exe and PowerShell).
rem Usage: ai-infra\tools\aci.cmd <command> [args]
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0aci.ps1" %*
exit /b %ERRORLEVEL%
