---
name: brainstorming
description: Convierte una idea cruda en un diseno aprobado por el humano ANTES de escribir codigo. Preguntas socraticas de una en una, 2-3 enfoques con trade-offs, aprobacion del diseno seccion por seccion, y escribe specs/<feature>/design.md. Gate duro: no implementar ni hacer scaffold hasta que el humano apruebe. TRIGGER — inicio de una feature o cambio no trivial sin diseno acordado; antecede a /spec-new y al Plan Mode nativo.
---

# brainstorming — de idea a diseno aprobado

Gate previo a cualquier codigo. No implementes, no crees scaffolding, no escribas plan hasta que el humano apruebe el diseno.

## Proceso

1. **Explorar contexto**: archivos, docs y commits recientes relevantes (apoyate en `ctx`).
2. **Preguntas socraticas, de una en una**: proposito, restricciones, criterios de exito. Una pregunta por turno hasta que el objetivo real quede articulado — no asumas lo que el humano "quiso decir".
3. **Reto de sobriedad (escalera anti-sobreingenieria)**: antes de proponer, aplica la escalera del `flujo` — ¿hace falta? ¿ya existe y se reusa? ¿lo resuelve stdlib/framework/dependencia? Descarta lo que no aporte.
4. **Proponer 2-3 enfoques** con trade-offs concretos y una recomendacion (usa `arch` si hay ≥5 componentes).
5. **Presentar el diseno por secciones**, ordenadas por complejidad (de 1 frase a ≤300 palabras). **Pedir aprobacion tras cada seccion**, no un OK global.
6. **Escribir el design doc** en `specs/<feature>/design.md` (con fecha en el frontmatter) y sugerir commitearlo.
7. **Self-review del diseno**: escanea placeholders, contradicciones, ambiguedad y scope antes de cerrar.
8. **Transicion**: solo con el diseno aprobado → `/spec-new <feature>` (spec/plan/tasks) y luego el plan.

## Reglas

- **No codigo antes de aprobacion.** Este es el punto que Superpowers acierta y que el framework necesitaba.
- Combina dos ejes: completitud (que no falte nada) **y** sobriedad (que no sobre nada). No sacrifiques uno por el otro.
- Antecede al Plan Mode nativo de Claude Code: brainstorming acuerda el QUE/diseno; Plan Mode o `/spec-new` estructuran el COMO.
