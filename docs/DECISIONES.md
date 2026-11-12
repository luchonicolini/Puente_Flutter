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

## Implementación de Figtree — 30/10/2026
Se incorporó `assets/fonts/Figtree-Variable.ttf` desde el repositorio oficial de Google Fonts y su licencia SIL OFL 1.1 en `assets/fonts/OFL.txt`. La familia `Figtree` quedó registrada en `pubspec.yaml`; faltan pruebas visuales en Android e iOS.

## Onboarding aprobado
Tres pantallas: «Comunicarnos nos acerca», «Escribí, hablá o mostrá», «Entendé y decidí con confianza». Solo en primera apertura, se puede omitir, sin permisos ni registro, y se puede reabrir desde Preferencias. Ver `docs/ONBOARDING.md`. Las ilustraciones generadas aún no están en GitHub.

## Implementación del Onboarding — 29/10/2026
A partir del diseño aprobado por el usuario, se incorporaron físicamente los recursos gráficos a `assets/images/onboarding/` y se implementó `OnboardingScreen` con las tres pantallas interactivas, navegación (Omitir, Siguiente, Volver, Empezar), etiquetas semánticas y adaptabilidad para texto escalable.

## Persistencia del Onboarding — 30/10/2026
Se aprobó `shared_preferences` para almacenar exclusivamente el booleano local `onboarding_completed`. Al omitir o completar la bienvenida, Puente abre Inicio en las siguientes aperturas; al reabrirla desde Preferencias, vuelve a Preferencias. No se guardan conversaciones ni contenido personal.

## Persistencia de Preferencias — 30/10/2026
Se amplió el uso local de `shared_preferences` a tema, escala de texto, reproducción de mensajes, vibración y la preferencia de no guardar conversaciones. No se persisten conversaciones ni transcripciones. Tema y escala se aplican a toda la app; los ajustes de voz quedan preparados para integrarse cuando existan TTS/STT reales.

## Implementación de la pantalla de Inicio — 29/10/2026
A partir del diseño visual aprobado por el usuario en el mockup individual, se actualizó `HomeScreen` (`lib/features/home/home_screen.dart`): titular «Comunicarnos hace todo más fácil», botón destacado «Iniciar conversación» (gradiente teal y badge circular), tres tarjetas secundarias verticales («Frases rápidas», «Expresar», «Comprar») y banner de presentación personal con ilustración e interacción «Ver ejemplo». Componente reutilizable `PuenteBrandLogo` compartido con el onboarding.

## Implementación de la pantalla de Conversación — 29/10/2026
A partir del mockup general aprobado de las 6 pantallas (`02. Conversación`), se implementó `ConversationScreen` (`lib/features/conversation/conversation_screen.dart`): burbujas diferenciadas con timestamp, tarjeta contextual «Información detectada» con desglose estructurado de datos (Inscripción / Cuota mensual), fila de 3 botones circulares superiores («Presentarme», «No entendí», «Confirmar»), compositor de texto con botón enviar, y fila inferior con control explícito de micrófono («Tocá para hablar»), silenciador y reproducción TTS en voz alta.

## Estabilización de UI y verificación de pruebas — 30/10/2026
Se corrigió la sintaxis en el diálogo de eliminación de datos locales en Preferencias, se vinculó el acceso de pantalla completa para mostrar texto en el compositor de Conversación (según `docs/DISENO_VISUAL.md`), y se alinearon las aserciones de `test/widget_test.dart` y `test/home_screen_test.dart`. La suite completa (15 pruebas unitarias y de widgets) quedó en verde y el análisis estático (`flutter analyze`) sin advertencias ni errores.

## Adopción de Riverpod y contratos de servicios de audio — 30/10/2026
El usuario aprobó avanzar con la integración de estado y audio real. Se incorporó `flutter_riverpod` y se crearon los contratos abstractos desacoplados en `lib/core/services/` (`TtsService` y `SttService`) junto con dobles de prueba controlables (`MockTtsService` y `MockSttService`). Se migró la pantalla de conversación a `ConversationController` (`StateNotifier`), permitiendo gestión reactiva de mensajes, detección automática de importes y control de micrófono/silencio. Se agregaron 9 pruebas unitarias y la suite completa alcanzó 24 pruebas pasando al 100% en verde.

