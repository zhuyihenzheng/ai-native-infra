# promote.ps1 — Windows counterpart of promote.sh.
# 把对齐产物(source: universal/ + project/)装配成生效入口文件(build artifact)。
# 这是 source → 生效 的唯一搬运工。对齐未完成则拒绝运行。
#
# 用法: powershell -NoProfile -ExecutionPolicy Bypass -File activate/promote.ps1 [目标项目根] [-Tools copilot]
#   -Tools 只生成指定工具的入口文件（逗号分隔，默认 claude,codex,copilot）。

[CmdletBinding()]
param(
  [Parameter(Position = 0)][string]$TargetRoot = '',
  [string]$Tools = 'claude,codex,copilot'
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InfraDir  = (Resolve-Path (Join-Path $ScriptDir '..')).Path
$InfraRel  = Split-Path -Leaf $InfraDir

if ($TargetRoot -ne '') {
  $ProjectRoot = (Resolve-Path $TargetRoot).Path
  $Explicit = $true
} else {
  $ProjectRoot = (Resolve-Path (Join-Path $InfraDir '..')).Path
  $Explicit = $false
}

$ProjectDir = Join-Path $InfraDir 'project'
$StatusFile = Join-Path $ProjectDir 'ALIGN-STATUS.md'
$RulesFile  = Join-Path $ProjectDir 'aligned-rules.md'
$Ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$Backup = Join-Path $InfraDir "_backup-$Ts"

# 装配出的入口文件里，ACI 的调用形式按本 OS 生成。
# Windows 用 .cmd 包装器：cmd.exe 和 PowerShell 里都能直接跑，内置 -ExecutionPolicy Bypass，
# 避免「デジタル署名されていません／未经数字签名」类执行策略报错（组策略强制 AllSigned 除外，见 universal/aci/README.md）。
$AciInvoke = "$InfraRel\tools\aci.cmd"

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Die([string]$m) { [Console]::Error.WriteLine("x $m"); exit 1 }

$ToolList = @($Tools.ToLower().Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
foreach ($t in $ToolList) {
  if ($t -notin @('claude', 'codex', 'copilot')) { Die "未知工具 '$t'（可选: claude,codex,copilot）" }
}
function Has-Tool([string]$Name) { return $ToolList -contains $Name }

Write-Output "==> 目标项目: $ProjectRoot"
Write-Output "==> 生成目标工具: $($ToolList -join ',')"

# ---- 闸门 0: 防误伤（这套是 Java 项目基建；目标必须像一个项目）----
if (-not $Explicit) {
  if ($InfraRel -eq 'ai-native-infra') {
    Write-Output "x 这是基础设施 模板家目录 [$InfraDir] ，还没部署进任何项目。"
    Write-Output "  请先把模板复制为 /path/to/your-project/ai-infra 再到该项目里运行；"
    Write-Output "  或显式指定目标: promote.ps1 C:\path\to\your-project"
    exit 1
  }
  $hasBuild = $false
  foreach ($b in @('pom.xml', 'build.gradle', 'build.gradle.kts')) {
    if (Test-Path -LiteralPath (Join-Path $ProjectRoot $b)) { $hasBuild = $true }
  }
  if (-not $hasBuild) {
    Write-Output "x 目标 [$ProjectRoot] 不含 pom.xml / build.gradle(.kts)，不像一个 Java 项目根。"
    Write-Output "  若确实要写这里，请显式指定: promote.ps1 `"$ProjectRoot`""
    exit 1
  }
}

# ---- 闸门 1: 对齐状态（只读第一处标记，避免 prose 干扰）----
$State = ''
if (Test-Path -LiteralPath $StatusFile) {
  $m = Select-String -LiteralPath $StatusFile -Pattern 'ALIGN_STATE:\s*([A-Za-z-]+)' | Select-Object -First 1
  if ($null -ne $m) { $State = $m.Matches[0].Groups[1].Value }
}
if ($State -ne 'aligned') {
  Write-Output "x 对齐未完成：机器标记 ALIGN_STATE = '$State'（需为 aligned）。"
  Write-Output '  请先跑完 /align-survey … /align-review，清空待确认项后再 activate。promote 中止。'
  exit 1
}

# ---- 闸门 2: 规则文件存在且无占位符 ----
if (-not (Test-Path -LiteralPath $RulesFile)) { Die "缺少 $RulesFile" }
$RulesText = Get-Content -LiteralPath $RulesFile -Raw -Encoding UTF8
if ($RulesText -match '\{\{') { Die "$RulesFile 仍含未替换占位符 {{...}}，中止。" }

# ---- 备份已有 AI 配置（只备份本次会覆盖的；绝不静默覆盖）----
New-Item -ItemType Directory -Path $Backup -Force | Out-Null
$backList = @()
if (Has-Tool 'claude')  { $backList += 'CLAUDE.md' }
if (Has-Tool 'codex')   { $backList += 'AGENTS.md' }
if (Has-Tool 'copilot') { $backList += '.github/copilot-instructions.md' }
foreach ($f in $backList) {
  $src = Join-Path $ProjectRoot $f
  if (Test-Path -LiteralPath $src) {
    $dst = Join-Path $Backup $f
    New-Item -ItemType Directory -Path (Split-Path -Parent $dst) -Force | Out-Null
    Copy-Item -LiteralPath $src -Destination $dst
    Write-Output "  备份 $f"
  }
}
$instrDir = Join-Path $ProjectRoot '.github/instructions'
if ((Has-Tool 'copilot') -and (Test-Path -LiteralPath $instrDir)) {
  Copy-Item -LiteralPath $instrDir -Destination (Join-Path $Backup '.github-instructions') -Recurse
  Write-Output '  备份 .github/instructions/'
}
Write-Output "==> 已有配置备份到: $Backup"

if (Has-Tool 'copilot') {
  foreach ($d in @('.github/instructions', '.github/prompts', '.vscode')) {
    New-Item -ItemType Directory -Path (Join-Path $ProjectRoot $d) -Force | Out-Null
  }
}

# ---- 装配工具: 用 .tpl 头 + aligned-rules.md 体 ----
$Marker = '<!-- ↓↓↓ 由 project/aligned-rules.md 装配，请勿手改本文件；改源后重跑 promote ↓↓↓ -->'
function Assemble([string]$Tpl, [string]$OutPath) {
  $head = Get-Content -LiteralPath $Tpl -Raw -Encoding UTF8
  $head = $head -replace '\{\{INFRA_DIR\}\}', $InfraRel
  $head = $head -replace '\{\{ACI\}\}', $AciInvoke
  $body = "$head`n$Marker`n`n$RulesText"
  [IO.File]::WriteAllText($OutPath, $body, $Utf8NoBom)
  Write-Output "  生成 $OutPath"
}

if (Has-Tool 'claude') {
  Assemble (Join-Path $ScriptDir 'CLAUDE.md.tpl') (Join-Path $ProjectRoot 'CLAUDE.md')
}
if (Has-Tool 'codex') {
  Assemble (Join-Path $ScriptDir 'AGENTS.md.tpl') (Join-Path $ProjectRoot 'AGENTS.md')
}

if (Has-Tool 'copilot') {
  # .github/copilot-instructions.md（薄版优先用 project 的，没有则用 tpl+rules）
  $thin = Join-Path $ProjectDir 'copilot-instructions.md'
  if (Test-Path -LiteralPath $thin) {
    Copy-Item -LiteralPath $thin -Destination (Join-Path $ProjectRoot '.github/copilot-instructions.md')
    Write-Output '  生成 .github/copilot-instructions.md (project 薄版)'
  } else {
    Assemble (Join-Path $ScriptDir 'copilot-instructions.md.tpl') (Join-Path $ProjectRoot '.github/copilot-instructions.md')
  }

  # 层 instructions
  $instrSrc = Get-ChildItem -Path (Join-Path $ProjectDir 'instructions') -Filter '*.instructions.md' -ErrorAction SilentlyContinue
  if ($null -ne $instrSrc -and @($instrSrc).Count -gt 0) {
    @($instrSrc) | ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $ProjectRoot '.github/instructions') }
    Write-Output '  拷 instructions/*'
  }

  # 工作流 prompts（Copilot slash）；把 bash 调用改写为本 OS 的 ACI 调用
  $promptSrc = Get-ChildItem -Path (Join-Path $InfraDir 'universal/prompts/workflow') -Filter '*.prompt.md' -ErrorAction SilentlyContinue
  if ($null -ne $promptSrc -and @($promptSrc).Count -gt 0) {
    foreach ($p in @($promptSrc)) {
      $t = Get-Content -LiteralPath $p.FullName -Raw -Encoding UTF8
      $t = $t -replace '\{\{INFRA_DIR\}\}', $InfraRel
      $t = $t -replace '\{\{ACI\}\}', $AciInvoke.Replace('$', '$$')
      $t = $t -replace 'ai-infra/', "$InfraRel/"
      $t = $t.Replace("bash $InfraRel/tools/aci.sh", $AciInvoke)
      [IO.File]::WriteAllText((Join-Path (Join-Path $ProjectRoot '.github/prompts') $p.Name), $t, $Utf8NoBom)
    }
    Write-Output '  生成 workflow prompts'
  }

  # ---- .vscode/settings.json 合并（开 Copilot 开关）----
  $snip = Join-Path $ScriptDir 'settings.snippet.json'
  $dest = Join-Path $ProjectRoot '.vscode/settings.json'
  $snipObj = Get-Content -LiteralPath $snip -Raw -Encoding UTF8 | ConvertFrom-Json
  if (Test-Path -LiteralPath $dest) {
    $baseObj = Get-Content -LiteralPath $dest -Raw -Encoding UTF8 | ConvertFrom-Json
  } else {
    $baseObj = New-Object PSObject
  }
  foreach ($prop in $snipObj.PSObject.Properties) {
    $baseObj | Add-Member -MemberType NoteProperty -Name $prop.Name -Value $prop.Value -Force
  }
  [IO.File]::WriteAllText($dest, (ConvertTo-Json $baseObj -Depth 10), $Utf8NoBom)
  Write-Output '  合并 .vscode/settings.json'
}

Write-Output "==> 完成（$($ToolList -join ',')）。所选工具现按本项目对齐规则工作。"
Write-Output "    回滚：从 $Backup 恢复。改规则：改 project/ 源后重跑本脚本。"
