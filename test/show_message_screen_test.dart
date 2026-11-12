import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/services/services_providers.dart';
import 'package:puente/core/services/tts_service.dart';
import 'package:puente/core/storage/app_preferences_store.dart';
import 'package:puente/core/theme/app_theme.dart';
import 'package:puente/core/widgets/top_alert_banner.dart';
import 'package:puente/features/show_message/show_message_screen.dart';

import 'helpers/test_overrides.dart';

void main() {
  Widget createShowMessageScreen({
    String initialText = '',
    bool isPresentation = false,
    ValueChanged<String>? onSavePresentation,
    ThemeData? theme,
    double textScale = 1.0,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      key: UniqueKey(),
      overrides: [...createTestOverrides(), ...overrides],
      child: MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        builder: (context, child) {
          final data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          );
        },
        home: ShowMessageScreen(
          initialText: initialText,
          isPresentation: isPresentation,
          onSavePresentation: onSavePresentation,
        ),
      ),
    );
  }

  testWidgets('Permite girar 180°, cambiar tamaño y validar texto vacío', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createShowMessageScreen());
    await tester.pumpAndSettle();

    expect(find.text('Mostrar mensaje'), findsOneWidget);

    await tester.tap(find.text('Mostrar en grande'));
    await tester.pumpAndSettle();
    expect(
      find.text('Escribí un mensaje antes de mostrarlo en grande.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'Necesito ayuda por favor');
    await tester.tap(find.text('Mostrar en grande'));
    await tester.pumpAndSettle();

    expect(find.text('Necesito ayuda por favor'), findsOneWidget);
    expect(find.text('Girar 180°'), findsOneWidget);

    await tester.tap(find.text('Girar 180°'));
    await tester.pump();
    expect(find.text('Volver a mí'), findsOneWidget);

    final sizeBefore =
        tester.widget<Text>(find.text('Necesito ayuda por favor')).style?.fontSize;
    await tester.tap(find.byIcon(Icons.text_fields_rounded));
    await tester.pump();
    final sizeAfter =
        tester.widget<Text>(find.text('Necesito ayuda por favor')).style?.fontSize;
    expect(sizeBefore, 40.0);
    expect(sizeAfter, 52.0);
  });

  testWidgets('Presentación editable permite guardado opt-in y actualiza preferencia', (
    WidgetTester tester,
  ) async {
    String? savedCallbackText;

    await tester.pumpWidget(
      createShowMessageScreen(
        initialText: AppPreferences.defaultPresentationText,
        isPresentation: true,
        onSavePresentation: (text) => savedCallbackText = text,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Presentarme'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(
      find.text('Guardar como mi presentación habitual'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byType(TextField),
      'Hola, tengo hipoacusia. Podés escribirme aquí.',
    );
    await tester.tap(find.text('Guardar como mi presentación habitual'));
    await tester.pump();

    await tester.tap(find.text('Mostrar en grande'));
    await tester.pumpAndSettle();

    expect(
      find.text('Hola, tengo hipoacusia. Podés escribirme aquí.'),
      findsOneWidget,
    );
    expect(
      savedCallbackText,
      'Hola, tengo hipoacusia. Podés escribirme aquí.',
    );
  });

  testWidgets('Reproducir respeta preferencia readMessages y usa TopAlertBanner', (
    WidgetTester tester,
  ) async {
    final mockTts = MockTtsService();

    await tester.pumpWidget(
      createShowMessageScreen(
        initialText: 'Buen día, ¿tienen turno hoy?',
        overrides: [
          ...createTestOverrides(ttsService: mockTts),
          appPreferencesProvider.overrideWith(
            (ref) => const AppPreferences(readMessages: false),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reproducir'));
    await tester.pumpAndSettle();
    expect(find.byType(TopAlertBanner), findsOneWidget);
    expect(
      find.text('La reproducción de voz está desactivada en Preferencias.'),
      findsOneWidget,
    );
    expect(mockTts.speakCount, 0);

    await tester.pumpWidget(
      createShowMessageScreen(
        initialText: 'Buen día, ¿tienen turno hoy?',
        overrides: [
          ...createTestOverrides(ttsService: mockTts),
          appPreferencesProvider.overrideWith(
            (ref) => const AppPreferences(readMessages: true),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reproducir'));
    await tester.pump();
    expect(mockTts.speakCount, 1);
    expect(mockTts.lastSpokenText, 'Buen día, ¿tienen turno hoy?');
  });

  testWidgets('Modo oscuro en pantalla pequeña con texto grande sin desbordamientos', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320 * 3, 568 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      createShowMessageScreen(
        initialText: AppPreferences.defaultPresentationText,
        isPresentation: true,
        theme: AppTheme.darkTheme,
        textScale: 1.35,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Presentarme'), findsOneWidget);
    expect(find.text('Reproducir'), findsOneWidget);
    expect(find.text('Girar 180°'), findsOneWidget);
  });

  testWidgets('Alterna modo sol de contraste extremo para lectura en exteriores', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      createShowMessageScreen(
        initialText: 'Texto para sol directo',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.wb_sunny_outlined), findsOneWidget);
    expect(find.text('Texto para sol directo'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.wb_sunny_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);
    final textWidget = tester.widget<Text>(find.text('Texto para sol directo'));
    expect(textWidget.style?.color, Colors.black);
    expect(textWidget.style?.fontWeight, FontWeight.w900);

    // Vuelve a modo estándar
    await tester.tap(find.byIcon(Icons.wb_sunny_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.wb_sunny_outlined), findsOneWidget);
  });
}
