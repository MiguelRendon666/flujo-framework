# Changelog

## 0.4.0

- **Entrega de hooks por `settings.json` del proyecto, no por el plugin.** El dogfood en Malia demostro que los hooks declarados en el `hooks.json` de un plugin NO se ejecutan en algunos Claude Code (probado: ni spec-guard ni scan-comments disparaban, ni tras reiniciar el proceso ni en sesion top-level), mientras que los hooks de `settings.json` SI corren (file-watched). Ahora `/flujo-init` copia los scripts a `<repo>/.claude/flujo-hooks/` (versionados en git) y materializa el bloque `hooks` en `.claude/settings.json` apuntando a `${CLAUDE_PROJECT_DIR}/.claude/flujo-hooks/*.ps1`.
- Ventaja: el enforcement **viaja en el git del proyecto** — los companeros lo obtienen al clonar, sin depender de que su Claude Code cargue hooks de plugin.
- `stop-dod.ps1` resuelve sus scripts hermanos (`gauntlet.ps1`, `tasks-complete.ps1`) por `$PSScriptRoot` (mismo directorio), ya no por `CLAUDE_PLUGIN_ROOT`.
- Removido el `hooks.json` del plugin y su referencia en `plugin.json` (evita doble disparo donde el plugin si cargue hooks).

## 0.3.0

- **Planeacion al nivel de Superpowers**: nueva skill `brainstorming` (socratico 1-a-1, aprobacion de diseno por secciones ANTES de codear, escribe `specs/<feature>/design.md`), con la escalera anti-sobreingenieria incrustada — combina completitud + sobriedad.
- Portadas al plugin las skills `ctx` (dimensionar contexto) y `arch` (max 2 opciones) — arregla las referencias colgantes del `flujo`.
- `plan.md`: regla anti-placeholder + autorevision antes de implementar (cobertura spec->tarea, conflict scan).
- Integracion documentada con Plan Mode nativo (brainstorming lo antecede).

## 0.2.0

- **spec-guard**: hook PreToolUse que bloquea editar rutas de dominio sin spec activa o modo declarado. Determinista por rutas (`flujo.json > specGuard.requirePaths`) + modo; no dispara en investigacion/lectura/tests/docs. Default sin rutas (no molesta hasta configurarse).
- Nuevo comando `/flujo-mode` (spike|explore|research|bugfix|chore|feature|clear).
- **Ruteo de modelos** por tarea: agente `coder` (modelo economico) para la fase 5; `solid-guardian` a Haiku; seccion `models` en `flujo.json`. El modelo grande deja de teclear boilerplate.
- Nuevo `flujo.json` (config de spec-guard y modelos) en las plantillas.

## 0.1.0

- Marketplace con dos plugins: `flujo-core` y `flujo-devexpress`.
- Motor: skill `flujo` (9 fases), `docs-rewrite`, `gauntlet`, `spec-new`, `adr-new`, `rules-comentarios`.
- Agentes: `solid-guardian`, `design-critic`, `fresh-verifier`.
- Hooks deterministas: scan-comments, block-bash, context-budget (opt-in), readiness, stop-dod.
- Templates de proyecto: docs (Diataxis + ADR + C4), specs, gauntlet.json, dod.json, CI.
- Comandos: `/flujo-init`, `/flujo-sync`.
