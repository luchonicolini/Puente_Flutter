# Arquitectura técnica propuesta (no implementada)

## Plataformas
Flutter y Dart para iOS y Android. La arquitectura y los paquetes se validarán antes de elegir dependencias.

## Organización conceptual
- `features/home`: inicio y navegación.
- `features/conversation`: mensajes, turnos, micrófono y presentación.
- `features/expression`: borradores, sugerencias y confirmación de intención.
- `features/confirmation`: datos importantes y solicitudes de verificación.
- `features/quick_phrases`: frases locales.
- `features/settings`: accesibilidad y privacidad.
- `core`: servicios, modelos compartidos, errores y diseño.

## Estado
Riverpod es candidato para gestión de estado. Evitar acoplar widgets directamente a proveedores de IA o plugins de plataforma.

## Servicios
- STT: estudiar disponibilidad y calidad para español rioplatense, latencia, ruido, privacidad y compatibilidad offline.
- TTS: estudiar voces disponibles por plataforma e idioma.
- IA de reformulación: contrato estructurado con texto original, incertidumbre, alternativas y necesidad de aclaración; confirmación obligatoria.
- Backend: si se usa API de IA externa, proxy seguro con control de costos, secretos y tratamiento de datos; proveedor aún por decidir.
- Persistencia: solo preferencias, frases y datos explícitamente guardados; política de borrado.

## Calidad
Pruebas unitarias de estados y confirmación, pruebas de widgets, pruebas manuales con dispositivos iOS/Android y sesiones de usabilidad con personas destinatarias.

## No decidido
Proveedor STT/TTS, API de IA, backend, esquema de persistencia, soporte offline exacto, política de retención, presupuesto y diseño visual definitivo. No tratarlos como hechos.
