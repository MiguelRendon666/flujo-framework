---
paths: ["**/*.cs", "**/*.razor", "**/*.sql", "**/*.css", "**/*.scss", "**/*.ps1"]
---

# Comentarios — tolerancia cero

Prohibido: bloques multi-linea (`/* */`, `/** */`, `//` en 2+ lineas seguidas, `@* *@` multi-linea), comentarios que explican QUE hace el codigo, breadcrumbs de IA (`// Added for X`), tono narrativo, redundancia con el nombre del simbolo, separadores decorativos y `#region`.

Unico permitido: 1 linea con WHY no inferible del codigo. Si el WHY es deducible → silencio.

XML docs (C# `///`): max 3 lineas, solo en APIs publicas de libreria o interfaces de contrato.

El hook `scan-comments` bloquea las violaciones antes de escribir.
