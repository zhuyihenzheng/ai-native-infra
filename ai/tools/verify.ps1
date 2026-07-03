# verify.ps1 - one-command verify entry (Windows, PowerShell 5.1 compatible).
# Command source of truth: verify.conf (WIN= line). Prefer running via ai\tools\verify.cmd,
# which embeds -ExecutionPolicy Bypass so corporate execution policy does not block it.
$ErrorActionPreference = 'Stop'

$conf = Join-Path $PSScriptRoot 'verify.conf'
if (-not (Test-Path $conf)) { Write-Host "x missing $conf"; exit 2 }

$line = Get-Content $conf | Where-Object { $_ -match '^WIN=' } | Select-Object -First 1
$cmd = if ($line) { $line.Substring(4).Trim() } else { '' }
if (-not $cmd) {
  Write-Host "x Not aligned: WIN= in verify.conf is empty. Run /onboard first (step 5 records this project's build/test command)."
  exit 2
}

$tailLines = 60
if ($env:VERIFY_TAIL) { $tailLines = [int]$env:VERIFY_TAIL }

Write-Host "==> $cmd"
$log = Join-Path $env:TEMP ("verify-" + [guid]::NewGuid().ToString('N') + ".log")
cmd.exe /c $cmd > $log 2>&1
$rc = $LASTEXITCODE

Get-Content $log -Tail $tailLines
if ($rc -eq 0) {
  Write-Host "OK verify PASSED"
  # Stop hook (stop-verify-gate.sh) checks this marker to know the latest edits were verified
  New-Item -ItemType File -Force (Join-Path $PSScriptRoot '.last-verify-pass') | Out-Null
  Remove-Item $log -Force
  exit 0
} else {
  Write-Host "x verify FAILED (exit $rc) - full log: $log"
  exit $rc
}
