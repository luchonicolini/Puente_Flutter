# Onboarding de Puente — diseño aprobado

## Estado
Flujo visual de tres pantallas aprobado por el usuario. **No implementado en Flutter**. Se generaron tres ilustraciones individuales en la conversación, pero los PNG aún deben incorporarse físicamente al repositorio.

## Comportamiento
- Mostrar únicamente en el primer inicio de la instalación.
- Tres pasos, navegación Siguiente / Volver / Empezar y acción Omitir visible.
- Al completar u omitir, guardar localmente el estado y abrir Inicio.
- No exigir cuenta, conexión ni permisos de micrófono.
- Poder volver a verlo desde Preferencias → Cómo usar Puente.
- Respetar escalado de texto, lectores de pantalla, contraste, áreas seguras y tamaños reducidos.

## Pantalla 1 — Bienvenida
**Título:** Comunicarnos nos acerca.

**Descripción:** Puente te ayuda a comunicarte con otras personas de forma sencilla, a tu manera.

**Ilustración:** dos personas conversando con globos de diálogo superpuestos, estilo 3D suave. Archivo previsto: `assets/images/onboarding/onboarding_welcome.png`.

**Controles:** Omitir, indicador 01/03, Siguiente.

## Pantalla 2 — Conversación
**Título:** Escribí, hablá o mostrá.

**Descripción:** La otra persona puede hablar o escribir. Vos podés leer, responder o mostrar un mensaje grande.

**Ilustración:** teléfono con burbujas de mensajes, teclado, micrófono y accesibilidad de texto, estilo 3D suave. Archivo previsto: `assets/images/onboarding/onboarding_communication.png`.

**Controles:** Omitir, Volver, indicador 02/03, Siguiente.

## Pantalla 3 — Autonomía
**Título:** Entendé y decidí con confianza.

**Descripción:** Pedí aclaraciones y confirmá información importante, como precios y horarios.

**Ilustración:** teléfono con mensajes, tarjetas de información, reloj y símbolos de confirmación, estilo 3D suave. Archivo previsto: `assets/images/onboarding/onboarding_independence.png`.

**Controles:** Omitir, Volver, indicador 03/03, Empezar.

## Identidad visual
- Figtree Variable según `docs/TIPOGRAFIA.md`.
- Teal principal `#0D7E88`, blanco, menta suave y azul oscuro.
- Espacios amplios, botones redondeados, ilustración superior y textos inferiores.
- Imágenes sin textos integrados: títulos, botones e indicadores deben ser widgets Flutter, no partes del PNG.
- Alt text descriptivo o marcar ilustración decorativa según contexto; no duplicar el contenido textual.

## Recursos gráficos pendientes
Los tres PNG generados en la conversación deben exportarse, revisarse para comprobar transparencia real (no patrón de cuadros incrustado) y agregarse a las rutas indicadas. **No afirmar que están subidos hasta verificarlo.**

## Criterios de aceptación
- Onboarding solo en primera apertura; reapertura voluntaria desde ajustes.
- Omitir y Empezar llevan a Inicio.
- No solicita permisos.
- Se adapta a pantallas pequeñas y texto aumentado.
- No bloquea el uso de la aplicación si faltan recursos o red.