## Integración de Text-to-Speech nativo (`flutter_tts`) — 30/10/2026
Se incorporó el paquete `flutter_tts` e implementó `FlutterTtsService` bajo el contrato `TtsService`. La síntesis de voz se configuró con español rioplatense (`es-AR`) como idioma preferente y velocidad natural (0.5). Se conectó con el botón de reproducir en voz alta de Conversación y en la pantalla Mostrar mensaje, deteniendo la voz automáticamente al salir de la pantalla o pasar la app a segundo plano. El control de silencio es exclusivo del micrófono y no impide reproducir TTS.

## Integración de Speech-to-Text nativo (`speech_to_text`) y permisos — 30/10/2026
Se incorporó `speech_to_text` e implementó `SpeechToTextService` bajo el contrato `SttService`. Se configuraron los permisos en `AndroidManifest.xml` (`RECORD_AUDIO`, `INTERNET`, queries para `RecognitionService`) y en `Info.plist` de iOS (`NSMicrophoneUsageDescription` y `NSSpeechRecognitionUsageDescription`) con descripciones claras de privacidad. La solicitud de permisos y el micrófono se activan estrictamente bajo demanda al pulsar «Tocá para hablar», mostrando transcripción parcial en vivo y publicando mensajes automáticamente al finalizar la frase del interlocutor. Los proveedores alternan transparentemente a dobles de prueba en entornos CI/tests, garantizando las 24 pruebas al 100% en verde.

## Descarte y borrado de datos locales — 30/10/2026
Al finalizar una conversación, el contenido que solo existe en memoria se descarta únicamente después de confirmación explícita. La acción «Eliminar datos guardados» en Preferencias también pide confirmación y elimina tema, escala de texto, ajustes locales y la marca de bienvenida. No elimina conversaciones ni transcripciones, porque Puente no las persiste localmente.

## Revisión explícita de transcripciones — 30/10/2026
Se conserva la integración nativa de reconocimiento y síntesis de voz para validarla en dispositivos reales, pero una transcripción nunca se incorpora automáticamente a la conversación. Al terminar o detener la escucha, el texto queda marcado como «sin confirmar» y la persona puede editarlo, descartarlo o agregarlo explícitamente. Hasta completar pruebas manuales en Android e iOS, la transcripción se considera una función en validación y escritura/Mostrar mensaje siguen siendo alternativas completas.

## Retiro de datos de demostración y pruebas — 30/10/2026
Para iniciar la implementación sobre funciones reales, se eliminaron los mensajes de conversación precargados, las sugerencias fijas que simulaban IA, los servicios mock y la suite de pruebas automática. La conversación ahora inicia vacía; Expresar conserva el texto original y comunica con claridad que la ayuda con IA está pendiente. Las pruebas deberán redefinirse cuando los flujos reales estén estabilizados.

**Revisión posterior (30/10/2026):** esta decisión se ajustó. Se retiraron los mensajes de demostración, pero se conservó la suite de pruebas y se aislaron los dobles de prueba en `test/helpers/test_overrides.dart`. El código productivo usa servicios reales; las pruebas inyectan los mocks mediante Riverpod. Ver «Retiro definitivo de mensajes de demostración y actualización del estado del MVP» y «Eliminación de deuda técnica: permisos de Bluetooth y mocks en producción».

## Acceso «Confirmar datos» en Inicio — 30/10/2026
Se reemplazó el acceso «Comprar» por «Confirmar datos» para evitar que Puente parezca una aplicación de comercio. Abre la pantalla de confirmación y permite ingresar manualmente un precio, horario, fecha, cantidad u otro dato antes de contrastarlo con lo que la otra persona escriba. La coincidencia de textos no se presenta como garantía de veracidad ni de justicia comercial.

## Indicador visual de micrófono activo — 30/10/2026
Durante la escucha se muestra una onda animada junto al texto «Micrófono activo» y la transcripción parcial. La animación confirma que Puente mantiene el micrófono activo; no representa volumen ni garantiza que haya voz detectada. El texto parcial es la señal de contenido reconocido.

## Alternativas locales en Expresar — 30/10/2026
Expresar ofrece tres alternativas editables —más formal, más directa y para pedir aclaración— generadas localmente a partir del texto original. No se usa ni se simula una IA externa. El original siempre está disponible y ninguna propuesta se aplica, envía o comparte sin una selección explícita. Cuando el texto puede expresar más de una intención, se muestran opciones de consulta o aclaración sin decidir por la persona.

