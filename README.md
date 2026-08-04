# Flujo

**Framework de enforcement para Claude Code.** Convierte la calidad de un *consejo que el agente puede ignorar* en una *regla que el harness impone*. Lo que debe cumplirse vive en **hooks** (scripts que ejecuta Claude Code), no en el prompt. El agente no puede reportar "listo" hasta demostrar —con evidencia— que pasó el guantelete.

> Casi todos los packs para Claude Code son CLAUDE.md + skills: contexto que el modelo elige seguir. Flujo es la capa determinista que faltaba.

---

## Tabla de contenido

- [Requisitos](#requisitos)
- [Instalación](#instalación)
- [Inicializar un proyecto](#inicializar-un-proyecto)
- [Cómo se comporta el agente a partir de ahora](#cómo-se-comporta-el-agente-a-partir-de-ahora)
- [Planeación por hitos (/workflow-plan)](#planeación-por-hitos-workflow-plan)
- [Ejemplos de interacción](#ejemplos-de-interacción)
- [Comandos](#comandos)
- [El guantelete de calidad](#el-guantelete-de-calidad)
- [Definition of Done](#definition-of-done)
- [Documentación IA-friendly](#documentación-ia-friendly)
- [Configuración](#configuración)
- [Estructura que crea en tu proyecto](#estructura-que-crea-en-tu-proyecto)
- [Arquitectura](#arquitectura)
- [Herramientas incluidas y créditos](#herramientas-incluidas-y-créditos)
- [Escape hatches y desactivación](#escape-hatches-y-desactivación)
- [Estado del proyecto (v0.5.1)](#estado-del-proyecto-v051)
- [Troubleshooting](#troubleshooting)

---

## Requisitos

| Requisito | Detalle |
|---|---|
| Claude Code | Versión con soporte de plugins, hooks y skills (`/plugin`). |
| PowerShell | **Windows PowerShell 5.1** basta (los hooks usan `powershell`, no `pwsh`). |
| git | Para clonar/instalar desde el marketplace. |
| .NET SDK | Solo para las etapas del guantelete (`dotnet build/format/test`). El motor funciona sin él; las etapas de test vienen apagadas hasta que las conectes. |

---

## Instalación

```bash
# 1. Añadir el marketplace
/plugin marketplace add MiguelRendon666/flujo-framework

# 2. Instalar el motor (agnóstico) y el pack de stack
/plugin install flujo-core@flujo
/plugin install flujo-devexpress@flujo   # opcional: solo si trabajas DevExpress/XAF

# 3. Recargar
/reload-plugins
```

En la instalación, `flujo-core` te pedirá configuración (`userConfig`):

| Opción | Qué es | Default |
|---|---|---|
| `db_connection` | Connection string de datos reales (solo lectura). Se guarda en el **keychain**, no en settings.json. | vacío |
| `enable_context_budget_hook` | Reencamina lecturas/búsquedas amplias en el hilo principal (economía de tokens). | `false` |
| `enable_persona` | Módulo de identidad del agente. | `false` |

---

## Inicializar un proyecto

Dentro del repo donde vas a trabajar:

```bash
/flujo-init
```

Es **idempotente** y **no pisa** lo que ya tengas. Crea la estructura, fusiona `settings.json` sin borrar tus permisos, y al terminar te imprime exactamente qué rellenar:

```
Flujo inicializado. Rellena, en este orden:
  1. docs/constitution.md   <- principios del proyecto (obligatorio)
  2. docs/_inbox/           <- tira aquí tus notas informales, sin formato
Luego ejecuta:  /docs-rewrite
Para una feature nueva:  /spec-new <slug>
```

Si el guantelete detecta que no existen tus proyectos de test reales, deja esas etapas `enabled: false` y te avisa cuáles activar.

---

## Cómo se comporta el agente a partir de ahora

Esta es la parte que cambia tu día a día. Con Flujo instalado, el agente adquiere estas peculiaridades:

### 1. No reporta "listo" hasta demostrarlo

Al final de cada turno, un **Stop hook** corre el guantelete local y verifica las tareas. Si algo falla, **no deja cerrar el turno**: te devuelve la etapa rota y sigue trabajando.

```json
{ "decision": "block",
  "reason": "DoD pendiente (intento 1/8). Resuelve y reintenta:\nGAUNTLET FAIL en etapa 'build'" }
```

Converge: solo bloquea sobre fallos **locales y accionables**; a los **8 intentos** deja de insistir y te **escala** el problema con un reporte (nunca un pase silencioso).

### 2. Bloquea comentarios prohibidos antes de escribir

Un **PreToolUse hook** escanea cada edición de código (`.cs .razor .css .scss .sql .ps1 .js .ts`). Si detecta un bloque multilínea, `//` consecutivos, separadores decorativos, `#region` o breadcrumbs de IA (`// Added for...`), **niega la escritura** y el agente reescribe sin el comentario. Tú no haces nada.

### 3. Bloquea comandos destructivos

Otro PreToolUse revisa cada comando Bash y niega patrones peligrosos (`rm -rf /`, `git reset --hard`, `git push --force`, `Remove-Item -Recurse -Force` sobre rutas, formateo de disco…). Si de verdad lo necesitas, lo corres tú a mano fuera del agente.

### 4. Planifica y acuerda el diseño antes de codear

Ante un cambio de >1 archivo o >15 líneas, una decisión de arquitectura, ambigüedad, o algo nuevo, el agente **planifica antes de tocar** (para lo trivial o informativo **no** se activa: responde directo):

- **Dimensiona el contexto** (`ctx`) — qué archivos y líneas hacen falta y qué excluir, para gastar el mínimo.
- **Acuerda el diseño contigo** (`brainstorming`) — preguntas socráticas de una en una, 2-3 enfoques con trade-offs, aprobación **sección por sección**. Escribe `specs/<feature>/design.md` y **no escribe código hasta que apruebes**.
- **Propone arquitectura** (`arch`) — máximo 2 opciones, con recomendación y riesgos.
- **Autorevisa el plan** antes de implementar — cada criterio de la spec tiene tarea (cobertura), **sin placeholders**, y un *conflict scan* que escala contradicciones como una sola pregunta.

Combina dos ejes que rara vez van juntos: **completitud** (que no falte nada) y **sobriedad** (que no sobre nada — escalera anti-sobreingeniería, reusar antes de crear).

### 5. Audita de forma independiente antes de dar "done"

Al terminar de implementar, corren revisores que no escribieron el código:

- **solid-guardian** — audita SOLID y arquitectura, veredicto estructurado.
- **design-critic** — audita UI/UX si tocaste markup visual.
- **fresh-verifier** (opcional) — intenta *refutar* que la tarea esté terminada, con contexto fresco.

### 6. Exige spec para tocar el dominio (spec-guard), sin frenar lo demás

Antes de **editar** una ruta que marcaste como dominio (`flujo.json` → `specGuard.requirePaths`), un hook `PreToolUse` exige que exista una spec activa (`/spec-new`) o un modo declarado. Si no, **bloquea la edición** con instrucciones. Pero:

- **No dispara** en investigación, lectura o correr casos (no hay edición que lo gatille).
- **No dispara** en `tests/`, `docs/`, `scripts/`, `scratch/`, `*.md`, `*.feature`.
- Si estás explorando cómo hacer algo en dominio, declaras `/flujo-mode spike` (o `research`/`bugfix`/`explore`/`chore`) una vez y editas libre, con traza.
- **Por defecto no bloquea nada** hasta que listes tus rutas de dominio en `flujo.json` (cero fricción sorpresa).

No adivina tu intención: la deciden **rutas configurables + un modo explícito**. El `.feature` en Gherkin queda como documentación viva y test BDD.

### 7. Documenta sin inventar

Tiras notas informales en `docs/_inbox/` y corres `/docs-rewrite`. El agente las reorganiza (Diátaxis + ADR), detecta contradicciones/obsolescencia y **te pregunta ante la duda** — nunca rellena con suposiciones.

### 8. Gasta menos tokens

El enforcement son scripts (≈0 tokens del modelo). Las auditorías corren en subagentes con contexto **desechable** y veredicto estructurado. La exploración va en cascada (grafo → símbolo → lectura acotada) en vez de cargar archivos enteros.

### 9. Rutea el modelo por tarea

Reserva el modelo grande para pensar: la implementación (fase 5) se delega al subagente `coder` en modelo económico, y las auditorías corren en Haiku/Sonnet — así el modelo caro no gasta tecleando boilerplate. Configurable en `flujo.json` → `models` (`plan`/`code`/`audit`/`quick`).

> Límite honesto: el modelo del **hilo principal** lo fijas tú con `/model`; el framework no lo cambia por mensaje (Claude Code no tiene hook para eso). Lo que sí controla es el modelo de cada subagente.

---

## Planeación por hitos (`/workflow-plan`)

Para trabajo no trivial, `/workflow-plan <historia>` convierte una **historia cruda** del usuario (la necesidad, no una solución ya hecha) en un plan ejecutable **por hitos**. Escala al tamaño (YAGNI): trivial → directo; una task → plan ligero; grande → deep-plan.

> **Es `/workflow-plan`, no `/plan`.** `/plan` es el Plan Mode nativo de Claude Code; su aprobación NO autoriza edición de código dentro de flujo. Usa siempre `/workflow-plan`.

**Flujo:** triage → clasifica (modify-flow / add-to-flow / new) → investiga (código: codebase-memory / Serena / grep; web: `deep-research` / context7 / dxdocs) llenando un **research-log** → verifica **impacto cross-flow** (que no rompa otros flujos) → propone **2-3 opciones** cuestionando tus ideas (socrático + escalera Ponytail) → construye el plan **incrementalmente**.

**Estructura del plan:**
- Un plan = razón de ser + justificación + flujo (qué / por qué) + **hitos**.
- Un **hito** = un entregable, dividido en **pasos** (código o no-código); el **último paso de cada hito es siempre doc-check** → la documentación se mantiene sola, hito a hito.
- Cada hito pasa una **revisión de diseño ANTES de escribirse al plan** (checklist del orquestador; escala a un subagente revisor en hitos grandes). El MD se arma hito validado tras hito validado.
- **Sourced + justificado (invariante):** cada paso trae su **fuente** (`archivo:línea` / query / doc) y su **porqué**, y cada decisión lista las **alternativas descartadas + razón**. Un plan sin evidencia no pasa la revisión — es auditable y retable, no solo "se ve bien".

**Tres capas de guantelete (el corazón es el de cada hito):**

| Capa | Cuándo | Qué valida |
|---|---|---|
| plan-gauntlet (por hito) | al planear | el diseño del hito antes de entrar al MD |
| milestone-gauntlet (por hito) | al ejecutar | el código del hito antes de avanzar |
| DoD (general) | al cerrar | el todo + `fresh-verifier` + evidencia |

**Artefactos:** `specs/<feature>/{spec.md (QUÉ), design.md (diseño aprobado), plan.md (hitos)}` + ADRs.

## Ejecución por hitos (`/flujo-implement`)

**Paso 2.** El agente, al cerrar el plan, te indica que ejecutes `/flujo-implement`; al correrlo, el hook cambia el modo a `implement` automáticamente y conduce la ejecución **un hito a la vez**: implementa los pasos (`coder`), corre el **guantelete de ese hito** tal como lo definió el plan (build/tests + `solid-guardian`/`design-critic`), y **PARA con un informe de cambios justificado a pedirte permiso** antes del siguiente hito. Reusa el límite de 8 intentos del DoD (`dod.json`). Ante un hallazgo que invalida el enfoque: **freno de mano** (revierte lo del hito con `git restore`, presenta hallazgos + propuestas ya pasadas por guantelete). Al terminar vuelve a modo `plan`. **Nunca commitea** (es tuyo) y **el agente nunca implementa ni cambia de modo por su cuenta.**

## Pruebas obligatorias (skill `test-gen` + guantelete)

El código de lógica **debe** estar probado; no es opcional. La lógica se controla con un **switch** (`flujo.json > testing.enabled`) que **tú decides al instalar** (informado): `/flujo-init` busca el proyecto de pruebas del repo y lo propone; si no hay, sugiere crear uno o apagar el switch. Con el switch **encendido**, las pruebas y **Stryker** (mutation testing) son **bloqueo duro**; sin proyecto de pruebas configurado, el guantelete **truena**. Con el switch **apagado**, cada cambio de código te **recuerda** que no queda cubierto.

Cada hito gana un **paso penúltimo de pruebas** (antes del doc-check): el skill **`test-gen`** las genera pensando **como usuario, no como programador** — casos borde, límites, errores **primero**, y el **happy path al final**. Cada prueba pasa un **guantelete de 11 reglas** antes de crearse (no duplicada, un solo happy path por grupo, debe poder fallar, prueba una sola cosa, determinista, aserción con sentido…). Se exime el código trivial (getters, contenedores de datos, catálogos repetidos, mapeos 1:1, UI). *Nota: los comandos concretos de prueba/cobertura/mutación viven en el `gauntlet.json` de tu proyecto; el framework define la política, no la tecnología.*

**Aceptación (Gherkin).** Los escenarios `.feature` (`Dado/Cuando/Entonces`) son **documentación viva del comportamiento, siempre presente**: `gherkin-gen` los deriva de los criterios de aceptación de la spec (adversarial primero, un solo `@happy`, `@cubre:<flujo>` como puente con las unitarias) y **pregunta si un criterio es ambiguo**. El chequeo `gherkin-check` valida su sanidad (bloqueo duro). **Ejecutar** esos escenarios como prueba (etapa `bdd`) es **opt-in** — se decide al instalar con una explicación amplia de costo/beneficio; apagarlo no apaga la escritura de escenarios.

**Deuda técnica (skill `tech-debt`).** Herramienta **advisory, no un muro**: le apuntas a un archivo/flujo/módulo y te da un informe priorizado por impacto (ubicación, por qué es deuda, remediación, esfuerzo). Read-only, no bloquea ni corre en el guantelete; lleva un registro (*tech debt ledger*) en `docs/TECH_DEBT.md`. Además, `/workflow-plan` surface la deuda de los flujos que el plan toca como sección **informativa** (no obligatoria) para que decidas si la pagas.

**Estilos (theme-first).** Opt-in por instalación (`style.enabled`): cuando se activa, **ningún valor de identidad visual se escribe a mano** (colores, tamaños, radios, fuentes, `1px`, `opacity`…) — todo sale de tokens del tema (`style.themeSource`, definido por ti). El skill **`theme-first`** aplica un **mini-gauntlet de token** (¿ya existe? → reusar; ¿casi-duplicado? → **para y pregunta**, evitando la "sopa de tokens"; nombre por rol, no por componente) y el detector **`style-check`** bloquea literales quemados en CSS/SCSS. Los estilos de **vendor** que no controlas (`style.vendorExempt`, ej. XAF) son intocables. Mover elementos no es esto (eso es `design-critic`). La detección específica por tecnología vive en los stack-packs.

## Ejemplos de interacción

### Feature nueva, de principio a fin

```
Tú:  Agrega exportación a Excel en la vista de Facturas.

IA:  Es no trivial → activo flujo. /brainstorming, una pregunta a la vez:
       • ¿Exportas la vista filtrada actual o todos los registros?

Tú:  La filtrada.

IA:    • ¿.xlsx nativo o vía la plantilla de ReportsV2 que ya existe?

Tú:  Nativo.

IA:  Diseño (apruébalo por partes): reuso el ExportController y exporto el
     CollectionSource filtrado a .xlsx nativo. → ¿OK?

Tú:  OK.

IA:  Escribo specs/facturas-export/design.md.
     /spec-new facturas-export  → spec/plan/tasks + .feature
     Autorevisión del plan: cobertura 12/12, sin placeholders, sin conflictos.
     [implemento reusando el ExportController existente]
     solid-guardian → PASS
     Stop hook:  dotnet build -warnaserror ✓   format ✓   gauntlet OK (6)
     Listo. Evidencia: 0 errores, 12/12 tareas, escenario .feature verde.
```

### Intentas (o la IA intenta) colar un comentario

```
La IA va a escribir:
    /* Calcula el total sumando los ítems */
    public decimal Total() => ...

PreToolUse scan-comments → DENY:
    "Política de comentarios (tolerancia cero): bloque /* */ multi-línea."

La IA reescribe sin el comentario y sigue. Cero intervención tuya.
```

### Le preguntas si ya terminó

```
Tú:  ¿ya quedó?
IA:  No según el gate. El Stop hook corrió el guantelete:
       ✗ etapa 'format' — 3 archivos sin formatear
     Lo arreglo y reintento (intento 2/8).
```

### Documentar tus notas

```
Tú:  (pegas ideas sueltas en docs/_inbox/estatus.md)
Tú:  /docs-rewrite
IA:  Procesé 1 nota → 1 how-to + 1 reference.
     ⚠ Contradicción: escribes "el estatus se calcula en el editor",
       pero el código lo hace en EstatusController:42.
       ¿Cuál es la fuente de verdad? (no decido por ti)
```

### Saltarte el gate a propósito (WIP)

```
Tú:  /gauntlet skip --reason "WIP, subo a rama de trabajo"
IA:  Guantelete saltado. Queda registrado con tu razón en el reporte
     (visible, no silencioso).
```

---

## Comandos

| Comando | Qué hace |
|---|---|
| `/flujo-new <nombre> <idea>` | Crea un proyecto **desde cero** (greenfield) con flujo desde el día uno: planea (stack elegido por ti), **guía** el scaffold del esqueleto (stack-pack o herramienta nativa), y cablea la gobernanza. Semilla = idea inline o archivo de requerimientos. |
| `/flujo-init` | Instala flujo sobre un proyecto que **ya existe**: materializa la capa de proyecto (docs, specs, gauntlet, CI). Idempotente. |
| `/flujo-sync` | Reconcilia lo gestionado por el framework tras un update del plugin, sin tocar tu contenido. |
| `/spec-new <slug>` | Crea `specs/<slug>/` (spec/plan/tasks/.feature) y la marca como feature activa. |
| `/flujo-mode <modo>` | Declara el tipo de tarea para el spec-guard. Editables ad-hoc: `spike`/`explore`/`bugfix`/`chore`/`feature`. NO-editables (bloquean código): `plan`/`document`/`review`. `clear` borra el modo. *(Para ejecutar un plan usa `/flujo-implement`, no un modo manual.)* |
| `/brainstorming` | De idea a diseño aprobado por secciones (socrático) antes de codear; escribe `specs/<feature>/design.md`. |
| `/workflow-plan <historia>` | De una historia cruda a plan **por hitos**: investiga (código+web), impacto cross-flow, 2-3 opciones, y **cada hito pasa revisión de diseño antes de escribirse al MD**. Corre en modo NO-editable (nunca implementa). *(No confundir con `/plan`, el Plan Mode nativo.)* |
| `/flujo-implement` | **Paso 2.** Ejecuta el `plan.md` activo **hito por hito**: implementa, corre el guantelete del hito, y PARA con informe justificado a pedir permiso. Fija modo `implement` (vía hook), reusa el límite de 8 del DoD, freno de mano ante hallazgos, nunca commitea, al terminar vuelve a `plan`. Solo lo corre el usuario. |
| `/ctx` · `/arch` | Dimensionar contexto mínimo · consultor de arquitectura (máx 2 opciones). |
| `/adr-new <título>` | Crea un ADR con formato MADR y numeración consecutiva. |
| `/gauntlet [tier]` | Corre el guantelete a mano (`local`/`ci`/`all`). `/gauntlet skip --reason "…"` para saltarlo con traza. |
| `/docs-rewrite [--check]` | Reescribe `_inbox` a docs IA-friendly. `--check` = read-only para CI. |

Además, la skill `flujo` se auto-invoca en tareas no triviales; no necesitas llamarla.

---

## El guantelete de calidad

> **Guantelete** (calco de *gauntlet*) = la **cadena de verificaciones** que el código debe atravesar antes de darse por terminado. Se conserva `gauntlet` como identificador técnico (`gauntlet.json`, `/gauntlet`); en prosa, léelo como "cadena de verificaciones".

Once etapas ordenadas por **costo/feedback** (lo barato primero, fail-fast). Definido en `gauntlet.json` de tu proyecto — el motor es agnóstico, los comandos son de tu stack:

| # | Etapa | Comando (default .NET) | Tier | Bloqueo |
|---|---|---|---|---|
| 1 | Build + warnings-as-errors | `dotnet build -warnaserror` | local + ci | duro |
| 2 | Formato | `dotnet format --verify-no-changes` | local + ci | duro |
| 3 | Comentarios prohibidos | script (hook) | local + ci | duro |
| 4 | Análisis estático | `.editorconfig` severidad error | local + ci | duro |
| 5 | Arquitectura | `dotnet test` (NetArchTest) | local + ci | duro |
| 6 | Unit + cobertura | `dotnet test /p:CollectCoverage=true /p:Threshold=80` | local + ci | duro |
| 7 | Integración | `dotnet test` | ci | duro |
| 8 | BDD Gherkin | `dotnet test` (Reqnroll) | ci | duro |
| 9 | E2E | `dotnet test` (Playwright) | ci | duro |
| 10 | Mutation | `dotnet stryker` | nightly | informativo |
| 11 | Doc drift + changelog | `docs-rewrite --check` | ci | blando |

- **local** (Stop hook): etapas 1-6, en segundos, sin infra.
- **ci** (`quality-gate.yml`): completo en cada push.
- **nightly** (cron): incluye la mutación (cara).

Cada etapa es una entrada del manifiesto; activar/desactivar es un `"enabled": true|false`:

```json
{ "id": "e2e", "order": 9, "cmd": "dotnet test tests/E2E", "tier": "ci", "blocking": "hard", "enabled": false }
```

Correr a mano: `powershell -File scripts/gauntlet.ps1 -Tier local`.

---

## Definition of Done

Un **único punto de aceptación** que no crea checks nuevos: comprueba que los gates previos están en verde **con evidencia mostrada**. Definido en `dod.json`:

```json
{
  "gates": [
    { "id": "gauntlet",        "required": true,  "check": "gauntlet --local", "blocking": "hard" },
    { "id": "tasks",           "required": true,  "check": "tasks-complete",   "blocking": "hard" },
    { "id": "evidence",        "required": false, "goal": "transcript shows 'gauntlet OK' and audit verdicts" },
    { "id": "semantic-verify", "required": false, "agent": "fresh-verifier",   "when": "nontrivial" }
  ],
  "maxBlocks": 8,
  "onExhausted": "handoff-report"
}
```

- **gauntlet** — el guantelete local pasa.
- **tasks** — todas las tareas de la feature activa en `[x]` (lee `.claude/.active-feature`).
- **evidence** — el transcript muestra el output real (`gauntlet OK`, veredictos), no solo la palabra "listo".
- **semantic-verify** — `fresh-verifier` contrasta el diff contra la spec.

`maxBlocks` acota la insistencia; al agotarse, escala a ti con un reporte.

---

## Documentación IA-friendly

`/docs-rewrite` recorre tu documentación y la reorganiza siguiendo **Diátaxis** (`tutorials/`, `how-to/`, `reference/`, `explanation/`) + **ADR (MADR)** + **C4** (Mermaid). Invariantes que **nunca** rompe:

- **Nunca inventa** — toda afirmación ancla al código o a tu input; lo demás se marca, no se escribe.
- **Nunca borra sin traza** — las eliminaciones quedan como cross-ref o `DEPRECATED`.
- **Pregunta, no adivina** — contradicciones y ambigüedades van a una tanda de preguntas.
- **Idempotente** — sin cambios en código/docs, cero diff.

Los `.feature` (Gherkin) son documentación viva: legibles y ejecutables (Reqnroll) a la vez.

---

## Configuración

| Archivo | Dónde | Para qué |
|---|---|---|
| `flujo.json` | raíz del proyecto | spec-guard (rutas que exigen spec) y ruteo de modelos por tarea |
| `gauntlet.json` | raíz del proyecto | etapas del guantelete y toggles |
| `dod.json` | raíz del proyecto | gates del Definition of Done y `maxBlocks` |
| `.claude/settings.json` | proyecto (versionado) | plugins habilitados, permisos, marketplace |
| `.claude/settings.local.json` | proyecto (gitignored) | overrides personales, secretos |
| `.claude/rules/comentarios.md` | proyecto | regla de comentarios (path-scoped a código) |
| `.editorconfig` / `stryker-config.json` | raíz | estilo y mutación |

`flujo.json` de un vistazo (por defecto no bloquea nada hasta que listes tus rutas de dominio):

```json
{
  "specGuard": {
    "enabled": true,
    "requirePaths": ["**/*Controller.cs", "**/Domain/**"],
    "exemptModes": ["spike", "research", "bugfix", "explore", "chore"]
  },
  "models": { "plan": "opus", "code": "sonnet", "audit": "haiku" }
}
```

MCP incluidos en `flujo-core`: `sequentialthinking`, `context7`, `fetch`, `codebase-memory`, `playwright`, y `postgres-real-data` (vía `db_connection`). El pack `flujo-devexpress` añade `dxdocs`.

---

## Estructura que crea en tu proyecto

```
tu-repo/
├── CLAUDE.md                     # constitución operativa (importa docs/constitution.md)
├── .claude/
│   ├── settings.json             # plugins + permisos (versionado)
│   ├── settings.local.json       # personal (gitignored)
│   ├── rules/comentarios.md      # regla path-scoped a *.cs, *.razor, ...
│   └── flujo-hooks/*.ps1         # scripts de los hooks (versionados; los ejecuta settings.json)
├── docs/
│   ├── constitution.md           # ← lo rellenas tú
│   ├── ARCHITECTURE.md
│   ├── _inbox/                    # ← tiras tus notas aquí
│   ├── adr/                       # ADR MADR (inmutables)
│   ├── architecture/context.mmd   # C4 (Mermaid)
│   └── tutorials|how-to|reference|explanation/   # Diátaxis
├── specs/<feature>/
│   ├── spec.md · plan.md · tasks.md
│   └── <feature>.feature          # Gherkin (doc viva + BDD)
├── gauntlet.json · dod.json
├── stryker-config.json · .editorconfig
└── .github/workflows/quality-gate.yml
```

---

## Arquitectura

Dos plugins en un marketplace:

- **flujo-core** — el motor, agnóstico de dominio. Skills (`flujo`, `brainstorming`, `ctx`, `arch`, `docs-rewrite`, `gauntlet`, `spec-new`, `adr-new`, `rules-comentarios`), agentes (`solid-guardian`, `design-critic`, `fresh-verifier`, `coder`), hooks + scripts, y las plantillas de proyecto.
- **flujo-devexpress** — pack de stack DevExpress XAF/Blazor/XPO: skills por componente + `dxdocs`. Intercambiable por otro pack sin tocar el motor.

Tres capas por **ubicación**: framework (plugin) · proyecto (`<repo>/.claude` + `docs/` + `specs/`, versionado) · desarrollador (`settings.local.json`, secretos). Enforcement determinista en hooks; guía en skills; el motor no sabe de tu stack (lee `gauntlet.json`).

---

## Herramientas incluidas y créditos

Flujo **orquesta** herramientas de terceros; **no reclama autoría de ninguna**. Cada una pertenece a sus autores y conserva su licencia. Esto es todo con lo que cuentas al instalarlo.

### MCP incluidos (arrancan al habilitar el plugin)

| MCP | Qué te da | Proyecto / autor | Licencia |
|---|---|---|---|
| `sequentialthinking` | Razonamiento estructurado multipaso | Model Context Protocol (Anthropic) — `modelcontextprotocol/servers` | MIT |
| `context7` | Docs actualizadas de librerías | Upstash — `upstash/context7` | MIT |
| `fetch` (`mcp-fetch-server`) | Traer web como md / txt / json / transcript | Zach Cáceres — `zcaceres/fetch-mcp` | MIT |
| `codebase-memory` | Grafo de código y búsqueda semántica | DeusData — `DeusData/codebase-memory-mcp` | MIT |
| `playwright` | Navegador: screenshot, snapshot a11y, red, consola | Microsoft — `microsoft/playwright-mcp` | Apache-2.0 |
| `postgres-real-data` | Consultar Postgres real (solo lectura) | Model Context Protocol (Anthropic) | MIT |
| `dxdocs` *(pack DevExpress)* | Documentación oficial DevExpress | DevExpress | Términos DevExpress |

### Skills incluidas

- **Motor (`flujo-core`)** — de este framework: `flujo`, `brainstorming`, `ctx`, `arch`, `docs-rewrite`, `gauntlet`, `spec-new`, `adr-new`, `rules-comentarios`.
- **Pack de stack (`flujo-devexpress`)** — **© DevExpress, skill pack oficial** (frontmatter `author: DevExpress`, v26.1; requiere licencia DevExpress para el producto):
  - *Blazor*: `ai-chat`, `charts`, `combobox`, `gauges`, `grid`, `pivot-table`, `ribbon`, `scheduler`, `toolbar`, `treelist`.
  - *XAF*: `appearance`, `business-logic`, `business-logic-xpo`, `business-model`, `controllers`, `editors`, `filtering`, `filtering-xpo`, `performance`, `reports`, `security`, `validation`, `views`.
  - `conexion-bases-datos` (ruteo del MCP de datos).

### Agentes y hooks

De este framework: agentes `solid-guardian`, `design-critic`, `fresh-verifier`; hooks `scan-comments`, `block-bash`, `context-budget`, `readiness`, `stop-dod`.

### Companions recomendados (NO incluidos — se instalan aparte)

La metodología rinde más con estos, pero el plugin **no** los empaqueta:

| Tool | Para qué | Proyecto / autor | Licencia |
|---|---|---|---|
| ponytail | Reto "senior perezoso" anti-sobreingeniería (MCP) | DietrichGebert — `DietrichGebert/ponytail` | MIT |
| dbhub | SQL Server / MySQL / MariaDB / SQLite (lo usa `conexion-bases-datos`) | Bytebase — `bytebase/dbhub` | ver repo |
| Serena | Edición a nivel símbolo vía LSP (economía de tokens) | `oraios/serena` | ver repo |

### Herramientas externas que invoca el guantelete (.NET)

No se empaquetan; el guantelete las llama por CLI si tu proyecto las tiene:

| Etapa | Herramienta | Proyecto |
|---|---|---|
| build / format | .NET SDK (`dotnet`) | Microsoft |
| arquitectura | NetArchTest | Ben Morris — `BenMorris/NetArchTest` |
| cobertura | coverlet | `coverlet-coverage/coverlet` |
| BDD Gherkin | Reqnroll | reqnroll.net |
| E2E | Playwright for .NET | Microsoft |
| mutación | Stryker.NET | stryker-mutator.io |

### Metodologías en las que se basa

Diátaxis (Daniele Procida) · ADR/MADR (Michael Nygard + proyecto MADR) · C4 model (Simon Brown) · Gherkin (Cucumber) · Living Documentation (Cyrille Martraire). Host y estándar: **Claude Code** y **MCP**, de **Anthropic**.

### Enlaces (repos / sitios)

**MCP incluidos**
- sequentialthinking · postgres-real-data — https://github.com/modelcontextprotocol/servers
- context7 — https://github.com/upstash/context7
- fetch (`mcp-fetch-server`) — https://github.com/zcaceres/fetch-mcp
- codebase-memory — https://github.com/DeusData/codebase-memory-mcp
- playwright — https://github.com/microsoft/playwright-mcp
- dxdocs · pack DevExpress — https://www.devexpress.com

**Companions recomendados**
- ponytail — https://github.com/DietrichGebert/ponytail
- dbhub — https://github.com/bytebase/dbhub
- Serena — https://github.com/oraios/serena

**Herramientas del guantelete (.NET)**
- .NET SDK — https://dotnet.microsoft.com
- NetArchTest — https://github.com/BenMorris/NetArchTest
- coverlet — https://github.com/coverlet-coverage/coverlet
- Reqnroll — https://reqnroll.net
- Playwright for .NET — https://playwright.dev/dotnet
- Stryker.NET — https://stryker-mutator.io

**Metodologías y host**
- Diátaxis — https://diataxis.fr
- ADR / MADR — https://adr.github.io/madr
- C4 model — https://c4model.com
- Gherkin (Cucumber) — https://cucumber.io/docs/gherkin
- Living Documentation — https://leanpub.com/livingdocumentation
- Claude Code — https://code.claude.com
- Model Context Protocol — https://modelcontextprotocol.io
- Anthropic — https://www.anthropic.com

> Cada herramienta conserva su propia licencia; consulta su repositorio para los términos exactos. Flujo solo las orquesta.

---

## Escape hatches y desactivación

- **Saltar el gate una vez, con traza:** `/gauntlet skip --reason "…"` — queda registrado, no silencioso.
- **Apagar el hook opcional de tokens:** `enable_context_budget_hook: false`.
- **Apagar todos los hooks (nuclear):** `"disableAllHooks": true` en `settings.json`. Desaconsejado; visible en config.
- **Desinstalar:** `/plugin uninstall flujo-core@flujo`.

---

## Estado del proyecto (v0.5.1)

**Funciona y está probado:**
- **Entrega de hooks por `settings.json`** (+ scripts en `.claude/flujo-hooks/`): verificado en Malia que **corre donde el `hooks.json` del plugin no** — es la vía fiable (file-watched) y viaja en git.
- Hooks deterministas (comentarios, comandos destructivos) — verificados.
- DoD por Stop hook: bloquea "done" si el guantelete falla; converge y escala a los 8 intentos.
- Runner del guantelete por manifiesto (build y formato listos).
- Instalable: marketplace + 2 plugins publicados y validados (`scripts/validate-plugins.ps1`).
- Planeación: `brainstorming` (diseño aprobado por secciones), `ctx`/`arch`, y autorevisión del plan (anti-placeholder, cobertura spec→tarea, conflict scan).
- spec-guard (bloqueo condicionado por rutas + modo, verificado por casos) y ruteo de modelos por subagente.

**Cableado, aún por rodar en real:**
- `/workflow-plan` (planeación por hitos) + `/flujo-implement` (ejecución por hitos, Paso 2) + mode-guard; en dogfood en el proyecto Malia.
- Etapas de test (unit/integración/BDD/E2E/mutación) vienen **apagadas** hasta conectar tus proyectos de test.
- `docs-rewrite` está diseñado e implementado; falta rodaje sobre documentación real.
- Pensado para **.NET** hoy; el motor es agnóstico, el stack se cambia.

---

## Troubleshooting

| Síntoma | Causa / solución |
|---|---|
| Los hooks no corren | Se entregan vía `.claude/settings.json` + scripts en `.claude/flujo-hooks/` (NO vía el plugin — su `hooks.json` no siempre carga). Verifica que `/flujo-init` los creó y que `powershell` está en PATH (PS 5.1 sirve; no usan `pwsh`). |
| El gauntlet "no corre nada" | Falta `gauntlet.json` en la raíz, o las etapas están `enabled: false`. |
| El Stop hook nunca bloquea | Falta `dod.json`, o el gate `gauntlet` no es `required`. |
| El gauntlet corre en una consulta (sin editar código) | Desde v0.4.1 no debería: `stop-dod` solo corre si el turno editó código (marcador `mark-dirty` en PostToolUse). Verifica que `/flujo-init` copió `mark-dirty.ps1` y que el hook PostToolUse está en `settings.json`. |
| El agente ignoró el flujo | La tarea fue trivial/informativa (el flujo se salta a propósito). |
| Cambié un archivo gestionado y se revirtió | Es esperado: `/flujo-sync` reconcilia lo del framework. Edita en la capa de proyecto/desarrollador. |

---

**Flujo · v0.5.1** — el gate no es negociable, pero es honesto.
