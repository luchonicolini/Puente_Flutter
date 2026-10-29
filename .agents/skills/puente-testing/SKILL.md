---
name: puente-testing
description: Planificar y ejecutar pruebas de UI, navegación, accesibilidad, privacidad y flujos críticos de Puente en iOS y Android.
---
# Puente · Testing
## Fuente de verdad
Antes de actuar, leer `AGENTS.md`, `docs/DECISIONES.md` y la documentación pertinente. Si hay conflicto, detenerse y consultar al usuario. No iniciar implementación Flutter hasta que lo autorice. No afirmar que una prueba se ejecutó si no se ejecutó.

## Entrega
Informar qué cambió, qué comprobaste realmente, riesgos y decisiones pendientes. No añadir dependencias sin explicar motivo, mantenimiento y alternativas.

## Cuándo usar
Para criterios de aceptación, regresión, bugs, entregas de pantallas y cambios en voz, IA o almacenamiento.

## Procedimiento
1. Leer `docs/PLAN_IMPLEMENTACION_UI.md`, `docs/FUNCIONALIDADES.md`, `docs/FLUJOS_USUARIO.md`.
2. Traducir cada requisito en casos de prueba con entrada, acción, resultado esperado y prioridad.
3. Priorizar: primera apertura/omitir onboarding; inicio sin cuenta; conversación híbrida; «No entendí»; presentación opcional; micrófono visible; Expresar sin cambiar intención; confirmación de importes; borrado.
4. Cubrir estados vacíos, errores, permisos denegados, sin conexión, texto grande y modo oscuro.
5. Cuando exista código, ejecutar `flutter analyze`, `flutter test` y pruebas de integración pertinentes; documentar comandos, resultados y entorno.
6. Para STT/TTS, evaluar dispositivos reales y variantes de español, ruido, interrupciones y latencia.
7. Reportar bugs reproducibles, severidad, pasos y evidencia; no marcar «aprobado» si falta validación.
8. Mantener una lista de regresión al incorporar nuevas funcionalidades.

## Evitar
No inventar resultados de CI ni pruebas en hardware; no sustituir pruebas con usuarios por tests automáticos.
