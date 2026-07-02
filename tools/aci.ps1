# aci.ps1 — Windows counterpart of aci.sh (domain gates + fallback observation).
#
# Primary value: deterministic domain gates the agent harness cannot provide
# natively — alignment state, one-command project verification, doc governance,
# traceability search, evidence checks. find/grep/view are bounded fallbacks
# for shell-only contexts. Compatible with Windows PowerShell 5.1 and pwsh 7+.
#
# Usage:  powershell -NoProfile -ExecutionPolicy Bypass -File tools/aci.ps1 <command> [args]

[CmdletBinding()]
param(
  [Parameter(Position = 0)][string]$Command = 'help',
  [Parameter(Position = 1, ValueFromRemainingArguments = $true)][string[]]$Rest
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
if ($null -eq $Rest) { $Rest = @() }

# ---- path resolution ----
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InfraDir  = (Resolve-Path (Join-Path $ScriptDir '..')).Path
$InfraRel  = Split-Path -Leaf $InfraDir

if ($env:ACI_PROJECT_ROOT) {
  $ProjectRoot = (Resolve-Path $env:ACI_PROJECT_ROOT).Path
} elseif ($InfraRel -eq 'ai-native-infra') {
  # Template-development mode: keep commands scoped to this repository.
  $ProjectRoot = $InfraDir
} else {
  # Deployed mode: any renamed infra directory lives under the target project.
  $ProjectRoot = (Resolve-Path (Join-Path $InfraDir '..')).Path
}

$Sep = [IO.Path]::DirectorySeparatorChar
if (($ProjectRoot -ne $InfraDir) -and $InfraDir.StartsWith($ProjectRoot + $Sep)) {
  $InfraProjectRel = $InfraDir.Substring($ProjectRoot.Length + 1) -replace '\\', '/'
} else {
  $InfraProjectRel = ''
}

$MaxViewLines  = 100
$MaxSearchHits = 50
$VerifyTail    = 60
if ($env:ACI_VIEW_LINES)  { $MaxViewLines  = [int]$env:ACI_VIEW_LINES }
if ($env:ACI_SEARCH_HITS) { $MaxSearchHits = [int]$env:ACI_SEARCH_HITS }
if ($env:ACI_VERIFY_TAIL) { $VerifyTail    = [int]$env:ACI_VERIFY_TAIL }

# ---- helpers ----
function Die([string]$Msg) {
  [Console]::Error.WriteLine("x $Msg")
  exit 1
}

function Get-PsEngine {
  if ($PSVersionTable.PSEdition -eq 'Core') {
    $exe = Join-Path $PSHOME 'pwsh'
    if (Test-Path ($exe + '.exe')) { $exe = $exe + '.exe' }
  } else {
    $exe = Join-Path $PSHOME 'powershell.exe'
  }
  return $exe
}

function Has-Cmd([string]$Name) {
  return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function To-Slash([string]$p) { return ($p -replace '\\', '/') }

function RelPath([string]$Path) {
  $p = $Path
  if ($p.StartsWith($ProjectRoot + $Sep)) { return To-Slash $p.Substring($ProjectRoot.Length + 1) }
  if ($p -eq $ProjectRoot) { return '.' }
  if ($p.StartsWith($InfraDir + $Sep)) { return To-Slash ($InfraRel + '/' + $p.Substring($InfraDir.Length + 1)) }
  return To-Slash $p
}

function Resolve-ExistingPath([string]$InputPath, [bool]$AllowDir) {
  $candidates = @($InputPath, (Join-Path $ProjectRoot $InputPath), (Join-Path $InfraDir $InputPath))
  foreach ($c in $candidates) {
    if ((Test-Path -LiteralPath $c -PathType Leaf) -or ($AllowDir -and (Test-Path -LiteralPath $c))) {
      $abs = (Resolve-Path -LiteralPath $c).Path
      if (($abs -eq $ProjectRoot) -or ($abs -eq $InfraDir) -or
          $abs.StartsWith($ProjectRoot + $Sep) -or $abs.StartsWith($InfraDir + $Sep)) {
        return $abs
      }
      Die "refusing to access outside project/infra root: $InputPath"
    }
  }
  if ($AllowDir) { Die "scope not found: $InputPath" } else { Die "file not found: $InputPath" }
}

function Write-Bounded([string[]]$Lines, [int]$Limit) {
  if ($null -eq $Lines -or $Lines.Count -eq 0) {
    Write-Output 'OK command ran successfully and produced no output'
    return
  }
  if ($Lines.Count -gt $Limit) {
    $Lines[0..($Limit - 1)] | Write-Output
    Write-Output ("! output truncated at {0}/{1} lines; refine the query." -f $Limit, $Lines.Count)
  } else {
    $Lines | Write-Output
  }
}

function Get-AlignState {
  $status = Join-Path $InfraDir 'project/ALIGN-STATUS.md'
  if (-not (Test-Path -LiteralPath $status)) { return 'missing' }
  $m = Select-String -LiteralPath $status -Pattern 'ALIGN_STATE:\s*([A-Za-z-]+)' | Select-Object -First 1
  if ($null -eq $m) { return '' }
  return $m.Matches[0].Groups[1].Value
}

$BinaryExt = @('.png','.jpg','.jpeg','.gif','.ico','.jar','.class','.zip','.gz','.tar','.pdf','.exe','.dll','.so','.dylib','.woff','.woff2','.ttf')

function Get-SearchFiles([string]$Scope, [bool]$ExcludeInfra) {
  $files = Get-ChildItem -LiteralPath $Scope -Recurse -File -Force -ErrorAction SilentlyContinue
  foreach ($f in $files) {
    $rel = To-Slash $f.FullName
    if ($rel -match '(^|/)(\.git|target|node_modules)(/|$)') { continue }
    if ($ExcludeInfra -and $InfraProjectRel -ne '') {
      $projRel = RelPath $f.FullName
      if ($projRel -eq $InfraProjectRel -or $projRel.StartsWith($InfraProjectRel + '/')) { continue }
    }
    $f
  }
}

# ---- commands ----
function Show-Usage {
@'
Usage: tools/aci.ps1 <command> [args]
       (invoke: powershell -NoProfile -ExecutionPolicy Bypass -File tools/aci.ps1 ...)

Domain gates (things your agent harness cannot know natively — use these):
  help                         Show this help.
  state                        Summarize project root, alignment state, live files, git status.
  verify                       Run this project's aligned build/test entry (project/verify.ps1
                               or, via bash, project/verify.sh), bounded output.
  validate                     Run tools/validate-ai-docs.ps1.
  promote-check                Report activation gates without writing live files.
  trace <ID>                   Search traceability ID occurrences (change blast radius).
  evidence <path:line>         Check that an evidence citation resolves to a file line.
  diff                         Summarize git status and changed files.

Fallback observation (prefer your agent's native search/read tools when it has them):
  find <name-fragment> [path]  Bounded filename search under project root or path.
  grep <pattern> [path]        Bounded text search (regex) under project root or path.
  view <path> [start] [count]  Line-numbered bounded file view; default count=100.

Environment:
  ACI_PROJECT_ROOT             Override target project root.
  ACI_VIEW_LINES               Max lines for view (default 100).
  ACI_SEARCH_HITS              Max results for find/grep/trace (default 50).
  ACI_VERIFY_TAIL              Max trailing lines shown from verify output (default 60).
'@ | Write-Output
}

function Cmd-State {
  Write-Output '== ACI state =='
  Write-Output "infra:   $InfraDir"
  Write-Output "project: $ProjectRoot"
  Write-Output "align:   $(Get-AlignState)"
  if ($InfraProjectRel -ne '') {
    Write-Output "search:  project-wide find/grep/trace exclude $InfraProjectRel/ by default"
  }
  Write-Output ''
  Write-Output '== live entry files =='
  foreach ($f in @('CLAUDE.md', 'AGENTS.md', '.github/copilot-instructions.md', '.vscode/settings.json')) {
    if (Test-Path -LiteralPath (Join-Path $ProjectRoot $f)) { Write-Output "OK $f" } else { Write-Output "-  $f" }
  }
  Write-Output ''
  Write-Output '== git status =='
  & git -C $ProjectRoot rev-parse --is-inside-work-tree 2>$null | Out-Null
  if ($LASTEXITCODE -eq 0) {
    $out = @(& git -C $ProjectRoot status --short 2>&1 | ForEach-Object { "$_" })
    Write-Bounded $out 40
  } else {
    Write-Output 'not a git worktree'
  }
}

function Cmd-PromoteCheck {
  Write-Output '== promote gates =='
  $state = Get-AlignState
  if ($state -eq 'aligned') { Write-Output 'OK ALIGN_STATE aligned' } else { Write-Output "x ALIGN_STATE is $state" }

  $rules = Join-Path $InfraDir 'project/aligned-rules.md'
  if (Test-Path -LiteralPath $rules) {
    Write-Output 'OK project/aligned-rules.md exists'
    $text = Get-Content -LiteralPath $rules -Raw -Encoding UTF8
    if ($text -match '\{\{') { Write-Output 'x aligned-rules.md still contains {{ placeholders }}' }
    else { Write-Output 'OK aligned-rules.md has no {{ placeholders }}' }
    if ($text -match '(?i)PLACEHOLDER') { Write-Output 'x aligned-rules.md still contains PLACEHOLDER' }
    else { Write-Output 'OK aligned-rules.md is not placeholder text' }
  } else {
    Write-Output 'x missing project/aligned-rules.md'
  }

  $isProject = $false
  foreach ($b in @('pom.xml', 'build.gradle', 'build.gradle.kts')) {
    if (Test-Path -LiteralPath (Join-Path $ProjectRoot $b)) { $isProject = $true }
  }
  if ($isProject -or ($ProjectRoot -eq $InfraDir)) { Write-Output 'OK target root shape accepted' }
  else { Write-Output 'x target root lacks pom.xml / build.gradle(.kts)' }
}

function Cmd-Find([string]$Query, [string]$Scope) {
  if (-not $Query) { Die 'find requires a filename fragment' }
  if (-not $Scope) { $Scope = $ProjectRoot }
  $scopeAbs = Resolve-ExistingPath $Scope $true
  $excludeInfra = ($scopeAbs -eq $ProjectRoot)
  $hits = @()
  foreach ($f in (Get-SearchFiles $scopeAbs $excludeInfra)) {
    $rel = RelPath $f.FullName
    if ($rel -match [regex]::Escape($Query)) { $hits += $rel }
    elseif ($rel.ToLower().Contains($Query.ToLower())) { $hits += $rel }
    if ($hits.Count -gt ($MaxSearchHits * 3)) { break }
  }
  Write-Bounded @($hits | Select-Object -Unique) $MaxSearchHits
}

function Cmd-Grep([string]$Pattern, [string]$Scope) {
  if (-not $Pattern) { Die 'grep requires a pattern' }
  if (-not $Scope) { $Scope = $ProjectRoot }
  $scopeAbs = Resolve-ExistingPath $Scope $true
  $excludeInfra = ($scopeAbs -eq $ProjectRoot)

  if (Has-Cmd 'rg') {
    # rg 的 --glob 排除按相对路径匹配，所以统一 cd 到根后用相对 scope 搜索
    $rgArgs = @('-n', '--no-heading', '--color', 'never')
    if ($scopeAbs -eq $ProjectRoot) {
      $base = $ProjectRoot
      if ($excludeInfra -and $InfraProjectRel -ne '') { $rgArgs += @('--glob', "!$InfraProjectRel/**") }
      $rgArgs += @('--', $Pattern, '.')
    } elseif ($scopeAbs.StartsWith($ProjectRoot + $Sep)) {
      $base = $ProjectRoot
      $rgArgs += @('--', $Pattern, (To-Slash $scopeAbs.Substring($ProjectRoot.Length + 1)))
    } else {
      $base = $scopeAbs
      $rgArgs += @('--', $Pattern, '.')
    }
    Push-Location $base
    try { $out = @(& rg @rgArgs 2>&1 | ForEach-Object { "$_" }); $code = $LASTEXITCODE }
    finally { Pop-Location }
    if ($code -gt 1) { $out | Write-Output; exit $code }
    $out = @($out | ForEach-Object { To-Slash ($_ -replace '^\./', '') })
    Write-Bounded $out $MaxSearchHits
    return
  }

  $hits = @()
  foreach ($f in (Get-SearchFiles $scopeAbs $excludeInfra)) {
    if ($BinaryExt -contains $f.Extension.ToLower()) { continue }
    if ($f.Length -gt 2MB) { continue }
    $ms = Select-String -LiteralPath $f.FullName -Pattern $Pattern -ErrorAction SilentlyContinue
    foreach ($m in @($ms)) {
      if ($null -ne $m) { $hits += ('{0}:{1}:{2}' -f (RelPath $f.FullName), $m.LineNumber, $m.Line) }
    }
    if ($hits.Count -gt ($MaxSearchHits * 3)) { break }
  }
  Write-Bounded $hits $MaxSearchHits
}

function Cmd-View([string]$Path, [string]$Start, [string]$Count) {
  if (-not $Path) { Die 'view requires a path' }
  $file = Resolve-ExistingPath $Path $false
  if (-not $Start) { $Start = '1' }
  if (-not $Count) { $Count = "$MaxViewLines" }
  if ($Start -notmatch '^\d+$') { Die 'start must be a positive integer' }
  if ($Count -notmatch '^\d+$') { Die 'count must be a positive integer' }
  $s = [int]$Start; $c = [int]$Count
  if ($s -lt 1) { Die 'start must be >= 1' }
  if ($c -gt $MaxViewLines) { $c = $MaxViewLines }
  $e = $s + $c - 1
  Write-Output ("== {0}:{1}-{2} ==" -f (RelPath $file), $s, $e)
  $lines = @(Get-Content -LiteralPath $file -Encoding UTF8)
  if ($s -gt $lines.Count) { return }
  $endIdx = [Math]::Min($e, $lines.Count) - 1
  $n = $s
  foreach ($l in $lines[($s - 1)..$endIdx]) {
    Write-Output ("{0,6}  {1}" -f $n, $l)
    $n++
  }
}

function Cmd-Trace([string]$Id) {
  if (-not $Id) { Die 'trace requires an ID' }
  Cmd-Grep $Id $ProjectRoot
}

function Cmd-Evidence([string]$Ref) {
  if (-not $Ref) { Die 'evidence requires path:line' }
  $m = [regex]::Match($Ref, '^(.+):(\d+)$')
  if (-not $m.Success) { Die 'evidence must look like path:line' }
  $path = $m.Groups[1].Value
  $line = [int]$m.Groups[2].Value
  $file = Resolve-ExistingPath $path $false
  $lines = @(Get-Content -LiteralPath $file -Encoding UTF8)
  if ($line -le $lines.Count) {
    Write-Output ("OK {0}:{1} exists" -f (RelPath $file), $line)
    Write-Output ("{0,6}  {1}" -f $line, $lines[$line - 1])
  } else {
    Die ("{0} has only {1} lines, citation asked for {2}" -f (RelPath $file), $lines.Count, $line)
  }
}

function Cmd-Diff {
  & git -C $ProjectRoot rev-parse --is-inside-work-tree 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0) { Die "project root is not a git worktree: $ProjectRoot" }
  Write-Output '== git status --short =='
  Write-Bounded @(& git -C $ProjectRoot status --short 2>&1 | ForEach-Object { "$_" }) 80
  Write-Output ''
  Write-Output '== changed files =='
  Write-Bounded @(& git -C $ProjectRoot diff --name-status 2>&1 | ForEach-Object { "$_" }) 80
  Write-Output ''
  Write-Output '== diff stat =='
  Write-Bounded @(& git -C $ProjectRoot diff --stat 2>&1 | ForEach-Object { "$_" }) 80
}

function Cmd-Verify {
  $ps1 = Join-Path $InfraDir 'project/verify.ps1'
  $sh  = Join-Path $InfraDir 'project/verify.sh'
  $out = @()
  $code = 0

  if (Test-Path -LiteralPath $ps1) {
    Write-Output ("== verify: {0}/project/verify.ps1 (cwd: {1}) ==" -f $InfraRel, $ProjectRoot)
    $engine = Get-PsEngine
    Push-Location $ProjectRoot
    try { $out = @(& $engine -NoProfile -ExecutionPolicy Bypass -File $ps1 2>&1 | ForEach-Object { "$_" }); $code = $LASTEXITCODE }
    finally { Pop-Location }
  } elseif ((Test-Path -LiteralPath $sh) -and (Has-Cmd 'bash')) {
    Write-Output ("== verify: {0}/project/verify.sh via bash (cwd: {1}) ==" -f $InfraRel, $ProjectRoot)
    Push-Location $ProjectRoot
    try { $out = @(& bash $sh 2>&1 | ForEach-Object { "$_" }); $code = $LASTEXITCODE }
    finally { Pop-Location }
  } else {
    Die ("missing {0}/project/verify.ps1 (or verify.sh + bash) — 对齐时应把本项目的 build/test 命令固化成 verify 脚本（见 /align-activate），否则请按 aligned-rules 命令段手动验证" -f $InfraRel)
  }

  if ($out.Count -gt $VerifyTail) {
    Write-Output ("...(showing last {0}/{1} output lines)" -f $VerifyTail, $out.Count)
    $out[($out.Count - $VerifyTail)..($out.Count - 1)] | Write-Output
  } else {
    $out | Write-Output
  }
  if ($code -eq 0) {
    Write-Output 'OK verify passed (exit 0)'
  } else {
    Write-Output ("x verify failed (exit {0})" -f $code)
  }
  exit $code
}

function Cmd-Validate {
  $engine = Get-PsEngine
  & $engine -NoProfile -ExecutionPolicy Bypass -File (Join-Path $InfraDir 'tools/validate-ai-docs.ps1')
  exit $LASTEXITCODE
}

# ---- dispatch ----
switch ($Command) {
  'help'          { Show-Usage }
  '-h'            { Show-Usage }
  '--help'        { Show-Usage }
  'state'         { Cmd-State }
  'verify'        { Cmd-Verify }
  'validate'      { Cmd-Validate }
  'promote-check' { Cmd-PromoteCheck }
  'find'          { Cmd-Find ($Rest | Select-Object -First 1) ($Rest | Select-Object -Skip 1 -First 1) }
  'grep'          { Cmd-Grep ($Rest | Select-Object -First 1) ($Rest | Select-Object -Skip 1 -First 1) }
  'view'          { Cmd-View ($Rest | Select-Object -First 1) ($Rest | Select-Object -Skip 1 -First 1) ($Rest | Select-Object -Skip 2 -First 1) }
  'trace'         { Cmd-Trace ($Rest | Select-Object -First 1) }
  'evidence'      { Cmd-Evidence ($Rest | Select-Object -First 1) }
  'diff'          { Cmd-Diff }
  default         { Die "unknown command: $Command (try: tools/aci.ps1 help)" }
}
