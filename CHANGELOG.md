# Changelog

## 0.6.0

- **Nuevo: mode-guard — frontera dura entre planear y editar.** Un modo **NO-editable** (`plan`/`document`/`review`) hace que `spec-guard` **NIEGUE toda edicion de codigo** (`.cs/.razor/.css/.scss/.js/.ts/.sql/.csproj/.props/.targets`), sin importar spec activa ni `requirePaths`. Solo se permiten `.md`/`.feature`. El chequeo corre **antes** de cualquier early-exit del spec-guard, asi que aplica siempre.
- **`/plan` es ahora estrictamente NO-editable.** El hook `readiness` fija `.claude/.task-mode=plan` al invocar `/plan`; el mode-guard bloquea codigo mientras dure. `/plan` **nunca implementa ni despacha implementacion** — su unico entregable es documentacion. Corrige el bucle donde tras un `/plan` el agente se ponia a buildear/implementar solo.
- **Pasar de un modo NO-editable a uno editable exige autorizacion EXPLICITA del usuario** (`/implement`, o `/flujo-mode <modo-editable>`). Ninguna transicion automatica a edicion. `implement` es ahora un modo editable declarado; `research` se retiro de `exemptModes` (usa `spike`/`explore` para editar sin spec).
- `flujo.json`: nuevo campo `specGuard.nonEditingModes` (default `["plan","document","review"]`).

## 0.5.1

- **`/plan`: sourced + justificado como INVARIANTE de la revision por hito.** Un hito no entra al `plan.md` si: (a) cada paso no trae su fuente (`archivo:linea`/query/doc) y su porque, (b) las decisiones no listan alternativas descartadas + razon, o (c) hay afirmaciones sin evidencia (se marcan `supuesto — verificar`, nunca se dan por hecho). Plan trazable y auditable garantizado, no opcional.
- Template `plan.md`: nueva seccion **Decisiones** (elegida vs descartadas + ADR) y campos **fuente/porque** por paso y por hito.

## 0.5.0

- **Nuevo comando `/plan <historia>`**: de una historia cruda del usuario a un plan ejecutable **por hitos**. Triage por tamano (YAGNI: trivial->directo, task->ligero, grande->deep-plan), clasifica (modify/add/new), investiga (codigo + web delegado, con research-log), verifica **impacto cross-flow**, propone 2-3 opciones (cuestiona las ideas del usuario), y construye el plan **INCREMENTALMENTE** — cada hito pasa una **revision de diseno** (checklist; escala a subagente revisor en hitos grandes) ANTES de escribirse al MD. Cada hito lleva **doc-check** como ultimo paso (docs auto-actualizadas).
- **Nuevo template `plan.md` por hitos**: razon de ser, justificacion, flujo, research-log, impacto cross-flow, e hitos con pasos (codigo/no-codigo) + guantelete propio del hito.
- Proximo (Paso 2): `/implement` — driver de ejecucion hito-por-hito con milestone-gauntlet scoped + re-plan por hallazgos.

## 0.4.1

- **El Stop hook (DoD) ya no corre el gauntlet en turnos sin ediciones de codigo.** Nuevo hook `PostToolUse` (`mark-dirty.ps1`) que marca "se edito codigo este turno" (solo extensiones de codigo, no `.md`); `stop-dod.ps1` corre el gauntlet **solo si ese marcador esta** y lo consume. Una consulta —aunque el arbol tenga cambios pendientes— ya no dispara build. Corrige el bucle de bloqueo en consultas sobre un build roto.
- **`/flujo-init` PROPONE `specGuard.requirePaths`** detectando la estructura de dominio del repo, en vez de dejarlo vacio para edicion manual. El usuario aprueba/ajusta; ya no hay que tocar `flujo.json` a mano.

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
