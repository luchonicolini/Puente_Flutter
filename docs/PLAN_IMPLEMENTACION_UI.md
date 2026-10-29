# Plan de implementación UI (sin código aún)

## Objetivo
Reproducir la dirección visual aprobada de las seis pantallas en Flutter sin sacrificar accesibilidad ni asumir integraciones técnicas no decididas.

## Fase 1: cimientos
- Configurar proyecto Flutter cuando el usuario autorice desarrollo.
- Definir tokens de diseño (colores, tipografía, espaciados, radios), temas claro/oscuro y escalado.
- Crear navegación, componentes reutilizables y datos de demostración claramente identificados.
- Probar tamaños pequeños y lectores de pantalla.

## Fase 2: pantallas
1. Inicio y navegación.
2. Conversación con mensajes simulados, teclado, controles visibles y estados.
3. Mostrar mensaje con rotación opcional y tipografía grande.
4. Expresar con original, alternativas simuladas y confirmación.
5. Confirmar información con comparación de valores y advertencia de límites.
6. Preferencias con controles funcionales locales.

## Fase 3: capacidades reales
Integrar STT, TTS e IA solo después de elegir servicios, revisar permisos y privacidad, y validar costos y calidad. Las simulaciones nunca deben presentarse como capacidades productivas.

## Criterios de revisión
- Se reconocen visualmente las seis pantallas aprobadas.
- Navegación consistente y regreso al contexto.
- Acciones «No entendí» y «Presentarme» disponibles con un toque.
- El texto original de Expresar siempre puede recuperarse.
- No hay activación oculta de micrófono ni guardado automático de conversaciones.
- Confirmaciones distinguen detección, comparación y verificación explícita.
- Funciona con fuentes grandes, modo oscuro y sin red para funciones locales.

## Entrega esperada al agente
Antes de programar, presentar estructura de widgets, navegación, estados, dependencias propuestas, pruebas y dudas que requieran decisión. No iniciar desarrollo hasta nueva autorización.
