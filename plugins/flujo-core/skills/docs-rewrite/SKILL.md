---
name: docs-rewrite
description: Transforma documentacion informal del usuario en documentacion estructurada IA-friendly sin inventar ni perder ideas. Recorre docs del proyecto, valida contra el codigo, detecta contradicciones/duplicidad/obsolescencia, pregunta ante ambiguedad, reorganiza segun Diataxis, mantiene referencias cruzadas y extrae decisiones a ADRs. TRIGGER — el usuario dejo notas en docs/_inbox/, pide ordenar/reescribir la documentacion, o el gauntlet corre `docs-rewrite --check`. Modo --check es read-only para CI.
arguments:
  - name: mode
    description: "vacio = reescritura interactiva; --check = read-only, reporta drift, no escribe ni pregunta"
---

# docs-rewrite — documentacion IA-friendly

## Invariantes (no negociables)

1. **Nunca inventa.** Ninguna afirmacion llega a la salida sin anchor VERIFIED (existe en codigo) o USER-ASSERTED (viene del usuario). Sin anchor → se marca, no se escribe.
2. **Nunca borra sin traza.** Toda eliminacion → cross-ref o marca DEPRECATED; el original queda en git.
3. **Pregunta, no adivina.** Ambiguedad bloqueante → una tanda batcheada de preguntas.
4. **Identidad estable.** IDs y numeros de ADR no cambian entre corridas.
5. **Idempotente.** Sin cambios en codigo/docs → cero diff.
6. **Preserva la idea del usuario.** USER-ASSERTED se reformatea, jamas se descarta.

## Estados de anchor

| Estado | Significado | Accion |
|---|---|---|
| VERIFIED | El simbolo/ruta/tabla citado existe en el codigo | Escribir; sellar last_verified |
| USER-ASSERTED | Viene de _inbox (intencion/rationale) | Escribir como explanation/decision, source: user |
| STALE | Citaba un simbolo que ya no existe | Marca DEPRECATED, confirmar antes de quitar |
| UNSUPPORTED | Ni codigo ni usuario | No escribir; reportar |
| CONFLICT | Usuario dice X, codigo muestra Y | No decidir; a la tanda de preguntas |

Resolucion en cascada barata: codebase-memory → Serena/LSP → grep. Nunca cargar archivos completos.

## Pipeline

0. Inventario (glob): docs/**, _inbox/**, README, CLAUDE.md. Excluir .feature (Reqnroll), ADR accepted (inmutables), CHANGELOG.
1. Atomizar: partir en unidades; etiquetar tipo y simbolos citados.
2. Anchor: resolver estado de cada unidad.
3. Conflictos: contradiccion / duplicidad (una copia canonica + cross-ref) / obsolescencia.
4. Clasificar Diataxis: tutorial | how-to | reference | explanation; dividir docs mixtos.
5. Preguntar: una sola ronda con opciones concretas.
6. Reescribir: front-matter estable + secciones atomicas; extraer decisiones via `/adr-new`; actualizar ARCHITECTURE.md.
7. Cross-refs: reconstruir enlaces, IDs estables, sin rotos.
8. Reporte + vaciar _inbox solo de lo ya procesado.

## Front-matter IA-friendly

```yaml
---
id: ref-slug-estable
title: Titulo
type: reference
status: current
source: both
last_verified: 2026-01-01
symbols: [ClaseA, MetodoB]
related: [adr-0007, how-to-x]
---
```

## Modo --check (gauntlet/CI)

Read-only, no interactivo, no escribe, no pregunta. Emite reporte de drift; exit ≠0 si hay anchors STALE (drift duro).
