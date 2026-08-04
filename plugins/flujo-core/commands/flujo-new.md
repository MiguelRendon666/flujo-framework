---
name: flujo-new
description: Crea un proyecto NUEVO desde cero con gobernanza flujo desde el dia uno (greenfield). Toma la idea del proyecto (inline) o un archivo de requerimientos como semilla, planea, guia el scaffold del esqueleto (receta de stack-pack o herramienta nativa), y cablea la gobernanza. Para instalar flujo sobre un proyecto que YA existe, usa /flujo-init. TRIGGER — el usuario quiere arrancar un proyecto nuevo.
disable-model-invocation: true
arguments:
  - name: nombre
    description: "nombre/slug del proyecto nuevo"
  - name: idea
    description: "la idea del proyecto en tus palabras, o el archivo de requerimientos a usar como semilla"
---

# /flujo-new — crear un proyecto desde cero

Greenfield: el proyecto nace con flujo. El core **ORQUESTA** (agnostico); el esqueleto concreto lo hace el **stack-pack** o la **herramienta nativa** — el core nunca asume el stack.

## Frontera
- Es para un proyecto **NUEVO** (carpeta vacia o casi). Si ya hay un proyecto establecido -> usa `/flujo-init`, no esto.
- La **semilla** es la **idea inline** o un **archivo de requerimientos** que el usuario indique; de ahi arranca la planeacion.

## Pasos
0. **Repo:** si no es un repo git, ofrecer `git init`.
1. **Planear primero (desde la idea/requerimientos):**
   - `brainstorming` socratico + `arch` -> objetivo real, **stack elegido por el usuario** (nunca asumido), arquitectura, estructura.
   - `constitution.md` es **opcional** aqui: se puede ir llenando despues; no bloquea el scaffold.
2. **Scaffold del esqueleto (GUIADO):**
   - Si hay un **stack-pack con receta** -> usarla.
   - Si no -> **INDICAR al usuario el comando nativo a correr** (`dotnet new ...`, `npm create ...`, etc.) segun el stack elegido, y esperar. El core **no ejecuta creacion stack-especifica a ciegas**.
   - El esqueleto incluye: estructura del stack, un **proyecto de pruebas**, y (si hay UI) un **archivo de tema**.
3. **Cablear la gobernanza:** correr `/flujo-init` sobre lo recien creado. Ahora `requirePaths`/`testing.project`/`themeSource` se **pueblan de verdad** (los acabamos de crear), no vacios.
4. **Primera feature (opcional):** arrancar con `/workflow-plan <la idea o el primer hito>`.

## Que crea el core vs el stack-pack
- **Core (universal):** `git init`, `.gitignore`, README, `docs/` + `constitution.md`, `specs/`, `flujo.json`/`gauntlet.json`/`dod.json`, `.editorconfig`, CI, `.claude/` hooks.
- **Stack-pack / nativo:** solucion/estructura, proyecto de pruebas real, tema, build.

## Reglas
- Agnostico: nunca asumas el stack; el usuario lo elige.
- No ejecutes scaffold stack-especifico a ciegas: usa receta de pack o guia al nativo.
- `constitution.md` opcional; la idea/requerimientos es la semilla.
- Proyecto existente -> `/flujo-init`, no esto.
