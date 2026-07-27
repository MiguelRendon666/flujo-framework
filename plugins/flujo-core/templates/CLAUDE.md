# Instrucciones del agente

Este proyecto usa el framework **Flujo**. El flujo detallado y las reglas viven en skills; aqui solo lo esencial.

## Contexto

Principios en @docs/constitution.md. Mapa del sistema en @docs/ARCHITECTURE.md.

## Flujo obligatorio

Tarea no trivial (>1 archivo o >15 lineas netas, decision de arquitectura, ambiguedad, o algo nuevo) → invocar la skill `flujo` antes de tocar nada. "Done" = gates del `dod.json` en verde con evidencia mostrada, no la palabra "listo" (lo verifica el Stop hook).

## Comentarios

Tolerancia cero. Regla en @.claude/rules/comentarios.md, aplicada de forma determinista por el hook `scan-comments`.

## Stack

<completar: lenguaje, framework, ORM, base de datos, convenciones propias del equipo>
