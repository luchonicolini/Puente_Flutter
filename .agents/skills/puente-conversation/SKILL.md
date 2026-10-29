---
name: puente-conversation
description: Planificar e implementar el flujo híbrido de conversación de Puente: mensajes, escritura, micrófono, STT, TTS, presentación y «No entendí».
---
# Puente · Conversación
## Fuente de verdad
Antes de actuar, leer `AGENTS.md`, `docs/DECISIONES.md` y la documentación pertinente. Si hay conflicto, detenerse y consultar al usuario. No iniciar implementación Flutter hasta que lo autorice. No afirmar que una prueba se ejecutó si no se ejecutó.

## Entrega
Informar qué cambió, qué comprobaste realmente, riesgos y decisiones pendientes. No añadir dependencias sin explicar motivo, mantenimiento y alternativas.

## Cuándo usar
Para mensajes, turnos, micrófono, reconocimiento de voz, síntesis, presentación, frases rápidas y modo sin conexión.

## Procedimiento
1. Leer `docs/FUNCIONALIDADES.md`, `docs/FLUJOS_USUARIO.md` y `docs/ACCESIBILIDAD.md`.
2. Modelar estados explícitos: inactivo, escuchando, parcial, transcrito, error, sin permisos, sin conexión.
3. Diseñar interfaz con el interlocutor sin instalación adicional y sin selección obligatoria previa de modalidad.
4. Solicitar permiso de micrófono solo al activarlo; indicar cuándo está activo y cómo detenerlo.
5. Conservar incertidumbre de STT, permitir corregir y repetir; no inventar palabras.
6. Mantener «No entendí» con frases locales: repetir, escribir, hablar más despacio, explicar diferente.
7. Mantener «Presentarme» opcional, editable y de un toque; texto grande y TTS opcional.
8. Integrar confirmación explícita de importes, fechas, horarios, cantidades y direcciones; transcripción no equivale a confirmación.
9. Evitar persistir conversaciones completas por defecto; diseñar descarte y guardado opt-in de datos puntuales.
10. Probar errores, permisos denegados, cambio de modalidad, interrupciones y falta de conexión.

## Evitar
No elegir proveedor STT/TTS ni prometer operación offline sin evaluación; no iniciar grabaciones ocultas.
