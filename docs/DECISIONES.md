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
- Riverpod, proveedor de IA, backend y paquetes STT/TTS (almacenamiento ligero de preferencias resuelto con `shared_preferences`).
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

## Onboarding aprobado
Tres pantallas: «Comunicarnos nos acerca», «Escribí, hablá o mostrá», «Entendé y decidí con confianza». Solo en primera apertura, se puede omitir, sin permisos ni registro, y se puede reabrir desde Preferencias. Ver `docs/ONBOARDING.md`. Las ilustraciones generadas aún no están en GitHub.

## Implementación del Onboarding — 29/10/2026
A partir del diseño aprobado por el usuario, se incorporaron físicamente los recursos gráficos a `assets/images/onboarding/` y se implementó `OnboardingScreen` con las tres pantallas interactivas, navegación (Omitir, Siguiente, Volver, Empezar), etiquetas semánticas y adaptabilidad para texto escalable.

## Implementación de la pantalla de Inicio — 29/10/2026
A partir del diseño visual aprobado por el usuario en el mockup individual, se actualizó `HomeScreen` (`lib/features/home/home_screen.dart`): titular «Comunicarnos hace todo más fácil», botón destacado «Iniciar conversación» (gradiente teal y badge circular), tres tarjetas secundarias verticales («Frases rápidas», «Expresar», «Comprar») y banner de presentación personal con ilustración e interacción «Ver ejemplo». Componente reutilizable `PuenteBrandLogo` compartido con el onboarding.

## Implementación de la pantalla de Conversación — 29/10/2026
A partir del mockup general aprobado de las 6 pantallas (`02. Conversación`), se implementó `ConversationScreen` (`lib/features/conversation/conversation_screen.dart`): burbujas diferenciadas con timestamp, tarjeta contextual «Información detectada» con desglose estructurado de datos (Inscripción / Cuota mensual), fila de 3 botones circulares superiores («Presentarme», «No entendí», «Confirmar»), compositor de texto con botón enviar, y fila inferior con control explícito de micrófono («Tocá para hablar»), silenciador y reproducción TTS en voz alta.

## Transparencia y modo demostración en Expresar — 30/10/2026
Ante la observación de que Expresar utilizaba tres respuestas fijas de gimnasio como si provinieran de una IA real, se aprobó la Opción A para preservar la honestidad del producto:
- Banner visible de «Modo demostración (UI)» informando que la integración con un motor de IA seguro está en evaluación técnica y de privacidad.
- Las variantes sugeridas se generan localmente a partir del propio texto redactado por la persona usuaria, en lugar de forzar siempre el caso del gimnasio.
- Cada tarjeta lleva un badge visible de «Propuesta simulada» y opción de «Editar».
- Botón prominente de «Usar mi texto original» disponible tanto en el encabezado como al pie de las propuestas para garantizar el control total del usuario sobre lo que expresa.

## Persistencia local del Onboarding y preferencias — 30/10/2026
Aprobada la incorporación de `shared_preferences: ^2.3.0` como solución oficial de almacenamiento clave-valor local:
- Se implementó `PreferencesService` (`lib/core/storage/preferences_service.dart`) con arquitectura reactiva (`ChangeNotifier`).
- Manejo reactivo de `ThemeMode`: `PuenteApp` en `main.dart` escucha los cambios en `PreferencesService` y actualiza dinámicamente el tema de toda la app (`themeMode: prefs.themeMode`).
- Persistencia real de todos los ajustes: tema visual (sistema/claro/oscuro), vibración háptica, reproducción automática TTS, velocidad de voz y almacenamiento opt-in.
- `has_seen_onboarding` se persiste al presionar «Omitir» o «Empezar».
- `main.dart` resuelve condicionalmente la pantalla de inicio: muestra `OnboardingScreen` únicamente en la primera apertura y `HomeScreen` en arranques posteriores.
- El usuario puede volver a ver el onboarding voluntariamente desde Preferencias → «Cómo usar Puente».
- Operación real de «Borrar datos locales»: limpia `SharedPreferences`, restablece el estado de los controles y notifica a la app para regresar al tema por defecto del sistema.

