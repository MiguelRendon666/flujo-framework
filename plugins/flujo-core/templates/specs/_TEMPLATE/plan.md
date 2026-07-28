# Plan — <feature>

> COMO. Referencia a `spec.md`; no repite el QUE. **Regla dura: sin placeholders** — prohibido "TBD", "manejar errores apropiadamente", "similar a la tarea N", o pasos sin detalle concreto. Si no sabes el detalle, no es un plan todavia.

## Enfoque

<arquitectura de la solucion, la mas simple que resuelve el problema real>

## Componentes afectados

<clases/modulos a tocar; reuso identificado via codebase-memory antes de crear>

## Decisiones y restricciones

<decisiones significativas (extraer a ADR con /adr-new); constraints globales que gobiernan todas las tareas>

## Riesgos

<lo que puede salir mal y como se mitiga>

## Autorevision del plan (antes de implementar)

- [ ] **Cobertura spec -> tarea**: cada criterio de aceptacion de `spec.md` tiene al menos una tarea en `tasks.md`. Gaps marcados explicitamente.
- [ ] **Sin placeholders** ni lenguaje vago en ninguna tarea.
- [ ] **Conflict scan**: ninguna tarea se contradice con otra ni con las decisiones/restricciones de arriba. Si hay conflicto -> una sola pregunta al humano ("¿cual gobierna?"), no lo resuelvas por tu cuenta.
- [ ] **Sobriedad (YAGNI)**: nada que no haga falta; reuso antes de crear.
