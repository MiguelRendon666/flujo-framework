---
name: spec-new
description: Crea la carpeta specs/<feature>/ con spec.md (QUE + POR QUE), plan.md (COMO), tasks.md (tareas) y un .feature Gherkin, a partir de la plantilla. Marca la feature como activa para el Gate de tareas del DoD. TRIGGER — inicio de una feature nueva, o cuando el Gate 1 readiness pide una spec antes de implementar.
disable-model-invocation: true
arguments:
  - name: feature
    description: "slug de la feature en kebab-case"
---

# spec-new — nueva especificacion

Crea `specs/<feature>/` copiando `specs/_TEMPLATE/`:

- `spec.md` — QUE se quiere y POR QUE (frontera dura, no el como). Criterios de aceptacion.
- `plan.md` — COMO: arquitectura, stack, decisiones. Referencia a spec.md.
- `tasks.md` — tareas numeradas `- [ ]`, derivadas de plan.md.
- `<feature>.feature` — Gherkin: escenarios Given/When/Then = doc viva + test BDD (Reqnroll).

Tras crear, escribe el slug en `.claude/.active-feature` para que el DoD verifique las tareas de esta feature.

## Reglas

- La frontera QUE/COMO/TAREAS no se mezcla (spec no lleva codigo; plan no repite el que).
- spec.md debe existir antes de implementar (Gate 1 readiness).
- Los escenarios .feature son la fuente de verdad del comportamiento; el gauntlet los ejecuta.