## Separación de reglas de dominio — 30/10/2026
Tomando como referencia la organización de Gastos Compartidos, Puente incorpora `lib/domain/` para reglas puras y reutilizables. La comparación de datos, la detección local de importes y las alternativas locales de Expresar no dependen de Flutter, pantallas ni plugins. No se adopta una base de datos de conversaciones: la arquitectura conserva la política de no persistirlas por defecto.

## Integración de respuesta háptica, permisos del sistema y frases rápidas locales — 30/10/2026
Aprobada la integración de las 3 mejoras del punto 1:
1. **Respuesta háptica y vibración (`vibration`):** Feedback táctil clave para personas sordas o con dificultades auditivas al iniciar la escucha, detener el micrófono y recibir un mensaje o transcripción del interlocutor. Se declaró el permiso `VIBRATE` en `AndroidManifest.xml` y se aisló tras `HapticService`.
2. **Gestión de permisos del sistema (`permission_handler`):** Se implementó `PermissionService` para auditar el estado del micrófono, detectando bloqueos y denegaciones permanentes con notificación directa que permite redirigir a Ajustes del sistema.
3. **Persistencia de Frases Rápidas (`QuickPhrasesStore`):** Se permite a la persona usuaria añadir y eliminar frases personalizadas guardadas de forma 100% local y offline mediante `shared_preferences`, manteniendo la regla de no exigir registro ni recopilar conversaciones.
4. **Garantía de pruebas:** Se implementaron dobles de prueba (`MockHapticService`, `MockPermissionService`, `MockQuickPhrasesStore`, `InMemoryOnboardingStore`, `InMemoryAppPreferencesStore`) con detección automática de entorno de test, logrando que el 100% de la suite de pruebas unitarias y de widgets se ejecute en verde con cero warnings en `dart analyze`.

## Transición animada en la llegada de mensajes — 30/10/2026
Aprobada la animación suave de entrada para los nuevos mensajes agregados al historial de conversación en `ConversationScreen`:
- **Efecto visual:** Combinación sutil de desvanecimiento (`FadeTransition` 0.0 a 1.0) y ligero desplazamiento vertical hacia arriba (`SlideTransition` con `Offset(0.0, 0.12)` a `Offset.zero`) en 250 ms con curva `Curves.easeOutCubic`.
- **Aislamiento por elemento:** Cada burbuja está identificada por `ValueKey(message.id)`, lo que asegura que solo la nueva burbuja ejecute la animación al montarse sin reanimar las burbujas ya visibles.
- **Accesibilidad y reducción de movimiento:** Se consulta `MediaQuery.maybeOf(context)?.disableAnimations`. Si el sistema operativo o el usuario tienen activada la reducción de movimiento, la animación se omite inmediatamente mostrando el mensaje de forma instantánea.

## Privacidad de audio, confirmación por tipo y turno del interlocutor — 30/10/2026
Se aprobaron y aplicaron los tres primeros puntos de mejora:
1. **Privacidad de audio:** silenciar ahora detiene el micrófono y bloquea nuevas escuchas hasta reactivarlo; no detiene la reproducción TTS. Al salir de Conversación, navegar a otra pantalla o pasar la app a segundo plano se cancelan STT y se detiene TTS. El texto parcial se descarta y no se convierte en transcripción. Reproducir un mensaje detiene antes el micrófono.
2. **Confirmación de datos:** la comparación se hace por tipo (`importe`, `fecha`, `hora`, `texto`), no por texto normalizado genérico. Los importes se interpretan en formato rioplatense e internacional; `3,5` y `35` no coinciden, mientras que `1.500` y `1500` sí. Se eliminó el valor fijo `$35.000` del acceso rápido «Confirmar»; la pantalla abre vacía y el dato detectado es editable. El detector local reconoce varios importes por mensaje, los etiqueta por contexto cercano y evita confundir fechas u horarios.
3. **Turno del interlocutor:** el compositor incorpora un selector explícito «Yo / La otra persona». Los mensajes se registran con el turno elegido; solo los del interlocutor disparan detección de datos y vibración. Las transcripciones STT y las frases de «No entendí» conservan el turno que corresponde.

