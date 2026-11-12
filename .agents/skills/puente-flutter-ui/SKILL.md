---
name: puente-flutter-ui
description: Diseñar o implementar pantallas, navegación, componentes y estilos Flutter de Puente respetando la identidad visual aprobada.
---
# Puente · Flutter UI
## Fuente de verdad
Antes de actuar, leer `AGENTS.md`, `docs/DECISIONES.md` y la documentación pertinente. Si hay conflicto, detenerse y consultar al usuario. No iniciar implementación Flutter hasta que lo autorice. No afirmar que una prueba se ejecutó si no se ejecutó.

## Entrega
Informar qué cambió, qué comprobaste realmente, riesgos y decisiones pendientes. No añadir dependencias sin explicar motivo, mantenimiento y alternativas.

## Cuándo usar
Para pantallas, componentes, navegación, tema, onboarding y assets visuales. No usar para cambiar requisitos de producto.

## Procedimiento
1. Leer `docs/DISENO_VISUAL.md`, `docs/TIPOGRAFIA.md`, `docs/FLUJOS_USUARIO.md` y, si aplica, `docs/ONBOARDING.md`.
2. Identificar pantalla, estados (vacío, cargando, error, permisos, teclado), entradas y salidas.
3. Proponer árbol de widgets, rutas y componentes reutilizables; solicitar aprobación para cambios importantes.
4. Al autorizarse código, usar Flutter/Dart, Figtree Variable (cuando esté disponible legalmente), tema centralizado y tamaños adaptativos.
5. Mantener visibles acciones críticas en Conversación: «No entendí», «Presentarme» y control explícito del micrófono.
6. En onboarding: tres pasos, primera apertura, Omitir, Siguiente, Volver, Empezar; sin permisos ni registro. Las imágenes están pendientes de verificar en el repo.
7. Revisar tamaños de fuente, contraste, safe areas, pantallas pequeñas, modo oscuro y navegación accesible.
8. Ejecutar análisis y pruebas disponibles; reportar las no realizadas.

## Evitar
No codificar textos dentro de ilustraciones; no sacrificar escalado para reproducir el mockup; no inventar pantallas o flujos nuevos.
