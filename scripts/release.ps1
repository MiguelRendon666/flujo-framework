param([string]$Root = (Split-Path $PSScriptRoot -Parent))
$ErrorActionPreference = 'Stop'

& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'validate-plugins.ps1')
if ($LASTEXITCODE -ne 0) { Write-Output 'release abortado: validacion fallida'; exit 1 }

$mk = Get-Content (Join-Path $Root '.claude-plugin/marketplace.json') -Raw | ConvertFrom-Json
$ver = ($mk.plugins | Select-Object -First 1).version

Push-Location $Root
git add -A
git commit -m "release v$ver"
git tag "v$ver"
Pop-Location
Write-Output "release v${ver}: commit + tag creados. Publica con: git push --follow-tags"
