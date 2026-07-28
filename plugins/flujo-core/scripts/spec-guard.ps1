$ErrorActionPreference = 'Stop'
$raw = [Console]::In.ReadToEnd()
if (-not $raw) { exit 0 }
try { $j = $raw | ConvertFrom-Json } catch { exit 0 }

$file = [string]$j.tool_input.file_path
if (-not $file) { exit 0 }

$proj = [string]$j.cwd
if (-not $proj) { $proj = $env:CLAUDE_PROJECT_DIR }
if (-not $proj) { exit 0 }

$cfgPath = Join-Path $proj 'flujo.json'
if (-not (Test-Path $cfgPath)) { exit 0 }
try { $cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json } catch { exit 0 }
$sg = $cfg.specGuard
if (-not $sg -or $sg.enabled -ne $true) { exit 0 }
if (-not $sg.requirePaths -or $sg.requirePaths.Count -eq 0) { exit 0 }

$rel = $file
if ($file.StartsWith($proj, [StringComparison]::OrdinalIgnoreCase)) {
  $rel = $file.Substring($proj.Length)
}
$rel = ($rel -replace '\\', '/').TrimStart('/')

function Test-Glob([string]$path, [string]$glob) {
  $rx = [Regex]::Escape($glob)
  $rx = $rx -replace '\\\*\\\*/', '(.*/)?'
  $rx = $rx -replace '\\\*\\\*', '.*'
  $rx = $rx -replace '\\\*', '[^/]*'
  return $path -match ('^' + $rx + '$')
}

foreach ($g in $sg.exemptPaths) { if (Test-Glob $rel $g) { exit 0 } }

$isDomain = $false
foreach ($g in $sg.requirePaths) { if (Test-Glob $rel $g) { $isDomain = $true; break } }
if (-not $isDomain) { exit 0 }

$modeFile = Join-Path $proj '.claude/.task-mode'
if (Test-Path $modeFile) {
  $mode = (Get-Content $modeFile -Raw).Trim().ToLower()
  if ($sg.exemptModes -contains $mode) { exit 0 }
}

$active = Join-Path $proj '.claude/.active-feature'
if (Test-Path $active) {
  $f = (Get-Content $active -Raw).Trim()
  if ($f) { exit 0 }
}

$reason = "spec-guard: editas '$rel' (ruta de dominio) sin spec activa. Crea una con /spec-new <feature>, o si no la amerita declara /flujo-mode spike|research|bugfix|explore|chore."
(@{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = $reason } } | ConvertTo-Json -Compress -Depth 5)
exit 0
