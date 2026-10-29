---
name: puente-accessibility
description: Auditar y mejorar accesibilidad, legibilidad y facilidad de uso de Puente en Flutter para personas con distintas preferencias de comunicación.
---
# Puente · Accesibilidad
## Fuente de verdad
Antes de actuar, leer `AGENTS.md`, `docs/DECISIONES.md` y la documentación pertinente. Si hay conflicto, detenerse y consultar al usuario. No iniciar implementación Flutter hasta que lo autorice. No afirmar que una prueba se ejecutó si no se ejecutó.

## Entrega
Informar qué cambió, qué comprobaste realmente, riesgos y decisiones pendientes. No añadir dependencias sin explicar motivo, mantenimiento y alternativas.

## Cuándo usar
En revisión de cualquier pantalla, flujo de voz/texto, permisos, onboarding, preferencias y antes de una entrega.

## Procedimiento
1. Leer `docs/ACCESIBILIDAD.md` y `docs/TIPOGRAFIA.md`.
2. Revisar navegación por lector de pantalla, orden de foco, nombres semánticos y estados anunciados.
3. Comprobar contraste: objetivo al menos 4.5:1 para texto normal y 3:1 para texto grande.
4. Revisar escalado dinámico, ajuste de líneas, controles táctiles grandes y uso con una mano.
5. Garantizar alternativas visuales a señales sonoras; no comunicar estados solo con color.
6. Verificar que micrófono activo, errores de transcripción y datos sin confirmar sean evidentes.
7. Revisar que no se revele sordera automáticamente ni se imponga una forma de comunicación.
8. Presentar hallazgos por severidad, pasos para reproducir y corrección propuesta; validar con usuarios reales cuando sea posible.

## Evitar
No asumir que todas las personas sordas leen o se comunican de igual forma. No afirmar cumplimiento normativo sin evaluación.
