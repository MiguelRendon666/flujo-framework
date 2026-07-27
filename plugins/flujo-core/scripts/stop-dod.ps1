$ErrorActionPreference = 'Stop'
$raw = [Console]::In.ReadToEnd()
$j = $null
$proj = $env:CLAUDE_PROJECT_DIR
if ($raw) { try { $j = $raw | ConvertFrom-Json; if ($j.cwd) { $proj = $j.cwd } } catch {} }
if (-not $proj) { $proj = (Get-Location).Path }

# stop_hook_active evita re-entrada infinita cuando el propio hook provoco la continuacion
if ($j -and $j.stop_hook_active -eq $true) { exit 0 }

$dodPath = Join-Path $proj 'dod.json'
if (-not (Test-Path $dodPath)) { exit 0 }
$dod = Get-Content $dodPath -Raw | ConvertFrom-Json
$maxBlocks = if ($dod.maxBlocks) { [int]$dod.maxBlocks } else { 8 }

$pluginRoot = $env:CLAUDE_PLUGIN_ROOT
if (-not $pluginRoot) { $pluginRoot = Split-Path $PSScriptRoot -Parent }
$scripts = Join-Path $pluginRoot 'scripts'

$failures = @()
$g = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $scripts 'gauntlet.ps1') -Tier local -ProjectDir $proj 2>&1
if ($LASTEXITCODE -ne 0) { $failures += ($g -join "`n") }
$tk = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $scripts 'tasks-complete.ps1') -ProjectDir $proj 2>&1
if ($LASTEXITCODE -ne 0) { $failures += ($tk -join "`n") }

$statePath = Join-Path $proj '.claude/.dod-state.json'
$count = 0
if (Test-Path $statePath) { try { $count = [int]((Get-Content $statePath -Raw | ConvertFrom-Json).blocks) } catch { $count = 0 } }

if ($failures.Count -eq 0) {
  if (Test-Path $statePath) { Remove-Item $statePath -Force }
  exit 0
}

$count++
if ($count -ge $maxBlocks) {
  if (Test-Path $statePath) { Remove-Item $statePath -Force }
  $msg = "DoD NO cumplido tras $maxBlocks intentos. Escalado al usuario. Pendiente:`n" + ($failures -join "`n")
  (@{ continue = $true; systemMessage = $msg } | ConvertTo-Json -Compress -Depth 6)
  exit 0
}

$dir = Split-Path $statePath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
(@{ blocks = $count } | ConvertTo-Json) | Set-Content -Path $statePath -Encoding utf8
$reason = "Definition of Done pendiente (intento $count/$maxBlocks). Resuelve y reintenta:`n" + ($failures -join "`n")
(@{ decision = 'block'; reason = $reason } | ConvertTo-Json -Compress -Depth 6)
exit 0
