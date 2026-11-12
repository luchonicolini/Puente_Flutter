import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/storage/app_preferences_store.dart';
import 'package:puente/core/theme/app_theme.dart';
import 'package:puente/features/conversation/conversation_screen.dart';
import 'package:puente/features/expression/expression_screen.dart';
import 'package:puente/features/home/home_screen.dart';
import 'package:puente/features/settings/settings_screen.dart';
import 'package:puente/features/show_message/show_message_screen.dart';

import 'helpers/test_overrides.dart';

void main() {
  Widget createHomeScreen({List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: [
        ...createTestOverrides(),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }

  testWidgets('HomeScreen renders all elements matching the visual mockup',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    // 1. Marca y ajustes en cabecera
    expect(find.text('Puente'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    // 2. Titular y subtítulo
    expect(find.textContaining('Comunicarnos\nhace todo más fácil.'), findsOneWidget);
    expect(find.textContaining('Escribí, hablá o usá frases rápidas'), findsOneWidget);

    // 3. Tarjeta destacada Iniciar conversación
    expect(find.textContaining('Iniciar\nconversación'), findsOneWidget);
    expect(find.text('Escribí, hablá y escuchá'), findsOneWidget);

    // 4. Tres tarjetas secundarias verticales
    expect(find.text('Frases rápidas'), findsOneWidget);
    expect(find.text('Mensajes útiles para el día a día'), findsOneWidget);

    expect(find.text('Mostrar mensaje'), findsOneWidget);
    expect(
      find.text('Escribí un texto grande para mostrar al instante'),
      findsOneWidget,
    );

    expect(find.text('Expresar'), findsOneWidget);
    expect(find.text('Te ayudamos a redactar tu mensaje'), findsOneWidget);

    // 5. Banner de presentación personal
    expect(
      find.textContaining('Podés mostrar un mensaje de presentación'),
      findsOneWidget,
    );
    expect(find.text('Ver ejemplo'), findsOneWidget);
  });

  testWidgets('Tapping Iniciar conversación opens ConversationScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Iniciar\nconversación'));
    await tester.pumpAndSettle();

    expect(find.byType(ConversationScreen), findsOneWidget);
  });

  testWidgets('Tapping Expresar opens ExpressionScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Expresar'));
    await tester.tap(find.text('Expresar'));
    await tester.pumpAndSettle();

    expect(find.byType(ExpressionScreen), findsOneWidget);
  });

  testWidgets('Tapping Ver ejemplo opens ShowMessageScreen with presentation',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    final verEjemploFinder = find.text('Ver ejemplo');
    await tester.ensureVisible(verEjemploFinder);
    await tester.tap(verEjemploFinder);
    await tester.pumpAndSettle();

    expect(find.byType(ShowMessageScreen), findsOneWidget);
    expect(find.textContaining('Hola, soy sordo.'), findsOneWidget);
  });

  testWidgets('Tapping Settings icon opens SettingsScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('Tapping Mostrar mensaje lets user write and show text in large view',
      (WidgetTester tester) async {
    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mostrar mensaje'));
    await tester.pumpAndSettle();

    expect(find.byType(ShowMessageScreen), findsOneWidget);
    expect(find.text('Mostrar en grande'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '¿Aceptan débito?');
    await tester.tap(find.text('Mostrar en grande'));
    await tester.pumpAndSettle();

    expect(find.text('¿Aceptan débito?'), findsOneWidget);
    expect(find.text('Reproducir'), findsOneWidget);
    expect(find.text('Girar 180°'), findsOneWidget);
  });

  testWidgets('Expresar from HomeScreen passes selected text to ConversationScreen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Expresar'));
    await tester.tap(find.text('Expresar'));
    await tester.pumpAndSettle();

    expect(find.byType(ExpressionScreen), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'Necesito saber el horario de atención',
    );
    await tester.pump();

    await tester.tap(find.text('Usar mi texto original'));
    await tester.pumpAndSettle();

    expect(find.text('¿Cómo querés usar tu mensaje?'), findsOneWidget);
    await tester.tap(find.text('Llevar a conversación'));
    await tester.pumpAndSettle();

    expect(find.byType(ConversationScreen), findsOneWidget);
    expect(
      find.text('Necesito saber el horario de atención'),
      findsOneWidget,
    );
  });

  testWidgets('Ver ejemplo muestra presentación personalizada y modo oscuro 1.35x sin desbordamientos',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320 * 3, 568 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: createTestOverrides(),
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          builder: (context, child) {
            final data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(textScaler: const TextScaler.linear(1.35)),
              child: child!,
            );
          },
          home: const HomeScreen(
            preferences: AppPreferences(
              presentationText: 'Hola, prefiero leer todo por escrito.',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final verEjemploFinder = find.text('Ver ejemplo');
    await tester.ensureVisible(verEjemploFinder);
    await tester.tap(verEjemploFinder);
    await tester.pumpAndSettle();

    expect(
      find.text('Hola, prefiero leer todo por escrito.'),
      findsOneWidget,
    );
  });
}
