@echo off
rem promote.cmd - policy-safe wrapper for activate/promote.ps1.
rem Usage: ai-infra\activate\promote.cmd [target-project-root]
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0promote.ps1" %*
exit /b %ERRORLEVEL%
