---
name: flujo-implement
description: Ejecuta el plan.md de la feature activa HITO POR HITO. Por cada hito implementa, corre el guantelete del hito, y PARA a pedir permiso con un informe de cambios justificado. NO commitea (los commits son del usuario). NO auto-invocable: solo lo corre el usuario, y correrlo ES su autorizacion explicita para implementar. TRIGGER — el usuario lo ejecuta tras /workflow-plan.
disable-model-invocation: true
---

# /flujo-implement — ejecutar el plan hito por hito

Driver de ejecucion (Paso 2). Toma el `plan.md` de la feature activa y lo ejecuta un hito a la vez. **Reusa lo que ya existe** (agentes `coder`/`solid-guardian`/`design-critic`/`fresh-verifier`, `gauntlet.ps1`, `dod.json`, skill `docs-rewrite`); no reimplementa nada.

## Frontera
- Corre en modo `implement`, que lo fija el hook `readiness` al invocar este comando. **Tu no cambias `.task-mode` a mano.**
- Requiere una feature activa con `specs/<feature>/plan.md`. Si no hay plan: dilo, pide correr `/workflow-plan` primero, y PARA.
- **Nunca commitees.** Los commits son responsabilidad del usuario.

## Regla de alcance (dura)
Ejecutas **UN hito, PARAS, informas y pides permiso**. Jamas encadenas hitos sin autorizacion explicita del usuario entre cada uno. Cada continuacion es una nueva corrida de `/flujo-implement`.

## Loop por hito
Toma el **primer hito pendiente** del `plan.md`. Para ese hito:

1. **Lee del plan:** objetivo, pasos, "Guantelete del hito" y criterio de aceptacion (tal como el `plan.md` ya los define).
2. **Ejecuta los pasos en orden:**
   - Pasos de codigo -> agente `coder`.
   - Pasos de UI/estilo -> respetan `theme-first` (si `style.enabled`): cero valores de identidad quemados, todo del tema; el mini-gauntlet de token antes de crear uno.
   - Pasos no-codigo -> directo.
   - Paso penultimo (pruebas unitarias) -> skill `test-gen` sobre lo que el hito creo/modifico. **Anti-stale:** si el hito MODIFICA un flujo, revisa/actualiza tambien las pruebas existentes de ese flujo Y sus escenarios `.feature` (via `gherkin-gen`), no solo agregas.
   - Ultimo paso (doc-check) -> skill `docs-rewrite` sobre la doc del flujo afectado.
3. **Corre el Guantelete del hito** tal como lo definio el plan:
   - Build/tests -> `gauntlet.ps1` (o los comandos especificos que liste ese hito).
   - Auditoria Fase 6 -> agente `solid-guardian` sobre los archivos de codigo tocados.
   - Auditoria Fase 7 -> agente `design-critic` si el hito toco UI/markup (HTML/CSS/Razor/JSX/Vue SFC, segun el stack).
   - Prioriza el bloqueo mas duro posible: si una etapa no pasa, el hito no avanza.
4. **Reintentos:** si el guantelete falla, corrige y reintenta. Cuenta los intentos; el tope es `maxBlocks` de `dod.json` (8). Al agotarlo -> **handoff**: PARA y reporta el estado al usuario, no sigas.
5. **Freno de mano:** si durante el hito detectas que el enfoque del plan esta mal (un hallazgo que lo invalida, no un bug puntual):
   - `git restore` de los archivos que tocaste en este hito (no hubo commits que revertir).
   - Presenta los hallazgos + 2-3 propuestas de solucion que **hayas pasado por guantelete** antes de proponerlas.
   - PARA y espera la decision del usuario. No avances al siguiente hito.
6. **Hito verde -> informe de cambios:** lista archivo por archivo lo que tocaste, cada cambio con su **justificacion** y su vinculo al paso/criterio del plan. Marca el hito como hecho en el `plan.md`.
7. **PARA y pide permiso** explicito para continuar al siguiente hito.

## Cierre
Cuando todos los hitos esten hechos (o el usuario detenga):
- `fresh-verifier` para una verificacion semantica final en cambios no triviales.
- Escribe `.task-mode=plan` (vuelve a modo plan; bajar a un modo mas restrictivo no es escalacion, el mode-guard solo frena lo contrario).
- Reporta el cierre: hitos completados, guanteletes en verde, y lo que quede pendiente.

## Reglas
- Reusa agentes/scripts existentes; no reescribas su logica.
- Nunca commitees; nunca saltes el permiso entre hitos.
- Todo cambio va justificado y ligado a un paso del plan; sin placeholders.
