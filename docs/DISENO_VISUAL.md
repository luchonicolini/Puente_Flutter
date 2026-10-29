# Diseño visual aprobado — Puente

Estado: **dirección visual aprobada por el usuario** a partir del mockup de seis pantallas (29/10/2026). El mockup es una referencia conceptual, no una captura de una app implementada. Los detalles de contenido y funcionamiento se ajustan a los requisitos de accesibilidad.

## Identidad visual
- Sensación: cálida, confiable, moderna, sencilla y sin ruido.
- Color principal: verde petróleo/teal `#0D7E88`; variantes oscuras y claras deben pasar pruebas de contraste.
- Fondos: blanco y gris muy claro; mensajes de usuario con tinte teal suave, interlocutor en gris claro.
- Texto principal: azul marino muy oscuro; secundarios en gris suficientemente contrastado.
- Tarjetas y botones: esquinas redondeadas; sin sombras pesadas ni decoración excesiva.
- Tipografía: **Figtree Variable** como fuente principal, con fallback del sistema; tamaño escalable. Ver `docs/TIPOGRAFIA.md`.
- Iconos: trazos sencillos con etiquetas de texto, no depender solo del icono.
- Componentes: encabezados compactos, CTA teal dominante, filas de acciones, campos grandes, avisos discretos y confirmaciones claras.
- Respetar modo oscuro, ajustes de fuente, áreas seguras, teclado y tamaños pequeños.

## Referencia de composición
El diseño visual aprobado muestra, en orden, Inicio, Conversación, Mostrar mensaje, Expresar, Confirmar información y Preferencias. El mockup fue compartido en la conversación de diseño; este repositorio registra sus especificaciones textuales. No asumir que el PNG está incluido en GitHub.

## 1. Inicio
- Logo Puente y acceso a preferencias arriba.
- Título de bienvenida y descripción breve.
- Botón principal grande «Iniciar conversación» con icono y flecha.
- Accesos secundarios: «Frases rápidas», «Expresar» y «Comprar» (atajo a funciones de confirmación dentro de conversación, no módulo independiente).
- Bloque inferior discreto que explica que se puede mostrar una presentación.
- Sin cuenta obligatoria.

## 2. Conversación — pantalla central
- Encabezado con volver, título «Conversación» y acción para finalizar/descartar con confirmación.
- Historial de burbujas: mensajes de usuario teal claro y del interlocutor gris; identificar participantes también por texto.
- En datos importantes, tarjeta contextual «Información detectada» con opción «Confirmar» y estado «Sin confirmar».
- Acciones persistentes y accesibles: «Presentarme», «No entendí», «Confirmar».
- Campo «Escribí tu mensaje…» con botón enviar, opción de mostrar texto grande y acceso a Expresar.
- Micrófono de acción explícita, con estado visible y posibilidad de detener; nunca iniciar por sí solo.
- Reproducción TTS opcional. No saturar con iconos redundantes.
- Estados: micrófono apagado/escuchando, texto parcial, error de transcripción, sin conexión, confirmación pendiente, teclado visible.
- «No entendí» siempre accesible incluso con teclado; usar hoja inferior de cuatro frases offline.

## 3. Mostrar mensaje
- Pantalla casi completa, texto grande, alto contraste y centrado.
- Ejemplo de presentación opcional y editable: «Hola, soy sordo. Podemos comunicarnos por escrito o podés hablar y mi teléfono mostrará lo que decís».
- Acciones inferiores «Reproducir», «Girar 180°», «Editar».
- La presentación nunca se abre automáticamente; puede mostrar cualquier mensaje escrito, no solo la presentación.
- Mantener accesibilidad y orientación controlada por usuario.

## 4. Expresar
- Título «Expresar» y explicación breve.
- Área «Tu mensaje» que preserva exactamente el texto original.
- Botón «Mejorar con IA»; indicador de carga y error no bloqueante.
- Sugerencias en tarjetas seleccionables; edición antes de enviar/mostrar/copiar.
- «Usar mi texto original» claramente disponible.
- Si la intención es ambigua, pedir aclaración con interpretaciones alternativas, nunca corregir silenciosamente.

## 5. Confirmar información
- Encabezado y selector de tipo: «Importe», «Fecha», «Horario», «Otro».
- Valor detectado grande y estado «Sin confirmar».
- Explicación: «Este dato fue detectado en la conversación. Pedile a la otra persona que lo escriba para confirmarlo».
- Campo para dato escrito por interlocutor, comparación y resultados «Coinciden» / «Son diferentes».
- Siempre aclarar: coincidir no garantiza que el dato sea verdadero o justo.
- Guardar solo un dato concreto con consentimiento explícito; no guardar conversación entera.
- Si se transcriben instrucciones médicas, derivar a confirmación profesional sin inventar consejo.

## 6. Preferencias
- «Apariencia»: tamaños de texto, claro/oscuro/sistema.
- «Comunicación»: TTS, velocidad de voz, vibración y controles accesibles.
- «Idioma»: español (Argentina) como valor inicial propuesto.
- «Frases rápidas»: editar y ordenar frases offline.
- «Privacidad»: almacenamiento opt-in, borrar datos, información sobre servicios externos.
- Ajustes persistidos localmente cuando sea posible.

## Navegación
Inicio → Conversación → Mostrar mensaje / Confirmar información → volver a Conversación.
Inicio → Expresar; desde el compositor de Conversación también abrir Expresar y volver con texto aprobado.
Inicio → Preferencias. «Presentarme» abre Mostrar mensaje con frase editable.
«Comprar» abre conversación con frases/contexto de precio, no crea una séptima pantalla principal.

## Reglas de implementación visual
- Priorizar funciones esenciales en la zona inferior alcanzable con una mano.
- Evitar que el teclado tape «No entendí».
- Controles táctiles con objetivos suficientemente amplios y contraste comprobado.
- Soportar escalado de texto sin truncar botones críticos.
- Comprobar en pantallas iPhone y Android reales; el mockup no es especificación exacta de dimensiones.
- Mantener consistencia de componentes y estados vacíos, carga y error.

## Tipografía aprobada
Usar **Figtree Variable** como fuente principal en todas las pantallas. Consultar escala, pesos, line-height y reglas de accesibilidad en [`TIPOGRAFIA.md`](TIPOGRAFIA.md). La indicación anterior de tipografía del sistema queda reemplazada por Figtree como primera opción, con fallback del sistema.
