# Instrucciones para agentes de IA — Puente

## Antes de cualquier tarea
1. Leer `README.md`, `docs/PRODUCTO.md`, `docs/DECISIONES.md` y el documento correspondiente a la tarea.
2. Verificar el estado real del repositorio; no asumir que existe código Flutter.
3. Respetar las decisiones aprobadas. Ante ambigüedades de producto, proponer alternativas y solicitar decisión, sin inventar requisitos.
4. Trabajar en cambios pequeños y verificables. Explicar archivos afectados, pruebas realizadas y limitaciones.
5. No incorporar funcionalidades futuras al MVP sin aprobación.

## Misión
Permitir que una persona pueda desenvolverse con mayor autonomía en situaciones cotidianas mediante comunicación accesible. El foco inicial son personas sordas o con dificultades auditivas, reconociendo la diversidad de preferencias y lenguas.

## Reglas innegociables
- No reformular, traducir ni enviar un mensaje ambiguo como si su intención fuera segura. Mostrar opciones y solicitar confirmación.
- Conservar el texto original y permitir descartarlo o editarlo.
- No inventar palabras ausentes en una transcripción ni ocultar incertidumbre.
- Precios, horarios, fechas, cantidades, direcciones e indicaciones sensibles requieren posibilidad de confirmación explícita por escrito; la coincidencia de textos no garantiza verdad.
- El botón «No entendí» debe ser visible en la conversación y ofrecer repetir, escribir, hablar más despacio o explicar de otra forma.
- Presentación personal opcional, editable, con acceso de un toque; nunca mostrarla automáticamente.
- No exigir cuenta para las funciones esenciales ni que el interlocutor instale la app.
- No grabar, almacenar o enviar conversaciones a terceros sin información clara, consentimiento y control de la persona usuaria.
- No exponer claves de API en la aplicación cliente; usar backend seguro si se integra IA externa.
- Evitar afirmar que Puente garantiza seguridad comercial, elimina discriminación o reemplaza profesionales/intérpretes.
- No asumir que toda persona sorda utiliza lengua de señas ni que necesita corregir su escritura.

## Tecnologías candidatas
Flutter/Dart, Riverpod y módulos por funcionalidad. Reconocimiento de voz, síntesis de voz y servicios de IA se elegirán tras pruebas de viabilidad, privacidad y costos. No tratar elecciones propuestas como aprobaciones definitivas.

## Flujo de trabajo
- Identificar el caso de uso, criterio de aceptación y riesgos.
- Proponer un plan breve antes de cambios grandes.
- Implementar accesibilidad desde el inicio, no como parche.
- Añadir pruebas cuando exista código.
- Actualizar documentación y `docs/DECISIONES.md` cuando se aprueben cambios de producto.
- Si no hay acceso a hardware, servicios o credenciales, indicarlo; no fingir pruebas.

## Documentos
Consultar `docs/PRODUCTO.md`, `docs/FUNCIONALIDADES.md`, `docs/FLUJOS_USUARIO.md`, `docs/ACCESIBILIDAD.md`, `docs/ARQUITECTURA.md` y `docs/DECISIONES.md`.

## Diseño aprobado
Consultar obligatoriamente `docs/DISENO_VISUAL.md` y `docs/PLAN_IMPLEMENTACION_UI.md` para tareas de interfaz. Las seis pantallas y su dirección visual están aprobadas; todavía no hay autorización para escribir código.

## Tipografía obligatoria
La familia visual aprobada es **Figtree Variable**. Antes de implementar UI, consultar `docs/TIPOGRAFIA.md`. No sustituirla por SF Pro o Roboto como fuente principal sin aprobación; mantener fallback del sistema. El archivo TTF aún debe incorporarse legalmente al proyecto.
