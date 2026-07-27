param([string]$Root = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'
$errors = @()

function Test-Json($path) {
  if (-not (Test-Path $path)) { return "falta: $path" }
  try { Get-Content $path -Raw | ConvertFrom-Json | Out-Null; return $null }
  catch { return "JSON invalido: $path -> $($_.Exception.Message)" }
}

$mk = Join-Path $Root '.claude-plugin/marketplace.json'
$e = Test-Json $mk; if ($e) { $errors += $e }
else {
  $m = Get-Content $mk -Raw | ConvertFrom-Json
  if (-not $m.name) { $errors += 'marketplace.json sin name' }
  foreach ($p in $m.plugins) {
    $src = Join-Path $Root ($p.source -replace '^\./', '')
    $manifest = Join-Path $src '.claude-plugin/plugin.json'
    $e = Test-Json $manifest; if ($e) { $errors += $e }
    else {
      $pj = Get-Content $manifest -Raw | ConvertFrom-Json
      if (-not $pj.name) { $errors += "$manifest sin name" }
      if ($pj.hooks) { $hp = Join-Path $src ($pj.hooks -replace '^\./', ''); $e = Test-Json $hp; if ($e) { $errors += $e } }
      if ($pj.mcpServers) { $mp = Join-Path $src ($pj.mcpServers -replace '^\./', ''); $e = Test-Json $mp; if ($e) { $errors += $e } }
    }
  }
}

Get-ChildItem -Path $Root -Recurse -Filter '*.ps1' | ForEach-Object {
  $tokens = $null; $perr = $null
  [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$tokens, [ref]$perr) | Out-Null
  if ($perr.Count -gt 0) { $errors += "PowerShell parse: $($_.Name) -> $($perr[0].Message)" }
}

if ($errors.Count -gt 0) {
  Write-Output 'VALIDACION FALLIDA:'
  $errors | ForEach-Object { Write-Output "  - $_" }
  exit 1
}
Write-Output 'validate-plugins: OK'
exit 0