## Reemplazo de SnackBars por avisos superiores (`TopAlertBanner`) — 30/10/2026
Se eliminaron los `SnackBar` inferiores que creaban una barra oscura horizontal sobre los controles críticos de la conversación (micrófono, compositor y botones de audio).
- **Componente `TopAlertBanner`:** se implementó un banner flotante en la parte superior (`Positioned` en la zona alta de la pantalla) con diseño de píldora redondeada (`BorderRadius.circular(16)`), sombra suave, colores contextuales por tipo (info, éxito, aviso, error) y tipografía Figtree.
- **Acciones y descartabilidad:** incluye ícono temático, botón de acción opcional (ej. «Ajustes» ante permisos bloqueados) y botón de cierre inmediato `(X)`, además de auto-descarte por temporizador.
- **Animación y accesibilidad:** aparece con `AnimatedSwitcher` (desvanecimiento y ligero deslizamiento vertical descendente de 250 ms), con soporte para lectores de pantalla (`Semantics(liveRegion: true)`) y respeto a la reducción de movimiento (`disableAnimations`).

## Actualización de Android compileSdk a 37 — 30/10/2026
Para dar soporte a la versión actual de `permission_handler_android` (requerida por `permission_handler`), se actualizó `compileSdk = 37` en `android/app/build.gradle.kts`. La compilación de Gradle (`assembleDebug`) finalizó exitosamente sin errores de compatibilidad AAR.


## Retiro definitivo de mensajes de demostración y actualización del estado del MVP — 30/10/2026
Se sincronizó el código con la regla de iniciar conversaciones reales sin datos simulados:
- **Conversación vacía por defecto:** Se eliminó la función `_defaultDemoMessages()` en `ConversationController`, estableciendo `initialMessages ?? const []` como estado inicial sin precargas artificiales.
- **Suite de pruebas desacoplada de la demo:** Se reescribieron las aserciones de `test/conversation_test.dart` para validar el estado limpio inicial y las interacciones dinámicas reales (redacción de mensajes, selector de turno e indicadores de audio).
- **Aislamiento en proveedores de servicios:** Se actualizaron `ttsServiceProvider` y `sttServiceProvider` en `services_providers.dart` para asegurar compatibilidad transparente de los dobles de prueba (`MockTtsService` y `MockSttService`) en el entorno automatizado.
- **Actualización de documentación:** Se actualizó `README.md` reconociendo que Puente avanzó de un prototipo preliminar a un MVP funcional en desarrollo activo, con 64 pruebas automatizadas en verde y verificación estática sin incidencias.

## Eliminación de deuda técnica: permisos de Bluetooth y mocks en producción — 30/10/2026
Se corrigieron dos fuentes críticas de deuda técnica:
1. **Permisos innecesarios de Bluetooth:** Se eliminaron las declaraciones `BLUETOOTH`, `BLUETOOTH_ADMIN` y `BLUETOOTH_CONNECT` de `AndroidManifest.xml`. Puente solo solicita los permisos imprescindibles para su funcionamiento (`RECORD_AUDIO`, `VIBRATE`, `INTERNET`), fortaleciendo la promesa de privacidad del usuario.
2. **Aislamiento de dobles de prueba vía Riverpod:** Se eliminó la verificación de `Platform.environment['FLUTTER_TEST']` y la importación de `dart:io` de `services_providers.dart` y `main.dart`. En el código productivo los proveedores instancian exclusivamente los servicios reales. En las pruebas automáticas se inyectan dobles de prueba de forma explícita mediante `ProviderScope(overrides: createTestOverrides(), ...)` a través del helper `test/helpers/test_overrides.dart`.

## Consolidación del diseño visual y accesibilidad sin dependencia de ilustraciones — 02/11/2026
Aprobada la consolidación de la interfaz para que el diseño esté sólidamente planteado y sea accesible de manera nativa sin requerir réplicas de ilustraciones o imágenes conceptuales:
- **Independencia de assets gráficos:** Se confirmó que la interfaz se sostiene con total claridad mediante estructura de layout, componentes de Material, jerarquía tipográfica e íconos semánticos, usando fallbacks vectoriales ante la ausencia de archivos PNG.
- **Escalado accesible respetando el sistema operativo:** En `main.dart` se corrigió la aplicación de `TextScaler`: la preferencia del usuario (0.9, 1.0, 1.15) ahora escala multiplicativamente sobre la configuración de accesibilidad del sistema (`systemFactor * preferences.textScale`), evitando anular o reducir el tamaño de fuente elegido en iOS o Android por personas con baja visión.
- **Contraste WCAG AA:** Se ajustó la paleta en `AppColors`: `textMutedLight` se elevó a `#5A6F7B` (>4.6:1 sobre blanco) y `textMutedDark` a `#8BA0AC`, cumpliendo el estándar WCAG AA para textos legibles sin perder la jerarquía visual.
- **Áreas táctiles accesibles (48×48 dp):** Se fijó `minimumSize: const Size(48, 48)` en controles de navegación rápida como el botón «Omitir» del Onboarding, garantizando facilidad de toque con una sola mano.
- **Estado inicial en Conversación:** Al estar vacía la conversación, se presenta un estado visual limpio y orientativo («Conversación iniciada») que guía a la persona a escribir o activar el micrófono sin parecer una pantalla congelada ni depender de mensajes falsos de demo.
- **Fallbacks tipográficos móviles:** Se removieron palabras clave web CSS (`-apple-system`, `sans-serif`) de `AppTypography.fontFallback`, dejando fuentes estándar nativas (`Roboto`, `Segoe UI`, `Helvetica Neue`, `Arial`).