## Incorporación física de la tipografía Figtree Variable — 30/10/2026
Se incorporó el archivo de fuente oficial `Figtree-Variable.ttf` en `assets/fonts/` junto con su licencia oficial SIL Open Font License 1.1 (`assets/fonts/OFL.txt`). Se registró la familia `Figtree` en `pubspec.yaml`, asegurando que la tipografía aprobada se cargue y renderice efectivamente en la aplicación manteniendo el fallback del sistema en `AppTypography`.

## Regla de fidelidad visual obligatoria — 30/10/2026
Aprobada e incorporada a `AGENTS.md` y documentación de diseño la regla de fidelidad visual estricta para la implementación de pantallas:
1. Análisis exhaustivo de estructura, proporciones, tipografía, colores, espaciados, radios e iconografía.
2. Construcción de componentes personalizados necesarios sin sustituir diseños custom por widgets genéricos por comodidad.
3. Uso estricto de recursos gráficos originales del repositorio.
4. Ejecución en simulador/dispositivo cuando esté disponible y comparación de capturas de pantalla frente al diseño de referencia.
5. Corrección de diferencias visuales antes de dar por finalizada la tarea.
6. Verificación con textos largos, fuentes grandes y diferentes pantallas, sin asumir coincidencia visual sin comprobación real.

## Honestidad en micrófono y síntesis de voz en Conversación — 30/10/2026
Ante la observación de que la interfaz mostraba «Escuchando...» en rojo y notificaciones de TTS sin captura de audio real ni permisos:
- Se eliminó el estado simulado de escucha en `ConversationScreen`. El botón ya no cambia a color rojo ni afirma estar escuchando cuando no hay captura de hardware.
- Al pulsar el micrófono o el parlante (TTS), se despliega un diálogo informativo accesible explicando que el reconocimiento/síntesis en tiempo real está en preparación y guiando a la persona a usar la entrada por texto o «Mostrar mensaje».
- Se preserva el flujo operativo de texto, respuestas rápidas, «No entendí», «Presentarme» y confirmación de datos.

## Arquitectura de Dominio y Persistencia desacoplada (Ports & Adapters) — 30/10/2026
Siguiendo las buenas prácticas observadas en la arquitectura de proyectos de referencia (`Gastos_Compartidos`):
1. **Desacoplamiento de Persistencia:** Se introdujo la abstracción `PreferencesStore` (`lib/core/storage/preferences_store.dart`) separando el contrato de almacenamiento de la implementación con `shared_preferences`. Se agregó `InMemoryPreferencesStore` y el constructor factory `PreferencesService.inMemory()`, permitiendo pruebas de widgets e integración completamente aisladas y reproducibles sin requerir acceso a disco o plugins de plataforma.
2. **Capa de Dominio para Datos Sensibles:** Se creó la capa `lib/domain/` con lógica pura de Dart sin acoplamiento a widgets de Flutter:
   - `SensitiveDataItem` y categorías (`price`, `schedule`, `date`, `other`).
   - `SensitiveDataDetector`: extracción determinista y atómica con expresiones regulares seguras contra Catastrophic Backtracking (ReDoS). Detecta importes (prefijo `$`, sufijos `pesos`/`ars`/`usd`), horarios (`18:30 hs`, `9:00`) y fechas (`15 de noviembre`, `20/11/2026`).
   - `SensitiveDataComparator`: normalización semántica y comparación estricta de importes, fechas y horarios, incorporando la regla innegociable de que la coincidencia de texto no garantiza certeza o legitimidad comercial.
3. **Integración en UI:** `ConfirmationScreen` utiliza `SensitiveDataComparator` para evaluar los datos ingresados por el interlocutor, y `ConversationScreen` procesa automáticamente las transcripciones entrantes con `SensitiveDataDetector` para generar tarjetas de información detectada con opción de confirmación por escrito.
