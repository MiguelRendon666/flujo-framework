---
name: flujo-init
description: Materializa la capa de proyecto de Flujo (docs/, specs/, .claude, gauntlet.json, dod.json, CI) en el repo actual, de forma idempotente y reutilizando lo que ya exista. Al terminar indica al usuario que archivos debe rellenar y donde.
disable-model-invocation: true
---

# /flujo-init — inicializar el proyecto

Materializa la capa de proyecto desde `${CLAUDE_PLUGIN_ROOT}/templates/` hacia `${CLAUDE_PROJECT_DIR}`. Es idempotente: no sobrescribe contenido del usuario.

## Pasos

1. **Inventariar lo existente** en el repo: `docs/`, `specs/`, `.claude/`, `CLAUDE.md`, `gauntlet.json`, `dod.json`, `.editorconfig`, CI. Nunca borrar; si algo ya existe, conservarlo.
2. **Copiar los scripts de hook**: de `${CLAUDE_PLUGIN_ROOT}/scripts/*.ps1` a `<repo>/.claude/flujo-hooks/`. Se **versionan en git** y son lo que ejecutan los hooks de `settings.json`. (Razon: la entrega de hooks via el `hooks.json` del plugin no es fiable en todos los Claude Code; via `settings.json` + scripts locales del proyecto si, porque settings es file-watched.)
3. **Copiar solo lo que falte** desde `templates/`:
   - `.claude/settings.json` (si existe, hacer **merge**: añadir `enabledPlugins`, `extraKnownMarketplaces` y el bloque `hooks` —que apunta a `${CLAUDE_PROJECT_DIR}/.claude/flujo-hooks/*.ps1`— sin pisar permisos del equipo).
   - `.claude/rules/comentarios.md`, `CLAUDE.md`, `docs/**`, `specs/_TEMPLATE/`, `flujo.json`, `gauntlet.json`, `dod.json`, `stryker-config.json`, `.editorconfig`, `ci/quality-gate.yml` → `.github/workflows/`.
   - `.gitignore`: añadir `.claude/settings.local.json`, `.claude/.dod-state.json`, `.claude/.active-feature`, `.claude/.task-mode` si no estan.
4. **Reutilizar/reorganizar documentacion previa** (Responsabilidad 9): si el repo ya tiene docs sueltas, moverlas a `docs/_inbox/` para que `/docs-rewrite` las procese despues; nunca eliminar sin dejar traza.
5. **Ajustar los manifiestos**:
   - `gauntlet.json`: verificar que los comandos del stack (`dotnet ...`) apuntan a proyectos reales; si no existen, dejar la etapa `enabled: false` y avisarlo.
   - `flujo.json` → `specGuard.requirePaths`: **detectar la estructura de dominio del repo** (carpetas de business objects/controllers, proyecto de modulo, etc.) y **PROPONER** al usuario una lista de globs; escribirla tras su OK. No dejarla vacia en silencio; si el usuario no aprueba ninguna, avisar que spec-guard no enforzara dominio hasta configurarla.
   - `flujo.json` → `testing`: **buscar el proyecto de pruebas del repo** (por convencion, un proyecto/carpeta cuyo nombre incluya Test/Tests/spec). Si hay candidatos, PROPONERLOS y escribir `testing.project` tras el OK. Si no se encuentra: avisar y preguntar — (a) el usuario indica el nombre, (b) sugerir crear un proyecto de pruebas, o (c) apagar el switch (`testing.enabled=false`) advirtiendo que sin proyecto de pruebas no habra unit tests. El switch se decide aqui, informado; no se apaga en silencio.
   - `flujo.json` → `style` (opt-in theme-first): si el proyecto tiene capa de UI/estilos, preguntar si activar el muro theme-first (`style.enabled`), con explicacion: bloquea valores de identidad visual quemados (colores, tamanos, radios, fuentes...) para que TODO salga de tokens del tema. Si se activa: pedir `style.themeSource` (donde viven los tokens; definido por el usuario, como el proyecto de pruebas) y `style.vendorExempt` (patrones de estilos de vendor que el usuario NO controla, ej. XAF, que quedan intocables). Si no hay UI, dejar `style.enabled=false`.
   - `flujo.json` → `testing.bdd` (opt-in ejecucion BDD): los escenarios Gherkin (`.feature`) siempre se escriben (documentacion). Ejecutarlos como prueba de aceptacion es OPCIONAL. Antes de preguntar, **da una explicacion amplia** (que no todos entienden BDD): QUE REQUIERE (proyecto de pruebas + runner BDD + step definitions = codigo-pegamento por escenario, crece con el numero); A QUE AFECTA (agrega etapa de bloqueo duro; cada flujo pedira sus step definitions); COMO BENEFICIA (verifica end-to-end, atrapa fallas de integracion que las unitarias no ven; los escenarios son doc viva Y prueba; ahorra tokens); COMO PERJUDICA (costo de montaje/mantenimiento; en proyectos chicos puede ser sobre-ingenieria; mal escrita es lenta y fragil). Recomendar encenderla si hay flujos de negocio importantes end-to-end; dejarla apagada si basta unitarias+Stryker. Aclarar: apagarla NO apaga la escritura de escenarios.
6. **Imprimir la guia de llenado** (lo mas importante):

```
Flujo inicializado. Rellena, en este orden:
  1. docs/constitution.md   <- principios del proyecto (obligatorio)
  2. docs/_inbox/           <- tira aqui tus notas informales, sin formato
Luego ejecuta:  /docs-rewrite
  -> convierte _inbox en documentacion IA-friendly (Diataxis + ADR) sin perder tus ideas.
Para una feature nueva:  /spec-new <slug>
```

## Reglas

- Idempotente: correrlo dos veces no cambia nada nuevo.
- Never sobrescribir `CLAUDE.md`, `constitution.md` ni docs del usuario con contenido ya presente.
- Never eliminar informacion existente sin justificarlo y sin moverla a `_inbox/` o dejar cross-ref.
