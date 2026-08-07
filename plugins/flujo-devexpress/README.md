# flujo-devexpress

Pack de **framework** DevExpress XAF/Blazor/XPO. Se instala **encima de `flujo-dotnet`** (el pack de lenguaje .NET aporta el `gauntlet.json`/CI/editorconfig; este pack solo aporta skills de componentes). Intercambiable por otro pack de framework sin tocar `flujo-core` ni `flujo-dotnet`.

## Contenido

- **skills**: 23 skills por componente (`devexpress-xaf-*`, `devexpress-blazor-*`).
- **.mcp.json**: `dxdocs` (documentacion DevExpress via HTTP).

## Requiere

`flujo-dotnet` instalado — este pack no trae `gauntlet.json`/CI/`.editorconfig` propios, siempre dependio del pack de lenguaje para eso.

## Uso

Se instala junto a `flujo-core` + `flujo-dotnet`. La Fase 5 del `flujo` (implementar) consulta la skill del componente tocado antes de escribir codigo custom.

## Nota

La skill `conexion-bases-datos` (ruteo de MCP de datos a servidores internos de un cliente especifico) se retiro de este pack: no era XAF ni .NET, era infraestructura privada que no debe vivir en un plugin de marketplace. Si la necesitas, mantenla como config local no versionada de tu proyecto.
