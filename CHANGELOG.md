# Changelog

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
