# Sistema tipográfico — Puente

## Fuente elegida
**Figtree Variable**, archivo previsto `Figtree-Variable.ttf`. Fuente principal para las seis pantallas, tanto en iOS como Android. Familia Flutter: `Figtree`.

**Estado:** Fuente incorporada físicamente en `assets/fonts/Figtree-Variable.ttf` bajo licencia SIL Open Font License (OFL) 1.1 (`assets/fonts/OFL.txt`) y registrada en `pubspec.yaml` bajo la familia `Figtree`. Aplicada en `AppTheme` con fallback al sistema operativo.

## Escala base (tamaños lógicos de Flutter)
| Token | Tamaño | Peso | Uso |
| --- | --- | --- | --- |
| display | 28 | 700 | Hero / titular principal |
| screenTitle | 22 | 600 | Título de pantalla |
| sectionTitle | 18 | 600 | Títulos de secciones |
| conversation | 18 | 400 | Mensajes de conversación |
| body | 16 | 400 | Texto general y formularios |
| button | 16 | 600 | Acciones principales |
| secondary | 14 | 400 | Ayudas y avisos |
| metadata | 12 | 500 | Hora y metadatos no esenciales |
| showMessage | 36–48 | 600–700 | Mostrar texto grande al interlocutor; ajustable y sin truncamiento |

## Pesos y espaciado
- Pesos habituales: 400 regular, 500 medium, 600 semibold, 700 bold.
- Altura de línea orientativa: 1.3–1.5 para lectura habitual; ajustar títulos y mensajes grandes por pruebas.
- Evitar texto totalmente en mayúsculas en bloques largos.
- No depender de una única medida fija: respetar escalado de texto del sistema y saltos de línea.
- Alineación izquierda para párrafos y conversación; centrar solo el mensaje grande cuando mejore la lectura.
- Evitar textos críticos por debajo de 14; 12 solo para metadatos prescindibles y siempre escalables.

## Accesibilidad
- Contraste mínimo objetivo: 4.5:1 para texto normal y 3:1 para texto grande, evaluado sobre los colores reales de cada tema.
- Probar tamaños de accesibilidad, alto contraste, modo oscuro y pantallas pequeñas.
- Nunca deshabilitar el escalado del sistema para preservar el mockup.
- Para «Mostrar mensaje», permitir aumentar el tamaño y desplazarse si el texto no entra.
- Fallback a tipografía del sistema cuando falte un glifo o recurso.

## Integración futura en Flutter (referencia, no implementada)
1. Añadir `assets/fonts/Figtree-Variable.ttf` desde fuente legítima junto a su licencia.
2. Registrar la familia `Figtree` en `pubspec.yaml`, incluyendo rango de pesos compatible con el archivo variable.
3. Aplicar `fontFamily: 'Figtree'` a `ThemeData` y a `TextTheme` compartido.
4. Centralizar tokens en un solo archivo de estilos y evitar tamaños dispersos.
5. Validar visualmente la fuente en Android e iOS y con escalado dinámico.

La tipografía no cambia la lógica de las seis pantallas ni autoriza empezar a programar.
