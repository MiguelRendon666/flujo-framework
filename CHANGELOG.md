# Changelog

## 0.9.0

- **Pilar Gherkin / aceptacion.** Los escenarios `.feature` son documentacion viva SIEMPRE activa; ejecutarlos como prueba (etapa `bdd`) es opt-in por instalacion.
- **Nuevo skill `gherkin-gen`:** genera los escenarios desde los criterios de aceptacion del `spec.md` (adversarial primero, UN `@happy` al final, `@cubre` en cada escenario). Ante criterio ambiguo o incompleto, PREGUNTA en vez de inventar. `spec-new` lo invoca: el `.feature` ya no nace vacio.
- **Nuevo chequeo `gherkin-check` (etapa `gherkin` del guantelete, bloqueo duro):** un solo `@happy` por `.feature`, `@cubre` en cada escenario, estructura de pasos presente. Corre siempre que existan `.feature`.
- **Sub-switch `testing.bdd`** (opt-in, default apagado): la ejecucion BDD se decide al instalar con una explicacion amplia (que requiere, a que afecta, como beneficia/perjudica). Apagarla NO apaga la escritura de escenarios.
- **Marcadores por defecto** `@happy` / `@borde` / `@error` / `@cubre:<flujo/funcion>` — el `@cubre` es el puente `.feature` (flujo) <-> pruebas unitarias (funcion).
- **`docs-rewrite`** ahora ENLAZA los `.feature` (sigue sin reescribirlos): la doc de un flujo referencia su `.feature` como fuente de verdad del comportamiento.
- `flujo-implement` anti-stale extendido: al modificar un flujo, actualiza tambien sus escenarios `.feature`.
- Politica en el core (agnostico); los comandos concretos de ejecucion viven en el `gauntlet.json` del proyecto.

## 0.8.0

- **Pilar de pruebas: unitarias como parte DURA del guantelete (agnostico).** Nuevo skill `test-gen` que genera pruebas para funcion/flujo/funcionalidad pensadas COMO USUARIO (adversarial primero, happy path al final); cada prueba pasa un guantelete de 11 reglas antes de crearse (no duplicada, un solo happy path por grupo, debe poder fallar, prueba una sola cosa, independiente, determinista, asercion con sentido, nombre por escenario...).
- **Switch de pruebas** (`flujo.json > testing.enabled`), decidido en la instalacion: `/flujo-init` busca el proyecto de pruebas del repo y lo propone; si no hay, sugiere crear uno o apagar el switch. Con el switch apagado, `stop-dod` recuerda en cada turno con codigo editado que ese cambio no queda cubierto por unit tests.
- **Variable del proyecto de pruebas** (`testing.project`) en vez de la ruta quemada `tests/Unit`: `gauntlet.ps1` la sustituye en el comando. Switch encendido y sin proyecto configurado -> bloqueo duro.
- **Stryker (mutation testing) pasa de nightly/informativo a local/duro** cuando el switch esta encendido: valida que las pruebas de verdad sirvan (mutan el CODIGO y revisan si las pruebas lo cazan).
- **Paso penultimo por hito = pruebas unitarias:** plantilla `plan.md`, `/workflow-plan` y `/flujo-implement` insertan/ejecutan un paso de pruebas (via `test-gen`) antes del doc-check, con anti-stale (al modificar un flujo se actualizan sus pruebas).
- **Exenciones** configurables (`testing.exemptions`): getters, contenedores de datos, catalogos repetidos, mapeos 1:1, autogenerado, cableado, UI. Siempre requerido: procesos y funciones con logica.
- Politica en el core (agnostico); los comandos concretos de prueba/cobertura/mutacion viven en el `gauntlet.json` del proyecto. Gherkin (marcadores + sanidad + doc-wiring) queda para 0.8.1.

## 0.7.0

