---
status: accepted
date: 2026-07-27
deciders: [equipo]
---

# 0001. Adoptar el framework Flujo

## Context and Problem Statement

El desarrollo asistido por IA producia resultados inconsistentes: no habia enforcement de calidad antes de dar una tarea por terminada, la documentacion se desincronizaba del codigo y las reglas vivian dispersas.

## Considered Options

- Reglas solo en CLAUDE.md (advisory).
- Framework Flujo: enforcement determinista via hooks + guantelete + DoD.

## Decision Outcome

Elegida: **Flujo**, porque CLAUDE.md es contexto y no fuerza nada; los hooks son la unica capa determinista que impide reportar "done" con verificaciones pendientes.

### Consequences

- Positiva: gates ejecutables, docs IA-friendly, un unico punto de aceptacion.
- Negativa: friccion inicial de configuracion; requiere mantener el manifiesto del guantelete.
- Neutral: dependencia del marketplace del framework.
