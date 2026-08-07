# flujo-dotnet

Pack de **lenguaje** .NET. Aporta lo que `flujo-core` ya no trae por default: `gauntlet.json`, CI (`quality-gate.yml`), el fragmento `[*.cs]` de `.editorconfig`, los permisos de `Bash(dotnet ...)`, la lista de extensiones de código (`.cs/.razor/.csproj/.props/.targets`) y el snippet de la sección "Stack" de `CLAUDE.md`.

## Contenido

- **templates/gauntlet.json** — 11 etapas con comandos `dotnet` (build/format/test/stryker). `arch`/`integration`/`e2e` vienen `enabled:false` por defecto (requieren infraestructura de pruebas que el pack no puede asumir); las demás vienen encendidas.
- **templates/stryker-config.json** — schema de Stryker.NET. Mutation testing es **obligatorio** cuando `flujo.json > testing.enabled = true` (bloqueo duro, no informativo).
- **templates/ci/quality-gate.yml** — pipeline con `setup-dotnet`.
- **templates/editorconfig.snippet**, **templates/settings.snippet.json**, **templates/codeExtensions.json**, **templates/CLAUDE.stack.md** — fragmentos que `/flujo-init` fusiona en los archivos del proyecto.

## Uso

Se instala junto a `flujo-core`. Es el pack de lenguaje que consumen los packs de framework — hoy `flujo-devexpress` (XAF/Blazor). `/flujo-init` detecta que está habilitado y copia estos templates en vez de generar un gauntlet vacío.

## Requisito

.NET SDK instalado (las etapas `build`/`format`/`test`/`stryker` corren vía `dotnet`/`dotnet stryker`).
