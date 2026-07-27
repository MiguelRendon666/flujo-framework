# flujo-devexpress

Pack de stack DevExpress XAF/Blazor/XPO. Depende del stack; intercambiable por otro pack sin tocar `flujo-core`.

## Contenido

- **skills**: 23 skills por componente (`devexpress-xaf-*`, `devexpress-blazor-*`) + `conexion-bases-datos` (ruteo de que MCP de datos usar).
- **.mcp.json**: `dxdocs` (documentacion DevExpress via HTTP).

## Uso

Se instala junto a `flujo-core`. La Fase 5 del `flujo` (implementar) consulta la skill del componente tocado antes de escribir codigo custom.
