param(
  [ValidateSet('patch', 'minor', 'major')][string]$Level = 'patch',
  [string]$Root = (Split-Path $PSScriptRoot -Parent)
)
$ErrorActionPreference = 'Stop'

function Step([string]$v) {
  $p = $v.Split('.'); $maj = [int]$p[0]; $min = [int]$p[1]; $pat = [int]$p[2]
  switch ($Level) {
    'major' { $maj++; $min = 0; $pat = 0 }
    'minor' { $min++; $pat = 0 }
    default { $pat++ }
  }
  "$maj.$min.$pat"
}

$mkPath = Join-Path $Root '.claude-plugin/marketplace.json'
$mk = Get-Content $mkPath -Raw | ConvertFrom-Json
foreach ($entry in $mk.plugins) {
  $manifest = Join-Path $Root (($entry.source -replace '^\./', '') + '/.claude-plugin/plugin.json')
  $pj = Get-Content $manifest -Raw | ConvertFrom-Json
  $new = Step $pj.version
  $pj.version = $new
  ($pj | ConvertTo-Json -Depth 10) | Set-Content $manifest -Encoding utf8
  $entry.version = $new
  Write-Output "$($entry.name): -> $new"
}
($mk | ConvertTo-Json -Depth 10) | Set-Content $mkPath -Encoding utf8
Write-Output "bump-version ($Level): OK. Actualiza CHANGELOG.md y corre release.ps1."