## Limpieza de flujos rotos y conexión de preferencias (Paso 1) — 11/11/2026
Se aprobó y ejecutó la limpieza de flujos desconectados y controles vacíos:
1. **Inicio (`HomeScreen`):** Se reemplazó la tarjeta aislada «Confirmar datos» (ex-«Comprar») por un acceso directo a **«Mostrar mensaje»** (`ShowMessageScreen` con edición inline cuando inicia vacío), dejando la confirmación escrita dentro del contexto real de `ConversationScreen`.
2. **Conexión de «Expresar» desde Inicio:** `HomeScreen` ahora recoge el texto elegido en `ExpressionScreen` y ofrece llevarlo a `ConversationScreen(initialContext: ...)` o mostrarlo en grande en `ShowMessageScreen`, evitando que el borrador se pierda al volver.
3. **Alternativas locales en `Expresar`:** Se ajustó `ExpressionAlternatives` para detectar consultas sin signo `?` y expresiones reales de duda sin falsos positivos en saludos simples, aclarando explícitamente en la UI que son sugerencias locales sin IA externa.
4. **Avisos no invasivos en `ShowMessageScreen`:** Se reemplazó el `SnackBar` inferior al reproducir audio por `TopAlertBanner`, evitando tapar los botones «Reproducir» y «Girar 180°».
5. **Preferencias conectadas:** Se vinculó «Reproducir mensajes» (`readMessages`) a `ConversationController` y `ShowMessageScreen`; «Vibrar al terminar de transcribir» (`vibrateAtEnd`) a `ConversationController`; «Velocidad de voz» (`speechRate` en `AppPreferencesStore`) a `TtsService.setSpeechRate`; y «Editar frases» a `QuickPhrasesSheet` con opción «Restaurar predeterminadas». Se reemplazaron el switch falso de privacidad y la flecha vacía de idioma por filas informativas transparentes.

## Mejoras dentro de Conversación: detección ampliada y flujos con el interlocutor (Paso 2) — 11/11/2026
Se completaron las mejoras dentro de la conversación presencial:
1. **Detección ampliada y confirmación por ítem:** `SensitiveDataDetector` ahora reconoce fechas (numéricas y en español como «15 de noviembre») y horarios (`9:41`, `18 hs`) además de importes, asignando el `DataKind` correspondiente sin confundir fechas/horarios con montos. `DataComparator` incorpora reconocimiento de meses en español y formato `hs`. Al tocar una tarjeta con múltiples ítems, `DetectedItemPickerSheet` permite elegir qué dato contrastar individualmente hasta confirmar todos.
2. **Accesos rápidos en estado vacío:** Cuando la conversación inicia vacía, presenta tres acciones de un toque: «Mostrar mi presentación», «Elegir frase rápida» (integrando `QuickPhrasesSheet` directamente en la charla) y «Escuchar al interlocutor».
3. **Flujo directo para el interlocutor:** Se incorporó el botón «Pasar para escribir» (`InterlocutorWriteSheet`, con rotación 180°) para que la otra persona responda cómodamente sin depender de entender los chips internos de turno.
4. **Confirmación rápida guiada:** Si se pulsa el acceso rápido «Confirmar» con datos pendientes, abre la confirmación del último dato detectado; si no hay datos previos, permite optar entre «Pedirle que escriba el dato» (`InterlocutorDataRequestSheet`, con giro 180° y registro explícito en la conversación) o «Comparar un dato que escuché» en `ConfirmationScreen`.
5. **Contraste de advertencia:** Se aplicó `AppColors.warningTextLight` en la etiqueta «Sin confirmar» de `DetectedInfoCard` y `ConfirmationScreen` para mejorar el contraste en modo claro.

