---
name: flujo
description: Flujo obligatorio de 9 fases + escalera anti-sobreingenieria para desarrollo riguroso en cualquier proyecto. Planificacion (dimensionar contexto + razonamiento estructurado + reto senior + arquitectura), busqueda de contexto en cascada barata, cuestionamiento y reuso, impacto sobre lo establecido, implementacion, auditoria de codigo (solid-guardian), auditoria visual (design-critic), re-chequeo final y verificacion en vivo. TRIGGER — invocar ANTES de tocar nada cuando el cambio no es trivial (>1 archivo o >15 lineas netas), hay decision de arquitectura, ambiguedad de interpretacion, o intencion de crear algo nuevo. SKIP — pregunta informativa que no toca codigo, consulta trivial de una linea, o tooling/meta.
---

# Flujo de trabajo — enforcement por fase

Toda tarea no trivial pasa por estas fases en orden. Cada fase tiene un dueño; no se salta.

| Fase | Dueño | Dispara cuando |
|---|---|---|
| 0. Dimensionar | Skill `ctx` (cuanto contexto hace falta antes de buscar) | Siempre, primero |
| 1. Planificar | Razonamiento estructurado (≥5 componentes) + reto senior (¿la solucion mas simple? ¿ya existe algo reusable?) + skill `arch` (max 2 opciones) | Peticion no trivial |
| 2. Buscar contexto | Cascada barata: codebase-memory (grafo) → Serena/LSP (simbolo) → Grep → Read offset+limit. Alcance incierto → delegar a `Explore` | Antes de escribir codigo |
| 3. Cuestionar y reusar | Escalera anti-sobreingenieria (abajo) | Cualquier propuesta, ambiguedad o intencion de crear algo nuevo |
| 4. Impacto | codebase-memory `trace_path`/`query_graph`; registrar decision via `/adr-new` | Al tocar convencion o codigo legado |
| 5. Implementar | Skills del stack del componente tocado + escalera como lente linea a linea | Al escribir codigo |
| 6. Auditar codigo | Agente `solid-guardian` una vez sobre el conjunto de archivos de la tarea. Excepcion: ≤1 archivo y ≤15 lineas → inline | Al terminar cambios de codigo |
| 7. Auditar diseño/UX | Agente `design-critic` una vez sobre el diff visual. Excepcion: un atributo/clase aislado → inline | Al terminar cambios de markup visual |
| 8. Re-chequear | Releer el diff completo contra lo evaluado en 1/3/5 — ¿sigue siendo el minimo? | Antes de reportar done, si toco >1 archivo |
| 9. Verificar en vivo | Skill `run`/`verify`; el Stop hook corre el guantelete local | UI o comportamiento antes de done |

## Escalera anti-sobreingenieria — parar en el primer si

1. ¿Hace falta que exista? → No: no construirlo (YAGNI).
2. ¿Ya existe en el proyecto? → Reusarlo (codebase-memory para confirmar).
3. ¿Lo resuelve la stdlib del lenguaje? → Usarla.
4. ¿Lo resuelve el framework/stack nativo? → Usarlo (revisar skill del componente antes de custom).
5. ¿Lo resuelve una dependencia ya instalada? → Usarla.
6. ¿Cabe en una linea? → Una linea.
7. Solo entonces: el minimo funcional necesario.

Guardrails que nunca se saltan: validacion en boundaries externos, manejo de perdida de datos, seguridad, accesibilidad.

## Arquitectura — no negociable

- Never abstracciones sin ≥3 casos reales que las justifiquen.
- Never clase con mas de una razon de cambio (SRP estricto).
- Never herencia donde composition resuelve lo mismo.
- Never validar entradas internas de codigo propio — solo boundaries externos.
- Never diseñar para requisitos hipoteticos futuros.

## Economia de tokens (transversal)

Enforcement determinista sobre razonamiento: lo que puede hacer un script/hook no se le pide al modelo. Exploracion en cascada (Fase 2). Auditores devuelven veredicto estructurado con `tools` acotado. Nunca releer un archivo recien editado.

## Definition of Done

"Done" = evidencia mostrada de que los gates del `dod.json` estan en verde, no la palabra "listo". El Stop hook lo verifica de forma determinista.
