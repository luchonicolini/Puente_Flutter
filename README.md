# Puente

**Tu independencia, tu manera de comunicarte.**

Puente es una aplicación móvil de accesibilidad, prevista para iOS y Android con Flutter, cuyo propósito es ayudar a personas sordas o con dificultades auditivas a desenvolverse con mayor autonomía en situaciones cotidianas. No pretende corregir a las personas: busca reducir barreras de comunicación entre interlocutores.

## Estado
**Fase de definición de producto.** No hay aplicación implementada ni funcionalidades verificadas. Las descripciones son requisitos propuestos, no capacidades existentes.

## Principios
- La persona usuaria conserva el control de lo que comunica.
- Interacción híbrida: escribir, mostrar texto, escuchar mediante transcripción y responder con voz sintetizada.
- La otra persona no necesita instalar Puente.
- Presentación opcional, accesible con un toque.
- Botón permanente «No entendí» para pedir repetición, escritura o aclaración.
- Confirmación explícita de precios, fechas, horarios, cantidades y direcciones; nunca asumir que una transcripción es correcta.
- Accesibilidad, privacidad, consentimiento y alternativas cuando la IA falle.

## Documentación
- [Instrucciones para agentes](AGENTS.md)
- [Visión y alcance](docs/PRODUCTO.md)
- [Requisitos funcionales](docs/FUNCIONALIDADES.md)
- [Flujos y pantallas](docs/FLUJOS_USUARIO.md)
- [Accesibilidad y privacidad](docs/ACCESIBILIDAD.md)
- [Arquitectura propuesta](docs/ARQUITECTURA.md)
- [Decisiones y pendientes](docs/DECISIONES.md)

## Desarrollo
Antes de escribir código, leer `AGENTS.md` y los documentos relevantes. No iniciar implementación ni elegir servicios definitivos sin acordar el alcance.

## Diseño de las seis pantallas
- [Diseño visual aprobado](docs/DISENO_VISUAL.md)
- [Plan de implementación de UI](docs/PLAN_IMPLEMENTACION_UI.md)

## Onboarding
El flujo de bienvenida de tres pantallas está especificado en [ONBOARDING.md](docs/ONBOARDING.md). Sus imágenes individuales están pendientes de subir al repositorio.

## Skills para agentes
Cinco procedimientos especializados están versionados en [`.agents/skills/`](.agents/skills/). Ver `AGENTS.md` para seleccionar la skill adecuada antes de cada tarea.
