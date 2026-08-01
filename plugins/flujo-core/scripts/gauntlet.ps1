param(
  [string]$Tier = 'local',
  [string]$ProjectDir = $env:CLAUDE_PROJECT_DIR
)
$ErrorActionPreference = 'Stop'
if (-not $ProjectDir) { $ProjectDir = (Get-Location).Path }
$cfgPath = Join-Path $ProjectDir 'gauntlet.json'
if (-not (Test-Path $cfgPath)) { Write-Output 'gauntlet: sin gauntlet.json en el proyecto, nada que correr'; exit 0 }
$cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json

# politica de pruebas desde flujo.json: switch (enabled) + proyecto de pruebas
$testEnabled = $false
$testProject = ''
$flujoPath = Join-Path $ProjectDir 'flujo.json'
if (Test-Path $flujoPath) {
  try { $t = (Get-Content $flujoPath -Raw | ConvertFrom-Json).testing; if ($t) { $testEnabled = ($t.enabled -eq $true); $testProject = [string]$t.project } } catch {}
}

$tiers = switch ($Tier) {
  'all' { @('local', 'ci', 'nightly') }
  'ci' { @('local', 'ci') }
  default { @($Tier) }
}
$stages = $cfg.stages | Where-Object { $tiers -contains $_.tier -and $_.enabled -ne $false } | Sort-Object order
$ran = 0
foreach ($s in $stages) {
  # etapas de prueba: gated por el switch; encendido sin proyecto = bloqueo duro
  if ($s.requiresTesting -eq $true) {
    if (-not $testEnabled) { continue }
    if (-not $testProject) {
      Write-Output "GAUNTLET FAIL en etapa '$($s.id)': testing.enabled=true pero flujo.json no define testing.project. Configura el proyecto de pruebas o apaga el switch."
      exit 1
    }
  }
  $ran++
  $cmd = $s.cmd -replace '\$\{testProject\}', $testProject
  Push-Location $ProjectDir
  $out = & cmd /c $cmd 2>&1
  $code = $LASTEXITCODE
  Pop-Location
  if ($code -ne 0) {
    $tail = ($out | Select-Object -Last 25) -join "`n"
    if ($s.blocking -eq 'soft') { Write-Output "gauntlet aviso en '$($s.id)' (informativo)"; continue }
    Write-Output "GAUNTLET FAIL en etapa '$($s.id)' (orden $($s.order)):`n$tail"
    exit 1
  }
}
Write-Output "gauntlet OK ($ran etapas, tier=$Tier)"
exit 0
