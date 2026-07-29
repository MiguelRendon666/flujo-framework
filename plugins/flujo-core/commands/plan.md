---
name: plan
description: De una historia cruda del usuario a un plan ejecutable por hitos. Investiga (codigo + web), verifica impacto cross-flow, propone 2-3 opciones y construye el plan INCREMENTALMENTE: cada hito pasa su revision de diseno antes de escribirse al MD. Escala la ceremonia al tamano (trivial->directo, task->ligero, grande->deep-plan). TRIGGER — el usuario describe QUE quiere lograr (una historia/necesidad), no una solucion ya hecha.
disable-model-invocation: true
arguments:
  - name: historia
    description: "la necesidad/historia del usuario, en sus palabras"
---

# /plan — de historia cruda a plan por hitos

Produce `specs/<feature>/{spec.md, design.md, plan.md}`. El corazon: **cada hito pasa su revision de diseno ANTES de entrar al `plan.md`**.

## 0. Triage (escalera YAGNI)
- **Trivial** (1 linea / cambio obvio) → NO planees; dilo y hazlo directo.
- **Una task** (un importador, un campo) → plan ligero: 1 hito, pasos, sin research web.
- **Grande / reestructura** → deep-plan completo (todo lo de abajo).

## 1. Clasifica
`modify-flow` (modifica un flujo existente) | `add-to-flow` (agrega, posible reestructura) | `new` (nada existe). Define cuanto analisis de codigo hace falta.

## 2. Investiga (delega; llena el research-log)
- **Codigo**: cascada `ctx` → codebase-memory (grafo) → Serena/LSP (simbolos) → Grep → Read acotado.
- **Externo**: context7/dxdocs (docs de stack), fetch (URLs), Explore/`deep-research` (busqueda amplia/multi-fuente).
- Registra cada hallazgo en el research-log del `plan.md`: `pregunta | tool | hallazgo | como informo`.

## 3. Impacto cross-flow
`codebase-memory.trace_path`/`query_graph`: ¿tocar esto rompe otros flujos? Registra en la tabla de impacto; si hay choque, propon mitigacion o replantea antes de seguir.

## 4. Propon (cuestiona, no aceptes a ciegas)
- **brainstorming** socratico: preguntas de una en una hasta articular el objetivo real (no el asumido).
- **arch**: 2-3 opciones con trade-offs concretos (respaldadas por research interno + web) + recomendacion.
- **Ponytail**: reta necesidad/tamano de CADA idea, incluidas las del usuario. Aprobacion del diseno por secciones → `design.md`.

## 5. Construye el plan por hitos — INCREMENTAL
Por cada hito, en orden:
1. Redacta: objetivo (entregable), que criterios de `spec.md` cubre, y sus **PASOS** (codigo y no-codigo; skill/mcp/tool por paso). **El ultimo paso SIEMPRE es doc-check** (revisar/actualizar la doc del flujo via `docs-rewrite`).
2. Define el **guantelete del hito** (que stages/tests lo validan en ejecucion).
3. **Revision de diseno del hito (checklist):**
   - [ ] los pasos cubren el objetivo del hito
   - [ ] sin placeholders ni vaguedad ("TBD", "manejar errores", "similar a...")
   - [ ] no choca con otros flujos (cross-flow verificado)
   - [ ] incluye el paso doc-check
   - [ ] dependencias entre pasos/hitos coherentes
   - [ ] guantelete del hito definido y verificable
   Hito grande/riesgoso → escala esta revision a un **subagente revisor adversarial**.
4. Si pasa → **agregalo al `plan.md`**. Si no → corrige y re-revisa. **Nunca escribas al MD un hito no revisado.**
Siguiente hito.

## 6. Cierre
- `/adr-new` para decisiones significativas.
- El `plan.md` queda listo para `/implement`: cada hito ya paso su revision de diseno.

## Reglas
- Nunca inventes: todo hallazgo ancla a codigo o a research citado.
- Escala al tamano: no hagas deep-plan de un one-liner.
- El plan MD es el producto de esta fase; se versiona en git.
