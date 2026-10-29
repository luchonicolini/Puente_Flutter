---
name: puente-ai-safety
description: Revisar funciones de IA de Puente para preservar intención, manejar ambigüedad, incertidumbre, privacidad y confirmación de datos.
---
# Puente · IA responsable
## Fuente de verdad
Antes de actuar, leer `AGENTS.md`, `docs/DECISIONES.md` y la documentación pertinente. Si hay conflicto, detenerse y consultar al usuario. No iniciar implementación Flutter hasta que lo autorice. No afirmar que una prueba se ejecutó si no se ejecutó.

## Entrega
Informar qué cambió, qué comprobaste realmente, riesgos y decisiones pendientes. No añadir dependencias sin explicar motivo, mantenimiento y alternativas.

## Cuándo usar
En Expresar, reformulación, traducción futura, detección de datos y cualquier procesamiento externo de conversación.

## Procedimiento
1. Leer `docs/PRODUCTO.md`, `docs/FUNCIONALIDADES.md`, `docs/ACCESIBILIDAD.md`.
2. Preservar siempre texto original y mostrar sugerencias como propuestas, nunca como hechos.
3. Si hay interpretaciones múltiples (pregunta o afirmación, por ejemplo), presentarlas y pedir elección; no decidir silenciosamente.
4. No enviar, copiar ni mostrar a terceros una reformulación sin confirmación del usuario.
5. Diferenciar transcripción, dato escrito, coincidencia entre valores y confirmación explícita. Coincidencia no demuestra veracidad ni justicia del precio.
6. Mostrar incertidumbre y permitir corrección o reintento; fallar de forma segura si la IA no responde.
7. Minimizar datos enviados a servicios externos; informar uso, solicitar consentimiento cuando corresponda y proteger credenciales en backend.
8. Crear pruebas con ejemplos ambiguos, cifras, fechas, negaciones, nombres propios y audio erróneo.
9. Evaluar resultados con personas usuarias; no asumir que una escritura no estándar es incorrecta.

## Evitar
No dar consejos clínicos/legales/financieros a partir de transcripciones inciertas; no afirmar que la IA garantiza comprensión.
