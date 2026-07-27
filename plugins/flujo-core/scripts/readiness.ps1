$ErrorActionPreference = 'Stop'
$raw = [Console]::In.ReadToEnd()
if (-not $raw) { exit 0 }
try { $j = $raw | ConvertFrom-Json } catch { exit 0 }
$proj = $j.cwd
if (-not $proj) { $proj = $env:CLAUDE_PROJECT_DIR }
if (-not $proj) { exit 0 }
if (Test-Path (Join-Path $proj 'specs')) { exit 0 }
$ctx = 'Recordatorio flujo: este proyecto aun no tiene carpeta specs/. Para cambios no triviales crea la spec con /spec-new antes de implementar (Gate 1 readiness).'
(@{ hookSpecificOutput = @{ hookEventName = 'UserPromptSubmit'; additionalContext = $ctx } } | ConvertTo-Json -Compress -Depth 5)
exit 0
