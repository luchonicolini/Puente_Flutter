# Registro de decisiones del producto

## Acordado
- Nombre: **Puente**.
- Misión: **Poder desenvolverme solo en situaciones cotidianas**.
- Público inicial: personas sordas o con dificultades auditivas; sin asumir necesidades idénticas.
- Flutter para iOS y Android.
- Modelo de interacción **híbrido**: interlocutor puede hablar o escribir; usuario puede escribir, mostrar o reproducir texto.
- Una sola persona necesita tener instalada la app.
- Sin registro obligatorio para funciones esenciales.
- Presentación **opcional**, editable y accesible con **un toque**; no aparece automáticamente.
- Botón **«No entendí»** visible, con opciones de repetición, escritura y aclaración.
- Confirmación escrita de datos relevantes como precios, fechas, horarios, direcciones y cantidades; una transcripción no equivale a confirmación.
- IA de Expresar bajo control del usuario: conservar original, aclarar ambigüedad, no enviar automáticamente.
- Empezar con MVP reducido y validar con usuarios antes de expandir.
- Repositorio como fuente de verdad para agentes mediante `AGENTS.md` y `docs/`.

## Propuestas aún no aprobadas definitivamente
- Diseño visual exacto y distribución final de las seis pantallas.
- Riverpod, proveedor de IA, backend, paquetes STT/TTS y almacenamiento.
- Detección automática de datos importantes y heurísticas para evitar alertas excesivas.
- Orden preciso de entregas y criterios cuantitativos de éxito.
- Idiomas adicionales, integraciones de teclado y módulos posteriores.
- Modelo económico y condiciones de gratuidad.

## Regla para agentes
No cambiar decisiones acordadas sin consultarlo. Cuando el usuario apruebe una modificación, registrar fecha, motivo y consecuencia aquí.

## Aprobación de diseño — 29/10/2026
El usuario aprobó la dirección visual del mockup de seis pantallas: Inicio, Conversación, Mostrar mensaje, Expresar, Confirmar información y Preferencias. Especificación detallada en `docs/DISENO_VISUAL.md`; plan de UI en `docs/PLAN_IMPLEMENTACION_UI.md`. Esta aprobación no implica comenzar programación ni aprobar proveedores técnicos.

## Decisión tipográfica — 29/10/2026
El usuario eligió **Figtree Variable** (`Figtree-Variable.ttf`) como tipografía principal de Puente para iOS y Android. Escala y reglas en `docs/TIPOGRAFIA.md`. El archivo de fuente y su licencia todavía deben incorporarse; no hay implementación Flutter iniciada.
