# Puente

**Tu independencia, tu manera de comunicarte.**

Puente es una aplicación móvil de accesibilidad desarrollada en Flutter para iOS y Android, cuyo propósito es ayudar a personas sordas o con dificultades auditivas a desenvolverse con mayor autonomía en situaciones cotidianas. No busca corregir la forma de expresarse de las personas: busca reducir y eliminar barreras de comunicación entre interlocutores.

## Estado
**MVP funcional en desarrollo activo.** Puente ha superado la etapa de maqueta estática o prototipo preliminar: cuenta con una arquitectura por capas (`features/`, `core/`, `domain/`), gestión reactiva de estado con Riverpod y funcionalidades reales conectadas para resolver situaciones cotidianas con foco en privacidad, autonomía y accesibilidad.

### Funcionalidades implementadas
- **Seis pantallas principales:** Inicio, Conversación, Mostrar mensaje en pantalla completa (con rotación de texto 180° para lectura cara a cara), Expresar (asistencia local de redacción), Confirmar información y Preferencias.
- **Conversación limpia e interactiva:** La conversación inicia vacía por defecto, sin mensajes simulados de demostración. Incorpora historial reactivo, animación de entrada para nuevos mensajes y selector explícito de turno («Yo» / «La otra persona») en el compositor, permitiendo que ambas partes puedan escribir directamente.
- **Ciclo de vida y privacidad de audio:** Control estricto de micrófono (`speech_to_text`) y síntesis de voz (`flutter_tts`) bajo solicitud explícita. El micrófono y la voz se detienen al pausar la app o salir de la conversación. El control de silencio detiene el micrófono y bloquea nuevas escuchas, pero no impide reproducir un mensaje con TTS. Las transcripciones no se agregan a ciegas: quedan como «sin confirmar» hasta su revisión explícita.
- **Detección y contrastación segura de datos:** Comparación de valores estructurada por tipo (`importe`, `fecha`, `horario`, `texto`) adaptada a formatos numéricos locales e internacionales para evitar falsos positivos (como 3,5 vs 35). Los datos detectados son editables y la pantalla de confirmación inicia limpia.
- **Avisos superiores no invasivos (`TopAlertBanner`):** Mensajes informativos y de advertencia flotantes en la parte superior que no bloquean los controles críticos de audio ni el compositor de texto, con soporte de accesibilidad y descartabilidad inmediata.
- **Persistencia local y offline:** Almacenamiento local mediante `shared_preferences` para ajustes de tema, escala de texto, estado del onboarding y repositorio editable de frases rápidas (`QuickPhrasesStore`). No se graban ni envían conversaciones a servidores externos.
- **Respuesta háptica (`HapticService`):** Señales táctiles diferenciadas al activar el micrófono, detenerlo y recibir mensajes del interlocutor.
- **Onboarding de bienvenida:** Flujo inicial de tres pantallas con recursos gráficos incorporados, totalmente omitible y sin exigencia de registro.
- **Tipografía aprobada:** Tipografía Figtree Variable con fallback al sistema operativo y cobertura completa en el análisis estático.

### Pendiente de validar o completar
- Pruebas en hardware físico Android e iOS para calibrar micrófonos, motores STT/TTS nativos y respuesta táctil en entornos con ruido ambiente.
- Sesiones de validación con personas usuarias (personas sordas o con dificultades auditivas en contextos reales de uso).
- Auditoría profunda de accesibilidad (ajuste fino de contrastes de color WCAG AA y escalabilidad relativa del texto respetando la configuración del sistema operativo).
- Evaluación y definición rigurosa ante cualquier eventual integración de servicios de IA externa en un backend seguro.

## Principios innegociables
- La persona usuaria conserva el control de lo que comunica.
- Interacción híbrida: escribir, mostrar texto, escuchar mediante transcripción y responder con voz sintetizada.
- La otra persona no necesita instalar Puente ni crear una cuenta.
- Presentación opcional, accesible con un toque y nunca mostrada de forma obligatoria.
- Botón permanente «No entendí» con opciones claras de aclaración (repetir, escribir, hablar más despacio, explicar de otra forma).
- Confirmación explícita de precios, fechas, horarios y cantidades sensibles; nunca asumir certeza sin validación.
- Privacidad absoluta: sin almacenamiento ni transmisión oculta de audio o conversaciones.

## Desarrollo y verificación

Para inicializar el proyecto:

```bash
flutter pub get
flutter run
```

### Suite de pruebas automáticas
Puente cuenta con una suite completa de pruebas unitarias, de reglas de dominio y de widgets que validan el comportamiento real de la aplicación sin depender de datos de prueba precargados.

Para ejecutar la verificación completa:

```bash
flutter test
flutter analyze
```

La suite cubre:
- Estados de conversación, envío y recepción de mensajes, y control de audio en `ConversationController`.
- Flujos de navegación y renderizado en `ConversationScreen`, `HomeScreen`, `ConfirmationScreen`, `TopAlertBanner` y `OnboardingScreen`.
- Aislamiento de lógica en `DataComparator` y `SensitiveDataDetector`, previniendo falsos positivos numéricos.
- Almacenamiento local de frases rápidas y preferencias del sistema.

## Documentación del proyecto
- [Instrucciones para agentes](AGENTS.md)
- [Registro de decisiones](docs/DECISIONES.md)
- [Visión y alcance](docs/PRODUCTO.md)
- [Requisitos funcionales](docs/FUNCIONALIDADES.md)
- [Flujos y pantallas](docs/FLUJOS_USUARIO.md)
- [Accesibilidad y privacidad](docs/ACCESIBILIDAD.md)
- [Arquitectura propuesta](docs/ARQUITECTURA.md)
- [Diseño visual aprobado](docs/DISENO_VISUAL.md)
- [Plan de implementación de UI](docs/PLAN_IMPLEMENTACION_UI.md)
- [Onboarding](docs/ONBOARDING.md)
- [Tipografía](docs/TIPOGRAFIA.md)
- [Política de privacidad pública (Google Play)](https://luchonicolini.github.io/Certificaciones-URL/puente/privacy.html)
- [Términos de uso públicos](https://luchonicolini.github.io/Certificaciones-URL/puente/terms.html)
- [Página de soporte](https://luchonicolini.github.io/Certificaciones-URL/puente/support.html)
- Procedimientos especializados para agentes en [`.agents/skills/`](.agents/skills/).
