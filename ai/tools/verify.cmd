@echo off
rem verify.cmd - Windows entry: cmd.exe / PowerShell 双方から直接実行可。
rem -ExecutionPolicy Bypass 内蔵（「デジタル署名されていません」対策）。
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0verify.ps1" %*
exit /b %ERRORLEVEL%
