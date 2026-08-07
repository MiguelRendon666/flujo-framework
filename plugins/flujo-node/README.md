# flujo-node

Pack de **lenguaje** Node/TypeScript. Espejo de `flujo-dotnet`: aporta `gauntlet.json`, CI (`quality-gate.yml`), el fragmento `[*.{js,ts,jsx,tsx,vue}]` de `.editorconfig`, los permisos de `Bash(npm/npx ...)`, la lista de extensiones de código (`.js/.ts/.jsx/.tsx/.vue`) y el snippet de la sección "Stack" de `CLAUDE.md`.

## Contenido

- **templates/gauntlet.json** — 11 etapas con comandos npm/npx (tsc, prettier, vitest, playwright, cucumber-js, stryker). `arch`/`integration`/`e2e` vienen `enabled:false` por defecto, igual que en `flujo-dotnet` — no es una limitación de Node, es el mismo default universal en ambos packs porque exigen infraestructura de pruebas que ningún template puede asumir.
- **templates/stryker-config.json** — schema real de Stryker JS (`mutate`, `testRunner: vitest`, `packageManager`). Mutation testing es **obligatorio** cuando `flujo.json > testing.enabled = true` (bloqueo duro, igual que en `flujo-dotnet` — Stryker es nativamente multi-lenguaje, no se trata distinto por stack).
- **templates/vitest.config.ts** — config base del test runner (no existía ningún equivalente antes de este pack).
- **templates/ci/quality-gate.yml** — pipeline con `setup-node`.
- **templates/editorconfig.snippet**, **templates/settings.snippet.json**, **templates/codeExtensions.json**, **templates/CLAUDE.stack.md** — fragmentos que `/flujo-init` fusiona en los archivos del proyecto.

## Uso

Se instala junto a `flujo-core`, en vez de `flujo-dotnet`, para proyectos JS/TS (Vue, React, Tauri, backend Node puro). Es la base sobre la que un futuro pack de framework (`flujo-vue`, `flujo-react`) agregaría skills de componentes, igual que `flujo-devexpress` lo hace sobre `flujo-dotnet`.

## Requisito

Node.js instalado (las etapas corren vía `npx`). Si el proyecto no tiene `prettier` configurado, `/flujo-init` te avisa y puedes optar por instalarlo o apagar la etapa `format`.
