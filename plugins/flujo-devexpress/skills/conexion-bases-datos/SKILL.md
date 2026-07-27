---
name: conexion-bases-datos
description: Decide qué MCP usar para tocar una base de datos real — postgres-db-malia-dev (Postgres del proyecto principal, fijo) vs dbhub (SQL Server / MySQL / MariaDB / SQLite: sitios SoftRestaurant12/Moksha ya configurados + source "adhoc" para conexiones temporales). Usar ANTES de ejecutar cualquier SQL contra una base de datos, o cuando el usuario pide validar/explorar datos, esquemas o resultados contra una base real. TRIGGER — mención de SQL Server, MySQL, MariaDB, SQLite, SoftRestaurant, Moksha, "conéctate a", "consulta la base", "valida contra datos reales" cuando la base no es la Postgres de desarrollo del proyecto.
---

# Conexión a bases de datos — qué MCP usar

## Postgres del proyecto (`postgres-db-malia-dev`)
- Conexión **fija**, ya apuntada a `xafgrupomalia_analytics_des` en `xafdbcorporativo02.gruporeyes.org`.
- Usar siempre que la tarea sea sobre el proyecto `ReporteriaGrupoMalia` (XPO/XAF, esquema conocido).
- No requiere configuración: es la base de datos de desarrollo del dominio de la app.

## Cualquier otra base NO-Postgres (`dbhub`)
Motor soportado: SQL Server, MySQL, MariaDB, SQLite. `dbhub.toml` vive en `C:\Users\Pablninn18\.claude\mcp-servers\dbhub\dbhub.toml`.

### Sitios SoftRestaurant12 / Moksha — ya configurados, solo lectura
Cada source expone dos tools: `execute_sql_<id>` y `search_objects_<id>` (readonly, max_rows 1000).

| id | Sitio | Host | Base |
|---|---|---|---|
| `orangire` | Orangire | 172.21.14.4:1433 | softrestaurant12 |
| `recinto` | Recinto | 172.21.48.4:999 | softrestaurant12 |
| `hotelvillaseca` | Hotel Villaseca | 172.21.60.4:999 | softrestaurant12 |
| `caffito` | Caffito (instancia NATIONALSOFT) | 172.22.58.4 | softrestaurant12 |
| `krallar` | Krallar (instancia SOFTRESTAURANT) | 172.21.65.2 | softrestaurant12 |
| `caminoviejo` | Camino Viejo | 172.24.19.9:999 | softrestaurant12 |
| `moksha` | Moksha | 172.21.14.4:1433 | moksha12 |

Ejemplo: para consultar Orangire, usar el tool `search_objects_orangire` o `execute_sql_orangire`.

### Cualquier otra base no listada (`adhoc`) — conexión temporal
**No existe un tool que reciba el DSN como parámetro por llamada.** dbhub resuelve la conexión desde `dbhub.toml` al arrancar o al recargar el archivo (hot reload, ~500ms, sin reiniciar el proceso MCP para conexiones — ver limitación de tool-list abajo). Patrón:

1. Editar `dbhub.toml` — cambiar el campo `dsn` (o los campos individuales `host`/`user`/`password`/etc.) del source `adhoc` a la conexión relevante para la tarea actual.
2. dbhub detecta el cambio y reconecta solo.
3. Ejecutar `execute_sql_adhoc` / `search_objects_adhoc`.
4. Al terminar, devolver el `dsn` de `adhoc` a `sqlite:///:memory:` (valor inerte) para no dejar credenciales reales en reposo.

**Passwords con caracteres especiales (`@`, `:`, etc.):** no usar el string DSN (`sqlserver://user:pass@host...`) porque requiere URL-encoding. Usar los campos individuales (`type`, `host`, `port`, `database`, `user`, `password`) como en los sources SoftRestaurant — evita encoding y es como están configurados todos los sources reales de este archivo.

## Instalación — local persistente, no `npx @latest`
El MCP está registrado apuntando a un install local en `C:\Users\Pablninn18\.claude\mcp-servers\dbhub\node_modules\@bytebase\dbhub`, **no** a `npx -y @bytebase/dbhub@latest`.

**Por qué:** el install efímero de `npx` (resuelve dependencias en un caché temporal en cada arranque) falló en cargar el conector de SQL Server — log de arranque: `Skipping SQL Server connector: required dependency "@typespec/ts-http-runtime/internal/logger" not installed`. Un `npm install @bytebase/dbhub@latest` persistente en esa carpeta sí resolvió la dependencia completa (probablemente un fallo transitorio de resolución bajo Netskope, mismo patrón que bloquea `uvx`/PyPI).

**Actualizar dbhub:** `cd` a esa carpeta y correr `npm install @bytebase/dbhub@latest` de nuevo — no se autoactualiza.

## Limitaciones de dbhub — no negociables
- **Los sitios SoftRestaurant12/Moksha corren sin TLS (`sslmode = "disable"`).** Verificado en vivo contra `orangire`: con `sslmode = "require"` el handshake TLS falla (`ssl_choose_client_version: unsupported protocol` — el SQL Server de esos sitios solo soporta un stack TLS que el OpenSSL moderno de Node ya no negocia, ni bajando `--tls-min-v1.0`). El ADO.NET original conectaba cifrado porque usa Schannel de Windows, más permisivo; el driver puro-JS de dbhub (`tedious`) no. Consecuencia real: el tráfico hacia esos 7 hosts va en texto plano — aceptable solo porque son IPs internas (172.21.x/172.22.x/172.24.x), nunca exponer estos sources vía `--transport http` con bind distinto a loopback.
- **Sin autenticación integrada de Windows/SSPI para SQL Server.** `tedious` no soporta Kerberos. `authentication=ntlm` igual exige usuario y password explícitos — no es trusted connection.
- **Los DSN/passwords quedan en texto plano** en `dbhub.toml` — no es un secreto gestionado. Nunca commitear ese archivo ni copiar su contenido a un repo o a un mensaje que vaya a un sistema externo (Wrike, Slack, etc.).
- **`readonly = true` fijado por diseño** en todos los `execute_sql_*` (doble capa: clasificador de keywords + modo read-only a nivel de motor). Para necesitar escritura real contra una base externa, evaluar explícitamente con el usuario antes de cambiarlo — no relajar este guardrail por iniciativa propia. Son bases de producción de puntos de venta reales.
- **Hot reload en modo stdio actualiza conexiones, pero no la lista de tools.** Si se agrega/quita un `[[sources]]` o `[[tools]]` al TOML, hace falta reiniciar la sesión de Claude Code (o reconectar el MCP) para que los tools nuevos aparezcan — los cambios de `dsn`/credenciales de un source ya existente (como el patrón `adhoc`) sí aplican sin reiniciar.
- **`lazy = true` en los 7 sources SoftRestaurant/Moksha** — no se conectan al arrancar dbhub, solo al primer query. Un error de red/credencial en esos sitios aparece en la respuesta del tool, no en el log de arranque.
- **Requiere Node.js ≥ 22.5.0** (confirmado instalado: v22.21.0).
- No reemplaza a `postgres-db-malia-dev` para el dominio del proyecto — usar Postgres para todo lo que sea `ReporteriaGrupoMalia`.
