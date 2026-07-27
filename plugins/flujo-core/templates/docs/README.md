# Documentacion

Estructura Diataxis: cada archivo pertenece a **un solo** modo. No mezclar.

| Carpeta | Modo | Orientacion |
|---|---|---|
| `tutorials/` | Tutorial | Aprender de la mano (onboarding) |
| `how-to/` | How-to | Resolver una tarea concreta |
| `reference/` | Reference | Descripcion sistematica (API, config, esquema) |
| `explanation/` | Explanation | Por que, trade-offs, contexto |

Otras carpetas:
- `_inbox/` — buzon de notas informales; `/docs-rewrite` las procesa a los 4 modos.
- `adr/` — Architecture Decision Records (MADR), inmutables.
- `architecture/` — diagramas C4 (Mermaid).

Las specs ejecutables (`.feature` Gherkin) viven en `specs/`, no aqui.
