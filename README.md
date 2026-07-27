# Flujo — framework instalable de desarrollo asistido por IA

Pack tipo plugin para Claude Code que **obliga** a trabajar bajo gates de calidad antes de dar una tarea por terminada. Motor agnostico de dominio + pack de stack intercambiable.

## Que hace

- **Flujo de 9 fases** con reto anti-sobreingenieria (skill `flujo`).
- **Guantelete de calidad** ordenado por costo/feedback, bloqueante via hooks (build → format → comentarios → estatico → arquitectura → unit/cobertura → integration → BDD → E2E → mutation → doc-drift).
- **Definition of Done determinista**: el Stop hook impide reportar "done" con verificaciones pendientes; converge en ≤8 intentos y escala al usuario si no.
- **Documentacion IA-friendly**: la skill `docs-rewrite` convierte notas informales en docs estructuradas (Diataxis + ADR) sin inventar ni perder ideas.
- **Economia de tokens**: enforcement determinista (scripts) en vez de razonamiento; auditores con contexto fresco; exploracion en cascada.

## Estructura

```
.claude-plugin/marketplace.json     marketplace con 2 plugins
plugins/flujo-core/                  motor agnostico (skills, agents, hooks, scripts, templates)
plugins/flujo-devexpress/            pack de stack DevExpress XAF/Blazor/XPO
examples/sample-app/                 proyecto minimal ya inicializado
scripts/validate-plugins.ps1         valida manifests y estructura
```

## Instalacion

```
/plugin marketplace add MiguelRendon666/flujo-framework
/plugin install flujo-core@flujo
/plugin install flujo-devexpress@flujo
```

En la instalacion se pediran (userConfig): connection string de datos reales (opcional, va al keychain) y toggles.

## Uso en un proyecto

```
/flujo-init          crea docs/, specs/, hooks, gauntlet.json, dod.json, CI (idempotente)
                     -> indica que rellenar: docs/constitution.md y docs/_inbox/
/docs-rewrite        convierte _inbox en documentacion IA-friendly
/spec-new <feature>  crea la spec de una feature
```

## Los dos plugins

- **flujo-core**: agnostico. El motor completo. Instalable en cualquier repo.
- **flujo-devexpress**: pack de stack (skills por componente XAF/Blazor/XPO + dxdocs + ruteo de bases de datos). Depende del stack; intercambiable por otro pack.
