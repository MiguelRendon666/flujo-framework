---
name: flujo-mode
description: Declara el tipo de la tarea actual para el spec-guard. Modos que eximen de spec (spike, explore, research, bugfix, chore) permiten editar rutas de dominio sin frenar. `feature` (o sin modo) exige spec en rutas de dominio. `clear` borra el modo.
disable-model-invocation: true
arguments:
  - name: mode
    description: "spike | explore | research | bugfix | chore | feature | clear"
---

# /flujo-mode — declarar el tipo de tarea

Escribe el modo recibido en `.claude/.task-mode` (una sola palabra, en minúsculas). Con `clear`, elimina ese archivo.

Efecto sobre el spec-guard:
- `spike`, `explore`, `research`, `bugfix`, `chore` → eximen: puedes editar rutas de dominio sin spec.
- `feature` o sin archivo → el spec-guard exige spec en las rutas de `flujo.json > specGuard.requirePaths`.

Es una declaración explícita de intención, con traza (el archivo queda). No adivina; tú decides si la tarea amerita spec.
