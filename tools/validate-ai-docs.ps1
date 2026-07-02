# validate-ai-docs.ps1 — Windows counterpart of validate-ai-docs.sh.
# 治理校验：文件齐全 + 证据路径存在 + 占位符未残留 + 状态自洽。退出码非 0 表示有问题（可挂 CI）。

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InfraDir  = (Resolve-Path (Join-Path $ScriptDir '..')).Path
$ProjectRoot = (Resolve-Path (Join-Path $InfraDir '..')).Path
$script:Err = 0

function Warn([string]$m) { Write-Output "x $m"; $script:Err = 1 }
function Ok([string]$m)   { Write-Output "OK $m" }
function Rel([string]$p)  { return ($p.Substring($InfraDir.Length + 1) -replace '\\', '/') }

Write-Output '== 1. 必需文件存在 =='
$required = @(
  'README.md',
  'project/ALIGN-STATUS.md',
  'project/aligned-rules.md',
  'activate/promote.sh',
  'activate/promote.ps1',
  'activate/promote.cmd',
  'tools/aci.sh',
  'tools/aci.ps1',
  'tools/aci.cmd',
  'tools/validate-ai-docs.sh',
  'tools/smoke-aci.sh',
  'universal/aci/README.md',
  'universal/maps/traceability.md'
)
foreach ($r in $required) {
  $f = Join-Path $InfraDir $r
  if (Test-Path -LiteralPath $f -PathType Leaf) { Ok $r } else { Warn "缺文件 $f" }
}

# 对齐状态（与 promote 同一机器标记；只读第一处，避免 prose 干扰）
$Aligned = $false
$statusFile = Join-Path $InfraDir 'project/ALIGN-STATUS.md'
if (Test-Path -LiteralPath $statusFile) {
  $m = Select-String -LiteralPath $statusFile -Pattern 'ALIGN_STATE:\s*([A-Za-z-]+)' | Select-Object -First 1
  if ($null -ne $m -and $m.Matches[0].Groups[1].Value -eq 'aligned') { $Aligned = $true }
}

Write-Output '== 2. 占位符未残留（仅在已对齐时强校验 project/）=='
$rules = Join-Path $InfraDir 'project/aligned-rules.md'
if ($Aligned) {
  $text = ''
  if (Test-Path -LiteralPath $rules) { $text = Get-Content -LiteralPath $rules -Raw -Encoding UTF8 }
  if ($text -match '\{\{') { Warn '已对齐但 aligned-rules.md 仍含 {{占位符}}' } else { Ok 'aligned-rules.md 无占位符' }
  if ($text -match '(?i)PLACEHOLDER') { Warn 'aligned-rules.md 仍是 PLACEHOLDER' }
} else {
  Write-Output '  (项目未对齐，跳过 project 占位符强校验)'
}

Write-Output '== 3. PROJECT-FACTS 证据路径存在性抽检 =='
$facts = Join-Path $InfraDir 'project/PROJECT-FACTS.md'
if (Test-Path -LiteralPath $facts) {
  $ftext = Get-Content -LiteralPath $facts -Raw -Encoding UTF8
  if ($ftext -notmatch '(?i)PLACEHOLDER') {
    $paths = [regex]::Matches($ftext, '[A-Za-z0-9_./-]+\.(java|xml|yml|yaml|sql|properties)') |
      ForEach-Object { $_.Value } | Sort-Object -Unique
    foreach ($p in $paths) {
      if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot $p))) {
        Write-Output "  ! 证据路径不存在: $p"
      }
    }
    Ok '证据路径抽检完成（! 为可疑项）'
  } else {
    Write-Output '  (PROJECT-FACTS 仍为占位，跳过)'
  }
} else {
  Write-Output '  (PROJECT-FACTS 不存在，跳过)'
}

Write-Output '== 4. 真实 PII / 凭证泄漏粗检（fixture 与 docs）=='
$leakPattern = '(password\s*=\s*[^ ]{6,}|BEGIN [A-Z ]*PRIVATE KEY|[0-9]{12,16})'
$leaks = @()
$candidates = Get-ChildItem -LiteralPath $InfraDir -Recurse -File -ErrorAction SilentlyContinue |
  Where-Object { $_.Extension -in @('.json', '.md', '.yml') -and $_.Name -ne 'settings.snippet.json' }
foreach ($f in $candidates) {
  $hit = Select-String -LiteralPath $f.FullName -Pattern $leakPattern -ErrorAction SilentlyContinue |
    Where-Object { $_.Line -notmatch 'h2:mem' } | Select-Object -First 1
  if ($null -ne $hit) { $leaks += (Rel $f.FullName) }
}
if ($leaks.Count -gt 0) {
  Write-Output '  ! 疑似敏感内容（请人工确认）:'
  $leaks | ForEach-Object { Write-Output "    $_" }
}
Ok '泄漏粗检完成'

Write-Output ''
if ($script:Err -eq 0) { Write-Output '== 结果：通过 ==' } else { Write-Output '== 结果：有问题（见上）==' }
exit $script:Err
