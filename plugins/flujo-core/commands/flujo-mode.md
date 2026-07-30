---
name: flujo-mode
description: Declara explicitamente el tipo de la tarea actual (el modo). Modos NO-editables (plan, document, review) bloquean toda edicion de codigo. Modos editables sin spec (spike, explore, bugfix, chore, implement) permiten editar rutas de dominio sin frenar. `feature` (o sin modo) exige spec en rutas de dominio. `clear` borra el modo.
disable-model-invocation: true
arguments:
  - name: mode
    description: "plan | document | review | spike | explore | bugfix | chore | implement | feature | clear"
---

# /flujo-mode — declarar el tipo de tarea

Este comando fija `.claude/.task-mode`. **El hook `readiness` lo escribe desde tu prompt literal**, no el modelo — asi la transicion es una decision tuya que el agente no puede falsificar (el mode-guard le impide editar el archivo de modo por su cuenta).

## Modos

**NO-editables** — bloquean TODA edicion de codigo (`.cs/.razor/.css/.scss/.js/.ts/.sql/.csproj/.props/.targets`) y de los archivos de control; solo permiten `.md`/`.feature`:
- `plan` — construir el plan (lo fija `/plan` automaticamente).
- `document` — escribir/actualizar documentacion.
- `review` — revisar/auditar sin tocar codigo.

**Editables sin spec** — eximen del spec-guard: puedes editar rutas de dominio sin spec activa:
- `spike`, `explore`, `bugfix`, `chore`, `implement`.

**Editable con spec**:
- `feature` (o sin archivo) → el spec-guard exige spec en `flujo.json > specGuard.requirePaths`.

`clear` elimina el archivo (equivale a `feature`).

## La frontera dura (mode-guard)

Pasar de un modo NO-editable a uno editable **requiere que TU lo declares explicitamente** aqui (o con `/implement`). El agente **nunca** puede hacer esa transicion solo: es tu autorizacion, con traza (el archivo queda). No adivina; tu decides cuando se pasa de planear/documentar/revisar a tocar codigo.