## Limpieza visual y accesibilidad en Conversación — 11/11/2026
Se reestructuró la presentación de `ConversationScreen` y `DetectedInfoCard` siguiendo las guías de `DISENO_VISUAL.md`, `TIPOGRAFIA.md` y `ACCESIBILIDAD.md` sin incorporar dependencias externas:
1. **Identificación y tipografía en burbujas (`ConversationMessageBubble`):** Cada burbuja muestra en texto al participante (`Vos` / `Otra persona`) junto a la hora (`12` px `metadata`), cuerpo en `18` px (`AppTypography.conversation`) y colores desde `AppColors.bubbleUser*` y `AppColors.bubbleOther*`.
2. **Tarjetas de confirmación y STT:** `DetectedInfoCard` adopta superficie plana sin sombra, cabecera semántica, etiqueta `Sin confirmar` en `12` px e indicación explícita de acción (`Tocar para confirmar por escrito` / `Tocar para revisar`). El bloque de transcripción pendiente usa tokens adaptados a modo claro/oscuro y evita que el botón `Agregar` se estire al ancho completo dentro del `Wrap`.
3. **Panel inferior ordenado y áreas táctiles `>= 48` dp (`ConversationBottomPanel`):** Se pasó de cuatro filas apiladas a tres bandas: accesos de 1 toque (`Presentarme`, `No entendí`, `Confirmar`), selector segmentado de turno (`Yo` / `La otra persona`) + `Pasar para escribir` sobre el compositor unificado (botón de envío `48×48`), y barra de micrófono/audio que se pliega al abrirse el teclado manteniendo un acceso compacto de micrófono y sin duplicar avisos flotantes al iniciar/detener escucha.
4. **Tokens en modo oscuro (`AppColors`):** Se incorporaron `primaryTealOnDark`, `warningTextDark`, `successTextDark` y `errorTextDark` con contraste WCAG AA (`>= 4.5:1`) sobre superficies oscuras.

## Presentación personal editable y contraste en modo oscuro en el resto de pantallas — 12/11/2026
1. **Presentación personal persistente (`AppPreferencesStore`, `SettingsScreen`, `ShowMessageScreen`, `HomeScreen`, `ConversationScreen`):** `AppPreferences` incorpora `presentationText` (persistida localmente en `SharedPreferences`, con opción de restaurar al texto predeterminado). Puede editarse en Preferencias («Texto de presentación») o guardarse de forma opt-in al editar desde `ShowMessageScreen`, y tanto «Ver ejemplo» en Inicio como «Presentarme» en Conversación consumen el texto personalizado.
2. **Contraste WCAG AA en modo oscuro:** Se ajustaron `outlinedButtonTheme` y `textButtonTheme` de `AppTheme.darkTheme` a `AppColors.primaryTealOnDark`, y se migraron los textos e íconos de acento/estado en `HomeScreen`, `ConfirmationScreen`, `ExpressionScreen` (`_AmbiguityNotice` y `_SuggestionCard`), `SettingsScreen`, `OnboardingScreen`, `QuickPhrasesSheet`, `NotUnderstoodSheet`, `PuenteBrandLogo` y `conversation_sheets.dart` hacia tokens legibles sobre fondos oscuros.
3. **Cobertura ampliada:** Se agregaron pruebas dedicadas para `AppPreferencesStore`, `ShowMessageScreen` y `ExpressionScreen`, además de validaciones en modo oscuro, pantalla `320×568` y escala de texto `1.35x` en las pantallas principales.

