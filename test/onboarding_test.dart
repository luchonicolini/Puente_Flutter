import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puente/core/storage/preferences_service.dart';
import 'package:puente/features/home/home_screen.dart';
import 'package:puente/features/onboarding/onboarding_screen.dart';
import 'package:puente/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Onboarding flow matches design, navigation and persists completion',
      (WidgetTester tester) async {
    // Definir tamaño de pantalla estándar móvil
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const PuenteApp(showOnboarding: true));
    await tester.pumpAndSettle();

    // --- Pantalla 1: Bienvenida ---
    expect(find.text('Puente'), findsOneWidget);
    expect(find.text('Omitir'), findsOneWidget);
    expect(find.text('01 / 03'), findsOneWidget);
    expect(find.textContaining('Comunicarnos'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);
    // En la primera pantalla no debe haber botón "Volver"
    expect(find.text('Volver'), findsNothing);

    // Avanzar a Pantalla 2
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    // --- Pantalla 2: Conversación ---
    expect(find.text('02 / 03'), findsOneWidget);
    expect(find.textContaining('Escribí, hablá'), findsOneWidget);
    expect(find.text('Volver'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);

    // Probar retroceder a Pantalla 1
    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();
    expect(find.text('01 / 03'), findsOneWidget);

    // Volver a avanzar a Pantalla 2 y luego a Pantalla 3
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    // --- Pantalla 3: Autonomía ---
    expect(find.text('03 / 03'), findsOneWidget);
    expect(find.textContaining('Entendé y decidí'), findsOneWidget);
    expect(find.text('Volver'), findsOneWidget);
    expect(find.text('Empezar'), findsOneWidget);

    // Tocar "Empezar" debe navegar a HomeScreen y persistir estado
    await tester.tap(find.text('Empezar'));
    await tester.pumpAndSettle();

    // Verifica que HomeScreen se haya montado
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.textContaining('Iniciar\nconversación'), findsOneWidget);

    // Verifica que se haya guardado en preferencias
    final prefs = await PreferencesService.getInstance();
    expect(prefs.hasSeenOnboarding, isTrue);
  });

  testWidgets('Tapping Omitir immediately navigates to HomeScreen and persists completion',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const PuenteApp(showOnboarding: true));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);

    await tester.tap(find.text('Omitir'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.textContaining('Iniciar\nconversación'), findsOneWidget);

    final prefs = await PreferencesService.getInstance();
    expect(prefs.hasSeenOnboarding, isTrue);
  });

  testWidgets('PuenteApp opens HomeScreen directly when showOnboarding is false',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PuenteApp(showOnboarding: false));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });
}
