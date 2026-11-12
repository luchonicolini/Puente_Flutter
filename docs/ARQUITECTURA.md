# Arquitectura técnica

## Estado actual

Puente adopta progresivamente una separación inspirada en capas: la interfaz
presenta estados e interacción, `domain/` contiene reglas puras de Dart y
`core/` concentra servicios de plataforma. No se persisten conversaciones.

Implementado actualmente:

- `domain/confirmation/data_comparison.dart`: comparación normalizada de dos
  valores; una coincidencia no acredita veracidad.
- `domain/conversation/sensitive_data_detector.dart`: detección local y
  determinista de importes para sugerir confirmación.
- `domain/expression/expression_alternatives.dart`: alternativas locales y
  revisión de posible ambigüedad sin servicios externos.
- `domain/expression/expression_assist.dart`: contrato estructurado
  (`ExpressionAssistResult`, `ExpressionAssistService`) para asistencia con IA
  preservando original, ambigüedades e incertidumbre.
- `supabase/functions/expression-assist/index.ts`: Edge Function proxy que
  consulta Gemini (`gemini-3.8-flash`, `store: false`) con salida JSON
  estructurada manteniendo la clave `GEMINI_API_KEY` fuera del cliente móvil.

La persistencia de preferencias continúa aislada en `core/storage/`. STT, TTS,
permisos y respuesta háptica son contratos/servicios de `core/services/` que
los controladores consumen sin exponer plugins a las pantallas.

## Plataformas
Flutter y Dart para iOS y Android. La arquitectura y los paquetes se validarán antes de elegir dependencias.

## Organización
- `features/home`: inicio y navegación.
- `features/conversation`: mensajes, turnos, micrófono y presentación.
- `features/expression`: borradores, sugerencias y confirmación de intención.
- `features/confirmation`: datos importantes y solicitudes de verificación.
- `features/quick_phrases`: frases locales.
- `features/settings`: accesibilidad y privacidad.
- `domain`: modelos y reglas puras, sin Flutter ni plugins.
- `core`: servicios, modelos compartidos, errores y diseño.

## Estado
Riverpod administra el estado de conversación. Evitar acoplar widgets directamente a proveedores de IA o plugins de plataforma.

## Servicios
- STT: estudiar disponibilidad y calidad para español rioplatense, latencia, ruido, privacidad y compatibilidad offline.
- TTS: estudiar voces disponibles por plataforma e idioma.
- IA de reformulación: contrato estructurado con texto original, incertidumbre, alternativas y necesidad de aclaración; confirmación obligatoria.
- Backend: si se usa API de IA externa, proxy seguro con control de costos, secretos y tratamiento de datos; proveedor aún por decidir.
- Persistencia: solo preferencias, frases y datos explícitamente guardados; política de borrado.

## Calidad
Las reglas de `domain/` están diseñadas para pruebas unitarias sin Flutter. La
suite automática se reconstruirá sobre funciones reales; además se requieren
pruebas manuales en dispositivos iOS/Android y sesiones de usabilidad con
personas destinatarias.

## No decidido
Proveedor STT/TTS, API de IA, backend, esquema de persistencia, soporte offline exacto, política de retención, presupuesto y diseño visual definitivo. No tratarlos como hechos.
