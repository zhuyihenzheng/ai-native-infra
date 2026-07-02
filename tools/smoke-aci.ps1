# smoke-aci.ps1 — throwaway deployed-mode checks for the PowerShell ACI layer.
# Run with: pwsh -NoProfile -File tools/smoke-aci.ps1   (or powershell.exe on Windows)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InfraDir  = (Resolve-Path (Join-Path $ScriptDir '..')).Path
$TmpDir    = Join-Path ([IO.Path]::GetTempPath()) ("ai-infra-aci-smoke-" + [Guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Path $TmpDir | Out-Null

if ($PSVersionTable.PSEdition -eq 'Core') {
  $Engine = Join-Path $PSHOME 'pwsh'
  if (Test-Path ($Engine + '.exe')) { $Engine = $Engine + '.exe' }
} else {
  $Engine = Join-Path $PSHOME 'powershell.exe'
}

function Fail([string]$m) {
  [Console]::Error.WriteLine("FAIL $m")
  Remove-Item -LiteralPath $TmpDir -Recurse -Force -ErrorAction SilentlyContinue
  exit 1
}

function Check-Contains([string]$Text, [string]$Needle, [string]$Label) {
  if (-not $Text.Contains($Needle)) { Fail "${Label}: expected [$Needle]" }
}

function Check-NotContains([string]$Text, [string]$Needle, [string]$Label) {
  if ($Text.Contains($Needle)) { Fail "${Label}: unexpected [$Needle]" }
}

function Run-Aci([string]$Project, [string]$InfraName, [string[]]$AciArgs) {
  $aci = Join-Path (Join-Path (Join-Path $Project $InfraName) 'tools') 'aci.ps1'
  $out = @(& $Engine -NoProfile -ExecutionPolicy Bypass -File $aci @AciArgs 2>&1 | ForEach-Object { "$_" })
  $script:LastCode = $LASTEXITCODE
  return ($out -join "`n")
}

function Prepare-Project([string]$Project, [string]$InfraName) {
  New-Item -ItemType Directory -Path (Join-Path $Project 'src/main/java/demo') -Force | Out-Null
  Push-Location $Project
  try {
    & git init -q 2>&1 | Out-Null
    Set-Content -Path (Join-Path $Project 'pom.xml') -Value '<project></project>' -Encoding UTF8
    Set-Content -Path (Join-Path $Project 'src/main/java/demo/Demo.java') -Value 'class Demo { CommonResult ok(){ return null; } }' -Encoding UTF8
    Copy-Item -LiteralPath $InfraDir -Destination (Join-Path $Project $InfraName) -Recurse
    Remove-Item -LiteralPath (Join-Path (Join-Path $Project $InfraName) '.git') -Recurse -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path (Join-Path $Project $InfraName) -Filter '_backup-*' -Directory -ErrorAction SilentlyContinue |
      ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force }
    Set-Content -Path (Join-Path (Join-Path $Project $InfraName) 'INFRA-MARKER.txt') -Value 'CommonResult in infra doc' -Encoding UTF8
    Remove-Item -LiteralPath (Join-Path (Join-Path $Project $InfraName) 'project/verify.sh') -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath (Join-Path (Join-Path $Project $InfraName) 'project/verify.ps1') -Force -ErrorAction SilentlyContinue
  } finally { Pop-Location }
}

function Mark-Aligned([string]$Project, [string]$InfraName) {
  $status = Join-Path (Join-Path $Project $InfraName) 'project/ALIGN-STATUS.md'
  $t = Get-Content -LiteralPath $status -Raw -Encoding UTF8
  $t = $t -replace 'ALIGN_STATE:\s*[A-Za-z-]+', 'ALIGN_STATE: aligned'
  [IO.File]::WriteAllText($status, $t, (New-Object System.Text.UTF8Encoding($false)))
  Set-Content -Path (Join-Path (Join-Path $Project $InfraName) 'project/aligned-rules.md') -Value "# Aligned Rules - smoke`n`n- Smoke rule [confirmed]" -Encoding UTF8
}

function Check-AciScope([string]$Project, [string]$InfraName) {
  $state = Run-Aci $Project $InfraName @('state')
  Check-Contains $state "project: $Project" "$InfraName state project root"
  Check-Contains $state "exclude $InfraName/ by default" "$InfraName state search exclusion"

  $projectGrep = Run-Aci $Project $InfraName @('grep', 'CommonResult')
  Check-Contains $projectGrep 'src/main/java/demo/Demo.java' "$InfraName project grep"
  Check-NotContains $projectGrep 'INFRA-MARKER' "$InfraName project grep excludes infra"

  $infraGrep = Run-Aci $Project $InfraName @('grep', 'CommonResult', $InfraName)
  Check-Contains $infraGrep "$InfraName/INFRA-MARKER.txt" "$InfraName explicit infra grep"

  $projectFind = Run-Aci $Project $InfraName @('find', 'INFRA-MARKER')
  Check-NotContains $projectFind 'INFRA-MARKER.txt' "$InfraName project find excludes infra"

  $infraFind = Run-Aci $Project $InfraName @('find', 'INFRA-MARKER', $InfraName)
  Check-Contains $infraFind "$InfraName/INFRA-MARKER.txt" "$InfraName explicit infra find"
}

function Check-Verify([string]$Project, [string]$InfraName) {
  $verifyPs1 = Join-Path (Join-Path $Project $InfraName) 'project/verify.ps1'

  $out = Run-Aci $Project $InfraName @('verify')
  if ($script:LastCode -eq 0) { Fail "$InfraName verify: expected failure without project verify script" }
  Check-Contains $out 'verify.ps1' "$InfraName verify missing-script message"

  Set-Content -Path $verifyPs1 -Value 'Write-Output "smoke-build-ok"' -Encoding UTF8
  $out = Run-Aci $Project $InfraName @('verify')
  if ($script:LastCode -ne 0) { Fail "$InfraName verify: expected success, got exit $($script:LastCode)" }
  Check-Contains $out 'smoke-build-ok' "$InfraName verify passthrough output"
  Check-Contains $out 'verify passed' "$InfraName verify success marker"

  Set-Content -Path $verifyPs1 -Value "Write-Output 'boom'`nexit 3" -Encoding UTF8
  $out = Run-Aci $Project $InfraName @('verify')
  if ($script:LastCode -ne 3) { Fail "$InfraName verify: expected exit 3, got $($script:LastCode)" }
  Check-Contains $out 'boom' "$InfraName verify failure output"
  Check-Contains $out 'verify failed (exit 3)' "$InfraName verify failure marker"
  Remove-Item -LiteralPath $verifyPs1 -Force

  # bash fallback for verify.sh (only where bash exists, e.g. Git Bash / macOS)
  if ($null -ne (Get-Command bash -ErrorAction SilentlyContinue)) {
    $verifySh = Join-Path (Join-Path $Project $InfraName) 'project/verify.sh'
    Set-Content -Path $verifySh -Value "#!/usr/bin/env bash`necho smoke-sh-fallback-ok" -Encoding UTF8
    $out = Run-Aci $Project $InfraName @('verify')
    if ($script:LastCode -ne 0) { Fail "$InfraName verify sh-fallback: expected success" }
    Check-Contains $out 'smoke-sh-fallback-ok' "$InfraName verify sh-fallback output"
    Remove-Item -LiteralPath $verifySh -Force
  }
}

function Check-PromotePaths([string]$Project, [string]$InfraName) {
  Mark-Aligned $Project $InfraName
  $promote = Join-Path (Join-Path (Join-Path $Project $InfraName) 'activate') 'promote.ps1'
  $out = @(& $Engine -NoProfile -ExecutionPolicy Bypass -File $promote 2>&1 | ForEach-Object { "$_" }) -join "`n"
  if ($LASTEXITCODE -ne 0) { Fail "$InfraName promote.ps1 failed: $out" }

  foreach ($f in @('CLAUDE.md', 'AGENTS.md', '.github/prompts/aci-task-loop.prompt.md')) {
    $t = Get-Content -LiteralPath (Join-Path $Project $f) -Raw -Encoding UTF8
    Check-Contains $t "$InfraName/tools/aci.ps1" "$InfraName promote output $f uses aci.ps1"
    Check-NotContains $t '{{ACI}}' "$InfraName promote output $f has no {{ACI}} leftover"
    Check-NotContains $t '{{INFRA_DIR}}' "$InfraName promote output $f has no {{INFRA_DIR}} leftover"
  }
  if ($InfraName -ne 'ai-infra') {
    $t = Get-Content -LiteralPath (Join-Path $Project 'CLAUDE.md') -Raw -Encoding UTF8
    Check-NotContains $t 'ai-infra/tools/' "$InfraName promote output CLAUDE.md has no hardcoded ai-infra path"
  }
  if (-not (Test-Path -LiteralPath (Join-Path $Project '.vscode/settings.json'))) {
    Fail "$InfraName promote.ps1 did not write .vscode/settings.json"
  }
}

function Run-Case([string]$InfraName) {
  $project = Join-Path $TmpDir "project-$InfraName"
  New-Item -ItemType Directory -Path $project | Out-Null
  $project = (Resolve-Path $project).Path
  Prepare-Project $project $InfraName
  Check-AciScope $project $InfraName
  Check-Verify $project $InfraName
  Check-PromotePaths $project $InfraName
  Write-Output "OK deployed PS-ACI smoke passed for $InfraName"
}

try {
  Run-Case 'ai-infra'
  Run-Case 'infra2'
  Write-Output '== PS ACI smoke: passed =='
} finally {
  Remove-Item -LiteralPath $TmpDir -Recurse -Force -ErrorAction SilentlyContinue
}
