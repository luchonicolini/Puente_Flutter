import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/services/tts_service.dart';
import 'package:puente/core/storage/app_preferences_store.dart';
import 'package:puente/core/storage/quick_phrases_store.dart';
import 'package:puente/core/theme/app_theme.dart';
import 'package:puente/features/quick_phrases/quick_phrases_sheet.dart';
import 'package:puente/features/settings/settings_screen.dart';

import 'helpers/test_overrides.dart';

void main() {
  Widget createSettingsScreen({
    AppPreferences initialPreferences = const AppPreferences(),
    ValueChanged<AppPreferences>? onPreferencesChanged,
    MockTtsService? ttsService,
    MockQuickPhrasesStore? quickPhrasesStore,
    ThemeData? theme,
    double textScale = 1.0,
  }) {
    return ProviderScope(
      overrides: createTestOverrides(
        ttsService: ttsService,
        quickPhrasesStore: quickPhrasesStore,
      ),
      child: MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        builder: (context, child) {
          final data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          );
        },
        home: SettingsScreen(
          preferences: initialPreferences,
          onPreferencesChanged: onPreferencesChanged,
        ),
      ),
    );
  }

  testWidgets('Velocidad de voz actualiza preferencia y TtsService', (
    WidgetTester tester,
  ) async {
    final mockTts = MockTtsService();
    AppPreferences? saved;

    await tester.pumpWidget(
      createSettingsScreen(
        ttsService: mockTts,
        onPreferencesChanged: (prefs) => saved = prefs,
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Velocidad de voz'),
      150,
    );
    await tester.tap(find.text('Velocidad de voz'));
    await tester.pumpAndSettle();

    expect(find.text('Lenta'), findsOneWidget);
    await tester.tap(find.text('Lenta'));
    await tester.pumpAndSettle();

    expect(saved?.speechRate, 0.35);
    expect(mockTts.speechRate, 0.35);
    expect(mockTts.setSpeechRateCount, 1);
  });

  testWidgets('Editar frases abre QuickPhrasesSheet con opción de restaurar', (
    WidgetTester tester,
  ) async {
    final store = MockQuickPhrasesStore(initial: ['Frase personalizada']);

    await tester.pumpWidget(
      createSettingsScreen(quickPhrasesStore: store),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Editar frases'), 150);
    await tester.tap(find.text('Editar frases'));
    await tester.pumpAndSettle();

    expect(find.byType(QuickPhrasesSheet), findsOneWidget);
    expect(find.text('Frase personalizada'), findsOneWidget);
    expect(find.text('Restaurar predeterminadas'), findsOneWidget);

    await tester.tap(find.text('Restaurar predeterminadas'));
    await tester.pumpAndSettle();

    expect(find.text('Hola, ¿cuánto cuesta esto?'), findsOneWidget);
    expect(find.text('Frase personalizada'), findsNothing);
  });

  testWidgets('Muestra bloques informativos honestos para idioma y privacidad', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createSettingsScreen());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('No se guardan conversaciones'),
      150,
    );
    expect(find.text('No se guardan conversaciones'), findsOneWidget);
    expect(
      find.text('Español (Argentina) · Único idioma disponible en esta versión'),
      findsOneWidget,
    );
  });

  testWidgets('Switches de comunicación actualizan readMessages y vibrateAtEnd', (
    WidgetTester tester,
  ) async {
    AppPreferences? saved;

    await tester.pumpWidget(
      createSettingsScreen(onPreferencesChanged: (prefs) => saved = prefs),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Reproducir mensajes'), 150);
    await tester.tap(find.text('Reproducir mensajes'));
    await tester.pumpAndSettle();
    expect(saved?.readMessages, isFalse);

    await tester.scrollUntilVisible(
      find.text('Vibrar al terminar de transcribir'),
      150,
    );
    await tester.tap(find.text('Vibrar al terminar de transcribir'));
    await tester.pumpAndSettle();
    expect(saved?.vibrateAtEnd, isFalse);

    await tester.scrollUntilVisible(
      find.text('Asistencia con IA en Expresar'),
      150,
    );
    await tester.tap(find.text('Asistencia con IA en Expresar'));
    await tester.pumpAndSettle();
    expect(saved?.useExpressionAi, isTrue);
  });

  testWidgets('Texto de presentación permite editar, guardar y restaurar', (
    WidgetTester tester,
  ) async {
    AppPreferences? saved;

    await tester.pumpWidget(
      createSettingsScreen(onPreferencesChanged: (prefs) => saved = prefs),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Texto de presentación'), 150);
    expect(find.text('Predeterminado'), findsOneWidget);

    await tester.tap(find.text('Texto de presentación'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      'Hola, prefiero leer mensajes escritos.',
    );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(
      saved?.presentationText,
      'Hola, prefiero leer mensajes escritos.',
    );
    expect(find.text('Personalizado'), findsOneWidget);

    await tester.tap(find.text('Texto de presentación'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restaurar predeterminado'));
    await tester.pump();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(
      saved?.presentationText,
      AppPreferences.defaultPresentationText,
    );
    expect(find.text('Predeterminado'), findsOneWidget);
  });

  testWidgets('Modo oscuro en pantalla pequeña con texto grande sin desbordamientos', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320 * 3, 568 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      createSettingsScreen(theme: AppTheme.darkTheme, textScale: 1.35),
    );
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Texto de presentación'),
      find.byType(ListView),
      const Offset(0, -150),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Texto de presentación'));
    await tester.pumpAndSettle();

    expect(find.text('Restaurar predeterminado'), findsOneWidget);
  });
}
