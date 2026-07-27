---
name: flujo-init
description: Materializa la capa de proyecto de Flujo (docs/, specs/, .claude, gauntlet.json, dod.json, CI) en el repo actual, de forma idempotente y reutilizando lo que ya exista. Al terminar indica al usuario que archivos debe rellenar y donde.
disable-model-invocation: true
---

# /flujo-init — inicializar el proyecto

Materializa la capa de proyecto desde `${CLAUDE_PLUGIN_ROOT}/templates/` hacia `${CLAUDE_PROJECT_DIR}`. Es idempotente: no sobrescribe contenido del usuario.

## Pasos

1. **Inventariar lo existente** en el repo: `docs/`, `specs/`, `.claude/`, `CLAUDE.md`, `gauntlet.json`, `dod.json`, `.editorconfig`, CI. Nunca borrar; si algo ya existe, conservarlo.
2. **Copiar solo lo que falte** desde `templates/`:
   - `.claude/settings.json` (si existe, hacer merge: añadir `enabledPlugins`, `extraKnownMarketplaces` y el wiring de hooks sin pisar permisos del equipo).
   - `.claude/rules/comentarios.md`, `CLAUDE.md`, `docs/**`, `specs/_TEMPLATE/`, `gauntlet.json`, `dod.json`, `stryker-config.json`, `.editorconfig`, `ci/quality-gate.yml` → `.github/workflows/`.
   - `.gitignore`: añadir `.claude/settings.local.json`, `.claude/.dod-state.json`, `.claude/.active-feature` si no estan.
3. **Reutilizar/reorganizar documentacion previa** (Responsabilidad 9): si el repo ya tiene docs sueltas, moverlas a `docs/_inbox/` para que `/docs-rewrite` las procese despues; nunca eliminar sin dejar traza.
4. **Ajustar el manifiesto**: en `gauntlet.json` verificar que los comandos del stack (`dotnet ...`) apuntan a los proyectos de test reales del repo; si no existen, dejar la etapa `enabled: false` y avisarlo.
5. **Imprimir la guia de llenado** (lo mas importante):

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
