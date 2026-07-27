# flujo-core

Motor agnostico de dominio del framework Flujo.

## Contenido

- **skills**: `flujo` (9 fases), `docs-rewrite` (docs IA-friendly), `gauntlet`, `spec-new`, `adr-new`, `rules-comentarios`.
- **agents**: `solid-guardian`, `design-critic`, `fresh-verifier` (veredicto estructurado, modelo barato).
- **hooks** (`hooks/hooks.json` → `scripts/`): scan-comments (PreToolUse), block-bash (PreToolUse), context-budget (PreToolUse, opt-in), readiness (UserPromptSubmit), stop-dod (Stop).
- **templates**: capa de proyecto que `/flujo-init` materializa.
- **.mcp.json**: set curado de MCP (sequentialthinking, context7, fetch, codebase-memory, playwright, postgres-real-data via userConfig).

## userConfig (pedido en instalacion)

- `db_connection` (sensitive): connection string de datos reales.
- `enable_context_budget_hook` (bool): reencamina lecturas/busquedas amplias.
- `enable_persona` (bool): modulo de identidad opcional.

## Nota de arquitectura

Los agents usan MCP de sesion (declarados en `.mcp.json` de este plugin) via su allowlist `tools`; no declaran mcpServers propios (limitacion de plugin agents). El guantelete lee `gauntlet.json` del proyecto: el motor es agnostico, los comandos son del stack.