- **Nuevo comando `/flujo-implement` (Paso 2): ejecucion del plan HITO POR HITO.** Toma el `plan.md` de la feature activa y ejecuta UN hito a la vez: implementa los pasos (`coder`), corre el "Guantelete del hito" tal como el plan lo definio (build/tests via `gauntlet.ps1` + `solid-guardian`/`design-critic`), y PARA con un informe de cambios justificado a pedir permiso antes del siguiente hito. **Reusa** el limite de 8 intentos del DoD (`dod.json` maxBlocks) y los agentes/skills existentes; no reescribe nada. **Freno de mano** ante hallazgos que invalidan el enfoque: `git restore` de lo tocado + hallazgos + propuestas ya pasadas por guantelete. **Nunca commitea** (es del usuario). Al terminar vuelve a modo `plan`. Solo lo corre el usuario: correrlo ES la autorizacion explicita, y `readiness` fija el modo `implement`.
- README: nueva seccion "Ejecucion por hitos" + fila en la tabla de comandos. `implement` retirado de los modos manuales de `/flujo-mode` (reservado para `/flujo-implement`).

## 0.6.3

- **El comando de ejecucion (Paso 2) se llamara `/flujo-implement`, no `/implement`** (evita colision como paso con `/plan`→`/workflow-plan`). Renombrado en `readiness` (detecta `/flujo-implement` → fija modo `implement`), mensajes del mode-guard, `/workflow-plan`, `/flujo-mode`, README.
- **Modelo de ejecucion aclarado:** el agente NUNCA implementa ni cambia de modo por su cuenta. Al cerrar el plan, **INDICA al usuario que ejecute `/flujo-implement`**; el usuario lo corre y el hook `readiness` cambia el modo a `implement` automaticamente (canal seguro: el mode-guard le impide al modelo editar `.task-mode`). El cambio de modo NO es manual.
- **`implement` deja de ser un modo manual de `/flujo-mode`** — se reserva para `/flujo-implement`. `/flujo-mode` queda solo para tareas ad-hoc fuera de un plan (`spike`/`explore`/`bugfix`/`chore`/`feature`). El valor `implement` sigue en `exemptModes` porque lo fija el comando, no el usuario.
- Nota: el DRIVER `/flujo-implement` (ejecucion hito-por-hito con milestone-gauntlet + re-plan + commit por hito) aun no esta construido; esto es solo el naming y el cableado del cambio-de-modo.

## 0.6.2

- **FIX del bug real: el Stop/DoD buildeaba tras CANCELAR una orden.** El marcador `.flujo-dirty` (lo pone `mark-dirty` en PostToolUse cuando se edita codigo) se consumia recien en el siguiente `Stop`. Si un turno editaba codigo y era **interrumpido/cancelado**, su marcador quedaba huerfano y disparaba el guantelete (build) en el **siguiente turno conversacional** — aunque ese turno no tocara nada. Fix: `readiness` (UserPromptSubmit) **limpia `.flujo-dirty` al inicio de cada turno**, asi el marcador solo refleja ediciones de ESE turno. Reproducido y verificado (turno conversacional con marcador huerfano → NO buildea; turno que si edita → si buildea).
- **Revertido `-p:NuGetAudit=false`** (introducido por error en 0.6.1): enmascaraba vulnerabilidades reales de dependencias; el gate se mantiene honesto. El problema nunca fue el contenido del build sino QUE corriera en el momento equivocado (arreglado arriba).

## 0.6.1

- **RENOMBRADO `/plan` → `/workflow-plan`.** `/plan` colisiona con el **Plan Mode NATIVO de Claude Code**: al escribir `/plan`, Claude Code entraba a su Plan Mode integrado (no nuestro comando, que tiene `disable-model-invocation`), y su aprobacion de ExitPlanMode ("you can now start coding") se leia como autorizacion para implementar — puenteando toda la gobernanza flujo. El comando REAL es ahora `/workflow-plan`. Actualizado en comando, `readiness`, `/flujo-mode`, README, template y CHANGELOG.
- **Red de seguridad:** `readiness` ahora fija `.task-mode=plan` tanto en `/workflow-plan` como en el `/plan` nativo, para que ni el Plan Mode nativo pueda auto-autorizar edicion de codigo (el mode-guard sigue bloqueando hasta que el usuario declare un modo editable).

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