## Asistencia opcional con Gemini en Expresar vía Supabase Edge Function — 12/11/2026
Aprobada la integración de IA externa en **Expresar** conectada al proyecto Supabase `LeadRadar` (`expression-assist`):
1. **Asistencia opcional y respeto de la escritura:** Expresar mantiene intacto el texto original y las alternativas locales offline (`ExpressionAlternatives`). La ayuda de Gemini se activa de forma explícita y opt-in (`useExpressionAi` en `AppPreferences`, desactivada por defecto) con diálogo de consentimiento previo y control en Preferencias.
2. **Proxy seguro sin claves en el cliente:** La aplicación Flutter no almacena ninguna clave de Gemini. Envía únicamente el borrador puntual (hasta 500 caracteres) al endpoint proxy en Supabase Edge Functions (`verify_jwt: false` validando la clave publicable de cliente en header `apikey`), que consume `gemini-3.8-flash` con `store: false`, sin retención de conversaciones y sin registrar el contenido del usuario.
3. **Contrato estructurado, ambigüedad e incertidumbre:** El proxy devuelve JSON estructurado (`ExpressionAssistResult`) con variantes claras en español (artículos, pronombres `el/la/los/las`, concordancia y claridad conservando cifras y negaciones), interpretaciones para elegir cuando exista ambigüedad (`has_ambiguity`, `interpretations`) y nota honesta de incertidumbre (`uncertainty_note`).
4. **Resiliencia offline:** Si falla la red, falta configurar la clave en servidor o la IA no responde, Expresar informa sin bloquear y ofrece respaldo inmediato con `ExpressionAlternatives` locales y el texto original.

## Paquete de animaciones y micro-interacciones accesibles — 12/11/2026
Aprobada la incorporación de 6 mejoras de animación nativas en Flutter (sin dependencias externas) respetando siempre la opción del sistema «Reducir movimiento» (`MediaQuery.disableAnimations`):
1. **Transiciones globales entre pantallas (`AppTheme`):** Se configuró `PageTransitionsTheme` en temas claro y oscuro con `_PuentePageTransitionsBuilder` (desvanecimiento + leve desplazamiento horizontal) en Android/Desktop y `CupertinoPageTransitionsBuilder` en iOS/macOS.
2. **Giro suave y transición de edición (`ShowMessageScreen`):** Se reemplazó la rotación instantánea por `AnimatedRotation` (320 ms `easeOutCubic`) al pulsar «Girar 180°», junto con `AnimatedSwitcher` entre vista de lectura y editor inline.
3. **Onda única en micrófono activo (`ListeningWaveIndicator` en `ConversationBottomPanel`):** Se descartó el halo concéntrico externo para mantener una interfaz serena sin sobrecarga visual, dejando únicamente la onda animada interna con control de ciclo de vida (`WidgetsBindingObserver`) y respeto a `disableAnimations`.
4. **Micro-interacción táctil (`TapScale`):** Widget reutilizable (`Listener` + `AnimatedScale`) aplicado en tarjetas y CTAs de Inicio, botones rápidos y micrófono en Conversación, tarjetas de Expresar y navegación del Onboarding sin interferir con `InkWell` ni lectores de pantalla.
5. **Aparición suave en «Expresar» y «Confirmar información»:** Se reutilizó `SmoothEntrance` (extraído de las burbujas de conversación y con soporte de retardo escalonado sin `Timer`) en tarjetas de propuestas y avisos de Expresar, y `AnimatedSize` + `AnimatedSwitcher` en los resultados de comparación.
6. **Transiciones e indicadores en `OnboardingScreen`:** Píldoras indicadoras expansibles (`AnimatedContainer`), `AnimatedSwitcher` para «Volver» y «Siguiente/Empezar», y escala/opacidad suave en ilustraciones vinculadas al `PageController`.

## Optimización de contraste en textos pequeños y Modo Sol para exteriores — 12/11/2026
1. **Contraste WCAG AAA en textos pequeños y botones en modo claro:** Se adoptó `AppColors.primaryTealDark` (`#095A62`, contraste $>7.4:1$) en `outlinedButtonTheme` y `textButtonTheme` de `AppTheme.lightTheme`, en el texto del logotipo `PuenteBrandLogo`, en los tags de pasos del Onboarding (`onboarding_screen.dart`), en los íconos de cabecera de `NotUnderstoodSheet`, `QuickPhrasesSheet`, `ConversationSheets` y en las filas de información/acción de `SettingsScreen`, garantizando nitidez absoluta incluso en pantallas de baja resolución o fuentes pequeñas.
2. **Modo sol de contraste extremo en `ShowMessageScreen`:** Se incorporó un botón de acceso directo en la barra superior («Activar modo sol / máximo contraste», ícono `Icons.wb_sunny_*`) para situaciones de lectura bajo luz solar directa o en exteriores. Al activarse, la pantalla conmuta a fondo blanco puro (`#FFFFFF`) con tipografía en negro puro (`#000000`, peso `w900`), logrando la relación de contraste fotópico máxima ($21:1$) y bordes sólidos de alto impacto visual sin alterar el flujo de edición ni la rotación cara a cara.
