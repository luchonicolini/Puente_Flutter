# Puente

> **English:** A Flutter accessibility app designed to help deaf and hard-of-hearing children communicate more independently in everyday situations. It combines text, message display and platform speech services while keeping the user in control of what is communicated.

Puente es un proyecto pensado para ayudar a **chicos sordos o con dificultades auditivas** que encuentran barreras para comunicarse con otras personas en situaciones cotidianas.
Su objetivo es facilitar esos intercambios y favorecer una mayor autonomía mediante texto, mensajes en pantalla y servicios de voz, sin que el interlocutor tenga que instalar la app.

La propuesta parte de una necesidad de comunicación accesible, reconociendo que cada persona puede tener preferencias y necesidades diferentes. El impacto en la vida cotidiana todavía debe validarse con las personas destinatarias.

**Estado:** implementación Flutter en desarrollo con pantallas, servicios y tests en el repositorio.
La presencia de código no implica validación de voz en todos los dispositivos ni publicación en tiendas.

## Vista previa

[COMPLETAR: capturas reales de Inicio, Conversación y Confirmar información]

Las ilustraciones de onboarding y la tipografía Figtree están incluidas en `assets/`.
Son recursos de la interfaz, no capturas de una aplicación ejecutándose.

## Funcionalidades y alcance actual

- Onboarding de tres pantallas y preferencias guardadas localmente.
- Conversación por texto, presentación personal opcional y botón **«No entendí»**.
- Mostrar un mensaje en pantalla y usar frases rápidas.
- Servicios de reconocimiento y síntesis de voz mediante plugins de plataforma.
- Detección determinista de importes, horarios y fechas; comparación con confirmaciones escritas.
- Preferencias de tema, voz y accesibilidad.
- **Expresar está en modo demostración:** las propuestas son simuladas localmente. No hay un proveedor de IA real integrado.

La disponibilidad y calidad de voz dependen del dispositivo, permisos, idioma y servicios del sistema.
No se garantiza reconocimiento offline ni exactitud de las transcripciones.
Una coincidencia de texto tampoco confirma la veracidad de un precio o condición.
Puente no reemplaza intérpretes ni servicios profesionales o de emergencia.

## Stack y arquitectura

| Área | Implementación |
| --- | --- |
| UI | Flutter y Dart; SDK Dart requerido: `^3.12.0` |
| Organización | Módulos por funcionalidad |
| Voz | Contratos `SpeechService` y `TtsService`; adaptadores speech_to_text y flutter_tts |
| Preferencias | `PreferencesService` con ChangeNotifier y abstracción `PreferencesStore` |
| Persistencia | shared_preferences; implementación en memoria para pruebas |
| Dominio | Detección y comparación de datos sensibles en Dart |
| Pruebas | flutter_test con servicios falsos e inyección de dependencias |

La UI depende de contratos para voz y preferencias, lo que permite comprobar interacciones sin micrófono,
red ni almacenamiento real. La lógica de detección y comparación está separada de los widgets.
No se presenta Riverpod ni un backend de IA como parte de la implementación.

| Directorio | Responsabilidad |
| --- | --- |
| `lib/features/` | Inicio, onboarding, conversación, expresión y confirmación |
| `lib/domain/` | Tipos y reglas de detección y comparación |
| `lib/core/services/` | Contratos y adaptadores de voz |
| `lib/core/storage/` | Preferencias persistentes y en memoria |
| `lib/core/theme/` | Colores, tipografía y tema |
| `test/` | Pruebas de dominio y pantallas |

## Cómo ejecutarlo

1. Instalá Flutter con Dart 3.12 o superior.
2. Prepará un emulador o dispositivo Android, o macOS con Xcode para iOS.
3. Cloná y ejecutá:

   ```bash
   git clone https://github.com/luchonicolini/Puente_Flutter.git
   cd Puente_Flutter
   flutter doctor
   flutter pub get
   flutter devices
   flutter run
   ```

4. Elegí el dispositivo con `flutter run -d <ID>` si hay varios disponibles.
5. Para validar voz, utilizá un dispositivo físico, concedé los permisos solicitados y comprobá los estados de permiso denegado o servicio no disponible.

No se necesita una clave de IA para probar la implementación actual.
Las pruebas con servicios falsos no certifican el funcionamiento de los plugins en hardware.

## Tests

```bash
flutter analyze
flutter test
```

La suite incluye onboarding, inicio, preferencias, conversación, expresión y confirmación de datos.
Los tests de conversación usan dobles de STT/TTS; los de preferencias pueden usar almacenamiento en memoria.
Este repositorio no tiene un workflow de CI propio en esta propuesta.

## Documentación

- [Producto](docs/PRODUCTO.md) y [decisiones](docs/DECISIONES.md).
- [Requisitos](docs/FUNCIONALIDADES.md), [flujos](docs/FLUJOS_USUARIO.md) y [accesibilidad y privacidad](docs/ACCESIBILIDAD.md).
- [Diseño](docs/DISENO_VISUAL.md), [onboarding](docs/ONBOARDING.md) y [tipografía](docs/TIPOGRAFIA.md).

Algunos documentos iniciales describen propuestas o etapas anteriores. Para evaluar la implementación,
contrastalos con el código y las entradas posteriores del registro de decisiones.

## Próximos pasos

- Validar STT/TTS, permisos, ruido y errores en dispositivos iOS y Android.
- Realizar pruebas de usabilidad y accesibilidad con personas destinatarias.
- Actualizar los documentos históricos que todavía describen componentes ya implementados.
- Evaluar privacidad, costos y confirmación de intención antes de integrar IA real.

## Pendientes de presentación

- [COMPLETAR: capturas reales de Inicio, Conversación y Confirmar información]
- [COMPLETAR: enlace a demo instalable o tienda si existe una publicación]

## Autor

[Luciano Nicolini](https://github.com/luchonicolini) · iOS Developer (Swift, SwiftUI), con desarrollo multiplataforma en Flutter.
