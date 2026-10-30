import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/storage/preferences_service.dart';
import 'package:puente/core/theme/app_theme.dart';
import 'package:puente/features/settings/settings_screen.dart';
import 'package:puente/main.dart';

void main() {
  late PreferencesService prefs;

  setUp(() {
    // Usamos el almacenamiento en memoria desacoplado de la plataforma
    prefs = PreferencesService.inMemory();
    PreferencesService.setMockInstance(prefs);
  });

  Widget createSettingsScreen() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: prefs.themeMode,
      home: const SettingsScreen(),
    );
  }

  testWidgets('SettingsScreen loads defaults and updates themeMode in PreferencesService',
      (WidgetTester tester) async {
    await tester.pumpWidget(createSettingsScreen());
    await tester.pumpAndSettle();

    expect(find.text('Preferencias'), findsOneWidget);
    expect(find.text('Sistema'), findsOneWidget);

    // Abrir dropdown y seleccionar "Oscuro"
    await tester.tap(find.text('Sistema'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Oscuro').last);
    await tester.pumpAndSettle();

    expect(prefs.themeMode, equals(ThemeMode.dark));
  });

  testWidgets('SettingsScreen persists switch toggles', (WidgetTester tester) async {
    await tester.pumpWidget(createSettingsScreen());
    await tester.pumpAndSettle();

    expect(prefs.speakResponsesAutomatically, isFalse);

    // Tocar switch "Reproducir voz automáticamente"
    final speakSwitch = find.widgetWithText(
      SwitchListTile,
      'Reproducir voz automáticamente',
    );
    await tester.tap(speakSwitch);
    await tester.pumpAndSettle();

    expect(prefs.speakResponsesAutomatically, isTrue);
  });

  testWidgets('Tapping Borrar datos locales clears preferences and resets state',
      (WidgetTester tester) async {
    // Ajustar dimensiones del viewport para asegurar renderizado de lista completa (práctica de Gastos Compartidos)
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await prefs.setThemeMode(ThemeMode.dark);
    await prefs.setOnboardingCompleted(true);
    await prefs.setSpeakResponsesAutomatically(true);

    await tester.pumpWidget(createSettingsScreen());
    await tester.pumpAndSettle();

    expect(find.text('Oscuro'), findsOneWidget);

    // Desplazar hacia abajo en la lista para asegurar visibilidad del botón de borrado
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    final clearButton = find.text('Borrar datos locales');
    await tester.tap(clearButton);
    await tester.pumpAndSettle();

    expect(find.text('Borrar todos los datos locales'), findsOneWidget);
    expect(find.text('Borrar datos'), findsOneWidget);

    // Confirmar borrado
    await tester.tap(find.text('Borrar datos'));
    await tester.pumpAndSettle();

    expect(prefs.hasSeenOnboarding, isFalse);
    expect(prefs.themeMode, equals(ThemeMode.system));
    expect(prefs.speakResponsesAutomatically, isFalse);
    expect(find.text('Datos locales eliminados y preferencias restablecidas.'), findsOneWidget);
  });

  testWidgets('PuenteApp reactively updates themeMode via PreferencesService',
      (WidgetTester tester) async {
    await tester.pumpWidget(PuenteApp(
      preferencesService: prefs,
      showOnboarding: false,
    ));
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, equals(ThemeMode.system));

    // Cambiar a modo oscuro en el servicio
    await prefs.setThemeMode(ThemeMode.dark);
    await tester.pumpAndSettle();

    final updatedApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(updatedApp.themeMode, equals(ThemeMode.dark));
  });
}
