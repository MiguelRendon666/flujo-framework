$ErrorActionPreference = 'Stop'
$raw = [Console]::In.ReadToEnd()
if (-not $raw) { exit 0 }
try { $j = $raw | ConvertFrom-Json } catch { exit 0 }

$path = $j.tool_input.file_path
if (-not $path) { exit 0 }
$ext = [System.IO.Path]::GetExtension($path).ToLower()
$codeExt = @('.cs', '.razor', '.css', '.scss', '.sql', '.ps1', '.js', '.ts')
if ($codeExt -notcontains $ext) { exit 0 }

$texts = @()
if ($j.tool_input.new_string) { $texts += [string]$j.tool_input.new_string }
if ($j.tool_input.content) { $texts += [string]$j.tool_input.content }
if ($j.tool_input.edits) { foreach ($e in $j.tool_input.edits) { if ($e.new_string) { $texts += [string]$e.new_string } } }
if ($texts.Count -eq 0) { exit 0 }

$violations = @()
foreach ($t in $texts) {
  if ($t -match '(?s)/\*.*?\r?\n.*?\*/') { $violations += 'bloque /* */ multi-linea' }
  if ($t -match '(?s)@\*.*?\r?\n.*?\*@') { $violations += 'bloque Razor @* *@ multi-linea' }
  if ($t -match '(?m)^[ \t]*//.*\r?\n[ \t]*//') { $violations += 'comentarios // consecutivos' }
  if ($t -match '(?m)^[ \t]*--.*\r?\n[ \t]*--') { $violations += 'comentarios SQL -- consecutivos' }
  if ($t -match '(?m)//\s*-{4,}' -or $t -match '(?m)/\*\s*=+') { $violations += 'separador decorativo' }
  if ($t -match '#region|#endregion') { $violations += 'marca #region' }
  if ($t -match '(?im)//\s*(added|updated|changed|this (handles|is)|for now|fixed for|to handle)') { $violations += 'breadcrumb de IA' }
}

if ($violations.Count -gt 0) {
  $reason = 'Politica de comentarios (tolerancia cero): ' + (($violations | Select-Object -Unique) -join '; ') + '. Elimina el comentario; solo se permite 1 linea con WHY no inferible.'
  (@{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = $reason } } | ConvertTo-Json -Compress -Depth 5)
}
exit 0
