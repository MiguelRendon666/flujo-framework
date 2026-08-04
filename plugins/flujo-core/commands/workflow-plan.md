---
name: workflow-plan
description: De una historia cruda del usuario a un plan ejecutable por hitos. Investiga (codigo + web), verifica impacto cross-flow, propone 2-3 opciones y construye el plan INCREMENTALMENTE: cada hito pasa su revision de diseno antes de escribirse al MD. Escala la ceremonia al tamano (trivial->directo, task->ligero, grande->deep-plan). TRIGGER — el usuario describe QUE quiere lograr (una historia/necesidad), no una solucion ya hecha. NOTA: se llama workflow-plan (NO plan) para no colisionar con el Plan Mode NATIVO de Claude Code.
disable-model-invocation: true
arguments:
  - name: historia
    description: "la necesidad/historia del usuario, en sus palabras"
---

# /workflow-plan — de historia cruda a plan por hitos

Produce `specs/<feature>/{spec.md, design.md, plan.md}`. El corazon: **cada hito pasa su revision de diseno ANTES de entrar al `plan.md`**.

> **El comando es `/workflow-plan`, NO `/plan`.** `/plan` es el Plan Mode NATIVO de Claude Code y NO ejecuta esta gobernanza: su aprobacion de ExitPlanMode dice "you can now start coding" y eso NO es autorizacion dentro de flujo. Usa siempre `/workflow-plan`.

## FRONTERA DURA (mode-guard) — leelo primero
`/workflow-plan` corre en **modo `plan` (NO-editable)**. El hook `readiness` fija `.claude/.task-mode=plan` y el `spec-guard` **NIEGA toda edicion de codigo** (`.cs/.razor/.css/.scss/.js/.ts/.sql/.csproj/.props/.targets`) mientras dure. **Tu unico entregable es documentacion** (`.md`/`.feature`): `spec.md`, `design.md`, `plan.md`, ADRs.

- **NUNCA implementes.** No escribas codigo, no despaches subagentes de implementacion (coder/A-malIA/etc.), no corras builds "para probar".
- **NUNCA cambies el modo por tu cuenta.** El plan termina cuando el `plan.md` esta completo. Ahi **PARAS**.
- Al cerrar, **INDICA al usuario que ejecute `/flujo-implement`** para arrancar la ejecucion. Solo el usuario lo corre; al hacerlo, el hook cambia el modo automaticamente. Tu nunca lo disparas ni cambias `.task-mode` a mano.
- Si crees que hace falta tocar codigo para validar algo: **dilo en el plan como paso pendiente**, no lo hagas.

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

## 3.1 Deuda tecnica (informativa, NO bloqueante)
Corre el skill `tech-debt` sobre los flujos/areas que el plan va a TOCAR e incluye sus hallazgos como seccion **informativa** del `plan.md`. Es enforcement **NO obligatorio**: surface la deuda relevante para que el usuario decida si la paga como parte del plan (agregando hitos) o la ignora. **Nunca bloquea la planeacion.**

## 4. Propon (cuestiona, no aceptes a ciegas)
- **brainstorming** socratico: preguntas de una en una hasta articular el objetivo real (no el asumido).
- **arch**: 2-3 opciones con trade-offs concretos (respaldadas por research interno + web) + recomendacion.
- **Ponytail**: reta necesidad/tamano de CADA idea, incluidas las del usuario. Aprobacion del diseno por secciones → `design.md`.

## 5. Construye el plan por hitos — INCREMENTAL
Por cada hito, en orden:
1. Redacta: objetivo (entregable), que criterios de `spec.md` cubre, y sus **PASOS** (codigo y no-codigo; skill/mcp/tool por paso). **El penultimo paso SIEMPRE es "pruebas unitarias"** (generar/actualizar con `test-gen`, solo codigo de logica, respeta exenciones) y **el ultimo SIEMPRE es doc-check** (via `docs-rewrite`).
2. Define el **guantelete del hito** (que stages/tests lo validan en ejecucion).
3. **Revision de diseno del hito (checklist):**
   - [ ] los pasos cubren el objetivo del hito
   - [ ] sin placeholders ni vaguedad ("TBD", "manejar errores", "similar a...")
   - [ ] no choca con otros flujos (cross-flow verificado)
   - [ ] incluye el paso doc-check
   - [ ] dependencias entre pasos/hitos coherentes
   - [ ] guantelete del hito definido y verificable
   - [ ] **cada paso trae su FUENTE** (`archivo:linea` / query / doc) **y su PORQUE**
   - [ ] **cada decision lista la opcion elegida Y las descartadas + razon**
   - [ ] **toda afirmacion ancla a evidencia real**; si no se pudo verificar, se marca `supuesto — verificar` (nunca se da por hecho)
   Hito grande/riesgoso → escala esta revision a un **subagente revisor adversarial**.
   > Un plan sourced + justificado (cada linea trazable a su fuente y su porque, con alternativas descartadas) es el estandar: mas efectivo que un plan que solo "se ve bien", porque es auditable y retable.
4. Si pasa → **agregalo al `plan.md`**. Si no → corrige y re-revisa. **Nunca escribas al MD un hito no revisado.**
Siguiente hito.

## 6. Cierre
- `/adr-new` para decisiones significativas.
- El `plan.md` queda listo. **Cierra INDICANDO al usuario:** "Plan completo. Para ejecutarlo, corre `/flujo-implement`." Cada hito ya paso su revision de diseno; el usuario decide cuando arrancar.

## Reglas
- Nunca inventes: todo hallazgo ancla a codigo o a research citado.
- Escala al tamano: no hagas deep-plan de un one-liner.
- El plan MD es el producto de esta fase; se versiona en git.
